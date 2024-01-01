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

  // Reset all tracked data
  inspector.reset();

  // Use the overlay widget in your widget tree:
  //
  // Stack(
  //   children: [
  //     MyApp(),
  //     if (StateInspector.instance.isVisible)
  //       Positioned(
  //         right: 16,
  //         bottom: 16,
  //         child: InspectorOverlay(
  //           logger: StateInspector.instance.logger,
  //           tracker: StateInspector.instance.tracker,
  //           onClose: () => StateInspector.instance.hide(),
  //         ),
  //       ),
  //   ],
  // )
}
