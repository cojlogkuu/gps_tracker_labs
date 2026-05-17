import 'package:flutter/material.dart';
import 'package:gps_tracker/core/theme/app_colors.dart';

Future<bool> showDeleteAccountDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => const _DeleteAccountDialog(),
  );
  return result ?? false;
}

class _DeleteAccountDialog extends StatelessWidget {
  const _DeleteAccountDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardBg,
      title: const Text(
        'Delete Account',
        style: TextStyle(color: Colors.white),
      ),
      content: const Text(
        'Are you sure? This action cannot be undone.',
        style: TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text(
            'Delete',
            style: TextStyle(color: AppColors.errorRed),
          ),
        ),
      ],
    );
  }
}
