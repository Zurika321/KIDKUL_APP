// import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart';
// // import 'dart:math';

// //Mẫu và Class lưu trữ file txt
// import 'package:KulBlock/provider/Sample&Data/Control&IOTLayoutProvider.dart'; //Mẫu Layout

// import 'package:KulBlock/provider/Sample&Data/IotLayoutProject.dart'; //Lưu Layout
// //class phần tử
// import 'package:KulBlock/widgets/2IOT&Control/phantu/PhanTu_Control.dart'; //SCSWidget – hiển thị cảm biến

// //class dịch vụ
// import 'package:KulBlock/service/bluetooth_service.dart'; //bluetooth
// import 'package:KulBlock/widgets/2IOT&Control/scanQR_widget.dart';
// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

// import 'package:showcaseview/showcaseview.dart';

// // import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'package:provider/provider.dart'; // lấy dữ liệu từ biến trạng thái main.dart
// import 'package:KulBlock/provider/provider.dart'; // lấy dữ liệu từ biến trạng thái main.dart
// // import 'package:KulBlock/l10n/l10n.dart'; // Lấy cờ theo ngôn ngữ
// import 'package:KulBlock/l10n/localized_map.dart';
// // import 'package:collection/collection.dart';

// class DataBluetooth {
//   static final Map<String, dynamic> _data = {};

//   static Map<String, dynamic> get data => _data;

//   static Map<String, dynamic> mergeNewData(Map<String, dynamic> newData) {
//     _data.addAll(newData);
//     return Map<String, dynamic>.from(_data);
//   }

//   static void clear() {
//     _data.clear();
//   }
// }

// class ControlItem {
//   final String id;
//   String realId;
//   Offset relativePosition;
//   Map<String, dynamic> config;
//   bool lock;
//   bool canMove;

//   /// Tọa độ pixel tuyệt đối ban đầu (chỉ sử dụng để convert)
//   double? top;
//   double? bottom;
//   double? left;
//   double? right;

//   ControlItem({
//     required this.id,
//     required this.realId,
//     this.relativePosition = Offset.zero,
//     this.top,
//     this.bottom,
//     this.left,
//     this.right,
//     Map<String, dynamic>? config,
//     this.lock = false,
//     this.canMove = true,
//   }) : config = config != null ? Map<String, dynamic>.from(config) : {};

//   factory ControlItem.fromJson(Map<String, dynamic> json) {
//     return ControlItem(
//       id: json['id'],
//       realId: json['realId'] ?? json['id'],
//       relativePosition: Offset(
//         (json['x'] as num).toDouble(),
//         (json['y'] as num).toDouble(),
//       ),
//       config: Map<String, dynamic>.from(json['config'] ?? {}),
//       lock: json['lock'] ?? false,
//       canMove:
//           json['canMove'] ?? true, // <- Thêm dòng này để đọc canMove từ JSON
//     );
//   }

//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'realId': realId,
//     'x': relativePosition.dx,
//     'y': relativePosition.dy,
//     'config': config,
//     'lock': lock,
//     'canMove': canMove,
//   };

//   ControlItem clone() {
//     return ControlItem(
//       id: id,
//       realId: realId,
//       relativePosition: Offset(relativePosition.dx, relativePosition.dy),
//       config: Map<String, dynamic>.from(config),
//       lock: lock,
//       canMove: canMove,
//       top: top,
//       bottom: bottom,
//       left: left,
//       right: right,
//     );
//   }
// }

// class RobotControlScreen extends StatefulWidget {
//   final String type;
//   final String projectName;
//   final bool isControl;
//   final bool checkAvailability;

//   const RobotControlScreen({
//     super.key,
//     required this.type,
//     required this.projectName,
//     required this.isControl,
//     this.checkAvailability = true,
//   });

//   @override
//   State<RobotControlScreen> createState() => _RobotControlScreenState();
// }

// class _RobotControlScreenState extends State<RobotControlScreen> {
//   bool isEditingLayout = false;
//   bool showMenu = false;
//   final Map<String, Map<String, dynamic>> controlGroups =
//       PhanTu_Control.controlGroups;
//   final List<ControlItem> placedControls = [];
//   final BluetoothService _bluetoothService = BluetoothService();
//   bool haveSave = false;
//   final List<Color> groupColors = [
//     Colors.blue.shade100,
//     Colors.green.shade100,
//     Colors.pink.shade100,
//     Colors.amber.shade100,
//     Colors.deepOrange.shade100,
//     Colors.purple.shade100,
//     Colors.teal.shade100,
//   ];
//   final Map<String, GlobalKey> sectionKeys = {};
//   late Map<String, List<Map<String, dynamic>>> groupedControls;
//   late List<String> groupedTitles;
//   final ScrollController _scrollController = ScrollController();
//   late BuildContext scrollViewContext;
//   bool loadDone = false;

//   String connectedDeviceName = "";

//   int getPlacedCountById(String id) {
//     return placedControls.where((item) => item.id.startsWith(id)).length;
//   }

//   String generateNewRealId(String id) {
//     int i = 1;
//     while (true) {
//       final candidate = '$id$i';
//       final exists = placedControls.any(
//         (control) => control.realId == candidate,
//       );
//       if (!exists) return candidate;
//       i++;
//     }
//   }

//   void handleDrop(String id, Offset position, Size screenSize) {
//     final currentCount = getPlacedCountById(id);
//     final maxCount = PhanTu_Control.getMaxById(id);

//     if (currentCount >= maxCount) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Maximum quantity reached $id')));
//       return;
//     }

//     final adjustedPos = Offset(
//       position.dx.clamp(0, screenSize.width * 0.9),
//       position.dy.clamp(0, screenSize.height * 0.9),
//     );

//     final relPos = Offset(
//       adjustedPos.dx / screenSize.width,
//       adjustedPos.dy / screenSize.height,
//     );

//     final newRealId = generateNewRealId(id);

