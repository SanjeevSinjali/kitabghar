import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:kitabghar/features/auth/domain/usecases/login_usercase.dart';
import 'package:kitabghar/features/auth/domain/usecases/logout_usecase.dart';
import 'package:kitabghar/features/auth/domain/usecases/register_usecase.dart';

import '../../../../mocktail_mocks.dart';

void main() {
  late MockAuthRepository mockRepository;
  late LoginUseCase loginUseCase;
  late RegisterUseCase registerUseCase;
  late LogoutUseCase logoutUseCase;

  setUpAll(registerAllFallbackValues);

  setUp(() {
    mockRepository = MockAuthRepository();
    loginUseCase = LoginUseCase(repository: mockRepository);
    registerUseCase = RegisterUseCase(repository: mockRepository);
    logoutUseCase = LogoutUseCase(repository: mockRepository);
  });

  group('LoginUseCase', () {
    final params = LoginParams(email: 'test@example.com', password: 'password123');

    test('returns Right(AuthEntity) when repository login succeeds', () async {
      when(() => mockRepository.login(params.email, params.password))
          .thenAnswer((_) async => const Right(tAuthEntity));

      final result = await loginUseCase(params);

      expect(result, const Right(tAuthEntity));
    });

    test('returns Left(Failure) when repository login fails', () async {
      when(() => mockRepository.login(params.email, params.password))
          .thenAnswer((_) async => const Left(tApiFailure));

      final result = await loginUseCase(params);

      expect(result, const Left(tApiFailure));
    });

    test('calls repository.login exactly once with the given email/password',
        () async {
      when(() => mockRepository.login(any(), any()))
          .thenAnswer((_) async => const Right(tAuthEntity));

      await loginUseCase(params);

      verify(() => mockRepository.login('test@example.com', 'password123'))
          .called(1);
    });

    test('propagates a LocalFailure unchanged from the repository', () async {
      when(() => mockRepository.login(any(), any()))
          .thenAnswer((_) async => const Left(tLocalFailure));

      final result = await loginUseCase(params);

      expect(result.isLeft(), true);
      result.fold((f) => expect(f.message, 'Local storage error'), (_) => fail('expected Left'));
    });
  });

  group('RegisterUseCase', () {
    test('returns Right(true) when repository register succeeds', () async {
      when(() => mockRepository.register(any()))
          .thenAnswer((_) async => const Right(true));

      final result = await registerUseCase(tAuthEntity);

      expect(result, const Right(true));
    });

    test('returns Left(Failure) when repository register fails', () async {
      when(() => mockRepository.register(any()))
          .thenAnswer((_) async => const Left(tApiFailure));

      final result = await registerUseCase(tAuthEntity);

      expect(result, const Left(tApiFailure));
    });

    test('passes the exact AuthEntity through to the repository', () async {
      when(() => mockRepository.register(any()))
          .thenAnswer((_) async => const Right(true));

      await registerUseCase(tAuthEntity);

      verify(() => mockRepository.register(tAuthEntity)).called(1);
    });

    test('does not call login or logout when registering', () async {
      when(() => mockRepository.register(any()))
          .thenAnswer((_) async => const Right(true));

      await registerUseCase(tAuthEntity);

      verifyNever(() => mockRepository.login(any(), any()));
      verifyNever(() => mockRepository.logout(any()));
    });
  });

  group('LogoutUseCase', () {
    const email = 'test@example.com';

    test('returns Right(true) when repository logout succeeds', () async {
      when(() => mockRepository.logout(email))
          .thenAnswer((_) async => const Right(true));

      final result = await logoutUseCase(email);

      expect(result, const Right(true));
    });

    test('returns Left(Failure) when repository logout fails', () async {
      when(() => mockRepository.logout(email))
          .thenAnswer((_) async => const Left(tApiFailure));

      final result = await logoutUseCase(email);

      expect(result, const Left(tApiFailure));
    });

    test('calls repository.logout with the exact email provided', () async {
      when(() => mockRepository.logout(any()))
          .thenAnswer((_) async => const Right(true));

      await logoutUseCase('someone@kitabghar.com');

      verify(() => mockRepository.logout('someone@kitabghar.com')).called(1);
    });

    test('does not swallow an unexpected LocalFailure', () async {
      when(() => mockRepository.logout(any()))
          .thenAnswer((_) async => const Left(tLocalFailure));

      final result = await logoutUseCase(email);

      expect(result, const Left(tLocalFailure));
    });
  });
}
