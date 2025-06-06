import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class SCS extends StatefulWidget {
  final double value;
  final unit;
  final Color trackColor;
  final Color progressBarColor;
  final double trackWidth;
  final double progressBarWidth;
  final double? shadowWidth;
  final String? bottomLabelText;
  final double min;
  final double max;
  final Color? colorText;
  final void Function()? onPress;
  final TextEditingController editingControllerTitle;
  final TextEditingController editingControllerUnit;
  final VoidCallback? onDelete;
  final Size size;

  const SCS({
    super.key,
    required this.value,
    required this.unit,
    required this.trackColor,
    required this.progressBarColor,
    this.shadowWidth,
    this.bottomLabelText,
    required this.min,
    required this.max,
    required this.trackWidth,
    required this.progressBarWidth,
    required this.onPress,
    this.colorText,
    required this.editingControllerTitle,
    required this.editingControllerUnit,
    this.onDelete,
    required this.size,
  });

  @override
  State<SCS> createState() => _SCSState();
}

class _SCSState extends State<SCS> {
  @override
  void initState() {
    super.initState();
  }

  void _dialogCustomSCS() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            alignment: Alignment.center,
            title: const Text("Tùy chỉnh Title & Unit"),
            content: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight:
                      MediaQuery.of(context).size.height *
                      0.5, // giới hạn chiều cao tối đa
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.onPress != null)
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: InputSettingSCS(
                                label: "Title",
                                controller: widget.editingControllerTitle,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: InputSettingSCS(
                                label: "Unit",
                                controller: widget.editingControllerUnit,
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 20),
                    if (widget.onPress != null || widget.onDelete != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (widget.onDelete != null)
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.of(
                                  context,
                                ).pop(); // đóng dialog trước khi mở xác nhận xoá
                                _showDeleteConfirmDialog();
                              },
                              icon: const Icon(Icons.delete),
                              label: const Text("Xoá"),
                            ),
                          if (widget.onPress != null)
                            ElevatedButton(
                              onPressed: widget.onPress,
                              child: const Text("Lưu"),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  void _showDeleteConfirmDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Xác nhận xoá"),
            content: const Text("Bạn có chắc chắn muốn xoá phần tử này không?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Huỷ"),
              ),
              TextButton(
                onPressed: () {
                  widget.onDelete?.call();
                  Navigator.pop(context); // đóng confirm dialog
                  // Navigator.pop(context); // đóng dialog chính
                },
                child: const Text("Xoá", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size.width,
      height: widget.size.height,
      child: GestureDetector(
        onLongPress: () {
          if (widget.onPress != null || widget.onDelete != null) {
            _dialogCustomSCS();
          }
        },
        child: SleekCircularSlider(
          appearance: CircularSliderAppearance(
            customWidths: CustomSliderWidths(
              trackWidth: widget.trackWidth,
              progressBarWidth: widget.progressBarWidth,
              shadowWidth: widget.shadowWidth ?? 0,
            ),
            customColors: CustomSliderColors(
              trackColor: widget.trackColor,
              progressBarColor: widget.progressBarColor,
              shadowColor: Colors.transparent,
              shadowMaxOpacity: 0,
              shadowStep: 20,
            ),
            infoProperties: InfoProperties(
              bottomLabelStyle: TextStyle(
                color: widget.colorText,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              bottomLabelText: widget.bottomLabelText,
              mainLabelStyle: TextStyle(
                color: widget.colorText,
                fontSize: 25.0,
                fontWeight: FontWeight.w600,
              ),
              modifier: (double val) {
                return '${widget.value} ${widget.unit}';
              },
            ),
            startAngle: 90,
            angleRange: 360,
            size: widget.size.shortestSide, // giới hạn theo cạnh nhỏ
            animationEnabled: true,
          ),
          min: widget.min,
          max: widget.max,
          initialValue: widget.value,
        ),
      ),
    );
  }
}

class InputSettingSCS extends StatefulWidget {
  final TextEditingController? controller;
  final String label;
  const InputSettingSCS({super.key, this.controller, required this.label});

  @override
  State<InputSettingSCS> createState() => _InputSettingSCSState();
}

class _InputSettingSCSState extends State<InputSettingSCS> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label),
          TextField(
            controller: widget.controller,
            decoration: InputDecoration(border: OutlineInputBorder()),
          ),
        ],
      ),
    );
  }
}
