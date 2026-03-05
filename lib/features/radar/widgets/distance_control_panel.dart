import 'package:flutter/material.dart';
import 'package:gps_tracker/core/theme/app_colors.dart';

class DistanceControlPanel extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String) onSubmitted;
  final double currentRadius;
  final bool isDestroyed;

  const DistanceControlPanel({
    required this.controller,
    required this.onSubmitted,
    required this.currentRadius,
    required this.isDestroyed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isDestroyed
                ? 'UNKNOWN'
                : 'Current Radius: '
                      '${currentRadius.toStringAsFixed(1)} m',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: controller,
            onSubmitted: onSubmitted,
            decoration: const InputDecoration(
              labelText: 'Add distance',
              prefixIcon: Icon(Icons.radar, color: AppColors.accentTeal),
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
