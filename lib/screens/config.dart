import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dbcrypt/dbcrypt.dart';
import 'package:lds_otp/utils/theme.dart';

class ConfigScreen extends StatefulWidget {
  @override
  State createState() => _ConfigState();
}

class _ConfigState extends State<ConfigScreen> {
  final DBCrypt _crypt = DBCrypt();

  bool _usesFingerprint = false;
  @override
  void initState() {
    super.initState();
    _chargeUserPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
        children: <Widget>[
          ListTile(
            title: Text("Cambiar PIN de acceso"),
            onTap: _savePin,
          ),
          SwitchListTile(
            title: Text("¿Usar huella dactilar?"),
            value: _usesFingerprint,
            onChanged: _changeFingerprintUserPref,
            activeColor: AppColors.primaryColor,
          )
        ],
      ),
    );
  }

  Future _changeFingerprintUserPref(bool isUsingFingerprint) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("uses_fingerprint", isUsingFingerprint);
  }

  Future _chargeUserPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _usesFingerprint = prefs.getBool("uses_fingerprint") ?? false;
    });
  }

  Future _savePin() async {

  }
}