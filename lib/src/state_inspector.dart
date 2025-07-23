import 'performance_metrics.dart';
import 'state_logger.dart';
import 'rebuild_tracker.dart';

/// State inspection manager for debugging Flutter apps.
///
/// Provides a singleton [instance] that combines [StateLogger] for
/// recording state changes, [RebuildTracker] for counting widget rebuilds,
/// and [PerformanceMetrics] for frame timing analysis.
class StateInspector {
  /// Shared instance.
  static final StateInspector instance = StateInspector._();

  /// Log of state changes.
  final StateLogger logger = StateLogger();

  /// Widget rebuild counter.
  final RebuildTracker tracker = RebuildTracker();

  /// Frame timing and FPS metrics.
  final PerformanceMetrics _performance = PerformanceMetrics();

  /// Whether the overlay is currently visible.
  bool isVisible = false;

  StateInspector._();

  /// Performance metrics for frame timing analysis.
  PerformanceMetrics get performance => _performance;

  /// Record a state change.
  void logState(String label, String value, {String? previous}) {
    logger.add(label: label, newValue: value, previousValue: previous);
  }

  /// Record a widget rebuild.
  void trackRebuild(String widgetName) {
    tracker.increment(widgetName);
  }

  /// Record a frame duration for performance tracking.
  void trackFrame(Duration frameTime) {
    _performance.recordFrame(frameTime);
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
    _performance.reset();
    isVisible = false;
  }
}
