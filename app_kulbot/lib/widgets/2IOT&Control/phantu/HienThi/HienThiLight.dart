import 'package:flutter/material.dart';
import 'package:KulBlock/provider/CustomInputField.dart';

// SCSWidget – hiển thị cảm biến
class Hienthilight extends StatefulWidget {
  final Map<String, dynamic> config;
  final dynamic value;
  final Function(Map<String, dynamic>)? onSave;
  final VoidCallback? onDelete;
  final bool inMenu;

  const Hienthilight({
    super.key,
    required this.config,
    required this.value,
    this.onSave,
    this.onDelete,
    required this.inMenu,
  });

  @override
  State<Hienthilight> createState() => _HienThiLightState();
}

class _HienThiLightState extends State<Hienthilight> {
  late String selectedKey;
  late double width;
  late double height;

  @override
  void initState() {
    super.initState();
    width = (widget.config['width'] ?? 50).toDouble();
    height = (widget.config['height'] ?? 50).toDouble();

    final doubleKeys =
        widget.value is Map
            ? widget.value.keys.where((k) => widget.value[k] is bool).toList()
            : <String>[];
    selectedKey =
        widget.config['key']?.toString() ??
        (doubleKeys.isNotEmpty ? doubleKeys.first : '');
  }

  final List<Map<String, dynamic>> availableIcons = [
    {'label': '💡 Lightbulb', 'icon': Icons.lightbulb_outline},
    {'label': '⚡ Bolt', 'icon': Icons.bolt},
    {'label': '🔌 Power', 'icon': Icons.power_settings_new},
    {'label': '🌀 Fan', 'icon': Icons.toys},
    {'label': '🌡 Thermo', 'icon': Icons.thermostat_outlined},
    {'label': '📣 Whistle', 'icon': Icons.campaign}, // Icon còi
  ];

  void _showEditDialog() {
    String tempKey = selectedKey;
    final doubleKeys =
        widget.value is Map
            ? widget.value.keys.where((k) => widget.value[k] is bool).toList()
            : <String>[];

    final dropdowns = [
      doubleKeys.isNotEmpty
          ? DropdownInputField<String>(
            label: "Select Data Port",
            key: "key",
            items: doubleKeys,
            selectedValue:
                doubleKeys.contains(tempKey)
                    ? tempKey
                    : (doubleKeys.isNotEmpty ? doubleKeys.first : ""),
          )
          : DropdownInputField<String>(
            label: "Select Data Port",
            key: "key",
            items: [],
            selectedValue: "",
          ),
      DropdownInputField<String>(
        label: "Icon",
        key: "icon",
        items: availableIcons.map((e) => e['icon'].toString()).toList(),
        items_name: availableIcons.map((e) => e['label'].toString()).toList(),
        selectedValue:
            widget.config['icon']?.toString() ??
            availableIcons.first['icon'].toString(),
      ),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return CustomBottomSheetContent(
          title: "Select Data Port For Light",
          controllers: const [], // Không có input text
          dropdowns: dropdowns,
          errorNotData:
              "No data available to display. Please check the Bluetooth connection!",
          onOk: (result) {
            final selectedIcon =
                availableIcons.firstWhere(
                  (e) => e['icon'].toString() == result['icon'],
                  orElse: () => availableIcons.first,
                )['icon'];
            final newConfig = {
              ...widget.config,
              'key': result['key'] ?? "",
              'icon': selectedIcon.toString(),
            };
            selectedKey = result['key'] ?? "";
            widget.onSave?.call(newConfig);
            Navigator.of(context).pop();
          },
          onDelete:
              widget.onDelete != null
                  ? () {
                    Navigator.of(context).pop();
                    widget.onDelete?.call();
                  }
                  : null,
          onCancel: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isOn = false;
    String iconStr = widget.config['icon'] ?? "";
    IconData iconData =
        availableIcons.firstWhere(
          (e) => e['icon'].toString() == iconStr,
          orElse: () => {'icon': Icons.tips_and_updates_outlined},
        )['icon'];

    if (widget.inMenu) {
      isOn = true;
    } else if (widget.value is Map &&
        selectedKey.isNotEmpty &&
        widget.value[selectedKey] is bool) {
      isOn = widget.value[selectedKey] == true;
    } else if (widget.value is Map && widget.value.isEmpty) {
      isOn = false;
      // Error = "Không có dữ liệu"; // widget.value = {}
    } else {
      isOn = false;
      //Trường hợp widget.value = {a=0.0, b=1.0} nhưng selectedKey = c
      // Error = "Cổng hiện tại không có dữ liệu";
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color:
            isOn
                ? const Color.fromARGB(255, 246, 255, 0)
                : const Color.fromARGB(255, 255, 230, 230),
        borderRadius: BorderRadius.circular(50.0),
      ),
      child: Stack(
        children: [
          Center(
            child: Tooltip(
              message: isOn ? "On" : "Off",
              child: Icon(
                iconData,
                color:
                    isOn
                        ? const Color.fromARGB(255, 0, 255, 4)
                        : const Color.fromARGB(255, 102, 102, 102),
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
                    color: Color.fromARGB(190, 76, 175, 79),
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
                onTap: _showEditDialog,
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
