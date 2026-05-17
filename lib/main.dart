import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gps_tracker/core/data/repositories/api_auth_repository.dart';
import 'package:gps_tracker/core/data/repositories/api_device_repository.dart';
import 'package:gps_tracker/core/data/repositories/auth_repository.dart';
import 'package:gps_tracker/core/data/repositories/device_repository.dart';
import 'package:gps_tracker/core/data/repositories/location_repository.dart';
import 'package:gps_tracker/core/providers/connectivity_provider.dart';
import 'package:gps_tracker/core/providers/mqtt_provider.dart';
import 'package:gps_tracker/core/theme/app_colors.dart';
import 'package:gps_tracker/features/auth/cubit/auth_cubit.dart';
import 'package:gps_tracker/features/auth/screens/login_screen.dart';
import 'package:gps_tracker/features/auth/screens/register_screen.dart';
import 'package:gps_tracker/features/device/cubit/device_cubit.dart';
import 'package:gps_tracker/features/main/screens/app_router.dart';
import 'package:gps_tracker/features/main/screens/main_navigation_screen.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Repositories (Singleton Instances) ──────────────────────────────────
  final localAuthRepo = SharedPrefsAuthRepository();
  final apiAuthRepo = ApiAuthRepository(cache: localAuthRepo);

  final localDeviceRepo = SharedPrefsDeviceRepository();
  final apiDeviceRepo = ApiDeviceRepository(cache: localDeviceRepo);

  final locationRepo = ApiLocationRepository();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ApiAuthRepository>.value(value: apiAuthRepo),
        RepositoryProvider<ApiDeviceRepository>.value(value: apiDeviceRepo),
        RepositoryProvider<ApiLocationRepository>.value(value: locationRepo),
        RepositoryProvider<IAuthRepository>.value(value: localAuthRepo),
        RepositoryProvider<IDeviceRepository>.value(value: localDeviceRepo),
      ],
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
          ChangeNotifierProvider(
            create: (_) => MqttProvider(
              localRepo: localDeviceRepo,
              apiRepo: apiDeviceRepo,
              locationRepo: locationRepo,
            ),
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>(
              create: (context) => AuthCubit(
                api: context.read<ApiAuthRepository>(),
                cache: context.read<IAuthRepository>(),
              )..tryAutoLogin(),
            ),
            BlocProvider<DeviceCubit>(
              create: (context) => DeviceCubit(
                api: context.read<ApiDeviceRepository>(),
                cache: context.read<IDeviceRepository>(),
              ),
            ),
          ],
          child: const GpsTrackerApp(),
        ),
      ),
    ),
  );
}

class GpsTrackerApp extends StatelessWidget {
  const GpsTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.primaryBg,
      ),
      home: const AppRouter(),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/home': (_) => const MainNavigationScreen(),
        '/main': (_) => const MainNavigationScreen(),
      },
    );
  }
}
