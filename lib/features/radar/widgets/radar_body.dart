import 'package:flutter/material.dart';
import 'package:gps_tracker/core/theme/app_colors.dart';
import 'package:gps_tracker/features/radar/widgets/distance_control_panel.dart';
import 'package:gps_tracker/features/radar/widgets/radar_view.dart';

class RadarBody extends StatelessWidget {
  final Animation<double> animation;
  final TextEditingController inputController;
  final double radius;
  final bool isDestroyed;
  final int mode;
  final Color color;
  final void Function(String) onSubmitted;

  const RadarBody({
    required this.animation,
    required this.inputController,
    required this.radius,
    required this.isDestroyed,
    required this.mode,
    required this.color,
    required this.onSubmitted,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Expanded(child: Center(child: _RadarOrOffline(this))),
          DistanceControlPanel(
            controller: inputController,
            onSubmitted: onSubmitted,
            currentRadius: radius,
            isDestroyed: isDestroyed,
          ),
        ],
      ),
    );
  }
}

class _RadarOrOffline extends StatelessWidget {
  final RadarBody props;
  const _RadarOrOffline(this.props);

  @override
  Widget build(BuildContext context) {
    if (props.isDestroyed) {
      return const Text(
        'TRACKER OFFLINE',
        style: TextStyle(
          color: AppColors.errorRed,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      );
    }
    return AnimatedBuilder(
      animation: props.animation,
      builder: (_, child) => RadarView(
        radius: props.radius,
        pulseValue: props.animation.value,
        mode: props.mode,
        color: props.color,
      ),
    );
  }
}
