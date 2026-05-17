import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gps_tracker/core/data/models/device_model.dart';
import 'package:gps_tracker/core/providers/mqtt_provider.dart';
import 'package:gps_tracker/core/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DeviceCard extends StatelessWidget {
  final DeviceModel device;

  const DeviceCard({required this.device, super.key});

  String _formatCoord(double? lat, double? lng) {
    if (lat == null || lng == null) return 'No location yet';
    return '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
  }

  String _formatTime(DateTime? ts) {
    if (ts == null) return '';
    return DateFormat('dd MMM, HH:mm:ss').format(ts.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final mqtt = context.read<MqttProvider>();
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.accentTeal.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          const Icon(Icons.device_hub, color: AppColors.accentTeal, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                SelectableText(
                  device.id,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatCoord(device.latestLatitude, device.latestLongitude),
                  style: const TextStyle(
                    color: AppColors.accentTeal,
                    fontSize: 11,
                  ),
                ),
                if (device.latestTimestamp != null)
                  Text(
                    _formatTime(device.latestTimestamp),
                    style: const TextStyle(color: Colors.white38, fontSize: 10),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, color: AppColors.accentTeal, size: 18),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: device.id));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Device ID copied'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: AppColors.errorRed,
              size: 20,
            ),
            onPressed: () => mqtt.deleteDevice(device.id),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
