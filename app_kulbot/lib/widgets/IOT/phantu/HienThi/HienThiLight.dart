import 'package:flutter/material.dart';
import 'package:Kulbot/widgets/Home/CustomInputField.dart';

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

  void _showEditDialog() {
    String tempKey = selectedKey;
    final doubleKeys =
        widget.value is Map
            ? widget.value.keys.where((k) => widget.value[k] is bool).toList()
            : <String>[];

    final dropdowns = [
      DropdownInputField<String>(
        label: "Chọn Cổng dữ liệu",
        key: "key",
        items: doubleKeys,
        selectedValue:
            doubleKeys.contains(tempKey)
                ? tempKey
                : (doubleKeys.isNotEmpty ? doubleKeys.first : ""),
      ),
    ];

    showDialog(
      context: context,
      builder:
          (_) => CustomDialog(
            title: "Cài đặt cổng cho đèn",
            controllers: const [], // Không có input text
            dropdowns:
                doubleKeys.isNotEmpty
                    ? dropdowns
                    : [
                      DropdownInputField<String>(
                        label: "Chọn Cổng dữ liệu",
                        key: "key",
                        items: [],
                        selectedValue: "",
                      ),
                    ],
            errorNotData:
                "Không có dữ liệu để hiển thị. Vui lòng kiểm tra kết nối bluetooth!",
            onOk: (result) {
              final newConfig = {...widget.config, 'key': result['key'] ?? ""};
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
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isOn = false;
    // String Error = "";

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
        color: isOn ? Colors.cyanAccent : Colors.grey,
        borderRadius: BorderRadius.circular(50.0),
      ),
      child: Stack(
        children: [
          Center(
            child:
                isOn
                    ? Icon(Icons.tips_and_updates_outlined, color: Colors.black)
                    : Icon(Icons.lightbulb, color: Colors.black),
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
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.7),
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
                onTap: _showEditDialog,
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
