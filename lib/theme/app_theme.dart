import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color darkCharcoal = Color(0xFF121212);
  static const Color accentNeonGreen = Color(0xFF00FFB2);
  static const Color accentNeonBlue = Color(0xFF00E0FF);
  
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkCharcoal,
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      colorScheme: const ColorScheme.dark(
        primary: accentNeonGreen,
        secondary: accentNeonBlue,
        surface: Colors.white10,
      ),
    );
  }
}
