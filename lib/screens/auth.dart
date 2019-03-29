import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lds_otp/utils/constants.dart';
import 'package:lds_otp/utils/messages.dart';

class AuthScreen extends StatefulWidget {

  @override
  State createState() => _AuthState();
}

class _AuthState extends State<AuthScreen> {
  bool _isAuthenticated = false;

  final auth = new LocalAuthentication();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Builder(
      builder:(context) => Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "Autenticador de Luz del Sur",
              style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.w700
              ),
            ),
            RaisedButton(
              color: SECONDARY_COLOR,
              textColor: Colors.white,
              elevation: 3.0,
              child: Container(
                width: 100.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.fingerprint),
                    Text("Ingresar")
                  ],
                ),
              ),
              onPressed: () async {
                await _authenticate();
                if(_isAuthenticated) {
                  Navigator.pushReplacementNamed (context, '/');
                } else {
                  showErrorMessage(context, "No se pudo realizar la "
                      "autenticación, intentelo nuevamente");
                }
              },
              shape: RoundedRectangleBorder(),
            )
          ],
        ),
      ),
    )
  );

  Future _authenticate() async {
    bool isAuthenticated = false;
    try {
      isAuthenticated = await auth.authenticateWithBiometrics(
          localizedReason: 'Coloca tu huella en el sensor',
          useErrorDialogs: true,
          stickyAuth: false);
    } on PlatformException catch (e) {
      showErrorMessage(context, e.message);
    }
    if (!mounted) return;

    setState(() {
      _isAuthenticated = isAuthenticated;
    });
  }
}