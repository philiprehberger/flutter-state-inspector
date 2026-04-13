import 'package:flutter/foundation.dart';

import 'performance_metrics.dart';
import 'state_logger.dart';
import 'rebuild_tracker.dart';

/// State inspection manager for debugging Flutter apps.
///
/// Provides a singleton [instance] that combines [StateLogger] for
/// recording state changes, [RebuildTracker] for counting widget rebuilds,
/// and [PerformanceMetrics] for frame timing analysis.
///
/// Extends [ChangeNotifier] so widgets can rebuild automatically when
/// state changes. Wrap the overlay in a [ListenableBuilder] to get
/// live updates.
class StateInspector extends ChangeNotifier {
  /// Shared instance.
  static final StateInspector instance = StateInspector._();

  /// Log of state changes.
  final StateLogger logger = StateLogger();

  /// Widget rebuild counter.
  final RebuildTracker tracker = RebuildTracker();

  /// Frame timing and FPS metrics.
  final PerformanceMetrics _performance = PerformanceMetrics();

  /// Whether the overlay is currently visible.
  bool _isVisible = false;

  StateInspector._();

  /// Whether the overlay is currently visible.
  bool get isVisible => _isVisible;

  /// Performance metrics for frame timing analysis.
  PerformanceMetrics get performance => _performance;

  /// Record a state change.
  void logState(String label, String value, {String? previous}) {
    logger.add(label: label, newValue: value, previousValue: previous);
    notifyListeners();
  }

  /// Record a widget rebuild.
  void trackRebuild(String widgetName) {
    tracker.increment(widgetName);
    notifyListeners();
  }

  /// Record a frame duration for performance tracking.
  void trackFrame(Duration frameTime) {
    _performance.recordFrame(frameTime);
    notifyListeners();
  }

  /// Show the overlay.
  void show() {
    _isVisible = true;
    notifyListeners();
  }

  /// Hide the overlay.
  void hide() {
    _isVisible = false;
    notifyListeners();
  }

  /// Toggle visibility.
  void toggle() {
    _isVisible = !_isVisible;
    notifyListeners();
  }

  /// Reset all tracked data.
  void reset() {
    logger.clear();
    tracker.reset();
    _performance.reset();
    _isVisible = false;
    notifyListeners();
  }
}
