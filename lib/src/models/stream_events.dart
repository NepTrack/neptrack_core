import 'vehicle.dart' show VehicleStatus, parseVehicleStatus;

/// Real-time `position` event from the Data Stream API.
///
/// Note: [speed] is in **knots** as delivered by the server. Use [speedKmh]
/// for km/h.
class PositionEvent {
  final String imei;
  final bool valid;
  final double latitude;
  final double longitude;
  /// Speed in **knots** — multiply by 1.852 for km/h (see [speedKmh]).
  final double speed;
  /// Heading in degrees (0–360).
  final double course;
  final double altitude;
  final VehicleStatus motionStatus;
  final String lastPlace;
  /// GSM signal strength 0–5.
  final int gsmSignal;
  final DateTime? fixTime;
  final DateTime? deviceTime;
  /// Active alarm keys e.g. `["sos", "overspeed"]`.
  final List<String> alarms;
  final PositionAttributes attributes;
  /// Original payload — kept for forward compatibility.
  final Map<String, dynamic> raw;

  PositionEvent({
    required this.imei,
    required this.valid,
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.course,
    required this.altitude,
    required this.motionStatus,
    required this.lastPlace,
    required this.gsmSignal,
    required this.fixTime,
    required this.deviceTime,
    required this.alarms,
    required this.attributes,
    required this.raw,
  });

  double get speedKmh => speed * 1.852;

  factory PositionEvent.fromJson(Map<String, dynamic> j) => PositionEvent(
        imei:         (j['imei'] ?? '').toString(),
        valid:        j['valid'] == true,
        latitude:     (j['latitude']  as num?)?.toDouble() ?? 0,
        longitude:    (j['longitude'] as num?)?.toDouble() ?? 0,
        speed:        (j['speed']     as num?)?.toDouble() ?? 0,
        course:       (j['course']    as num?)?.toDouble() ?? 0,
        altitude:     (j['altitude']  as num?)?.toDouble() ?? 0,
        motionStatus: parseVehicleStatus(j['motionStatus'] as String?),
        lastPlace:    (j['lastPlace'] ?? '').toString(),
        gsmSignal:    (j['gsmSignal'] as num?)?.toInt() ?? 0,
        fixTime:      _ms(j['fixTime']),
        deviceTime:   _ms(j['deviceTime']),
        alarms:       ((j['alarms'] as List?) ?? const [])
            .map((e) => e.toString()).toList(),
        attributes:   PositionAttributes.fromJson(
            (j['attributes'] as Map?)?.cast<String, dynamic>() ?? const {}),
        raw:          j,
      );
}

class PositionAttributes {
  final bool ignition;
  final bool charge;
  final int batteryLevel;
  final bool blocked;
  final int satellites;
  final DateTime? serverTime;

  PositionAttributes({
    required this.ignition,
    required this.charge,
    required this.batteryLevel,
    required this.blocked,
    required this.satellites,
    required this.serverTime,
  });

  factory PositionAttributes.fromJson(Map<String, dynamic> j) =>
      PositionAttributes(
        ignition:     j['ignition'] == true,
        charge:       j['charge']   == true,
        batteryLevel: (j['batteryLevel'] as num?)?.toInt() ?? 0,
        blocked:      j['blocked'] == true,
        satellites:   (j['satellites'] as num?)?.toInt() ?? 0,
        serverTime:   _ms(j['serverTime']),
      );
}

/// Real-time `alarm` event.
class AlarmEvent {
  final String imei;
  final List<String> alarms;
  final DateTime? eventTime;
  final Map<String, dynamic> raw;

  AlarmEvent({
    required this.imei,
    required this.alarms,
    required this.eventTime,
    required this.raw,
  });

  factory AlarmEvent.fromJson(Map<String, dynamic> j) => AlarmEvent(
        imei:      (j['imei'] ?? '').toString(),
        alarms:    ((j['alarms'] as List?) ?? const [])
            .map((e) => e.toString()).toList(),
        eventTime: _ms(j['fixTime'] ?? j['deviceTime'] ?? j['serverTime']),
        raw:       j,
      );
}

/// Real-time `motion` event — fired on motion status transitions.
class MotionEvent {
  final String imei;
  final VehicleStatus motionStatus;
  final DateTime? eventTime;
  final Map<String, dynamic> raw;

  MotionEvent({
    required this.imei,
    required this.motionStatus,
    required this.eventTime,
    required this.raw,
  });

  factory MotionEvent.fromJson(Map<String, dynamic> j) => MotionEvent(
        imei:         (j['imei'] ?? '').toString(),
        motionStatus: parseVehicleStatus(j['motionStatus'] as String?),
        eventTime:    _ms(j['fixTime'] ?? j['deviceTime'] ?? j['serverTime']),
        raw:          j,
      );
}

DateTime? _ms(Object? v) {
  if (v == null) return null;
  final n = v is num ? v.toInt() : int.tryParse(v.toString());
  if (n == null || n == 0) return null;
  return DateTime.fromMillisecondsSinceEpoch(n);
}
