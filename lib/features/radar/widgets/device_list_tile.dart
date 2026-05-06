import 'package:flutter/material.dart';
import 'package:gps_tracker/core/data/models/device_model.dart';
import 'package:gps_tracker/core/theme/app_colors.dart';

class DeviceListTile extends StatelessWidget {
  final DeviceModel device;

  const DeviceListTile({required this.device, super.key});

  @override
  Widget build(BuildContext context) {
    final last =
        device.coordinates.isNotEmpty ? device.coordinates.last : null;
    final distText = last == null
        ? '—'
        : last.distance >= 1000
            ? '${(last.distance / 1000).toStringAsFixed(2)} km'
            : '${last.distance.toStringAsFixed(0)} m';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.accentTeal.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.device_hub, color: AppColors.accentTeal, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (last != null)
                  Text(
                    'Ping: ${last.latitude.toStringAsFixed(4)}, '
                    '${last.longitude.toStringAsFixed(4)}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            distText,
            style: const TextStyle(
              color: AppColors.accentTeal,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
