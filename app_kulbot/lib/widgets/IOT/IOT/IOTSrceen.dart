import 'package:flutter/material.dart';
import 'dart:math';

//Mẫu và Class lưu trữ file txt
import 'package:Kulbot/widgets/IOT/Sample%26Data/ControlLayoutProvider.dart'; //Mẫu Layout
import 'package:Kulbot/widgets/IOT/Sample%26Data/IotLayoutProvider.dart'; //Lưu Layout

//class phần tử
import 'package:Kulbot/widgets/IOT/phantu/PhanTu_IOT.dart'; //SCSWidget – hiển thị cảm biến

//class dịch vụ
import 'package:Kulbot/service/bluetooth_service.dart'; //bluetooth
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

// import 'package:Kulbot/widgets/IOT/Bluetooth/bluetooth_device_dialog.dart';
// import 'package:Kulbot/widgets/IOT/Bluetooth/bluetooth_service.dart'
// as bt_service;

import 'package:showcaseview/showcaseview.dart';

import 'package:provider/provider.dart'; // lấy dữ liệu từ biến trạng thái main.dart
import 'package:Kulbot/provider/provider.dart'; // lấy dữ liệu từ biến trạng thái main.dart
import 'package:Kulbot/l10n/l10n.dart'; // ngôn ngữ
import 'package:Kulbot/widgets/IOT/Sample&Data/ControlValueManager.dart'; // quản lý key của showcase

import 'package:Kulbot/widgets/IOT/phantu/listbox.dart'; // danh sách thiết bị

// class ControlValueManager {
//   static final Map<String, dynamic> values = {};

//   static dynamic getValue(String id) => values[id];

//   static void setValue(String id, dynamic newValue) => values[id] = newValue;

//   static bool hasValue(String id) => values.containsKey(id);

//   static void clearAll() {
//     values.clear();
//   }

//   static void removeValuesForRealId(String realId) {
//     values.removeWhere((key, _) => key.startsWith('$realId\_'));
//   }
// }

class ControlItem {
  final String id; // ID gốc để tạo widget (VD: "horn")
  String realId; // ID thực tế để phân biệt giữa nhiều bản sao (VD: "horn1")
  Offset relativePosition;
  Map<String, dynamic> config;
  bool lock;
  bool canMove;

