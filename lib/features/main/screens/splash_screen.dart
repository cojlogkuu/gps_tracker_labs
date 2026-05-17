import 'package:flutter/material.dart';
import 'package:gps_tracker/core/providers/connectivity_provider.dart';
import 'package:gps_tracker/core/theme/app_colors.dart';
import 'package:gps_tracker/features/auth/cubit/auth_cubit.dart';
import 'package:gps_tracker/features/auth/cubit/auth_state.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    final auth = context.read<AuthCubit>();
    await auth.tryAutoLogin();

    if (!mounted) return;
    if (auth.state is AuthAuthenticated) {
      final isOnline = context.read<ConnectivityProvider>().isOnline;
      if (!isOnline) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            const SnackBar(
              content: Text(
                'Offline Mode: Limited Functionality',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor: AppColors.errorRed,
            ),
          );
      }
      Navigator.of(context).pushReplacementNamed('/main');
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

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
