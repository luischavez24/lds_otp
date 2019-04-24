import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lds_otp/screens/auth.dart';
import 'package:lds_otp/screens/boarding.dart';
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
  AppBloc _appBloc;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc();
    _appBloc = AppBloc();

    _appBloc.dispatch(CheckAppUse());
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
          home: BlocBuilder(
              bloc: _appBloc,
              builder: (BuildContext context, AppState state) {
                if(state is AppStarted) {
                  return Theme(data: buildDarkTheme(),child: Scaffold());
                }
                else if(state is AppLoading) {
                  return Theme(
                      data: buildDarkTheme(),
                      child: Scaffold(
                        body: Center(
                            child: CircularProgressIndicator(value: null, strokeWidth: 4.5)
                        ),
                      )
                  );
                } else if (state is AppNormalUse) {
                  return AuthScreen();
                } else if(state is AppFirstUse) {
                  return BoardingScreen();
                }
              }
          ),
          theme: buildLightTheme()
      ),
    );
  }

  @override
  void dispose() {
    _authBloc?.dispose();
    _appBloc?.dispose();
    super.dispose();
  }
}