  ControlItem({
    required this.id,
    required this.realId,
    required this.relativePosition,
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
    'canMove': canMove, // <- Thêm dòng này để ghi canMove ra JSON
  };

  ControlItem clone() {
    return ControlItem(
      id: id,
      realId: realId,
      relativePosition: Offset(relativePosition.dx, relativePosition.dy),
      config: Map<String, dynamic>.from(config),
      lock: lock,
      canMove: canMove, // <- Clone luôn canMove
    );
  }
}

void showSaveDialog(
  BuildContext context, {
  required Function(String) onSaveNew,
  required Function(String) onOverwrite,
}) async {
  final savedLayouts = await IotLayoutProvider.getSavedLayoutNames();
  final TextEditingController controller = TextEditingController(
    text: "United",
  );

  showDialog(
    context: context,
    builder: (_) {
      return DefaultTabController(
        length: 2,
        child: AlertDialog(
          title: const Text('Lưu dự án'),
          content: SizedBox(
            width: 400,
            height: 300,
            child: Column(
              children: [
                const TabBar(tabs: [Tab(text: 'Lưu mới'), Tab(text: 'Ghi đè')]),
                Expanded(
                  child: TabBarView(
                    children: [
                      // Tab 1: Lưu mới
                      Column(
                        children: [
                          TextField(
                            controller: controller,
                            decoration: const InputDecoration(
                              labelText: "Tên dự án",
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              final name = controller.text.trim();
                              if (name.isNotEmpty) {
                                onSaveNew(name);
                                Navigator.of(context).pop();
                              }
                            },
                            child: const Text('Lưu'),
                          ),
                        ],
                      ),
                      // Tab 2: Ghi đè
                      ListView.builder(
                        itemCount: savedLayouts.length,
                        itemBuilder: (context, index) {
                          final name = savedLayouts[index];
                          return ListTile(
                            title: Text(name),
                            trailing: IconButton(
                              icon: const Icon(Icons.save),
                              onPressed: () {
                                // Xác nhận trước khi ghi đè
                                showDialog(
                                  context: context,
                                  builder:
                                      (_) => AlertDialog(
                                        title: const Text("Xác nhận"),
                                        content: Text('Ghi đè dự án "$name"?'),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () =>
                                                    Navigator.of(context).pop(),
                                            child: const Text("Huỷ"),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(
                                                context,
                                              ).pop(); // xác nhận
                                              Navigator.of(
                                                context,
                                              ).pop(); // dialog chính
                                              onOverwrite(name);
                                            },
                                            child: const Text("Xác nhận"),
                                          ),
                                        ],
                                      ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Đóng"),
            ),
          ],
        ),
      );
    },
  );
}

class RobotControlScreen extends StatefulWidget {
  final String projectName;
  final String type;
  final bool checkAvailability;

  const RobotControlScreen({
    super.key,
    required this.projectName,
    required this.type,
    this.checkAvailability = true,
  });

  @override
  State<RobotControlScreen> createState() => _RobotControlScreenState();
}

class _RobotControlScreenState extends State<RobotControlScreen> {
  bool isEditingLayout = false;
  bool showMenu = false;
  late String nameProject;
  final Map<String, Map<String, dynamic>> controlGroups =
      PhanTu_IOT.controlGroups;
  final List<ControlItem> placedControls = [];
  final BluetoothService _bluetoothService = BluetoothService();

  bool _isListening = false;
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
    final maxCount = PhanTu_IOT.getMaxById(id);

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
    _initLayout();

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
      });
    });

    _bluetoothService.requestLocationPermission().then((_) {
      if (widget.checkAvailability) {
        _bluetoothService.startDiscoveryWithTimeout();
      }
    });

    _bluetoothService.getBondedDevices();
    _checkBluetoothStatus();
  }

  @override
  void dispose() {
    ControlValueManager.clearAll();
    ShowKeyManager.clear();
    super.dispose();
  }

  void _checkBluetoothStatus() {
    _bluetoothService.flutterBluetoothSerial.state.then((state) {
      setState(() {
        _bluetoothService.bluetoothState = state;
      });
    });
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
      if (items.isEmpty) {
        // Nếu không có layout nào được tải, thông báo cho người dùng
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Không tìm thấy dữ liệu từ project: ${widget.projectName}.',
            ),
          ),
        );
      } else {
        placedControls.addAll(items);
        setState(() {});
      }
    } else if (widget.type != "new") {
      placedControls.addAll(ControlLayoutProvider.getLayout(widget.type));
      setState(() {});
    }
  }

  final String _moveForwardCommand = "";
  final String _moveBackwardCommand = "";
  final String _moveTurnLeftCommand = "";
  final String _moveTurnRightCommand = "";
  final String _moveStopCommand = "";
  bool get isConnected => (_bluetoothService.connection?.isConnected ?? false);

