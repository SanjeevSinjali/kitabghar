import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:kitabghar/core/error/failures.dart';
import 'package:kitabghar/core/providers/notification_provider.dart';
import 'package:kitabghar/features/auth/domain/entities/auth_entity.dart';
import 'package:kitabghar/features/auth/domain/usecases/login_usercase.dart';
import 'package:kitabghar/features/auth/presentation/pages/login_page.dart';
import 'package:kitabghar/features/auth/presentation/pages/signup_page.dart';
import 'package:kitabghar/features/auth/presentation/view_model/auth_view_model.dart';

import '../fakes/fake_notification_service.dart';
import '../mocktail_mocks.dart';

void main() {
  late MockLoginUseCase mockLoginUseCase;
  late MockRegisterUseCase mockRegisterUseCase;
  late MockLogoutUseCase mockLogoutUseCase;

  setUpAll(registerAllFallbackValues);

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
        notificationServiceProvider.overrideWithValue(FakeNotificationService()),
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

    testWidgets('renders the "Welcome back" heading and subtitle',
        (tester) async {
      await tester.pumpWidget(buildTestable());

      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Start your reading adventure'), findsOneWidget);
    });

    testWidgets('renders a "Remember me" checkbox unchecked by default',
        (tester) async {
      await tester.pumpWidget(buildTestable());

      expect(find.text('Remember me'), findsOneWidget);
      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, false);
    });

    testWidgets('renders a "Continue with Google" button', (tester) async {
      await tester.pumpWidget(buildTestable());

      expect(find.text('Continue with Google'), findsOneWidget);
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
      verifyNever(() => mockLoginUseCase.call(any()));
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

    testWidgets('toggles the "Remember me" checkbox when tapped',
        (tester) async {
      await tester.pumpWidget(buildTestable());

      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, true);
    });

    testWidgets('shows a loading indicator while the login call is pending',
        (tester) async {
      final completer = Completer<Either<Failure, AuthEntity>>();
      when(() => mockLoginUseCase.call(any()))
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
      when(() => mockLoginUseCase.call(any()))
          .thenAnswer((_) async => const Right(tAuthEntity));

      await tester.pumpWidget(buildTestable());
      await fillValidForm(tester);

      final loginButton = find.text('Login');
      await tester.ensureVisible(loginButton);
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      verify(() => mockLoginUseCase.call(any())).called(1);
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.byType(LoginPage), findsNothing);
    });

    testWidgets('shows an error dialog when login fails', (tester) async {
      when(() => mockLoginUseCase.call(any())).thenAnswer((_) async =>
          const Left(ApiFailure(message: 'Invalid credentials')));

      await tester.pumpWidget(buildTestable());
      await fillValidForm(tester);

      final loginButton = find.text('Login');
      await tester.ensureVisible(loginButton);
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      expect(find.text('Password incorrect'), findsOneWidget);
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('dismisses the error dialog when "Got it" is tapped',
        (tester) async {
      when(() => mockLoginUseCase.call(any())).thenAnswer((_) async =>
          const Left(ApiFailure(message: 'Invalid credentials')));

      await tester.pumpWidget(buildTestable());
      await fillValidForm(tester);
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Got it'));
      await tester.pumpAndSettle();

      expect(find.text('Password incorrect'), findsNothing);
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

    testWidgets('trims whitespace from the email before calling LoginUseCase',
        (tester) async {
      when(() => mockLoginUseCase.call(any()))
          .thenAnswer((_) async => const Right(tAuthEntity));

      await tester.pumpWidget(buildTestable());
      await tester.enterText(
          find.widgetWithText(TextFormField, 'example@gmail.com'),
          '  test@example.com  ');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'password'), 'password123');

      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      final captured =
          verify(() => mockLoginUseCase.call(captureAny())).captured.single
              as LoginParams;
      expect(captured.email, 'test@example.com');
    });
  });
}
