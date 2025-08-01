import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

////////////////////////////////////////////
///////////////////////////////////////////
class ControlModel extends ChangeNotifier {
  final String id;
  final String realId;
  Map<String, dynamic> config;
  Offset relativePosition;
  final bool lock;
  final bool canMove;

  ControlModel({
    required this.id,
    required this.realId,
    required this.config,
    required this.relativePosition,
    required this.lock,
    required this.canMove,
  });

  void updateConfig(Map<String, dynamic> newConfig) {
    config = newConfig;
    notifyListeners();
  }

  void updatePosition(Offset newPos) {
    relativePosition = newPos;
    notifyListeners();
  }

  factory ControlModel.fromJson(Map<String, dynamic> json) {
    return ControlModel(
      id: json['id'],
      realId: json['realId'],
      relativePosition: Offset(
        (json['relativePosition']['dx'] ?? 0).toDouble(),
        (json['relativePosition']['dy'] ?? 0).toDouble(),
      ),
      config: Map<String, dynamic>.from(json['config'] ?? {}),
      lock: json['lock'] ?? false,
      canMove: json['canMove'] ?? true,
    );
  }

  ControlItem toItem() {
    return ControlItem(
      id: id,
      realId: realId,
      relativePosition: relativePosition,
      config: Map<String, dynamic>.from(config),
      lock: lock,
      canMove: canMove,
    );
  }
}

class ControlItem {
  final String id;
  String realId;
  Offset relativePosition;
  Map<String, dynamic> config;
  bool lock;
  bool canMove;

  /// Tọa độ pixel tuyệt đối ban đầu (chỉ sử dụng để convert)
  double? top;
  double? bottom;
  double? left;
  double? right;

  ControlItem({
    required this.id,
    required this.realId,
    this.relativePosition = Offset.zero,
    this.top,
    this.bottom,
    this.left,
    this.right,
    Map<String, dynamic>? config,
    this.lock = false,
    this.canMove = true,
  }) : config = config != null ? Map<String, dynamic>.from(config) : {};

  factory ControlItem.fromJson(Map<String, dynamic> json) {
    return ControlItem(
      id: json['id'],
      realId: json['realId'] ?? json['id'],
      relativePosition: Offset(
        (json['x'] as num).toDouble(),
        (json['y'] as num).toDouble(),
      ),
      config: Map<String, dynamic>.from(json['config'] ?? {}),
      lock: json['lock'] ?? false,
      canMove:
          json['canMove'] ?? true, // <- Thêm dòng này để đọc canMove từ JSON
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'realId': realId,
    'x': relativePosition.dx,
    'y': relativePosition.dy,
    'config': config,
    'lock': lock,
    'canMove': canMove,
  };

  ControlModel toModel() {
    return ControlModel(
      id: id,
      realId: realId,
      relativePosition: relativePosition,
      config: Map<String, dynamic>.from(config),
      lock: lock,
      canMove: canMove,
    );
  }

  ControlItem clone() {
    return ControlItem(
      id: id,
      realId: realId,
      relativePosition: Offset(relativePosition.dx, relativePosition.dy),
      config: Map<String, dynamic>.from(config),
      lock: lock,
      canMove: canMove,
      top: top,
      bottom: bottom,
      left: left,
      right: right,
    );
  }
}

class PlacedControlWidget extends StatelessWidget {
  final ControlModel model;
  final Size screenSize;
  final Size elementSize;
  final bool isEditing;
  final bool shouldLock;
  final bool isEditingLayout;
  final String? tooltipMessage;
  final Widget Function(
    Map<String, dynamic> config,
    void Function(Map<String, dynamic>) onSave,
  )
  buildChild;
  final void Function(Offset newOffset) onDrop;

