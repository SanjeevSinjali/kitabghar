import 'package:flutter/material.dart';
import 'package:kitabghar/features/auth/presentation/pages/signup_page.dart';
import 'package:kitabghar/features/dashboard/presentation/pages/dashboard_page.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()));
    }
  }

  void _goToSignup() {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => const SignupView()));
  }

  InputDecoration _fieldDecoration(String hint, IconData icon) =>
      InputDecoration(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D3A52),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Center(
              child: Image.asset('assets/images/logo.png',
                  width: 350, height: 480, fit: BoxFit.contain),
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(width: double.infinity),
                          Text('Welcome back',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text('Start your reading adventure',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14, color: Colors.black45)),
                        ],
                      ),
                      const SizedBox(height: 28),

                      const Text('Email', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _fieldDecoration('example@gmail.com', Icons.mail_outline),
                        validator: (v) => v!.trim().isEmpty ? 'Please enter email' : null,
                      ),
                      const SizedBox(height: 16),

                      const Text('Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: _obscure,
                        decoration: _fieldDecoration('password', Icons.lock_outline).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: Colors.black45),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                        validator: (v) => v!.isEmpty ? 'Please enter password' : null,
                      ),
                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            Checkbox(
                              value: _rememberMe,
                              shape: const CircleBorder(),
                              onChanged: (v) => setState(() => _rememberMe = v ?? false),
                            ),
                            const Text('Remember me', style: TextStyle(fontSize: 13, color: Colors.black54)),
                          ]),
                          TextButton(
                            onPressed: () {},
                            child: const Text('Forgot Password ?',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _login,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white, // white background
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Colors.black26),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Login',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
                        ),
                      ),
                      const SizedBox(height: 24),

                      Row(children: [
                        const Expanded(child: Divider(color: Colors.black26)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('Or login with', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                        ),
                        const Expanded(child: Divider(color: Colors.black26)),
                      ]),
                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _gmailButton(),
                          const SizedBox(width: 16),
                          _socialButton(Icons.apple, Colors.black),
                          const SizedBox(width: 16),
                          _socialButton(Icons.facebook, const Color(0xFF1877F2)),
                        ],
                      ),
                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account? ",
                              style: TextStyle(fontSize: 14, color: Colors.black54)),
                          GestureDetector(
                            onTap: _goToSignup,
                            child: const Text('Sign up',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
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

  Widget _gmailButton() => Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: Colors.black12),
        ),
        child: const Center(
          child: Text('G',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFEA4335))),
        ),
      );

  Widget _socialButton(IconData icon, Color color) => Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        child: Icon(icon, color: Colors.white, size: 26),
      );
}