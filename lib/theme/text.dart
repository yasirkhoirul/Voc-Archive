import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyTheme {
  const MyTheme._();

  // Mempertahankan textStyle default sebagai fallback
  static final textStyle = _buildTextTheme(false);

  static TextTheme getTextTheme(bool isMobile) {
    return _buildTextTheme(isMobile);
  }

  static TextTheme _buildTextTheme(bool isMobile) {
    return TextTheme(
      displayLarge: GoogleFonts.roboto(
        fontSize: isMobile ? 32 : 64,
        fontWeight: FontWeight.w900,
      ),
      displayMedium: GoogleFonts.roboto(
        fontSize: isMobile ? 32 : 64,
        fontWeight: FontWeight.w100,
      ),
      titleLarge: GoogleFonts.roboto(
        fontSize: isMobile ? 24 : 32,
        fontWeight: FontWeight.w400,
      ),
      titleMedium: GoogleFonts.roboto(
        fontSize: isMobile ? 20 : 24,
        fontWeight: FontWeight.w100,
      ),
      bodyMedium: GoogleFonts.roboto(
        fontSize: isMobile ? 14 : 16,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: GoogleFonts.roboto(
        fontSize: isMobile ? 12 : 14,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: GoogleFonts.roboto(
        fontSize: isMobile ? 16 : 20,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
