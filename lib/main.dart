import 'package:flutter/material.dart';
import 'package:gps_tracker/core/data/repositories/api_auth_repository.dart';
import 'package:gps_tracker/core/data/repositories/api_device_repository.dart';
import 'package:gps_tracker/core/data/repositories/auth_repository.dart';
import 'package:gps_tracker/core/data/repositories/device_repository.dart';
import 'package:gps_tracker/core/data/repositories/location_repository.dart';
import 'package:gps_tracker/core/providers/auth_provider.dart';
import 'package:gps_tracker/core/providers/connectivity_provider.dart';
import 'package:gps_tracker/core/providers/mqtt_provider.dart';
import 'package:gps_tracker/core/theme/app_colors.dart';
import 'package:gps_tracker/features/auth/screens/login_screen.dart';
import 'package:gps_tracker/features/auth/screens/register_screen.dart';
import 'package:gps_tracker/features/main/screens/app_router.dart';
import 'package:gps_tracker/features/main/screens/main_navigation_screen.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Repositories ────────────────────────────────────────────────────────
  final localAuthRepo = SharedPrefsAuthRepository();
  final apiAuthRepo = ApiAuthRepository(cache: localAuthRepo);

  final localDeviceRepo = SharedPrefsDeviceRepository();
  final apiDeviceRepo = ApiDeviceRepository(cache: localDeviceRepo);

  final locationRepo = ApiLocationRepository();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(cache: localAuthRepo, api: apiAuthRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => MqttProvider(
            localRepo: localDeviceRepo,
            apiRepo: apiDeviceRepo,
            locationRepo: locationRepo,
          ),
        ),
      ],
      child: GpsTrackerApp(apiDeviceRepo: apiDeviceRepo),
    ),
  );
}

class GpsTrackerApp extends StatelessWidget {
  final ApiDeviceRepository apiDeviceRepo;

  const GpsTrackerApp({required this.apiDeviceRepo, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.primaryBg,
      ),
      // AppRouter handles initial auth check declaratively.
      // Named routes are used only for user-initiated navigation.
      home: AppRouter(apiDeviceRepo: apiDeviceRepo),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/home': (_) => MainNavigationScreen(apiDeviceRepo: apiDeviceRepo),
        '/main': (_) => MainNavigationScreen(apiDeviceRepo: apiDeviceRepo),
      },
    );
  }
}
