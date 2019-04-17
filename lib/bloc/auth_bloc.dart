import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:lds_otp/services/auth_services.dart';
import 'package:lds_otp/utils/exception.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState>{
  @override
  AuthState get initialState => AuthStarted();

  @override
  Stream<AuthState> mapEventToState(AuthEvent event) async*{
    if(event is CheckCredentials) {
      yield* _mapCheckCredentialsToState(event);
    } else if(event is Logout) {
      yield* _mapLogoutToState(event);
    }
  }

  Stream<AuthState> _mapCheckCredentialsToState(CheckCredentials event) async*{
      if(!(currentState is AuthSuccessful)) {
        yield AuthChecking();
        final authService = AuthService.getServiceByAuthType(event.authType);
        var isAuthenticated = await authService.authenticate(pin: event.pin);
        yield isAuthenticated ? AuthSuccessful() : AuthFailed();
      }
  }

  Stream<AuthState> _mapLogoutToState(Logout event) async*{
    if(currentState is AuthSuccessful) {
      yield AuthStarted();
    }
  }
}

abstract class AuthState extends Equatable {
  AuthState([List props = const []]) : super(props);
}

class AuthStarted extends AuthState { }

class AuthSuccessful extends AuthState { }

class AuthChecking extends AuthState { }

class AuthFailed extends AuthState { }

abstract class AuthEvent extends Equatable {
  AuthEvent([List props = const []]) : super(props);
}

class CheckCredentials extends AuthEvent {
  AuthType authType;
  String pin;
  CheckCredentials([this.authType, this.pin]) : super ([authType, pin]);
}

class Logout extends AuthEvent {}