import 'package:flutter/material.dart';
import 'package:gps_tracker/core/data/models/device_model.dart';
import 'package:gps_tracker/core/data/repositories/api_device_repository.dart';
import 'package:gps_tracker/core/providers/mqtt_provider.dart';
import 'package:gps_tracker/core/theme/app_colors.dart';
import 'package:gps_tracker/features/profile/widgets/device_card.dart';
import 'package:provider/provider.dart';

class DeviceListWidget extends StatefulWidget {
  final ApiDeviceRepository apiDeviceRepo;

  const DeviceListWidget({required this.apiDeviceRepo, super.key});

  @override
  State<DeviceListWidget> createState() => _DeviceListWidgetState();
}

class _DeviceListWidgetState extends State<DeviceListWidget> {
  late Future<List<DeviceModel>> _devicesFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _devicesFuture = widget.apiDeviceRepo.fetchDevices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final mqtt = context.watch<MqttProvider>();
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
        FutureBuilder<List<DeviceModel>>(
          future: _devicesFuture,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.accentTeal),
              );
            }
            // Offline or error: fall back to local MQTT cache.
            final devices = snap.hasError ? mqtt.devices : (snap.data ?? []);
            if (snap.hasError) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Offline — showing cached devices'),
                    backgroundColor: AppColors.errorRed,
                    duration: Duration(seconds: 2),
                  ),
                );
              });
            }
            if (devices.isEmpty) {
              return const Text(
                'No devices yet. Create one above.',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              );
            }
            return Column(
              children: devices
                  .map((d) => DeviceCard(key: ValueKey(d.id), device: d))
                  .toList(),
            );
          },
        ),
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
            onPressed: () async {
              Navigator.of(ctx).pop();
              await mqtt.createDevice(ctrl.text.trim());
              if (mounted) _refresh();
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
