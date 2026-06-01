import 'package:flutter/material.dart';
import 'package:kitabghar/features/splash/presentation/pages/splashscreen.dart';


class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
      home: SplashView(),
    );
  }
} 