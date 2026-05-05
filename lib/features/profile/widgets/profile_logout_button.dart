import 'package:flutter/material.dart';
import 'package:gps_tracker/core/theme/app_colors.dart';

class ProfileLogoutButton extends StatelessWidget {
  final VoidCallback onLogout;

  const ProfileLogoutButton({required this.onLogout, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: onLogout,
        icon: const Icon(Icons.logout, size: 18, color: AppColors.errorRed),
        label: const Text(
          'SIGN OUT',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: AppColors.errorRed,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.errorRed.withValues(alpha: 0.5)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }
}
