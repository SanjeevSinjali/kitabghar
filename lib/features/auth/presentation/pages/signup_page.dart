import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kitabghar/features/auth/domain/entities/auth_entity.dart';
import 'package:kitabghar/features/auth/presentation/view_model/auth_view_model.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  bool _obscure = true;
  bool _agree = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  void _signup() {
    if (_formKey.currentState?.validate() ?? false) {
      if (!_agree) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please agree to the terms and privacy.')),
        );
        return;
      }
      ref.read(authViewModelProvider.notifier).register(
            AuthEntity(
              name: _nameCtrl.text.trim(),
              email: _emailCtrl.text.trim(),
              password: _passwordCtrl.text.trim(),
              phone: _phoneCtrl.text.trim(),
              address: _addressCtrl.text.trim(),
            ),
          );
    }
  }

  InputDecoration _fieldDecoration(String hint, IconData icon,
          {Widget? suffix}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black26, fontSize: 13),
        prefixIcon: Icon(icon, color: Colors.black45, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        visualDensity: VisualDensity.compact,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      );

  Widget _socialButton(IconData icon, Color color) => Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(color: Colors.black12),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      );

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    ref.listen(authViewModelProvider, (previous, next) {
      if (next.isSuccess && next.user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully!')),
        );
        Navigator.pop(context);
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
        ref.read(authViewModelProvider.notifier).resetState();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF1D3A52),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Center(
              child: Image.asset(
                'assets/images/logo.png',
                width: 240,
                height: 180,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF5F0E8),
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Column(
                          children: [
                            Text('Register',
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(height: 2),
                            Text('Join the world of readers',
                                style: TextStyle(
                                    fontSize: 13, color: Colors.black45)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text('Full Name',
                          style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: _fieldDecoration(
                            'Example Bahadur', Icons.person_outline),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Please enter full name'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      const Text('Email',
                          style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _fieldDecoration(
                            'example@gmail.com', Icons.mail_outline),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Please enter email'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      const Text('Phone Number',
                          style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: _fieldDecoration(
                            '98XXXXXXXX', Icons.phone_outlined),
                        validator: (v) => (v == null || v.length < 7)
                            ? 'Enter a valid phone number'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      const Text('Address',
                          style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _addressCtrl,
                        decoration: _fieldDecoration(
                            'Kathmandu, Nepal',
                            Icons.location_on_outlined),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Please enter address'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      const Text('Password',
                          style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: _obscure,
                        decoration: _fieldDecoration(
                          'password',
                          Icons.lock_outline,
                          suffix: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.black45,
                              size: 20,
                            ),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                        ),
                        validator: (v) => (v == null || v.length < 6)
                            ? 'Password must be 6+ characters'
                            : null,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Transform.scale(
                            scale: 0.9,
                            child: Checkbox(
                              value: _agree,
                              shape: const CircleBorder(),
                              onChanged: (v) =>
                                  setState(() => _agree = v ?? false),
                            ),
                          ),
                          const Expanded(
                            child: Text(
                              'I agree to the Term & Condition and Privacy',
                              style: TextStyle(
                                  fontSize: 11.5, color: Colors.black54),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: authState.isLoading ? null : _signup,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            side: const BorderSide(color: Colors.black26),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: authState.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                )
                              : const Text(
                                  'Sign up',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Expanded(
                              child: Divider(color: Colors.black26)),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10),
                            child: Text('Or Sign up with',
                                style: TextStyle(
                                    fontSize: 12.5,
                                    color: Colors.grey.shade500)),
                          ),
                          const Expanded(
                              child: Divider(color: Colors.black26)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _socialButton(Icons.g_mobiledata, Colors.red),
                          const SizedBox(width: 14),
                          _socialButton(Icons.apple, Colors.black),
                          const SizedBox(width: 14),
                          _socialButton(
                              Icons.facebook, const Color(0xFF1877F2)),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Already have an account? ',
                              style: TextStyle(
                                  fontSize: 13.5, color: Colors.black54)),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Text('Sign in',
                                style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}