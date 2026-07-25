import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kitabghar/app.dart';
import 'package:kitabghar/core/providers/notification_provider.dart';
import 'package:kitabghar/core/providers/theme_provider.dart';
import 'package:kitabghar/core/services/hive/hive_service.dart';
import 'package:kitabghar/core/services/notifications/notification_service.dart';
import 'package:kitabghar/core/services/theme/theme_service.dart';
import 'package:kitabghar/features/auth/presentation/view_model/auth_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final hiveService = HiveService();
  await hiveService.init();

  final themeService = ThemeService();
  await themeService.init();

  final notificationService = NotificationService();
  await notificationService.init();

  runApp(
    ProviderScope(
      overrides: [
        hiveServiceProvider.overrideWithValue(hiveService),
        themeServiceProvider.overrideWithValue(themeService),
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: const App(),
    ),
  );
}