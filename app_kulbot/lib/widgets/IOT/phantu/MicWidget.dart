// MicShowKeyWidget.dart
import 'package:flutter/material.dart';

class MicShowKeyWidget extends StatelessWidget {
  final double size;
  final bool active;

  const MicShowKeyWidget({super.key, required this.size, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      // color: Colors.blue.withOpacity(0.3),
      decoration: BoxDecoration(
        color: Colors.cyanAccent,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.mic, color: active ? Colors.green : Colors.grey),
    );
  }
}
