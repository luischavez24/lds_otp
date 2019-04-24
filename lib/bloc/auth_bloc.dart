import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:lds_otp/models/biometric_config.dart';
import 'package:lds_otp/services/auth_services.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState>{

  @override
  AuthState get initialState => AuthStarted();

  @override
  Stream<AuthState> mapEventToState(AuthEvent event) async*{
    if(event is CheckCredentials) {
      yield* _mapCheckCredentialsToState(event);
    } else if(event is Logout) {
      yield* _mapLogoutToState(event);
    } else if(event is CheckBiometrics) {
      yield* _mapCheckBiometricsToState(event);
    }
  }

  Stream<AuthState> _mapCheckCredentialsToState(CheckCredentials event) async*{
      if(!(currentState is AuthSuccessful)) {
        yield AuthChecking();
        final authService = AuthService.getServiceByAuthType(event.authType);
        try {
          var isAuthenticated = await authService.authenticate(pin: event.pin);
          if(isAuthenticated) {
            yield AuthSuccessful();
          } else {
            yield AuthFailed("Las credenciales son incorrectas", await _biometricConfig);
          }
        } on Exception catch(e) {
          yield AuthFailed("Ocurrio el siguiente error: $e", await _biometricConfig);
        }
      }
  }

  Stream<AuthState> _mapCheckBiometricsToState(CheckBiometrics event) async* {
    if(currentState is AuthStarted) {
      yield AuthChecking();
      var biometricConfig = await _biometricConfig;
      yield AuthStarted(biometricConfig);
    }
  }

  Future<BiometricConfig> get _biometricConfig async {
    final BiometricAuthService authService = AuthService.getServiceByAuthType(AuthType.BIOMETRIC);
    return BiometricConfig(
        canCheck: await authService.canCheckBiometrics(),
        uses: await authService.usesFingerprint()
    );
  }

  Stream<AuthState> _mapLogoutToState(Logout event) async*{
    if(currentState is AuthSuccessful) {
      yield AuthStarted(await _biometricConfig);
    }
  }
}

abstract class AuthState extends Equatable {
  AuthState([List props = const []]) : super(props);
}

class AuthStarted extends AuthState {
  BiometricConfig biometricConfig;
  AuthStarted([this.biometricConfig])
      : super([biometricConfig ?? BiometricConfig()]);
}

class AuthSuccessful extends AuthState { }

class AuthChecking extends AuthState { }

class AuthFailed extends AuthState {
  BiometricConfig biometricConfig ;
  String error;
  AuthFailed([this.error, this.biometricConfig])
      : super([error, biometricConfig ?? BiometricConfig()]);
}

abstract class AuthEvent extends Equatable {
  AuthEvent([List props = const []]) : super(props);
}

class CheckCredentials extends AuthEvent {
  AuthType authType;
  String pin;
  CheckCredentials([this.authType, this.pin]) : super ([authType, pin]);
}

class CheckBiometrics extends AuthEvent {}

class Logout extends AuthEvent {}