import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kitabghar/core/utils/snackbar_utils.dart';
import 'package:kitabghar/features/auth/presentation/state/password_recovery_state.dart';
import 'package:kitabghar/features/auth/presentation/view_model/password_recovery_view_model.dart';

class RecoverPasswordPage extends ConsumerStatefulWidget {
  const RecoverPasswordPage({super.key});

  @override
  ConsumerState<RecoverPasswordPage> createState() => _RecoverPasswordPageState();
}

class _RecoverPasswordPageState extends ConsumerState<RecoverPasswordPage> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(String hint, IconData icon) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black26),
        prefixIcon: Icon(icon, color: Colors.black45),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      );

  Future<void> _sendCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      SnackbarUtils.showError(context, 'Please enter your email address.');
      return;
    }
    final error = await ref.read(passwordRecoveryViewModelProvider.notifier).requestCode(email);
    if (!mounted) return;
    if (error != null) {
      SnackbarUtils.showError(context, error);
    }
  }

  Future<void> _resetPassword() async {
    final code = _codeController.text.trim();
    final newPassword = _newPasswordController.text;
    if (code.isEmpty || newPassword.isEmpty) {
      SnackbarUtils.showError(context, 'Please fill in both fields.');
      return;
    }
    final error = await ref.read(passwordRecoveryViewModelProvider.notifier).resetPassword(
          email: _emailController.text.trim(),
          code: code,
          newPassword: newPassword,
        );
    if (!mounted) return;
    if (error != null) {
      SnackbarUtils.showError(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(passwordRecoveryViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF1D3A52),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Center(
              child: Icon(Icons.lock_reset_rounded, color: Colors.white.withValues(alpha: 0.9), size: 100),
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF5F0E8),
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                child: state.resetSuccess
                    ? _buildSuccessState(context)
                    : (!state.codeSent ? _buildRequestCodeStep(state) : _buildResetStep(state)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCodeStep(PasswordRecoveryState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recover Password',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text(
          'Enter your email address and we\'ll send you a code to reset your password.',
          style: TextStyle(fontSize: 14, color: Colors.black45),
        ),
        const SizedBox(height: 28),
        const Text('Email', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: _fieldDecoration('example@gmail.com', Icons.mail_outline),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: state.isLoading ? null : _sendCode,
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Colors.black26),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: state.isLoading
                ? const SizedBox(
                    height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Send Code',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Text('Back to Login',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
          ),
        ),
      ],
    );
  }

  Widget _buildResetStep(PasswordRecoveryState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Enter Code', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(
          'We sent a 6-digit code to ${_emailController.text.trim()}. Enter it below along with your new password.',
          style: const TextStyle(fontSize: 14, color: Colors.black45),
        ),
        const SizedBox(height: 28),
        const Text('Verification Code', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _codeController,
          keyboardType: TextInputType.number,
          decoration: _fieldDecoration('6-digit code', Icons.pin_outlined),
        ),
        const SizedBox(height: 16),
        const Text('New Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _newPasswordController,
          obscureText: _obscure,
          decoration: _fieldDecoration('New password', Icons.lock_outline).copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: Colors.black45,
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: state.isLoading ? null : _resetPassword,
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Colors.black26),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: state.isLoading
                ? const SizedBox(
                    height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Reset Password',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: () {
              ref.read(passwordRecoveryViewModelProvider.notifier).reset();
              _codeController.clear();
              _newPasswordController.clear();
            },
            child: const Text('Start over', style: TextStyle(fontSize: 13, color: Colors.black54)),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessState(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFF2ECC71).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded, color: Color(0xFF2ECC71), size: 32),
        ),
        const SizedBox(height: 20),
        const Text('Password Reset', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text(
          'Your password has been reset successfully. You can now log in with your new password.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.black45),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Colors.black26),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Back to Login',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
          ),
        ),
      ],
    );
  }
}