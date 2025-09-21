import 'package:flutter/material.dart';

class AppTheme {
  // Color Constants
  static const Color seaGreen = Color(0xFF2E8B57);
  static const Color backgroundWhite = Colors.white;
  static const Color textBlack = Colors.black;
  static const Color textGrey = Colors.black54;
  static const Color lightGrey = Colors.black38;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: seaGreen,
      scaffoldBackgroundColor: backgroundWhite,
      
      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: seaGreen,
        secondary: seaGreen,
        surface: backgroundWhite,
        background: backgroundWhite,
        onPrimary: backgroundWhite,
        onSecondary: backgroundWhite,
        onSurface: textBlack,
        onBackground: textBlack,
      ),
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: seaGreen,
        foregroundColor: backgroundWhite,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: backgroundWhite,
        ),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: seaGreen,
          foregroundColor: backgroundWhite,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: seaGreen,
          side: const BorderSide(color: seaGreen, width: 2),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: seaGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: const TextStyle(color: textGrey),
        hintStyle: const TextStyle(color: lightGrey),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: backgroundWhite,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(8),
      ),
      
      // Text Themes
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textBlack,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textBlack,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textBlack,
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textBlack,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textBlack,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textBlack,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textBlack,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textBlack,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textBlack,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: textGrey,
        ),
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: textBlack,
        size: 24,
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: seaGreen,
        foregroundColor: backgroundWhite,
        elevation: 4,
      ),
    );
  }
}

// Custom Widget Styles
class AppStyles {
  static const EdgeInsets screenPadding = EdgeInsets.all(24);
  static const EdgeInsets cardPadding = EdgeInsets.all(16);
  static const double borderRadius = 12;
  static const double cardElevation = 4;
  
  static const TextStyle featureText = TextStyle(
    fontSize: 16,
    color: AppTheme.textBlack,
    fontWeight: FontWeight.w500,
  );
  
  static const TextStyle subtitleText = TextStyle(
    fontSize: 16,
    color: AppTheme.textGrey,
  );
  
  static const TextStyle captionText = TextStyle(
    fontSize: 12,
    color: AppTheme.lightGrey,
  );
}