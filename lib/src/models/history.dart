import 'vehicle.dart' show VehicleStatus, parseVehicleStatus;

/// A single GPS fix from `GET /vehicles/{id}/history`.
class HistoryPoint {
  final double lat;
  final double lng;
  final double speed;
  final DateTime time;
  final VehicleStatus status;

  HistoryPoint({
    required this.lat,
    required this.lng,
    required this.speed,
    required this.time,
    required this.status,
  });

  factory HistoryPoint.fromJson(Map<String, dynamic> j) => HistoryPoint(
        lat:    (j['lat']   as num).toDouble(),
        lng:    (j['lng']   as num).toDouble(),
        speed:  (j['speed'] as num?)?.toDouble() ?? 0,
        time:   DateTime.fromMillisecondsSinceEpoch(
                  (j['time_ms'] as num).toInt()),
        status: parseVehicleStatus(j['status'] as String?),
      );
}

class Trip {
  final double lat1, lng1, lat2, lng2;
  final DateTime time1, time2;
  final int? placeId1, placeId2;
  /// km
  final double distance;
  final Duration duration;
  final double maxSpeed, avgSpeed;

  Trip({
    required this.lat1,
    required this.lng1,
    required this.lat2,
    required this.lng2,
    required this.time1,
    required this.time2,
    required this.placeId1,
    required this.placeId2,
    required this.distance,
    required this.duration,
    required this.maxSpeed,
    required this.avgSpeed,
  });

  factory Trip.fromJson(Map<String, dynamic> j) => Trip(
        lat1:     (j['lat1'] as num).toDouble(),
        lng1:     (j['lng1'] as num).toDouble(),
        lat2:     (j['lat2'] as num).toDouble(),
        lng2:     (j['lng2'] as num).toDouble(),
        time1:    DateTime.fromMillisecondsSinceEpoch((j['time1'] as num).toInt()),
        time2:    DateTime.fromMillisecondsSinceEpoch((j['time2'] as num).toInt()),
        placeId1: (j['place_id1'] as num?)?.toInt(),
        placeId2: (j['place_id2'] as num?)?.toInt(),
        distance: (j['distance'] as num?)?.toDouble() ?? 0,
        duration: Duration(milliseconds: (j['duration'] as num?)?.toInt() ?? 0),
        maxSpeed: (j['max_speed'] as num?)?.toDouble() ?? 0,
        avgSpeed: (j['avg_speed'] as num?)?.toDouble() ?? 0,
      );
}

class StopEvent {
  final double lat, lng;
  final int? placeId;
  final DateTime time1, time2;
  final Duration duration;

  StopEvent({
    required this.lat,
    required this.lng,
    required this.placeId,
    required this.time1,
    required this.time2,
    required this.duration,
  });

  factory StopEvent.fromJson(Map<String, dynamic> j) => StopEvent(
        lat:      (j['lat'] as num).toDouble(),
        lng:      (j['lng'] as num).toDouble(),
        placeId:  (j['place_id'] as num?)?.toInt(),
        time1:    DateTime.fromMillisecondsSinceEpoch((j['time1'] as num).toInt()),
        time2:    DateTime.fromMillisecondsSinceEpoch((j['time2'] as num).toInt()),
        duration: Duration(milliseconds: (j['duration'] as num?)?.toInt() ?? 0),
      );
}

class HistoryResponse {
  /// Vehicle's configured overspeed threshold (km/h).
  final double overspeedThreshold;
  final List<HistoryPoint> points;
  final List<Trip> trips;
  final List<StopEvent> stops;
  final Map<int, String> places;

  HistoryResponse({
    required this.overspeedThreshold,
    required this.points,
    required this.trips,
    required this.stops,
    required this.places,
  });

  factory HistoryResponse.fromJson(Map<String, dynamic> j) {
    final places = <int, String>{};
    final rawPlaces = (j['places'] as Map?) ?? const {};
    rawPlaces.forEach((k, v) {
      final id = int.tryParse(k.toString());
      if (id != null) places[id] = v.toString();
    });
    return HistoryResponse(
      overspeedThreshold: (j['overspeed'] as num?)?.toDouble() ?? 0,
      points: ((j['points'] as List?) ?? const [])
          .map((e) => HistoryPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      trips: ((j['trips'] as List?) ?? const [])
          .map((e) => Trip.fromJson(e as Map<String, dynamic>))
          .toList(),
      stops: ((j['stops'] as List?) ?? const [])
          .map((e) => StopEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      places: places,
    );
  }
}
