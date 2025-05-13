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
  final void Function() onPress;
  final TextEditingController editingControllerTitle;
  final TextEditingController editingControllerUnit;

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
            title: Text("Custom title & unit"),
            content: Container(
              height: 200,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        // Use Expanded to prevent overflow in Row
                        child: Padding(
                          padding: EdgeInsets.all(5),
                          child: InputSettingSCS(
                            label: "Title",
                            controller: widget.editingControllerTitle,
                          ),
                        ),
                      ),
                      SizedBox(width: 5), // Add spacing between the two columns
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(5),
                          child: InputSettingSCS(
                            label: "Unit",
                            controller: widget.editingControllerUnit,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      child: Text("Lưu"),
                      onPressed: widget.onPress,
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        child: Column(
          children: [
            GestureDetector(
              child: SleekCircularSlider(
                appearance: CircularSliderAppearance(
                  customWidths: CustomSliderWidths(
                    trackWidth: widget.trackWidth,
                    progressBarWidth: widget.progressBarWidth,
                    shadowWidth: 40,
                  ),
                  customColors: CustomSliderColors(
                    trackColor: widget.trackColor,
                    progressBarColor: widget.progressBarColor,
                    shadowColor: Colors.transparent,
                    shadowMaxOpacity: 0, //);
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
                  size: 200.0,
                  animationEnabled: true,
                ),
                min: widget.min,
                max: widget.max,
                initialValue: widget.value,
              ),
              onLongPress: () {
                _dialogCustomSCS();
              },
            ),
          ],
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
