import 'package:flutter/material.dart';
import 'package:gps_tracker/core/theme/app_colors.dart';
import 'package:gps_tracker/features/radar/widgets/distance_control_panel.dart';
import 'package:gps_tracker/features/radar/widgets/radar_view.dart';

class RadarScreen extends StatefulWidget {
  const RadarScreen({super.key});

  @override
  State<RadarScreen> createState() => _RadarScreenState();
}

class _RadarScreenState extends State<RadarScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final TextEditingController _input = TextEditingController();
  double _radius = 0;
  bool _isDestroyed = false;
  int _mode = 1;
  Color _color = AppColors.accentTeal;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
  }

  void _handleInput(String inputText) {
    if (inputText.trim().isEmpty) return;

    if (inputText.trim().toLowerCase() == 'avada kedavra') {
      setState(() {
        _radius = 0;
        _isDestroyed = true;
        _controller.stop();
      });
      _input.clear();
      return;
    }

    final double? val = double.tryParse(inputText);
    if (val != null) {
      setState(() {
        _isDestroyed = false;
        _radius = (_radius + val).clamp(0, 10000);

        if (_radius < 500) {
          _controller.duration = const Duration(milliseconds: 2500);
          _color = AppColors.accentTeal;
          _mode = 1;
        } else if (_radius < 1000) {
          _controller.duration = const Duration(milliseconds: 1000);
          _color = Colors.orangeAccent;
          _mode = 2;
        } else {
          _controller.duration = const Duration(milliseconds: 400);
          _color = AppColors.errorRed;
          _mode = 3;
        }
        if (!_controller.isAnimating) _controller.repeat();
      });
      _input.clear();
    } else {
      _showError(inputText);
    }
  }

  void _showError(String inputText) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'ERROR: "$inputText" is not a valid '
          'coordinate format.',
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
      appBar: AppBar(title: const Text('IoT GPS Control')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: _isDestroyed
                    ? const Text(
                        'TRACKER OFFLINE',
                        style: TextStyle(
                          color: AppColors.errorRed,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : AnimatedBuilder(
                        animation: _controller,
                        builder: (context, _) => RadarView(
                          radius: _radius,
                          pulseValue: _controller.value,
                          mode: _mode,
                          color: _color,
                        ),
                      ),
              ),
            ),
            DistanceControlPanel(
              controller: _input,
              onSubmitted: _handleInput,
              currentRadius: _radius,
              isDestroyed: _isDestroyed,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _input.dispose();
    super.dispose();
  }
}
