enum GeofenceType { radius, polygon, unknown }

GeofenceType parseGeofenceType(String? s) {
  switch (s) {
    case 'radius':  return GeofenceType.radius;
    case 'polygon': return GeofenceType.polygon;
    default:        return GeofenceType.unknown;
  }
}

class Geofence {
  final int geofenceId;
  final String name;
  final GeofenceType type;
  final double lat;
  final double lng;
  /// Metres — null for polygons.
  final int? radius;
  final bool alertEntry;
  final bool alertExit;
  final List<String> alertMedium;
  final List<int> vehIds;
  final int vehCount;

  Geofence({
    required this.geofenceId,
    required this.name,
    required this.type,
    required this.lat,
    required this.lng,
    required this.radius,
    required this.alertEntry,
    required this.alertExit,
    required this.alertMedium,
    required this.vehIds,
    required this.vehCount,
  });

  factory Geofence.fromJson(Map<String, dynamic> j) => Geofence(
        geofenceId:  (j['geofence_id'] as num).toInt(),
        name:        (j['name'] ?? '').toString(),
        type:        parseGeofenceType(j['type'] as String?),
        lat:         (j['lat'] as num?)?.toDouble() ?? 0,
        lng:         (j['lng'] as num?)?.toDouble() ?? 0,
        radius:      (j['radius'] as num?)?.toInt(),
        alertEntry:  j['alert_entry'] == true,
        alertExit:   j['alert_exit']  == true,
        alertMedium: ((j['alert_medium'] as List?) ?? const [])
            .map((e) => e.toString()).toList(),
        vehIds: ((j['veh_ids'] as List?) ?? const [])
            .map((e) => (e as num).toInt()).toList(),
        vehCount: (j['veh_count'] as num?)?.toInt() ?? 0,
      );
}

class GeofencesResponse {
  final int total;
  final int page;
  final int perPage;
  final List<Geofence> geofences;

  GeofencesResponse({
    required this.total,
    required this.page,
    required this.perPage,
    required this.geofences,
  });

  factory GeofencesResponse.fromJson(Map<String, dynamic> j) =>
      GeofencesResponse(
        total:    (j['total']    as num?)?.toInt() ?? 0,
        page:     (j['page']     as num?)?.toInt() ?? 1,
        perPage:  (j['per_page'] as num?)?.toInt() ?? 50,
        geofences: ((j['geofences'] as List?) ?? const [])
            .map((e) => Geofence.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
