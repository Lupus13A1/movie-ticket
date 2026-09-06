import 'package:flutter/material.dart';

/// Minimalist Monochrome Design System
///
/// Pure black & white. Serif typography. Sharp corners.
/// No shadows. No accent colors. Editorial luxury.
class AppTheme {
  AppTheme._();

  // ── Colors (Strictly Monochrome) ──────────────────────────────
  static const Color background = Color(0xFFFFFFFF);
  static const Color foreground = Color(0xFF000000);
  static const Color muted = Color(0xFFF5F5F5);
  static const Color mutedForeground = Color(0xFF525252);
  static const Color borderColor = Color(0xFF000000);
  static const Color borderLight = Color(0xFFE5E5E5);
  static const Color error = Color(0xFF000000);

  // ── Typography ────────────────────────────────────────────────
  static const String fontDisplay = 'Playfair Display';
  static const String fontBody = 'Source Serif 4';
  static const String fontMono = 'JetBrains Mono';

  // ── Theme Data ────────────────────────────────────────────────
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.light(
          primary: foreground,
          onPrimary: background,
          secondary: foreground,
          onSecondary: background,
          surface: background,
          onSurface: foreground,
          error: foreground,
          onError: background,
        ),

        // Typography
        fontFamily: fontBody,
        textTheme: const TextTheme(
          // Display — oversized serif headlines
          displayLarge: TextStyle(
            fontFamily: fontDisplay,
            fontSize: 96,
            fontWeight: FontWeight.w900,
            letterSpacing: -2.0,
            height: 0.9,
            color: foreground,
          ),
          displayMedium: TextStyle(
            fontFamily: fontDisplay,
            fontSize: 72,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.5,
            height: 0.95,
            color: foreground,
          ),
          displaySmall: TextStyle(
            fontFamily: fontDisplay,
            fontSize: 56,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.0,
            height: 1.0,
            color: foreground,
          ),
          // Headlines
          headlineLarge: TextStyle(
            fontFamily: fontDisplay,
            fontSize: 40,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            height: 1.1,
            color: foreground,
          ),
          headlineMedium: TextStyle(
            fontFamily: fontDisplay,
            fontSize: 32,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.25,
            height: 1.15,
            color: foreground,
          ),
          headlineSmall: TextStyle(
            fontFamily: fontDisplay,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            height: 1.2,
            color: foreground,
          ),
          // Body
          bodyLarge: TextStyle(
            fontFamily: fontBody,
            fontSize: 18,
            fontWeight: FontWeight.w400,
            height: 1.625,
            color: foreground,
          ),
          bodyMedium: TextStyle(
            fontFamily: fontBody,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 1.625,
            color: foreground,
          ),
          bodySmall: TextStyle(
            fontFamily: fontBody,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.5,
            color: mutedForeground,
          ),
          // Labels — uppercase tracking
          labelLarge: TextStyle(
            fontFamily: fontBody,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.5,
            height: 1.2,
            color: foreground,
          ),
          labelMedium: TextStyle(
            fontFamily: fontBody,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 2.0,
            height: 1.2,
            color: foreground,
          ),
          labelSmall: TextStyle(
            fontFamily: fontMono,
            fontSize: 11,
            fontWeight: FontWeight.w400,
            letterSpacing: 1.5,
            height: 1.2,
            color: mutedForeground,
          ),
        ),

        // ── Input Decoration ──────────────────────────────────────
        inputDecorationTheme: const InputDecorationTheme(
          filled: false,
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: borderLight, width: 1),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: foreground, width: 2),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: foreground, width: 4),
          ),
          errorBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: foreground, width: 2),
          ),
          focusedErrorBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: foreground, width: 4),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 0),
          hintStyle: TextStyle(
            fontFamily: fontBody,
            fontStyle: FontStyle.italic,
            color: mutedForeground,
            fontSize: 16,
          ),
          labelStyle: TextStyle(
            fontFamily: fontBody,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.5,
            color: foreground,
          ),
          floatingLabelStyle: TextStyle(
            fontFamily: fontBody,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.5,
            color: foreground,
          ),
          errorStyle: TextStyle(
            fontFamily: fontBody,
            fontSize: 12,
            color: foreground,
          ),
        ),

        // ── Elevated Button (Primary) ─────────────────────────────
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.hovered)) return background;
              return foreground;
            }),
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.hovered)) return foreground;
              return background;
            }),
            side: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.hovered)) {
                return const BorderSide(color: foreground, width: 2);
              }
              return BorderSide.none;
            }),
            shape: WidgetStateProperty.all(
              const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            ),
            elevation: WidgetStateProperty.all(0),
            textStyle: WidgetStateProperty.all(
              const TextStyle(
                fontFamily: fontBody,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 3.0,
              ),
            ),
            animationDuration: const Duration(milliseconds: 100),
          ),
        ),

        // ── Outlined Button (Secondary) ───────────────────────────
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.hovered)) return foreground;
              return Colors.transparent;
            }),
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.hovered)) return background;
              return foreground;
            }),
            side: WidgetStateProperty.all(
              const BorderSide(color: foreground, width: 2),
            ),
            shape: WidgetStateProperty.all(
              const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            ),
            elevation: WidgetStateProperty.all(0),
            textStyle: WidgetStateProperty.all(
              const TextStyle(
                fontFamily: fontBody,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 3.0,
              ),
            ),
            animationDuration: const Duration(milliseconds: 100),
          ),
        ),

        // ── Text Button (Ghost) ───────────────────────────────────
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: WidgetStateProperty.all(foreground),
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
            textStyle: WidgetStateProperty.all(
              const TextStyle(
                fontFamily: fontBody,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                decoration: TextDecoration.underline,
              ),
            ),
            shape: WidgetStateProperty.all(
              const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
          ),
        ),

        // Zero radius everywhere
        cardTheme: const CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(color: foreground, width: 1),
          ),
          color: background,
        ),

        dividerTheme: const DividerThemeData(
          color: foreground,
          thickness: 4,
          space: 0,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: background,
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
          ),
        ),
      );
}
