import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryGreen = Color(0xFF2E7D32);   // Forest Green
  static const Color secondaryGreen = Color(0xFF66BB6A); // Light Green
  static const Color accentGold = Color(0xFFF9A825);     // Warm Gold
  static const Color cocoaBrown = Color(0xFF5D4037);     // Cocoa Brown
  
  // Backgrounds
  static const Color bgDark = Color(0xFFF8FAF8);        // Natural light off-white
  static const Color bgCard = Color(0xFFFFFFFF);        // Pure white cards
  static const Color bgInput = Color(0xFFF1F5F1);       // Very light natural input field

  // Status Colors
  static const Color success = Color(0xFF43A047);
  static const Color warning = Color(0xFFFB8C00);       // Orange
  static const Color error = Color(0xFFE53935);         // Red
  static const Color info = Color(0xFF1E88E5);          // Blue

  // Legacy mappings for backward compatibility
  static const Color primaryBrown = cocoaBrown;
  static const Color primaryOrange = warning;
  static const Color primaryYellow = accentGold;
  static const Color primaryBlue = info;
  static const Color riskCritical = error;
  static const Color riskHigh = warning;
  static const Color riskMedium = accentGold;
  static const Color riskLow = primaryGreen;

  // Text Colors
  static const Color textLight = Color(0xFF263238);     // Slate Charcoal
  static const Color textMuted = Color(0xFF546E7A);     // Medium Slate Gray

  // Border Radius Constants
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 24.0;

  // Spacing (8-point grid)
  static const double spaceXS = 4.0;
  static const double spaceS = 8.0;
  static const double spaceM = 16.0;
  static const double spaceL = 24.0;
  static const double spaceXL = 32.0;

  // Soft shadows
  static List<BoxShadow> get softShadow {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ];
  }

  // Premium Gradients
  static const LinearGradient greenGradient = LinearGradient(
    colors: [primaryGreen, Color(0xFF388E3C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cocoaGradient = LinearGradient(
    colors: [cocoaBrown, Color(0xFF8D6E63)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [accentGold, Color(0xFFFBC02D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryGreen,
      scaffoldBackgroundColor: bgDark,
      cardColor: bgCard,
      fontFamily: GoogleFonts.poppins().fontFamily,
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: const TextStyle(color: textLight, fontSize: 32, fontWeight: FontWeight.bold),
        titleLarge: const TextStyle(color: textLight, fontSize: 20, fontWeight: FontWeight.w600),
        bodyLarge: const TextStyle(color: textLight, fontSize: 16),
        bodyMedium: const TextStyle(color: textMuted, fontSize: 14),
      ),
      colorScheme: const ColorScheme.light(
        primary: primaryGreen,
        secondary: secondaryGreen,
        surface: bgCard,
        error: error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bgDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textLight,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: textLight),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: primaryGreen,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgInput,
        hintStyle: const TextStyle(color: textMuted),
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: Colors.black.withOpacity(0.03), width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: primaryGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
      ),
    );
  }
}
