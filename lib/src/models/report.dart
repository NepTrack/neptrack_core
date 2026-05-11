import 'vehicle.dart' show VehicleStatus, parseVehicleStatus;

class ReportVehicle {
  final String regNo;
  final String name;
  final String type;
  final VehicleStatus status;
  final double todayKm;
  final double speed;
  final String lastPlace;
  final DateTime? lastTime;

  ReportVehicle({
    required this.regNo,
    required this.name,
    required this.type,
    required this.status,
    required this.todayKm,
    required this.speed,
    required this.lastPlace,
    required this.lastTime,
  });

  factory ReportVehicle.fromJson(Map<String, dynamic> j) => ReportVehicle(
        regNo:     (j['reg_no'] ?? '').toString(),
        name:      (j['name']   ?? '').toString(),
        type:      (j['type']   ?? '').toString(),
        status:    parseVehicleStatus(j['status'] as String?),
        todayKm:   (j['today_km'] as num?)?.toDouble() ?? 0,
        speed:     (j['speed']    as num?)?.toDouble() ?? 0,
        lastPlace: (j['last_place'] ?? '').toString(),
        lastTime:  (j['last_time'] is num)
            ? DateTime.fromMillisecondsSinceEpoch((j['last_time'] as num).toInt())
            : null,
      );
}

class ReportStats {
  final double totalKm;
  final Duration running, idle, overspeed, stop;
  final double maxSpeed;
  final int trips;

  ReportStats({
    required this.totalKm,
    required this.running,
    required this.idle,
    required this.overspeed,
    required this.stop,
    required this.maxSpeed,
    required this.trips,
  });

  factory ReportStats.fromJson(Map<String, dynamic> j) => ReportStats(
        totalKm:   (j['total_km'] as num?)?.toDouble() ?? 0,
        running:   Duration(milliseconds: (j['running_ms']   as num?)?.toInt() ?? 0),
        idle:      Duration(milliseconds: (j['idle_ms']      as num?)?.toInt() ?? 0),
        overspeed: Duration(milliseconds: (j['overspeed_ms'] as num?)?.toInt() ?? 0),
        stop:      Duration(milliseconds: (j['stop_ms']      as num?)?.toInt() ?? 0),
        maxSpeed:  (j['max_speed'] as num?)?.toDouble() ?? 0,
        trips:     (j['trips'] as num?)?.toInt() ?? 0,
      );
}

class DailyStat {
  final String date;
  final double km;
  final double avgSpeed;
  final double overspeed;

  DailyStat({
    required this.date,
    required this.km,
    required this.avgSpeed,
    required this.overspeed,
  });

  factory DailyStat.fromJson(Map<String, dynamic> j) => DailyStat(
        date:      (j['date'] ?? '').toString(),
        km:        (j['km']      as num?)?.toDouble() ?? 0,
        avgSpeed:  (j['aspeed']  as num?)?.toDouble() ?? 0,
        overspeed: (j['ospeed']  as num?)?.toDouble() ?? 0,
      );
}

class ReportResponse {
  final ReportVehicle vehicle;
  final ReportStats stats;
  final List<DailyStat> table;

  ReportResponse({
    required this.vehicle,
    required this.stats,
    required this.table,
  });

  factory ReportResponse.fromJson(Map<String, dynamic> j) => ReportResponse(
        vehicle: ReportVehicle.fromJson(
            (j['vehicle'] as Map).cast<String, dynamic>()),
        stats:   ReportStats.fromJson(
            (j['stats'] as Map).cast<String, dynamic>()),
        table:   ((j['table'] as List?) ?? const [])
            .map((e) => DailyStat.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
