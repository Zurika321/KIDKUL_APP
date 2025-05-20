import 'package:flutter/material.dart';

import 'package:Kulbot/widgets/IOT/IOT/IOTSrceen.dart';

//Phần tử
import 'package:Kulbot/widgets/IOT/phantu/SCSWidget.dart'; //SCSWidget – hiển thị cảm biến
import 'package:Kulbot/widgets/IOT/phantu/SwitchControlWidget.dart'; //SwitchControlWidget – hiển thị công tắc
// import 'package:Kulbot/widgets/IOT/SliderControlWidget.dart'; //SliderControlWidget – hiển thị thanh trượt

//Mẫu và Class lưu trữ file txt
// import 'package:Kulbot/widgets/IOT/Sample%26Data/ControlLayoutProvider.dart'; //Mẫu Layout
// import 'package:Kulbot/widgets/IOT/Sample%26Data/IotLayoutProvider.dart'; //Lưu Layout

class PhanTu_IOT {
  static List<Map<String, dynamic>> controlGroups = [
    {
      'title': 'Các nút điều khiển',
      'controls': [
        {
          'id': 'light',
          'name': 'Đèn',
          'size': [0.1, 0, 0.1, 0],
          //ko cần chuyển sang double vì hàm chuyển sang double dùm rồi
          'sizeInMenu': [0, 50, 0, 50],
          'max': 3,
          'widgetBuilder':
              (
                Size size,
                Map<String, dynamic> config,
                Map<String, dynamic> value,
                Function(Map<String, dynamic>)? onSave,
                VoidCallback? onDelete,
              ) => LightButtonWidget(size: size.height),
        },
        {
          'id': 'horn',
          'name': 'Còi',
          'size': [0.1, 0, 0.1, 0],
          'sizeInMenu': [0, 50, 0, 50],
          'max': 3,
          'widgetBuilder':
              (
                Size size,
                Map<String, dynamic> config,
                Map<String, dynamic> value,
                Function(Map<String, dynamic>)? onSave,
                VoidCallback? onDelete,
              ) => HornButtonWidget(
                size: size.height,
              ), //lấy size height để tạo hộp vuông cho nút
        },
      ],
    },
    {
      'title': 'Bảng trạng thái',
      'controls': [
        {
          'id': 'SCSWidget',
          'name': 'SCSWidget',
          'size': [0.5, 0, 0.5, 0],
          'sizeInMenu': [0, 210, 0, 210],
          // dạng [XScale,Xpx,YScale,Ypx] Scale là tỉ lệ màn hình px là chỉnh thẳng px => size width = XScale * screenWidth + Xpx
          'max': 3,
          'valueKeys': [
            {'key': 'temp', 'default': 0},
            // có thẻ thay đổi giá trị khi xuất hiện ở đây
          ],
          'config': {'title': 'Temp', 'unit': '˚C'},
          //mảng setting tùy chỉnh (lưu chung trong dự án)
          'widgetBuilder':
              (
                Size size,
                Map<String, dynamic> config,
                Map<String, dynamic> value,
                Function(Map<String, dynamic>)? onSave,
                VoidCallback? onDelete,
              ) => SCSWidget(
                config: config,
                value: value,
                onDelete: onDelete,
                size: Size(size.width - 10, size.height - 10),
              ),
        },
      ],
    },
  ];

  static List<Map<String, dynamic>> getValueKeysById(String id) {
    for (var group in controlGroups) {
      for (var control in group['controls']) {
        if (control['id'] == id) {
          final valueKeys = control['valueKeys'];
          if (valueKeys != null && valueKeys is List) {
            return List<Map<String, dynamic>>.from(valueKeys);
          }
          return [];
        }
      }
    }
    return [];
  } //lấy key tạo setValue trong class ControlValueManager

  static Map<String, dynamic> getValueMapByControl(String id, String realId) {
    final List<Map<String, dynamic>> keys = getValueKeysById(id);
    final Map<String, dynamic> valueMap = {};

    for (var item in keys) {
      final key = item['key'];
      final fullKey = '${realId}_${key}';
      final def = item['default'] ?? 0;

      if (!ControlValueManager.hasValue(fullKey)) {
        ControlValueManager.setValue(fullKey, def);
      }

      valueMap[key] = ControlValueManager.getValue(fullKey);
    }

    return valueMap;
  } // tạo mảng Map<String,dynamic> cho value khi gọi hàm getControlWidget

  static int getMaxById(String id) {
    for (var group in PhanTu_IOT.controlGroups) {
      for (var control in group['controls']) {
        if (control['id'] == id) return control['max'] ?? 5;
      }
    }
    return 5;
  }

  static List<double> getControlSizeById(String id) {
    // cái này là lấy size trong menu là 4 index đầu , 4 cái sau là ngoài menu
    for (final group in controlGroups) {
      for (final control in group['controls']) {
        if (control['id'] == id) {
          final sizeInMenu =
              (control['sizeInMenu'] as List)
                  .map((e) => (e is int) ? e.toDouble() : e as double)
                  .toList();
          final size =
              (control['size'] as List)
                  .map((e) => (e is int) ? e.toDouble() : e as double)
                  .toList();

          return [...sizeInMenu, ...size];
        }
      }
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
  )?
  getWidgetBuilderById(String id) {
    for (final group in controlGroups) {
      for (final control in group['controls']) {
        if (control['id'] == id) {
          return control['widgetBuilder']
              as Widget Function(
                Size,
                Map<String, dynamic>,
                Map<String, dynamic>,
                Function(Map<String, dynamic>)?,
                VoidCallback?,
              )?;
        }
      }
    }
    return null;
  }

  static Widget getControlWidget({
    required String id,
    required Size size,
    Map<String, dynamic>? config,
    Map<String, dynamic>? value,
    bool isPreview = false,
    // làm thêm cái hiện box mờ sau phần tử nhưng không quan trọng nên chưa làm
    bool inMenu = true,
    Function(Map<String, dynamic>)? onSave,
    VoidCallback? onDelete, // ✅ thêm vào đây
    bool lock = false,
  }) {
    final bool isSmall = isPreview || inMenu;
    final List<double> sizeInfo = getControlSizeById(id);
    // [menu_XScale, menu_XOffset, menu_YScale, menu_YOffset, XScale, XOffset, YScale, YOffset]

    // Tính kích thước theo tỷ lệ và offset
    final double xScale = isSmall ? sizeInfo[0] : sizeInfo[4];
    final double xOffset = isSmall ? sizeInfo[1] : sizeInfo[5];
    final double yScale = isSmall ? sizeInfo[2] : sizeInfo[6];
    final double yOffset = isSmall ? sizeInfo[3] : sizeInfo[7];

    double width = size.height * xScale + xOffset;
    double height = size.height * yScale + yOffset;

    // Giới hạn để không âm hoặc quá nhỏ
    width = width.clamp(30.0, size.width);
    height = height.clamp(30.0, size.height);
    // final double widgetSize = height;

    if (config != null) {
      config['lock'] = lock;
    }
    switch (id) {
      case "joystick360":
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

      default:
        final builder = getWidgetBuilderById(id);
        if (builder != null) {
          return SizedBox(
            width: width,
            height: height,
            child: builder(
              size,
              config ?? <String, dynamic>{},
              value ?? <String, dynamic>{},
              onSave,
              onDelete,
            ), // ✅ truyền thêm
          );
        }

        return const SizedBox();
    }
  }
}

///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////

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
