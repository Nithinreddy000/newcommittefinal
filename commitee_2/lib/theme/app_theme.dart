import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF6E56CF);
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color surfaceColor = Colors.white;
  static const Color textColor = Color(0xFF1A1523);
  static const Color accentColor = Color(0xFFEA580C);

  static ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
      surface: surfaceColor,
      background: backgroundColor,
      onBackground: textColor,
    ),
    textTheme: const TextTheme(
      headline1: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textColor),
      headline2: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: textColor),
      bodyText1: TextStyle(fontSize: 16, color: textColor),
      bodyText2: TextStyle(fontSize: 14, color: textColor),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        primary: primaryColor,
        onPrimary: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.grey[200],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    // Implement dark theme here, similar to light theme but with darker colors
  );
}

