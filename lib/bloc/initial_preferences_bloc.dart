import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:lds_otp/repository/secrets_repository.dart';
import 'package:lds_otp/utils/exception.dart';

class InitialPreferencesBloc extends Bloc<InitialPreferencesEvent, InitialPreferencesState> {

  @override
  InitialPreferencesState get initialState => InitialPreferencesStarted();

  @override
  Stream<InitialPreferencesState> mapEventToState (
      InitialPreferencesEvent event)  async*{
      yield InitialPreferencesStarted();
  }
}

abstract class InitialPreferencesState extends Equatable {
  InitialPreferencesState([List props = const []]) : super(props);
}
class InitialPreferencesStarted extends InitialPreferencesState {}
abstract class InitialPreferencesEvent extends Equatable {
  InitialPreferencesEvent([List props = const []]) : super(props);
}