import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:kitabghar/core/error/failures.dart';
import 'package:kitabghar/features/auth/domain/entities/auth_entity.dart';
import 'package:kitabghar/features/auth/presentation/pages/login_page.dart';
import 'package:kitabghar/features/auth/presentation/pages/signup_page.dart';
import 'package:kitabghar/features/auth/presentation/view_model/auth_view_model.dart';

import '../mocks/mocks.mocks.dart';

void main() {
  late MockLoginUseCase mockLoginUseCase;
  late MockRegisterUseCase mockRegisterUseCase;
  late MockLogoutUseCase mockLogoutUseCase;

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
  });

  Widget buildTestable() {
    return ProviderScope(
      overrides: [
        loginUseCaseProvider.overrideWithValue(mockLoginUseCase),
        registerUseCaseProvider.overrideWithValue(mockRegisterUseCase),
        logoutUseCaseProvider.overrideWithValue(mockLogoutUseCase),
      ],
      child: MaterialApp(
        home: const LoginPage(),
        routes: {
          '/dashboard': (_) => const Scaffold(body: Text('Dashboard')),
        },
      ),
    );
  }

  Future<void> fillValidForm(WidgetTester tester) async {
    await tester.enterText(
        find.widgetWithText(TextFormField, 'example@gmail.com'),
        'test@example.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'password'), 'password123');
  }

  group('LoginPage widget tests', () {
    testWidgets('renders the email field, password field and login button',
        (tester) async {
      await tester.pumpWidget(buildTestable());

      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Login'), findsOneWidget);
      expect(find.text("Don't have an account? "), findsOneWidget);
    });

    testWidgets('shows validation errors when submitted with empty fields',
        (tester) async {
      await tester.pumpWidget(buildTestable());

      final loginButton = find.text('Login');
      await tester.ensureVisible(loginButton);
      await tester.tap(loginButton);
      await tester.pump();

      expect(find.text('Please enter email'), findsOneWidget);
      expect(find.text('Please enter password'), findsOneWidget);
      verifyZeroInteractions(mockLoginUseCase);
    });

    testWidgets('toggles password visibility when the eye icon is tapped',
        (tester) async {
      await tester.pumpWidget(buildTestable());

      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_outlined), findsNothing);

      final eyeIcon = find.byIcon(Icons.visibility_off_outlined);
      await tester.ensureVisible(eyeIcon);
      await tester.tap(eyeIcon);
      await tester.pump();

      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off_outlined), findsNothing);
    });

    testWidgets('shows a loading indicator while the login call is pending',
        (tester) async {
      final completer = Completer<Either<Failure, AuthEntity>>();
      when(mockLoginUseCase.call(any))
          .thenAnswer((_) => completer.future);

      await tester.pumpWidget(buildTestable());
      await fillValidForm(tester);

      final loginButton = find.text('Login');
      await tester.ensureVisible(loginButton);
      await tester.tap(loginButton);
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete(const Right(tAuthEntity));
      await tester.pumpAndSettle();
    });

    testWidgets('calls LoginUseCase and navigates to dashboard on success',
        (tester) async {
      when(mockLoginUseCase.call(any))
          .thenAnswer((_) async => const Right(tAuthEntity));

      await tester.pumpWidget(buildTestable());
      await fillValidForm(tester);

      final loginButton = find.text('Login');
      await tester.ensureVisible(loginButton);
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      verify(mockLoginUseCase.call(any)).called(1);
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.byType(LoginPage), findsNothing);
    });

    testWidgets('shows an error snackbar when login fails', (tester) async {
      when(mockLoginUseCase.call(any)).thenAnswer((_) async =>
          const Left(ApiFailure(message: 'Invalid credentials')));

      await tester.pumpWidget(buildTestable());
      await fillValidForm(tester);

      final loginButton = find.text('Login');
      await tester.ensureVisible(loginButton);
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      expect(find.text('Invalid credentials'), findsOneWidget);
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('navigates to SignupPage when "Sign up" is tapped',
        (tester) async {
      await tester.pumpWidget(buildTestable());

      final signUpLink = find.text('Sign up');
      await tester.ensureVisible(signUpLink);
      await tester.tap(signUpLink);
      await tester.pumpAndSettle();

      expect(find.byType(SignupPage), findsOneWidget);
    });
  });
}