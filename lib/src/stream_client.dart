import 'dart:async';
import 'dart:convert';

import 'package:socket_io_client/socket_io_client.dart' as io;

import 'models/stream_events.dart';

/// NepTrack Data Stream API client — Socket.IO v2.
///
/// Required scope on the API token: **live_stream**. Up to 5 concurrent
/// streams per vehicle per token. The server is pinned to Socket.IO v2,
/// so `socket_io_client: ^1.0.2` is used under the hood.
///
/// The WebSocket URL is provided by NepTrack support / your account dashboard.
///
/// Usage:
/// ```dart
/// final stream = NeptrackStreamClient(
///   url: 'wss://...',
///   token: 'npt_...',
/// );
///
/// stream.positions.listen((p) => print('${p.imei}: ${p.speedKmh} km/h'));
/// stream.alarms.listen((a) => print('ALARM ${a.imei} ${a.alarms}'));
/// stream.motions.listen((m) => print('MOTION ${m.imei} ${m.motionStatus}'));
///
/// stream.connect();
/// stream.subscribe('355000000000001');
///
/// // when done:
/// await stream.close();
/// ```
class NeptrackStreamClient {
  /// WebSocket URL (e.g. `wss://your-host`).
  final String url;

  /// API token — must include the `live_stream` scope.
  final String token;

  /// Restrict to `websocket` only (no long-polling fallback).
  final bool websocketOnly;

  final io.Socket _socket;
  final _positions = StreamController<PositionEvent>.broadcast();
  final _alarms    = StreamController<AlarmEvent>.broadcast();
  final _motions   = StreamController<MotionEvent>.broadcast();
  final _errors    = StreamController<StreamError>.broadcast();
  final _connects    = StreamController<void>.broadcast();
  final _disconnects = StreamController<String?>.broadcast();
  final Set<String> _subscriptions = {};
  bool _closed = false;

  NeptrackStreamClient({
    required this.token,
    required this.url,
    this.websocketOnly = true,
  }) : _socket = io.io(
          url,
          (io.OptionBuilder()
                ..setTransports(
                    websocketOnly ? ['websocket'] : ['websocket', 'polling'])
                ..setQuery({'token': token})
                ..disableAutoConnect())
              .build(),
        ) {
    _wire();
  }

  // ── Streams ────────────────────────────────────────────────────────────────

  /// `position` events.
  Stream<PositionEvent> get positions => _positions.stream;

  /// `alarm` events.
  Stream<AlarmEvent> get alarms => _alarms.stream;

  /// `motion` events — fired on motion status transitions.
  Stream<MotionEvent> get motions => _motions.stream;

  /// Authentication failures and decode errors.
  Stream<StreamError> get errors => _errors.stream;

  /// Connect lifecycle events.
  Stream<void> get onConnect => _connects.stream;

  /// Disconnect events — payload is the disconnect reason string (may be null).
  Stream<String?> get onDisconnect => _disconnects.stream;

  /// Filter [positions] by IMEI.
  Stream<PositionEvent> positionsFor(String imei) =>
      positions.where((e) => e.imei == imei);

  /// Filter [alarms] by IMEI.
  Stream<AlarmEvent> alarmsFor(String imei) =>
      alarms.where((e) => e.imei == imei);

  /// Filter [motions] by IMEI.
  Stream<MotionEvent> motionsFor(String imei) =>
      motions.where((e) => e.imei == imei);

  // ── Control ────────────────────────────────────────────────────────────────

  /// Open the connection. Re-subscribes to all previously subscribed IMEIs
  /// on every (re)connect.
  void connect() {
    if (_closed) {
      throw StateError('NeptrackStreamClient has been closed.');
    }
    _socket.connect();
  }

  /// Subscribe to a single vehicle by IMEI. Safe to call before [connect];
  /// the subscription is replayed once the connection is established.
  void subscribe(String imei) {
    _subscriptions.add(imei);
    if (_socket.connected) _socket.emit('subscribe', imei);
  }

  /// Subscribe to multiple IMEIs.
  void subscribeAll(Iterable<String> imeis) {
    for (final i in imeis) {
      subscribe(i);
    }
  }

  /// IMEIs currently subscribed (locally tracked).
  Set<String> get subscriptions => Set.unmodifiable(_subscriptions);

  /// Whether the socket is currently connected.
  bool get connected => _socket.connected;

  /// Disconnect and release all resources. The instance cannot be reused.
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    _socket.dispose();
    await Future.wait([
      _positions.close(),
      _alarms.close(),
      _motions.close(),
      _errors.close(),
      _connects.close(),
      _disconnects.close(),
    ]);
  }

  // ── Internal ───────────────────────────────────────────────────────────────

  void _wire() {
    _socket.onConnect((_) {
      for (final imei in _subscriptions) {
        _socket.emit('subscribe', imei);
      }
      _connects.add(null);
    });

    _socket.on('position', (data) {
      final j = _toMap(data);
      if (j != null) _positions.add(PositionEvent.fromJson(j));
    });
    _socket.on('alarm', (data) {
      final j = _toMap(data);
      if (j != null) _alarms.add(AlarmEvent.fromJson(j));
    });
    _socket.on('motion', (data) {
      final j = _toMap(data);
      if (j != null) _motions.add(MotionEvent.fromJson(j));
    });

    _socket.onConnectError((err) {
      final msg = err?.toString() ?? 'connect_error';
      _errors.add(StreamError(
        message: msg,
        unauthorized: msg.contains('Unauthorized'),
      ));
    });
    _socket.onError((err) {
      _errors.add(StreamError(message: err?.toString() ?? 'error'));
    });
    _socket.onDisconnect((reason) {
      _disconnects.add(reason?.toString());
    });
  }

  Map<String, dynamic>? _toMap(dynamic data) {
    try {
      if (data is Map) return data.cast<String, dynamic>();
      if (data is String) {
        final parsed = jsonDecode(data);
        if (parsed is Map) return parsed.cast<String, dynamic>();
      }
    } catch (e) {
      _errors.add(StreamError(message: 'decode error: $e'));
    }
    return null;
  }
}

/// Stream-side error (authentication, decode, or transport).
class StreamError {
  final String message;
  final bool unauthorized;
  StreamError({required this.message, this.unauthorized = false});

  @override
  String toString() =>
      'StreamError(${unauthorized ? "Unauthorized — " : ""}$message)';
}
