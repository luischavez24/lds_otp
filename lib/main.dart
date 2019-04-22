import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lds_otp/screens/auth.dart';
import 'package:lds_otp/utils/theme.dart';
import 'package:lds_otp/bloc/bloc.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {

  @override
  State createState() => _MyAppState();
}


class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc();
    _authBloc.dispatch(CheckBiometrics());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProviderTree(
      blocProviders: [
        BlocProvider<AuthBloc>(bloc: _authBloc),
      ],
      child: MaterialApp(
          title: 'Autenticador LDS',
          home: AuthScreen(),
          theme: buildLightTheme()
      ),
    );
  }

  @override
  void dispose() {
    _authBloc?.dispose();
    super.dispose();
  }
}