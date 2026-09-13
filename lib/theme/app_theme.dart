import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Cyberpunk + Glassmorphism Design System
class AppTheme {
  AppTheme._();

  // ── Colors ──────────────────────────────────────────────────
  static const Color background = Color(0xFF0A0A12); // Deep dark blue-black
  static const Color foreground = Color(0xFFE0E0FF); // Off-white with cyan tint
  static const Color primary = Color(0xFFFF00FF); // Neon Magenta
  static const Color secondary = Color(0xFF00FFFF); // Neon Cyan
  static const Color tertiary = Color(0xFFFFFF00); // Neon Yellow

  static const Color muted = Color(
    0x2200FFFF,
  ); // Very sheer cyan for glass fills
  static const Color mutedForeground = Color(0xFFA0A0C0);
  static const Color borderColor = Color(
    0x8800FFFF,
  ); // Semi-transparent cyan border
  static const Color borderLight = Color(0x4400FFFF);
  static const Color error = Color(0xFFFF003C);

  static const List<Color> primaryColors = [primary, secondary, tertiary];
  static const Color primaryRed = primary; // Fallback
  static const Color primaryBlue = secondary;
  static const Color primaryYellow = tertiary;

  static final Border border2 = Border.all(color: borderColor, width: 1);
  static final Border border4 = Border.all(color: secondary, width: 2);
  static const BoxShadow hardShadow = BoxShadow(
    color: Colors.transparent,
    offset: Offset.zero,
  );
  static const BoxShadow hardShadowLarge = BoxShadow(
    color: Colors.transparent,
    offset: Offset.zero,
  );

  static BoxDecoration cardDecoration({
    Color color = muted,
    bool largeShadow = false,
    bool thickBorder = false,
  }) {
    return BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
      border: thickBorder ? border4 : border2,
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.2),
          blurRadius: largeShadow ? 30 : 15,
          spreadRadius: largeShadow ? 5 : 0,
        ),
      ],
    );
  }

  // ── Typography ────────────────────────────────────────────────
  static const String fontDisplay = 'Orbitron';
  static const String fontBody = 'Rajdhani';
  static const String fontMono = 'Share Tech Mono';

  // ── Theme Data ────────────────────────────────────────────────
  static ThemeData get theme {
    final baseTextTheme = GoogleFonts.rajdhaniTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor:
          Colors.transparent, // Transparent so background gradient shows
      colorScheme: const ColorScheme.dark(
        primary: secondary, // Use cyan as main primary for inputs etc
        onPrimary: background,
        secondary: primary,
        onSecondary: background,
        surface: Colors.transparent,
        onSurface: foreground,
        error: error,
        onError: background,
      ),

      // Typography
      fontFamily: fontBody,
      textTheme: baseTextTheme.copyWith(
        displayLarge: TextStyle(
          fontFamily: fontDisplay,
          fontSize: 96,
          fontWeight: FontWeight.w900,
          letterSpacing: -2.0,
          color: foreground,
          shadows: [Shadow(color: primary.withOpacity(0.5), blurRadius: 10)],
        ),
        displayMedium: TextStyle(
          fontFamily: fontDisplay,
          fontSize: 72,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.5,
          color: foreground,
        ),
        displaySmall: TextStyle(
          fontFamily: fontDisplay,
          fontSize: 56,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.0,
          color: foreground,
        ),
        headlineLarge: TextStyle(
          fontFamily: fontDisplay,
          fontSize: 40,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: foreground,
        ),
        headlineMedium: TextStyle(
          fontFamily: fontDisplay,
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: foreground,
        ),
        headlineSmall: TextStyle(
          fontFamily: fontDisplay,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: foreground,
        ),
        bodyLarge: TextStyle(
          fontFamily: fontBody,
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: foreground,
        ),
        bodyMedium: TextStyle(
          fontFamily: fontBody,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: foreground,
        ),
        bodySmall: TextStyle(
          fontFamily: fontBody,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: mutedForeground,
        ),
        labelLarge: TextStyle(
          fontFamily: fontDisplay,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 2.5,
          color: foreground,
        ),
        labelMedium: TextStyle(
          fontFamily: fontDisplay,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 2.0,
          color: foreground,
        ),
        labelSmall: TextStyle(
          fontFamily: fontMono,
          fontSize: 11,
          fontWeight: FontWeight.w400,
          letterSpacing: 1.5,
          color: secondary,
        ),
      ),

      // ── Input Decoration ──────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: muted,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: borderLight, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: borderColor, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: secondary, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: error, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: error, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        hintStyle: TextStyle(
          fontFamily: fontBody,
          fontStyle: FontStyle.italic,
          color: mutedForeground,
          fontSize: 16,
        ),
        labelStyle: TextStyle(
          fontFamily: fontDisplay,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 2.5,
          color: secondary,
        ),
        floatingLabelStyle: TextStyle(
          fontFamily: fontDisplay,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 2.5,
          color: secondary,
          shadows: [Shadow(color: secondary.withOpacity(0.5), blurRadius: 5)],
        ),
        errorStyle: TextStyle(fontFamily: fontBody, fontSize: 12, color: error),
      ),

      // ── Elevated Button (Primary) ─────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered))
              return primary.withOpacity(0.8);
            if (states.contains(WidgetState.disabled)) return muted;
            return primary;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return mutedForeground;
            return background;
          }),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          ),
          elevation: WidgetStateProperty.all(8),
          shadowColor: WidgetStateProperty.all(primary.withOpacity(0.5)),
          textStyle: WidgetStateProperty.all(
            TextStyle(
              fontFamily: fontDisplay,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 3.0,
            ),
          ),
        ),
      ),

      // ── Outlined Button (Secondary) ───────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered))
              return secondary.withOpacity(0.2);
            return Colors.transparent;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return mutedForeground;
            return secondary;
          }),
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return BorderSide(
                color: mutedForeground.withOpacity(0.5),
                width: 1,
              );
            }
            return BorderSide(color: secondary, width: 2);
          }),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          ),
          elevation: WidgetStateProperty.all(0),
          textStyle: WidgetStateProperty.all(
            TextStyle(
              fontFamily: fontDisplay,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 3.0,
            ),
          ),
        ),
      ),

      // ── Text Button (Ghost) ───────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(tertiary),
          overlayColor: WidgetStateProperty.all(tertiary.withOpacity(0.1)),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          textStyle: WidgetStateProperty.all(
            TextStyle(
              fontFamily: fontBody,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),

      // Card Theme (Glassmorphism base)
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderColor, width: 1),
        ),
        color: muted,
      ),

      dividerTheme: DividerThemeData(
        color: borderColor,
        thickness: 1,
        space: 24,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: foreground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: fontDisplay,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 2.0,
          color: foreground,
          shadows: [Shadow(color: secondary.withOpacity(0.8), blurRadius: 10)],
        ),
      ),
    );
  }
}
