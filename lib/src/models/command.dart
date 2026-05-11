/// Engine command action.
enum EngineAction { stop, restore }

extension EngineActionWire on EngineAction {
  String get wire => this == EngineAction.stop ? 'stop' : 'restore';
}

class CommandResult {
  final String message;
  /// Relay state AFTER the command: true = engine ON, false = engine cut.
  final bool relay;
  CommandResult({required this.message, required this.relay});
  factory CommandResult.fromJson(Map<String, dynamic> j) => CommandResult(
        message: (j['msg'] ?? '').toString(),
        relay:   j['relay'] == true,
      );
}
