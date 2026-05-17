import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gps_tracker/core/providers/connectivity_provider.dart';
import 'package:gps_tracker/core/theme/app_colors.dart';
import 'package:gps_tracker/features/main/cubit/navigation_cubit.dart';
import 'package:gps_tracker/features/profile/screens/profile_screen.dart';
import 'package:gps_tracker/features/radar/screens/radar_screen.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NavigationCubit(),
      child: const _MainNavigationContent(),
    );
  }
}

class _MainNavigationContent extends StatelessWidget {
  const _MainNavigationContent();

  @override
  Widget build(BuildContext context) {
    final isOnline = context.watch<ConnectivityProvider>().isOnline;
    const pages = [RadarScreen(), ProfileScreen()];

    return BlocBuilder<NavigationCubit, int>(
      builder: (context, selectedIndex) {
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
                    'OFFLINE MODE: LIMITED FUNCTIONALITY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Expanded(
                child: IndexedStack(index: selectedIndex, children: pages),
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: selectedIndex,
            onTap: (index) => context.read<NavigationCubit>().setTab(index),
            backgroundColor: AppColors.cardBg,
            selectedItemColor: AppColors.accentTeal,
            unselectedItemColor: Colors.white38,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.radar), label: 'Radar'),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}
