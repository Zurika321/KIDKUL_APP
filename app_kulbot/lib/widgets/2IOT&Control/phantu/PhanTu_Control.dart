import 'package:KulBlock/widgets/2IOT&Control/phantu/Command/CommandSequenceWidget.dart';
import 'package:KulBlock/widgets/2IOT&Control/phantu/Label/Labels.dart';
import 'package:flutter/material.dart';

// import 'package:KulBlock/widgets/IOT/IOT/IOTSrceen.dart';

//thư viện
import 'package:showcaseview/showcaseview.dart'; //showcase

//Phần tử
import 'package:KulBlock/widgets/2IOT&Control/phantu/SCS/SCSWidget.dart'; //SCSWidget – hiển thị cảm biến
import 'package:KulBlock/widgets/2IOT&Control/phantu/Mic/MicWidget.dart';
import 'package:KulBlock/widgets/2IOT&Control/phantu/Chart/ChartLogic.dart';
// import 'package:KulBlock/widgets/2IOT&Control/phantu/Label/label.dart'
//     as label_widget;
import 'package:KulBlock/widgets/2IOT&Control/phantu/Label/Labels.dart';
import 'package:KulBlock/widgets/2IOT&Control/phantu/ListBox/listbox.dart';
import 'package:KulBlock/widgets/2IOT&Control/phantu/Button/ControlButtonWidget.dart';
import 'package:KulBlock/widgets/2IOT&Control/phantu/Button/HoldLightWidget.dart';
import 'package:KulBlock/widgets/2IOT&Control/phantu/Button/SwitchLightWidget.dart';
import 'package:KulBlock/widgets/2IOT&Control/phantu/Button/VolumeSliderWidget.dart';
import 'package:KulBlock/widgets/2IOT&Control/phantu/HienThi/HienThiLight.dart';
import 'package:KulBlock/widgets/2IOT&Control/phantu/ListBox/listbox_tester.dart';
import 'package:KulBlock/widgets/2IOT&Control/phantu/JoyStick/Joystick360degrees.dart';
import 'package:KulBlock/widgets/2IOT&Control/phantu/JoyStick/JoystickHorizontal.dart';
import 'package:KulBlock/widgets/2IOT&Control/phantu/JoyStick/JoystickVertical.dart';

//Mẫu và Class lưu trữ file txt
// import 'package:KulBlock/widgets/IOT/Sample%26Data/ControlLayoutProvider.dart'; //Mẫu Layout
// import 'package:KulBlock/widgets/IOT/Sample%26Data/IotLayoutProvider.dart'; //Lưu Layout

