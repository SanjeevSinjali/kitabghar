import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kitabghar/app/theme/app_theme.dart';
import 'package:kitabghar/core/providers/theme_provider.dart';
import 'package:kitabghar/features/auth/presentation/pages/login_page.dart';
import 'package:kitabghar/features/auth/presentation/pages/signup_page.dart';
import 'package:kitabghar/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:kitabghar/features/splash/presentation/pages/splashscreen.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: const SplashView(),
      routes: {
        '/login': (_) => const LoginPage(),
        '/signup': (_) => const SignupPage(),
        '/dashboard': (_) => const DashboardPage(),
      },
    );
  }
}