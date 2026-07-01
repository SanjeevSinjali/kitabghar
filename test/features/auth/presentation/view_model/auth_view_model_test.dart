import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:kitabghar/core/error/failures.dart';
import 'package:kitabghar/features/auth/domain/entities/auth_entity.dart';
import 'package:kitabghar/features/auth/presentation/view_model/auth_view_model.dart';

import '../../../../mocks/mocks.mocks.dart';

void main() {
  late MockLoginUseCase mockLoginUseCase;
  late MockRegisterUseCase mockRegisterUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late AuthNotifier notifier;

  const tAuthEntity = AuthEntity(
    id: '1',
    name: 'Test User',
    email: 'test@example.com',
    password: 'password123',
    phoneNumber: '9800000000',
    token: 'sample-token',
  );

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockRegisterUseCase = MockRegisterUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    notifier = AuthNotifier(
      registerUseCase: mockRegisterUseCase,
      loginUseCase: mockLoginUseCase,
      logoutUseCase: mockLogoutUseCase,
    );
  });

  test('login() should set isSuccess true and store the user on success',
      () async {
    when(mockLoginUseCase.call(any))
        .thenAnswer((_) async => const Right(tAuthEntity));

    await notifier.login('test@example.com', 'password123');

    expect(notifier.state.isLoading, false);
    expect(notifier.state.isSuccess, true);
    expect(notifier.state.user, tAuthEntity);
    expect(notifier.state.error, null);
  });

  test('login() should set an error message and keep user null on failure',
      () async {
    when(mockLoginUseCase.call(any)).thenAnswer(
        (_) async => const Left(ApiFailure(message: 'Invalid credentials')));

    await notifier.login('bad@example.com', 'wrongPassword');

    expect(notifier.state.isLoading, false);
    expect(notifier.state.isSuccess, false);
    expect(notifier.state.user, null);
    expect(notifier.state.error, 'Invalid credentials');
  });

  test('register() should set isSuccess true when registration succeeds',
      () async {
    when(mockRegisterUseCase.call(any))
        .thenAnswer((_) async => const Right(true));

    await notifier.register(tAuthEntity);

    expect(notifier.state.isLoading, false);
    expect(notifier.state.isSuccess, true);
    expect(notifier.state.error, null);
  });
}