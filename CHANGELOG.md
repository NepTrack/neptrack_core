# Changelog

## 0.2.0 — 2026-05-11

### Added
- `NeptrackStreamClient` — Socket.IO v2 client for the real-time Data Stream
  API. Exposes `positions`, `alarms`, `motions`, `errors`, `onConnect`,
  `onDisconnect` broadcast streams plus per-IMEI `positionsFor` /
  `alarmsFor` / `motionsFor` filters.
- `PositionEvent`, `AlarmEvent`, `MotionEvent`, `PositionAttributes`,
  `StreamError` models.
- `AlarmsResponse` now carries `page` and `perPage` to match
  `MotionLogsResponse`.

### Fixed
- `VehicleDetail.lowFuel` now reads the correct response field
  (`low_fuel`, previously the typo `lfule`) — values were always 0.

### Breaking changes
- Removed phantom fields that were never returned by the server:
  - `VehicleDetail.public` and `VehicleDetail.publicPrivacy`
  - `Vehicle.shared` and `Vehicle.groups`
  - `VehicleListResponse.groups` and the `VehicleGroup` class
- `AlarmsResponse` constructor now requires `page` and `perPage`.

## 0.1.0

- Initial release: REST client for vehicles, history, reports, alarms,
  motion logs, geofences, and engine commands.
