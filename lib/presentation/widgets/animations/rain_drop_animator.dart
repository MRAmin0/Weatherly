import 'dart:math' as math;
import 'package:flutter/material.dart';

class RainDropAnimator extends StatefulWidget {
  final double width;
  final double height;

  const RainDropAnimator({
    super.key,
    required this.width,
    required this.height,
  });

  @override
  State<RainDropAnimator> createState() => _RainDropAnimatorState();
}

class _RainDropAnimatorState extends State<RainDropAnimator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_RainDrop> _drops = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _createDrops();
  }

  void _createDrops() {
    _drops.clear();
    for (int i = 0; i < 45; i++) {
      _drops.add(
        _RainDrop(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          speed: 0.1 + _random.nextDouble() * 0.15,
          length: 15 + _random.nextDouble() * 20,
          opacity: 0.1 + _random.nextDouble() * 0.4,
          thickness: 0.5 + _random.nextDouble() * 1.5,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _RainPainter(
              drops: _drops,
              progress: _controller.value,
              baseColor: Colors.lightBlueAccent,
            ),
          );
        },
      ),
    );
  }
}

class _RainDrop {
  final double x; // 0.0 to 1.0 (relative width)
  final double y; // 0.0 to 1.0 (relative height)
  final double speed;
  final double length;
  final double opacity;
  final double thickness;

  _RainDrop({
    required this.x,
    required this.y,
    required this.speed,
    required this.length,
    required this.opacity,
    required this.thickness,
  });
}

class _RainPainter extends CustomPainter {
  final List<_RainDrop> drops;
  final double progress;
  final Color baseColor;

  _RainPainter({
    required this.drops,
    required this.progress,
    required this.baseColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var drop in drops) {
      // Calculate current position with wraparound
      double currentY = (drop.y + progress * drop.speed * 10) % 1.0;
      double startX = drop.x * size.width;
      double startY = currentY * size.height;

      // Organic tilt and drift
      double endX = startX + 1.5;
      double endY = startY + drop.length;

      final Rect dropRect = Rect.fromPoints(
        Offset(startX, startY),
        Offset(endX, endY),
      );

      // Create a gradient for a tapering/fade effect
      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            baseColor.withValues(alpha: 0.0), // Top is invisible
            baseColor.withValues(alpha: drop.opacity), // Bottom is visible
          ],
        ).createShader(dropRect)
        ..strokeCap = StrokeCap.round
        ..strokeWidth = drop.thickness;

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RainPainter oldDelegate) => true;
}
