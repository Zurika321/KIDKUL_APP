import 'package:flutter/material.dart';

//Mẫu và Class lưu trữ file txt
import 'package:Kulbot/widgets/IOT/Sample%26Data/ControlLayoutProvider.dart'; //Mẫu Layout
import 'package:Kulbot/widgets/IOT/Sample%26Data/IotLayoutProvider.dart'; //Lưu Layout

//class phần tử
import 'package:Kulbot/widgets/IOT/phantu/PhanTu_IOT.dart'; //SCSWidget – hiển thị cảm biến

class ControlItem {
  final String id;
  Offset relativePosition;
  Map<String, dynamic> config;

  ControlItem({
    required this.id,
    required this.relativePosition,
    this.config = const {}, // mặc định rỗng nếu không có
  });

  factory ControlItem.fromJson(Map<String, dynamic> json) {
    return ControlItem(
      id: json['id'],
      relativePosition: Offset(
        (json['x'] as num).toDouble(),
        (json['y'] as num).toDouble(),
      ),
      config: Map<String, dynamic>.from(json['config'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'x': relativePosition.dx,
    'y': relativePosition.dy,
    'config': config,
  };
}

void showSaveDialog(BuildContext context, Function(String) onSave) {
  TextEditingController controller = TextEditingController(text: "United");

  showDialog(
    context: context,
    builder:
        (_) => AlertDialog(
          title: const Text('Nhập tên dự án'),
          content: TextField(controller: controller),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                onSave(controller.text.trim());
                Navigator.pop(context);
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
  );
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
  late String nameProject;
  final List<Map<String, dynamic>> controlGroups = PhanTu_IOT.controlGroups;
  final List<ControlItem> placedControls = [];

  void handleDrop(String id, Offset position, Size screenSize) {
    // if (placedControls.any((item) => item.id == id)) return;

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
    });
  }

  @override
  void initState() {
    super.initState();
    isEditingLayout = widget.type == "new";
    showMenu = isEditingLayout;

    _initLayout(); // Gọi hàm async riêng
  }

  Future<void> _initLayout() async {
    setState(() {
      nameProject =
          widget.projectName.isNotEmpty
              ? widget.projectName
              : (widget.type.isEmpty
                  ? "Untitled"
                  : widget.type == "new"
                  ? "Untitled"
                  : widget.type);
    });
    if (widget.type.isEmpty && widget.projectName.isNotEmpty) {
      final items = await IotLayoutProvider.loadLayout(widget.projectName);
      placedControls.addAll(items);
      setState(() {});
    } else if (widget.type != "new") {
      placedControls.addAll(ControlLayoutProvider.getLayout(widget.type));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(nameProject),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              showSaveDialog(context, (String name) async {
                final savedName = await IotLayoutProvider.saveLayout(
                  name,
                  placedControls,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ Đã lưu layout "$savedName" thành công!'),
                  ),
                );
                setState(() {
                  nameProject = savedName;
                });
              });
            },
          ),

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
          ...placedControls.asMap().entries.map((entry) {
            final index = entry.key;
            final control = entry.value;

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

                            final controlSize = PhanTu_IOT.getControlSize(
                              control.id,
                              size,
                            );

                            control.relativePosition = Offset(
                              (newPos.dx.clamp(
                                    0.0,
                                    size.width - controlSize.width,
                                  )) /
                                  size.width,
                              (newPos.dy.clamp(
                                    0.0,
                                    size.height - controlSize.height,
                                  )) /
                                  size.height,
                            );
                          });
                        }
                        : null,

                child: PhanTu_IOT.getControlWidget(
                  id: control.id,
                  size: size,
                  inMenu: false,
                  config: control.config,
                  onSave: (newConfig) {
                    setState(() {
                      placedControls[index].config = newConfig;
                    });
                  },
                ),
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
                                  group['controls'] as List<dynamic>;

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
                                          controls.map((control) {
                                            final id = control['id'] as String;
                                            final name =
                                                control['name'] as String? ??
                                                id;
                                            final config =
                                                control['config']
                                                    as Map<String, dynamic>?;

                                            return Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Draggable<String>(
                                                  data: id,
                                                  feedback:
                                                      PhanTu_IOT.getControlWidget(
                                                        id: id,
                                                        size: size,
                                                        config: config,
                                                        isPreview: true,
                                                        inMenu: false,
                                                      ),

                                                  onDragStarted:
                                                      () => setState(
                                                        () => showMenu = false,
                                                      ),
                                                  // childWhenDragging: Opacity(
                                                  //   opacity: 0.3,
                                                  //   child: getControlWidget(
                                                  //   id: id,
                                                  //   size: size,
                                                  //   config: config,
                                                  //   ),
                                                  // ),
                                                  child:
                                                      PhanTu_IOT.getControlWidget(
                                                        id: id,
                                                        size: size,
                                                        config: config,
                                                        isPreview: true,
                                                      ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  name,
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
}
