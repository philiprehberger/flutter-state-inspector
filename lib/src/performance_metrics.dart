/// Tracks frame timing metrics for performance monitoring.
///
/// Use [recordFrame] to log individual frame durations and query
/// aggregate statistics like [averageFrameTimeMs] and [estimatedFps].
class PerformanceMetrics {
  /// Total number of frames tracked.
  int frameCount = 0;

  /// Sum of all frame durations.
  Duration totalFrameTime = Duration.zero;

  /// Maximum single frame duration.
  Duration peakFrameTime = Duration.zero;

  /// Record a single frame duration.
  ///
  /// Increments [frameCount], adds to [totalFrameTime], and updates
  /// [peakFrameTime] if [frameTime] is larger than the current peak.
  void recordFrame(Duration frameTime) {
    frameCount++;
    totalFrameTime += frameTime;
    if (frameTime > peakFrameTime) {
      peakFrameTime = frameTime;
    }
  }

  /// Average frame time in milliseconds.
  ///
  /// Returns 0 if no frames have been recorded.
  double get averageFrameTimeMs {
    if (frameCount == 0) return 0;
    return totalFrameTime.inMicroseconds / frameCount / 1000;
  }

  /// Peak frame time in milliseconds.
  double get peakFrameTimeMs =>
      peakFrameTime.inMicroseconds / 1000;

  /// Estimated frames per second based on average frame time.
  ///
  /// Returns 0 if no frames have been recorded.
  double get estimatedFps {
    if (frameCount == 0) return 0;
    return 1000 / averageFrameTimeMs;
  }

  /// Reset all tracked metrics to zero.
  void reset() {
    frameCount = 0;
    totalFrameTime = Duration.zero;
    peakFrameTime = Duration.zero;
  }

  /// Export metrics as a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'frameCount': frameCount,
      'totalFrameTimeMs': totalFrameTime.inMicroseconds / 1000,
      'peakFrameTimeMs': peakFrameTimeMs,
      'averageFrameTimeMs': averageFrameTimeMs,
      'estimatedFps': estimatedFps,
    };
  }
}
