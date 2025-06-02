import 'package:Kulbot/widgets/IOT/phantu/ControlMicWidget.dart';
import 'package:flutter/material.dart';

import 'package:Kulbot/widgets/IOT/IOT/IOTSrceen.dart';

//thư viện
import 'package:showcaseview/showcaseview.dart'; //showcase

//Phần tử
import 'package:Kulbot/widgets/IOT/phantu/SCSWidget.dart'; //SCSWidget – hiển thị cảm biến
// import 'package:Kulbot/widgets/IOT/phantu/SwitchControlWidget.dart'; //SwitchControlWidget – hiển thị công tắc
// import 'package:Kulbot/widgets/IOT/SliderControlWidget.dart'; //SliderControlWidget – hiển thị thanh trượt
import 'package:Kulbot/widgets/IOT/phantu/MicWIdget.dart';
import 'package:Kulbot/widgets/IOT/phantu/Chart/ChartLogic.dart';
import 'package:Kulbot/widgets/IOT/phantu/ControlButtonWidget.dart';

//Mẫu và Class lưu trữ file txt
// import 'package:Kulbot/widgets/IOT/Sample%26Data/ControlLayoutProvider.dart'; //Mẫu Layout
// import 'package:Kulbot/widgets/IOT/Sample%26Data/IotLayoutProvider.dart'; //Lưu Layout

class PhanTu_IOT {
  static Map<String, Map<String, dynamic>> controlGroups = {
    'light': {
      'title': 'Các nút điều khiển',
      'name': 'Đèn',
      'size': [0.1, 0, 0.1, 0],
      'sizeInMenu': [0, 50, 0, 50],
      'typeBox': "height",
      'max': 3,
      'config': {'title': 'Đèn', 'on': 'OO', 'off': 'PP'},
      'widgetBuilder':
          (
            Size size,
            Map<String, dynamic> config,
            Map<String, dynamic> value,
            Function(Map<String, dynamic>)? onSave,
            VoidCallback? onDelete,
            Future<void> Function(String msg)? sendCommand,
            bool inMenu,
          ) => ControlButtonWidget(
            config: config,
            size: Size(size.width - 10, size.height - 10),
            lock: config['lock'] == true,
            sendCommand: sendCommand ?? null,
            onSave: onSave,
            onDelete: onDelete,
          ),
    },
    'mic': {
      'title': 'Các nút điều khiển',
      'name': 'Mic',
      'size': [0.1, 0, 0.1, 0],
      'sizeInMenu': [0, 40, 0, 40],
      'typeBox': "height",
      'max': 1,
      'config': {'showkey': 'đây là cái mic'},
    },
    'SCSWidget': {
      'title': 'Biểu đồ/đồ thị',
      'name': 'SCSWidget',
      'size': [0.35, 0, 0.35, 0],
      'sizeInMenu': [0, 210, 0, 210],
      'typeBox': "width",
      'max': 3,
      'valueKeys': [
        {'key': 'temp', 'default': 0},
      ],
      'config': {'title': 'Temp', 'unit': '˚C'},
      'widgetBuilder':
          (
            Size size,
            Map<String, dynamic> config,
            Map<String, dynamic> value,
            Function(Map<String, dynamic>)? onSave,
            VoidCallback? onDelete,
            Future<void> Function(String msg)? sendCommand,
            bool inMenu,
          ) => SCSWidget(
            config: config,
            value: value,
            onDelete: onDelete,
            size: Size(size.width - 10, size.height - 10),
          ),
    },
    'CustomChart': {
      'title': 'Biểu đồ/đồ thị',
      'name': 'CustomChart',
      'size': [0.4, 0, 0.3, 0],
      'sizeInMenu': [0, 210, 0, 210],
      'typeBox': "width",
      'max': 3,
      'valueKeys': [
        {
          'key': 'data',
          'default':
              {
                    'data1': [0.0],
                  }
                  as Map<String, List<double>>,
        },
        {'key': 'isCurved', 'default': true},
      ],
      'config': {"visibleCount": 10},
      'widgetBuilder':
          (
            Size size,
            Map<String, dynamic> config,
            Map<String, dynamic> value,
            Function(Map<String, dynamic>)? onSave,
            VoidCallback? onDelete,
            Future<void> Function(String msg)? sendCommand,
            bool inMenu,
          ) => CustomChart(
            size: size,
            config: config,
            value: value,
            onSave: onSave,
            onDelete: onDelete,
            inMenu: inMenu,
          ),
    },
  };

