import 'package:flutter/material.dart';

class AppTheme {
  // iOS System Colors (Light)
  static const iosBackground = Color(0xFFF2F2F7); // System Grouped Background
  static const iosSurface = Colors.white;
  static const iosBlue = Color(0xFF007AFF);
  static const iosGreen = Color(0xFF34C759);
  static const iosRed = Color(0xFFFF3B30);
  static const iosGrey = Color(0xFF8E8E93);
  static const iosDivider = Color(0xFFC6C6C8);
  
  // iOS System Colors (Dark)
  static const iosDarkBackground = Color(0xFF000000);
  static const iosDarkSurface = Color(0xFF1C1C1E);
  static const iosDarkBlue = Color(0xFF0A84FF);

  // Biznet Brand Colors
  static const Color biznetBlue = Color(0xFF1A1F71); // Dark Blue (Dominant)
  static const Color biznetLightBlue = Color(0xFF00ADEE); // Light Blue (Accent)
  
  // Text Styles
  // White & Blue Minimalist Colors
  static const Color primaryBlue = biznetBlue; 
  static const Color accentBlue = biznetLightBlue;
  static const Color backgroundLight = Colors.white; 
  static const Color cardSurface = Colors.white;
  
  static const Color textDark = Color(0xFF1E293B); // Slate 800
  static const Color textGrey = Color(0xFF64748B); // Slate 500
  static const Color textLight = Colors.white; 
  
  static const Color warningAmber = Color(0xFFFF9500); 
  static const Color successGreen = Color(0xFF10B981); 
  static const Color errorRed = Color(0xFFEF4444); 
  
  // Gradients (Subtle)
  static const List<Color> primaryGradient = [
    primaryBlue,
    Color(0xFF1D4ED8),
  ];

  static const List<Color> successGradient = [
    successGreen,
    Color(0xFF059669),
  ];

  static const List<Color> warningGradient = [
    warningAmber,
    Color(0xFFEA580C),
  ];

  static ThemeData lightTheme = ThemeData(
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: backgroundLight,
    fontFamily: 'sans-serif',
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundLight,
      elevation: 0,
      iconTheme: IconThemeData(color: textDark),
      titleTextStyle: TextStyle(color: textDark, fontSize: 18, fontWeight: FontWeight.bold),
    ),
    colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: primaryBlue,
      background: backgroundLight,
    ),
  );

  // Clean Typography
  static TextStyle get largeTitle => const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textDark,
    letterSpacing: -0.5,
  );

  static TextStyle get title1 => const TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: textDark,
  );
  
  static TextStyle get body => const TextStyle(
    fontSize: 16,
    color: textDark,
    height: 1.5,
  );

  static TextStyle get caption => const TextStyle(
    fontSize: 14,
    color: textGrey,
  );

  // Minimalist Card
  static BoxDecoration get cleanCardDecoration => BoxDecoration(
    color: cardSurface,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: const Color(0xFFF1F5F9)), // Subtle border
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF64748B).withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );
  
  static BoxDecoration get cardDecoration => cleanCardDecoration;
  static BoxDecoration get iosCardDecoration => cleanCardDecoration; // Alias

  static BoxDecoration statusBadge(Color color) {
    return BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withOpacity(0.2)),
    );
  }

  static Widget gradientButton({
    required String label,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
