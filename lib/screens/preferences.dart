import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lds_otp/bloc/preferences_bloc.dart';
import 'package:lds_otp/models/preferences_model.dart';
import 'package:lds_otp/utils/theme.dart';

class PreferencesScreen extends StatefulWidget {
  @override
  State createState() => _PreferencesState();
}
class _PreferencesState extends State<PreferencesScreen> {

  @override
  Widget build(BuildContext context) {
    final preferencesProvider = BlocProvider.of<PreferencesBloc>(context);
    preferencesProvider.dispatch(LoadPreferences());
    return BlocBuilder(
      bloc: preferencesProvider,
      builder: (context, state) {
        if (state is PreferencesLoading) {
          return Center(
              child: CircularProgressIndicator(value: null, strokeWidth: 4.5)
          );
        } else if (state is PreferencesNotLoaded) {
          return Center(
              child: Text("No se pudieron cargar las preferencias")
          );
        } else if(state is PreferencesLoaded) {
          return Container(
            child: ListView(
                children: <Widget>[
                  ListTile(
                    title: Text("Cambiar PIN de acceso"),
                    onTap: _savePin,
                  ),
                  SwitchListTile(
                    title: Text("¿Usar huella dactilar?"),
                    value: _getValueInLoadedPreferences(state, "uses_fingerprint"),
                    onChanged: (isUsingFingerprint) => _changeFingerprintUserPref(
                        preferencesProvider,
                        isUsingFingerprint
                    ),
                    activeColor: AppColors.accentColor,
                  )
                ]
            ),
          );
        }
      },
    );
  }

  dynamic _getValueInLoadedPreferences(PreferencesLoaded state, String key) {
    return state.preferences.where((pref) => pref.key == key).first.value;
  }

  void _changeFingerprintUserPref(PreferencesBloc preferencesBloc, bool isUsingFingerprint) {
      final preference = PreferenceModel(
          key: "uses_fingerprint",
          value: isUsingFingerprint
      );
      preferencesBloc.dispatch(SavePreference(preference));
  }

  Future _savePin() async {}
}