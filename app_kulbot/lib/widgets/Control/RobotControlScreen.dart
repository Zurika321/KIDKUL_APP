import 'package:flutter/material.dart';

class ControlItem {
  final String id;
  Offset relativePosition;
  final Size size;
  final double padding;

  ControlItem({
    required this.id,
    required this.relativePosition,
    required this.size,
    this.padding = 10,
  });

  /// Tính toán vị trí thực (absolute) dựa theo kích thước màn hình
  Offset getAbsolutePosition(Size screenSize) {
    return Offset(
      relativePosition.dx * screenSize.width,
      relativePosition.dy * screenSize.height,
    );
  }

  /// Cập nhật vị trí theo absolute (pixel), sau đó chuyển lại thành relative
  void setAbsolutePosition(Offset abs, Size screenSize) {
    relativePosition = Offset(
      abs.dx / screenSize.width,
      abs.dy / screenSize.height,
    );
  }

  /// Tạo widget Rectangle tương ứng với control (phục vụ kiểm tra va chạm)
  Rect getRect(Size screenSize) {
    final abs = getAbsolutePosition(screenSize);
    return Rect.fromLTWH(abs.dx, abs.dy, size.width, size.height);
  }
}

class RobotControlScreen extends StatefulWidget {
  final String projectName;
  final String type;
  const RobotControlScreen({
    super.key,
    required this.projectName,
    required this.type,
  });

  @override
  State<RobotControlScreen> createState() => _RobotControlScreenState();
}

class _RobotControlScreenState extends State<RobotControlScreen> {
  bool isEditingLayout = false;
  bool showMenu = false;
  final List<String> availableControls = ['joystick', 'light', 'horn'];
  final List<Map<String, dynamic>> controlGroups = [
    {
      'title': 'Joystick',
      'controls': ['joystick'],
    },
    {
      'title': 'Các nút điều khiển',
      'controls': ['light', 'horn'],
    },
  ];
  final List<ControlItem> placedControls = [];

  void handleDrop(String id, Offset position, Size screenSize) {
    final baseSize =
        id == 'joystick' ? screenSize.height * 0.25 : screenSize.height * 0.1;

    final controlSize = Size(baseSize, baseSize);
    final adjustedPos = Offset(
      position.dx.clamp(0, screenSize.width - baseSize),
      position.dy.clamp(0, screenSize.height - baseSize),
    );

    final relPos = Offset(
      adjustedPos.dx / screenSize.width,
      adjustedPos.dy / screenSize.height,
    );

    setState(() {
      placedControls.add(
        ControlItem(id: id, relativePosition: relPos, size: controlSize),
      );
      availableControls.remove(id);
    });
  }

  void _adjustControlPosition(ControlItem control, Size screenSize) {
    double x = control.getAbsolutePosition(screenSize).dx;
    double y = control.getAbsolutePosition(screenSize).dy;

    // Không cho ra ngoài màn hình
    x = x.clamp(
      control.padding,
      screenSize.width - control.size.width - control.padding,
    );
    y = y.clamp(
      control.padding,
      screenSize.height - control.size.height * 1 - control.padding,
    );
    Offset corrected = Offset(x, y);

    for (final other in placedControls) {
      if (other == control) continue;

      final rect1 = Rect.fromLTWH(
        corrected.dx,
        corrected.dy,
        control.size.width,
        control.size.height,
      );
      final rect2 = other.getRect(screenSize);

      if (rect1.overlaps(rect2)) {
        corrected = Offset(
          (corrected.dx + control.size.width + control.padding).clamp(
            control.padding,
            screenSize.width - control.size.width,
          ),
          (corrected.dy + control.size.height + control.padding).clamp(
            control.padding,
            screenSize.height - control.size.height,
          ),
        );
      }
    }

    control.setAbsolutePosition(corrected, screenSize);
  }

  @override
  void initState() {
    super.initState();
    isEditingLayout = widget.type == "new";
    showMenu = isEditingLayout;
  }

