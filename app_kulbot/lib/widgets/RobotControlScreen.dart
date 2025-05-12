import 'package:flutter/material.dart';

class ControlItem {
  final String id;
  Offset relativePosition;
  ControlItem({required this.id, required this.relativePosition});
}

class RobotControlScreen extends StatefulWidget {
  final String projectName;
  final String type;
  const RobotControlScreen(
      {super.key, required this.projectName, required this.type});

  @override
  State<RobotControlScreen> createState() => _RobotControlScreenState();
}

class _RobotControlScreenState extends State<RobotControlScreen> {
  bool isEditingLayout = false;
  bool showMenu = false;
  final List<String> availableControls = ['joystick', 'light', 'horn'];
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
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Điều khiển Robot"),
        actions: [
          IconButton(
            icon: Icon(isEditingLayout ? Icons.check : Icons.edit),
            onPressed: () => setState(() {
              isEditingLayout = !isEditingLayout;
              showMenu = false;
            }),
          ),
        ],
      ),
      body: Stack(
        children: [
          ...placedControls.map((control) {
            final position = Offset(
              control.relativePosition.dx * size.width,
              control.relativePosition.dy * size.height,
            );
            return Positioned(
              left: position.dx,
              top: position.dy,
              child: GestureDetector(
                onPanUpdate: isEditingLayout
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
          if (isEditingLayout && showMenu)
            Positioned(
              top: 80,
              right: 10,
              child: Column(
                children: availableControls.map((id) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      children: [
                        Draggable<String>(
                          data: id,
                          feedback: getControlWidget(id, size,
                              isPreview: true, inMenu: false),
                          childWhenDragging: Opacity(
                            opacity: 0.3,
                            child: getControlWidget(id, size),
                          ),
                          child: getControlWidget(id, size),
                        ),
                        const SizedBox(height: 4),
                        Text(id, style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          if (isEditingLayout)
            DragTarget<String>(
              onAcceptWithDetails: (details) {
                handleDrop(details.data, details.offset, size);
              },
              builder: (context, candidateData, rejectedData) =>
                  const SizedBox.expand(),
            ),
        ],
      ),
      floatingActionButton: isEditingLayout
          ? FloatingActionButton(
              onPressed: () => setState(() => showMenu = !showMenu),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget getControlWidget(String id, Size size,
      {bool isPreview = false, bool inMenu = true}) {
    final double smallSize = size.height * 0.1;
    final double largeSize = size.height * 0.25;

    switch (id) {
      case 'joystick':
        final size = !isPreview && !inMenu ? 80.0 : largeSize;
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.cyanAccent.withOpacity(isPreview ? 0.7 : 1),
            shape: BoxShape.circle,
          ),
          child:
              const Center(child: Text('🎮', style: TextStyle(fontSize: 24))),
        );

      case 'light':
        return LightButtonWidget(
          size: !isPreview && !inMenu
              ? 80.0
              : MediaQuery.of(context).size.height * 0.1,
        );

      case 'horn':
        return HornButtonWidget(
          size: !isPreview && !inMenu
              ? 80.0
              : MediaQuery.of(context).size.height * 0.1,
        );

      default:
        return const SizedBox();
    }
  }
}

// class EditablePositionedWidget extends StatefulWidget {
//   final Offset position;
//   final bool isEditing;
//   final Widget child;
//   final void Function(Offset newPosition) onPositionChanged;
//   final List<ControlItem> Function() getAllControls;

//   const EditablePositionedWidget({
//     super.key,
//     required this.position,
//     required this.isEditing,
//     required this.child,
//     required this.onPositionChanged,
//     required this.getAllControls,
//   });

//   @override
//   State<EditablePositionedWidget> createState() =>
//       _EditablePositionedWidgetState();
// }

// class _EditablePositionedWidgetState extends State<EditablePositionedWidget> {
//   late Offset localPosition;

//   @override
//   void initState() {
//     super.initState();
//     localPosition = widget.position;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;

//     return Positioned(
//       left: localPosition.dx,
//       top: localPosition.dy,
//       child: GestureDetector(
//         onPanUpdate: widget.isEditing
//             ? (details) {
//                 setState(() {
//                   localPosition += details.delta;
//                 });
//               }
//             : null,
//         onPanEnd: widget.isEditing
//             ? (details) {
//                 final RenderBox box = context.findRenderObject() as RenderBox;
//                 final Size widgetSize = box.size;
//                 Offset adjusted = localPosition;

//                 adjusted = Offset(
//                   adjusted.dx.clamp(0.0, size.width - widgetSize.width),
//                   adjusted.dy.clamp(0.0, size.height - widgetSize.height),
//                 );

//                 for (var other in widget.getAllControls().where((e) =>
//                     e.isVisible && e.id != (widget.key as ValueKey).value)) {
//                   final otherPos = Offset(
//                     other.relativePosition.dx * size.width,
//                     other.relativePosition.dy * size.height,
//                   );
//                   final dx = (adjusted.dx - otherPos.dx).abs();
//                   final dy = (adjusted.dy - otherPos.dy).abs();

//                   if (dx < widgetSize.width && dy < widgetSize.height) {
//                     adjusted = widget.position; // revert nếu đè
//                     break;
//                   }
//                 }

//                 setState(() {
//                   localPosition = adjusted;
//                 });
//                 widget.onPositionChanged(adjusted);
//               }
//             : null,
//         child: widget.child,
//       ),
//     );
//   }
// }

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
