/// Vehicle status as reported by NepTrack.
enum VehicleStatus { running, stop, idle, overspeed, inactive, nodata, unknown }

VehicleStatus parseVehicleStatus(String? s) {
  switch (s) {
    case 'running':    return VehicleStatus.running;
    case 'stop':       return VehicleStatus.stop;
    case 'idle':       return VehicleStatus.idle;
    case 'overspeed':  return VehicleStatus.overspeed;
    case 'inactive':   return VehicleStatus.inactive;
    case 'nodata':     return VehicleStatus.nodata;
    default:           return VehicleStatus.unknown;
  }
}

/// Summary vehicle from `GET /vehicles`.
class Vehicle {
  final int vehId;
  final String imei;
  final String regNo;
  final String name;
  final String type;
  final VehicleStatus status;
  final double speed;
  final double todayKm;
  final double lat;
  final double lng;
  final double bearing;
  final double altitude;
  final int battery;
  final int gsm;
  final int sat;
  final bool gps;
  final bool charging;
  final bool relay;
  final double odometer;
  final String lastPlace;
  final DateTime? lastTime;
  final DateTime? stime;

  Vehicle({
    required this.vehId,
    required this.imei,
    required this.regNo,
    required this.name,
    required this.type,
    required this.status,
    required this.speed,
    required this.todayKm,
    required this.lat,
    required this.lng,
    required this.bearing,
    required this.altitude,
    required this.battery,
    required this.gsm,
    required this.sat,
    required this.gps,
    required this.charging,
    required this.relay,
    required this.odometer,
    required this.lastPlace,
    required this.lastTime,
    required this.stime,
  });

  factory Vehicle.fromJson(Map<String, dynamic> j) => Vehicle(
        vehId:     (j['veh_id'] as num).toInt(),
        imei:      (j['imei'] ?? '').toString(),
        regNo:     (j['reg_no'] ?? '').toString(),
        name:      (j['name'] ?? '').toString(),
        type:      (j['type'] ?? '').toString(),
        status:    parseVehicleStatus(j['status'] as String?),
        speed:     (j['speed'] as num?)?.toDouble() ?? 0,
        todayKm:   (j['today_km'] as num?)?.toDouble() ?? 0,
        lat:       (j['lat'] as num?)?.toDouble() ?? 0,
        lng:       (j['lng'] as num?)?.toDouble() ?? 0,
        bearing:   (j['bearing'] as num?)?.toDouble() ?? 0,
        altitude:  (j['altitude'] as num?)?.toDouble() ?? 0,
        battery:   (j['battery'] as num?)?.toInt() ?? 0,
        gsm:       (j['gsm']     as num?)?.toInt() ?? 0,
        sat:       (j['sat']     as num?)?.toInt() ?? 0,
        gps:       j['gps'] == true,
        charging:  j['charging'] == true,
        relay:     j['relay'] == true,
        odometer:  (j['odometer'] as num?)?.toDouble() ?? 0,
        lastPlace: (j['last_place'] ?? '').toString(),
        lastTime:  _ms(j['last_time']),
        stime:     _ms(j['stime']),
      );
}

/// Detailed vehicle from `GET /vehicles/{veh_id}`.
class VehicleDetail {
  final int vehId;
  final String regNo;
  final String name;
  final String type;
  /// Overspeed threshold km/h.
  final double overspeed;
  final double odometer;
  /// km / litre.
  final double mileage;
  /// Low fuel threshold (%).
  final int lowFuel;

  VehicleDetail({
    required this.vehId,
    required this.regNo,
    required this.name,
    required this.type,
    required this.overspeed,
    required this.odometer,
    required this.mileage,
    required this.lowFuel,
  });

  factory VehicleDetail.fromJson(Map<String, dynamic> j) => VehicleDetail(
        vehId:     (j['veh_id'] as num).toInt(),
        regNo:     (j['reg_no'] ?? '').toString(),
        name:      (j['name'] ?? '').toString(),
        type:      (j['type'] ?? '').toString(),
        overspeed: double.tryParse((j['ospeed'] ?? '0').toString()) ?? 0,
        odometer:  (j['odometer'] as num?)?.toDouble() ?? 0,
        mileage:   (j['milage']   as num?)?.toDouble() ?? 0,
        lowFuel:   (j['low_fuel'] as num?)?.toInt() ?? 0,
      );
}

class VehicleCounts {
  final int all, running, stop, idle, overspeed, inactive, nodata;
  VehicleCounts({
    required this.all,
    required this.running,
    required this.stop,
    required this.idle,
    required this.overspeed,
    required this.inactive,
    required this.nodata,
  });
  factory VehicleCounts.fromJson(Map<String, dynamic> j) => VehicleCounts(
        all:       (j['all']       as num?)?.toInt() ?? 0,
        running:   (j['running']   as num?)?.toInt() ?? 0,
        stop:      (j['stop']      as num?)?.toInt() ?? 0,
        idle:      (j['idle']      as num?)?.toInt() ?? 0,
        overspeed: (j['overspeed'] as num?)?.toInt() ?? 0,
        inactive:  (j['inactive']  as num?)?.toInt() ?? 0,
        nodata:    (j['nodata']    as num?)?.toInt() ?? 0,
      );
}

class VehicleListResponse {
  final List<Vehicle> vehicles;
  final VehicleCounts counts;
  VehicleListResponse({
    required this.vehicles,
    required this.counts,
  });
  factory VehicleListResponse.fromJson(Map<String, dynamic> j) =>
      VehicleListResponse(
        vehicles: ((j['vehicles'] as List?) ?? const [])
            .map((e) => Vehicle.fromJson(e as Map<String, dynamic>))
            .toList(),
        counts: VehicleCounts.fromJson(
            (j['counts'] as Map?)?.cast<String, dynamic>() ?? const {}),
      );
}

DateTime? _ms(Object? v) {
  if (v == null) return null;
  final n = v is num ? v.toInt() : int.tryParse(v.toString());
  if (n == null || n == 0) return null;
  return DateTime.fromMillisecondsSinceEpoch(n);
}
