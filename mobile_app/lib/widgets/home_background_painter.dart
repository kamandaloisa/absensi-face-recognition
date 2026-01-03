import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class HomeBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = AppTheme.biznetBlue
      ..style = PaintingStyle.fill;

    Path path = Path();
    path.lineTo(0, size.height * 0.7); // Start from top-left, go down 70%
    
    // Draw Bezier Curve
    path.quadraticBezierTo(
      size.width * 0.25, size.height * 0.85, // Control Point 1
      size.width * 0.5, size.height * 0.8,   // Mid Point
    );
    path.quadraticBezierTo(
      size.width * 0.75, size.height * 0.75, // Control Point 2
      size.width, size.height * 0.9,         // End Point
    );

    path.lineTo(size.width, 0); // Go up to top-right
    path.close();

    canvas.drawPath(path, paint);
    
    // Optional: Add the lighter blue overlay shape behind
    Paint accentPaint = Paint()
      ..color = AppTheme.biznetLightBlue.withOpacity(0.2)
      ..style = PaintingStyle.fill;
      
    // A simple accent circle/shape top right
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.1), 100, accentPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
