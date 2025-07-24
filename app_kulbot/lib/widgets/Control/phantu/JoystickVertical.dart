// JoystickVertical.dart
import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:Kulbot/widgets/Home/CustomInputField.dart';

class JoystickVertical extends StatefulWidget {
  final Future<void> Function(String)? sendCommand;
  final Map<String, dynamic> config;
  final Function(Map<String, dynamic>)? onSave;
  final VoidCallback? onDelete;
  final bool inMenu;
  final bool lock;

  const JoystickVertical({
    super.key,
    required this.config,
    this.onSave,
    this.onDelete,
    this.lock = false,
    this.sendCommand,
    this.inMenu = false,
  });

  @override
  State<JoystickVertical> createState() => _JoystickVerticalState();
}

class _JoystickVerticalState extends State<JoystickVertical> {
  bool isPressed = false;
  late double width;
  late double height;

  late TextEditingController stop, tien, lui;

  @override
  void initState() {
    super.initState();
    stop = TextEditingController(text: widget.config['stop'] ?? 'SS');
    tien = TextEditingController(text: widget.config['tien'] ?? 'FW');
    lui = TextEditingController(text: widget.config['lui'] ?? 'BW');
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
            ],
            onOk: (data) {
              widget.onSave?.call({
                ...widget.config,
                'stop': data['stop'],
                'tien': data['tien'],
                'lui': data['lui'],
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

  void _onMove(details) {
    final dy = details.y;
    final strength = dy.abs().clamp(0.0, 1.0);

    if (strength < 0.2) {
      print("stop");
      widget.sendCommand?.call(stop.text);
    } else if (dy > 0) {
      print("forward");
      widget.sendCommand?.call(tien.text);
    } else {
      print("backward");
      widget.sendCommand?.call(lui.text);
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
              child: Joystick(mode: JoystickMode.vertical, listener: _onMove),
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
