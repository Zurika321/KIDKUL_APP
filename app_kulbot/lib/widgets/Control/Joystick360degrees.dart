import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:showcaseview/showcaseview.dart';

class Joystick360degrees extends StatelessWidget {
  final GlobalKey showcaseKey;
  final String description;
  final void Function(double angle, double strength) onMove;

  const Joystick360degrees({
    Key? key,
    required this.showcaseKey,
    required this.description,
    required this.onMove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Showcase(
      key: showcaseKey,
      description: description,
      child: Container(
        width: 200,
        height: 200,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.cyanAccent),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Joystick(
          mode: JoystickMode.all,
          listener: (details) {
            final dx = details.x;
            final dy = details.y;
            final angle = (dy == 0 && dx == 0)
                ? 0.0
                : (atan2(dy, dx) * 180 / pi + 360) % 360;
            final strength = sqrt(dx * dx + dy * dy).clamp(0.0, 1.0);
            onMove(angle, strength);
          },
          base: JoystickBase(
            decoration: JoystickBaseDecoration(
              drawOuterCircle: true,
              drawInnerCircle: true,
              middleCircleColor: Colors.cyanAccent,
              boxShadowColor: Colors.cyanAccent.withOpacity(0.5),
            ),
            arrowsDecoration: JoystickArrowsDecoration(
              color: Colors.yellowAccent,
            ),
          ),
          stick: JoystickStick(
            size: 80,
            decoration: JoystickStickDecoration(
              color: Colors.yellowAccent,
            ),
          ),
        ),
      ),
    );
  }
}