class PhanTu_Control {
  static Map<String, Map<String, dynamic>> controlGroups = {
    //Đừng để id bắt đầu giống nhau vd: mic và micshowkey
    'JoyStick360_': {
      'title': 'jt',
      'name': "jt360",
      'size': [0, 125, 0, 125],
      'sizeInMenu': [0, 105, 0, 105],
      // 'typeBox': "height",
      'max': 1,
      'config': {'title': 'Light', 'on': 'OO', 'off': 'PP', "showkey": "jt360"},
      'widgetBuilder':
          (
            Map<String, dynamic> config,
            Map<String, dynamic> value,
            Function(Map<String, dynamic>)? onSave,
            VoidCallback? onDelete,
            Future<void> Function(String msg)? sendCommand,
            bool inMenu,
          ) => Joystick360degrees(
            config: config,
            lock: config['lock'] == true,
            sendCommand: sendCommand,
            onSave: onSave,
            onDelete: onDelete,
            // inMenu: inMenu,
          ),
    },
    'JoyStickH': {
      'title': 'jt',
      'name': "jth",
      'size': [0, 125, 0, 125],
      'sizeInMenu': [0, 105, 0, 105],
      // 'typeBox': "height",
      'max': 1,
      'config': {'title': 'Light', 'on': 'OO', 'off': 'PP', "showkey": "jth"},
      'widgetBuilder':
          (
            Map<String, dynamic> config,
            Map<String, dynamic> value,
            Function(Map<String, dynamic>)? onSave,
            VoidCallback? onDelete,
            Future<void> Function(String msg)? sendCommand,
            bool inMenu,
          ) => JoystickHorizontal(
            config: config,
            lock: config['lock'] == true,
            sendCommand: sendCommand,
            onSave: onSave,
            onDelete: onDelete,
            // inMenu: inMenu,
          ),
    },
    'JoyStickV': {
      'title': 'jt',
      'name': "jtv",
      'size': [0, 125, 0, 125],
      'sizeInMenu': [0, 105, 0, 105],
      // 'typeBox': "height",
      'max': 1,
      'config': {'title': 'Light', 'on': 'OO', 'off': 'PP', "showkey": "jtv"},
      'widgetBuilder':
          (
            Map<String, dynamic> config,
            Map<String, dynamic> value,
            Function(Map<String, dynamic>)? onSave,
            VoidCallback? onDelete,
            Future<void> Function(String msg)? sendCommand,
            bool inMenu,
          ) => JoystickVertical(
            config: config,
            lock: config['lock'] == true,
            sendCommand: sendCommand,
            onSave: onSave,
            onDelete: onDelete,
            // inMenu: inMenu,
          ),
    },
    'Button_light': {
      'title': 'control buttons',
      'name': "Button",
      'size': [0.1, 0, 0.1, 0],
      'sizeInMenu': [0, 50, 0, 50],
      'typeBox': "height",
      'max': 3,
      'config': {
        'title': 'Light',
        'on': 'OO',
        'off': 'PP',
        "showkey": "button",
      },
      'widgetBuilder':
          (
            Map<String, dynamic> config,
            Map<String, dynamic> value,
            Function(Map<String, dynamic>)? onSave,
            VoidCallback? onDelete,
            Future<void> Function(String msg)? sendCommand,
            bool inMenu,
          ) => ControlButtonWidget(
            config: config,
            lock: config['lock'] == true,
            sendCommand: sendCommand,
            onSave: onSave,
            onDelete: onDelete,
            // inMenu: inMenu,
          ),
    },
    'HoldLight': {
      'title': 'control buttons',
      'name': 'Hold Button',
      'typeBox': "height",
      'size': [0.1, 0, 0.1, 0],
      'sizeInMenu': [0, 50, 0, 50],
      'max': 4,
      'config': {'on': 'OO', 'off': 'PP', "showkey": "hold_button"},
      'widgetBuilder':
          (
            Map<String, dynamic> config,
            Map<String, dynamic> value,
            Function(Map<String, dynamic>)? onSave,
            VoidCallback? onDelete,
            Future<void> Function(String msg)? sendCommand,
            bool inMenu,
          ) => HoldButtonWidget(
            config: config,
            lock: config['lock'] == true,
            sendCommand: sendCommand,
            onSave: onSave,
            onDelete: onDelete,
            // inMenu: inMenu,
          ),
    },
    'SwitchButton': {
      'title': 'control buttons',
      'name': 'Switch Button',
      'typeBox': "height",
      'size': [0.1, 0, 0.1, 0],
      'sizeInMenu': [0, 50, 0, 50],
      'max': 4,
      'config': {'on': 'OO', 'off': 'PP', "showkey": "switch_button"},
      'widgetBuilder':
          (
            Map<String, dynamic> config,
            Map<String, dynamic> value,
            Function(Map<String, dynamic>)? onSave,
            VoidCallback? onDelete,
            Future<void> Function(String msg)? sendCommand,
            bool inMenu,
          ) => SwitchButtonWidget(
            config: config,
            lock: config['lock'] == true,
            sendCommand: sendCommand,
            onSave: onSave,
            onDelete: onDelete,
            // inMenu: inMenu,
          ),
    },
    'mic': {
      'title': 'control buttons',
      'name': 'Mic',
      'size': [0.1, 0, 0.1, 0],
      'sizeInMenu': [0, 50, 0, 50],
      'typeBox': "height",
      'max': 1,
      'config': {"showkey": "mic"},
    },
    'volume': {
      'title': 'control buttons',
      'name': 'Volume',
      'typeBox': 'height',
      'size': [0, 210, 0, 60],
      'sizeInMenu': [0, 210, 0, 60],
      'max': 1,
      'getData': true,
      'config': {'title': 'Volume', "showkey": "volume"},
      'widgetBuilder':
          (
            Map<String, dynamic> config,
            Map<String, dynamic> value,
            Function(Map<String, dynamic>)? onSave,
            VoidCallback? onDelete,
            Future<void> Function(String msg)? sendCommand,
            bool inMenu,
          ) => VolumeSliderWidget(
            value: value,
            lock: config['lock'] == true,
            onDelete: onDelete,
            // inMenu: inMenu,
            config: config,
            onSave: onSave,
            sendCommand: sendCommand,
          ),
    },
    'Labels': {
      'title': 'data tables',
      'name': 'Labels',
      'size': [0, 200, 0, 80],
      'sizeInMenu': [0, 160, 0, 150],
      'typeBox': "height",
      'max': 5,
      'getData': true,
      'config': {"showkey": "Labels"},
      'widgetBuilder':
          (
            Map<String, dynamic> config,
            Map<String, dynamic> value,
            Function(Map<String, dynamic>)? onSave,
            VoidCallback? onDelete,
            Future<void> Function(String msg)? sendCommand,
            bool inMenu,
          ) => Labels(
            config: config,
            value: value,
            onDelete: onDelete,
            onSave: onSave,
            inMenu: inMenu,
          ),
    },
    // 'LabelString': {
    //   'title': 'data tables',
    //   'name': 'Label String',
    //   'size': [0.3, 50, 0.2, 50],
    //   'sizeInMenu': [0, 105, 0, 105],
    //   'typeBox': "height",
    //   'max': 1,
    //   'getData': true,
    //   'config': {"showkey": "label_string"},
    //   'widgetBuilder':
    //       (
    //         Map<String, dynamic> config,
    //         Map<String, dynamic> value,
    //         Function(Map<String, dynamic>)? onSave,
    //         VoidCallback? onDelete,
    //         Future<void> Function(String msg)? sendCommand,
    //         bool inMenu,
    //       ) => label_widget.Label(
    //         config: config,
    //         value: value,
    //         onDelete: onDelete,
    //         onSave: onSave,
    //         dataDouble: false,
    //         inMenu: inMenu,
    //       ),
    // },
    // 'LabelDouble': {
    //   'title': 'data tables',
    //   'name': 'Label Double',
    //   'size': [0.3, 50, 0.2, 50],
    //   'sizeInMenu': [0, 105, 0, 105],
    //   'typeBox': "height",
    //   'max': 1,
    //   'getData': true,
    //   'config': {"showkey": "label_double"},
    //   'widgetBuilder':
    //       (
    //         Map<String, dynamic> config,
    //         Map<String, dynamic> value,
    //         Function(Map<String, dynamic>)? onSave,
    //         VoidCallback? onDelete,
    //         Future<void> Function(String msg)? sendCommand,
    //         bool inMenu,
    //       ) => label_widget.Label(
    //         config: config,
    //         value: value,
    //         onDelete: onDelete,
    //         onSave: onSave,
    //         dataDouble: true,
    //         inMenu: inMenu,
    //       ),
    // },
    'Light': {
      'title': 'data tables',
      'name': 'Light',
      'typeBox': "height",
      'size': [0.1, 0, 0.1, 0],
      'sizeInMenu': [0, 50, 0, 50],
      'max': 4,
      'getData': true,
      'config': {"showkey": "light"},
      'widgetBuilder':
          (
            Map<String, dynamic> config,
            Map<String, dynamic> value,
            Function(Map<String, dynamic>)? onSave,
            VoidCallback? onDelete,
            Future<void> Function(String msg)? sendCommand,
            bool inMenu,
          ) => Hienthilight(
            config: config,
            value: value,
            onSave: onSave,
            onDelete: onDelete,
            inMenu: inMenu,
          ),
    },
    'SCSWidget': {
      'title': 'data tables',
      'name': 'SCS',
      'size': [0.3, 0, 0.3, 0],
      'sizeInMenu': [0, 220, 0, 220],
      'typeBox': "width",
      'max': 3,
      'getData': true,
      'config': {'title': 'Temp', 'unit': '˚C', "showkey": "scs"},
      'widgetBuilder':
          (
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
            onSave: onSave,
            inMenu: inMenu,
          ),
    },
    'CustomChart': {
      'title': 'data tables',
      'name': 'Chart',
      'size': [0.4, 0, 0.3, 0],
      'sizeInMenu': [0, 220, 0, 220],
      'typeBox': "width",
      'max': 3,
      'getData': true,
      'config': {"visibleCount": 10, "showkey": "chart"},
      'widgetBuilder':
          (
            Map<String, dynamic> config,
            Map<String, dynamic> value,
            Function(Map<String, dynamic>)? onSave,
            VoidCallback? onDelete,
            Future<void> Function(String msg)? sendCommand,
            bool inMenu,
          ) => CustomChart(
            config: config,
            value: value,
            onSave: onSave,
            onDelete: onDelete,
            inMenu: inMenu,
          ),
    },
    'Status': {
      'title': 'Status',
      'name': 'Bluetooth Status',
      'size': [0, 150, 0, 80],
      'sizeInMenu': [0, 220, 0, 40],
      'typeBox': "height",
      'max': 1,
      'config': {'showkey': "listbox"},
      'widgetBuilder':
          (
            Map<String, dynamic> config,
            Map<String, dynamic> value,
            Function(Map<String, dynamic>)? onSave,
            VoidCallback? onDelete,
            Future<void> Function(String msg)? sendCommand,
            bool inMenu,
          ) => ListBox(
            config: config,
            value: value,
            onDelete: onDelete,
            onSave: onSave,
          ),
    },
    'ListBoxTester': {
      'title': 'Tester',
      'name': 'ListBox Tester',
      'size': [0, 150, 0, 200],
      'sizeInMenu': [0, 220, 0, 150],
      'typeBox': "height",
      'max': 1,
      'config': {"showkey": "listbox_tester"},
      'widgetBuilder':
          (
            Map<String, dynamic> config,
            Map<String, dynamic> value,
            Function(Map<String, dynamic>)? onSave,
            VoidCallback? onDelete,
            Future<void> Function(String msg)? sendCommand,
            bool inMenu,
          ) => ListBoxTester(
            config: config,
            value: value,
            onDelete: onDelete,
            onSave: onSave,
          ),
    },
    'Command': {
      'title': 'Tester',
      'name': 'Command',
      'size': [0, 150, 0, 200],
      'sizeInMenu': [0, 220, 0, 150],
      'typeBox': "height",
      'max': 1,
      'config': {"showkey": "Command"},
      'widgetBuilder':
          (
            Map<String, dynamic> config,
            Map<String, dynamic> value,
            Function(Map<String, dynamic>)? onSave,
            VoidCallback? onDelete,
            Future<void> Function(String msg)? sendCommand,
            bool inMenu,
          ) => CommandSequenceWidget(
            config: config,
            lock: config['lock'] == true,
            sendCommand: sendCommand,
            onSave: onSave,
            onDelete: onDelete,
          ),
    },
  };

