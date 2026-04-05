import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyTheme{
  const MyTheme._();
  static final textStyle = TextTheme(
    displayLarge: GoogleFonts.roboto (
      fontSize: 64,
      fontWeight: FontWeight.w900,
    ),
    displayMedium: GoogleFonts.roboto(
      fontSize: 64,
      fontWeight: FontWeight.w100,
    ),
    titleMedium: GoogleFonts.robotoFlex(
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
    bodyMedium: GoogleFonts.robotoFlex(
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
  );
}