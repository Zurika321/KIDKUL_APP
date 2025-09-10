import 'package:flutter/material.dart';

class ControlButtonWidget extends StatefulWidget {
  final Map<String, dynamic> config;
  final Function(Map<String, dynamic>)? onSave;
  final VoidCallback? onDelete;
  final Size size;
  final bool lock;
  final Future<void> Function(String)? sendCommand;

  const ControlButtonWidget({
    Key? key,
    required this.config,
    this.onSave,
    this.onDelete,
    required this.size,
    this.lock = false,
    this.sendCommand,
  }) : super(key: key);

  @override
  State<ControlButtonWidget> createState() => _ControlButtonWidgetState();
}

class _ControlButtonWidgetState extends State<ControlButtonWidget> {
  bool isPressed = false;
  late TextEditingController _titleController;
  late TextEditingController _onCommandController;
  late TextEditingController _offCommandController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.config['title'] ?? 'Nút',
    );
    _onCommandController = TextEditingController(
      text: widget.config['on'] ?? 'OO',
    );
    _offCommandController = TextEditingController(
      text: widget.config['off'] ?? 'PP',
    );
  }

  void _showSettingDialog() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Cài đặt nút"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Tên'),
                ),
                TextField(
                  controller: _onCommandController,
                  decoration: const InputDecoration(labelText: 'Lệnh bật'),
                ),
                TextField(
                  controller: _offCommandController,
                  decoration: const InputDecoration(labelText: 'Lệnh tắt'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  final newConfig = {
                    'title': _titleController.text,
                    'on': _onCommandController.text,
                    'off': _offCommandController.text,
                  };
                  widget.onSave?.call(newConfig);
                  Navigator.pop(context);
                  setState(() {});
                },
                child: const Text("Lưu"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Hủy"),
              ),
            ],
          ),
    );
  }

  void _handleTap() async {
    setState(() {
      isPressed = !isPressed;
    });
    final command =
        isPressed ? widget.config['on'] ?? 'OO' : widget.config['off'] ?? 'PP';
    await widget.sendCommand?.call(command);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: !widget.lock ? _showSettingDialog : null,
      onTap: !widget.lock ? null : _handleTap,
      child: Container(
        width: widget.size.width,
        height: widget.size.height,
        decoration: BoxDecoration(
          color: isPressed ? Colors.grey : Colors.cyanAccent,
          borderRadius: BorderRadius.circular(50.0),
        ),
        padding: const EdgeInsets.all(12.0),
        child: Icon(Icons.tips_and_updates_outlined, color: Colors.black),
      ),
    );
  }
}
