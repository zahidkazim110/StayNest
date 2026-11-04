import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'screens/welcome/welcome_screen.dart';

class StayNestApp extends StatelessWidget {
  const StayNestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StayNest',
      theme: AppTheme.lightTheme,
      home: const WelcomeScreen(),
    );
  }
}
