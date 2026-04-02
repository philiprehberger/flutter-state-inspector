import 'state_logger.dart';
import 'rebuild_tracker.dart';

/// State inspection manager for debugging Flutter apps.
///
/// Provides a singleton [instance] that combines [StateLogger] for
/// recording state changes and [RebuildTracker] for counting widget rebuilds.
class StateInspector {
  /// Shared instance.
  static final StateInspector instance = StateInspector._();

  /// Log of state changes.
  final StateLogger logger = StateLogger();

  /// Widget rebuild counter.
  final RebuildTracker tracker = RebuildTracker();

  /// Whether the overlay is currently visible.
  bool isVisible = false;

  StateInspector._();

  /// Record a state change.
  void logState(String label, String value, {String? previous}) {
    logger.add(label: label, newValue: value, previousValue: previous);
  }

  /// Record a widget rebuild.
  void trackRebuild(String widgetName) {
    tracker.increment(widgetName);
  }

  /// Show the overlay.
  void show() => isVisible = true;

  /// Hide the overlay.
  void hide() => isVisible = false;

  /// Toggle visibility.
  void toggle() => isVisible = !isVisible;

  /// Reset all tracked data.
  void reset() {
    logger.clear();
    tracker.reset();
    isVisible = false;
  }
}
