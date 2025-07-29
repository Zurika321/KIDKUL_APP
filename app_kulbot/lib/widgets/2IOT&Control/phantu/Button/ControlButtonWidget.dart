import 'package:flutter/material.dart';
import 'package:KulBlock/provider/CustomInputField.dart';

class ControlButtonWidget extends StatefulWidget {
  final Map<String, dynamic> config;
  final Function(Map<String, dynamic>)? onSave;
  final VoidCallback? onDelete;
  final bool lock;
  final Future<void> Function(String)? sendCommand;
  // final bool inMenu;

  const ControlButtonWidget({
    super.key,
    required this.config,
    this.onSave,
    this.onDelete,
    this.lock = false,
    this.sendCommand,
    // this.inMenu = false,
  });

  @override
  State<ControlButtonWidget> createState() => _ControlButtonWidgetState();
}

class _ControlButtonWidgetState extends State<ControlButtonWidget> {
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
      text: widget.config['title'] ?? 'Button',
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

  final List<Map<String, dynamic>> availableIcons = [
    {'label': '💡 Lightbulb', 'icon': Icons.lightbulb_outline},
    {'label': '⚡ Bolt', 'icon': Icons.bolt},
    {'label': '🔌 Power', 'icon': Icons.power_settings_new},
    {'label': '🌀 Fan', 'icon': Icons.toys},
    {'label': '🌡 Thermo', 'icon': Icons.thermostat_outlined},
    {'label': '📣 Whistle', 'icon': Icons.campaign},
  ];

  void _showSettingDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return CustomBottomSheetContent(
          title: "Setting Button",
          controllers: [
            TextInputField<String>(
              label: "Title",
              key: "title",
              controller: _titleController,
              minlength: 1,
              maxlength: 20,
            ),
            TextInputField<String>(
              label: "ON Command",
              key: "on",
              controller: _onCommandController,
              minlength: 1,
              maxlength: 5,
            ),
            TextInputField<String>(
              label: "OFF Command",
              key: "off",
              controller: _offCommandController,
              minlength: 1,
              maxlength: 5,
            ),
          ],
          dropdowns: [
            DropdownInputField<String>(
              label: "Icon",
              key: "icon",
              items: availableIcons.map((e) => e['icon'].toString()).toList(),
              items_name:
                  availableIcons.map((e) => e['label'].toString()).toList(),
              selectedValue:
                  widget.config['icon']?.toString() ??
                  availableIcons.first['icon'].toString(),
            ),
          ],
          onOk: (data) {
            final selectedIcon =
                availableIcons.firstWhere(
                  (e) => e['icon'].toString() == data['icon'],
                  orElse: () => availableIcons.first,
                )['icon'];

            widget.onSave?.call({
              ...widget.config,
              'title': data['title'],
              'on': data['on'],
              'off': data['off'],
              'icon': selectedIcon.toString(),
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
    String iconStr = widget.config['icon'] ?? "";
    IconData iconData =
        availableIcons.firstWhere(
          (e) => e['icon'].toString() == iconStr,
          orElse: () => {'icon': Icons.tips_and_updates_outlined},
        )['icon'];
    return
    // AbsorbPointer(
    //   absorbing: widget.inMenu,
    //   child:
    GestureDetector(
      onTap: widget.lock ? _handleTap : null,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color:
              isPressed
                  ? const Color.fromARGB(255, 161, 161, 161)
                  : const Color.fromARGB(255, 24, 255, 255),
          borderRadius: BorderRadius.circular(50.0),
        ),
        // padding: const EdgeInsets.all(12.0),
        child: Stack(
          children: [
            Center(
              child: Icon(iconData, color: const Color.fromARGB(255, 0, 0, 0)),
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
                      color: Color.fromARGB(170, 76, 175, 79),
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
      ),
      // ),
    );
  }
}
