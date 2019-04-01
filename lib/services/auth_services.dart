import 'package:shared_preferences/shared_preferences.dart';
import 'package:dbcrypt/dbcrypt.dart';
import 'package:local_auth/local_auth.dart';

enum AuthType {
  BIOMETRIC,
  PIN
}
abstract class AuthService {

  Future<bool> authenticate({ String pin });

  factory AuthService.getServiceByAuthType(AuthType authType) {
    if (authType == AuthType.PIN) {
      return PinAuthService();
    } else if (authType == AuthType.BIOMETRIC) {
      return BiometricAuthService();
    } else {
      throw Exception("Tipo de autenticación no soportado");
    }
  }
}

class PinAuthService implements AuthService {
  final DBCrypt _crypt = DBCrypt();

  @override
  Future<bool> authenticate({ String pin }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var defaultPin = _crypt.hashpw("1234", DBCrypt().gensalt());
    return  _crypt.checkpw(pin, prefs.getString("pin") ?? defaultPin);
  }
}

class BiometricAuthService implements AuthService {
  final auth = new LocalAuthentication();

  @override
  Future<bool> authenticate({ String pin }) async {
    return await auth.authenticateWithBiometrics(
        localizedReason: 'Coloca tu huella en el sensor',
        useErrorDialogs: true,
        stickyAuth: false);
  }
}