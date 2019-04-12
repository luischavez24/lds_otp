import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lds_otp/utils/exception.dart';

class SecretsRepository {
  final _secureStorage = FlutterSecureStorage();

  Future<String> getSecret(String key) async {
    return await _secureStorage.read(key: key);
  }

  Future saveSecret(String key, String value) async {
    await _secureStorage.write(key: key , value: value);
  }

  Future changePin(String oldValue, String newValue) async {
    if(oldValue == newValue) {
      var isAuthenticated = await verifyPin(oldValue);
      if(isAuthenticated) {
        await saveSecret("pin", newValue);
      } else {
        throw AuthFailException("Los pins no coinciden");
      }
    } else {
      throw SamePinException("Los pins ingresados son iguales");
    }
  }

  Future<bool> verifyPin(String pin) async => (pin == await getSecret("pin"));
}