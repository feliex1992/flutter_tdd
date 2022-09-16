import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_application_1/core/error/failures.dart';
import 'package:flutter_application_1/core/usecases/usecase.dart';
import 'package:flutter_application_1/core/util/input_converter.dart';
import 'package:flutter_application_1/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:flutter_application_1/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:flutter_application_1/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:flutter_application_1/features/number_trivia/domain/usecases/get_random_number_trivia.dart';

part 'number_trivia_event.dart';
part 'number_trivia_state.dart';

const String serverFailureMessage = 'Server Failure';
const String cacheFailureMessage = 'Cache Failure';
const String invalidInputFailureMessage =
    'Invalid Input - The number must be a positive integer or zero.';

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  final GetConcreteNumberTrivia getConcreteNumberTrivia;
  final GetRandomNumberTrivia getRandomNumberTrivia;
  final InputConverter inputConverter;

  NumberTriviaBloc({
    required this.getConcreteNumberTrivia,
    required this.getRandomNumberTrivia,
    required this.inputConverter,
  }) : super(Empty()) {
    on<GetTriviaForConcreteNumber>(_onGetTriviaForConcreteNumber);
    on<GetTriviaForRandomNumber>(_onGetTriviaForRandomNumber);
  }

  Future<void> _onGetTriviaForConcreteNumber(
    GetTriviaForConcreteNumber event,
    Emitter<NumberTriviaState> emit,
  ) async {
    final inputEither =
        inputConverter.stringToUnsignedInteger(event.numberString);
    inputEither.fold(
      (Failure failure) =>
          emit(const Error(message: invalidInputFailureMessage)),
      (int number) async {
        await _getTriviaConcreteOrRandom(
          emit,
          () => getConcreteNumberTrivia(Params(number: number)),
        );
      },
    );
  }

  Future<void> _onGetTriviaForRandomNumber(
    GetTriviaForRandomNumber event,
    Emitter<NumberTriviaState> emit,
  ) async {
    await _getTriviaConcreteOrRandom(
      emit,
      () => getRandomNumberTrivia(NoParams()),
    );
  }

  Future<void> _getTriviaConcreteOrRandom(
      Emitter<NumberTriviaState> emit,
      Future<Either<Failure, NumberTrivia>> Function()
          _getConcreteOrRandom) async {
    emit(Loading());
    final failureOrTrivia = await _getConcreteOrRandom();
    failureOrTrivia.fold((failure) {
      emit(Error(
        message: _mapFailureToMessage(failure),
      ));
    }, (trivia) => emit(Loaded(trivia: trivia)));
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return serverFailureMessage;
      case CacheFailure:
        return cacheFailureMessage;
      default:
        return 'Unexpected error';
    }
  }
}
