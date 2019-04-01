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
        theme: ThemeData(
          fontFamily: "Montserrat",
          primarySwatch: AppColors.primaryColor,
          buttonTheme: ButtonThemeData(
            buttonColor: AppColors.secondaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0)
            ),
            textTheme: ButtonTextTheme.normal
          )
        )
    );
  }
}