import 'package:flutter/material.dart';

class AppFonts {
  static const String openSans = "Open Sans";
  static const String cabin = "Cabin";
}

class AppColors {
  static const Color primaryColor = MaterialColor(0xFF3B5998,
      <int, Color> {
        100: Color(0xFFC4CDE0),
        200: Color(0xFF9DACCC),
        300: Color(0xFF768BB7),
        400: Color(0xFF5872A7),
        500: Color(0xFF3B5998),
        600: Color(0xFF355190),
        700: Color(0xFF2D4885),
        800: Color(0xFF263E7B),
        900: Color(0xFF192E6A)
      }
  );
  static const Color accentColor = Colors.deepOrangeAccent;

  static const Color primaryColor2 = MaterialColor(0xFF07436F,
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
  static const Color accentColor2 = MaterialColor(0xFFF39200,
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

ThemeData buildLightTheme () {
  final base = ThemeData.light();
  return _buildBaseTheme(base).copyWith(
    primaryColor: AppColors.primaryColor, // *
    scaffoldBackgroundColor: Colors.white, // *
    cardColor: Colors.white, // *
    textSelectionColor: AppColors.primaryColor, // *
    textTheme: _buildAppTextTheme(
        base.textTheme,
        bodyColor: Colors.black,
        displayColor: Colors.black38
    ) // *
  );
}

ThemeData buildDarkTheme () {
  final base = ThemeData.dark();
  return _buildBaseTheme(base).copyWith(
    primaryColor: AppColors.textColor, // *
    scaffoldBackgroundColor: AppColors.primaryColor, // *
    cardColor: AppColors.primaryColor, // *
    textSelectionColor: AppColors.accentColor, // *
    textTheme: _buildAppTextTheme(base.textTheme, bodyColor: AppColors.textColor), // *
  );
}

ThemeData _buildBaseTheme(ThemeData base) {
  return base.copyWith(
    accentColor: AppColors.accentColor,
    buttonColor: AppColors.accentColor,
    errorColor: Colors.redAccent,
    primaryTextTheme: _buildAppTextTheme(
        base.primaryTextTheme,
        bodyColor: AppColors.textColor
    ),
    accentTextTheme: _buildAppTextTheme(
        base.accentTextTheme,
        bodyColor: AppColors.textColor
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.elliptical(10, 10)),
          gapPadding: 10.0
      ),
    ),
  );
}

TextTheme _buildAppTextTheme(TextTheme base, { Color bodyColor,  Color displayColor }) {
  return base.copyWith(
      headline: base.headline.copyWith(
          fontWeight: FontWeight.w900
      ),
      title: base.title.copyWith(
          fontSize: 18.0,
          fontWeight: FontWeight.w500
      ),
      caption: base.title.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 14.0
      )
  ).apply(
      fontFamily: AppFonts.openSans,
      displayColor: displayColor ?? bodyColor,
      bodyColor: bodyColor
  );
}