  Offset? _dragStart;
  Offset? _controlStart;
  String? _draggingControlId;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Điều khiển Robot"),
        actions: [
          IconButton(
            icon: Icon(isEditingLayout ? Icons.check : Icons.edit),
            onPressed:
                () => setState(() {
                  isEditingLayout = !isEditingLayout;
                  showMenu = false;
                }),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Các nút đã đặt
          ...placedControls.map((control) {
            final position = Offset(
              control.relativePosition.dx * size.width,
              control.relativePosition.dy * size.height,
            );
            return Positioned(
              left: position.dx,
              top: position.dy,
              child: GestureDetector(
                onPanStart:
                    isEditingLayout
                        ? (details) {
                          _dragStart = details.globalPosition;
                          _controlStart = position;
                          _draggingControlId = control.id;
                        }
                        : null,
                onPanUpdate:
                    isEditingLayout
                        ? (details) {
                          if (_draggingControlId != control.id) return;
                          final dragOffset =
                              details.globalPosition - _dragStart!;
                          final newPos = _controlStart! + dragOffset;
                          setState(() {
                            control.relativePosition = Offset(
                              newPos.dx.clamp(0, size.width) / size.width,
                              newPos.dy.clamp(0, size.height) / size.height,
                            );
                          });
                        }
                        : null,
                onPanEnd:
                    isEditingLayout
                        ? (_) {
                          _dragStart = null;
                          _controlStart = null;
                          _draggingControlId = null;
                          setState(() {
                            _adjustControlPosition(control, size);
                          });
                        }
                        : null,
                // child: GestureDetector(
                //   onPanUpdate: isEditingLayout
                //       ? (details) {
                //           setState(() {
                //             final newPos = position + details.delta;
                //             control.relativePosition = Offset(
                //               newPos.dx.clamp(0, size.width) / size.width,
                //               newPos.dy.clamp(0, size.height) / size.height,
                //             );
                //           });
                //         }
                //       : null,
                child: getControlWidget(control.id, size, inMenu: false),
              ),
            );
          }),

          // Màn che + Menu bên phải
          if (isEditingLayout && showMenu)
            Stack(
              children: [
                // Lớp nền đen mờ
                GestureDetector(
                  onTap: () => setState(() => showMenu = false),
                  child: Container(color: Colors.black.withOpacity(0.3)),
                ),

                // Menu trượt ra từ phải
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  top: 0,
                  bottom: 0,
                  right: 0,
                  width: 250,
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(12),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            controlGroups.map((group) {
                              final title = group['title'] as String;
                              final controls =
                                  group['controls'] as List<String>;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 12,
                                      runSpacing: 12,
                                      children:
                                          controls.map((id) {
                                            return Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Draggable<String>(
                                                  data: id,
                                                  feedback: getControlWidget(
                                                    id,
                                                    size,
                                                    isPreview: true,
                                                    inMenu: false,
                                                  ),
                                                  onDragStarted: () {
                                                    setState(
                                                      () => showMenu = false,
                                                    );
                                                  },
                                                  childWhenDragging: Opacity(
                                                    opacity: 0.3,
                                                    child: getControlWidget(
                                                      id,
                                                      size,
                                                    ),
                                                  ),
                                                  child: getControlWidget(
                                                    id,
                                                    size,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  id,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            );
                                          }).toList(),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),

          // Drag target để thả button
          if (isEditingLayout)
            DragTarget<String>(
              onAcceptWithDetails: (details) {
                handleDrop(details.data, details.offset, size);
                setState(() => showMenu = true);
              },
              builder:
                  (context, candidateData, rejectedData) =>
                      const SizedBox.expand(),
            ),
        ],
      ),
      floatingActionButton:
          isEditingLayout
              ? FloatingActionButton(
                onPressed: () => setState(() => showMenu = !showMenu),
                child: const Icon(Icons.add),
              )
              : null,
    );
  }

  Widget getControlWidget(
    String id,
    Size size, {
    bool isPreview = false,
    bool inMenu = true,
  }) {
    final bool isSmall = isPreview || inMenu;

    switch (id) {
      case 'joystick':
        final widgetSize = isSmall ? 80.0 : (size.height * 0.25);
        return Container(
          width: widgetSize,
          height: widgetSize,
          decoration: BoxDecoration(
            color: Colors.cyanAccent.withOpacity(isPreview ? 0.7 : 1),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text('🎮', style: TextStyle(fontSize: 24)),
          ),
        );

      case 'light':
        return LightButtonWidget(size: isSmall ? 80.0 : size.height * 0.1);

      case 'horn':
        return HornButtonWidget(size: isSmall ? 80.0 : size.height * 0.1);

      default:
        return const SizedBox();
    }
  }
}

class LightButtonWidget extends StatefulWidget {
  final double size;

  const LightButtonWidget({super.key, required this.size});

  @override
  State<LightButtonWidget> createState() => _LightButtonWidgetState();
}

class _LightButtonWidgetState extends State<LightButtonWidget> {
  bool isOn = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isOn = !isOn;
        });
        // Gửi lệnh tới robot nếu cần
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: isOn ? Colors.yellowAccent : Colors.cyanAccent,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.lightbulb_outline, color: Colors.black),
      ),
    );
  }
}

class HornButtonWidget extends StatelessWidget {
  final double size;
  const HornButtonWidget({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.orangeAccent,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.volume_up, color: Colors.white),
    );
  }
}
