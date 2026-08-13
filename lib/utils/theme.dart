import 'package:flutter/material.dart';

class AppTheme {
  // Brand color seeds
  static const Color primarySeedColor = Colors.indigo;

  // Custom mood color palettes
  static const Color moodHappyColor = Color(0xFF2ECC71);     // Emerald green
  static const Color moodNormalColor = Color(0xFF3498DB);    // Ocean blue
  static const Color moodSadColor = Color(0xFF9B59B6);       // Amethyst purple
  static const Color moodSickColor = Color(0xFFF1C40F);      // Amber yellow
  static const Color moodEmergencyColor = Color(0xFFE74C3C); // Alizarin red

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.light,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: Colors.white,
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        scrolledUnderElevation: 2,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: primarySeedColor,
      brightness: Brightness.dark,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 2,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class MoodStyle {
  final Color color;
  final IconData icon;

  const MoodStyle({required this.color, required this.icon});
}

MoodStyle getMoodStyle(String mood) {
  switch (mood.trim().toLowerCase()) {
    case 'happy':
      return const MoodStyle(
        color: AppTheme.moodHappyColor,
        icon: Icons.sentiment_very_satisfied_rounded,
      );
    case 'normal':
      return const MoodStyle(
        color: AppTheme.moodNormalColor,
        icon: Icons.sentiment_satisfied_rounded,
      );
    case 'sad':
      return const MoodStyle(
        color: AppTheme.moodSadColor,
        icon: Icons.sentiment_very_dissatisfied_rounded,
      );
    case 'sick':
      return const MoodStyle(
        color: AppTheme.moodSickColor,
        icon: Icons.sick_rounded,
      );
    case 'emergency':
      return const MoodStyle(
        color: AppTheme.moodEmergencyColor,
        icon: Icons.warning_amber_rounded,
      );
    default:
      return const MoodStyle(
        color: Colors.grey,
        icon: Icons.help_outline_rounded,
      );
  }
}
