import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gps_tracker/core/data/models/coordinate_model.dart';
import 'package:gps_tracker/core/data/models/device_model.dart';
import 'package:gps_tracker/core/theme/app_colors.dart';
import 'package:gps_tracker/core/utils/haversine.dart';
import 'package:gps_tracker/features/radar/widgets/ping_dialog_fields.dart';
import 'package:uuid/uuid.dart';

class AddDevicePingDialog extends StatefulWidget {
  final List<DeviceModel> devices;
  final double? baseLat;
  final double? baseLng;
  final void Function(DeviceModel updated, bool isNew) onPingSent;

  const AddDevicePingDialog({
    required this.devices,
    required this.onPingSent,
    this.baseLat,
    this.baseLng,
    super.key,
  });

  @override
  State<AddDevicePingDialog> createState() => _AddDevicePingDialogState();
}

class _AddDevicePingDialogState extends State<AddDevicePingDialog> {
  String? _selId;
  final _nameCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
  }

  void _generateRandom() {
    final bLat = widget.baseLat;
    final bLng = widget.baseLng;
    if (bLat == null || bLng == null) return;
    final rng = Random();
    final dLat = rng.nextDouble() * 0.09 - 0.045;
    final dLng = rng.nextDouble() * 0.09 - 0.045;
    setState(() {
      _latCtrl.text = (bLat + dLat).toStringAsFixed(6);
      _lngCtrl.text = (bLng + dLng).toStringAsFixed(6);
    });
  }

  void _sendPing() {
    final lat = double.tryParse(_latCtrl.text.trim());
    final lng = double.tryParse(_lngCtrl.text.trim());
    if (lat == null || lng == null) return;

    final dist =
        haversineDistance(widget.baseLat ?? 0, widget.baseLng ?? 0, lat, lng);
    final coord = CoordinateModel(
      latitude: lat,
      longitude: lng,
      timestamp: DateTime.now(),
      distance: dist,
    );

    final isNew = _selId == null || _selId == DeviceDropdown.newKey;
    DeviceModel target;
    if (isNew) {
      final name = _nameCtrl.text.trim().isEmpty
          ? 'Device ${widget.devices.length + 1}'
          : _nameCtrl.text.trim();
      target = DeviceModel(
        id: const Uuid().v4(),
        name: name,
        coordinates: [coord],
      );
    } else {
      final ex = widget.devices.firstWhere((d) => d.id == _selId);
      target = ex.copyWith(coordinates: [...ex.coordinates, coord]);
    }
    widget.onPingSent(target, isNew);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final showName = _selId == null || _selId == DeviceDropdown.newKey;
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
              deviceIds: widget.devices.map((d) => d.id).toList(),
              deviceNames: widget.devices.map((d) => d.name).toList(),
              value: _selId,
              onChanged: (v) => setState(() => _selId = v),
            ),
            if (showName) ...[
              const SizedBox(height: 12),
              PingDialogField(
                controller: _nameCtrl,
                label: 'Device Name',
                icon: Icons.label_outline,
              ),
            ],
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
                onPressed: widget.baseLat != null ? _generateRandom : null,
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
          onPressed: _sendPing,
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