  static List<Map<String, dynamic>> getValueKeysById(String id) {
    final group = controlGroups[id];
    if (group != null) {
      if (group.containsKey("valueKeys") &&
          group["valueKeys"] != null &&
          group["valueKeys"].isNotEmpty) {
        return List<Map<String, dynamic>>.from(group["valueKeys"]);
      }
    }
    return [];
  } //lấy key tạo setValue trong class ControlValueManager

  static Map<String, dynamic> getValueMapByControl(String id, String realId) {
    final List<Map<String, dynamic>> keys = getValueKeysById(id);
    final Map<String, dynamic> valueMap = {};

    for (var item in keys) {
      final String key = item['key'];
      final String fullKey = '${realId}_$key';
      final dynamic def = item['default'];

      // Nếu chưa có giá trị thì gán default
      if (!ControlValueManager.hasValue(fullKey)) {
        ControlValueManager.setValue(fullKey, def);
      }

      // Lấy lại giá trị đã lưu (hoặc default) và ép kiểu theo kiểu của default
      dynamic rawValue = ControlValueManager.getValue(fullKey);

      // Ép kiểu thủ công dựa vào runtimeType của default
      dynamic typedValue;
      if (def is bool) {
        typedValue = rawValue is bool ? rawValue : def;
      } else if (def is int) {
        typedValue = rawValue is int ? rawValue : def;
      } else if (def is double) {
        typedValue = rawValue is double ? rawValue : def;
      } else if (def is String) {
        typedValue = rawValue is String ? rawValue : def;
      } else if (def is Map<String, List<double>>) {
        typedValue =
            rawValue is Map<String, dynamic>
                ? rawValue.map((k, v) => MapEntry(k, List<double>.from(v)))
                : def;
      } else {
        typedValue = rawValue; // fallback
      }

      valueMap[key] = typedValue;
    }

    return valueMap;
  }
  // tạo mảng Map<String,dynamic> cho value khi gọi hàm getControlWidget

  static String getTypeBoxById(String id) {
    final group = controlGroups[id];
    if (group != null && group.containsKey('typeBox')) {
      return group['typeBox'] ?? 'none';
    }
    return 'none';
  }

  static String getTitleById(String id) {
    final group = controlGroups[id];
    if (group != null && group.containsKey('title')) {
      return group['title'] ?? 'Không có tiêu đề';
    }
    return 'Không có tiêu đề';
  }

  static int getMaxById(String id) {
    final group = controlGroups[id];
    if (group != null && group.containsKey('max')) {
      return group['max'] ?? 5;
    }
    return 5;
  }

  static List<double> getControlSizeById(String id) {
    final group = controlGroups[id];
    if (group != null) {
      final sizeInMenu =
          (group['sizeInMenu'] as List)
              .map((e) => (e is int) ? e.toDouble() : e as double)
              .toList();
      final size =
          (group['size'] as List)
              .map((e) => (e is int) ? e.toDouble() : e as double)
              .toList();
      return [...sizeInMenu, ...size];
    }
    // fallback cũng phải là List<double>
    return [0.0, 50.0, 0.0, 50.0, 0.0, 80.0, 0.0, 80.0];
  }

  static Widget Function(
    Size size,
    Map<String, dynamic> config,
    Map<String, dynamic> value,
    Function(Map<String, dynamic>)? onSave,
    VoidCallback? onDelete,
    Future<void> Function(String msg)? sendCommand,
    bool inMenu,
  )?
  getWidgetBuilderById(String id) {
    final group = controlGroups[id];
    if (group != null && group.containsKey('widgetBuilder')) {
      return group['widgetBuilder']
          as Widget Function(
            Size,
            Map<String, dynamic>,
            Map<String, dynamic>,
            Function(Map<String, dynamic>)?,
            VoidCallback?,
            Future<void> Function(String msg)?,
            bool inMenu,
          )?;
    }
    return null;
  }

  static String getNoteShowKey(id) {
    final group = controlGroups[id];
    if (group != null && group.containsKey('config')) {
      if (group['config'].isNotEmpty &&
          group['config'].containsKey('showkey')) {
        return group['config']['showkey'];
      }
    }
    return "Chưa có mô tả";
  }

