# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.4.0] - 2026-04-28

### Added
- `PerformanceMetrics.recordMark()` records a named timestamp for custom timing
- `PerformanceMetrics.measureMark()` returns the `Duration` between two recorded marks (or `Duration.zero` if either is missing)
- `StateLogger.diffSince()` returns entries recorded within a given time window in chronological order

## [0.3.0] - 2026-04-12

### Added
- `StateInspector` now extends `ChangeNotifier` for reactive UI updates
- `InspectorOverlay` accepts `performance` parameter instead of accessing singleton directly

### Changed
- `PerformanceMetrics` fields (`frameCount`, `totalFrameTime`, `peakFrameTime`) are now private with public getters
- `StateInspector.isVisible` is now a getter backed by a private field

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