  void moveMotor() {
    if (!isConnected) return;
    final voice = voicetotext.toLowerCase();
    if (voice.contains('tiến') ||
        voice.contains('lên') ||
        voice.contains('forward')) {
      _bluetoothService.sendMessage(_moveForwardCommand);
    } else if (voice.contains('lui') ||
        voice.contains('lùi') ||
        voice.contains('back')) {
      _bluetoothService.sendMessage(_moveBackwardCommand);
    } else if (voice.contains('trái') || voice.contains('left')) {
      _bluetoothService.sendMessage(_moveTurnLeftCommand);
    } else if (voice.contains('phải') || voice.contains('right')) {
      _bluetoothService.sendMessage(_moveTurnRightCommand);
    } else if (voice.contains('dừng') || voice.contains('stop')) {
      _bluetoothService.sendMessage(_moveStopCommand);
    } else {
      print("Không nhận diện được lệnh thoại: $voicetotext");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;

    return ShowCaseWidget(
      builder:
          (context) => Scaffold(
            backgroundColor: const Color.fromARGB(255, 221, 221, 228),
            appBar: _buildAppBar(context, isDarkMode),
            floatingActionButton:
                isEditingLayout
                    ? FloatingActionButton(
                      onPressed: () => setState(() => showMenu = !showMenu),
                      child: const Icon(Icons.add),
                    )
                    : null,
            body: SafeArea(child: _buildMainStack(size)),
          ),
    );
  }

  // appBar: AppBar(
  //   title: Text(nameProject),
  //   actions: [
  //     IconButton(
  //       icon: Icon(isEditingLayout ? Icons.check : Icons.edit),
  //       onPressed:
  //           () => setState(() {
  //             final realId = "SCSWidget1_temp";
  //             final datatemp1 = ControlValueManager.getValue(realId);
  //             if (datatemp1 is num) {
  //               ControlValueManager.setValue(realId, datatemp1 + 1);
  //               debugPrint("✅ $realId = ${datatemp1 + 1}");
  //             }
  //           }),
  //     ),

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDarkMode) {
    final provider = Provider.of<LocaleProvider>(context);
    var locale = provider.locale ?? Locale('en');

    return AppBar(
      backgroundColor: isDarkMode ? Colors.black45 : Colors.blueGrey[900],
      title: Row(
        children: [
          Icon(Icons.rocket, color: Colors.cyanAccent),
          SizedBox(width: 10),
          Text(
            nameProject,
            style: TextStyle(
              color: Colors.cyanAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.cyanAccent),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        // Showcase(
        //   key: ShowKeyManager.createKey("LanguageSelector"),
        //   description: "Đây là nút chọn ngôn ngữ",
        //   child: DropdownButton(
        //     value: locale,
        //     icon: Container(width: 12),
        //     items:
        //         L10n.all.map((locale) {
        //           final flag = L10n.getflag(locale.languageCode);

        //           return DropdownMenuItem(
        //             child: Center(
        //               child: Text(flag, style: TextStyle(fontSize: 32)),
        //             ),
        //             value: locale,
        //             onTap: () {
        //               final provider = Provider.of<LocaleProvider>(
        //                 context,
        //                 listen: false,
        //               );
        //               provider.setLocale(locale);
        //             },
        //           );
        //         }).toList(),
        //     onChanged: (_) {},
        //   ),
        // ),
        // Showcase(
        //   key: ShowKeyManager.createKey("ScanQRcode"),
        //   description: 'Đây là nút quét mã QR để điều khiển robot',
        //   child: IconButton(
        //     icon: Icon(
        //       Icons.qr_code_scanner_outlined,
        //       color: Colors.cyanAccent,
        //     ),
        //     onPressed: scanQRcodeNormal,
        //   ),
        // ),
        Showcase(
          key: ShowKeyManager.createKey("TongLeBluetooth"),
          description: 'Bật / tắt Bluetooth và kết nối robot',
          child: IconButton(
            icon: Icon(
              _bluetoothService.bluetoothState.isEnabled
                  ? (isConnected ? Icons.bluetooth_connected : Icons.bluetooth)
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
        IconButton(
          icon: const Icon(Icons.cable, color: Colors.cyanAccent),
          onPressed: () {
            setState(() {
              const String name = "CustomChart1_data";
              if (ControlValueManager.hasValue(name)) {
                final value = ControlValueManager.getValue(name);
                if (value is Map<String, List<double>>) {
                  final random = Random();
                  final updatedValue = {
                    "data1": [
                      ...?value["data1"],
                      double.parse(
                        (random.nextDouble() * 100).toStringAsFixed(1),
                      ),
                    ],
                    "data2": [
                      ...?value["data2"],
                      double.parse(
                        (random.nextDouble() * 100).toStringAsFixed(1),
                      ),
                    ],
                  };
                  ControlValueManager.setValue(name, updatedValue);
                }
              }
            });
          },
        ),
        Showcase(
          key: ShowKeyManager.createKey("Huongdan"),
          description: 'Đây là nút hướng dẫn sử dụng điều khiển robot',
          child: IconButton(
            icon: Icon(Icons.question_mark_rounded, color: Colors.cyanAccent),
            onPressed: () {
              ShowCaseWidget.of(
                context,
              ).startShowCase(ShowKeyManager.getAllKeys());
            },
          ),
        ),
        Showcase(
          key: ShowKeyManager.createKey("SaveProjectIOT"),
          description: 'Đây là nút save project',
          child: IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              showSaveDialog(
                context,
                onSaveNew: (String name) async {
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
                },
                onOverwrite: (String name) async {
                  final success = await IotLayoutProvider.updateLayout(
                    name,
                    placedControls,
                  );
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('✅ Đã ghi đè layout "$name" thành công!'),
                      ),
                    );
                    setState(() {
                      nameProject = name;
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('❌ Không thể ghi đè layout "$name"!'),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ),
        Showcase(
          key: ShowKeyManager.createKey("EditMode"),
          description: "Bật/tắt chế độ edit",
          child: IconButton(
            icon: Icon(isEditingLayout ? Icons.check : Icons.edit),
            color: const Color.fromARGB(255, 0, 238, 255),
            onPressed: () {
              setState(() {
                isEditingLayout = !isEditingLayout;
                showMenu = false;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMainStack(Size size) {
    return StreamBuilder<Map<String, dynamic>>(
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
        debugPrint("Dữ liệu động: $dynamicData");
        return Stack(
          children: [
            // Các nút đã đặt
            ...placedControls.asMap().entries.map((entry) {
              final index = entry.key;
              final control = entry.value;

              final List<double> sizeInfo = PhanTu_IOT.getControlSizeById(
                control.id,
              );

              final double xOffset = control.relativePosition.dx * size.width;
              final double yOffset = control.relativePosition.dy * size.height;

              final String typeBox = PhanTu_IOT.getTypeBoxById(control.id);

              double width =
                  (typeBox == "height" ? size.height : size.width) *
                      sizeInfo[4] +
                  sizeInfo[5];
              double height =
                  (typeBox == "width" ? size.width : size.height) *
                      sizeInfo[6] +
                  sizeInfo[7];

              width = width.clamp(30.0, size.width);
              height = height.clamp(30.0, size.height);

              final bool canMove = control.canMove && isEditingLayout;
              final bool shouldLock =
                  control.lock || (!isEditingLayout && !control.lock);

              final number = int.tryParse(
                RegExp(r'\d+$').firstMatch(control.realId)?.group(0) ?? '',
              );
              final String title = PhanTu_IOT.getTitleById(control.id);

              final bool isChart = title == "Biểu đồ/đồ thị";
              final bool bluetoothOff =
                  _bluetoothService.bluetoothState == BluetoothState.STATE_OFF;
              final bool notConnected = !isConnected;

              Widget childWidget;
              if (isChart && (bluetoothOff || notConnected)) {
                childWidget = SizedBox(
                  width: width,
                  height: height,
                  child: Container(
                    width: size.width,
                    height: size.height,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, color: Colors.red, size: 48),
                          const SizedBox(height: 8),
                          Text(
                            bluetoothOff
                                ? "⚠️ Bluetooth chưa bật!"
                                : "⚠️ Chưa kết nối với robot!",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.red,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                childWidget = PhanTu_IOT.getControlWidget(
                  id: control.id,
                  size: Size(size.width, size.height - 70.0),
                  inMenu: false,
                  value: //null,
                      isChart ? dynamicData : null,
                  // PhanTu_IOT.getValueMapByControl(
                  //   control.id,
                  //   control.realId,
                  // ),
                  config: control.config,
                  showKey: number == 1,
                  lock: shouldLock,
                  sendCommand: (msg) async {
                    debugPrint("Thực hiện bluetooth : " + msg.toString());
                    await Future.delayed(const Duration(milliseconds: 200));
                  },
                  onSave: (newConfig) {
                    setState(() {
                      placedControls[index].config = newConfig;
                    });
                  },
                  VoiceTextToCommand: (String msg) async {
                    if (msg.isNotEmpty) {
                      debugPrint("Gửi lệnh qua bluetooth: $msg");
                    } else {
                      debugPrint("Lệnh rỗng, không gửi qua bluetooth.");
                    }
                  },
                  onDelete: () {
                    setState(() {
                      placedControls.removeAt(index);
                      ControlValueManager.removeValuesForRealId(control.realId);
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
            //tạo t class position 16 16 cái listbox value là biến tên thiết bị
            Positioned(
              left: 16,
              top: 16,
              child: ListBox(
                height: 40,
                width: 150,
                value:
                    connectedDeviceName.isEmpty
                        ? "Vui lòng bât bluetooth"
                        : connectedDeviceName,
              ),
            ),

            // Màn che + Menu bên phải
            if (isEditingLayout && showMenu)
              Stack(
                children: [
                  // Nền mờ để tắt menu khi nhấn ra ngoài
                  GestureDetector(
                    onTap: () => setState(() => showMenu = false),
                    child: Container(
                      color: Colors.black.withAlpha(77),
                    ), // 0.3 * 255 ≈ 77
                  ),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                              final id = control['id'];
                                              final name =
                                                  control['name'] ?? id;
                                              final configRaw =
                                                  control['config'];
                                              final config =
                                                  configRaw == null
                                                      ? <String, dynamic>{}
                                                      : Map<
                                                        String,
                                                        dynamic
                                                      >.from(configRaw);

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
                                                          inMenu: true,
                                                        ),
                                                    onDragStarted:
                                                        () => setState(
                                                          () =>
                                                              showMenu = false,
                                                        ),
                                                    child:
                                                        PhanTu_IOT.getControlWidget(
                                                          id: id,
                                                          size: size,
                                                          config: config,
                                                          isPreview: true,
                                                          inMenu: true,
                                                          lock: true,
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
      },
    );
  }
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
