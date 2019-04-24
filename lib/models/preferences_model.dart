import 'package:meta/meta.dart';

class PreferenceModel<T> {

  String key;
  T value;

  PreferenceModel({ @required this.key, @required this.value });
}

