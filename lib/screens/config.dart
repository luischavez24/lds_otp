import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dbcrypt/dbcrypt.dart';
import 'package:lds_otp/utils/theme.dart';

class ConfigScreen extends StatefulWidget {
  @override
  State createState() => _ConfigState();
}

class _ConfigState extends State<ConfigScreen> {

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Text("Cargando preferencias...");
          default:
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            return Container(
              child: ListView(
                children: <Widget>[
                  ListTile(
                    title: Text("Cambiar PIN de acceso"),
                    onTap: _savePin,
                  ),
                  SwitchListTile(
                    title: Text("¿Usar huella dactilar?"),
                    value: snapshot.data.getBool("uses_fingerprint") ?? false,
                    onChanged: _changeFingerprintUserPref,
                    activeColor: AppColors.primaryColor,
                  )
                ],
              ),
            );
        }
      },
    );
  }

  Future _changeFingerprintUserPref(bool isUsingFingerprint) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("uses_fingerprint", isUsingFingerprint);
  }

  Future _savePin() async {

  }
}