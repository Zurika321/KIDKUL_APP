import 'package:flutter/material.dart';
import 'package:Kulbot/widgets/Home/CustomInputField.dart';

class SwitchButtonWidget extends StatefulWidget {
  final Map<String, dynamic> config;
  final Function(Map<String, dynamic>)? onSave;
  final VoidCallback? onDelete;
  final bool lock;
  final Future<void> Function(String)? sendCommand;
  final bool inMenu;

  const SwitchButtonWidget({
    super.key,
    required this.config,
    this.onSave,
    this.onDelete,
    this.lock = false,
    this.sendCommand,
    this.inMenu = false,
  });

  @override
  State<SwitchButtonWidget> createState() => _SwitchButtonWidgetState();
}

class _SwitchButtonWidgetState extends State<SwitchButtonWidget> {
  bool isOn = false;
  late double width;
  late double height;
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
      text: widget.config['on'] ?? 'ON',
    );
    _offCommandController = TextEditingController(
      text: widget.config['off'] ?? 'OFF',
    );
    width = (widget.config['width'] ?? 50).toDouble();
    height = (widget.config['height'] ?? 50).toDouble();
  }

  void _toggleSwitch(bool value) async {
    setState(() {
      isOn = value;
    });
    final command =
        isOn ? widget.config['on'] ?? 'ON' : widget.config['off'] ?? 'OFF';
    await widget.sendCommand?.call(command);
  }

  void _showSettingDialog() {
    if (widget.onSave == null && widget.onDelete == null) return;

    showDialog(
      context: context,
      builder:
          (_) => CustomDialog(
            title: "Cài đặt nút",
            controllers: [
              TextInputField<String>(
                label: "Tên",
                key: "title",
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
            onOk:
                widget.onSave != null
                    ? (data) {
                      widget.onSave?.call({
                        ...widget.config,
                        'title': data['title'],
                        'on': data['on'],
                        'off': data['off'],
                      });
                      Navigator.pop(context);
                    }
                    : null,
            onCancel: () => Navigator.pop(context),
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // onTap: _showSettingDialog,
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          children: [
            AbsorbPointer(
              absorbing: widget.inMenu,
              child: Material(
                color: Colors.transparent,
                child: Center(
                  child: SizedBox(
                    width: width,
                    height: height,
                    child: Switch(
                      value: isOn,
                      onChanged: _toggleSwitch,
                      activeColor: Colors.orange,
                      inactiveThumbColor: Colors.grey,
                      inactiveTrackColor: Colors.grey[300],
                    ),
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
                      width = width.clamp(60, 150);
                      height = height.clamp(50, 80);
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
    );
  }
}
