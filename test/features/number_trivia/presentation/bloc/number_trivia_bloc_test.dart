import 'package:bloc_test/bloc_test.dart';
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_application_1/core/error/failures.dart';
import 'package:flutter_application_1/core/usecases/usecase.dart';
import 'package:flutter_application_1/core/util/input_converter.dart';
import 'package:flutter_application_1/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:flutter_application_1/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:flutter_application_1/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:flutter_application_1/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';

import 'number_trivia_bloc_test.mocks.dart';

@GenerateMocks([
  GetConcreteNumberTrivia,
  GetRandomNumberTrivia,
  InputConverter,
])
void main() {
  late NumberTriviaBloc bloc;
  late MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  late MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  late MockInputConverter mockInputConverter;

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();

    bloc = NumberTriviaBloc(
      getConcreteNumberTrivia: mockGetConcreteNumberTrivia,
      getRandomNumberTrivia: mockGetRandomNumberTrivia,
      inputConverter: mockInputConverter,
    );
  });

  test('should bloc state is empty', () {
    // assert
    expect(bloc.state, equals(Empty()));
  });

  group('GetTriviaForConcreteNumber', () {
    const String tNumberString = '1';
    const int tNumberParsed = 1;
    const NumberTrivia tNumberTrivia =
        NumberTrivia(text: 'test trivia', number: 1);

    void setUpInputConverterSuccess() {
      when(mockInputConverter.stringToUnsignedInteger(any))
          .thenReturn(const Right(tNumberParsed));
    }

    blocTest(
      'should call the InputConverter to validate and convert the string to an unsigned integer.',
      build: () {
        setUpInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((realInvocation) async => const Right(tNumberTrivia));

        return bloc;
      },
      act: (Bloc bloc) =>
          bloc.add(const GetTriviaForConcreteNumber(tNumberString)),
      verify: (_) => {
        verify(mockInputConverter.stringToUnsignedInteger(tNumberString)),
      },
    );

    blocTest(
      'should emit [Error] when the input is invalid',
      build: () {
        when(mockInputConverter.stringToUnsignedInteger(any))
            .thenReturn(Left(InvalidInputFailure()));
        return bloc;
      },
      act: (Bloc bloc) =>
          bloc.add(const GetTriviaForConcreteNumber(tNumberString)),
      expect: () => [
        const Error(message: invalidInputFailureMessage),
      ],
    );

    blocTest(
      'should get data from the concrete use case',
      build: () {
        setUpInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((realInvocation) async => const Right(tNumberTrivia));

        return bloc;
      },
      act: (Bloc bloc) =>
          bloc.add(const GetTriviaForConcreteNumber(tNumberString)),
      verify: (_) => verify(
          mockGetConcreteNumberTrivia(const Params(number: tNumberParsed))),
    );

    blocTest(
      'should emit [Loading, Loaded] when data is gotten successfully',
      build: () {
        setUpInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((realInvocation) async => const Right(tNumberTrivia));

        return bloc;
      },
      act: (Bloc bloc) =>
          bloc.add(const GetTriviaForConcreteNumber(tNumberString)),
      expect: () => [
        Loading(),
        const Loaded(trivia: tNumberTrivia),
      ],
    );

    blocTest(
      'should emit [Loading, Error] when getting data fails',
      build: () {
        setUpInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((realInvocation) async => Left(ServerFailure()));

        return bloc;
      },
      act: (Bloc bloc) =>
          bloc.add(const GetTriviaForConcreteNumber(tNumberString)),
      expect: () => [
        Loading(),
        const Error(message: serverFailureMessage),
      ],
    );

    blocTest(
      'should emit [Loading, Error] when getting data cache fails',
      build: () {
        setUpInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((realInvocation) async => Left(CacheFailure()));

        return bloc;
      },
      act: (Bloc bloc) =>
          bloc.add(const GetTriviaForConcreteNumber(tNumberString)),
      expect: () => [
        Loading(),
        const Error(message: cacheFailureMessage),
      ],
    );
  });

  group('GetTriviaForRandomNumber', () {
    const NumberTrivia tNumberTrivia =
        NumberTrivia(text: 'test trivia', number: 1);

    blocTest(
      'should get data from the concrete use case',
      build: () {
        when(mockGetRandomNumberTrivia(any))
            .thenAnswer((realInvocation) async => const Right(tNumberTrivia));

        return bloc;
      },
      act: (Bloc bloc) => bloc.add(GetTriviaForRandomNumber()),
      verify: (_) => verify(mockGetRandomNumberTrivia(NoParams())),
    );

    blocTest(
      'should emit [Loading, Loaded] when data is gotten successfully',
      build: () {
        when(mockGetRandomNumberTrivia(any))
            .thenAnswer((realInvocation) async => const Right(tNumberTrivia));

        return bloc;
      },
      act: (Bloc bloc) => bloc.add(GetTriviaForRandomNumber()),
      expect: () => [
        Loading(),
        const Loaded(trivia: tNumberTrivia),
      ],
    );

    blocTest(
      'should emit [Loading, Error] when getting data fails',
      build: () {
        when(mockGetRandomNumberTrivia(any))
            .thenAnswer((realInvocation) async => Left(ServerFailure()));

        return bloc;
      },
      act: (Bloc bloc) => bloc.add(GetTriviaForRandomNumber()),
      expect: () => [
        Loading(),
        const Error(message: serverFailureMessage),
      ],
    );

    blocTest(
      'should emit [Loading, Error] when getting data cache fails',
      build: () {
        when(mockGetRandomNumberTrivia(any))
            .thenAnswer((realInvocation) async => Left(CacheFailure()));

        return bloc;
      },
      act: (Bloc bloc) => bloc.add(GetTriviaForRandomNumber()),
      expect: () => [
        Loading(),
        const Error(message: cacheFailureMessage),
      ],
    );
  });
}
