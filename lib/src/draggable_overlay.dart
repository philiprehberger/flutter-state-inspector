import 'package:flutter/material.dart';

/// A draggable wrapper widget for debug panels.
///
/// Renders [child] inside a [Stack] with a [Positioned] widget
/// that can be repositioned by dragging via [GestureDetector].
class DraggableOverlay extends StatefulWidget {
  /// The widget to display inside the draggable container.
  final Widget child;

  /// Starting position of the overlay.
  final Offset initialPosition;

  /// Create a draggable overlay.
  const DraggableOverlay({
    super.key,
    required this.child,
    this.initialPosition = const Offset(16, 100),
  });

  @override
  State<DraggableOverlay> createState() => _DraggableOverlayState();
}

class _DraggableOverlayState extends State<DraggableOverlay> {
  late Offset _position;

  @override
  void initState() {
    super.initState();
    _position = widget.initialPosition;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: _position.dx,
          top: _position.dy,
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                _position += details.delta;
              });
            },
            child: widget.child,
          ),
        ),
      ],
    );
  }
}
