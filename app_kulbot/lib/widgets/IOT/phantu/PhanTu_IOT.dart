import 'package:flutter/material.dart';

// import 'package:Kulbot/widgets/IOT/IOT/IOTSrceen.dart';

//thư viện
import 'package:showcaseview/showcaseview.dart'; //showcase

//Phần tử
import 'package:Kulbot/widgets/IOT/phantu/SCS/SCSWidget.dart'; //SCSWidget – hiển thị cảm biến
// import 'package:Kulbot/widgets/IOT/phantu/SwitchControlWidget.dart'; //SwitchControlWidget – hiển thị công tắc
// import 'package:Kulbot/widgets/IOT/SliderControlWidget.dart'; //SliderControlWidget – hiển thị thanh trượt
import 'package:Kulbot/widgets/IOT/phantu/Mic/MicWIdget.dart';
// import 'package:Kulbot/widgets/IOT/phantu/Mic/ControlMicWidget.dart';
import 'package:Kulbot/widgets/IOT/phantu/Chart/ChartLogic.dart';
import 'package:Kulbot/widgets/IOT/phantu/Button/ControlButtonWidget.dart';
// import 'package:Kulbot/widgets/IOT/Sample&Data/ControlValueManager.dart';
import 'package:Kulbot/widgets/IOT/phantu/Label/label.dart';
import 'package:Kulbot/widgets/IOT/phantu/listbox.dart';

//Mẫu và Class lưu trữ file txt
// import 'package:Kulbot/widgets/IOT/Sample%26Data/ControlLayoutProvider.dart'; //Mẫu Layout
// import 'package:Kulbot/widgets/IOT/Sample%26Data/IotLayoutProvider.dart'; //Lưu Layout

class PhanTu_IOT {
  static Map<String, Map<String, dynamic>> controlGroups = {
    //Đừng để id bắt đầu giống nhau vd: mic và micshowkey
    //Tại lười nên không muốn fix cái này :)))
    'light': {
      'title': 'Các nút điều khiển',
      'name': 'Đèn',
      'size': [0.1, 0, 0.1, 0],
      'sizeInMenu': [0, 50, 0, 50],
      'typeBox': "height",
      'max': 3,
      'config': {
        'title': 'Đèn',
        'on': 'OO',
        'off': 'PP',
        'showkey': 'đây là nút bật tắt',
      },
      //config mặc định khi add vào widget chính
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
      'name': 'Mic 1',
      'size': [0.1, 0, 0.1, 0],
      'sizeInMenu': [0, 50, 0, 50],
      'typeBox': "height",
      'max': 1,
      'config': {'showkey': 'đây là cái mic'},
    },
    'ListBox': {
      'title': 'Các nút điều khiển',
      'name': 'Trạng thái bluetooth',
      'size': [0.3, 50, 0.2, 50],
      'sizeInMenu': [0, 150, 0, 100],
      'typeBox': "height",
      'max': 1,
      'config': {'showkey': 'Hiển thị trạng thái bluetooth'},
      'widgetBuilder':
          (
            Size size,
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
    'LabelString': {
      'title': 'Các nút điều khiển',
      'name': 'Label String',
      'size': [0.3, 50, 0.2, 50],
      'sizeInMenu': [0, 150, 0, 100],
      'typeBox': "height",
      'max': 1,
      'config': {'showkey': 'đây là cái Label String'},
      'widgetBuilder':
          (
            Size size,
            Map<String, dynamic> config,
            Map<String, dynamic> value,
            Function(Map<String, dynamic>)? onSave,
            VoidCallback? onDelete,
            Future<void> Function(String msg)? sendCommand,
            bool inMenu,
          ) => Label(
            config: config,
            value: value,
            onDelete: onDelete,
            onSave: onSave,
            dataDouble: false,
            inMenu: inMenu,
          ),
    },
    'LabelDouble': {
      'title': 'Các nút điều khiển',
      'name': 'Label Double',
      'size': [0.3, 50, 0.2, 50],
      'sizeInMenu': [0, 150, 0, 100],
      'typeBox': "height",
      'max': 1,
      'config': {'showkey': 'đây là cái Label Double'},
      'widgetBuilder':
          (
            Size size,
            Map<String, dynamic> config,
            Map<String, dynamic> value,
            Function(Map<String, dynamic>)? onSave,
            VoidCallback? onDelete,
            Future<void> Function(String msg)? sendCommand,
            bool inMenu,
          ) => Label(
            config: config,
            value: value,
            onDelete: onDelete,
            onSave: onSave,
            dataDouble: true,
            inMenu: inMenu,
          ),
    },
    'SCSWidget': {
      'title': 'Biểu đồ/đồ thị',
      'name': 'SCSWidget',
      'size': [0.3, 0, 0.3, 0],
      'sizeInMenu': [0, 210, 0, 210],
      'typeBox': "width",
      'max': 3,
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
            inMenu: inMenu,
          ),
    },
    'CustomChart': {
      'title': 'Biểu đồ/đồ thị',
      'name': 'CustomChart',
      'size': [0.4, 0, 0.3, 0],
      'sizeInMenu': [0, 210, 0, 210],
      'typeBox': "width",
      'max': 3,
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

    final bool useShowKey = showKey && !inMenu && !isPreview;

    if (Customrieng != null) {
      return useShowKey
          ? ShowKeyWrapper(
            keyShowcase:
                ShowKeyManager.getKey(id) ?? ShowKeyManager.createKey(id),
            description: getNoteShowKey(id),
            child: Customrieng,
          )
          : Customrieng;
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

      return useShowKey
          ? ShowKeyWrapper(
            keyShowcase:
                ShowKeyManager.getKey(id) ?? ShowKeyManager.createKey(id),
            description: getNoteShowKey(id),
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
