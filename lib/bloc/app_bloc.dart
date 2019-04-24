import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lds_otp/repository/preferences_repository.dart';
import 'package:lds_otp/repository/secrets_repository.dart';

class AppBloc extends Bloc<AppEvent, AppState> {

  @override
  AppState get initialState => AppStarted();

  @override
  Stream<AppState> mapEventToState (AppEvent event)  async* {
    if(event is CheckAppUse) {
      yield* _mapCheckAppUseToState(event);
    }
  }

  Stream<AppState> _mapCheckAppUseToState(CheckAppUse event) async* {

    yield AppLoading();

    // TODO: Wrap this logic in a service
    final secretsRepository = SecretsRepository();

    final preferencesRepository = PreferencesRepository();

    final hasPin = (await secretsRepository.getSecret("pin")) != null;

    final usesFingerprint = (
        await preferencesRepository.getPreference("uses_fingerprint")) != null;

    yield hasPin && usesFingerprint ? AppNormalUse() : AppFirstUse();

  }
}

abstract class AppState extends Equatable {
  AppState([List props = const []]) : super(props);
}
class AppLoading extends AppState {

}
class AppStarted extends AppState {

}

class AppNormalUse extends AppState {

}

class AppFirstUse extends AppState {

}

abstract class AppEvent extends Equatable {
  AppEvent([List props = const []]) : super(props);
}

class CheckAppUse extends AppEvent {}