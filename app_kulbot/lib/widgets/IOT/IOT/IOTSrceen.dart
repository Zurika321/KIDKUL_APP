import 'package:flutter/material.dart';

class ControlItem {
  final String id;
  Offset relativePosition;
  ControlItem({required this.id, required this.relativePosition});
}

class ControlLayoutProvider {
  // Danh sách các mẫu và layout tương ứng
  static final Map<String, List<ControlItem>> _layouts = {
    'IOT1': [
      ControlItem(id: 'joystick', relativePosition: const Offset(0.1, 0.7)),
      ControlItem(id: 'light', relativePosition: const Offset(0.8, 0.7)),
    ],
    'IOT2': [
      ControlItem(id: 'joystick', relativePosition: const Offset(0.05, 0.75)),
      ControlItem(id: 'light', relativePosition: const Offset(0.7, 0.7)),
      ControlItem(id: 'horn', relativePosition: const Offset(0.85, 0.7)),
    ],
  };

  /// Trả về layout của một mẫu theo `type`
  static List<ControlItem> getLayout(String type) {
    return _layouts[type] ?? [];
  }

  /// Trả về danh sách tên các mẫu (ví dụ: ['IOT1', 'IOT2'])
  static List<String> getAvailableTypes() {
    return _layouts.keys.toList();
  }

  /// Trả về map toàn bộ layout: { 'IOT1': [...], 'IOT2': [...] }
  static Map<String, List<ControlItem>> getAllLayouts() {
    return Map.from(_layouts);
  }

  /// Kiểm tra một `type` có hợp lệ không
  static bool isValidType(String type) {
    return _layouts.containsKey(type);
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
    final adjustedPos = Offset(
      position.dx.clamp(0, screenSize.width * 0.9),
      position.dy.clamp(0, screenSize.height * 0.9),
    );
    final relPos = Offset(
      adjustedPos.dx / screenSize.width,
      adjustedPos.dy / screenSize.height,
    );
    setState(() {
      placedControls.add(ControlItem(id: id, relativePosition: relPos));
      availableControls.remove(id);
    });
  }

  @override
  void initState() {
    super.initState();
    isEditingLayout = widget.type == "new";
    showMenu = isEditingLayout;

    if (widget.type != "new") {
      placedControls.addAll(ControlLayoutProvider.getLayout(widget.type));
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.projectName.isNotEmpty
              ? widget.projectName
              : (widget.type.isNotEmpty ? widget.type : "Untitled"),
        ),
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
                onPanUpdate:
                    isEditingLayout
                        ? (details) {
                          setState(() {
                            final newPos = position + details.delta;
                            control.relativePosition = Offset(
                              newPos.dx.clamp(0, size.width) / size.width,
                              newPos.dy.clamp(0, size.height) / size.height,
                            );
                          });
                        }
                        : null,
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
