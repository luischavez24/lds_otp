import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:dbcrypt/dbcrypt.dart';
import 'package:lds_otp/utils/theme.dart';
import 'package:shimmer/shimmer.dart';

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
        var options = <Widget>[
          ListTile(
            title: Text("Cambiar PIN de acceso"),
            onTap: _savePin,
          ),
          SwitchListTile(
            title: Text("¿Usar huella dactilar?"),
            value: snapshot.data?.getBool("uses_fingerprint") ?? false,
            onChanged: _changeFingerprintUserPref,
            activeColor: AppColors.accentColor,
          )
        ];

        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Container(
              child: ListView(
                  children: options.map((option) => Shimmer.fromColors(
                      child: option,
                      baseColor: Colors.grey[300],
                      highlightColor: Colors.grey[100],
                  )).toList()
              ),
            );
          default:
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return Container(
                child: ListView(
                    children: options
                ),
              );
            }
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