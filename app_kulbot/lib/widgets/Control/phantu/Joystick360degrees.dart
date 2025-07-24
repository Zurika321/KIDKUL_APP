import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:Kulbot/widgets/Home/CustomInputField.dart';

class Joystick360degrees extends StatefulWidget {
  final Future<void> Function(String)? sendCommand;
  final Map<String, dynamic> config;
  final Function(Map<String, dynamic>)? onSave;
  final VoidCallback? onDelete;
  final bool inMenu;
  final bool lock;

  const Joystick360degrees({
    super.key,
    required this.config,
    this.onSave,
    this.onDelete,
    this.lock = false,
    this.sendCommand,
    this.inMenu = false,
  });

  @override
  State<Joystick360degrees> createState() => _Joystick360degreesState();
}

class _Joystick360degreesState extends State<Joystick360degrees> {
  bool isPressed = false;
  late double width;
  late double height;

  late TextEditingController stop,
      tien,
      lui,
      phai,
      trai,
      tienphai,
      tientrai,
      luiphai,
      luitrai;

  @override
  void initState() {
    super.initState();
    stop = TextEditingController(text: widget.config['stop'] ?? 'SS');
    tien = TextEditingController(text: widget.config['tien'] ?? 'FW');
    lui = TextEditingController(text: widget.config['lui'] ?? 'BW');
    phai = TextEditingController(text: widget.config['phai'] ?? 'TR');
    trai = TextEditingController(text: widget.config['trai'] ?? 'TL');
    tienphai = TextEditingController(text: widget.config['tienphai'] ?? 'FWR');
    tientrai = TextEditingController(text: widget.config['tientrai'] ?? 'FWL');
    luiphai = TextEditingController(text: widget.config['luiphai'] ?? 'BWR');
    luitrai = TextEditingController(text: widget.config['luitrai'] ?? 'BWL');
    width = (widget.config['width'] ?? 125).toDouble();
    height = (widget.config['height'] ?? 125).toDouble();
  }

  void _showSettingDialog() {
    showDialog(
      context: context,
      builder:
          (_) => CustomDialog(
            title: "Cài đặt nút",
            controllers: [
              TextInputField<String>(
                label: "Stop",
                key: "stop",
                controller: stop,
                minlength: 2,
                maxlength: 3,
              ),
              TextInputField<String>(
                label: "Forward",
                key: "tien",
                controller: tien,
                minlength: 2,
                maxlength: 3,
              ),
              TextInputField<String>(
                label: "Backward",
                key: "lui",
                controller: lui,
                minlength: 2,
                maxlength: 3,
              ),
              TextInputField<String>(
                label: "Right",
                key: "phai",
                controller: phai,
                minlength: 2,
                maxlength: 3,
              ),
              TextInputField<String>(
                label: "Left",
                key: "trai",
                controller: trai,
                minlength: 2,
                maxlength: 3,
              ),
              TextInputField<String>(
                label: "Forward Right",
                key: "tienphai",
                controller: tienphai,
                minlength: 2,
                maxlength: 3,
              ),
              TextInputField<String>(
                label: "Forward Left",
                key: "tientrai",
                controller: tientrai,
                minlength: 2,
                maxlength: 3,
              ),
              TextInputField<String>(
                label: "Backward Right",
                key: "luiphai",
                controller: luiphai,
                minlength: 2,
                maxlength: 3,
              ),
              TextInputField<String>(
                label: "Backward Left",
                key: "luitrai",
                controller: luitrai,
                minlength: 2,
                maxlength: 3,
              ),
            ],
            onOk: (data) {
              widget.onSave?.call({
                ...widget.config,
                'stop': data['stop'],
                'tien': data['tien'],
                'lui': data['lui'],
                'phai': data['phai'],
                'trai': data['trai'],
                'tienphai': data['tienphai'],
                'tientrai': data['tientrai'],
                'luiphai': data['luiphai'],
                'luitrai': data['luitrai'],
              });
              Navigator.pop(context);
            },
            onCancel: () {
              Navigator.pop(context);
            },
            onDelete:
                widget.onDelete != null
                    ? () {
                      Navigator.pop(context);
                      widget.onDelete?.call();
                    }
                    : null,
          ),
    );
  }

  void _handleJoystickMove(details) {
    final dx = details.x;
    final dy = details.y;
    final angle =
        (dy == 0 && dx == 0) ? 0.0 : (atan2(dy, dx) * 180 / pi + 360) % 360;
    final strength = sqrt(dx * dx + dy * dy).clamp(0.0, 1.0);
    double adjustedAngle = (angle + 90) % 360;

    if (strength < 0.2) {
      print("🛑 Dừng");
      widget.sendCommand?.call("stop");
    } else {
      if (adjustedAngle >= 337.5 || adjustedAngle < 22.5) {
        print("⬆️ Tiến");
        widget.sendCommand?.call("forward");
      } else if (adjustedAngle >= 22.5 && adjustedAngle < 67.5) {
        print("↗️ Tiến Phải");
        widget.sendCommand?.call("forwardRight");
      } else if (adjustedAngle >= 67.5 && adjustedAngle < 112.5) {
        print("➡️ Xoay Phải");
        widget.sendCommand?.call("turnRight");
      } else if (adjustedAngle >= 112.5 && adjustedAngle < 157.5) {
        print("↘️ Lùi Phải");
        widget.sendCommand?.call("backwardRight");
      } else if (adjustedAngle >= 157.5 && adjustedAngle < 202.5) {
        print("⬇️ Lùi");
        widget.sendCommand?.call("backward");
      } else if (adjustedAngle >= 202.5 && adjustedAngle < 247.5) {
        print("↙️ Lùi Trái");
        widget.sendCommand?.call("backwardLeft");
      } else if (adjustedAngle >= 247.5 && adjustedAngle < 292.5) {
        print("⬅️ Xoay Trái");
        widget.sendCommand?.call("turnLeft");
      } else if (adjustedAngle >= 292.5 && adjustedAngle < 337.5) {
        print("↖️ Tiến Trái");
        widget.sendCommand?.call("forwardLeft");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final small = width < height ? width : height;
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      child: Stack(
        children: [
          Center(
            child: Container(
              width: small,
              height: small,
              child: Joystick(
                mode: JoystickMode.all,
                listener: (details) {
                  _handleJoystickMove(details);
                },
              ),
            ),
          ),
          if (widget.config["lock"] == false)
            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    width += details.delta.dx;
                    height += details.delta.dy;
                    width = width.clamp(125, 225);
                    height = height.clamp(125, 225);
                  });
                },
                onPanEnd: (_) {
                  widget.onSave?.call({
                    ...widget.config,
                    'width': width,
                    'height': height,
                  });
                },
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.7),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: const Icon(
                    Icons.open_in_full,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          if (widget.config["lock"] == false)
            Positioned(
              right: 0,
              top: 0,
              child: GestureDetector(
                onTap: _showSettingDialog,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.7),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: const Icon(
                    Icons.settings,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
