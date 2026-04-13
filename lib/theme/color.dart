import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Colors.black;
  static const Color secondary = Color(0xFF7F7F7F);
  static const Color surface = Colors.white;

  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: Colors.white,
    secondary: secondary,
    onSecondary: Colors.white,
    surface: surface,
    onSurface: Colors.black,
    error: Colors.red,
    onError: Colors.white,
  );
}
