import 'package:neptrack_core/neptrack_core.dart';

Future<void> main() async {
  final client = NeptrackClient(
    token: 'npt_YOUR_TOKEN_HERE',
    // baseUrl: 'https://sys.neptrack.com/rest/v1', // override if needed
  );

  try {
    // 1. Vehicles list
    final list = await client.listVehicles();
    print('Vehicles: ${list.vehicles.length}');
    print('Running:  ${list.counts.running}');
    for (final v in list.vehicles) {
      print('  ${v.regNo}  ${v.status.name}  ${v.speed} km/h  '
            'at ${v.lat},${v.lng}');
    }

    if (list.vehicles.isEmpty) return;
    final v = list.vehicles.first;

    // 2. Vehicle detail
    final detail = await client.vehicleDetail(v.vehId);
    print('\nDetail: ${detail.regNo}  overspeed=${detail.overspeed}  '
          'mileage=${detail.mileage}');

    // 3. Today's history
    final hist = await client.vehicleHistory(v.vehId);
    print('\nHistory points: ${hist.points.length}');
    print('Trips: ${hist.trips.length}, stops: ${hist.stops.length}');

    // 4. 7-day report
    final report = await client.vehicleReport(v.vehId);
    print('\n7-day total: ${report.stats.totalKm} km, '
          'max speed ${report.stats.maxSpeed}, '
          'trips ${report.stats.trips}');

    // 5. Latest alarms
    final alarms = await client.listAlarms(page: 1);
    print('\nAlarms (page 1): ${alarms.alarms.length} of ${alarms.total}');

    // 6. Motion logs filtered to "running"
    final motions =
        await client.listMotionLogs(vehId: v.vehId, toStatus: 'running');
    print('\nMotion → running: ${motions.motions.length}');

    // 7. Geofences
    final fences = await client.listGeofences();
    print('\nGeofences: ${fences.geofences.length}');

    // 8. Engine command (commented — destructive!)
    // final cmd = await client.sendCommand(v.vehId, EngineAction.stop);
    // print(cmd.message);

  } on NeptrackAuthException catch (e) {
    print('Auth failed: $e');
  } on NeptrackScopeException catch (e) {
    print('Missing scope: $e');
  } on NeptrackRateLimitException catch (e) {
    print('Rate limited: $e');
  } on NeptrackException catch (e) {
    print('API error: $e');
  } finally {
    client.close();
  }
}
