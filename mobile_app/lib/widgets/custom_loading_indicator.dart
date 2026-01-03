import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class CustomLoadingIndicator extends StatefulWidget {
  final double size;
  final Color color;

  const CustomLoadingIndicator({
    super.key,
    this.size = 30, // Default size slightly smaller for buttons
    this.color = const Color(0xFF42A8CC),
  });

  @override
  State<CustomLoadingIndicator> createState() => _CustomLoadingIndicatorState();
}

class _CustomLoadingIndicatorState extends State<CustomLoadingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // Faster 1s for better feel
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _LoadingPainter(
            progress: _controller.value,
            color: widget.color,
          ),
        );
      },
    );
  }
}

class _LoadingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _LoadingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0 // Standard stroke width for mobile visibility
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final path = Path()..addRect(rect);

    // Create a dashed effect that moves
    // Perimeter of the square is 4 * size
    final perimeter = size.width * 4;
    final dashLength = size.width; // 1/4th of the perimeter
    final gapLength = size.width * 3; // The rest is gap
    
    // We'll calculate the offset based on progress
    // In Flutter, we can't easily animate dash offset without a package
    // So we'll manually draw the segment
    
    final currentOffset = progress * perimeter;
    
    // Extract a segment of the path
    ui.PathMetrics pathMetrics = path.computeMetrics();
    for (ui.PathMetric pathMetric in pathMetrics) {
      // Calculate start and end of the dash
      double start = currentOffset;
      double end = currentOffset + dashLength;
      
      if (end <= pathMetric.length) {
        canvas.drawPath(pathMetric.extractPath(start, end), paint);
      } else {
        // Wrap around the corners
        canvas.drawPath(pathMetric.extractPath(start, pathMetric.length), paint);
        canvas.drawPath(pathMetric.extractPath(0, end - pathMetric.length), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LoadingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
