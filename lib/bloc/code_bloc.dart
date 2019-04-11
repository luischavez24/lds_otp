import 'package:bloc/bloc.dart';
import 'package:lds_otp/models/code_model.dart';
import 'package:lds_otp/storage/db_provider.dart';
import 'package:equatable/equatable.dart';

class CodesBloc extends Bloc<CodesEvent, CodesState> {
  final _repository = DBProvider.db;

  @override
  CodesState get initialState => CodesLoading();

  @override
  Stream<CodesState> mapEventToState(CodesEvent event) async *{
      if (event is LoadCodes) {
        yield* _mapLoadCodesToState();
      } else if(event is AddCode) {
        yield* _mapAddCodeToState(currentState, event);
      } else if(event is DeleteCode){
        yield* _mapDeleteCodeToState(currentState, event);
      }
  }

  Stream<CodesState> _mapLoadCodesToState() async* {
    try {
      final codes = await _repository.getAllCodes();
      yield CodesLoaded(codes);
    } catch(_) {
      yield CodesNotLoaded();
    }
  }

  Stream<CodesState> _mapAddCodeToState(CodesState currentState, AddCode event) async*{
    if(currentState is CodesLoaded) {
      final CodeModel newCode = event.code;
      await _repository.addCode(newCode);
      yield* _mapLoadCodesToState();
    }
  }
  Stream<CodesState> _mapDeleteCodeToState(CodesState currentState, DeleteCode event) async* {
    if(currentState is CodesLoaded) {
      final CodeModel code = event.code;
      await _repository.deleteCode(code.user, code.domain);
      yield* _mapLoadCodesToState();
    }
  }
}

abstract class CodesState extends Equatable {
  CodesState([List props = const []]) : super(props);
}



class CodesLoading extends CodesState {
  @override
  String toString() => 'CodesLoading';
}

class CodesLoaded extends CodesState {
  final List<CodeModel> codes;

  CodesLoaded([this.codes = const []]) : super([codes]);

  @override
  String toString() => 'CodesLoaded';
}

class CodesNotLoaded extends CodesState {
  @override
  String toString() => 'CodesNotLoaded';
}

abstract class CodesEvent extends Equatable {
  CodesEvent([List props = const []]) : super(props);
}

class LoadCodes extends CodesEvent {
  @override
  String toString() => 'LoadCodes';
}

class AddCode extends CodesEvent {
  final CodeModel code;

  AddCode(this.code) : super([code]);

  @override
  String toString() => 'AddCode { code: $code }';
}

class DeleteCode extends CodesEvent {
  final CodeModel code;

  DeleteCode(this.code) : super([code]);

  @override
  String toString() => 'DeleteCode { code: $code }';
}