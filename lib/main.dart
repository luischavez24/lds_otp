import 'package:flutter/material.dart';
import 'package:lds_otp/screens/home.dart';
import 'package:lds_otp/utils/constants.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Autenticador LDS',
        theme: ThemeData(
          fontFamily: "Open Sans",
          primarySwatch: PRIMARY_COLOR
        ),
        home: HomeScreen());
  }
}
