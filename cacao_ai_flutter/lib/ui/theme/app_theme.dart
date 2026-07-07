import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryGreen = Color(0xFF00B26A); // Emerald green for leaves & healthy state
  static const Color primaryBrown = Color(0xFF5D4037); // Cacao pod brown
  static const Color accentGreen = Color(0xFF34D399);

  // Dark Theme Backgrounds
  static const Color bgDark = Color(0xFF0B0D0C);
  static const Color bgCard = Color(0xFF141916);
  static const Color bgInput = Color(0xFF1A211D);

  // Status Colors
  static const Color riskCritical = Color(0xFFEF4444); // Red
  static const Color riskHigh = Color(0xFFF97316);     // Orange
  static const Color riskMedium = Color(0xFFFBBF24);   // Yellow
  static const Color riskLow = Color(0xFF10B981);      // Green

  // Text Colors
  static const Color textLight = Color(0xFFF3F4F6);
  static const Color textMuted = Color(0xFF9CA3AF);

  // Gradients
  static const LinearGradient greenGradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF111827), Color(0xFF1F2937)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cacaoGradient = LinearGradient(
    colors: [Color(0xFF5D4037), Color(0xFF8D6E63)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryGreen,
      scaffoldBackgroundColor: bgDark,
      cardColor: bgCard,
      fontFamily: GoogleFonts.outfit().fontFamily,
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: const TextStyle(color: textLight, fontSize: 32, fontWeight: FontWeight.bold),
        titleLarge: const TextStyle(color: textLight, fontSize: 20, fontWeight: FontWeight.w600),
        bodyLarge: const TextStyle(color: textLight, fontSize: 16),
        bodyMedium: const TextStyle(color: textMuted, fontSize: 14),
      ),
      colorScheme: const ColorScheme.dark(
        primary: primaryGreen,
        secondary: primaryBrown,
        surface: bgCard,
        background: bgDark,
        error: riskCritical,
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
          foregroundColor: textLight,
          backgroundColor: primaryGreen,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
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
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: riskCritical, width: 1.5),
        ),
      ),
    );
  }
}
