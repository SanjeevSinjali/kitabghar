import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kitabghar/core/extensions/context_extensions.dart';
import 'package:kitabghar/core/utils/snackbar_utils.dart';
import 'package:kitabghar/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:kitabghar/features/profile/presentation/view_model/profile_view_model.dart';

class SecurityPrivacyPage extends ConsumerStatefulWidget {
  const SecurityPrivacyPage({super.key});

  @override
  ConsumerState<SecurityPrivacyPage> createState() =>
      _SecurityPrivacyPageState();
}

class _SecurityPrivacyPageState extends ConsumerState<SecurityPrivacyPage> {
  final _currentPasswordController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;

  String? get _token => ref.read(authViewModelProvider).user?.token;

  @override
  void initState() {
    super.initState();
    // Make sure we always start on a clean slate when this page opens.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileViewModelProvider.notifier).resetPasswordChangeFlow();
    });
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final token = _token;
    if (token == null) return;
    final password = _currentPasswordController.text;
    if (password.isEmpty) {
      SnackbarUtils.showError(context, 'Please enter your current password.');
      return;
    }

    final error = await ref
        .read(profileViewModelProvider.notifier)
        .requestPasswordChange(token: token, currentPassword: password);

    if (!mounted) return;
    if (error != null) {
      SnackbarUtils.showError(context, 'Password incorrect.');
    }
  }

  Future<void> _confirmChange() async {
    final token = _token;
    if (token == null) return;
    final code = _codeController.text.trim();
    final newPassword = _newPasswordController.text;

    if (code.isEmpty || newPassword.isEmpty) {
      SnackbarUtils.showError(context, 'Please fill in both fields.');
      return;
    }

    final error = await ref.read(profileViewModelProvider.notifier).confirmPasswordChange(
          token: token,
          code: code,
          newPassword: newPassword,
        );

    if (!mounted) return;
    if (error != null) {
      SnackbarUtils.showError(context, error);
    }
  }

  void _startOver() {
    _currentPasswordController.clear();
    _codeController.clear();
    _newPasswordController.clear();
    ref.read(profileViewModelProvider.notifier).resetPasswordChangeFlow();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileViewModelProvider);

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(title: const Text('Security & Privacy')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Icon(Icons.lock_outline_rounded, color: context.textPrimary),
              const SizedBox(width: 10),
              Text(
                'Change Password',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: state.passwordChangeSuccess
                ? _buildSuccessState(context)
                : (!state.codeSent
                    ? _buildRequestCodeStep(context, state)
                    : _buildConfirmStep(context, state)),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF2ECC71).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded, color: Color(0xFF2ECC71), size: 28),
        ),
        const SizedBox(height: 16),
        Text(
          'Password updated',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: context.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your password has been changed successfully.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: context.textSecondary),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _startOver,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Change it again',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          ),
        ),
      ],
    );
  }

  Widget _buildRequestCodeStep(BuildContext context, dynamic state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter your current password to receive a verification code by email.',
          style: TextStyle(fontSize: 13, color: context.textSecondary),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _currentPasswordController,
          obscureText: _obscureCurrent,
          style: TextStyle(color: context.textPrimary),
          decoration: InputDecoration(
            hintText: 'Current password',
            prefixIcon: Icon(Icons.lock_outline_rounded, color: context.textTertiary),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureCurrent
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: context.textTertiary,
              ),
              onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: state.isChangingPassword ? null : _sendCode,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: state.isChangingPassword
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : const Text('Send Code',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmStep(BuildContext context, dynamic state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'We sent a 6-digit code to your email. Enter it below along with your new password.',
          style: TextStyle(fontSize: 13, color: context.textSecondary),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _codeController,
          keyboardType: TextInputType.number,
          style: TextStyle(color: context.textPrimary),
          decoration: InputDecoration(
            hintText: '6-digit code',
            prefixIcon: Icon(Icons.pin_outlined, color: context.textTertiary),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _newPasswordController,
          obscureText: _obscureNew,
          style: TextStyle(color: context.textPrimary),
          decoration: InputDecoration(
            hintText: 'New password',
            prefixIcon: Icon(Icons.lock_outline_rounded, color: context.textTertiary),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: context.textTertiary,
              ),
              onPressed: () => setState(() => _obscureNew = !_obscureNew),
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: state.isChangingPassword ? null : _confirmChange,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: state.isChangingPassword
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : const Text('Confirm',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: _startOver,
            child: Text('Start over',
                style: TextStyle(color: context.textSecondary, fontSize: 13)),
          ),
        ),
      ],
    );
  }
}