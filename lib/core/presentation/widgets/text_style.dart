import 'package:flutter/material.dart';

class CustomTexteStyle {
  static TextTheme buildTextTheme({required Color colors}) {
    return TextTheme(
      titleLarge: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w700,
          fontFamily: 'Poppins',
          color: colors),
      displayMedium: TextStyle(
        fontSize: 32,
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w500,
        color: colors,
      ),
      bodyMedium: const TextStyle(
        fontSize: 16,
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
      bodySmall: TextStyle(
        fontSize: 14,
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w400,
        color: colors,
      ),
    );
  }
}
