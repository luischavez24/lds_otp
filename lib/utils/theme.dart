import 'package:flutter/material.dart';

class AppFonts {
  static const String openSans = "Open Sans";
  static const String cabin = "Cabin";
}

class AppColors {
  static const MaterialColor primaryColor = MaterialColor(0xFF07436F,
      <int, Color> {
        100: Color(0xFFB5C7D4),
        200: Color(0xFF83A1B7),
        300: Color(0xFF517B9A),
        400: Color(0xFF2C5F85),
        500: Color(0xFF07436F),
        600: Color(0xFF063D67),
        700: Color(0xFF042C52),
        800: Color(0xFF002f6c),
        900: Color(0xFF021E40)
      }
  );

  static const MaterialColor accentColor = MaterialColor(0xFFF39200,
      <int, Color> {
        100: Color(0xFFFBDEB3),
        200: Color(0xFFF9C980),
        300: Color(0xFFF7B34D),
        400: Color(0xFFF5A226),
        500: Color(0xFFF39200),
        600: Color(0xFFF18A00),
        700: Color(0xFFEF7F00),
        800: Color(0xFFED7500),
        900: Color(0xFFEA6300)
      }
  );

  static const textColor = Colors.white;
}