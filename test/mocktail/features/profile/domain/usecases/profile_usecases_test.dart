import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:kitabghar/features/profile/domian/usecases/confirm_password_change_usecase.dart';
import 'package:kitabghar/features/profile/domian/usecases/get_profile_usecase.dart';
import 'package:kitabghar/features/profile/domian/usecases/request_password_change_usecase.dart';
import 'package:kitabghar/features/profile/domian/usecases/update_profile_usecase.dart';

import '../../../../mocktail_mocks.dart';

void main() {
  late MockProfileRepository mockRepository;
  late GetProfileUseCase getProfileUseCase;
  late UpdateProfileUseCase updateProfileUseCase;
  late RequestPasswordChangeUseCase requestPasswordChangeUseCase;
  late ConfirmPasswordChangeUseCase confirmPasswordChangeUseCase;

  const tToken = 'sample-token';

  setUpAll(registerAllFallbackValues);

  setUp(() {
    mockRepository = MockProfileRepository();
    getProfileUseCase = GetProfileUseCase(repository: mockRepository);
    updateProfileUseCase = UpdateProfileUseCase(repository: mockRepository);
    requestPasswordChangeUseCase =
        RequestPasswordChangeUseCase(repository: mockRepository);
    confirmPasswordChangeUseCase =
        ConfirmPasswordChangeUseCase(repository: mockRepository);
  });

  group('GetProfileUseCase', () {
    test('returns Right(ProfileEntity) when the fetch succeeds', () async {
      when(() => mockRepository.getProfile(token: any(named: 'token')))
          .thenAnswer((_) async => const Right(tProfileEntity));

      final result = await getProfileUseCase(tToken);

      expect(result, const Right(tProfileEntity));
    });

    test('returns Left(Failure) when the fetch fails', () async {
      when(() => mockRepository.getProfile(token: any(named: 'token')))
          .thenAnswer((_) async => const Left(tApiFailure));

      final result = await getProfileUseCase(tToken);

      expect(result, const Left(tApiFailure));
    });

    test('calls repository.getProfile with the exact token', () async {
      when(() => mockRepository.getProfile(token: any(named: 'token')))
          .thenAnswer((_) async => const Right(tProfileEntity));

      await getProfileUseCase(tToken);

      verify(() => mockRepository.getProfile(token: tToken)).called(1);
    });
  });

  group('UpdateProfileUseCase', () {
    const params = UpdateProfileParams(token: tToken, name: 'New Name');

    test('returns Right(ProfileEntity) when the update succeeds', () async {
      when(() => mockRepository.updateProfile(
            token: any(named: 'token'),
            name: any(named: 'name'),
            email: any(named: 'email'),
            avatar: any(named: 'avatar'),
          )).thenAnswer((_) async => const Right(tProfileEntity));

      final result = await updateProfileUseCase(params);

      expect(result, const Right(tProfileEntity));
    });

    test('returns Left(Failure) when the update fails', () async {
      when(() => mockRepository.updateProfile(
            token: any(named: 'token'),
            name: any(named: 'name'),
            email: any(named: 'email'),
            avatar: any(named: 'avatar'),
          )).thenAnswer((_) async => const Left(tApiFailure));

      final result = await updateProfileUseCase(params);

      expect(result, const Left(tApiFailure));
    });

    test('forwards only the provided name field, leaving email/avatar null',
        () async {
      when(() => mockRepository.updateProfile(
            token: any(named: 'token'),
            name: any(named: 'name'),
            email: any(named: 'email'),
            avatar: any(named: 'avatar'),
          )).thenAnswer((_) async => const Right(tProfileEntity));

      await updateProfileUseCase(params);

      verify(() => mockRepository.updateProfile(
            token: tToken,
            name: 'New Name',
            email: null,
            avatar: null,
          )).called(1);
    });
  });

  group('RequestPasswordChangeUseCase', () {
    final params = RequestPasswordChangeParams(
        token: tToken, currentPassword: 'oldPassword123');

    test('returns Right(String) with a confirmation message on success',
        () async {
      when(() => mockRepository.requestPasswordChange(
              token: any(named: 'token'),
              currentPassword: any(named: 'currentPassword')))
          .thenAnswer((_) async => const Right('Verification code sent'));

      final result = await requestPasswordChangeUseCase(params);

      expect(result, const Right('Verification code sent'));
    });

    test('returns Left(Failure) when the current password is wrong',
        () async {
      when(() => mockRepository.requestPasswordChange(
              token: any(named: 'token'),
              currentPassword: any(named: 'currentPassword')))
          .thenAnswer((_) async => const Left(tApiFailure));

      final result = await requestPasswordChangeUseCase(params);

      expect(result, const Left(tApiFailure));
    });

    test('forwards the exact current password to the repository', () async {
      when(() => mockRepository.requestPasswordChange(
              token: any(named: 'token'),
              currentPassword: any(named: 'currentPassword')))
          .thenAnswer((_) async => const Right('Verification code sent'));

      await requestPasswordChangeUseCase(params);

      verify(() => mockRepository.requestPasswordChange(
          token: tToken, currentPassword: 'oldPassword123')).called(1);
    });
  });

  group('ConfirmPasswordChangeUseCase', () {
    final params = ConfirmPasswordChangeParams(
        token: tToken, code: '123456', newPassword: 'newPassword123');

    test('returns Right(String) with a success message when confirmed',
        () async {
      when(() => mockRepository.confirmPasswordChange(
              token: any(named: 'token'),
              code: any(named: 'code'),
              newPassword: any(named: 'newPassword')))
          .thenAnswer((_) async => const Right('Password changed'));

      final result = await confirmPasswordChangeUseCase(params);

      expect(result, const Right('Password changed'));
    });

    test('returns Left(Failure) when the verification code is invalid',
        () async {
      when(() => mockRepository.confirmPasswordChange(
              token: any(named: 'token'),
              code: any(named: 'code'),
              newPassword: any(named: 'newPassword')))
          .thenAnswer((_) async => const Left(tApiFailure));

      final result = await confirmPasswordChangeUseCase(params);

      expect(result, const Left(tApiFailure));
    });

    test('forwards the exact code and new password to the repository',
        () async {
      when(() => mockRepository.confirmPasswordChange(
              token: any(named: 'token'),
              code: any(named: 'code'),
              newPassword: any(named: 'newPassword')))
          .thenAnswer((_) async => const Right('Password changed'));

      await confirmPasswordChangeUseCase(params);

      verify(() => mockRepository.confirmPasswordChange(
          token: tToken, code: '123456', newPassword: 'newPassword123')).called(1);
    });
  });
}
