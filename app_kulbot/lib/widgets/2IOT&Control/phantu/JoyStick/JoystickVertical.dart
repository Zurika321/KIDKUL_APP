// JoystickVertical.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:KulBlock/provider/CustomInputField.dart';

class JoystickVertical extends StatefulWidget {
  final Future<void> Function(String)? sendCommand;
  final Map<String, dynamic> config;
  final Function(Map<String, dynamic>)? onSave;
  final VoidCallback? onDelete;
  // final bool inMenu;
  final bool lock;

  const JoystickVertical({
    super.key,
    required this.config,
    this.onSave,
    this.onDelete,
    this.lock = false,
    this.sendCommand,
    // this.inMenu = false,
  });

  @override
  State<JoystickVertical> createState() => _JoystickVerticalState();
}

class _JoystickVerticalState extends State<JoystickVertical> {
  bool isPressed = false;
  late double width;
  late double height;

  late TextEditingController stop, tien, lui, stickIcon;

  @override
  void initState() {
    super.initState();
    stop = TextEditingController(text: widget.config['stop'] ?? 'SS');
    tien = TextEditingController(text: widget.config['tien'] ?? 'FW');
    lui = TextEditingController(text: widget.config['lui'] ?? 'BW');
    stickIcon = TextEditingController(text: widget.config['stickIcon'] ?? '🔘');

    width = (widget.config['width'] ?? 125).toDouble();
    height = (widget.config['height'] ?? 125).toDouble();
  }

  void _showSettingDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return CustomBottomSheetContent(
          title: "SettingButton",
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
              label: "Stick Icon",
              key: "stickIcon",
              controller: stickIcon,
              minlength: 1,
              maxlength: 2,
            ),
          ],
          onOk: (data) {
            widget.onSave?.call({
              ...widget.config,
              'stop': data['stop'],
              'tien': data['tien'],
              'lui': data['lui'],
              'stickIcon': data['stickIcon'],
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
        );
      },
    );
  }

  void _onMove(details) {
    final dy = details.y;
    final strength = dy.abs().clamp(0.0, 1.0);

    if (strength < 0.2) {
      // print("stop");
      widget.sendCommand?.call(stop.text);
    } else if (dy > 0) {
      // print("forward");
      widget.sendCommand?.call(tien.text);
    } else {
      // print("backward");
      widget.sendCommand?.call(lui.text);
    }
  }

  bool _shouldShowBackground(String text) {
    if (text.isEmpty) return false;

    // Kiểm tra ký tự đầu tiên
    final rune = text.runes.first;

    // Emoji Unicode: nhiều emoji nằm trong khoảng từ 0x1F300 đến 0x1FAFF và các khối khác
    if ((rune >= 0x1F300 && rune <= 0x1FAFF) || // emoji chính
        (rune >= 0x2600 && rune <= 0x26FF) || // symbol & emoji bổ sung
        (rune >= 0x2700 && rune <= 0x27BF)) {
      return false; // là emoji
    }

    return true; // là ký tự thông thường, số, đặc biệt, v.v.
  }

  @override
  Widget build(BuildContext context) {
    final small = width < height ? width : height;
    final double fontSize = math.max(20.0, small * 0.18);
    final double size = math.max(30.0, small * 0.25);

    return Container(
      width: width,
      height: height,
      // padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        // color: Colors.black,
      ),
      child: Stack(
        children: [
          Center(
            child: Container(
              width: small,
              height: small,
              child: AbsorbPointer(
                absorbing: widget.config["lock"] == false,
                child: Joystick(
                  mode: JoystickMode.vertical,
                  stick: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color:
                          _shouldShowBackground(stickIcon.text)
                              ? const Color.fromARGB(120, 76, 175, 79)
                              : null,
                      shape: BoxShape.circle, //BoxShape.rectangle,
                      // borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        stickIcon.text,
                        textAlign: TextAlign.center,
                        textHeightBehavior: const TextHeightBehavior(
                          applyHeightToFirstAscent: false,
                          applyHeightToLastDescent: false,
                        ),
                        style: TextStyle(
                          fontSize: fontSize,
                          height: 1.0, // giảm chiều cao dòng
                        ),
                      ),
                    ),
                  ),
                  listener: _onMove,
                ),
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
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(190, 33, 149, 243),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: const Icon(
                    Icons.open_in_full,
                    size: 16,
                    color: Color.fromARGB(255, 255, 255, 255),
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
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(190, 76, 175, 79),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: const Icon(
                    Icons.settings,
                    size: 16,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
