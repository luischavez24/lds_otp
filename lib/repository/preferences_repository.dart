import 'package:shared_preferences/shared_preferences.dart';
import 'package:lds_otp/models/preferences_model.dart';

class PreferencesRepository {

  Future<List<PreferenceModel>> getAllPreferences() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getKeys()
        .map((key) => PreferenceModel(key: key, value: sharedPreferences.get(key)))
        .toList();

  }

  Future savePreference<T>(PreferenceModel<T> preference) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final key = preference.key;
    final value = preference.value;
    if(value is bool) {
      await sharedPreferences.setBool(key, value);
    } else if(value is String) {
      await sharedPreferences.setString(key, value);
    } else if(value is double) {
      await sharedPreferences.setDouble(key, value);
    } else if(value is int) {
      await sharedPreferences.setInt(key, value);
    } else {
      throw ArgumentError("T not supported");
    }
  }

  Future<PreferenceModel> getPreference(String key) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    return PreferenceModel(key: key, value: sharedPreferences.get(key));
  }
}