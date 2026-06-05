import 'package:flutter/material.dart';
import 'package:kitabghar/features/auth/presentation/pages/login_page.dart';
import 'package:kitabghar/features/auth/presentation/pages/signup_page.dart';
import 'package:kitabghar/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:kitabghar/features/splash/presentation/pages/splashscreen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
      home: const SplashView(),
      routes: {
        '/login': (_) => const LoginPage(),
        '/signup': (_) => const SignupPage(),
        '/dashboard': (_) => const DashboardPage(),
      },
    );
  }
}