import 'dart:math';
import 'package:flutter/material.dart';

class AdminBackground extends StatefulWidget {
  final Widget child;
  
  const AdminBackground({super.key, required this.child});

  @override
  State<AdminBackground> createState() => _AdminBackgroundState();
}

class _AdminBackgroundState extends State<AdminBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base Dark Background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0F172A), // Slate 900
                Color(0xFF1E1B4B), // Indigo 950
                Color(0xFF0F172A), // Slate 900
              ],
            ),
          ),
        ),

        // Animated Geometric Grid
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: HexGridPainter(_controller.value),
              size: Size.infinite,
            );
          },
        ),
        
        // Content
        widget.child,
      ],
    );
  }
}

class HexGridPainter extends CustomPainter {
  final double animationValue;

  HexGridPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03) // Very subtle
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final highlightPaint = Paint()
      ..color = const Color(0xFFFFD700).withOpacity(0.05) // Gold tint
      ..style = PaintingStyle.fill;

    const double hexSize = 60.0;
    final double width = size.width;
    final double height = size.height;

    // Draw Hex Grid
    for (double y = 0; y < height + hexSize; y += hexSize * 0.866) { // 0.866 is sin(60)
      for (double x = 0; x < width + hexSize; x += hexSize * 1.5) {
        bool offset = (y ~/ (hexSize * 0.866)) % 2 != 0;
        double xPos = x + (offset ? hexSize * 0.75 : 0);
        
        // Animate some hexes filling up
        if ((xPos + y + animationValue * 1000).toInt() % 17 == 0) {
          _drawHex(canvas, Offset(xPos, y), hexSize / 2, highlightPaint);
        }

        _drawHex(canvas, Offset(xPos, y), hexSize / 2, paint);
      }
    }
    
    // Draw "Data Streams" - connecting lines
    final linePaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.transparent, const Color(0xFF6366F1).withOpacity(0.2), Colors.transparent],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, width, height))
      ..strokeWidth = 2;

    double lineX = (size.width * 0.8) + sin(animationValue * 2 * pi) * 20;
    canvas.drawLine(Offset(lineX, 0), Offset(lineX, size.height), linePaint);
  }

  void _drawHex(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      double angle = (60 * i + 30) * pi / 180;
      double x = center.dx + size * cos(angle);
      double y = center.dy + size * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant HexGridPainter oldDelegate) {
     return oldDelegate.animationValue != animationValue;
  }
}
