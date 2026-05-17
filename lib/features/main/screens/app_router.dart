import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gps_tracker/core/providers/connectivity_provider.dart';
import 'package:gps_tracker/core/theme/app_colors.dart';
import 'package:gps_tracker/features/auth/cubit/auth_cubit.dart';
import 'package:gps_tracker/features/auth/cubit/auth_state.dart';
import 'package:gps_tracker/features/auth/screens/login_screen.dart';
import 'package:gps_tracker/features/main/screens/main_navigation_screen.dart';

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthInitial || state is AuthLoading) {
          return const _SplashView();
        }

        if (state is AuthAuthenticated) {
          return const MainNavigationScreen();
        }

        return const LoginScreen();
      },
    );
  }
}

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
