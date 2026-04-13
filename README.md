# philiprehberger_state_inspector

[![Tests](https://github.com/philiprehberger/flutter-state-inspector/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/flutter-state-inspector/actions/workflows/ci.yml)
[![pub package](https://img.shields.io/pub/v/philiprehberger_state_inspector.svg)](https://pub.dev/packages/philiprehberger_state_inspector)
[![Last updated](https://img.shields.io/github/last-commit/philiprehberger/flutter-state-inspector)](https://github.com/philiprehberger/flutter-state-inspector/commits/main)

Debug overlay showing state changes, rebuild counts, and transition history

## Requirements

- Dart >= 3.6
- Flutter >= 3.29

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  philiprehberger_state_inspector: ^0.3.0
```

Then run:

```bash
flutter pub get
```

## Usage

```dart
import 'package:philiprehberger_state_inspector/state_inspector.dart';

final inspector = StateInspector.instance;

// Log state changes
inspector.logState('counter', '1', previous: '0');
inspector.logState('theme', 'dark');

// Track widget rebuilds
inspector.trackRebuild('CounterWidget');
```

### Showing the Overlay

`StateInspector` extends `ChangeNotifier`, so wrap the overlay in a
`ListenableBuilder` for automatic updates:

```dart
ListenableBuilder(
  listenable: StateInspector.instance,
  builder: (context, _) {
    if (!StateInspector.instance.isVisible) return const SizedBox.shrink();
    return InspectorOverlay(
      logger: StateInspector.instance.logger,
      tracker: StateInspector.instance.tracker,
      performance: StateInspector.instance.performance,
      onClose: () => StateInspector.instance.hide(),
    );
  },
)
```

### Performance Tracking

```dart
// Record frame durations
inspector.trackFrame(const Duration(milliseconds: 16));

// Query metrics
final fps = inspector.performance.estimatedFps;
final avg = inspector.performance.averageFrameTimeMs;
final peak = inspector.performance.peakFrameTimeMs;
final frames = inspector.performance.frameCount;
```

### Exporting Data

```dart
// Export state history as JSON
final jsonData = inspector.logger.exportJson();

// Export state history as CSV
final csvString = inspector.logger.exportCsv();
```

### Draggable Overlay

Wrap the `InspectorOverlay` in a `DraggableOverlay` for repositionable panels:

```dart
DraggableOverlay(
  initialPosition: const Offset(16, 100),
  child: InspectorOverlay(
    logger: StateInspector.instance.logger,
    tracker: StateInspector.instance.tracker,
    performance: StateInspector.instance.performance,
    onClose: () => StateInspector.instance.hide(),
  ),
)
```

### Querying State History

```dart
final allEntries = inspector.logger.all;
final recentEntries = inspector.logger.recent(5);
final counterEntries = inspector.logger.filterByLabel('counter');
final exported = inspector.logger.export();
```

### Querying Rebuild Counts

```dart
final count = inspector.tracker.count('CounterWidget');
final topRebuilders = inspector.tracker.topRebuilders(5);
final totalRebuilds = inspector.tracker.total;
```

## API

| Method | Description |
|--------|-------------|
| `StateInspector.instance` | Shared singleton instance |
| `StateInspector.logState()` | Record a state change with label and value |
| `StateInspector.trackRebuild()` | Record a widget rebuild |
| `StateInspector.show()` | Show the overlay |
| `StateInspector.hide()` | Hide the overlay |
| `StateInspector.toggle()` | Toggle overlay visibility |
| `StateInspector.reset()` | Clear all tracked data |
| `StateInspector.trackFrame()` | Record a frame duration |
| `StateInspector.performance` | Access performance metrics |
| `StateLogger.add()` | Add a state entry |
| `StateLogger.all` | All recorded entries |
| `StateLogger.recent(n)` | Most recent n entries |
| `StateLogger.filterByLabel()` | Filter entries by label |
| `StateLogger.clear()` | Remove all entries |
| `StateLogger.count` | Total number of entries |
| `StateLogger.export()` | Export as formatted string |
| `StateLogger.exportJson()` | Export as JSON array |
| `StateLogger.exportCsv()` | Export as CSV string |
| `PerformanceMetrics.recordFrame()` | Record a frame duration |
| `PerformanceMetrics.averageFrameTimeMs` | Average frame time in ms |
| `PerformanceMetrics.peakFrameTimeMs` | Peak frame time in ms |
| `PerformanceMetrics.estimatedFps` | Estimated FPS |
| `PerformanceMetrics.frameCount` | Total frames tracked |
| `PerformanceMetrics.reset()` | Reset all metrics |
| `PerformanceMetrics.toJson()` | Export metrics as map |
| `DraggableOverlay` | Draggable wrapper for debug panels |
| `RebuildTracker.increment()` | Record a widget rebuild |
| `RebuildTracker.count()` | Get rebuild count for a widget |
| `RebuildTracker.topRebuilders(n)` | Top n most rebuilt widgets |
| `RebuildTracker.reset()` | Clear all counts |
| `RebuildTracker.total` | Total rebuilds across all widgets |

## Development

```bash
flutter pub get
flutter analyze --fatal-infos
flutter test
```

## Support

If you find this project useful:

⭐ [Star the repo](https://github.com/philiprehberger/flutter-state-inspector)

🐛 [Report issues](https://github.com/philiprehberger/flutter-state-inspector/issues?q=is%3Aissue+is%3Aopen+label%3Abug)

💡 [Suggest features](https://github.com/philiprehberger/flutter-state-inspector/issues?q=is%3Aissue+is%3Aopen+label%3Aenhancement)

❤️ [Sponsor development](https://github.com/sponsors/philiprehberger)

🌐 [All Open Source Projects](https://philiprehberger.com/open-source-packages)

💻 [GitHub Profile](https://github.com/philiprehberger)

🔗 [LinkedIn Profile](https://www.linkedin.com/in/philiprehberger)

## License

[MIT](LICENSE)
