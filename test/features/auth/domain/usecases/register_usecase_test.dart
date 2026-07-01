import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:kitabghar/core/error/failures.dart';
import 'package:kitabghar/features/auth/domain/entities/auth_entity.dart';
import 'package:kitabghar/features/auth/domain/usecases/register_usecase.dart';

import '../../../../mocks/mocks.mocks.dart';

void main() {
  late MockIAuthRepository mockRepository;
  late RegisterUseCase useCase;

  const tAuthEntity = AuthEntity(
    name: 'New User',
    email: 'new.user@example.com',
    password: 'strongPass1',
    phoneNumber: '9811111111',
  );

  setUp(() {
    mockRepository = MockIAuthRepository();
    useCase = RegisterUseCase(repository: mockRepository);
  });

  test('should return true when registration succeeds', () async {
    when(mockRepository.register(tAuthEntity))
        .thenAnswer((_) async => const Right(true));

    final result = await useCase(tAuthEntity);

    result.fold(
      (failure) => fail('Expected Right, got Left($failure)'),
      (success) => expect(success, true),
    );
    verify(mockRepository.register(tAuthEntity)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return a Failure when the email is already registered',
      () async {
    const tFailure = ApiFailure(message: 'Email already in use');
    when(mockRepository.register(tAuthEntity))
        .thenAnswer((_) async => const Left(tFailure));

    final result = await useCase(tAuthEntity);

    result.fold(
      (failure) => expect(failure.message, tFailure.message),
      (success) => fail('Expected Left, got Right($success)'),
    );
    verify(mockRepository.register(tAuthEntity)).called(1);
  });
}