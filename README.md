# neptrack_core

Pure Dart SDK for the [NepTrack](https://neptrack.com) GPS tracking platform — REST API + real-time Data Stream.

No Flutter dependencies — works in Flutter apps, Dart server processes, and CLI tools.

> Manage tokens on the [NepTrack dashboard](https://neptrack.com) → **API Integration → API Tokens**.

## Install

```yaml
dependencies:
  neptrack_core: ^0.2.0
```

## Authentication

Generate an API token from the dashboard under **API Integration → API Tokens**. Each token has scopes; calls that require a scope your token doesn't have will throw `NeptrackScopeException`.

## Quick start

```dart
import 'package:neptrack_core/neptrack_core.dart';

final client = NeptrackClient(token: 'npt_...');

final list = await client.listVehicles();
for (final v in list.vehicles) {
  print('${v.regNo}  ${v.status.name}  ${v.speed} km/h');
}

client.close();
```

## REST endpoints

| Method                          | Endpoint                          | Required scope    |
|---------------------------------|-----------------------------------|-------------------|
| `listVehicles()`                | `GET  /vehicles`                  | `vehicles`        |
| `vehicleDetail(id)`             | `GET  /vehicles/{id}`             | `vehicle_details` |
| `vehicleHistory(id, …)`         | `GET  /vehicles/{id}/history`     | `history`         |
| `vehicleReport(id, …)`          | `GET  /vehicles/{id}/report`      | `reports`         |
| `listAlarms(…)`                 | `GET  /alarms`                    | `alarms`          |
| `listMotionLogs(…)`             | `GET  /motion-logs`               | `motion_logs`     |
| `listGeofences(…)`              | `GET  /geofences`                 | `geofence`        |
| `sendCommand(id, action)`       | `POST /vehicles/{id}/command`     | `command`         |

## Real-time Data Stream

`NeptrackStreamClient` is a Socket.IO v2 client for live `position`, `alarm`,
and `motion` events. Token must include the **`live_stream`** scope.

```dart
import 'package:neptrack_core/neptrack_core.dart';

final stream = NeptrackStreamClient(
  url:   'wss://...',  // ask NepTrack support for your stream endpoint
  token: 'npt_...',
);

stream.positions.listen((p) {
  print('${p.imei}  ${p.latitude},${p.longitude}  ${p.speedKmh.toStringAsFixed(1)} km/h');
});
stream.alarms.listen ((a) => print('ALARM  ${a.imei} ${a.alarms}'));
stream.motions.listen((m) => print('MOTION ${m.imei} ${m.motionStatus.name}'));
stream.errors.listen ((e) {
  if (e.unauthorized) print('Token invalid / missing live_stream scope');
});

stream.connect();
stream.subscribe('355000000000001');     // by IMEI
// or: stream.subscribeAll(['355...', '355...']);

// later:
await stream.close();
```

Per-IMEI filters: `stream.positionsFor(imei)`, `alarmsFor(imei)`, `motionsFor(imei)`.

Server-side: up to **5 concurrent streams per vehicle**, Socket.IO **v2 only**
(v3/v4 clients are not compatible — that's why this SDK pins
`socket_io_client: ^1.0.2`).

## Error handling

All errors derive from `NeptrackException`:

| Exception                       | Cause                                     |
|---------------------------------|-------------------------------------------|
| `NeptrackAuthException` (401)   | Missing / invalid / revoked token         |
| `NeptrackScopeException` (403)  | Token lacks the scope for this endpoint   |
| `NeptrackRateLimitException`    | Too many failed auth attempts             |
| `NeptrackApiException`          | Endpoint returned `err: true`             |
| `NeptrackException`             | Anything else (network, 5xx, etc.)        |

```dart
try {
  await client.listVehicles();
} on NeptrackAuthException {
  // re-prompt for token
} on NeptrackException catch (e) {
  print('Failed: ${e.message}');
}
```

Stream-side errors arrive on `stream.errors` as `StreamError` values
(`unauthorized: true` indicates token / scope issues).

## Engine command

`sendCommand` cuts or restores engine power via the device relay. **This is a physical action — never call `stop` while the vehicle is in motion.**

```dart
await client.sendCommand(vehId, EngineAction.stop);
await client.sendCommand(vehId, EngineAction.restore);
```

## Custom endpoints (self-hosted)

```dart
NeptrackClient(
  token:   'npt_...',
  baseUrl: 'https://your-instance.example.com/rest/v1',
);

NeptrackStreamClient(
  token: 'npt_...',
  url:   'wss://your-instance.example.com',
);
```

## Resources

- Website & dashboard — [neptrack.com](https://neptrack.com)
- Issues — [github.com/neptrack/neptrack_core/issues](https://github.com/neptrack/neptrack_core/issues)

## License

Apache-2.0 — see [LICENSE](LICENSE). © NepTrack.
