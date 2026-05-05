import 'package:flutter/material.dart';
import 'package:gps_tracker/core/theme/app_colors.dart';

class ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const ProfileInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accentTeal, size: 18),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.4),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileInfoCard extends StatelessWidget {
  final List<ProfileInfoRow> items;

  const ProfileInfoCard({required this.items, super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.accentTeal.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            items[i],
            if (i < items.length - 1)
              Divider(
                height: 1,
                color: AppColors.accentTeal.withValues(alpha: 0.1),
                indent: 52,
              ),
          ],
        ],
      ),
    );
  }
}
