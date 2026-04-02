/// Record of a single state change event.
class StateEntry {
  /// When the state change occurred.
  final DateTime timestamp;

  /// Label identifying the source of the state change.
  final String label;

  /// The previous state value, if available.
  final String? previousValue;

  /// The new state value.
  final String newValue;

  /// Create a new state entry.
  const StateEntry({
    required this.timestamp,
    required this.label,
    required this.newValue,
    this.previousValue,
  });
}
