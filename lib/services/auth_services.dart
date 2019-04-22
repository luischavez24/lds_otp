import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final _secureStorage = FlutterSecureStorage();
  @override
  Future<bool> authenticate({ String pin }) async {
    final userPIN = await _secureStorage.read(key: "pin") ?? "1234";
    return userPIN == pin;
  }
}

class BiometricAuthService implements AuthService {
  final auth = new LocalAuthentication();

  @override
  Future<bool> authenticate({ String pin }) async {

    if(!(await auth.canCheckBiometrics)) {
      throw Exception("El dispositivo no tiene lector de huellas");
    }

    return await auth.authenticateWithBiometrics(
        localizedReason: 'Coloca tu huella en el sensor',
        useErrorDialogs: true,
        stickyAuth: false);
  }

  Future<bool> canCheckBiometrics() async {
    return await auth.canCheckBiometrics;
  }

  Future<bool> usesFingerprint() async {
    if(await canCheckBiometrics()) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getBool("uses_fingerprint") ?? false;
    }
    return false;
  }
}