//     setState(() {
//       placedControls.add(
//         ControlItem(id: id, realId: newRealId, relativePosition: relPos),
//       );
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     FlutterBluetoothSerial.instance.state.then((state) {
//       setState(() {
//         _bluetoothService.bluetoothState = state;
//       });
//     });

//     FlutterBluetoothSerial.instance.address.then((address) {
//       setState(() {
//         _bluetoothService.address = address!;
//       });
//     });

//     FlutterBluetoothSerial.instance.name.then((name) {
//       setState(() {
//         _bluetoothService.name = name!;
//       });
//     });

//     _bluetoothService.onDeviceConnected = (String deviceName) {
//       setState(() {
//         connectedDeviceName = "Connected to $deviceName";
//       });
//     };

//     _bluetoothService.onDeviceDisconnected = () {
//       setState(() {
//         connectedDeviceName = "Not connected to robot";
//       });
//     };

//     FlutterBluetoothSerial.instance.onStateChanged().listen((
//       BluetoothState state,
//     ) {
//       setState(() {
//         _bluetoothService.bluetoothState = state;
//         if (state == BluetoothState.STATE_OFF) {
//           connectedDeviceName = "Bluetooth is Off";
//         } else if (state == BluetoothState.STATE_ON) {
//           connectedDeviceName = "Bluetooth is On";
//         }
//       });
//     });

//     _bluetoothService.requestLocationPermission().then((_) {
//       if (widget.checkAvailability) {
//         _bluetoothService.startDiscoveryWithTimeout();
//       }
//     });

//     _bluetoothService.getBondedDevices();
//     // _checkBluetoothStatus();
//     updateGroupedSections();
//     final size =
//         WidgetsBinding.instance.window.physicalSize /
//         WidgetsBinding.instance.window.devicePixelRatio;
//     _initLayout(size, widget.projectName, widget.type);
//   }

//   Future<void> scanQRcodeNormal() async {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder:
//             (context) => ScanQRWidget(
//               onScanComplete: (String result) {
//                 _bluetoothService.sendMessage(result);
//               },
//             ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     ShowKeyManager.clear();
//     _bluetoothService.stopDiscovery();
//     DataBluetooth.clear();
//     super.dispose();
//   }

//   Future<void> _initLayout(Size size, String projectName, String type) async {
//     List<ControlItem> rawItems = [];
//     bool isProvider = true;

//     if (!widget.isControl) {
//       if (type.isEmpty && projectName.isNotEmpty && !kIsWeb) {
//         final items = await IotLayoutProject.loadLayout(projectName);
//         if (items.isEmpty) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('No data found from project: $projectName.'),
//             ),
//           );
//         } else {
//           isProvider = false;
//           rawItems.addAll(items);
//           haveSave = true;
//         }
//       } else if (type != "new") {
//         rawItems.addAll(
//           ControlLayoutProvider.getLayout(type, widget.isControl),
//         );
//       }
//     } else {
//       rawItems.addAll(ControlLayoutProvider.getLayout(type, widget.isControl));
//     }

//     // Normalize xong mới set vào placedControls
//     if (rawItems.isNotEmpty) {
//       placedControls.addAll(normalizeLayoutItems(rawItems, size, isProvider));
//     }
//     setState(() {
//       loadDone = true;
//       isEditingLayout = widget.type == "new";
//       // showMenu = isEditingLayout;
//     });
//     await Future.delayed(const Duration(milliseconds: 1000));
//     if (isEditingLayout) {
//       setState(() {
//         showMenu = isEditingLayout;
//       });
//     }
//   }

//   void updateGroupedSections() {
//     groupedControls = {};
//     sectionKeys.clear();
//     controlGroups.forEach((id, control) {
//       final title = control['title'] ?? '';
//       groupedControls.putIfAbsent(title, () => []).add({...control, 'id': id});
//     });
//     groupedTitles = groupedControls.keys.toList();
//     for (var title in groupedTitles) {
//       sectionKeys[title] = GlobalKey();
//     }
//   }

//   List<ControlItem> normalizeLayoutItems(
//     List<ControlItem> items,
//     Size screenSize,
//     bool CenterRelativePosition,
//   ) {
//     final List<ControlItem> result = [];
//     final Set<String> usedRealIds = {};

//     for (var item in items) {
//       final clone = item.clone();

//       // Đảm bảo realId không bị trùng
//       String newRealId = clone.realId;
//       int suffix = 1;
//       while (usedRealIds.contains(newRealId)) {
//         newRealId = '${clone.realId}_$suffix';
//         suffix++;
//       }
//       clone.realId = newRealId;
//       usedRealIds.add(newRealId);

//       // Lấy kích thước từ config hoặc fallback mặc định
//       final width =
//           (clone.config["width"] is double)
//               ? clone.config["width"] as double
//               : 100.0;
//       final height =
//           (clone.config["height"] is double)
//               ? clone.config["height"] as double
//               : 100.0;

//       // Tính toạ độ Y
//       double dy;
//       if (clone.top != null) {
//         dy = clone.top! / screenSize.height;
//       } else if (clone.bottom != null) {
//         dy =
//             (screenSize.height - clone.bottom! - height - 55) /
//             screenSize.height;
//       } else {
//         dy =
//             clone.relativePosition.dy +
//             (CenterRelativePosition
//                 ? ((clone.relativePosition.dy >= 0.5 ? -height : height) /
//                     screenSize.height /
//                     2)
//                 : 0);
//       }

//       // Tính toạ độ X
//       double dx;
//       if (clone.left != null) {
//         dx = clone.left! / screenSize.width;
//       } else if (clone.right != null) {
//         dx = (screenSize.width - clone.right! - width) / screenSize.width;
//       } else {
//         dx =
//             clone.relativePosition.dx +
//             (CenterRelativePosition
//                 ? ((clone.relativePosition.dx >= 0.5 ? -width : width) /
//                     screenSize.width /
//                     2)
//                 : 0);
//       }

//       clone.top = null;
//       clone.bottom = null;
//       clone.left = null;
//       clone.right = null;

//       // Clamp về phạm vi [0, 1]
//       dx = dx.clamp(0.0, 1.0);
//       dy = dy.clamp(0.0, 1.0);

//       clone.relativePosition = Offset(dx, dy);
//       result.add(clone);
//     }

//     return result;
//   }

//   bool get isConnected => (_bluetoothService.connection?.isConnected ?? false);

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     // final themeNotifier = Provider.of<ThemeNotifier>(context);
//     // final isDarkMode = themeNotifier.isDarkMode;

//     final provider = Provider.of<LocaleProvider>(context);
//     var locale = provider.locale ?? Locale('en');

//     return ShowCaseWidget(
//       builder:
//           (context) => Scaffold(
//             backgroundColor: Theme.of(context).colorScheme.background,
//             appBar: buildTopBar(context, locale),
//             floatingActionButton:
//                 isEditingLayout && !showMenu && !widget.isControl
//                     ? FloatingActionButton(
//                       onPressed: () => setState(() => showMenu = !showMenu),
//                       child: const Icon(Icons.add),
//                     )
//                     : null,
//             body: SafeArea(child: _buildMainStack(size, context)),
//           ),
//     );
//   }

//   PreferredSizeWidget buildTopBar(BuildContext context, Locale locale) {
//     return AppBar(
//       automaticallyImplyLeading: false,
//       backgroundColor: Colors.transparent,
//       elevation: 2,
//       toolbarHeight: 56,
//       titleSpacing: 0,
//       leading: IconButton(
//         icon: const Icon(
//           Icons.arrow_back,
//           color: Color.fromARGB(255, 68, 137, 255),
//         ),
//         splashColor: Colors.transparent,
//         highlightColor: Colors.transparent,
//         onPressed: () {
//           final navigator = Navigator.of(context);
//           if (widget.isControl) {
//             navigator.pop();
//           } else {
//             if (haveSave) {
//               if (navigator.mounted) {
//                 navigator.pop(true);
//               }
//             } else {
//               if (!kIsWeb) {
//                 showDialog(
//                   context: context,
//                   builder:
//                       (ctx) => AlertDialog(
//                         title: const Text("Layout not saved"),
//                         content: const Text(
//                           "Do you want to save the layout before exiting?",
//                         ),
//                         actions: [
//                           TextButton(
//                             onPressed: () {
//                               Navigator.of(ctx).pop();
//                               if (navigator.mounted) navigator.pop(false);
//                             },
//                             child: const Text("No"),
//                           ),
//                           TextButton(
//                             onPressed: () {
//                               Navigator.of(ctx).pop();
//                               showSaveDialog(
//                                 context,
//                                 onSaveNew: (String name) async {
//                                   final savedName =
//                                       await IotLayoutProject.saveLayout(
//                                         name,
//                                         placedControls,
//                                       );
//                                   if (!context.mounted) return;
//                                   navigator.pop(true);
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     SnackBar(
//                                       content: Text(
//                                         '✅ Layout "$savedName" saved successfully!',
//                                       ),
//                                     ),
//                                   );
//                                 },
//                                 onOverwrite: (String name) async {
//                                   final success =
//                                       await IotLayoutProject.updateLayout(
//                                         name,
//                                         placedControls,
//                                       );
//                                   if (success) {
//                                     if (!context.mounted) return;
//                                     navigator.pop(true);
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       SnackBar(
//                                         content: Text(
//                                           '✅ Successfully overwritten layout "$name"!',
//                                         ),
//                                       ),
//                                     );
//                                   } else {
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       SnackBar(
//                                         content: Text(
//                                           '❌ Cannot override layout "$name"!',
//                                         ),
//                                       ),
//                                     );
//                                   }
//                                 },
//                               );
//                             },
//                             child: const Text("Yes"),
//                           ),
//                         ],
//                       ),
//                 );
//               } else {
//                 navigator.pop();
//               }
//             }
//           }
//         },
//       ),
//       actions: [
//         Showcase(
//           key: ShowKeyManager.createKey("Huongdan"),
//           description: LocalizedStringGetter.showkey_get(context, "Huongdan"),
//           child: IconButton(
//             icon: const Icon(
//               Icons.question_mark_rounded,
//               color: Color.fromARGB(255, 83, 109, 254),
//             ),
//             onPressed: () {
//               if (!context.mounted) return;
//               ShowCaseWidget.of(
//                 context,
//               ).startShowCase(ShowKeyManager.getAllKeys());
//             },
//           ),
//         ),
//         if (!widget.isControl)
//           Showcase(
//             key: ShowKeyManager.createKey("ScanQRcode"),
//             description: LocalizedStringGetter.showkey_get(
//               context,
//               "ScanQRcode",
//             ),
//             child: IconButton(
//               icon: const Icon(
//                 Icons.qr_code_scanner_outlined,
//                 color: Colors.deepPurpleAccent,
//               ),
//               onPressed: scanQRcodeNormal,
//             ),
//           ),
//         Showcase(
//           key: ShowKeyManager.createKey("TongLeBluetooth"),
//           description: LocalizedStringGetter.showkey_get(
//             context,
//             "TongLeBluetooth",
//           ),
//           child: IconButton(
//             icon: Icon(
//               _bluetoothService.bluetoothState.isEnabled
//                   ? (isConnected ? Icons.bluetooth_connected : Icons.bluetooth)
//                   : Icons.bluetooth_disabled,
//               color:
//                   isConnected
//                       ? const Color.fromARGB(255, 64, 195, 255)
//                       : const Color.fromARGB(255, 255, 82, 82),
//             ),
//             onPressed: () {
//               _bluetoothService.startDiscoveryWithTimeout();
//               isConnected
//                   ? _bluetoothService.connection?.dispose()
//                   : _bluetoothService.connectBluetoothDialog(context);
//             },
//           ),
//         ),
//         if (!widget.isControl)
//           Showcase(
//             key: ShowKeyManager.createKey("SaveProjectIOT"),
//             description: LocalizedStringGetter.showkey_get(
//               context,
//               "SaveProjectIOT",
//             ),
//             child: IconButton(
//               icon: const Icon(
//                 Icons.save,
//                 color: Color.fromARGB(255, 105, 240, 175),
//               ),
//               onPressed: () {
//                 if (kIsWeb) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text("Cannot save when using web")),
//                   );
//                 } else {
//                   showSaveDialog(
//                     context,
//                     onSaveNew: (String name) async {
//                       final savedName = await IotLayoutProject.saveLayout(
//                         name,
//                         placedControls,
//                       );
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text(
//                             '✅ Layout "$savedName" saved successfully!',
//                           ),
//                         ),
//                       );
//                       setState(() => haveSave = true);
//                     },
//                     onOverwrite: (String name) async {
//                       final success = await IotLayoutProject.updateLayout(
//                         name,
//                         placedControls,
//                       );
//                       if (success) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text(
//                               '✅ Successfully overwritten layout "$name"!',
//                             ),
//                           ),
//                         );
//                         setState(() => haveSave = true);
//                       } else {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text('❌ Cannot override layout "$name"!'),
//                           ),
//                         );
//                       }
//                     },
//                   );
//                 }
//               },
//             ),
//           ),
//         Showcase(
//           key: ShowKeyManager.createKey("EditMode"),
//           description: LocalizedStringGetter.showkey_get(context, "EditMode"),
//           child: IconButton(
//             icon: Icon(isEditingLayout ? Icons.check : Icons.edit),
//             color: const Color.fromARGB(255, 255, 172, 64),
//             onPressed:
//                 () => setState(() {
//                   isEditingLayout = !isEditingLayout;
//                   showMenu = false;
//                 }),
//           ),
//         ),
//       ],
//     );
//   }

//   // PreferredSizeWidget buildTopBar(BuildContext context, Locale locale) {
//   //   return PreferredSize(
//   //     preferredSize: const Size.fromHeight(56),
//   //     child: SafeArea(
//   //       child: Container(
//   //         padding: const EdgeInsets.only(top: 8, right: 8),
//   //         alignment: Alignment.topRight,
//   //         decoration: const BoxDecoration(
//   //           color: Color.fromARGB(0, 0, 0, 0),
//   //           border: Border(
//   //             bottom: BorderSide(color: Color.fromARGB(255, 0, 0, 0), width: 2),
//   //           ),
//   //         ),
//   //         child: Row(
//   //           mainAxisSize: MainAxisSize.min,
//   //           children: [
//   //             const SizedBox(width: 8),
//   //             Showcase(
//   //               key: ShowKeyManager.createKey("Huongdan"),
//   //               description: LocalizedStringGetter.showkey_get(
//   //                 context,
//   //                 "Huongdan",
//   //               ),
//   //               child: IconButton(
//   //                 icon: const Icon(
//   //                   Icons.question_mark_rounded,
//   //                   color: Color.fromARGB(255, 83, 109, 254),
//   //                 ),
//   //                 onPressed: () {
//   //                   if (!mounted) return;
//   //                   ShowCaseWidget.of(
//   //                     context,
//   //                   ).startShowCase(ShowKeyManager.getAllKeys());
//   //                 },
//   //               ),
//   //             ),
//   //             // Showcase(
//   //             //   key: ShowKeyManager.createKey("LanguageSelector"),
//   //             //   description: LocalizedStringGetter.showkey_get(
//   //             //     context,
//   //             //     "LanguageSelector",
//   //             //   ),
//   //             //   child: DropdownButton(
//   //             //     value: locale,
//   //             //     icon: Container(width: 12),
//   //             //     items:
//   //             //         L10n.all.map((locale) {
//   //             //           final flag = L10n.getflag(locale.languageCode);
//   //             //           return DropdownMenuItem(
//   //             //             child: Center(
//   //             //               child: Text(flag, style: TextStyle(fontSize: 32)),
//   //             //             ),
//   //             //             value: locale,
//   //             //             onTap: () {
//   //             //               final provider = Provider.of<LocaleProvider>(
//   //             //                 context,
//   //             //                 listen: false,
//   //             //               );
//   //             //               provider.setLocale(locale);
//   //             //             },
//   //             //           );
//   //             //         }).toList(),
//   //             //     onChanged: (_) {},
//   //             //   ),
//   //             // ),
//   //             if (!widget.isControl)
//   //               Showcase(
//   //                 key: ShowKeyManager.createKey("ScanQRcode"),
//   //                 description: LocalizedStringGetter.showkey_get(
//   //                   context,
//   //                   "ScanQRcode",
//   //                 ),
//   //                 child: IconButton(
//   //                   icon: const Icon(
//   //                     Icons.qr_code_scanner_outlined,
//   //                     color: Colors.deepPurpleAccent,
//   //                   ),
//   //                   onPressed: scanQRcodeNormal,
//   //                 ),
//   //               ),
//   //             Showcase(
//   //               key: ShowKeyManager.createKey("TongLeBluetooth"),
//   //               description: LocalizedStringGetter.showkey_get(
//   //                 context,
//   //                 "TongLeBluetooth",
//   //               ),
//   //               child: IconButton(
//   //                 icon: Icon(
//   //                   _bluetoothService.bluetoothState.isEnabled
//   //                       ? (isConnected
//   //                           ? Icons.bluetooth_connected
//   //                           : Icons.bluetooth)
//   //                       : Icons.bluetooth_disabled,
//   //                   color:
//   //                       isConnected
//   //                           ? const Color.fromARGB(255, 64, 195, 255)
//   //                           : const Color.fromARGB(255, 255, 82, 82),
//   //                 ),
//   //                 onPressed: () {
//   //                   _bluetoothService.startDiscoveryWithTimeout();
//   //                   isConnected
//   //                       ? _bluetoothService.connection?.dispose()
//   //                       : _bluetoothService.connectBluetoothDialog(context);
//   //                 },
//   //               ),
//   //             ),
//   //             if (!widget.isControl)
//   //               Showcase(
//   //                 key: ShowKeyManager.createKey("SaveProjectIOT"),
//   //                 description: LocalizedStringGetter.showkey_get(
//   //                   context,
//   //                   "SaveProjectIOT",
//   //                 ),
//   //                 child: IconButton(
//   //                   icon: const Icon(Icons.save),
//   //                   color: const Color.fromARGB(255, 105, 240, 175),
//   //                   onPressed: () {
//   //                     if (kIsWeb) {
//   //                       ScaffoldMessenger.of(context).showSnackBar(
//   //                         const SnackBar(
//   //                           content: Text("Cannot save when using web"),
//   //                         ),
//   //                       );
//   //                     }
//   //                     {
//   //                       showSaveDialog(
//   //                         context,
//   //                         onSaveNew: (String name) async {
//   //                           final savedName = await IotLayoutProject.saveLayout(
//   //                             name,
//   //                             placedControls,
//   //                           );
//   //                           ScaffoldMessenger.of(context).showSnackBar(
//   //                             SnackBar(
//   //                               content: Text(
//   //                                 '✅ Layout "$savedName" saved successfully!',
//   //                               ),
//   //                             ),
//   //                           );
//   //                           setState(() {
//   //                             haveSave = true;
//   //                           });
//   //                         },
//   //                         onOverwrite: (String name) async {
//   //                           final success = await IotLayoutProject.updateLayout(
//   //                             name,
//   //                             placedControls,
//   //                           );
//   //                           if (success) {
//   //                             ScaffoldMessenger.of(context).showSnackBar(
//   //                               SnackBar(
//   //                                 content: Text(
//   //                                   '✅ Successfully overwritten layout "$name"!',
//   //                                 ),
//   //                               ),
//   //                             );
//   //                             setState(() {
//   //                               haveSave = true;
//   //                             });
//   //                           } else {
//   //                             ScaffoldMessenger.of(context).showSnackBar(
//   //                               SnackBar(
//   //                                 content: Text(
//   //                                   '❌ Cannot override layout "$name"!',
//   //                                 ),
//   //                               ),
//   //                             );
//   //                           }
//   //                         },
//   //                       );
//   //                     }
//   //                   },
//   //                 ),
//   //               ),
//   //             Showcase(
//   //               key: ShowKeyManager.createKey("EditMode"),
//   //               description: LocalizedStringGetter.showkey_get(
//   //                 context,
//   //                 "EditMode",
//   //               ),
//   //               child: IconButton(
//   //                 icon: Icon(isEditingLayout ? Icons.check : Icons.edit),
//   //                 color: const Color.fromARGB(255, 255, 172, 64),
//   //                 onPressed: () {
//   //                   setState(() {
//   //                     isEditingLayout = !isEditingLayout;
//   //                     showMenu = false;
//   //                   });
//   //                 },
//   //               ),
//   //             ),
//   //           ],
//   //         ),
//   //       ),
//   //     ),
//   //   );
//   // }

//   void moveMotor(String voicetotext) {
//     if (voicetotext.contains('Tiến') ||
//         voicetotext.contains('lên') ||
//         voicetotext.contains('forward')) {
//       _bluetoothService.sendMessage('f');
//     } else if (voicetotext.contains('lui') ||
//         voicetotext.contains('lùi') ||
//         voicetotext.contains('back')) {
//       _bluetoothService.sendMessage('b');
//     } else if (voicetotext.contains('trái') || voicetotext.contains('left')) {
//       _bluetoothService.sendMessage('l');
//     } else if (voicetotext.contains('phải') || voicetotext.contains('right')) {
//       _bluetoothService.sendMessage('r');
//     } else if (voicetotext.contains('dừng lại') ||
//         voicetotext.contains('stop')) {
//       _bluetoothService.sendMessage('s');
//     }
//   }

//   late Map<String, dynamic> value3 = {"data": "No Data available"};
//   late String value2 = "";
//   late String value1 = "";
//   late String valueofid1 = "";
//   late String valueofid2 = "";

//   final Map<String, dynamic> mockData = {
//     'temp1': 36.5, // double
//     'humidity': 80, // int
//     'status': 'Running', // String
//     'isActive': true, // bool
//     'pressure': 101.325, // double
//     'errorMsg': '', // String
//     'retryCount': 3, // int
//     'isConnected': false, // bool
//   };

//   Widget _buildMainStack(Size size, BuildContext context) {
//     scrollViewContext = context;
//     return Stack(
//       children: [
//         StreamBuilder<Map<String, dynamic>>(
//           stream: _bluetoothService.stream,
//           builder: (context, snapshot) {
//             // final dynamicData =
//             //     (snapshot.data != null)
//             //         ? Map<String, dynamic>.fromEntries(
//             //           snapshot.data!.entries.map(
//             //             (e) => MapEntry(e.key.toString(), e.value),
//             //           ),
//             //         )
//             //         : <String, dynamic>{};
//             final dynamicData =
//                 snapshot.data != null
//                     ? DataBluetooth.mergeNewData(snapshot.data!)
//                     : DataBluetooth.data;
//             // debugPrint("Dữ liệu động: $dynamicData");
//             // Các nút đã đặt
//             return Stack(
//               children: [
//                 ...placedControls.asMap().entries.map((entry) {
//                   final index = entry.key;
//                   final control = entry.value;

//                   final List<double> sizeInfo =
//                       PhanTu_Control.getControlSizeById(control.id);

//                   final double xOffset =
//                       control.relativePosition.dx * size.width;
//                   final double yOffset =
//                       control.relativePosition.dy * size.height;

//                   final String typeBox = PhanTu_Control.getTypeBoxById(
//                     control.id,
//                   );

//                   double width =
//                       control.config["width"] ??
//                       ((typeBox == "height" ? size.height : size.width) *
//                               sizeInfo[4] +
//                           sizeInfo[5]);
//                   double height =
//                       control.config["height"] ??
//                       ((typeBox == "width" ? size.width : size.height) *
//                               sizeInfo[6] +
//                           sizeInfo[7]);

//                   width = width.clamp(30.0, size.width);
//                   height = height.clamp(30.0, size.height);

//                   final bool canMove = control.canMove && isEditingLayout;
//                   final bool shouldLock =
//                       control.lock || (!isEditingLayout && !control.lock);

//                   String? tooltipMessage;

//                   if (isEditingLayout && shouldLock && !canMove) {
//                     tooltipMessage = "This element cannot be edited or moved.";
//                   } else if (isEditingLayout && shouldLock) {
//                     tooltipMessage = "This element cannot be edited.";
//                   } else if (isEditingLayout && !canMove) {
//                     tooltipMessage = "This element cannot be moved.";
//                   }

//                   final number = int.tryParse(
//                     RegExp(r'\d+$').firstMatch(control.realId)?.group(0) ?? '',
//                   );

//                   String? NoteShowKey =
//                       number == 1
//                           ? LocalizedStringGetter.showkey_get(
//                             context,
//                             PhanTu_Control.getNoteShowKey(context, control.id),
//                           )
//                           : null;
//                   // final String title = PhanTu_Control.getTitleById(control.id);

//                   final bool havedata = PhanTu_Control.getGetDataById(
//                     control.id,
//                   );
//                   // final bool bluetoothOff =
//                   //     _bluetoothService.bluetoothState ==
//                   //     BluetoothState.STATE_OFF;
//                   // final bool notConnected = !isConnected;

//                   Widget childWidget;
//                   if (control.id == "ListBoxTester") {
//                     childWidget = PhanTu_Control.getControlWidget(
//                       id: control.id,
//                       size: Size(
//                         size.width,
//                         size.height - 65.0,
//                       ), //-56 là cái bar ở trên
//                       inMenu: false,
//                       value: {
//                         "valueofid1": valueofid1,
//                         "valueofid2": valueofid2,
//                         "value1": value1,
//                         "value2": value2,
//                         "value3": value3,
//                       },
//                       config: control.config,
//                       NoteshowKey: NoteShowKey,
//                       lock: shouldLock,
//                       onSave: (newConfig) {
//                         setState(() {
//                           valueofid2 = "${control.id} - ${control.realId}";
//                           value3 = newConfig;
//                           placedControls[index].config = newConfig;
//                         });
//                       },
//                       onDelete:
//                           (widget.isControl)
//                               ? null
//                               : () {
//                                 setState(() {
//                                   placedControls.removeAt(index);
//                                 });
//                               },
//                     );
//                   } else if (control.id == "ListBox") {
//                     childWidget = PhanTu_Control.getControlWidget(
//                       id: control.id,
//                       size: Size(
//                         size.width,
//                         size.height - 65.0,
//                       ), //-56 là cái bar ở trên
//                       inMenu: false,
//                       value: {
//                         "data":
//                             connectedDeviceName.isEmpty
//                                 ? "Please turn on bluetooth!"
//                                 : connectedDeviceName,
//                       },
//                       config: control.config,
//                       NoteshowKey: NoteShowKey,
//                       lock: shouldLock,
//                       onSave: (newConfig) {
//                         setState(() {
//                           if (placedControls.any(
//                             (item) => item.id == 'ListBoxTester',
//                           )) {
//                             valueofid2 = "${control.id} - ${control.realId}";
//                             value3 = newConfig;
//                           }
//                           placedControls[index].config = newConfig;
//                         });
//                       },
//                       onDelete:
//                           (widget.isControl)
//                               ? null
//                               : () {
//                                 setState(() {
//                                   placedControls.removeAt(index);
//                                 });
//                               },
//                     );
//                   } else {
//                     childWidget = PhanTu_Control.getControlWidget(
//                       id: control.id,
//                       size: Size(
//                         size.width,
//                         size.height - 65.0,
//                       ), //-56 là cái bar ở trên
//                       inMenu: false,
//                       value:
//                           havedata
//                               ? kIsWeb
//                                   ? mockData
//                                   : dynamicData
//                               : null,
//                       config: control.config,
//                       NoteshowKey: NoteShowKey,
//                       lock: shouldLock,
//                       sendCommand: (msg) async {
//                         if (placedControls.any(
//                           (item) => item.id == 'ListBoxTester',
//                         )) {
//                           setState(() {
//                             valueofid1 = "${control.id} - ${control.realId}";
//                             value1 = msg;
//                           });
//                         }
//                         if (connectedDeviceName != "Not connected to robot") {
//                           _bluetoothService.sendMessage(msg);
//                           await Future.delayed(
//                             const Duration(milliseconds: 100),
//                           );
//                         }
//                       },
//                       onSave: (newConfig) {
//                         setState(() {
//                           if (placedControls.any(
//                             (item) => item.id == 'ListBoxTester',
//                           )) {
//                             valueofid2 = "${control.id} - ${control.realId}";
//                             value3 = newConfig;
//                           }
//                           placedControls[index].config = newConfig;
//                         });
//                       },
//                       VoiceTextToCommand:
//                           control.id == "mic"
//                               ? (String msg) async {
//                                 if (msg.isNotEmpty) {
//                                   moveMotor(msg);
//                                 } else {
//                                   debugPrint(
//                                     "Lệnh rỗng, không gửi qua bluetooth.",
//                                   );
//                                 }
//                                 if (placedControls.any(
//                                   (item) => item.id == 'ListBoxTester',
//                                 )) {
//                                   setState(() {
//                                     value2 = msg;
//                                   });
//                                 }
//                               }
//                               : null,
//                       onDelete:
//                           (widget.isControl)
//                               ? null
//                               : () {
//                                 setState(() {
//                                   placedControls.removeAt(index);
//                                 });
//                               },
//                     );
//                   }

//                   return DraggableControl(
//                     key: ValueKey(control.realId),
//                     initialPosition: Offset(xOffset, yOffset),
//                     screenSize: Size(size.width, size.height - 65.0),
//                     elementSize: Size(width, height),
//                     isEditing: canMove,
//                     onDrop: (newOffset) {
//                       setState(() {
//                         control.relativePosition = Offset(
//                           newOffset.dx / size.width,
//                           newOffset.dy / size.height,
//                         );
//                       });
//                     },
//                     // child:
//                     //     tooltipMessage != null
//                     //         ? Tooltip(
//                     //           message: tooltipMessage,
//                     //           preferBelow: false,
//                     //           waitDuration: const Duration(milliseconds: 500),
//                     //           child: childWidget,
//                     //         )
//                     //         : childWidget,
//                     child: Tooltip(
//                       message: tooltipMessage ?? '',
//                       preferBelow: false,
//                       waitDuration: const Duration(milliseconds: 500),
//                       child:
//                           isEditingLayout
//                               ? Container(
//                                 decoration: BoxDecoration(
//                                   border: Border.all(
//                                     color:
//                                         canMove
//                                             ? const Color.fromARGB(
//                                               190,
//                                               64,
//                                               195,
//                                               255,
//                                             )
//                                             : const Color.fromARGB(
//                                               190,
//                                               255,
//                                               82,
//                                               82,
//                                             ),
//                                     width: 2,
//                                   ),
//                                   borderRadius: BorderRadius.circular(
//                                     8,
//                                   ), // Tuỳ chỉnh nếu widget bo góc
//                                 ),
//                                 child: childWidget,
//                               )
//                               : childWidget,
//                     ),
//                   );
//                 }),
//               ],
//             );
//           },
//         ),

//         // Positioned(
//         //   top: 8,
//         //   left: 8,
//         //   child: IconButton(
//         //     icon: const Icon(
//         //       Icons.arrow_back,
//         //       color: Color.fromARGB(255, 68, 137, 255),
//         //     ),
//         //     onPressed: () {
//         //       if (widget.isControl) {
//         //         Navigator.of(context).pop();
//         //       } else {
//         //         final _navigator = Navigator.of(context);
//         //         if (haveSave) {
//         //           if (_navigator.mounted) {
//         //             _navigator.pop(true);
//         //           }
//         //         } else {
//         //           if (!kIsWeb) {
//         //             showDialog(
//         //               context: context,
//         //               builder:
//         //                   (ctx) => AlertDialog(
//         //                     title: const Text("Layout not saved"),
//         //                     content: const Text(
//         //                       "Do you want to save the layout before exiting?",
//         //                     ),
//         //                     actions: [
//         //                       TextButton(
//         //                         onPressed: () {
//         //                           Navigator.of(ctx).pop();
//         //                           if (_navigator.mounted) {
//         //                             _navigator.pop(false);
//         //                           }
//         //                         },
//         //                         child: const Text("No"),
//         //                       ),
//         //                       TextButton(
//         //                         onPressed: () {
//         //                           Navigator.of(
//         //                             ctx,
//         //                           ).pop(); // Đóng dialog xác nhận
//         //                           showSaveDialog(
//         //                             context, // Sử dụng context của IconButton thay vì _navigator.context
//         //                             onSaveNew: (String name) async {
//         //                               final savedName =
//         //                                   await IotLayoutProject.saveLayout(
//         //                                     name,
//         //                                     placedControls,
//         //                                   );
//         //                               if (!mounted) return;
//         //                               _navigator.pop(true);
//         //                               ScaffoldMessenger.of(
//         //                                 context,
//         //                               ).showSnackBar(
//         //                                 SnackBar(
//         //                                   content: Text(
//         //                                     '✅ Layout "$savedName" saved successfully!',
//         //                                   ),
//         //                                 ),
//         //                               );
//         //                             },
//         //                             onOverwrite: (String name) async {
//         //                               final success =
//         //                                   await IotLayoutProject.updateLayout(
//         //                                     name,
//         //                                     placedControls,
//         //                                   );
//         //                               if (success) {
//         //                                 if (!mounted) return;
//         //                                 _navigator.pop(true);
//         //                                 ScaffoldMessenger.of(
//         //                                   context,
//         //                                 ).showSnackBar(
//         //                                   SnackBar(
//         //                                     content: Text(
//         //                                       '✅ Successfully overwritten layout "$name"!',
//         //                                     ),
//         //                                   ),
//         //                                 );
//         //                               } else {
//         //                                 ScaffoldMessenger.of(
//         //                                   context,
//         //                                 ).showSnackBar(
//         //                                   SnackBar(
//         //                                     content: Text(
//         //                                       '❌ Cannot override layout "$name"!',
//         //                                     ),
//         //                                   ),
//         //                                 );
//         //                               }
//         //                             },
//         //                           );
//         //                         },
//         //                         child: const Text("Yes"),
//         //                       ),
//         //                     ],
//         //                   ),
//         //             );
//         //           } else {
//         //             _navigator.pop();
//         //           }
//         //         }
//         //       }
//         //     },
//         //     splashColor: const Color.fromARGB(0, 0, 0, 0),
//         //     highlightColor: const Color.fromARGB(0, 0, 0, 0),
//         //   ),
//         // ),
//         // Positioned(top: 0, right: 0, child: buildTopBar(context, locale)),

//         // Màn che + Menu bên phải
//         if (isEditingLayout)
//           Stack(
//             children: [
//               // Nền mờ để tắt menu khi nhấn ra ngoài
//               if (showMenu)
//                 GestureDetector(
//                   onTap: () => setState(() => showMenu = false),
//                   child: Container(
//                     color: const Color.fromARGB(255, 0, 0, 0).withAlpha(77),
//                   ),
//                 ),

//               AnimatedPositioned(
//                 key: const ValueKey("menu_sidebar"),
//                 duration: const Duration(milliseconds: 300),
//                 curve: Curves.easeOut,
//                 top: 0,
//                 bottom: 0,
//                 right: showMenu && loadDone ? 0 : -350,
//                 width: 250,
//                 child: SingleChildScrollView(
//                   controller: _scrollController,
//                   child: Container(
//                     color: Theme.of(context).scaffoldBackgroundColor,
//                     padding: const EdgeInsets.all(10),
//                     child: Builder(
//                       builder: (_) {
//                         List<Widget> widgets = [];
//                         for (int i = 0; i < groupedTitles.length; i++) {
//                           final title = groupedTitles[i];
//                           final controls = groupedControls[title]!;
//                           // final key = GlobalKey();
//                           // sectionKeys[title] = key;
//                           final color = groupColors[i % groupColors.length];
//                           widgets.add(
//                             Container(
//                               width: 230,
//                               key: sectionKeys[title],
//                               color: color,
//                               padding: const EdgeInsets.all(5),
//                               child: Padding(
//                                 padding: const EdgeInsets.only(bottom: 10),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       title == "jt"
//                                           ? LocalizedStringGetter.Control_get(
//                                             context,
//                                             title,
//                                           )
//                                           : LocalizedStringGetter.IOT_get(
//                                             context,
//                                             title,
//                                           ),
//                                       style: const TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 8),
//                                     Wrap(
//                                       spacing: 10,
//                                       runSpacing: 10,
//                                       children:
//                                           controls.map((control) {
//                                             final id = control['id'];
//                                             final name = control['name'] ?? id;
//                                             final configRaw = control['config'];
//                                             final config =
//                                                 configRaw == null
//                                                     ? <String, dynamic>{}
//                                                     : Map<String, dynamic>.from(
//                                                       configRaw,
//                                                     );

//                                             return Column(
//                                               mainAxisSize: MainAxisSize.min,
//                                               children: [
//                                                 LongPressDraggable<String>(
//                                                   // hoặc Draggable<String>( nếu muốn chạm vào là kéo lun
//                                                   data: id,
//                                                   feedback:
//                                                       PhanTu_Control.getControlWidget(
//                                                         id: id,
//                                                         size: size,
//                                                         config: config,
//                                                         isPreview: true,
//                                                         inMenu: true,
//                                                         lock: true,
//                                                       ),
//                                                   onDragStarted:
//                                                       () => setState(
//                                                         () => showMenu = false,
//                                                       ),
//                                                   child: AbsorbPointer(
//                                                     absorbing: true,
//                                                     child:
//                                                         PhanTu_Control.getControlWidget(
//                                                           id: id,
//                                                           size: size,
//                                                           config: config,
//                                                           isPreview: true,
//                                                           inMenu: true,
//                                                           lock: true,
//                                                         ),
//                                                   ),
//                                                 ),
//                                                 const SizedBox(height: 4),
//                                                 Text(
//                                                   (name.contains("jt")
//                                                       ? LocalizedStringGetter.Control_get(
//                                                         context,
//                                                         name,
//                                                       )
//                                                       : LocalizedStringGetter.IOT_get(
//                                                         context,
//                                                         name,
//                                                       )),
//                                                   style: const TextStyle(
//                                                     fontSize: 12,
//                                                   ),
//                                                 ),
//                                               ],
//                                             );
//                                           }).toList(),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           );
//                         }

//                         return Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: widgets,
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//               ),
//               // Nút điều hướng nhóm
//               AnimatedPositioned(
//                 key: const ValueKey("menu_sidebar_scroll"),
//                 duration: const Duration(milliseconds: 300),
//                 curve: Curves.easeOut,
//                 top: 10,
//                 right: showMenu && loadDone ? 260 : -250, // Đẩy ra ngoài khi ẩn
//                 child: SingleChildScrollView(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: List.generate(groupedTitles.length, (index) {
//                       final title = groupedTitles[index];
//                       final key = sectionKeys[title]!;
//                       final color = groupColors[index % groupColors.length];
//                       return Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 4),
//                         child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: color,
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 12,
//                               vertical: 8,
//                             ),
//                           ),
//                           onPressed: () {
//                             setState(() => showMenu = true);

//                             WidgetsBinding.instance.addPostFrameCallback((_) {
//                               final contextTarget = key.currentContext;
//                               if (contextTarget == null) {
//                                 debugPrint("❗ contextTarget vẫn null: $title");
//                                 return;
//                               }

//                               // Tìm context của scroll view để tính chính xác offset
//                               final scrollContext = scrollViewContext;
//                               // if (scrollContext == null) {
//                               //   debugPrint("⚠️ scrollViewContext null");
//                               //   return;
//                               // }

//                               final box =
//                                   contextTarget.findRenderObject() as RenderBox;
//                               final scrollBox =
//                                   scrollContext.findRenderObject() as RenderBox;

//                               final offset = box.localToGlobal(
//                                 Offset.zero,
//                                 ancestor: scrollBox,
//                               );
//                               final targetOffset =
//                                   _scrollController.offset + offset.dy - 10;

//                               _scrollController.animateTo(
//                                 targetOffset,
//                                 duration: const Duration(milliseconds: 500),
//                                 curve: Curves.easeInOut,
//                               );
//                             });
//                           },
//                           child: Text(
//                             title.contains("jt")
//                                 ? LocalizedStringGetter.Control_get(
//                                   context,
//                                   title,
//                                 )
//                                 : LocalizedStringGetter.IOT_get(context, title),
//                             style: const TextStyle(fontSize: 12),
//                           ),
//                         ),
//                       );
//                     }),
//                   ),
//                 ),
//               ),
//             ],
//           ),

//         // Drag target để thả button
//         if (isEditingLayout)
//           DragTarget<String>(
//             onAcceptWithDetails: (details) {
//               handleDrop(details.data, details.offset, size);
//               setState(() => showMenu = true);
//             },
//             builder:
//                 (context, candidateData, rejectedData) =>
//                     const SizedBox.expand(),
//           ),
//       ],
//     );
//   }
// }

// class DragController {
//   final ValueNotifier<Offset> currentOffset = ValueNotifier(Offset.zero);

//   late Offset startOffset;
//   late Size screenSize;
//   late Size elementSize;

//   void startDrag(Offset initialOffset, Size screenSize, Size elementSize) {
//     startOffset = initialOffset;
//     this.screenSize = screenSize;
//     this.elementSize = elementSize;
//     currentOffset.value = initialOffset;
//   }

//   void updateDrag(Offset delta) {
//     final newOffset = Offset(
//       (currentOffset.value.dx + delta.dx).clamp(
//         0.0,
//         screenSize.width - elementSize.width,
//       ),
//       (currentOffset.value.dy + delta.dy).clamp(
//         0.0,
//         screenSize.height - elementSize.height,
//       ),
//     );
//     currentOffset.value = newOffset;
//   }

//   void endDrag() {
//     // optional logic
//   }
// }

// class DraggableControl extends StatefulWidget {
//   final Widget child;
//   final Offset initialPosition;
//   final Size screenSize;
//   final Size elementSize;
//   final Function(Offset) onDrop;
//   final bool isEditing;

//   const DraggableControl({
//     super.key,
//     required this.child,
//     required this.initialPosition,
//     required this.screenSize,
//     required this.elementSize,
//     required this.onDrop,
//     required this.isEditing,
//   });

//   @override
//   State<DraggableControl> createState() => _DraggableControlState();
// }

// class _DraggableControlState extends State<DraggableControl> {
//   final DragController dragController = DragController();

//   @override
//   void initState() {
//     super.initState();
//     dragController.startDrag(
//       widget.initialPosition,
//       widget.screenSize,
//       widget.elementSize,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     dragController.screenSize = widget.screenSize;
//     dragController.elementSize = widget.elementSize;

//     // Clamp lại vị trí nếu cần
//     final clampedOffset = Offset(
//       dragController.currentOffset.value.dx.clamp(
//         0.0,
//         dragController.screenSize.width - dragController.elementSize.width,
//       ),
//       dragController.currentOffset.value.dy.clamp(
//         0.0,
//         dragController.screenSize.height - dragController.elementSize.height,
//       ),
//     );
//     if (clampedOffset != dragController.currentOffset.value) {
//       dragController.currentOffset.value = clampedOffset; // Cập nhật trực tiếp
//     }

//     return ValueListenableBuilder<Offset>(
//       valueListenable: dragController.currentOffset,
//       builder: (context, offset, _) {
//         return Positioned(
//           left: offset.dx,
//           top: offset.dy,
//           child: GestureDetector(
//             onPanUpdate:
//                 widget.isEditing
//                     ? (details) => dragController.updateDrag(details.delta)
//                     : null,
//             onPanEnd:
//                 widget.isEditing
//                     ? (_) => widget.onDrop(dragController.currentOffset.value)
//                     : null,
//             child: widget.child,
//           ),
//         );
//       },
//     );
//   }
// }

// void showSaveDialog(
//   BuildContext context, {
//   required Function(String) onSaveNew,
//   required Function(String) onOverwrite,
// }) async {
//   final savedLayouts = await IotLayoutProject.getSavedLayoutNames();
//   final TextEditingController controller = TextEditingController(
//     text: "United",
//   );

//   showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder:
//         (_) => MediaQuery.removeViewInsets(
//           context: context,
//           removeBottom: true,
//           child: DefaultTabController(
//             length: 2,
//             child: AlertDialog(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               insetPadding: const EdgeInsets.all(
//                 16,
//               ), // giới hạn kích thước dialog
//               contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
//               title: const TabBar(
//                 tabs: [Tab(text: 'Save New'), Tab(text: 'Overwrite')],
//               ),
//               content: SingleChildScrollView(
//                 child: SizedBox(
//                   width: 400,
//                   height: 300,
//                   child: TabBarView(
//                     children: [
//                       // ===== TAB 1: LƯU MỚI =====
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.stretch,
//                         children: [
//                           const Text(
//                             "Name Project",
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           const SizedBox(height: 8),
//                           TextField(
//                             controller: controller,
//                             maxLength: 50,
//                             decoration: const InputDecoration(
//                               hintText: "Enter project name...",
//                               border: OutlineInputBorder(),
//                             ),
//                           ),
//                           const SizedBox(height: 16),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.end,
//                             children: [
//                               TextButton(
//                                 onPressed: () => Navigator.of(context).pop(),
//                                 child: const Text("Cancel"),
//                               ),
//                               ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: const Color.fromARGB(
//                                     255,
//                                     76,
//                                     175,
//                                     79,
//                                   ),
//                                 ),
//                                 onPressed: () {
//                                   final name = controller.text.trim();
//                                   if (name.isNotEmpty) {
//                                     onSaveNew(name);
//                                     Navigator.of(context).pop();
//                                   }
//                                 },
//                                 child: const Text("Save"),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),

//                       // ===== TAB 2: GHI ĐÈ =====
//                       SingleChildScrollView(
//                         child: ListView.builder(
//                           shrinkWrap: true,
//                           physics: const NeverScrollableScrollPhysics(),
//                           itemCount: savedLayouts.length,
//                           itemBuilder: (context, index) {
//                             final name = savedLayouts[index];
//                             return ListTile(
//                               title: Text(name),
//                               trailing: IconButton(
//                                 icon: const Icon(Icons.save),
//                                 onPressed: () {
//                                   showDialog(
//                                     context: context,
//                                     builder:
//                                         (_) => AlertDialog(
//                                           title: const Text("Confirm"),
//                                           content: Text(
//                                             'Overwrite project "$name"?',
//                                           ),
//                                           actions: [
//                                             TextButton(
//                                               onPressed:
//                                                   () => Navigator.pop(context),
//                                               child: const Text("Cancel"),
//                                             ),
//                                             ElevatedButton(
//                                               onPressed: () {
//                                                 Navigator.pop(
//                                                   context,
//                                                 ); // close confirm
//                                                 Navigator.pop(
//                                                   context,
//                                                 ); // close main dialog
//                                                 onOverwrite(name);
//                                               },
//                                               child: const Text("Confirm"),
//                                             ),
//                                           ],
//                                         ),
//                                   );
//                                 },
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//   );
// }
