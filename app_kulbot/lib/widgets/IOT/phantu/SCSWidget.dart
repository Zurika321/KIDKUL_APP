import 'package:Kulbot/widgets/IOT/SleekCircularSlider.dart';
import 'package:flutter/material.dart';

// SCSWidget – hiển thị cảm biến
class SCSWidget extends StatefulWidget {
  final Map<String, dynamic> config;
  final dynamic value;
  final Function(Map<String, dynamic>)? onSave;
  final VoidCallback? onDelete;
  final Size size;

  SCSWidget({
    super.key,
    required this.config,
    required this.value,
    this.onSave,
    this.onDelete,
    required this.size,
  });

  @override
  State<SCSWidget> createState() => _SCSWidgetState();
}

class _SCSWidgetState extends State<SCSWidget> {
  late TextEditingController _titleController;
  late TextEditingController _unitController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.config['title']?.toString() ?? 'Temp',
    );
    _unitController = TextEditingController(
      text: widget.config['unit']?.toString() ?? '˚C',
    );
  }

  void _save() {
    final newConfig = {
      ...widget.config,
      'title': _titleController.text,
      'unit': _unitController.text,
    };

    debugPrint("Lưu thông tin: ${newConfig['title']} (${newConfig['unit']})");

    // Gọi callback cập nhật config ở bên ngoài
    widget.onSave?.call(newConfig);

    setState(() {});

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    double sensorValue = 0;
    double maxValue = _unitController.text == "˚C" ? 50.0 : 100.0;
    bool lock = widget.config['lock'] ?? false;

    if (widget.value is Map && widget.value['id1'] != null) {
      sensorValue = widget.value['id1'].toDouble();
    } else if (widget.value is Map && widget.value.isEmpty) {
      sensorValue = 0.0; //giá trị mặc định ở menu
    } else {
      sensorValue = 99.0;
      //nếu bạn thấy nó ra value 99 thì sai ở PhanTu_IOT hoặc IOTScreen nói chung là sai mảng value
      debugPrint("⚠️ [SCSWidget] Giá trị không hợp lệ: ${widget.value}");
    }
    sensorValue = sensorValue.clamp(0.0, maxValue);

    return Container(
      width: widget.size.height,
      height: widget.size.height,
      color: Colors.blue.withAlpha((0.3 * 255).toInt()),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: SCS(
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
              onPress: lock ? null : _save,
              onDelete: lock ? null : widget.onDelete,
              size: widget.size,
            ),
          ),
        ],
      ),
    );
  }
}
