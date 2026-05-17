import 'package:flutter/material.dart';
import 'package:gps_tracker/core/theme/app_colors.dart';

Future<String?> showEditNameDialog(BuildContext context, String currentName) {
  final ctrl = TextEditingController(text: currentName);
  return showDialog<String>(
    context: context,
    builder: (ctx) => _EditNameDialog(ctrl: ctrl),
  );
}

class _EditNameDialog extends StatelessWidget {
  final TextEditingController ctrl;
  const _EditNameDialog({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardBg,
      title: const Text('Edit Name', style: TextStyle(color: Colors.white)),
      content: TextField(
        controller: ctrl,
        autofocus: true,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          labelText: 'Full Name',
          labelStyle: TextStyle(color: AppColors.accentTeal),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.accentTeal),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.accentTeal, width: 2),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(ctrl.text.trim()),
          child: const Text(
            'Save',
            style: TextStyle(color: AppColors.accentTeal),
          ),
        ),
      ],
    );
  }
}
