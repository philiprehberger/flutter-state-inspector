import 'state_entry.dart';

/// Thread-safe log of state change entries.
///
/// Records [StateEntry] objects and provides methods to query,
/// filter, and export the history.
class StateLogger {
  final List<StateEntry> _entries = [];

  /// Add a new state change entry.
  void add({
    required String label,
    required String newValue,
    String? previousValue,
  }) {
    _entries.add(StateEntry(
      timestamp: DateTime.now(),
      label: label,
      newValue: newValue,
      previousValue: previousValue,
    ));
  }

  /// All recorded entries in insertion order.
  List<StateEntry> get all => List.unmodifiable(_entries);

  /// The most recent [n] entries.
  ///
  /// Returns fewer than [n] if fewer entries exist.
  List<StateEntry> recent(int n) {
    if (n >= _entries.length) return List.unmodifiable(_entries);
    return List.unmodifiable(_entries.sublist(_entries.length - n));
  }

  /// Filter entries by [label].
  List<StateEntry> filterByLabel(String label) {
    return _entries.where((e) => e.label == label).toList();
  }

  /// Remove all entries.
  void clear() => _entries.clear();

  /// Total number of recorded entries.
  int get count => _entries.length;

  /// Export all entries as a formatted string.
  ///
  /// Each line contains the timestamp, label, and value transition.
  String export() {
    final buffer = StringBuffer();
    for (final entry in _entries) {
      final time = entry.timestamp.toIso8601String();
      final prev = entry.previousValue;
      if (prev != null) {
        buffer.writeln('[$time] ${entry.label}: $prev -> ${entry.newValue}');
      } else {
        buffer.writeln('[$time] ${entry.label}: ${entry.newValue}');
      }
    }
    return buffer.toString();
  }
}
