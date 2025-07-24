import 'package:flutter/material.dart';
// import 'dart:math';

//Mẫu và Class lưu trữ file txt
import 'package:Kulbot/widgets/Control/Sample%26Data/ControlLayoutProvider.dart'; //Mẫu Layout
//class phần tử
import 'package:Kulbot/widgets/Control/phantu/PhanTu_Control.dart'; //SCSWidget – hiển thị cảm biến

//class dịch vụ
import 'package:Kulbot/service/bluetooth_service.dart'; //bluetooth
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'package:showcaseview/showcaseview.dart';

// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart'; // lấy dữ liệu từ biến trạng thái main.dart
import 'package:Kulbot/provider/provider.dart'; // lấy dữ liệu từ biến trạng thái main.dart
import 'package:Kulbot/l10n/l10n.dart'; // Lấy cờ theo ngôn ngữ
import 'package:Kulbot/l10n/localized_map.dart';

// import 'package:shared_preferences/shared_preferences.dart';

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

class RobotControlScreen extends StatefulWidget {
  final String type;
  final bool checkAvailability;

  const RobotControlScreen({
    super.key,
    required this.type,
    this.checkAvailability = true,
  });

  @override
  State<RobotControlScreen> createState() => _RobotControlScreenState();
}

class _RobotControlScreenState extends State<RobotControlScreen> {
  bool isEditingLayout = false;
  bool showMenu = false;
  final Map<String, Map<String, dynamic>> controlGroups =
      PhanTu_Control.controlGroups;
  final List<ControlItem> placedControls = [];
  final BluetoothService _bluetoothService = BluetoothService();

  String voicetotext = "";

  String connectedDeviceName = "";

  int getPlacedCountById(String id) {
    return placedControls.where((item) => item.id.startsWith(id)).length;
  }

  String generateNewRealId(String id) {
    int i = 1;
    while (true) {
      final candidate = '$id$i';
      final exists = placedControls.any(
        (control) => control.realId == candidate,
      );
      if (!exists) return candidate;
      i++;
    }
  }

  void handleDrop(String id, Offset position, Size screenSize) {
    final currentCount = getPlacedCountById(id);
    final maxCount = PhanTu_Control.getMaxById(id);

    if (currentCount >= maxCount) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Đã đạt số lượng tối đa cho $id')));
      return;
    }

    final adjustedPos = Offset(
      position.dx.clamp(0, screenSize.width * 0.9),
      position.dy.clamp(0, screenSize.height * 0.9),
    );

    final relPos = Offset(
      adjustedPos.dx / screenSize.width,
      adjustedPos.dy / screenSize.height,
    );

    final newRealId = generateNewRealId(id);

