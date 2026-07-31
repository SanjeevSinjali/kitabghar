import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kitabghar/core/api/api_client.dart';
import 'package:kitabghar/features/auth/presentation/pages/recover_password_page.dart';
import 'package:kitabghar/features/auth/presentation/view_model/password_recovery_view_model.dart';

/// A test double for PasswordRecoveryNotifier that lets each test decide
/// exactly what requestCode/resetPassword should do, without making any
/// real network calls through ApiClient.
class _FakePasswordRecoveryNotifier extends PasswordRecoveryNotifier {
  final String? Function(String email)? onRequestCode;
  final String? Function({
    required String email,
    required String code,
    required String newPassword,
  })? onResetPassword;

  _FakePasswordRecoveryNotifier({this.onRequestCode, this.onResetPassword})
      : super(apiClient: ApiClient());

  @override
  Future<String?> requestCode(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    await Future.delayed(Duration.zero);
    final error = onRequestCode?.call(email);
    if (error != null) {
      state = state.copyWith(isLoading: false, error: error);
    } else {
      state = state.copyWith(isLoading: false, codeSent: true);
    }
    return error;
  }

  @override
  Future<String?> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    await Future.delayed(Duration.zero);
    final error = onResetPassword?.call(
      email: email,
      code: code,
      newPassword: newPassword,
    );
    if (error != null) {
      state = state.copyWith(isLoading: false, error: error);
    } else {
      state = state.copyWith(isLoading: false, resetSuccess: true);
    }
    return error;
  }
}

void main() {
  Widget buildTestable({
    String? Function(String email)? onRequestCode,
    String? Function({
      required String email,
      required String code,
      required String newPassword,
    })? onResetPassword,
  }) {
    return ProviderScope(
      overrides: [
        passwordRecoveryViewModelProvider.overrideWith((ref) =>
            _FakePasswordRecoveryNotifier(
                onRequestCode: onRequestCode,
                onResetPassword: onResetPassword)),
      ],
      child: const MaterialApp(home: RecoverPasswordPage()),
    );
  }

  group('RecoverPasswordPage widget tests — request code step', () {
    testWidgets('renders the email field and "Send Code" button',
        (tester) async {
      await tester.pumpWidget(buildTestable());

      expect(find.text('Recover Password'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Send Code'), findsOneWidget);
    });

    testWidgets('shows an error snackbar if "Send Code" is tapped with no email',
        (tester) async {
      await tester.pumpWidget(buildTestable());

      await tester.tap(find.text('Send Code'));
      await tester.pump();

      expect(
          find.text('Please enter your email address.'), findsOneWidget);
    });

    testWidgets('shows a loading indicator while the request is pending',
        (tester) async {
      await tester.pumpWidget(buildTestable(
        onRequestCode: (_) => null,
      ));

      await tester.enterText(
          find.widgetWithText(TextFormField, 'example@gmail.com'),
          'jane@example.com');
      await tester.tap(find.text('Send Code'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('advances to the code-entry step after a successful request',
        (tester) async {
      await tester.pumpWidget(buildTestable(onRequestCode: (_) => null));

      await tester.enterText(
          find.widgetWithText(TextFormField, 'example@gmail.com'),
          'jane@example.com');
      await tester.tap(find.text('Send Code'));
      await tester.pumpAndSettle();

      expect(find.text('Enter Code'), findsOneWidget);
      expect(find.text('Verification Code'), findsOneWidget);
    });

    testWidgets('shows an error message when requesting the code fails',
        (tester) async {
      await tester.pumpWidget(
          buildTestable(onRequestCode: (_) => 'No account with that email'));

      await tester.enterText(
          find.widgetWithText(TextFormField, 'example@gmail.com'),
          'unknown@example.com');
      await tester.tap(find.text('Send Code'));
      await tester.pumpAndSettle();

      expect(find.text('No account with that email'), findsOneWidget);
      expect(find.text('Recover Password'), findsOneWidget);
    });

    testWidgets('pops back to the previous page when "Back to Login" is tapped',
        (tester) async {
      await tester.pumpWidget(ProviderScope(
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const RecoverPasswordPage())),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('Recover Password'), findsOneWidget);

      await tester.tap(find.text('Back to Login'));
      await tester.pumpAndSettle();

      expect(find.text('Recover Password'), findsNothing);
      expect(find.text('open'), findsOneWidget);
    });
  });

  group('RecoverPasswordPage widget tests — reset step', () {
    Future<void> advanceToResetStep(WidgetTester tester,
        {String? Function(String)? onRequestCode}) async {
      await tester.enterText(
          find.widgetWithText(TextFormField, 'example@gmail.com'),
          'jane@example.com');
      await tester.tap(find.text('Send Code'));
      await tester.pumpAndSettle();
    }

    testWidgets('renders code and new-password fields after code is sent',
        (tester) async {
      await tester.pumpWidget(buildTestable(onRequestCode: (_) => null));
      await advanceToResetStep(tester);

      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Reset Password'), findsOneWidget);
    });

    testWidgets('shows an error snackbar when code or password is empty',
        (tester) async {
      await tester.pumpWidget(buildTestable(onRequestCode: (_) => null));
      await advanceToResetStep(tester);

      await tester.tap(find.text('Reset Password'));
      await tester.pump();

      expect(find.text('Please fill in both fields.'), findsOneWidget);
    });

    testWidgets('toggles the new-password visibility icon', (tester) async {
      await tester.pumpWidget(buildTestable(onRequestCode: (_) => null));
      await advanceToResetStep(tester);

      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });

    testWidgets('shows the success screen after a successful password reset',
        (tester) async {
      await tester.pumpWidget(buildTestable(
        onRequestCode: (_) => null,
        onResetPassword: ({required email, required code, required newPassword}) =>
            null,
      ));
      await advanceToResetStep(tester);

      await tester.enterText(
          find.widgetWithText(TextFormField, '6-digit code'), '123456');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'New password'), 'newPass123');
      await tester.tap(find.text('Reset Password'));
      await tester.pumpAndSettle();

      expect(find.text('Password Reset'), findsOneWidget);
      expect(find.text('Enter Code'), findsNothing);
    });

    testWidgets('shows an error message when the reset code is invalid',
        (tester) async {
      await tester.pumpWidget(buildTestable(
        onRequestCode: (_) => null,
        onResetPassword: ({required email, required code, required newPassword}) =>
            'Invalid or expired code',
      ));
      await advanceToResetStep(tester);

      await tester.enterText(
          find.widgetWithText(TextFormField, '6-digit code'), '000000');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'New password'), 'newPass123');
      await tester.tap(find.text('Reset Password'));
      await tester.pumpAndSettle();

      expect(find.text('Invalid or expired code'), findsOneWidget);
      expect(find.text('Enter Code'), findsOneWidget);
    });

    testWidgets('"Start over" clears the code and password fields',
        (tester) async {
      await tester.pumpWidget(buildTestable(onRequestCode: (_) => null));
      await advanceToResetStep(tester);

      await tester.enterText(
          find.widgetWithText(TextFormField, '6-digit code'), '123456');
      await tester.ensureVisible(find.text('Start over'));
      await tester.tap(find.text('Start over'));
      await tester.pumpAndSettle();

      expect(find.text('Recover Password'), findsOneWidget);
    });
  });
}
