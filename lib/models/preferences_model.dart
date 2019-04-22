import 'package:meta/meta.dart';

class PreferenceModel<T> {

  String key;
  T value;

  PreferenceModel({ @required this.key, @required this.value });
}

class BiometricConfig {
  bool canCheck;
  bool uses;

  BiometricConfig({ this.canCheck = false, this.uses = false });
}