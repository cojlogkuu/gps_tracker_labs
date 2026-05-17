import 'package:flutter/material.dart';
import 'package:gps_tracker/core/data/repositories/api_device_repository.dart';
import 'package:gps_tracker/core/providers/auth_provider.dart';
import 'package:gps_tracker/core/providers/connectivity_provider.dart';
import 'package:gps_tracker/core/theme/app_colors.dart';
import 'package:gps_tracker/features/auth/screens/login_screen.dart';
import 'package:gps_tracker/features/main/screens/main_navigation_screen.dart';
import 'package:provider/provider.dart';

/// Declarative startup router.
///
/// Runs [AuthProvider.tryAutoLogin] exactly once (in [initState], safely via
/// [context.read]).  While the future is pending it shows [_SplashView].
/// Once resolved it reads auth state with [context.watch] and returns the
/// correct widget directly — no [Navigator] calls during build, which
/// eliminates the "_dependents.isEmpty" crash on Flutter Web reload.
class AppRouter extends StatefulWidget {
  final ApiDeviceRepository apiDeviceRepo;

  const AppRouter({required this.apiDeviceRepo, super.key});

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  late final Future<void> _autoLoginFuture;

  @override
  void initState() {
    super.initState();
    // read (listen: false) is safe inside initState.
    _autoLoginFuture = context.read<AuthProvider>().tryAutoLogin();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _autoLoginFuture,
      builder: (context, snapshot) {
        // Still resolving — show the splash visual.
        if (snapshot.connectionState != ConnectionState.done) {
          return const _SplashView();
        }

        // CRITICAL: purely declarative — return widgets, never call Navigator.
        final isAuth = context.watch<AuthProvider>().isAuthenticated;
        if (isAuth) {
          return MainNavigationScreen(apiDeviceRepo: widget.apiDeviceRepo);
        }
        return const LoginScreen();
      },
    );
  }
}

/// Pure visual splash — no async logic, no navigation.
class _SplashView extends StatelessWidget {
  const _SplashView();

  @override
  Widget build(BuildContext context) {
    final isOnline = context.watch<ConnectivityProvider>().isOnline;
    return Scaffold(
      body: Column(
        children: [
          if (!isOnline)
            Container(
              width: double.infinity,
              color: AppColors.errorRed,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
                bottom: 8,
              ),
              alignment: Alignment.center,
              child: const Text(
                'NO INTERNET CONNECTION',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const Expanded(
            child: Center(
              child: Icon(Icons.radar, size: 80, color: AppColors.accentTeal),
            ),
          ),
        ],
      ),
    );
  }
}
