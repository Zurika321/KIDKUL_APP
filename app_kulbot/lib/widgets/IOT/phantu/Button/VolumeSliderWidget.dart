import 'package:Kulbot/widgets/Home/CustomInputField.dart';
import 'package:flutter/material.dart';

class VolumeSliderWidget extends StatefulWidget {
  // final double initialVolume;
  final VoidCallback? onDelete;
  final Map<String, dynamic> config;
  final Function(Map<String, dynamic>)? onSave;
  final Future<void> Function(String)? sendCommand;
  final Map<String, dynamic> value;
  final bool lock;
  final bool inMenu;

  const VolumeSliderWidget({
    super.key,
    // this.initialVolume = 0.5,
    this.onDelete,
    this.lock = false,
    this.inMenu = false,
    required this.config,
    required this.value,
    this.onSave,
    this.sendCommand,
  });

  @override
  State<VolumeSliderWidget> createState() => _VolumeSliderWidgetState();
}

class _VolumeSliderWidgetState extends State<VolumeSliderWidget> {
  late double _volume;
  late double width;
  late double height;

  @override
  void initState() {
    super.initState();
    _volume = widget.value['volume'] ?? 50;
    width = (widget.config['width'] ?? 100).toDouble();
    height = (widget.config['height'] ?? 20).toDouble();
  }

  void _showSettingDialog() {
    showDialog(
      context: context,
      builder:
          (_) => CustomDialog(
            title: "Cài đặt âm lượng",
            dropdowns: [
              DropdownInputField<int>(
                label: "Tốc độ kéo",
                key: "speed",
                items: [100, 50, 25, 20, 10, 5, 4, 2, 1],
                items_name: ["1", "2", "4", "5", "10", "20", "25", "50", "100"],
                selectedValue: widget.config['speed'] ?? 20,
              ),
            ],
            onOk: (data) {
              widget.onSave?.call({...widget.config, 'speed': data['speed']});
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
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          Material(
            color: Colors.transparent,
            child: Row(
              children: [
                const Icon(Icons.volume_down),
                Expanded(
                  child: Slider(
                    value: _volume,
                    min: 0,
                    max: 100,
                    divisions: widget.config["speed"] ?? 20,
                    label: _volume.round().toString(),
                    onChanged:
                        widget.inMenu
                            ? null
                            : (value) {
                              setState(() {
                                _volume = value;
                              });
                              // widget.onSave?.call({
                              //   ...widget.config,
                              //   "volume": value.round(),
                              // });
                              widget.sendCommand?.call(
                                "âm lượng: ${value.round()}",
                              );
                            },
                    onChangeEnd:
                        widget.inMenu
                            ? null
                            : (value) {
                              widget.onSave?.call({
                                ...widget.config,
                                "volume": value.round(),
                              });
                            },
                  ),
                ),
                const Icon(Icons.volume_up),
              ],
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
                    width = width.clamp(100, 600);
                    height = height.clamp(30, 200);
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
                    color: Colors.blue.withOpacity(0.7),
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
                onTap: _showSettingDialog,
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
