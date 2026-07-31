import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:kitabghar/core/error/failures.dart';
import 'package:kitabghar/core/providers/notification_provider.dart';
import 'package:kitabghar/features/auth/domain/entities/auth_entity.dart';
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
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SignupPage())),
              child: const Text('open signup'),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> pumpSignup(WidgetTester tester) async {
    await tester.pumpWidget(buildTestable());
    await tester.tap(find.text('open signup'));
    await tester.pumpAndSettle();
  }

  Future<void> fillValidForm(WidgetTester tester) async {
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Example Bahadur'), 'Jane Doe');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'example@gmail.com'),
        'jane@example.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'password'), 'password123');
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
  }

  group('SignupPage widget tests', () {
    testWidgets('renders name, email and password fields', (tester) async {
      await pumpSignup(tester);

      expect(find.byType(TextFormField), findsNWidgets(3));
      expect(find.text('Register'), findsOneWidget);
      expect(find.text('Sign up'), findsOneWidget);
    });

    testWidgets('renders the terms & conditions checkbox unchecked',
        (tester) async {
      await pumpSignup(tester);

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, false);
    });

    testWidgets('shows validation errors when submitted with empty fields',
        (tester) async {
      await pumpSignup(tester);

      await tester.ensureVisible(find.text('Sign up'));
      await tester.tap(find.text('Sign up'));
      await tester.pump();

      expect(find.text('Please enter full name'), findsOneWidget);
      expect(find.text('Please enter email'), findsOneWidget);
      expect(find.text('Password must be 6+ characters'), findsOneWidget);
      verifyNever(() => mockRegisterUseCase.call(any()));
    });

    testWidgets('shows a password-length validation error for short passwords',
        (tester) async {
      await pumpSignup(tester);

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Example Bahadur'), 'Jane Doe');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'example@gmail.com'),
          'jane@example.com');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'password'), '123');

      await tester.ensureVisible(find.text('Sign up'));
      await tester.tap(find.text('Sign up'));
      await tester.pump();

      expect(find.text('Password must be 6+ characters'), findsOneWidget);
    });

    testWidgets(
        'shows an error snackbar if the terms checkbox is not checked',
        (tester) async {
      await pumpSignup(tester);

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Example Bahadur'), 'Jane Doe');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'example@gmail.com'),
          'jane@example.com');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'password'), 'password123');

      await tester.ensureVisible(find.text('Sign up'));
      await tester.tap(find.text('Sign up'));
      await tester.pump();

      expect(find.text('Please agree to the terms and privacy.'),
          findsOneWidget);
      verifyNever(() => mockRegisterUseCase.call(any()));
    });

    testWidgets('toggles password visibility when the eye icon is tapped',
        (tester) async {
      await pumpSignup(tester);

      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();

      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });

    testWidgets('calls RegisterUseCase when the form is valid and terms are checked',
        (tester) async {
      when(() => mockRegisterUseCase.call(any()))
          .thenAnswer((_) async => const Right(true));

      await pumpSignup(tester);
      await fillValidForm(tester);

      await tester.ensureVisible(find.text('Sign up'));
      await tester.tap(find.text('Sign up'));
      await tester.pumpAndSettle();

      verify(() => mockRegisterUseCase.call(any())).called(1);
    });

    testWidgets('pops back to the previous page after successful registration',
        (tester) async {
      when(() => mockRegisterUseCase.call(any()))
          .thenAnswer((_) async => const Right(true));

      await pumpSignup(tester);
      await fillValidForm(tester);

      await tester.ensureVisible(find.text('Sign up'));
      await tester.tap(find.text('Sign up'));
      await tester.pumpAndSettle();

      expect(find.byType(SignupPage), findsNothing);
      expect(find.text('open signup'), findsOneWidget);
    });

    testWidgets('shows an error snackbar when registration fails',
        (tester) async {
      when(() => mockRegisterUseCase.call(any())).thenAnswer((_) async =>
          const Left(ApiFailure(message: 'Email already registered')));

      await pumpSignup(tester);
      await fillValidForm(tester);

      await tester.ensureVisible(find.text('Sign up'));
      await tester.tap(find.text('Sign up'));
      await tester.pumpAndSettle();

      expect(find.text('Email already registered'), findsOneWidget);
      expect(find.byType(SignupPage), findsOneWidget);
    });

    testWidgets('sends the trimmed name/email to RegisterUseCase',
        (tester) async {
      when(() => mockRegisterUseCase.call(any()))
          .thenAnswer((_) async => const Right(true));

      await pumpSignup(tester);
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Example Bahadur'),
          '  Jane Doe  ');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'example@gmail.com'),
          '  jane@example.com  ');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'password'), 'password123');
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      await tester.ensureVisible(find.text('Sign up'));
      await tester.tap(find.text('Sign up'));
      await tester.pumpAndSettle();

      final captured =
          verify(() => mockRegisterUseCase.call(captureAny())).captured.single
              as AuthEntity;
      expect(captured.name, 'Jane Doe');
      expect(captured.email, 'jane@example.com');
    });
  });
}
