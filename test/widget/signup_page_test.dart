import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:kitabghar/features/auth/presentation/pages/signup_page.dart';
import 'package:kitabghar/features/auth/presentation/view_model/auth_view_model.dart';

import '../mocks/mocks.mocks.dart';

void main() {
  late MockLoginUseCase mockLoginUseCase;
  late MockRegisterUseCase mockRegisterUseCase;
  late MockLogoutUseCase mockLogoutUseCase;

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
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignupPage()),
                ),
                child: const Text('Open Signup'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> openSignupPage(WidgetTester tester) async {
    await tester.pumpWidget(buildTestable());
    await tester.tap(find.text('Open Signup'));
    await tester.pumpAndSettle();
  }

  Future<void> fillValidForm(WidgetTester tester) async {
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Example Bahadur'), 'Jane Doe');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'example@gmail.com'),
        'jane@example.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, '98XXXXXXXX'), '9812345678');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'password'), 'password123');
  }

  group('SignupPage widget tests', () {
    testWidgets('renders all registration fields', (tester) async {
      await openSignupPage(tester);

      expect(find.byType(TextFormField), findsNWidgets(4));
      expect(find.text('Register'), findsOneWidget);
      expect(find.text('Sign up'), findsOneWidget);
    });

    testWidgets(
        'shows a terms-and-conditions error when submitted without agreeing',
        (tester) async {
      await openSignupPage(tester);
      await fillValidForm(tester);

      final signUpButton = find.text('Sign up');
      await tester.ensureVisible(signUpButton);
      await tester.tap(signUpButton);
      await tester.pump();

      expect(find.text('Please agree to the terms and privacy.'),
          findsOneWidget);
      verifyZeroInteractions(mockRegisterUseCase);
    });

    testWidgets(
        'calls RegisterUseCase and pops the page on successful registration',
        (tester) async {
      when(mockRegisterUseCase.call(any))
          .thenAnswer((_) async => const Right(true));

      await openSignupPage(tester);
      await fillValidForm(tester);

      final checkbox = find.byType(Checkbox);
      await tester.ensureVisible(checkbox);
      await tester.tap(checkbox);
      await tester.pump();

      final signUpButton = find.text('Sign up');
      await tester.ensureVisible(signUpButton);
      await tester.tap(signUpButton);
      await tester.pumpAndSettle();

      verify(mockRegisterUseCase.call(any)).called(1);
      expect(find.text('Account created successfully!'), findsOneWidget);
      expect(find.byType(SignupPage), findsNothing);
      expect(find.text('Open Signup'), findsOneWidget);
    });
  });
}