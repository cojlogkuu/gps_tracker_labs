import 'package:flutter/material.dart';
import 'package:gps_tracker/core/theme/app_colors.dart';

class ProfileHeader extends StatelessWidget {
  final String name;

  const ProfileHeader({required this.name, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.accentTeal.withValues(alpha: 0.6),
              width: 2,
            ),
          ),
          child: const Icon(
            Icons.person,
            color: AppColors.accentTeal,
            size: 36,
          ),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
