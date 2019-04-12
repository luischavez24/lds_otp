import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lds_otp/models/preferences_model.dart';
import 'package:lds_otp/repository/preferences_repository.dart';

class PreferencesBloc extends Bloc<PreferencesEvent, PreferencesState>{
  final _repository = PreferencesRepository();
  @override
  PreferencesState get initialState => PreferencesLoading();

  @override
  Stream<PreferencesState> mapEventToState(PreferencesEvent event) async*{
    if (event is LoadPreferences) {
      yield* _mapLoadPreferencesToState();
    } else if(event is SavePreference) {
      yield* _mapSavePreferenceToState(event);
    }
  }

  Stream<PreferencesState> _mapLoadPreferencesToState() async* {
    try {
      final preferences = await _repository.getAllPreferences();
      yield PreferencesLoaded(preferences);
    } catch(_) {
      yield PreferencesNotLoaded();
    }
  }
  Stream<PreferencesState> _mapSavePreferenceToState(SavePreference event) async*{
    if(currentState is PreferencesLoaded) {
      await _repository.savePreference(event.preference);
      yield* _mapLoadPreferencesToState();
    }
  }
}

class PreferencesState extends Equatable {
  PreferencesState([List props = const []]) : super(props);
}

class PreferencesLoading extends PreferencesState { }

class PreferencesLoaded extends PreferencesState {
  final List<PreferenceModel> preferences;
  PreferencesLoaded([this.preferences = const []]) : super([preferences]);
}

class PreferencesNotLoaded extends PreferencesState { }

class PreferencesEvent extends Equatable {
  PreferencesEvent([List props = const []]) : super(props);
}

class LoadPreferences extends PreferencesEvent {
  final List<PreferenceModel> preferences;
  LoadPreferences([this.preferences]) : super([preferences]);
}


class SavePreference extends PreferencesEvent {
  final PreferenceModel preference;
  SavePreference([this.preference]) : super([preference]);
}