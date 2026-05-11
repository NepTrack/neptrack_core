import 'vehicle.dart' show VehicleStatus, parseVehicleStatus;

class MotionLog {
  final int motionId;
  final int vehId;
  final String regNo;
  final String vehName;
  final String vehType;
  final VehicleStatus fromStatus;
  final VehicleStatus toStatus;
  final double speed;
  final double lat;
  final double lon;
  final DateTime eventTime;
  final String eventFmt;
  final String receivedFmt;
  final String timeAgo;

  MotionLog({
    required this.motionId,
    required this.vehId,
    required this.regNo,
    required this.vehName,
    required this.vehType,
    required this.fromStatus,
    required this.toStatus,
    required this.speed,
    required this.lat,
    required this.lon,
    required this.eventTime,
    required this.eventFmt,
    required this.receivedFmt,
    required this.timeAgo,
  });

  factory MotionLog.fromJson(Map<String, dynamic> j) => MotionLog(
        motionId:    (j['motion_id'] as num).toInt(),
        vehId:       (j['veh_id']    as num).toInt(),
        regNo:       (j['reg_no']    ?? '').toString(),
        vehName:     (j['veh_name']  ?? '').toString(),
        vehType:     (j['veh_type']  ?? '').toString(),
        fromStatus:  parseVehicleStatus(j['from_status'] as String?),
        toStatus:    parseVehicleStatus(j['to_status']   as String?),
        speed:       (j['speed'] as num?)?.toDouble() ?? 0,
        lat:         (j['lat']   as num?)?.toDouble() ?? 0,
        lon:         (j['lon']   as num?)?.toDouble() ?? 0,
        eventTime:   DateTime.fromMillisecondsSinceEpoch(
                       (j['event_time_ms'] as num).toInt()),
        eventFmt:    (j['event_fmt']    ?? '').toString(),
        receivedFmt: (j['received_fmt'] ?? '').toString(),
        timeAgo:     (j['time_ago']     ?? '').toString(),
      );
}

class MotionLogsResponse {
  final int total;
  final int page;
  final int perPage;
  final List<MotionLog> motions;

  MotionLogsResponse({
    required this.total,
    required this.page,
    required this.perPage,
    required this.motions,
  });

  factory MotionLogsResponse.fromJson(Map<String, dynamic> j) =>
      MotionLogsResponse(
        total:   (j['total']    as num?)?.toInt() ?? 0,
        page:    (j['page']     as num?)?.toInt() ?? 1,
        perPage: (j['per_page'] as num?)?.toInt() ?? 50,
        motions: ((j['motions'] as List?) ?? const [])
            .map((e) => MotionLog.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
