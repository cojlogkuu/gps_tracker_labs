import 'package:flutter/material.dart';
import 'package:gps_tracker/core/theme/app_colors.dart';

class PingDialogField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isNumeric;

  const PingDialogField({
    required this.controller,
    required this.label,
    required this.icon,
    this.isNumeric = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: isNumeric
          ? const TextInputType.numberWithOptions(decimal: true, signed: true)
          : TextInputType.text,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.accentTeal, fontSize: 11),
        prefixIcon: Icon(icon, color: AppColors.accentTeal, size: 17),
        filled: true,
        fillColor: AppColors.primaryBg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
      ),
    );
  }
}

class DeviceDropdown extends StatelessWidget {
  static const newKey = '__new__';

  final List<String> deviceIds;
  final List<String> deviceNames;
  final String? value;
  final void Function(String?) onChanged;

  const DeviceDropdown({
    required this.deviceIds,
    required this.deviceNames,
    required this.onChanged,
    this.value,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      dropdownColor: AppColors.cardBg,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        labelText: 'Device',
        labelStyle: const TextStyle(color: AppColors.accentTeal, fontSize: 11),
        prefixIcon: const Icon(
          Icons.device_hub,
          color: AppColors.accentTeal,
          size: 17,
        ),
        filled: true,
        fillColor: AppColors.primaryBg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
      ),
      items: [
        for (int i = 0; i < deviceIds.length; i++)
          DropdownMenuItem(value: deviceIds[i], child: Text(deviceNames[i])),
        const DropdownMenuItem(value: newKey, child: Text('＋ New Device')),
      ],
      onChanged: onChanged,
    );
  }
}
