import 'package:flutter/material.dart';
import 'package:Kulbot/widgets/Home/CustomInputField.dart';

class Label extends StatefulWidget {
  final Map<String, dynamic> value;
  final Map<String, dynamic> config;
  final bool
  dataDouble; // true: chỉ nhận value double, false: chỉ nhận value String
  final Function(Map<String, dynamic>)? onSave;
  final VoidCallback? onDelete;
  final bool inMenu;

  const Label({
    super.key,
    required this.value,
    required this.config,
    this.dataDouble = false,
    this.onSave,
    this.onDelete,
    required this.inMenu,
  });

  @override
  State<Label> createState() => _LabelState();
}

class _LabelState extends State<Label> {
  late String selectedKey;
  late String title;
  late double width;
  late double height;

  @override
  void initState() {
    super.initState();
    title =
        widget.config['title'] ?? widget.dataDouble
            ? 'Label Double'
            : 'Label String';
    width = (widget.config['width'] ?? 56).toDouble();
    height = (widget.config['height'] ?? 56).toDouble();
    // Chỉ lấy key phù hợp kiểu dữ liệu
    final keys =
        widget.value.keys
            .where(
              (k) =>
                  widget.dataDouble
                      ? widget.value[k] is double
                      : widget.value[k] is String,
            )
            .toList();
    selectedKey = widget.config['key'] ?? (keys.isNotEmpty ? keys.first : '');
  }

  void _showEditDialog() {
    final titleController = TextEditingController(text: title);
    final List<String> stringKeys =
        widget.value.keys.where((k) => widget.value[k] is String).toList();
    String tempKey = selectedKey;

    final controllers = [
      TextInputField<String>(
        label: "Tiêu đề",
        key: "title",
        controller: titleController,
      ),
    ];

    final dropdowns = [
      DropdownInputField<String>(
        label: "Chọn cổng dữ liệu",
        key: "key",
        items: stringKeys,
        selectedValue:
            stringKeys.contains(tempKey)
                ? tempKey
                : (stringKeys.isNotEmpty ? stringKeys.first : ""),
      ),
    ];

    showDialog(
      context: context,
      builder:
          (_) => CustomDialog(
            title: "Cấu hình Label",
            controllers: controllers,
            dropdowns:
                stringKeys.isNotEmpty
                    ? dropdowns
                    : [
                      DropdownInputField<String>(
                        label: "Chọn cổng dữ liệu",
                        key: "key",
                        items: [],
                        selectedValue: "",
                      ),
                    ],
            errorNotData:
                "Không có dữ liệu để hiển thị. Vui lòng kiểm tra kết nối bluetooth!",
            onOk: (result) {
              final newKey = result['key'];
              final newTitle = result['title'];
              widget.onSave?.call({
                ...widget.config,
                'title': newTitle,
                'key': newKey,
              });
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
    final value =
        (selectedKey.isNotEmpty &&
                ((widget.dataDouble && widget.value[selectedKey] is double) ||
                    (!widget.dataDouble &&
                        widget.value[selectedKey] is String)))
            ? widget.value[selectedKey].toString()
            : (selectedKey.isEmpty ||
                (widget.dataDouble && widget.value[selectedKey] is! double))
            ? "Cổng hiện tại không có dữ liệu"
            : 'Không có dữ liệu';
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          // Nội dung chính
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.inMenu ? "---" : value,
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  selectedKey,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
          // Nút kéo resize ở góc dưới bên phải
          if (widget.config["lock"] == false)
            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    width += details.delta.dx;
                    height += details.delta.dy;
                    width = width.clamp(120, 600);
                    height = height.clamp(80, 600);
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
