import 'package:KulBlock/widgets/2IOT&Control/phantu/SCS/SleekCircularSlider.dart';
import 'package:flutter/material.dart';
import 'package:KulBlock/provider/CustomInputField.dart';

// SCSWidget – hiển thị cảm biến
class SCSWidget extends StatefulWidget {
  final Map<String, dynamic> config;
  final dynamic value;
  final Function(Map<String, dynamic>)? onSave;
  final VoidCallback? onDelete;
  final bool inMenu;

  const SCSWidget({
    super.key,
    required this.config,
    required this.value,
    this.onSave,
    this.onDelete,
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
    if (widget.onSave == null && widget.onDelete == null) return;

    final titleController = TextEditingController(text: _titleController.text);
    final unitController = TextEditingController(text: _unitController.text);
    String tempKey = selectedKey;

    final doubleKeys =
        widget.value is Map
            ? widget.value.keys.where((k) => widget.value[k] is double).toList()
            : <String>[];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return CustomBottomSheetContent(
          title: 'Sensor configuration',
          controllers: [
            TextInputField<String>(
              label: "Title",
              controller: titleController,
              key: "title",
              minlength: 1,
              maxlength: 50,
            ),
            TextInputField<String>(
              label: "Unit",
              controller: unitController,
              key: "unit",
              minlength: 1,
              maxlength: 20,
            ),
          ],
          dropdowns: [
            DropdownInputField<String>(
              label: "Select Data Port",
              key: "key",
              items: doubleKeys,
              selectedValue: doubleKeys.contains(tempKey) ? tempKey : "",
            ),
          ],
          errorNotData:
              "No data available to display. Please check the Bluetooth connection!",
          onOk: (data) {
            tempKey = doubleKeys.isEmpty ? "" : data["key"];
            final newConfig = {
              ...widget.config,
              'title': data['title'],
              'unit': data['unit'],
              'key': tempKey,
            };
            selectedKey = tempKey;
            widget.onSave?.call(newConfig);
            Navigator.pop(context);
          },
          onCancel: () => Navigator.pop(context),
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
      Error = "No data available"; // widget.value = {}
    } else {
      sensorValue = 0.0;
      //Trường hợp widget.value = {a=0.0, b=1.0} nhưng selectedKey = c
      Error = "No data on the selected port";
    }
    sensorValue = sensorValue.clamp(0.0, maxValue);

    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromARGB(255, 33, 149, 243)),
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
                      color: const Color.fromARGB(255, 255, 255, 255),
                      alignment: Alignment.center,
                      child: Text(
                        Error,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 244, 67, 54),
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // const SizedBox(height: 8),
                    SCS(
                      value: sensorValue,
                      unit: _unitController.text,
                      bottomLabelText: _titleController.text,
                      trackColor: const Color.fromARGB(255, 255, 193, 7),
                      progressBarColor: const Color.fromARGB(255, 255, 153, 0),
                      min: 0,
                      max: maxValue,
                      trackWidth: 5,
                      progressBarWidth: 20,
                      editingControllerTitle: _titleController,
                      editingControllerUnit: _unitController,
                      onPress: null,
                      onDelete: null,
                      size: Size(width - 10, width - 10),
                    ),
                  ],
                ),
              )
              : SCS(
                value: sensorValue,
                unit: _unitController.text,
                bottomLabelText: _titleController.text,
                trackColor: const Color.fromARGB(255, 255, 193, 7),
                progressBarColor: const Color.fromARGB(255, 255, 153, 0),
                min: 0,
                max: maxValue,
                trackWidth: 5,
                progressBarWidth: 20,
                editingControllerTitle: _titleController,
                editingControllerUnit: _unitController,
                onPress: null,
                onDelete: null,
                size: Size(width - 10, width - 10),
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