  const PlacedControlWidget({
    super.key,
    required this.model,
    required this.screenSize,
    required this.elementSize,
    required this.isEditing,
    required this.shouldLock,
    required this.isEditingLayout,
    required this.tooltipMessage,
    required this.buildChild,
    required this.onDrop,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: model,
      builder: (context, _) {
        final offset = Offset(
          model.relativePosition.dx * screenSize.width,
          model.relativePosition.dy * screenSize.height,
        );

        final childWidget = buildChild(model.config, model.updateConfig);

        return DraggableControl(
          key: ValueKey(model.realId),
          initialPosition: offset,
          screenSize: screenSize,
          elementSize: elementSize,
          isEditing: isEditing,
          onDrop:
              (newOffset) => model.updatePosition(
                Offset(
                  newOffset.dx / screenSize.width,
                  newOffset.dy / screenSize.height,
                ),
              ),
          child: Tooltip(
            message: tooltipMessage ?? '',
            preferBelow: false,
            waitDuration: const Duration(milliseconds: 500),
            child:
            // isEditing
            //     ?
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color:
                      isEditingLayout
                          ? isEditing
                              ? (shouldLock
                                  ? const Color.fromARGB(255, 80, 156, 255)
                                  : const Color.fromARGB(255, 83, 255, 64))
                              : (shouldLock
                                  ? const Color.fromARGB(255, 255, 74, 74)
                                  : const Color.fromARGB(255, 255, 68, 221))
                          : const Color.fromARGB(0, 255, 255, 255),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: childWidget,
            ),
            // : childWidget,
          ),
        );
      },
    );
  }
}

class DraggableControl extends StatefulWidget {
  final Widget child;
  final Offset initialPosition;
  final Size screenSize;
  final Size elementSize;
  final Function(Offset) onDrop;
  final bool isEditing;

  const DraggableControl({
    super.key,
    required this.child,
    required this.initialPosition,
    required this.screenSize,
    required this.elementSize,
    required this.onDrop,
    required this.isEditing,
  });

  @override
  State<DraggableControl> createState() => _DraggableControlState();
}

class DragController {
  final ValueNotifier<Offset> currentOffset = ValueNotifier(Offset.zero);

  late Offset startOffset;
  late Size screenSize;
  late Size elementSize;

  void startDrag(Offset initialOffset, Size screenSize, Size elementSize) {
    startOffset = initialOffset;
    this.screenSize = screenSize;
    this.elementSize = elementSize;
    currentOffset.value = initialOffset;
  }

  void updateDrag(Offset delta) {
    final newOffset = Offset(
      (currentOffset.value.dx + delta.dx).clamp(
        0.0,
        screenSize.width - elementSize.width,
      ),
      (currentOffset.value.dy + delta.dy).clamp(
        0.0,
        screenSize.height - elementSize.height,
      ),
    );
    currentOffset.value = newOffset;
  }

  void endDrag() {
    // optional logic
  }
}

class _DraggableControlState extends State<DraggableControl> {
  final DragController dragController = DragController();

  @override
  void initState() {
    super.initState();
    dragController.startDrag(
      widget.initialPosition,
      widget.screenSize,
      widget.elementSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    dragController.screenSize = widget.screenSize;
    dragController.elementSize = widget.elementSize;

    // Clamp lại vị trí nếu cần
    final clampedOffset = Offset(
      dragController.currentOffset.value.dx.clamp(
        0.0,
        dragController.screenSize.width - dragController.elementSize.width,
      ),
      dragController.currentOffset.value.dy.clamp(
        0.0,
        dragController.screenSize.height - dragController.elementSize.height,
      ),
    );
    if (clampedOffset != dragController.currentOffset.value) {
      dragController.currentOffset.value = clampedOffset; // Cập nhật trực tiếp
    }

    return ValueListenableBuilder<Offset>(
      valueListenable: dragController.currentOffset,
      builder: (context, offset, _) {
        return Positioned(
          left: offset.dx,
          top: offset.dy,
          child: GestureDetector(
            onPanUpdate:
                widget.isEditing
                    ? (details) => dragController.updateDrag(details.delta)
                    : null,
            onPanEnd:
                widget.isEditing
                    ? (_) => widget.onDrop(dragController.currentOffset.value)
                    : null,
            child: widget.child,
          ),
        );
      },
    );
  }
}
