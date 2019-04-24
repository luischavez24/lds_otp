import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lds_otp/bloc/auth_bloc.dart';
import 'package:lds_otp/models/biometric_config.dart';
import 'package:lds_otp/models/preferences_model.dart';
import 'package:lds_otp/utils/messages.dart';
import 'package:lds_otp/utils/theme.dart';
import 'package:lds_otp/utils/validation.dart';
import 'package:lds_otp/services/auth_services.dart';
import 'package:lds_otp/screens/home.dart';

class AuthScreen extends StatefulWidget {
  @override
  State createState() => _AuthState();
}

class _AuthState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  String _data = "";

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthEvent, AuthState>(
      bloc: BlocProvider.of<AuthBloc>(context),
      builder: (BuildContext context, AuthState state) {
        if(state is AuthChecking) {
          return Theme(
              data: buildDarkTheme(),
              child: Scaffold(
                body: Center(
                    child: CircularProgressIndicator(value: null, strokeWidth: 4.5)
                ),
              )
          );
        } else if (state is AuthStarted) {
          return _buildLoginScreen(context, state.biometricConfig);
        } else if (state is AuthSuccessful)  {
          return HomeScreen();
        } else if(state is AuthFailed) {
          return _buildLoginScreen(context, state.biometricConfig,
              errorMessage: state.error
          );
        }
      },
    );
  }

  Widget _buildLoginScreen(BuildContext context, BiometricConfig biometricConfig, { String errorMessage }) {
    biometricConfig = biometricConfig ?? BiometricConfig();
    return Theme(
        data: buildDarkTheme(),
        child: Scaffold(
            body: Builder(builder: (context) => SafeArea(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  children: <Widget>[
                    SizedBox(height: 80.0),
                    _buildIcon(context),
                    SizedBox(height: 50.0),
                    TextFormField(
                      keyboardType: TextInputType.numberWithOptions(
                          signed: false,
                          decimal: false
                      ),
                      decoration: InputDecoration(
                          labelText: "PIN",
                          filled: true
                      ),
                      obscureText: true,
                      validator: validatePINField,
                      onSaved: (value) { _data = value; },
                    ),
                    SizedBox(
                        height: 60.0,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 25.0,
                            horizontal: 5.0
                          ),
                          child: Text(errorMessage ?? "",
                            style: TextStyle(
                              color: Colors.redAccent,
                            ),
                          ),
                        )
                    ),
                    ButtonBar(
                      children: <Widget>[
                        RaisedButton.icon(
                          onPressed: () => _pinAuth(context),
                          color: AppColors.accentColor,
                          textColor: AppColors.textColor,
                          icon: Icon(Icons.lock),
                          label: Text("Acceder"),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)
                          ),
                        ),
                        biometricConfig.canCheck ? IconButton(
                          icon: Icon(Icons.fingerprint),
                          onPressed: biometricConfig.uses ? () => _biometricAuth(context) : null,
                          color: AppColors.accentColor,
                        ) : Container()
                      ],
                    )
                  ],
                ),
              ),
            )
            )
        )
    );
  }

  Future _pinAuth(BuildContext context) async {
    final AuthBloc authBloc = BlocProvider.of<AuthBloc>(context);
    _formKey.currentState.save();

    if(_formKey.currentState.validate()) {
      authBloc.dispatch(CheckCredentials(AuthType.PIN, _data));
    }
  }

  Future _biometricAuth(BuildContext context) async {
    final AuthBloc authBloc = BlocProvider.of<AuthBloc>(context);
    try {
      authBloc.dispatch(CheckCredentials(AuthType.BIOMETRIC));
      if(!mounted) return;
    } on PlatformException catch (e) {
      showMessage(context, e.message);
    }
  }

  Widget _buildIcon(BuildContext context) {
    return Column(
      children: <Widget>[
        Image.asset('assets/images/logo.png',
            height: 160.0
        ),
        SizedBox(height: 20.0),
        Text("Autenticador",
            style: TextStyle(
                fontSize: 20.0
            )
        )
      ],
    );
  }
}