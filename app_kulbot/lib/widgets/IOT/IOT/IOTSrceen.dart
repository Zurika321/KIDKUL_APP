import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; //xoay màn hình
// import 'dart:math';

//Mẫu và Class lưu trữ file txt
import 'package:Kulbot/widgets/IOT/Sample%26Data/ControlLayoutProvider.dart'; //Mẫu Layout
import 'package:Kulbot/widgets/IOT/Sample%26Data/IotLayoutProvider.dart'; //Lưu Layout

//class phần tử
import 'package:Kulbot/widgets/IOT/phantu/PhanTu_IOT.dart'; //SCSWidget – hiển thị cảm biến

//class dịch vụ
import 'package:Kulbot/service/bluetooth_service.dart'; //bluetooth
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'package:showcaseview/showcaseview.dart';

// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'package:provider/provider.dart'; // lấy dữ liệu từ biến trạng thái main.dart
// import 'package:Kulbot/provider/provider.dart'; // lấy dữ liệu từ biến trạng thái main.dart
// import 'package:Kulbot/l10n/l10n.dart'; // Lấy cờ theo ngôn ngữ
import 'package:Kulbot/l10n/localized_map.dart';
import 'package:Kulbot/widgets/Home/CustomInputField.dart';

// import 'package:shared_preferences/shared_preferences.dart';

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
    barrierDismissible: false,
    builder:
        (_) => MediaQuery.removeViewInsets(
          context: context,
          removeBottom: true,
          child: DefaultTabController(
            length: 2,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              insetPadding: const EdgeInsets.all(
                16,
              ), // giới hạn kích thước dialog
              contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              title: const TabBar(
                tabs: [Tab(text: 'Lưu mới'), Tab(text: 'Ghi đè')],
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 400,
                  height: 300,
                  child: TabBarView(
                    children: [
                      // ===== TAB 1: LƯU MỚI =====
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            "Tên dự án",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: controller,
                            maxLength: 50,
                            decoration: const InputDecoration(
                              hintText: "Nhập tên dự án...",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text("Huỷ"),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                                onPressed: () {
                                  final name = controller.text.trim();
                                  if (name.isNotEmpty) {
                                    onSaveNew(name);
                                    Navigator.of(context).pop();
                                  }
                                },
                                child: const Text("Lưu"),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // ===== TAB 2: GHI ĐÈ =====
                      SingleChildScrollView(
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: savedLayouts.length,
                          itemBuilder: (context, index) {
                            final name = savedLayouts[index];
                            return ListTile(
                              title: Text(name),
                              trailing: IconButton(
                                icon: const Icon(Icons.save),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder:
                                        (_) => AlertDialog(
                                          title: const Text("Xác nhận"),
                                          content: Text(
                                            'Ghi đè dự án "$name"?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(context),
                                              child: const Text("Huỷ"),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(
                                                  context,
                                                ); // close confirm
                                                Navigator.pop(
                                                  context,
                                                ); // close main dialog
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
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
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
  bool haveSave = false;

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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    ShowKeyManager.clear();
    _bluetoothService.stopDiscovery();
    super.dispose();
  }

  // void _checkBluetoothStatus() {
  //   _bluetoothService.flutterBluetoothSerial.state.then((state) {
  //     setState(() {
  //       _bluetoothService.bluetoothState = state;
  //     });
  //   });
  // }

  Future<void> _initLayout(Size size) async {
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
    bool loadedFromStorage = false;
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
        haveSave = true;
        loadedFromStorage = true;
      }
    } else if (widget.type != "new") {
      placedControls.addAll(ControlLayoutProvider.getLayout(widget.type));
    }

    // Kiểm tra trước khi add ListBox1
    if (!loadedFromStorage) {
      final y = 50 / size.height;
      final x = (size.width - 218) / size.width;
      if (!placedControls.any((item) => item.realId == 'ListBox1')) {
        placedControls.add(
          ControlItem(
            id: 'ListBox',
            realId: 'ListBox1',
            relativePosition: Offset(x < 0 ? 0 : x, y),
            config: {'height': 50.0, 'width': 200.0},
            lock: false,
            canMove: true,
          ),
        );
      }

      // Kiểm tra trước khi add ListBoxTester1
      // if (!placedControls.any((item) => item.realId == 'ListBoxTester1')) {
      //   placedControls.add(
      //     ControlItem(
      //       id: 'ListBoxTester',
      //       realId: 'ListBoxTester1',
      //       relativePosition: const Offset(0, 0.5),
      //       config: {'height': 200.0, 'width': 200.0},
      //       lock: false,
      //       canMove: true,
      //     ),
      //   );
      // }
    }

    setState(() {});
  }

  // final String _moveForwardCommand = "";
  // final String _moveBackwardCommand = "";
  // final String _moveTurnLeftCommand = "";
  // final String _moveTurnRightCommand = "";
  // final String _moveStopCommand = "";
  bool get isConnected => (_bluetoothService.connection?.isConnected ?? false);

  // void moveMotor() {
  //   if (!isConnected) return;
  //   final voice = voicetotext.toLowerCase();
  //   if (voice.contains('tiến') ||
  //       voice.contains('lên') ||
  //       voice.contains('forward')) {
  //     _bluetoothService.sendMessage(_moveForwardCommand);
  //   } else if (voice.contains('lui') ||
  //       voice.contains('lùi') ||
  //       voice.contains('back')) {
  //     _bluetoothService.sendMessage(_moveBackwardCommand);
  //   } else if (voice.contains('trái') || voice.contains('left')) {
  //     _bluetoothService.sendMessage(_moveTurnLeftCommand);
  //   } else if (voice.contains('phải') || voice.contains('right')) {
  //     _bluetoothService.sendMessage(_moveTurnRightCommand);
  //   } else if (voice.contains('dừng') || voice.contains('stop')) {
  //     _bluetoothService.sendMessage(_moveStopCommand);
  //   } else {
  //     print("Không nhận diện được lệnh thoại: $voicetotext");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;
    // final provider = Provider.of<LocaleProvider>(context);
    // var locale = provider.locale ?? Locale('en');

    return ShowCaseWidget(
      builder:
          (context) => Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,

            // appBar: _buildAppBar(context, isDarkMode), //ko sài appbar nữa anh Kha bảo thế !!!
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

  PreferredSizeWidget buildTopBar(BuildContext context) {
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
                key: ShowKeyManager.createKey("SaveProjectIOT"),
                description: LocalizedStringGetter.showkey_get(
                  context,
                  "SaveProjectIOT",
                ),
                child: IconButton(
                  icon: const Icon(Icons.save),
                  color: Colors.greenAccent,
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
                            content: Text(
                              '✅ Đã lưu layout "$savedName" thành công!',
                            ),
                          ),
                        );
                        setState(() {
                          nameProject = savedName;
                          haveSave = true;
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
                              content: Text(
                                '✅ Đã ghi đè layout "$name" thành công!',
                              ),
                            ),
                          );
                          setState(() {
                            nameProject = name;
                            haveSave = true;
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '❌ Không thể ghi đè layout "$name"!',
                              ),
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
    return Stack(
      children: [
        Positioned(
          top: 8,
          left: 8,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.blueAccent),
            onPressed: () {
              final _navigator = Navigator.of(context);
              if (haveSave) {
                if (_navigator.mounted) {
                  _navigator.pop();
                  _navigator.pop();
                }
              } else {
                showDialog(
                  context: context, // Sử dụng context của IconButton
                  builder:
                      (ctx) => AlertDialog(
                        title: const Text("Chưa lưu layout"),
                        content: const Text(
                          "Bạn có muốn lưu layout trước khi thoát không?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(ctx).pop();
                              if (_navigator.mounted) {
                                _navigator.pop();
                                _navigator.pop();
                              }
                            },
                            child: const Text("Không"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(ctx).pop(); // Đóng dialog xác nhận
                              showSaveDialog(
                                context, // Sử dụng context của IconButton thay vì _navigator.context
                                onSaveNew: (String name) async {
                                  final savedName =
                                      await IotLayoutProvider.saveLayout(
                                        name,
                                        placedControls,
                                      );
                                  if (!mounted)
                                    return; // Kiểm tra mounted của State
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '✅ Đã lưu layout "$savedName" thành công!',
                                      ),
                                    ),
                                  );
                                  _navigator.pop();
                                  _navigator.pop();
                                },
                                onOverwrite: (String name) async {
                                  final success =
                                      await IotLayoutProvider.updateLayout(
                                        name,
                                        placedControls,
                                      );
                                  if (!mounted)
                                    return; // Kiểm tra mounted của State
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        success
                                            ? '✅ Ghi đè layout "$name" thành công!'
                                            : '❌ Không thể ghi đè layout "$name"!',
                                      ),
                                    ),
                                  );
                                  if (success) {
                                    _navigator.pop();
                                    _navigator.pop();
                                  }
                                },
                              );
                            },
                            child: const Text("Có"),
                          ),
                        ],
                      ),
                );
              }
            },
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
        ),
        Positioned(top: 0, right: 0, child: buildTopBar(context)),
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

                  final List<double> sizeInfo = PhanTu_IOT.getControlSizeById(
                    control.id,
                  );

                  final double xOffset =
                      control.relativePosition.dx * size.width;
                  final double yOffset =
                      control.relativePosition.dy * size.height;

                  final String typeBox = PhanTu_IOT.getTypeBoxById(control.id);

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
                            PhanTu_IOT.getNoteShowKey(context, control.id),
                          )
                          : null;
                  // final String title = PhanTu_IOT.getTitleById(control.id);

                  final bool havedata = PhanTu_IOT.getGetDataById(control.id);
                  // final bool bluetoothOff =
                  //     _bluetoothService.bluetoothState ==
                  //     BluetoothState.STATE_OFF;
                  // final bool notConnected = !isConnected;

                  Widget childWidget;
                  if (control.id == "ListBoxTester") {
                    childWidget = PhanTu_IOT.getControlWidget(
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
                    childWidget = PhanTu_IOT.getControlWidget(
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
                    childWidget = PhanTu_IOT.getControlWidget(
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
                                    LocalizedStringGetter.IOT_get(
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
                                                    PhanTu_IOT.getControlWidget(
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
                                                      PhanTu_IOT.getControlWidget(
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
                                                LocalizedStringGetter.IOT_get(
                                                  context,
                                                  name,
                                                ),
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
