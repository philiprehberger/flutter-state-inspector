// ignore_for_file: unused_local_variable

/// Example usage of philiprehberger_state_inspector.
///
/// This file demonstrates how to use the StateInspector in a Flutter app.
/// It cannot run standalone — it requires a Flutter application context.
library;

import 'package:philiprehberger_state_inspector/state_inspector.dart';

void example() {
  // Access the shared inspector instance
  final inspector = StateInspector.instance;

  // Log state changes with optional previous value
  inspector.logState('counter', '1', previous: '0');
  inspector.logState('theme', 'dark');

  // Track widget rebuilds
  inspector.trackRebuild('CounterWidget');
  inspector.trackRebuild('CounterWidget');
  inspector.trackRebuild('HeaderWidget');

  // Toggle the overlay visibility
  inspector.toggle();

  // Query the state logger
  final allEntries = inspector.logger.all;
  final recentEntries = inspector.logger.recent(5);
  final counterEntries = inspector.logger.filterByLabel('counter');
  final exported = inspector.logger.export();

  // Query the rebuild tracker
  final counterRebuilds = inspector.tracker.count('CounterWidget');
  final topRebuilders = inspector.tracker.topRebuilders(5);
  final totalRebuilds = inspector.tracker.total;

  // Track frame durations for performance metrics
  inspector.trackFrame(const Duration(milliseconds: 16));
  inspector.trackFrame(const Duration(milliseconds: 18));
  inspector.trackFrame(const Duration(milliseconds: 14));

  // Query performance metrics
  final fps = inspector.performance.estimatedFps;
  final avgFrame = inspector.performance.averageFrameTimeMs;
  final peakFrame = inspector.performance.peakFrameTimeMs;
  final frames = inspector.performance.frameCount;
  final perfJson = inspector.performance.toJson();

  // Export state history as JSON
  final jsonData = inspector.logger.exportJson();

  // Export state history as CSV
  final csvString = inspector.logger.exportCsv();

  // Reset all tracked data
  inspector.reset();

  // Listen for changes (StateInspector extends ChangeNotifier):
  //
  // inspector.addListener(() {
  //   print('State changed!');
  // });
  //
  // Use ListenableBuilder for a reactive overlay:
  //
  // ListenableBuilder(
  //   listenable: StateInspector.instance,
  //   builder: (context, _) {
  //     if (!StateInspector.instance.isVisible) return const SizedBox.shrink();
  //     return InspectorOverlay(
  //       logger: StateInspector.instance.logger,
  //       tracker: StateInspector.instance.tracker,
  //       performance: StateInspector.instance.performance,
  //       onClose: () => StateInspector.instance.hide(),
  //     );
  //   },
  // )
  //
  // Or use DraggableOverlay for a repositionable panel:
  //
  // DraggableOverlay(
  //   initialPosition: const Offset(16, 100),
  //   child: InspectorOverlay(
  //     logger: StateInspector.instance.logger,
  //     tracker: StateInspector.instance.tracker,
  //     performance: StateInspector.instance.performance,
  //     onClose: () => StateInspector.instance.hide(),
  //   ),
  // )
}
