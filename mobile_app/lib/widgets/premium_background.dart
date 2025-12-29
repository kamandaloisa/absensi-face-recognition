import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class AnimatedMeshBackground extends StatefulWidget {
  final Widget child;
  
  const AnimatedMeshBackground({super.key, required this.child});

  @override
  State<AnimatedMeshBackground> createState() => _AnimatedMeshBackgroundState();
}

class _AnimatedMeshBackgroundState extends State<AnimatedMeshBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
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
        // Deep Base Background
        Container(
          color: const Color(0xFF0A0E21), // Very dark blue/black base
        ),

        // Animated Orbs
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: MeshGradientPainter(_controller.value),
              size: Size.infinite,
            );
          },
        ),

        // Glass Overlay to smooth everything
        Container(
          decoration: BoxDecoration(
            color: AppTheme.primaryDarkBlue.withOpacity(0.3),
            backgroundBlendMode: BlendMode.overlay,
          ),
        ),

        // Content
        widget.child,
      ],
    );
  }
}

class MeshGradientPainter extends CustomPainter {
  final double value;

  MeshGradientPainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60); // Heavy blur

    // Calculate positions based on animation value
    final double w = size.width;
    final double h = size.height;
    
    // Orb 1: Top Left (Primary Blue)
    paint.color = const Color(0xFF1A237E).withOpacity(0.6);
    canvas.drawCircle(
      Offset(w * 0.2 + (sin(value * 2 * pi) * 30), h * 0.2 + (cos(value * 2 * pi) * 30)),
      w * 0.5,
      paint,
    );

    // Orb 2: Bottom Right (Accent Blue/Purple)
    paint.color = const Color(0xFF3949AB).withOpacity(0.5);
    canvas.drawCircle(
      Offset(w * 0.8 - (cos(value * 2 * pi) * 40), h * 0.8 - (sin(value * 2 * pi) * 40)),
      w * 0.6,
      paint,
    );

    // Orb 3: Center Moving (Cyan/Light Blue) - Highlight
    paint.color = const Color(0xFF00BCD4).withOpacity(0.3);
    canvas.drawCircle(
      Offset(w * 0.5 + (sin(value * pi) * 60), h * 0.5 + (cos(value * pi) * 60)),
      w * 0.3,
      paint,
    );
     
    // Orb 4: Bottom Left (Deep Purple)
    paint.color = const Color(0xFF311B92).withOpacity(0.5);
     canvas.drawCircle(
      Offset(w * 0.1, h * 0.9),
      w * 0.4,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant MeshGradientPainter oldDelegate) {
     return oldDelegate.value != value;
  }
}

class HeaderCurvedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppTheme.primaryDarkBlue,
          AppTheme.primaryBlue,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    path.lineTo(0, size.height - 40);
    
    // First curve
    path.quadraticBezierTo(
      size.width * 0.25, 
      size.height, 
      size.width * 0.5, 
      size.height - 20
    );
    
    // Second curve
    path.quadraticBezierTo(
      size.width * 0.75, 
      size.height - 40, 
      size.width, 
      size.height - 20
    );
    
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);

    // Decorative circle
    final circlePaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;
      
    canvas.drawCircle(Offset(size.width * 0.9, 0), 100, circlePaint);
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.2), 50, circlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
