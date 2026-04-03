# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.0] - 2026-04-02

### Added
- `PerformanceMetrics` class for frame timing and FPS tracking
- `StateInspector.trackFrame()` and `performance` getter
- `StateLogger.exportJson()` for JSON array export
- `StateLogger.exportCsv()` for CSV string export
- `DraggableOverlay` widget for repositionable debug panels
- Performance tab in `InspectorOverlay` showing frame metrics

## [0.1.0] - 2026-04-01

### Added
- Initial release
- `StateEntry` record for tracking state changes with timestamp and labels
- `StateLogger` for recording, filtering, and exporting state change history
- `RebuildTracker` for counting and ranking widget rebuilds
- `InspectorOverlay` widget with tabbed view of state changes and rebuild counts
- `StateInspector` singleton facade for convenient state logging and rebuild tracking
