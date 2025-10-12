import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_constants.dart';

/// Halloween-themed app styling
class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppConstants.primaryOrange,
      scaffoldBackgroundColor: const Color(0xFF0D0015),

      colorScheme: const ColorScheme.dark(
        primary: AppConstants.primaryOrange,
        secondary: AppConstants.primaryPurple,
        surface: Color(0xFF1A0033),
        error: AppConstants.bloodRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppConstants.ghostWhite,
        onError: Colors.white,
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.creepster(
          fontSize: 24,
          color: AppConstants.primaryOrange,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(
          color: AppConstants.primaryOrange,
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        color: AppConstants.primaryPurple.withValues(alpha: 0.3),
        elevation: 8,
        shadowColor: AppConstants.primaryOrange.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryOrange,
          foregroundColor: Colors.white,
          elevation: 6,
          shadowColor: AppConstants.primaryOrange.withValues(alpha: 0.6),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppConstants.primaryOrange,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: GoogleFonts.creepster(
          fontSize: 48,
          color: AppConstants.primaryOrange,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: GoogleFonts.creepster(
          fontSize: 36,
          color: AppConstants.primaryOrange,
        ),
        headlineLarge: GoogleFonts.poppins(
          fontSize: 28,
          color: AppConstants.ghostWhite,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 24,
          color: AppConstants.ghostWhite,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 20,
          color: AppConstants.ghostWhite,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 16,
          color: AppConstants.ghostWhite,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14,
          color: AppConstants.ghostWhite.withValues(alpha: 0.8),
        ),
        labelLarge: GoogleFonts.poppins(
          fontSize: 14,
          color: AppConstants.ghostWhite,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppConstants.primaryPurple.withValues(alpha: 0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppConstants.primaryOrange.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppConstants.primaryOrange.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppConstants.primaryOrange, width: 2),
        ),
        labelStyle: GoogleFonts.poppins(
          color: AppConstants.ghostWhite.withValues(alpha: 0.7),
        ),
        hintStyle: GoogleFonts.poppins(
          color: AppConstants.ghostWhite.withValues(alpha: 0.5),
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppConstants.primaryOrange,
        size: 24,
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: AppConstants.primaryOrange.withValues(alpha: 0.2),
        thickness: 1,
        space: 16,
      ),

      // Slider Theme
      sliderTheme: SliderThemeData(
        activeTrackColor: AppConstants.primaryOrange,
        inactiveTrackColor: AppConstants.primaryOrange.withValues(alpha: 0.3),
        thumbColor: AppConstants.primaryOrange,
        overlayColor: AppConstants.primaryOrange.withValues(alpha: 0.2),
        trackHeight: 4,
      ),

      // Dialog Theme
      dialogTheme: DialogTheme(
        backgroundColor: const Color(0xFF1A0033),
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppConstants.primaryOrange.withValues(alpha: 0.3)),
        ),
        titleTextStyle: GoogleFonts.creepster(
          fontSize: 24,
          color: AppConstants.primaryOrange,
        ),
        contentTextStyle: GoogleFonts.poppins(
          fontSize: 16,
          color: AppConstants.ghostWhite,
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF0D0015),
        selectedItemColor: AppConstants.primaryOrange,
        unselectedItemColor: AppConstants.ghostWhite,
        elevation: 16,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  // Light theme (optional, for future use)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppConstants.primaryOrange,
      scaffoldBackgroundColor: Colors.white,

      colorScheme: const ColorScheme.light(
        primary: AppConstants.primaryOrange,
        secondary: AppConstants.primaryPurple,
        surface: Colors.white,
        error: AppConstants.bloodRed,
      ),

      textTheme: TextTheme(
        displayLarge: GoogleFonts.creepster(
          fontSize: 48,
          color: AppConstants.primaryOrange,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
    );
  }
}
