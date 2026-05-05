import 'package:flutter/material.dart';
import 'package:gps_tracker/core/theme/app_colors.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: AppColors.accentTeal.withValues(alpha: 0.5),
            ),
          ),
          child: const Icon(
            Icons.gps_fixed,
            color: AppColors.accentTeal,
            size: 24,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'GPS TRACKER',
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 3,
            color: AppColors.accentTeal,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Sign In',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}