  static String getTypeBoxById(String id) {
    final group = controlGroups[id];
    if (group != null && group.containsKey('typeBox')) {
      return group['typeBox'] ?? 'none';
    }
    return 'none';
  }

  // static String getTitleById(String id) {
  //   final group = controlGroups[id];
  //   if (group != null && group.containsKey('title')) {
  //     return group['title'] ?? 'Không có tiêu đề';
  //   }
  //   return 'Không có tiêu đề';
  // }

  static bool getGetDataById(String id) {
    final group = controlGroups[id];
    if (group != null && group.containsKey('getData')) {
      return group['getData'] ?? false;
    }
    return false;
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
    // Size size,
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
            // Size,
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

  static String getNoteShowKey(BuildContext context, String id) {
    final group = controlGroups[id];
    if (group != null && group.containsKey('config')) {
      if (group['config'].isNotEmpty &&
          group['config'].containsKey('showkey')) {
        return group['config']['showkey'];
      }
    }
    return "No description";
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
    String? NoteshowKey,
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

    width = width.clamp(50.0, size.width);
    height = height.clamp(50.0, size.height);

    config ??= <String, dynamic>{};
    value ??= <String, dynamic>{};
    config['lock'] = lock;
    config["width"] ??= width;
    config["height"] ??= height;

    Widget? Customrieng;

    if (id == "mic") {
      Customrieng = MicShowKeyWidget(
        config: config,
        onSave: onSave ?? (Map<String, dynamic> _) {},
        onDelete: onDelete ?? () {},
        lock: lock,
        voiceTextToCommand: VoiceTextToCommand,
      );
    } //trường hợp tự custom

    final bool useShowKey = NoteshowKey != null && !inMenu && !isPreview;

    if (Customrieng != null) {
      return useShowKey
          ? ShowKeyWrapper(
            keyShowcase:
                ShowKeyManager.getKey(id) ?? ShowKeyManager.createKey(id),
            description: NoteshowKey,
            child: Customrieng,
          )
          : Customrieng;
    }

    final builder = getWidgetBuilderById(id);
    if (builder != null) {
      final Widget builtWidget = builder(
        // Size(width, height),
        config,
        value,
        onSave,
        onDelete,
        sendCommand,
        isSmall,
      );

      return useShowKey
          ? ShowKeyWrapper(
            keyShowcase:
                ShowKeyManager.getKey(id) ?? ShowKeyManager.createKey(id),
            description: NoteshowKey,
            child: builtWidget,
          )
          : builtWidget;
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
  static GlobalKey? getKey(String id) => _keys[id];

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
