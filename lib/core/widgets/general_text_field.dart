import 'package:flutter/material.dart';
import 'package:gps_tracker/core/theme/app_colors.dart';

class GeneralTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;

  const GeneralTextField({
    required this.controller,
    required this.label,
    this.prefixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.textInputAction = TextInputAction.next,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: AppColors.accentTeal,
          fontSize: 13,
          letterSpacing: 1.2,
        ),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppColors.accentTeal, size: 20)
            : null,
        filled: true,
        fillColor: AppColors.primaryBg,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(
            color: AppColors.accentTeal.withValues(alpha: 0.35),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.accentTeal, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.errorRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.errorRed, width: 1.5),
        ),
        errorStyle: const TextStyle(color: AppColors.errorRed, fontSize: 11),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
