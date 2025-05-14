import 'package:Kulbot/widgets/IOT/SleekCircularSlider.dart';
import 'package:flutter/material.dart';

// SCSWidget – hiển thị cảm biến
class SCSWidget extends StatefulWidget {
  final Map<String, dynamic> config;
  final Function(Map<String, dynamic>)? onSave;

  const SCSWidget({super.key, required this.config, this.onSave});

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

    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double value = widget.config['value']?.toDouble() ?? 0;

    return SCS(
      value: value,
      unit: _unitController.text,
      trackColor: Colors.amber,
      progressBarColor: Colors.orange,
      min: 0,
      max: 100,
      trackWidth: 5,
      progressBarWidth: 20,
      bottomLabelText: _titleController.text,
      editingControllerTitle: _titleController,
      editingControllerUnit: _unitController,
      onPress: _save,
    );
  }
}

// Row(
//   children: [
//     Expanded(
//       child: SCSWidget(
//         value: snapshot.data?['receivedValue1'] ?? 0.0,
//         unit: SCS_dv_1.isEmpty ? '˚C' : SCS_dv_1,
//         title: SCS_title_1.isEmpty ? 'Temp 1' : SCS_title_1,
//         editingControllerTitle: _editingSCS_title_1,
//         editingControllerUnit: _editingSCS_dv_1,
//         onPress: () {
//           _saveSettings();
//           Navigator.pop(context);
//           _delayedLoadSettings();
//         },
//       ),
//     ),
//     // Widget thứ hai tương tự
//   ],
// ),
