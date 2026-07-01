import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:kitabghar/core/error/failures.dart';
import 'package:kitabghar/features/auth/domain/usecases/logout_usecase.dart';

import '../../../../mocks/mocks.mocks.dart';

void main() {
  late MockIAuthRepository mockRepository;
  late LogoutUseCase useCase;

  const tEmail = 'test@example.com';

  setUp(() {
    mockRepository = MockIAuthRepository();
    useCase = LogoutUseCase(repository: mockRepository);
  });

  test('should return true when logout succeeds', () async {
    when(mockRepository.logout(tEmail)).thenAnswer((_) async => const Right(true));

    final result = await useCase(tEmail);

    result.fold(
      (failure) => fail('Expected Right, got Left($failure)'),
      (success) => expect(success, true),
    );
    verify(mockRepository.logout(tEmail)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return a Failure when logout fails on the repository',
      () async {
    const tFailure = LocalFailure('Could not clear local session');
    when(mockRepository.logout(tEmail))
        .thenAnswer((_) async => const Left(tFailure));

    final result = await useCase(tEmail);

    result.fold(
      (failure) => expect(failure.message, tFailure.message),
      (success) => fail('Expected Left, got Right($success)'),
    );
    verify(mockRepository.logout(tEmail)).called(1);
  });
}