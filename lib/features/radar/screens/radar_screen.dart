import 'package:flutter/material.dart';
import 'package:gps_tracker/core/data/models/device_model.dart';
import 'package:gps_tracker/core/providers/mqtt_provider.dart';
import 'package:gps_tracker/core/theme/app_colors.dart';
import 'package:gps_tracker/features/auth/cubit/auth_cubit.dart';
import 'package:gps_tracker/features/radar/widgets/add_device_ping_dialog.dart';
import 'package:gps_tracker/features/radar/widgets/radar_body.dart';
import 'package:provider/provider.dart';

class RadarScreen extends StatefulWidget {
  const RadarScreen({super.key});

  @override
  State<RadarScreen> createState() => _RadarScreenState();
}

class _RadarScreenState extends State<RadarScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
  }

  void _syncAnimation(List<DeviceModel> devices) {
    if (devices.isEmpty) {
      _ctrl.duration = const Duration(milliseconds: 2500);
      return;
    }
    final nearest = devices.where((d) => d.coordinates.isNotEmpty).fold<double>(
      double.infinity,
      (min, d) {
        final dist = d.coordinates.last.distance;
        return dist < min ? dist : min;
      },
    );
    if (nearest < 500) {
      _ctrl.duration = const Duration(milliseconds: 2500);
    } else if (nearest < 2000) {
      _ctrl.duration = const Duration(milliseconds: 1200);
    } else {
      _ctrl.duration = const Duration(milliseconds: 600);
    }
    if (!_ctrl.isAnimating) _ctrl.repeat();
  }

  Color _radarColor(List<DeviceModel> devices) {
    if (devices.isEmpty) return AppColors.accentTeal;
    final nearest = devices.where((d) => d.coordinates.isNotEmpty).fold<double>(
      double.infinity,
      (min, d) {
        final dist = d.coordinates.last.distance;
        return dist < min ? dist : min;
      },
    );
    if (nearest < 500) return AppColors.accentTeal;
    if (nearest < 2000) return Colors.orangeAccent;
    return AppColors.errorRed;
  }

  int _radarMode(List<DeviceModel> devices) {
    if (devices.isEmpty) return 1;
    final nearest = devices.where((d) => d.coordinates.isNotEmpty).fold<double>(
      double.infinity,
      (min, d) {
        final dist = d.coordinates.last.distance;
        return dist < min ? dist : min;
      },
    );
    if (nearest < 500) return 1;
    if (nearest < 2000) return 2;
    return 3;
  }

  void _openPingDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => const AddDevicePingDialog(),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mqtt = context.watch<MqttProvider>();
    _syncAnimation(mqtt.devices);

    return Scaffold(
      appBar: AppBar(
        title: const Text('IoT GPS Control'),
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openPingDialog(context),
        backgroundColor: AppColors.accentTeal,
        foregroundColor: AppColors.primaryBg,
        tooltip: 'Send Device Ping',
        child: const Icon(Icons.add_location_alt),
      ),
      body: RadarBody(
        animation: _ctrl,
        devices: mqtt.devices,
        baseLat: mqtt.baseLat,
        baseLng: mqtt.baseLng,
        mode: _radarMode(mqtt.devices),
        color: _radarColor(mqtt.devices),
        onSetBase: (lat, lng) async {
          await context.read<AuthCubit>().updateBaseCoords(lat, lng);
          if (!context.mounted) return;
          await mqtt.setBase(lat, lng);
        },
      ),
    );
  }
}
