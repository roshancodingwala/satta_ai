import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Color Palette (Saffron × Deep Indigo) ────────────────────────────
  static const Color background   = Color(0xFF0D0B1E); // deep space indigo
  static const Color surface      = Color(0xFF16122E); // card surface
  static const Color surfaceLight = Color(0xFF1E1A3C); // elevated surface
  static const Color primary      = Color(0xFFE8871A); // saffron orange
  static const Color primaryDark  = Color(0xFFB5611A); // deep saffron
  static const Color secondary    = Color(0xFF7C5CBF); // lotus purple
  static const Color accent       = Color(0xFF4ECDC4); // teal calm
  static const Color textPrimary  = Color(0xFFF0EBE3); // warm white
  static const Color textSecondary= Color(0xFFB0A9C8); // muted lavender
  static const Color danger       = Color(0xFFFF6B6B); // crisis red
  static const Color success      = Color(0xFF6BCB77); // peace green

  // ── Gradients ──────────────────────────────────────────────────────────
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1A1040), Color(0xFF0D0B1E)],
  );

  static const LinearGradient saffronGradient = LinearGradient(
    colors: [Color(0xFFE8871A), Color(0xFFB5611A)],
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF7C5CBF), Color(0xFF4E3A8C)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E1A3C), Color(0xFF16122E)],
  );

  // ── Text Styles ────────────────────────────────────────────────────────
  static TextStyle get displayLarge => GoogleFonts.outfit(
    fontSize: 36, fontWeight: FontWeight.w700, color: textPrimary,
  );

  static TextStyle get headlineMedium => GoogleFonts.outfit(
    fontSize: 24, fontWeight: FontWeight.w600, color: textPrimary,
  );

  static TextStyle get titleLarge => GoogleFonts.outfit(
    fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary,
  );

  static TextStyle get bodyLarge => GoogleFonts.outfit(
    fontSize: 16, fontWeight: FontWeight.w400, color: textPrimary, height: 1.6,
  );

  static TextStyle get bodyMedium => GoogleFonts.outfit(
    fontSize: 14, fontWeight: FontWeight.w400, color: textSecondary, height: 1.5,
  );

  static TextStyle get labelSmall => GoogleFonts.outfit(
    fontSize: 12, fontWeight: FontWeight.w500, color: textSecondary,
    letterSpacing: 0.8,
  );

  // ── ThemeData ──────────────────────────────────────────────────────────
  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    primaryColor: primary,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: secondary,
      surface: surface,
      error: danger,
    ),
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: displayLarge,
      headlineMedium: headlineMedium,
      titleLarge: titleLarge,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      labelSmall: labelSmall,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        textStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
        elevation: 8,
        shadowColor: primary.withOpacity(0.4),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
      hintStyle: GoogleFonts.outfit(color: textSecondary),
      contentPadding: const EdgeInsets.all(18),
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 6,
      shadowColor: Colors.black38,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.outfit(
        fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary,
      ),
      iconTheme: const IconThemeData(color: textPrimary),
    ),
  );
}
