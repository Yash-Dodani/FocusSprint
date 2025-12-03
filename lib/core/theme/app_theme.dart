import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final base = ThemeData.light();
    return base.copyWith(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF5F5FA),
      colorScheme: base.colorScheme.copyWith(
        primary: const Color(0xFF5B2EFF),
        secondary: const Color(0xFF8E5BFF),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: const Color(0xFF1B1B1F),
        displayColor: const Color(0xFF1B1B1F),
      ),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData.dark();
    return base.copyWith(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF050511),
      colorScheme: base.colorScheme.copyWith(
        primary: const Color(0xFF8E5BFF),
        secondary: const Color(0xFF5B2EFF),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Color(0xFF050511),
        foregroundColor: Colors.white,
      ),
      cardColor: const Color(0xFF101020),
      textTheme: base.textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
    );
  }
}
