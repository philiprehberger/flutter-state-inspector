import 'package:flutter/material.dart';

import 'state_entry.dart';
import 'state_logger.dart';
import 'rebuild_tracker.dart';
import 'state_inspector.dart';

/// Debug overlay widget showing state changes, rebuild counts, and performance.
///
/// Displays a compact panel with three tabs:
/// - **State** lists recent state change entries from [StateLogger]
/// - **Rebuilds** shows the top widget rebuild counts from [RebuildTracker]
/// - **Perf** shows frame timing and FPS metrics from [PerformanceMetrics]
class InspectorOverlay extends StatelessWidget {
  /// The state logger to read entries from.
  final StateLogger logger;

  /// The rebuild tracker to read counts from.
  final RebuildTracker tracker;

  /// Optional callback when the close button is pressed.
  final VoidCallback? onClose;

  /// Optional position hint for parent layout.
  final Offset? position;

  /// Create an inspector overlay.
  const InspectorOverlay({
    super.key,
    required this.logger,
    required this.tracker,
    this.onClose,
    this.position,
  });

  @override
  Widget build(BuildContext context) {
    final entries = logger.recent(20);
    final topRebuilds = tracker.topRebuilders(10);

    return Material(
      elevation: 8,
      color: Colors.grey[900],
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 320,
        height: 400,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    const TabBar(
                      tabs: [
                        Tab(text: 'State'),
                        Tab(text: 'Rebuilds'),
                        Tab(text: 'Perf'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildStateList(entries),
                          _buildRebuildList(topRebuilds),
                          _buildPerfTab(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          const Icon(Icons.bug_report, color: Colors.greenAccent, size: 20),
          const SizedBox(width: 8),
          const Text(
            'State Inspector',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (onClose != null)
            IconButton(
              icon: const Icon(
                Icons.close,
                color: Colors.white70,
                size: 18,
              ),
              onPressed: onClose,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }

  Widget _buildStateList(List<StateEntry> entries) {
    if (entries.isEmpty) {
      return const Center(
        child: Text(
          'No state changes',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: entries.length,
      itemBuilder: (_, i) {
        final e = entries[entries.length - 1 - i];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(
            '${e.label}: ${e.newValue}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }

  Widget _buildRebuildList(List<MapEntry<String, int>> rebuilds) {
    if (rebuilds.isEmpty) {
      return const Center(
        child: Text(
          'No rebuilds tracked',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: rebuilds.length,
      itemBuilder: (_, i) {
        final entry = rebuilds[i];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  entry.key,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                '${entry.value}x',
                style: const TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPerfTab() {
    final perf = StateInspector.instance.performance;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPerfRow('Frames', '${perf.frameCount}'),
          const SizedBox(height: 4),
          _buildPerfRow(
            'Avg Frame Time',
            '${perf.averageFrameTimeMs.toStringAsFixed(2)} ms',
          ),
          const SizedBox(height: 4),
          _buildPerfRow(
            'Peak Frame Time',
            '${perf.peakFrameTimeMs.toStringAsFixed(2)} ms',
          ),
          const SizedBox(height: 4),
          _buildPerfRow(
            'Estimated FPS',
            perf.estimatedFps.toStringAsFixed(1),
          ),
        ],
      ),
    );
  }

  Widget _buildPerfRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
        Text(
          value,
          style: const TextStyle(color: Colors.cyanAccent, fontSize: 12),
        ),
      ],
    );
  }
}
