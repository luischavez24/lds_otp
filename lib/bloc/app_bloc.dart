import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lds_otp/services/preference_service.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final preferencesService = PreferencesService();

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
    if(await preferencesService.isAppFirstUse()) {
      yield AppFirstUse();
    } else {
      yield AppNormalUse();
    }
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