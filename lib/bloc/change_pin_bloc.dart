import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lds_otp/repository/secrets_repository.dart';
import 'package:lds_otp/utils/exception.dart';

class ChangePinBloc extends Bloc<ChangePinEvent, ChangePinState>{

  final _secretsRepository = SecretsRepository();

  @override
  ChangePinState get initialState => ChangePinStarted();

  @override
  Stream<ChangePinState> mapEventToState(ChangePinEvent event) async* {
    if(event is ChangePin) {
        yield* _mapChangePinToState(event);
    } else if(event is StartPinChange) {
        yield ChangePinStarted();
    }
  }

  Stream<ChangePinState> _mapChangePinToState(ChangePin event) async* {
    if(!(currentState is ChangePinFinished)) {
      try {
        await _secretsRepository.changePin(event.oldPin, event.newPin);
        yield ChangePinFinished();
      } on AuthFailException {
        yield PinWrong();
      } on SamePinException {
        yield PinEqual();
      }
    }
  }
}

abstract class ChangePinState extends Equatable {
  ChangePinState([List props = const []]) : super(props);
}

class ChangePinStarted extends ChangePinState { }

class PinEqual extends ChangePinState { }

class PinWrong extends ChangePinState { }

class ChangePinFinished extends ChangePinState { }

abstract class ChangePinEvent extends Equatable {
  ChangePinEvent([List props = const []]) : super(props);
}

class StartPinChange extends ChangePinEvent {}
class ChangePin extends ChangePinEvent {
  final oldPin;
  final newPin;
  ChangePin([this.oldPin, this.newPin]) : super([oldPin, newPin]);
}



