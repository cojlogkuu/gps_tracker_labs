import 'package:flutter/material.dart';
import 'package:gps_tracker/core/theme/app_colors.dart';
import 'package:gps_tracker/features/radar/widgets/radar_body.dart';

class RadarScreen extends StatefulWidget {
  const RadarScreen({super.key});

  @override
  State<RadarScreen> createState() => _RadarScreenState();
}

class _RadarScreenState extends State<RadarScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  final _input = TextEditingController();
  double _radius = 0;
  bool _isDestroyed = false;
  int _mode = 1;
  Color _color = AppColors.accentTeal;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _input.dispose();
    super.dispose();
  }

  void _handleInput(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return;

    if (text.toLowerCase() == 'avada kedavra') {
      setState(() {
        _radius = 0;
        _isDestroyed = true;
        _ctrl.stop();
      });
      _input.clear();
      return;
    }

    final val = double.tryParse(text);
    if (val == null) {
      _showError(text);
      return;
    }

    setState(() {
      _isDestroyed = false;
      _radius = (_radius + val).clamp(0, 10000);
      _applyMode();
      if (!_ctrl.isAnimating) _ctrl.repeat();
    });
    _input.clear();
  }

  void _applyMode() {
    if (_radius < 500) {
      _ctrl.duration = const Duration(milliseconds: 2500);
      _color = AppColors.accentTeal;
      _mode = 1;
    } else if (_radius < 1000) {
      _ctrl.duration = const Duration(milliseconds: 1000);
      _color = Colors.orangeAccent;
      _mode = 2;
    } else {
      _ctrl.duration = const Duration(milliseconds: 400);
      _color = AppColors.errorRed;
      _mode = 3;
    }
  }

  void _showError(String text) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'ERROR: "$text" is not a valid coordinate format.',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.errorRed,
        ),
      );
    _input.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IoT GPS Control'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: AppColors.accentTeal),
            tooltip: 'Profile',
            onPressed: () => Navigator.of(context).pushNamed('/profile'),
          ),
        ],
      ),
      body: RadarBody(
        animation: _ctrl,
        inputController: _input,
        radius: _radius,
        isDestroyed: _isDestroyed,
        mode: _mode,
        color: _color,
        onSubmitted: _handleInput,
      ),
    );
  }
}
