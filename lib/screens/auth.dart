import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:local_auth/local_auth.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:lds_otp/utils/messages.dart';
import 'package:lds_otp/utils/theme.dart';
import 'package:lds_otp/services/auth_services.dart';

class AuthScreen extends StatefulWidget {
  @override
  State createState() => _AuthState();
}

class _AuthState extends State<AuthScreen> {
  final auth = new LocalAuthentication();
  final _formKey = GlobalKey<FormState>();

  bool _usesFingerprint = false;
  String _data = "";

  @override
  void initState() {
    super.initState();
    _chargeUserPrefs();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Builder(
      builder:(context) => Container(
          child: SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                children: <Widget>[
                  SizedBox(height: 80.0),
                  _icon,
                  SizedBox(height: 80.0),
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
                    validator: _validatePINField,
                    onSaved: (value) { _data = value; },
                  ),
                  SizedBox(height: 60.0),
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
                      IconButton(
                        icon: Icon(Icons.fingerprint),
                        onPressed: _usesFingerprint ? () => _biometricAuth(context) : null,
                        color: AppColors.primaryColor,
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
      )
    )
  );

  String _validatePINField (value) {
    if(value.length > 4) {
      return "El PIN debe ser de 4 dígitos";
    }
    return null;
  }
  
  Future _pinAuth(BuildContext context) async {
    _formKey.currentState.save();
    if(_formKey.currentState.validate()) {
      final authService = AuthService.getServiceByAuthType(AuthType.PIN);
      _postAuthenticationAction(context, await authService.authenticate(pin: _data));
    }
  }

  Future _biometricAuth(BuildContext context,) async {
    final authService = AuthService.getServiceByAuthType(AuthType.BIOMETRIC);
    try {
      var isAuthenticated = await authService.authenticate();
      if(!mounted) return;
      _postAuthenticationAction(context, isAuthenticated);
    } on PlatformException catch (e) {
      showMessage(context, e.message);
    }
  }

  void _postAuthenticationAction(BuildContext context, bool isAuthenticated) {
    if(isAuthenticated) {
      Navigator.pushReplacementNamed (context, '/');
    } else {
      showMessage(context, "No se pudo realizar la autenticación, intentelo nuevamente");
    }
  }

  Future _chargeUserPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _usesFingerprint = prefs.getBool("uses_fingerprint") ?? false;
    });
  }

  Widget get _icon => Column(
    children: <Widget>[
      Image.asset('assets/images/logo.png', height: 80.0),
      SizedBox(height: 20.0),
      Text("Autenticador",
          style: TextStyle(
              fontSize: 20.0,
              color: AppColors.primaryColor
          )
      )
    ],
  );

}