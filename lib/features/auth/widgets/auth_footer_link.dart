import 'package:flutter/material.dart';
import 'package:gps_tracker/core/theme/app_colors.dart';

class AuthFooterLink extends StatelessWidget {
  final String question;
  final String actionLabel;
  final VoidCallback onTap;

  const AuthFooterLink({
    required this.question,
    required this.actionLabel,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          question,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 13,
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            actionLabel,
            style: const TextStyle(
              color: AppColors.accentTeal,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
