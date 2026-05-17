import 'package:flutter/material.dart';
import 'package:gps_tracker/core/data/models/device_model.dart';
import 'package:gps_tracker/core/theme/app_colors.dart';
import 'package:gps_tracker/features/radar/widgets/base_coords_panel.dart';
import 'package:gps_tracker/features/radar/widgets/device_list_tile.dart';
import 'package:gps_tracker/features/radar/widgets/radar_view.dart';

class RadarBody extends StatelessWidget {
  final Animation<double> animation;
  final List<DeviceModel> devices;
  final double? baseLat;
  final double? baseLng;
  final int mode;
  final Color color;
  final Future<void> Function(double lat, double lng) onSetBase;

  const RadarBody({
    required this.animation,
    required this.devices,
    required this.onSetBase,
    this.baseLat,
    this.baseLng,
    this.mode = 1,
    this.color = AppColors.accentTeal,
    super.key,
  });

  double get _nearestDistance {
    double min = double.infinity;
    for (final d in devices) {
      if (d.coordinates.isNotEmpty) {
        final dist = d.coordinates.last.distance;
        if (dist < min) min = dist;
      }
    }
    return min == double.infinity ? 0 : min;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: AnimatedBuilder(
                animation: animation,
                builder: (context, child) => RadarView(
                  radius: _nearestDistance.clamp(0, 10000),
                  pulseValue: animation.value,
                  mode: mode,
                  color: color,
                ),
              ),
            ),
          ),
          if (devices.isNotEmpty) ...[
            const SizedBox(height: 16),
            _DeviceSection(devices: devices),
          ],
          const SizedBox(height: 16),
          BaseCoordsPanel(
            initialLat: baseLat,
            initialLng: baseLng,
            onSave: onSetBase,
          ),
        ],
      ),
    );
  }
}

class _DeviceSection extends StatelessWidget {
  final List<DeviceModel> devices;
  const _DeviceSection({required this.devices});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'TRACKED DEVICES',
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 2.5,
            color: AppColors.accentTeal,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        for (final d in devices) DeviceListTile(device: d),
      ],
    );
  }
}
