/// Tracks frame timing metrics for performance monitoring.
///
/// Use [recordFrame] to log individual frame durations and query
/// aggregate statistics like [averageFrameTimeMs] and [estimatedFps].
class PerformanceMetrics {
  int _frameCount = 0;
  Duration _totalFrameTime = Duration.zero;
  Duration _peakFrameTime = Duration.zero;

  /// Total number of frames tracked.
  int get frameCount => _frameCount;

  /// Sum of all frame durations.
  Duration get totalFrameTime => _totalFrameTime;

  /// Maximum single frame duration.
  Duration get peakFrameTime => _peakFrameTime;

  /// Record a single frame duration.
  ///
  /// Increments [frameCount], adds to [totalFrameTime], and updates
  /// [peakFrameTime] if [frameTime] is larger than the current peak.
  void recordFrame(Duration frameTime) {
    _frameCount++;
    _totalFrameTime += frameTime;
    if (frameTime > _peakFrameTime) {
      _peakFrameTime = frameTime;
    }
  }

  /// Average frame time in milliseconds.
  ///
  /// Returns 0 if no frames have been recorded.
  double get averageFrameTimeMs {
    if (frameCount == 0) return 0;
    return _totalFrameTime.inMicroseconds / _frameCount / 1000;
  }

  /// Peak frame time in milliseconds.
  double get peakFrameTimeMs =>
      _peakFrameTime.inMicroseconds / 1000;

  /// Estimated frames per second based on average frame time.
  ///
  /// Returns 0 if no frames have been recorded.
  double get estimatedFps {
    if (frameCount == 0) return 0;
    return 1000 / averageFrameTimeMs;
  }

  /// Reset all tracked metrics to zero.
  void reset() {
    _frameCount = 0;
    _totalFrameTime = Duration.zero;
    _peakFrameTime = Duration.zero;
  }

  /// Export metrics as a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'frameCount': frameCount,
      'totalFrameTimeMs': _totalFrameTime.inMicroseconds / 1000,
      'peakFrameTimeMs': peakFrameTimeMs,
      'averageFrameTimeMs': averageFrameTimeMs,
      'estimatedFps': estimatedFps,
    };
  }
}
