import 'package:flutter/material.dart';
import 'package:lds_otp/screens/home.dart';
import 'package:lds_otp/screens/auth.dart';
import 'package:lds_otp/utils/theme.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Autenticador LDS',
        initialRoute: '/auth',
        routes: {
          '/': (context) => HomeScreen(),
          '/auth': (context) => AuthScreen()
        },
        theme: _buildTheme()
    );
  }

  ThemeData _buildTheme () {
    final ThemeData base= ThemeData.light();
    return base.copyWith(
        primaryColor: AppColors.primaryColor,
        accentColor: AppColors.accentColor,
        buttonColor: AppColors.accentColor,
        scaffoldBackgroundColor: Colors.white,
        cardColor: Colors.white,
        textSelectionColor: AppColors.primaryColor,
        errorColor: Colors.redAccent,
        textTheme: _buildAppTextTheme(base.textTheme, Colors.black),
        primaryTextTheme: _buildAppTextTheme(base.primaryTextTheme, AppColors.textColor),
        accentTextTheme: _buildAppTextTheme(base.accentTextTheme,  AppColors.textColor),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.elliptical(10, 10)),
            gapPadding: 10.0
          )
        ),
    );
  }

  TextTheme _buildAppTextTheme(TextTheme base, Color textColor) {
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
      displayColor: textColor,
      bodyColor: textColor
    );
  }
}