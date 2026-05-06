import 'package:flutter/material.dart';
import 'package:gps_tracker/core/data/models/device_model.dart';
import 'package:gps_tracker/core/data/repositories/device_repository.dart';
import 'package:gps_tracker/core/theme/app_colors.dart';
import 'package:gps_tracker/features/radar/widgets/add_device_ping_dialog.dart';
import 'package:gps_tracker/features/radar/widgets/radar_body.dart';

class RadarScreen extends StatefulWidget {
  const RadarScreen({super.key});

  @override
  State<RadarScreen> createState() => _RadarScreenState();
}

class _RadarScreenState extends State<RadarScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  final IDeviceRepository _repo = SharedPrefsDeviceRepository();

  List<DeviceModel> _devices = [];
  double? _baseLat;
  double? _baseLng;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
    _load();
  }

  Future<void> _load() async {
    final coords = await _repo.loadBaseCoords();
    final devices = await _repo.loadDevices();
    if (!mounted) return;
    setState(() {
      if (coords != null) {
        _baseLat = coords.$1;
        _baseLng = coords.$2;
      }
      _devices = devices;
      _syncAnimation();
    });
  }

  void _syncAnimation() {
    if (_devices.isEmpty) {
      _ctrl.duration = const Duration(milliseconds: 2500);
      return;
    }
    final nearest = _devices
        .where((d) => d.coordinates.isNotEmpty)
        .fold<double>(double.infinity, (min, d) {
      final dist = d.coordinates.last.distance;
      return dist < min ? dist : min;
    });
    if (nearest < 500) {
      _ctrl.duration = const Duration(milliseconds: 2500);
    } else if (nearest < 2000) {
      _ctrl.duration = const Duration(milliseconds: 1200);
    } else {
      _ctrl.duration = const Duration(milliseconds: 600);
    }
    if (!_ctrl.isAnimating) _ctrl.repeat();
  }

  Color get _radarColor {
    if (_devices.isEmpty) return AppColors.accentTeal;
    final nearest = _devices
        .where((d) => d.coordinates.isNotEmpty)
        .fold<double>(double.infinity, (min, d) {
      final dist = d.coordinates.last.distance;
      return dist < min ? dist : min;
    });
    if (nearest < 500) return AppColors.accentTeal;
    if (nearest < 2000) return Colors.orangeAccent;
    return AppColors.errorRed;
  }

  int get _radarMode {
    if (_devices.isEmpty) return 1;
    final nearest = _devices
        .where((d) => d.coordinates.isNotEmpty)
        .fold<double>(double.infinity, (min, d) {
      final dist = d.coordinates.last.distance;
      return dist < min ? dist : min;
    });
    if (nearest < 500) return 1;
    if (nearest < 2000) return 2;
    return 3;
  }

  Future<void> _setBase(double lat, double lng) async {
    await _repo.saveBaseCoords(lat, lng);
    if (!mounted) return;
    setState(() {
      _baseLat = lat;
      _baseLng = lng;
    });
  }

  Future<void> _onPingSent(DeviceModel updated, bool isNew) async {
    final list = isNew
        ? [..._devices, updated]
        : [
            for (final d in _devices)
              d.id == updated.id ? updated : d,
          ];
    await _repo.saveDevices(list);
    if (!mounted) return;
    setState(() {
      _devices = list;
      _syncAnimation();
    });
  }

  void _openPingDialog() {
    showDialog<void>(
      context: context,
      builder: (_) => AddDevicePingDialog(
        devices: _devices,
        baseLat: _baseLat,
        baseLng: _baseLng,
        onPingSent: _onPingSent,
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IoT GPS Control'),
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openPingDialog,
        backgroundColor: AppColors.accentTeal,
        foregroundColor: AppColors.primaryBg,
        tooltip: 'Send Device Ping',
        child: const Icon(Icons.add_location_alt),
      ),
      body: RadarBody(
        animation: _ctrl,
        devices: _devices,
        baseLat: _baseLat,
        baseLng: _baseLng,
        mode: _radarMode,
        color: _radarColor,
        onSetBase: _setBase,
      ),
    );
  }
}