  static Widget getControlWidget({
    required String id,
    required Size size,
    Map<String, dynamic>? config,
    Map<String, dynamic>? value,
    bool isPreview = false,
    bool inMenu = true,
    Function(Map<String, dynamic>)? onSave,
    VoidCallback? onDelete,
    bool lock = false,
    bool showKey = false,
    Future<void> Function(String msg)? sendCommand,
    Future<void> Function(String msg)? VoiceTextToCommand,
  }) {
    final bool isSmall = isPreview || inMenu;
    final List<double> sizeInfo = getControlSizeById(id);

    final double xScale = isSmall ? sizeInfo[0] : sizeInfo[4];
    final double xOffset = isSmall ? sizeInfo[1] : sizeInfo[5];
    final double yScale = isSmall ? sizeInfo[2] : sizeInfo[6];
    final double yOffset = isSmall ? sizeInfo[3] : sizeInfo[7];

    final String typeBox = getTypeBoxById(id);

    double width =
        (typeBox == "height" ? size.height : size.width) * xScale + xOffset;
    double height =
        (typeBox == "width" ? size.width : size.height) * yScale + yOffset;

    width = width.clamp(30.0, size.width);
    height = height.clamp(30.0, size.height);

    config ??= <String, dynamic>{};
    value ??= <String, dynamic>{};
    config['lock'] = lock;

    // Trường hợp đặc biệt với joystick
    if (id == "joystick360") {
      return SizedBox(
        width: width,
        height: height,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.cyanAccent.withOpacity(isPreview ? 0.7 : 1),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text('🎮', style: TextStyle(fontSize: 24)),
          ),
        ),
      );
    }
    if (id == "mic") {
      return SizedBox(
        width: width,
        height: height,
        child: MicWidget(
          config: config,
          onSave: onSave ?? (Map<String, dynamic> _) {},
          onDelete: onDelete ?? () {},
          lock: lock,
          size: size,
          voiceTextToCommand: VoiceTextToCommand,
        ),
      );
    }

    final builder = getWidgetBuilderById(id);
    if (builder != null) {
      final Widget builtWidget = builder(
        Size(width, height),
        config,
        value,
        onSave,
        onDelete,
        sendCommand,
        isSmall,
      );

      final bool useShowKey = showKey && !inMenu && !isPreview;

      return SizedBox(
        width: width,
        height: height,
        child:
            useShowKey
                ? ShowKeyWrapper(
                  keyShowcase:
                      ShowKeyManager.getKey(id) ?? ShowKeyManager.createKey(id),
                  description: getNoteShowKey(id),
                  child: builtWidget,
                )
                : builtWidget,
      );
    }

    return const SizedBox();
  }
}

///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////

class ShowKeyManager {
  static final Map<String, GlobalKey> _keys = {};

  /// Trả về GlobalKey nếu đã tồn tại, hoặc tạo mới nếu chưa có
  static GlobalKey createKey(String id) {
    return _keys.putIfAbsent(id, () => GlobalKey());
  }

  /// Trả về GlobalKey theo id, hoặc null nếu chưa tạo
  static GlobalKey? getKey(String id) => _keys[id] ?? null;

  /// Trả về toàn bộ GlobalKey đã tạo
  static List<GlobalKey> getAllKeys() {
    printAllKeyNames();
    return _keys.values.toList();
  }

  /// Trả về danh sách GlobalKey theo thứ tự key (0-9 rồi A-Z)
  // static List<GlobalKey> getAllSortedKeys() {
  //   final sortedEntries =
  //       _keys.entries.toList()
  //         ..sort((a, b) => a.key.toLowerCase().compareTo(b.key.toLowerCase()));
  //   return sortedEntries.map((entry) => entry.value).toList();
  // } // rảnh đâu mà đặt số thứ tự :)) vd đặt tên "01huongdan" "02editmode"

  /// In ra tất cả tên key (id) đang được lưu trong ShowKeyManager
  static void printAllKeyNames() {
    for (final id in _keys.keys) {
      print(id);
    }
    print("-------------------------");
  }

  /// Xoá tất cả key (nếu cần reset)
  static void clear() => _keys.clear();
}

class ShowKeyWrapper extends StatelessWidget {
  final GlobalKey keyShowcase;
  final String description;
  final Widget child;
  // final String? label;

  const ShowKeyWrapper({
    super.key,
    required this.keyShowcase,
    required this.description,
    required this.child,
    // this.label,
  });

  @override
  Widget build(BuildContext context) {
    // return Column(
    //   children: [
    // if (label != null) ...[
    //   Text(
    //     label!,
    //     style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
    //   ),
    //   const SizedBox(height: 2),
    // ],
    return Showcase(key: keyShowcase, description: description, child: child);
    // ],
    // );
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
        // color: Colors.blue.withOpacity(0.3),
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
      // color: Colors.blue.withOpacity(0.3),
      decoration: const BoxDecoration(
        color: Colors.orangeAccent,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.volume_up, color: Colors.white),
    );
  }
}
