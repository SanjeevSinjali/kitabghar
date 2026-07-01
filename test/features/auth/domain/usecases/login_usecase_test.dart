import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:kitabghar/core/error/failures.dart';
import 'package:kitabghar/features/auth/domain/entities/auth_entity.dart';
import 'package:kitabghar/features/auth/domain/usecases/login_usercase.dart';

import '../../../../mocks/mocks.mocks.dart';

void main() {
  late MockIAuthRepository mockRepository;
  late LoginUseCase useCase;

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tAuthEntity = AuthEntity(
    id: '1',
    name: 'Test User',
    email: tEmail,
    password: tPassword,
    phoneNumber: '9800000000',
    token: 'sample-token',
  );

  setUp(() {
    mockRepository = MockIAuthRepository();
    useCase = LoginUseCase(repository: mockRepository);
  });

  test('should return AuthEntity from the repository when login succeeds',
      () async {
    when(mockRepository.login(tEmail, tPassword))
        .thenAnswer((_) async => const Right(tAuthEntity));

    final result =
        await useCase(LoginParams(email: tEmail, password: tPassword));

    result.fold(
      (failure) => fail('Expected Right, got Left($failure)'),
      (user) => expect(user, tAuthEntity),
    );
    verify(mockRepository.login(tEmail, tPassword)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return a Failure when the repository call fails', () async {
    const tFailure = ApiFailure(message: 'Invalid email or password');
    when(mockRepository.login(tEmail, 'wrongPassword'))
        .thenAnswer((_) async => const Left(tFailure));

    final result =
        await useCase(LoginParams(email: tEmail, password: 'wrongPassword'));

    result.fold(
      (failure) => expect(failure.message, tFailure.message),
      (user) => fail('Expected Left, got Right($user)'),
    );
    verify(mockRepository.login(tEmail, 'wrongPassword')).called(1);
  });
}