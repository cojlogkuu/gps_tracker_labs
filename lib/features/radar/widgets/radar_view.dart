import 'dart:math';

import 'package:flutter/material.dart';

class RadarView extends StatelessWidget {
  final double radius;
  final double pulseValue;
  final int mode;
  final Color color;

  const RadarView({
    required this.radius,
    required this.pulseValue,
    required this.mode,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final double size = min(radius * 2.5 + 50, 320);
    final double rotation = mode >= 2 ? pulseValue * 2 * pi : 0.0;
    final double shake = mode == 3 ? sin(pulseValue * pi * 10) * 8 : 0.0;

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: size * pulseValue,
          height: size * pulseValue,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withValues(alpha: 1.0 - pulseValue),
              width: 3,
            ),
          ),
        ),
        Container(
          width: size * (pulseValue * 0.6),
          height: size * (pulseValue * 0.6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.15 * (1.0 - pulseValue)),
          ),
        ),
        Transform.translate(
          offset: Offset(shake, 0),
          child: Transform.rotate(
            angle: rotation,
            child: Icon(Icons.satellite_alt, color: color, size: 48),
          ),
        ),
      ],
    );
  }
}