    setState(() {
      placedControls.add(
        ControlItem(id: id, realId: newRealId, relativePosition: relPos),
      );
    });
    // for (final controlitem in placedControls) {
    //   print(controlitem.realId.toString());
    // }
  }

  @override
  void initState() {
    super.initState();
    isEditingLayout = widget.type == "new";
    showMenu = isEditingLayout;

    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothService.bluetoothState = state;
      });
    });

    FlutterBluetoothSerial.instance.address.then((address) {
      setState(() {
        _bluetoothService.address = address!;
      });
    });

    FlutterBluetoothSerial.instance.name.then((name) {
      setState(() {
        _bluetoothService.name = name!;
      });
    });

    _bluetoothService.onDeviceConnected = (String deviceName) {
      setState(() {
        connectedDeviceName = "Đã kết nối với $deviceName";
      });
    };

    _bluetoothService.onDeviceDisconnected = () {
      setState(() {
        connectedDeviceName = "Chưa kết nối với robot";
      });
    };

    FlutterBluetoothSerial.instance.onStateChanged().listen((
      BluetoothState state,
    ) {
      setState(() {
        _bluetoothService.bluetoothState = state;
        if (state == BluetoothState.STATE_OFF) {
          connectedDeviceName = "Bluetooth đã tắt";
        } else if (state == BluetoothState.STATE_ON) {
          connectedDeviceName = "Bluetooth đã bật";
        }
      });
    });

    _bluetoothService.requestLocationPermission().then((_) {
      if (widget.checkAvailability) {
        _bluetoothService.startDiscoveryWithTimeout();
      }
    });

    _bluetoothService.getBondedDevices();
    // _checkBluetoothStatus();
    final size =
        WidgetsBinding.instance.window.physicalSize /
        WidgetsBinding.instance.window.devicePixelRatio;
    _initLayout(size);
  }

  // late NavigatorState _navigator;
  // late ScaffoldMessengerState _messenger;

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   _navigator = Navigator.of(context);
  //   _messenger = ScaffoldMessenger.of(context);
  // }

  @override
  void dispose() {
    ShowKeyManager.clear();
    _bluetoothService.stopDiscovery();
    super.dispose();
  }

  Future<void> _initLayout(Size size) async {
    placedControls.addAll(ControlLayoutProvider.getLayout(widget.type, size));
    setState(() {});
  }

  bool get isConnected => (_bluetoothService.connection?.isConnected ?? false);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // final themeNotifier = Provider.of<ThemeNotifier>(context);
    // final isDarkMode = themeNotifier.isDarkMode;

    // final provider = Provider.of<LocaleProvider>(context);
    // var locale = provider.locale ?? Locale('en');

    return ShowCaseWidget(
      builder:
          (context) => Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,

            floatingActionButton:
                isEditingLayout && !showMenu
                    ? FloatingActionButton(
                      onPressed: () => setState(() => showMenu = !showMenu),
                      child: const Icon(Icons.add),
                    )
                    : null,
            body: SafeArea(child: _buildMainStack(size, context)),
          ),
    );
  }

  PreferredSizeWidget buildTopBar(BuildContext context, Locale locale) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(56),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.only(top: 8, right: 8),
          alignment: Alignment.topRight,
          decoration: const BoxDecoration(
            color: Colors.transparent,
            border: Border(bottom: BorderSide(color: Colors.black, width: 2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 8),
              Showcase(
                key: ShowKeyManager.createKey("LanguageSelector"),
                description: "Đây là nút chọn ngôn ngữ",
                child: DropdownButton(
                  value: locale,
                  icon: Container(width: 12),
                  items:
                      L10n.all.map((locale) {
                        final flag = L10n.getflag(locale.languageCode);

                        return DropdownMenuItem(
                          child: Center(
                            child: Text(flag, style: TextStyle(fontSize: 32)),
                          ),
                          value: locale,
                          onTap: () {
                            final provider = Provider.of<LocaleProvider>(
                              context,
                              listen: false,
                            );
                            provider.setLocale(locale);
                          },
                        );
                      }).toList(),
                  onChanged: (_) {},
                ),
              ),
              Showcase(
                key: ShowKeyManager.createKey("Huongdan"),
                description: LocalizedStringGetter.showkey_get(
                  context,
                  "Huongdan",
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.question_mark_rounded,
                    color: Colors.blueAccent,
                  ),
                  onPressed: () {
                    if (!mounted) return;
                    ShowCaseWidget.of(
                      context,
                    ).startShowCase(ShowKeyManager.getAllKeys());
                  },
                ),
              ),
              Showcase(
                key: ShowKeyManager.createKey("TongLeBluetooth"),
                description: LocalizedStringGetter.showkey_get(
                  context,
                  "TongLeBluetooth",
                ),
                child: IconButton(
                  icon: Icon(
                    _bluetoothService.bluetoothState.isEnabled
                        ? (isConnected
                            ? Icons.bluetooth_connected
                            : Icons.bluetooth)
                        : Icons.bluetooth_disabled,
                    color: isConnected ? Colors.greenAccent : Colors.redAccent,
                  ),
                  onPressed: () {
                    _bluetoothService.startDiscoveryWithTimeout();
                    isConnected
                        ? _bluetoothService.connection?.dispose()
                        : _bluetoothService.connectBluetoothDialog(context);
                  },
                ),
              ),
              Showcase(
                key: ShowKeyManager.createKey("EditMode"),
                description: LocalizedStringGetter.showkey_get(
                  context,
                  "EditMode",
                ),
                child: IconButton(
                  icon: Icon(isEditingLayout ? Icons.check : Icons.edit),
                  color: Colors.blueAccent,
                  onPressed: () {
                    setState(() {
                      isEditingLayout = !isEditingLayout;
                      showMenu = false;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  late Map<String, dynamic> value3 = {"data": "chưa có dữ liệu"};
  late String value2 = "";
  late String value1 = "";
  late String valueofid1 = "";
  late String valueofid2 = "";

  Widget _buildMainStack(Size size, BuildContext context) {
    // return StreamBuilder<Map<String, dynamic>>(
    //   stream: _bluetoothService.stream,
    //   builder: (context, snapshot) {
    //     final dynamicData =
    //         (snapshot.data != null)
    //             ? Map<String, dynamic>.fromEntries(
    //               snapshot.data!.entries.map(
    //                 (e) => MapEntry(e.key.toString(), e.value),
    //               ),
    //             )
    //             : <String, dynamic>{};
    //     debugPrint("Dữ liệu động: $dynamicData");
    final provider = Provider.of<LocaleProvider>(context);
    var locale = provider.locale ?? Locale('en');
    return Stack(
      children: [
        Positioned(
          top: 8,
          left: 8,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.blueAccent),
            onPressed: () {
              Navigator.of(context).pop();
            },
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
        ),
        Positioned(top: 0, right: 0, child: buildTopBar(context, locale)),
        StreamBuilder<Map<String, dynamic>>(
          stream: _bluetoothService.stream,
          builder: (context, snapshot) {
            final dynamicData =
                (snapshot.data != null)
                    ? Map<String, dynamic>.fromEntries(
                      snapshot.data!.entries.map(
                        (e) => MapEntry(e.key.toString(), e.value),
                      ),
                    )
                    : <String, dynamic>{};
            // debugPrint("Dữ liệu động: $dynamicData");
            // Các nút đã đặt
            return Stack(
              children: [
                ...placedControls.asMap().entries.map((entry) {
                  final index = entry.key;
                  final control = entry.value;

                  final List<double> sizeInfo =
                      PhanTu_Control.getControlSizeById(control.id);

                  final double xOffset =
                      control.relativePosition.dx * size.width;
                  final double yOffset =
                      control.relativePosition.dy * size.height;

                  final String typeBox = PhanTu_Control.getTypeBoxById(
                    control.id,
                  );

                  double width =
                      control.config["width"] ??
                      ((typeBox == "height" ? size.height : size.width) *
                              sizeInfo[4] +
                          sizeInfo[5]);
                  double height =
                      control.config["height"] ??
                      ((typeBox == "width" ? size.width : size.height) *
                              sizeInfo[6] +
                          sizeInfo[7]);

                  width = width.clamp(30.0, size.width);
                  height = height.clamp(30.0, size.height);

                  final bool canMove = control.canMove && isEditingLayout;
                  final bool shouldLock =
                      control.lock || (!isEditingLayout && !control.lock);

                  final number = int.tryParse(
                    RegExp(r'\d+$').firstMatch(control.realId)?.group(0) ?? '',
                  );

                  String? NoteShowKey =
                      number == 1
                          ? LocalizedStringGetter.showkey_get(
                            context,
                            PhanTu_Control.getNoteShowKey(context, control.id),
                          )
                          : null;
                  // final String title = PhanTu_Control.getTitleById(control.id);

                  final bool havedata = PhanTu_Control.getGetDataById(
                    control.id,
                  );
                  // final bool bluetoothOff =
                  //     _bluetoothService.bluetoothState ==
                  //     BluetoothState.STATE_OFF;
                  // final bool notConnected = !isConnected;

                  Widget childWidget;
                  if (control.id == "ListBoxTester") {
                    childWidget = PhanTu_Control.getControlWidget(
                      id: control.id,
                      size: Size(
                        size.width,
                        size.height - 56.0,
                      ), //-56 là cái bar ở trên
                      inMenu: false,
                      value: {
                        "valueofid1": valueofid1,
                        "valueofid2": valueofid2,
                        "value1": value1,
                        "value2": value2,
                        "value3": value3,
                      },
                      config: control.config,
                      NoteshowKey: NoteShowKey,
                      lock: shouldLock,
                      onSave: (newConfig) {
                        setState(() {
                          valueofid2 = "${control.id} - ${control.realId}";
                          value3 = newConfig;
                          placedControls[index].config = newConfig;
                        });
                      },
                      onDelete: () {
                        setState(() {
                          placedControls.removeAt(index);
                        });
                      },
                    );
                  } else if (control.id == "ListBox") {
                    childWidget = PhanTu_Control.getControlWidget(
                      id: control.id,
                      size: Size(
                        size.width,
                        size.height - 56.0,
                      ), //-56 là cái bar ở trên
                      inMenu: false,
                      value: {
                        "data":
                            connectedDeviceName.isEmpty
                                ? "Vui lòng bât bluetooth!"
                                : connectedDeviceName,
                      },
                      config: control.config,
                      NoteshowKey: NoteShowKey,
                      lock: shouldLock,
                      onSave: (newConfig) {
                        setState(() {
                          if (placedControls.any(
                            (item) => item.id == 'ListBoxTester',
                          )) {
                            valueofid2 = "${control.id} - ${control.realId}";
                            value3 = newConfig;
                          }
                          placedControls[index].config = newConfig;
                        });
                      },
                      onDelete: () {
                        setState(() {
                          placedControls.removeAt(index);
                        });
                      },
                    );
                  } else {
                    childWidget = PhanTu_Control.getControlWidget(
                      id: control.id,
                      size: Size(
                        size.width,
                        size.height - 56.0,
                      ), //-56 là cái bar ở trên
                      inMenu: false,
                      value: havedata ? dynamicData : null,
                      config: control.config,
                      NoteshowKey: NoteShowKey,
                      lock: shouldLock,
                      sendCommand: (msg) async {
                        if (placedControls.any(
                          (item) => item.id == 'ListBoxTester',
                        )) {
                          setState(() {
                            valueofid1 = "${control.id} - ${control.realId}";
                            value1 = msg;
                          });
                        }

                        if (connectedDeviceName != "Chưa kết nối với robot") {
                          _bluetoothService.sendMessage(msg);
                          await Future.delayed(
                            const Duration(milliseconds: 100),
                          );
                        }
                      },
                      onSave: (newConfig) {
                        setState(() {
                          if (placedControls.any(
                            (item) => item.id == 'ListBoxTester',
                          )) {
                            valueofid2 = "${control.id} - ${control.realId}";
                            value3 = newConfig;
                          }

                          placedControls[index].config = newConfig;
                        });
                      },
                      VoiceTextToCommand:
                          control.id == "mic"
                              ? (String msg) async {
                                // if (msg.isNotEmpty) {
                                //   debugPrint("Gửi lệnh qua bluetooth: $msg");
                                // } else {
                                //   debugPrint("Lệnh rỗng, không gửi qua bluetooth.");
                                // }
                                if (placedControls.any(
                                  (item) => item.id == 'ListBoxTester',
                                )) {
                                  setState(() {
                                    value2 = msg;
                                  });
                                }
                              }
                              : null,
                      onDelete: () {
                        setState(() {
                          placedControls.removeAt(index);
                        });
                      },
                    );
                  }

                  return DraggableControl(
                    key: ValueKey(control.realId),
                    initialPosition: Offset(xOffset, yOffset),
                    screenSize: size,
                    elementSize: Size(width, height),
                    isEditing: canMove,
                    onDrop: (newOffset) {
                      setState(() {
                        control.relativePosition = Offset(
                          newOffset.dx / size.width,
                          newOffset.dy / size.height,
                        );
                      });
                    },
                    child: childWidget,
                  );
                }),
              ],
            );
          },
        ),

        // Màn che + Menu bên phải
        if (isEditingLayout)
          Stack(
            children: [
              // Nền mờ để tắt menu khi nhấn ra ngoài
              if (showMenu)
                GestureDetector(
                  onTap: () => setState(() => showMenu = false),
                  child: Container(color: Colors.black.withAlpha(77)),
                ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                top: 0,
                bottom: 0,
                right: showMenu ? 0 : -250,
                width: 250,
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  padding: const EdgeInsets.all(12),
                  child: SingleChildScrollView(
                    child: Builder(
                      builder: (_) {
                        // Gom các control theo title
                        final Map<String, List<Map<String, dynamic>>>
                        groupedControls = {};
                        controlGroups.forEach((id, control) {
                          final title = control['title'] ?? '';
                          groupedControls.putIfAbsent(title, () => []).add({
                            ...control,
                            'id': id,
                          });
                        });

                        List<Widget> widgets = [];
                        groupedControls.forEach((title, controls) {
                          widgets.add(
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title == "jt"
                                        ? LocalizedStringGetter.Control_get(
                                          context,
                                          title,
                                        )
                                        : LocalizedStringGetter.IOT_get(
                                          context,
                                          title,
                                        ),
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
                                          final id = control['id'];
                                          final name = control['name'] ?? id;
                                          final configRaw = control['config'];
                                          final config =
                                              configRaw == null
                                                  ? <String, dynamic>{}
                                                  : Map<String, dynamic>.from(
                                                    configRaw,
                                                  );

                                          return Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              LongPressDraggable<String>(
                                                // hoặc Draggable<String>( nếu muốn chạm vào là kéo lun
                                                data: id,
                                                feedback:
                                                    PhanTu_Control.getControlWidget(
                                                      id: id,
                                                      size: size,
                                                      config: config,
                                                      isPreview: true,
                                                      inMenu: true,
                                                      lock: true,
                                                    ),
                                                onDragStarted:
                                                    () => setState(
                                                      () => showMenu = false,
                                                    ),
                                                child: AbsorbPointer(
                                                  absorbing: true,
                                                  child:
                                                      PhanTu_Control.getControlWidget(
                                                        id: id,
                                                        size: size,
                                                        config: config,
                                                        isPreview: true,
                                                        inMenu: true,
                                                        lock: true,
                                                      ),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                (name.contains("jt")
                                                    ? LocalizedStringGetter.Control_get(
                                                      context,
                                                      name,
                                                    )
                                                    : LocalizedStringGetter.IOT_get(
                                                      context,
                                                      name,
                                                    )),
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
                            ),
                          );
                        });

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: widgets,
                        );
                      },
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
    );
  }

  //,
  //   );
  // }
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
