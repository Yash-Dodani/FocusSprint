import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/notification_service.dart';
import 'core/theme/app_theme.dart';

import 'data/repositories/sprint_repository.dart';
import 'providers/sprint_provider.dart';
import 'providers/theme_provider.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/home/home_screen.dart';
import 'services/permission_service.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();
  await PermissionService.ensureNotificationPermission();
  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('seen_onboarding') ?? false;

  runApp(FocusSprintApp(hasSeenOnboarding: hasSeenOnboarding));
}

class FocusSprintApp extends StatelessWidget {
  final bool hasSeenOnboarding;

  const FocusSprintApp({super.key, required this.hasSeenOnboarding});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SprintProvider(SprintRepository()),
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, theme, _) {
          return MaterialApp(
            title: 'FocusSprint',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: theme.mode,
            home: hasSeenOnboarding
                ? const HomeScreen()
                : const OnboardingScreen(),
          );
        },
      ),
    );
  }
}
