import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF6C5CE7);
  static const Color secondaryColor = Color(0xFFA29BFE);
  static const Color accentColor = Color(0xFF00CEC9);
  static const Color incomeColor = Color(0xFF00B894);
  static const Color expenseColor = Color(0xFFFF7675);
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkCardBackground = Color(0xFF1E293B);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: Colors.white,
      error: expenseColor,
    ),
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1E293B),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      height: 68,
      indicatorColor: primaryColor.withValues(alpha: 0.15),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: primaryColor, size: 24);
        }
        return const IconThemeData(color: Color(0xFF64748B), size: 24);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: primaryColor,
          );
        }
        return GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF64748B),
        );
      }),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: darkCardBackground,
      error: expenseColor,
    ),
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: darkCardBackground,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: darkCardBackground,
      elevation: 0,
      height: 68,
      indicatorColor: secondaryColor.withValues(alpha: 0.25),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: secondaryColor, size: 24);
        }
        return const IconThemeData(color: Color(0xFF94A3B8), size: 24);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: secondaryColor,
          );
        }
        return GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF94A3B8),
        );
      }),
    ),
  );
}
