import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lds_otp/bloc/change_pin_bloc.dart';
import 'package:lds_otp/bloc/preferences_bloc.dart';
import 'package:lds_otp/models/preferences_model.dart';
import 'package:lds_otp/screens/change_pin.dart';
import 'package:lds_otp/utils/theme.dart';

class PreferencesScreen extends StatefulWidget {
  @override
  State createState() => _PreferencesState();
}
class _PreferencesState extends State<PreferencesScreen> {

  @override
  Widget build(BuildContext context) {
    final preferencesBloc = BlocProvider.of<PreferencesBloc>(context);
    final changePinBloc = BlocProvider.of<ChangePinBloc>(context);

    return BlocBuilder(
      bloc: preferencesBloc,
      builder: (ctx, state) {
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
                    onTap: () => _savePin(context, changePinBloc),
                  ),
                  SwitchListTile(
                    title: Text("¿Usar huella dactilar?"),
                    value: _getValueInLoadedPreferences(state, "uses_fingerprint") ?? false,
                    onChanged: (isUsingFingerprint) => _changeFingerprintUserPref(
                        preferencesBloc,
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
    var filterPreferences = state.preferences.where((pref) => pref.key == key);
    if(filterPreferences.isNotEmpty) {
      return filterPreferences.first.value;
    } else {
      return null;
    }
  }

  void _changeFingerprintUserPref(PreferencesBloc preferencesBloc, bool isUsingFingerprint) {
      final preference = PreferenceModel(
          key: "uses_fingerprint",
          value: isUsingFingerprint
      );
      preferencesBloc.dispatch(SavePreference(preference));
  }

  Future _savePin(BuildContext context, ChangePinBloc changePinBloc) async {
    changePinBloc.dispatch(StartPinChange());
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ChangePinScreen(changePinBloc: changePinBloc,)
    ));
  }
}