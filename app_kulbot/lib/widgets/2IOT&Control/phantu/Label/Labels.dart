import 'package:flutter/material.dart';
import 'package:KulBlock/provider/CustomInputField.dart';

class Labels extends StatefulWidget {
  final Map<String, dynamic> value;
  final Map<String, dynamic> config;
  final Function(Map<String, dynamic>)? onSave;
  final VoidCallback? onDelete;
  final bool inMenu;

  const Labels({
    required this.value,
    required this.config,
    this.onSave,
    this.onDelete,
    required this.inMenu,
  });

  @override
  State<Labels> createState() => _LabelsState();
}

class DataKey {
  final String name;
  final String type;

  DataKey({required this.name, required this.type});
}

class _LabelsState extends State<Labels> {
  late String selectedKey;
  late String title;
  late double width;
  late double height;
  List<DataKey> keys = [];

  @override
  void initState() {
    super.initState();
    title = widget.config['title'] ?? 'Label';
    width = (widget.config['width'] ?? 200).toDouble();
    height = (widget.config['height'] ?? 80).toDouble();
    _applyConfig();
  }

  void _applyConfig() {
    keys =
        widget.value.entries
            .where((e) {
              final typeStr = e.value.runtimeType.toString();
              return ['String', 'int', 'double', 'bool'].contains(typeStr);
            })
            .map(
              (e) => DataKey(name: e.key, type: e.value.runtimeType.toString()),
            )
            .toList();
    selectedKey = keys.isNotEmpty ? keys.first.name : "";
  }

  @override
  void didUpdateWidget(Labels oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && !widget.inMenu) {
      _applyConfig();
    }
  }

  void _showEditDialog() {
    final titleController = TextEditingController(text: title);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return CustomBottomSheetContent(
              title: "Setting Label",
              controllers: [
                TextInputField<String>(
                  label: "Title",
                  key: "title",
                  maxlength: 20,
                  minlength: 1,
                  controller: titleController,
                ),
              ],
              onOk: (result) {
                final newTitle = result['title'];
                widget.onSave?.call({...widget.config, 'title': newTitle});
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    title = widget.config['title'] ?? 'Label';
    final dynamic rawValue = widget.value[selectedKey];
    final String dataType = rawValue?.runtimeType.toString() ?? "unknown";
    final String displayValue = rawValue?.toString() ?? "Null Data";

    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromARGB(255, 76, 175, 79)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                DropdownButtonFormField<String>(
                  // key: ValueKey(dataType),
                  value: selectedKey,
                  decoration: const InputDecoration(
                    labelText: "Select data port",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) {
                    if (val == null) return;
                    setState(() {
                      selectedKey = val;
                    });
                  },
                  items:
                      keys.map((item) {
                        return DropdownMenuItem<String>(
                          value: item.name,
                          child: Text(
                            "${item.name} (${item.type})",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                ),
                const SizedBox(height: 8),
                Text(
                  "Data : ${dataType == "String" ? '"' : ""}${widget.inMenu ? "---" : displayValue}${dataType == "String" ? '"' : ""}",
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          // Các nút resize và setting như cũ
          if (widget.config["lock"] == false) ...[
            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    width += details.delta.dx;
                    height += details.delta.dy;
                    width = width.clamp(200, 300);
                    height = height.clamp(80, 300);
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
        ],
      ),
    );
  }
}
