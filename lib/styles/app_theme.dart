import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// 🎨 Tema global de la aplicación HealthU (Material 3 + Google Fonts + estilo profesional)
class AppTheme {
  static const Color primaryColor = Color(0xFF00C853); // Verde principal HealthU
  static const Color accentColor = Color(0xFF64DD17); // Verde brillante de apoyo
  static const Color backgroundLight = Colors.white; // Fondo blanco puro global
  static const Color backgroundDark = Color(0xFF121212); // Fondo oscuro elegante

  /// 🌞 Tema claro (moderno, limpio y sin AppBar visible)
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.white, // 🔹 Fondo blanco total
        textTheme: GoogleFonts.poppinsTextTheme(),

        // 🔹 AppBar totalmente transparente y moderna
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: const IconThemeData(color: Colors.black87),
          titleTextStyle: GoogleFonts.poppins(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
        ),

        // 🔹 Botones elevados con diseño profesional y sombra ligera
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            elevation: 4,
            shadowColor: primaryColor.withOpacity(0.25),
          ),
        ),

        // 🔹 Campos de texto suaves y modernos
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          hintStyle: TextStyle(color: Colors.grey[500]),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: primaryColor, width: 1.2),
          ),
        ),

        // 🔹 SnackBars elegantes
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Colors.black87,
          contentTextStyle: GoogleFonts.poppins(color: Colors.white),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        // 🔹 Iconos y tipografía uniformes
        iconTheme: const IconThemeData(color: primaryColor),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primaryColor,
            textStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
        ),
      );

  /// 🌙 Tema oscuro (con enfoque elegante y contraste equilibrado)
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: backgroundDark,
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),

        // 🔹 AppBar oscuro minimalista
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
        ),

        // 🔹 Botones elevados (resaltados sobre fondo oscuro)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // 🔹 Campos de texto en modo oscuro
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
          hintStyle: TextStyle(color: Colors.grey[400]),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: primaryColor, width: 1.2),
          ),
        ),

        // 🔹 SnackBars coherentes con modo oscuro
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Colors.grey[850],
          contentTextStyle: GoogleFonts.poppins(color: Colors.white),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        // 🔹 Estilo de textos y botones oscuros
        iconTheme: const IconThemeData(color: accentColor),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: accentColor,
            textStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
        ),
      );
}
