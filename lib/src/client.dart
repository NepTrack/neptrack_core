import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

import 'exceptions.dart';
import 'models/alarm.dart';
import 'models/command.dart';
import 'models/geofence.dart';
import 'models/history.dart';
import 'models/motion_log.dart';
import 'models/report.dart';
import 'models/vehicle.dart';

/// NepTrack REST API client.
///
/// Authenticate by passing your API token (created on the NepTrack
/// dashboard → API Tokens page). Every call sends the token as
/// `Authorization: Bearer <token>`.
///
/// Usage:
/// ```dart
/// final client = NeptrackClient(token: 'npt_...');
/// final list   = await client.listVehicles();
/// ```
///
/// Call [close] when you are done to release the underlying HTTP client.
class NeptrackClient {
  /// Default production base URL.
  static const defaultBaseUrl = 'https://sys.neptrack.com/rest/v1';

  /// Base URL of the REST API — no trailing slash.
  final String baseUrl;

  /// API token (the `Bearer ...` value).
  final String token;

  /// Request timeout — applied per call.
  final Duration timeout;

  final http.Client _http;
  final bool _ownsClient;

  NeptrackClient({
    required this.token,
    this.baseUrl = defaultBaseUrl,
    this.timeout = const Duration(seconds: 30),
    http.Client? httpClient,
  })  : _http = httpClient ?? http.Client(),
        _ownsClient = httpClient == null;

  /// Release the underlying HTTP client.
  void close() {
    if (_ownsClient) _http.close();
  }

  // ── Vehicles ───────────────────────────────────────────────────────────────

  /// `GET /vehicles` — all vehicles with live status.
  /// Required scope: **vehicles**.
  Future<VehicleListResponse> listVehicles() async {
    final body = await _get('/vehicles');
    return VehicleListResponse.fromJson(body);
  }

  /// `GET /vehicles/{veh_id}` — configuration details for one vehicle.
  /// Required scope: **vehicle_details**.
  Future<VehicleDetail> vehicleDetail(int vehId) async {
    final body = await _get('/vehicles/$vehId');
    return VehicleDetail.fromJson(body);
  }

  // ── History ────────────────────────────────────────────────────────────────

  /// `GET /vehicles/{veh_id}/history`
  /// Required scope: **history**.
  ///
  /// [startDate] / [endDate] default to today on the server.
  Future<HistoryResponse> vehicleHistory(
    int vehId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final body = await _get(
      '/vehicles/$vehId/history',
      query: {
        if (startDate != null) 'sdate': _ymd(startDate),
        if (endDate != null)   'edate': _ymd(endDate),
      },
    );
    return HistoryResponse.fromJson(body);
  }

  // ── Reports ────────────────────────────────────────────────────────────────

  /// `GET /vehicles/{veh_id}/report` — per-day stats, max 31 days.
  /// Required scope: **reports**.
  Future<ReportResponse> vehicleReport(
    int vehId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final body = await _get(
      '/vehicles/$vehId/report',
      query: {
        if (startDate != null) 'start_date': _ymd(startDate),
        if (endDate != null)   'end_date':   _ymd(endDate),
      },
    );
    return ReportResponse.fromJson(body);
  }

  // ── Alarms ─────────────────────────────────────────────────────────────────

  /// `GET /alarms` — paginated alarm events (50 per page).
  /// Required scope: **alarms**.
  Future<AlarmsResponse> listAlarms({
    int? vehId,
    DateTime? date,
    int page = 1,
  }) async {
    final body = await _get('/alarms', query: {
      if (vehId != null) 'veh_id': vehId.toString(),
      if (date  != null) 'fdate':  _ymd(date),
      'page': page.toString(),
    });
    return AlarmsResponse.fromJson(body);
  }

  // ── Motion logs ────────────────────────────────────────────────────────────

  /// `GET /motion-logs` — paginated motion status changes (50 per page).
  /// Required scope: **motion_logs**.
  Future<MotionLogsResponse> listMotionLogs({
    int? vehId,
    String? toStatus,
    DateTime? date,
    int page = 1,
  }) async {
    final body = await _get('/motion-logs', query: {
      if (vehId    != null) 'veh_id': vehId.toString(),
      if (toStatus != null) 'fto':    toStatus,
      if (date     != null) 'fdate':  _ymd(date),
      'page': page.toString(),
    });
    return MotionLogsResponse.fromJson(body);
  }

  // ── Geofences ──────────────────────────────────────────────────────────────

  /// `GET /geofences` — paginated geofences (50 per page).
  /// Required scope: **geofence**.
  Future<GeofencesResponse> listGeofences({
    int? vehId,
    String? search,
    GeofenceType? type,
    int page = 1,
  }) async {
    final body = await _get('/geofences', query: {
      if (vehId  != null) 'veh_id': vehId.toString(),
      if (search != null && search.isNotEmpty) 'search': search,
      if (type   != null && type != GeofenceType.unknown)
        'ftype': type == GeofenceType.radius ? 'radius' : 'polygon',
      'page': page.toString(),
    });
    return GeofencesResponse.fromJson(body);
  }

  // ── Commands ───────────────────────────────────────────────────────────────

  /// `POST /vehicles/{veh_id}/command` — cut or restore engine power.
  /// Required scope: **command**.
  ///
  /// **Destructive.** Ensure the vehicle is safely parked before stopping.
  Future<CommandResult> sendCommand(int vehId, EngineAction action) async {
    final body = await _post(
      '/vehicles/$vehId/command',
      body: {'action': action.wire},
    );
    return CommandResult.fromJson(body);
  }

  // ── Internal ───────────────────────────────────────────────────────────────

  @visibleForTesting
  Future<Map<String, dynamic>> rawGet(String path,
          {Map<String, String>? query}) =>
      _get(path, query: query);

  Future<Map<String, dynamic>> _get(String path,
      {Map<String, String>? query}) async {
    final uri = _buildUri(path, query);
    final res = await _http
        .get(uri, headers: _headers())
        .timeout(timeout);
    return _decode(res);
  }

  Future<Map<String, dynamic>> _post(String path,
      {Map<String, dynamic>? body}) async {
    final uri = _buildUri(path, null);
    final res = await _http
        .post(uri,
            headers: {..._headers(), 'Content-Type': 'application/json'},
            body: jsonEncode(body ?? const {}))
        .timeout(timeout);
    return _decode(res);
  }

  Uri _buildUri(String path, Map<String, String>? query) {
    final cleanBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final url = '$cleanBase$path';
    final u = Uri.parse(url);
    if (query == null || query.isEmpty) return u;
    return u.replace(queryParameters: {
      ...u.queryParameters,
      ...query,
    });
  }

  Map<String, String> _headers() => {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };

  Map<String, dynamic> _decode(http.Response res) {
    final status = res.statusCode;

    // Try to parse JSON. Some error responses may not be JSON.
    Map<String, dynamic>? body;
    try {
      final raw = jsonDecode(res.body);
      if (raw is Map<String, dynamic>) body = raw;
    } catch (_) {/* ignore */}

    final msg = body?['msg']?.toString() ?? 'HTTP $status';

    switch (status) {
      case 401: throw NeptrackAuthException(msg);
      case 403: throw NeptrackScopeException(msg);
      case 429: throw NeptrackRateLimitException(msg);
    }
    if (status < 200 || status >= 300 || body == null) {
      throw NeptrackException(msg, statusCode: status);
    }
    if (body['err'] == true) {
      throw NeptrackApiException(msg);
    }
    return body;
  }

  static String _ymd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
