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

  /// Entries recorded within the most recent [window].
  ///
  /// Returns entries with `timestamp >= DateTime.now() - window`,
  /// preserving chronological insertion order. Returns an empty list
  /// when no entries fall inside the window.
  List<StateEntry> diffSince(Duration window) {
    final cutoff = DateTime.now().subtract(window);
    return _entries
        .where((e) => !e.timestamp.isBefore(cutoff))
        .toList();
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

  /// Export all entries as a list of JSON-compatible maps.
  ///
  /// Each map contains `timestamp` (ISO8601), `label`, `newValue`,
  /// and `previousValue` keys.
  List<Map<String, dynamic>> exportJson() {
    return _entries.map((e) => {
      'timestamp': e.timestamp.toIso8601String(),
      'label': e.label,
      'newValue': e.newValue,
      'previousValue': e.previousValue,
    }).toList();
  }

  /// Export all entries as a CSV string.
  ///
  /// Includes a header row: `timestamp,label,new_value,previous_value`
  /// followed by one row per entry. Values containing commas are
  /// wrapped in double quotes.
  String exportCsv() {
    final buffer = StringBuffer();
    buffer.writeln('timestamp,label,new_value,previous_value');
    for (final entry in _entries) {
      final timestamp = _csvEscape(entry.timestamp.toIso8601String());
      final label = _csvEscape(entry.label);
      final newValue = _csvEscape(entry.newValue);
      final previousValue = _csvEscape(entry.previousValue ?? '');
      buffer.writeln('$timestamp,$label,$newValue,$previousValue');
    }
    return buffer.toString();
  }

  String _csvEscape(String value) {
    if (value.contains(',')) {
      return '"$value"';
    }
    return value;
  }
}
