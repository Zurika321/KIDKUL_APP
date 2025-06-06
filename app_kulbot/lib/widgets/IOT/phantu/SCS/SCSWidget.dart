import 'package:Kulbot/widgets/IOT/phantu/SCS/SleekCircularSlider.dart';
import 'package:flutter/material.dart';

// SCSWidget – hiển thị cảm biến
class SCSWidget extends StatefulWidget {
  final Map<String, dynamic> config;
  final dynamic value;
  final Function(Map<String, dynamic>)? onSave;
  final VoidCallback? onDelete;
  final Size size;
  final bool inMenu;

  SCSWidget({
    super.key,
    required this.config,
    required this.value,
    this.onSave,
    this.onDelete,
    required this.size,
    required this.inMenu,
  });

  @override
  State<SCSWidget> createState() => _SCSWidgetState();
}

class _SCSWidgetState extends State<SCSWidget> {
  late TextEditingController _titleController;
  late TextEditingController _unitController;
  late String selectedKey;
  late double width;
  late double height;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.config['title']?.toString() ?? 'Temp',
    );
    _unitController = TextEditingController(
      text: widget.config['unit']?.toString() ?? '˚C',
    );
    width = (widget.config['width'] ?? 160).toDouble();
    height = (widget.config['height'] ?? 100).toDouble();

    // Lấy key double đầu tiên nếu chưa có
    final doubleKeys =
        widget.value is Map
            ? widget.value.keys.where((k) => widget.value[k] is double).toList()
            : <String>[];
    selectedKey =
        widget.config['key']?.toString() ??
        (doubleKeys.isNotEmpty ? doubleKeys.first : '');
  }

  void _showEditDialog() {
    final titleController = TextEditingController(text: _titleController.text);
    final unitController = TextEditingController(text: _unitController.text);
    String tempKey = selectedKey;
    final doubleKeys =
        widget.value is Map
            ? widget.value.keys.where((k) => widget.value[k] is double).toList()
            : <String>[];

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Cấu hình cảm biến'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Tiêu đề'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: unitController,
                  decoration: const InputDecoration(labelText: 'Đơn vị'),
                ),
                const SizedBox(height: 10),
                doubleKeys.isEmpty
                    ? const Text(
                      'Không có dữ liệu để hiển thị. Vui lòng kiểm tra kết bluetooth!',
                      style: TextStyle(color: Colors.red),
                    )
                    : DropdownButtonFormField<String>(
                      value: doubleKeys.first,
                      items:
                          doubleKeys
                              .map(
                                (k) =>
                                    DropdownMenuItem(value: k, child: Text(k)),
                              )
                              .toList(),
                      onChanged: (val) {
                        if (val != null) tempKey = val;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Chọn Cổng dữ liệu',
                      ),
                    ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onDelete?.call();
                },
                child: const Text('Xoá', style: TextStyle(color: Colors.red)),
              ),
              ElevatedButton(
                onPressed: () {
                  // setState(() {
                  //   _titleController.text = titleController.text;
                  //   _unitController.text = unitController.text;
                  //   selectedKey = doubleKeys.isEmpty ? "" : tempKey;
                  // });
                  tempKey = doubleKeys.isEmpty ? "" : tempKey;
                  final newConfig = {
                    ...widget.config,
                    'title': titleController.text,
                    'unit': unitController.text,
                    'key': tempKey,
                  };
                  widget.onSave?.call(newConfig);
                  Navigator.pop(context);
                },
                child: const Text('Lưu'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double sensorValue = 0.0;
    double maxValue = _unitController.text == "˚C" ? 50.0 : 100.0;
    String Error = "";

    // Lấy value theo key double đã chọn
    if (widget.inMenu) {
      //trường hợp trong menu,nên không cần widget.value, còn lại kiểm tra
      sensorValue = 0.0;
    } else if (widget.value is Map &&
        selectedKey.isNotEmpty &&
        widget.value[selectedKey] is double) {
      sensorValue = widget.value[selectedKey].toDouble();
    } else if (widget.value is Map && widget.value.isEmpty) {
      sensorValue = 0.0;
      Error = "Không có dữ liệu"; // widget.value = {}
    } else {
      sensorValue = 0.0;
      //Trường hợp widget.value = {a=0.0, b=1.0} nhưng selectedKey = c
      Error = "Cổng hiện tại không có dữ liệu";
    }
    sensorValue = sensorValue.clamp(0.0, maxValue);

    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        // mainAxisSize: MainAxisSize.min,
        children: [
          Error.isNotEmpty
              ? SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      color: Colors.white,
                      alignment: Alignment.center,
                      child: Text(
                        Error,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // const SizedBox(height: 8),
                    SCS(
                      value: sensorValue,
                      unit: _unitController.text,
                      bottomLabelText: _titleController.text,
                      trackColor: Colors.amber,
                      progressBarColor: Colors.orange,
                      min: 0,
                      max: maxValue,
                      trackWidth: 5,
                      progressBarWidth: 20,
                      editingControllerTitle: _titleController,
                      editingControllerUnit: _unitController,
                      onPress: null,
                      onDelete: null,
                      size: widget.size,
                    ),
                  ],
                ),
              )
              : SCS(
                value: sensorValue,
                unit: _unitController.text,
                bottomLabelText: _titleController.text,
                trackColor: Colors.amber,
                progressBarColor: Colors.orange,
                min: 0,
                max: maxValue,
                trackWidth: 5,
                progressBarWidth: 20,
                editingControllerTitle: _titleController,
                editingControllerUnit: _unitController,
                onPress: null,
                onDelete: null,
                size: widget.size,
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
                    width = width.clamp(100, 600);
                    height = height.clamp(100, 600);
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
