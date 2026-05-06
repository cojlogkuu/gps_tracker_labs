import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gps_tracker/core/providers/mqtt_provider.dart';
import 'package:gps_tracker/core/theme/app_colors.dart';
import 'package:provider/provider.dart';

class DeviceListWidget extends StatelessWidget {
  const DeviceListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final mqtt = context.watch<MqttProvider>();
    final devices = mqtt.devices;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentTeal,
            foregroundColor: AppColors.primaryBg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: const Icon(Icons.add),
          label: const Text('CREATE NEW DEVICE'),
          onPressed: () => _showCreateDialog(context, mqtt),
        ),
        const SizedBox(height: 16),
        if (devices.isEmpty)
          const Text(
            'No devices saved yet.',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          )
        else
          ...devices.map((d) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.accentTeal.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.device_hub,
                    color: AppColors.accentTeal,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          d.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        SelectableText(
                          d.id,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 10,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.copy,
                      color: AppColors.accentTeal,
                      size: 18,
                    ),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: d.id));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Device ID copied to clipboard'),
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
                    onPressed: () => mqtt.deleteDevice(d.id),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  void _showCreateDialog(BuildContext context, MqttProvider mqtt) {
    final ctrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        title: const Text(
          'Create Device',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: ctrl,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Device Name',
            labelStyle: TextStyle(color: AppColors.accentTeal),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.accentTeal),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              mqtt.createDevice(ctrl.text.trim());
              Navigator.of(ctx).pop();
            },
            child: const Text(
              'Create',
              style: TextStyle(color: AppColors.accentTeal),
            ),
          ),
        ],
      ),
    );
  }
}
