import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gps_tracker/core/providers/mqtt_provider.dart';
import 'package:gps_tracker/core/theme/app_colors.dart';
import 'package:gps_tracker/features/radar/widgets/ping_dialog_fields.dart';
import 'package:provider/provider.dart';

class AddDevicePingDialog extends StatefulWidget {
  const AddDevicePingDialog({super.key});

  @override
  State<AddDevicePingDialog> createState() => _AddDevicePingDialogState();
}

class _AddDevicePingDialogState extends State<AddDevicePingDialog> {
  String? _selId;
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();

  @override
  void dispose() {
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
  }

  void _generateRandom(double bLat, double bLng) {
    final rng = Random();
    final dLat = rng.nextDouble() * 0.09 - 0.045;
    final dLng = rng.nextDouble() * 0.09 - 0.045;
    setState(() {
      _latCtrl.text = (bLat + dLat).toStringAsFixed(6);
      _lngCtrl.text = (bLng + dLng).toStringAsFixed(6);
    });
  }

  void _sendPing(MqttProvider mqtt) {
    if (_selId == null) return;
    final lat = double.tryParse(_latCtrl.text.trim());
    final lng = double.tryParse(_lngCtrl.text.trim());
    if (lat == null || lng == null) return;

    mqtt.publishCoordinate(_selId!, lat, lng);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final mqtt = context.watch<MqttProvider>();
    final devices = mqtt.devices;
    final bLat = mqtt.baseLat;
    final bLng = mqtt.baseLng;

    if (_selId == null && devices.isNotEmpty) {
      _selId = devices.first.id;
    }

    return AlertDialog(
      backgroundColor: AppColors.cardBg,
      title: const Text(
        'Send Device Ping',
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DeviceDropdown(
              deviceIds: devices.map((d) => d.id).toList(),
              deviceNames: devices.map((d) => d.name).toList(),
              value: _selId,
              onChanged: (v) => setState(() => _selId = v),
            ),
            const SizedBox(height: 12),
            PingDialogField(
              controller: _latCtrl,
              label: 'Latitude',
              icon: Icons.location_on_outlined,
              isNumeric: true,
            ),
            const SizedBox(height: 12),
            PingDialogField(
              controller: _lngCtrl,
              label: 'Longitude',
              icon: Icons.explore_outlined,
              isNumeric: true,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.accentTeal,
                  side: const BorderSide(color: AppColors.accentTeal),
                ),
                icon: const Icon(Icons.shuffle, size: 16),
                label: const Text('Generate Random Nearby'),
                onPressed: bLat != null && bLng != null
                    ? () => _generateRandom(bLat, bLng)
                    : null,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        TextButton(
          onPressed: () => _sendPing(mqtt),
          child: const Text(
            'Send Ping',
            style: TextStyle(
              color: AppColors.accentTeal,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
