// import 'dart:nativewrappers/_internal/vm/lib/ffi_allocation_patch.dart';

import 'package:flutter/material.dart';
import 'package:Kulbot/widgets/Home/CustomInputField.dart';

class HoldButtonWidget extends StatefulWidget {
  final Map<String, dynamic> config;
  final Function(Map<String, dynamic>)? onSave;
  final VoidCallback? onDelete;
  final bool lock;
  final Future<void> Function(String)? sendCommand;
  final bool inMenu;

  const HoldButtonWidget({
    super.key,
    required this.config,
    this.onSave,
    this.onDelete,
    this.lock = false,
    this.sendCommand,
    this.inMenu = false,
  });

  @override
  State<HoldButtonWidget> createState() => _HoldButtonWidgetState();
}

class _HoldButtonWidgetState extends State<HoldButtonWidget> {
  bool isPressed = false;
  late double width;
  late double height;
  late TextEditingController _titleController;
  late TextEditingController _onCommandController;
  late TextEditingController _offCommandController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.config['title'] ?? 'Giữ nút',
    );
    _onCommandController = TextEditingController(
      text: widget.config['on'] ?? 'OO',
    );
    _offCommandController = TextEditingController(
      text: widget.config['off'] ?? 'PP',
    );
    width = (widget.config['width'] ?? 50).toDouble();
    height = (widget.config['height'] ?? 50).toDouble();
  }

  void _showSettingDialog() {
    showDialog(
      context: context,
      builder:
          (_) => CustomDialog(
            title: "Cài đặt nút giữ",
            controllers: [
              TextInputField<String>(
                label: "Tên",
                key: "title", // dùng đúng key để map vào config
                controller: _titleController,
                minlength: 1,
                maxlength: 20,
              ),
              TextInputField<String>(
                label: "Lệnh bật",
                key: "on",
                controller: _onCommandController,
                minlength: 1,
                maxlength: 5,
              ),
              TextInputField<String>(
                label: "Lệnh tắt",
                key: "off",
                controller: _offCommandController,
                minlength: 1,
                maxlength: 5,
              ),
            ],
            onOk: (data) {
              widget.onSave?.call({
                ...widget.config,
                'title': data['title'],
                'on': data['on'],
                'off': data['off'],
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

  void _handlePressDown(_) async {
    setState(() {
      isPressed = true;
    });
    final onCommand = widget.config['on'] ?? 'OO';
    await widget.sendCommand?.call(onCommand);
  }

  void _handlePressUp(_) async {
    setState(() {
      isPressed = false;
    });
    final offCommand = widget.config['off'] ?? 'PP';
    await widget.sendCommand?.call(offCommand);
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: widget.inMenu,
      child: GestureDetector(
        onTapDown: (widget.lock && !widget.inMenu) ? _handlePressDown : null,
        onTapUp: (widget.lock && !widget.inMenu) ? _handlePressUp : null,
        onTapCancel:
            (widget.lock && !widget.inMenu)
                ? () async {
                  setState(() {
                    isPressed = false;
                  });
                  final offCommand = widget.config['off'] ?? 'PP';
                  await widget.sendCommand?.call(offCommand);
                }
                : null,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: isPressed ? Colors.orangeAccent : Colors.grey,
            borderRadius: BorderRadius.circular(50.0),
          ),
          // padding: const EdgeInsets.all(12.0),
          child: Stack(
            children: [
              const Center(child: Icon(Icons.lightbulb, color: Colors.black)),
              if (widget.config["lock"] == false)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        width += details.delta.dx;
                        height += details.delta.dy;
                        width = width.clamp(50, 200);
                        height = height.clamp(50, 200);
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
        ),
      ),
    );
  }
}
