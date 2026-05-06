import 'package:flutter/material.dart';
import 'package:gps_tracker/core/theme/app_colors.dart';
import 'package:gps_tracker/features/auth/screens/login_screen.dart';
import 'package:gps_tracker/features/auth/screens/register_screen.dart';
import 'package:gps_tracker/features/main/screens/main_navigation_screen.dart';

void main() => runApp(const GpsTrackerApp());

class GpsTrackerApp extends StatelessWidget {
  const GpsTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.primaryBg,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/home': (_) => const MainNavigationScreen(),
        '/main': (_) => const MainNavigationScreen(),
      },
    );
  }
}
