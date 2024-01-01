/// Tracks widget rebuild counts by widget name.
///
/// Use [increment] to record a rebuild and [topRebuilders] to find
/// the most frequently rebuilt widgets.
class RebuildTracker {
  final Map<String, int> _counts = {};

  /// Record a rebuild for [widgetName].
  void increment(String widgetName) {
    _counts[widgetName] = (_counts[widgetName] ?? 0) + 1;
  }

  /// Get the rebuild count for [widgetName].
  ///
  /// Returns 0 if the widget has not been tracked.
  int count(String widgetName) => _counts[widgetName] ?? 0;

  /// The [n] widgets with the highest rebuild counts, sorted descending.
  List<MapEntry<String, int>> topRebuilders(int n) {
    final sorted = _counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(n).toList();
  }

  /// Remove all tracked data.
  void reset() => _counts.clear();

  /// Total rebuild count across all widgets.
  int get total => _counts.values.fold(0, (sum, v) => sum + v);
}
