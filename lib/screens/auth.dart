import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dbcrypt/dbcrypt.dart';

import 'package:lds_otp/utils/messages.dart';
import 'package:lds_otp/utils/theme.dart';

class AuthScreen extends StatefulWidget {
  @override
  State createState() => _AuthState();
}

class _AuthState extends State<AuthScreen> {
  final auth = new LocalAuthentication();
  final _crypt = DBCrypt();
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
                    onSaved: (value) { _data = value; },
                  ),
                  SizedBox(height: 60.0),
                  ButtonBar(
                    children: <Widget>[
                      RaisedButton.icon(
                          onPressed: () {
                            _formKey.currentState.save();
                            _auth(context, AuthType.PIN);
                          },
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
                        onPressed: _usesFingerprint ? () => _auth(context, AuthType.BIOMETRIC) : null,
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

  Future _auth (BuildContext context, AuthType authType) async {
    var isAuthenticated = false;

    if(authType == AuthType.PIN) {
      isAuthenticated = await _pinAuth();
    } else if (authType == AuthType.BIOMETRIC) {
      isAuthenticated = await _biometricAuth();
    } else {
      throw Exception("Tipo de autenticación no soportado");
    }

    if(isAuthenticated) {
      Navigator.pushReplacementNamed (context, '/');
    } else {
      showMessage(context, "No se pudo realizar la autenticación, intentelo nuevamente");
    }
  }

  Future<bool> _pinAuth() async {
    if(_formKey.currentState.validate()) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var defaultPin = _crypt.hashpw("1234", DBCrypt().gensalt());
      var savedPin = prefs.getString("pin");
      return  _crypt.checkpw(_data, savedPin ?? defaultPin);
    }
    return false;
  }

  Future<bool> _biometricAuth() async {
    var isAuthenticated = false;

    try {
      isAuthenticated = await auth.authenticateWithBiometrics(
          localizedReason: 'Coloca tu huella en el sensor',
          useErrorDialogs: true,
          stickyAuth: false);
    } on PlatformException catch (e) {
      showMessage(context, e.message);
    }

    if (!mounted) return false;

    return isAuthenticated;
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
      Text("Autenticador", style: TextStyle(fontSize: 20.0))
    ],
  );

}

enum AuthType {
  BIOMETRIC,
  PIN
}