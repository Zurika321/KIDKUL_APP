import 'package:flutter/material.dart';

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
          'size': 0.1,
          'sizeInMenu': 50,
          'widgetBuilder':
              (
                double size,
                Map<String, dynamic> config,
                Function(Map<String, dynamic>)? onSave,
              ) => LightButtonWidget(size: size),
        },
        {
          'id': 'horn',
          'name': 'Còi',
          'size': 0.1,
          'sizeInMenu': 50,
          'widgetBuilder':
              (
                double size,
                Map<String, dynamic> config,
                Function(Map<String, dynamic>)? onSave,
              ) => HornButtonWidget(size: size),
        },
      ],
    },
    {
      'title': 'Bảng trạng thái',
      'controls': [
        {
          'id': 'SCSWidget',
          'name': '',
          'size': 0.5,
          'sizeInMenu': 230,
          'config': {'title': 'Temp', 'unit': '˚C', 'value': 0.0},
          'widgetBuilder': (
            double size,
            Map<String, dynamic> config,
            Function(Map<String, dynamic>)? onSave,
          ) {
            return SizedBox(
              width: size,
              height: size,
              child: SCSWidget(config: config, onSave: onSave),
            );
          },
        },
      ],
    },
  ];

  static Size getControlSize(String id, Size screenSize) {
    for (final group in controlGroups) {
      final controls = group['controls'] as List<dynamic>;

      for (final control in controls) {
        if (control['id'] == id) {
          final sizeRatio = control['size'] as double;
          final size = screenSize.height * sizeRatio;
          return Size(size, size);
        }
      }
    }

    // Mặc định nếu không tìm thấy
    return const Size(80, 80);
  }

  static List<double> _getControlSizeById(String id) {
    for (final group in controlGroups) {
      for (final control in group['controls']) {
        if (control['id'] == id) {
          return [control['sizeInMenu'], control['size'] ?? 0.1];
        }
      }
    }
    return [80, 0.1];
  }

  static Widget Function(
    double size,
    Map<String, dynamic> config,
    Function(Map<String, dynamic>)? onSave,
  )?
  getWidgetBuilderById(String id) {
    for (final group in controlGroups) {
      for (final control in group['controls']) {
        if (control['id'] == id) {
          return control['widgetBuilder']
              as Widget Function(
                double,
                Map<String, dynamic>,
                Function(Map<String, dynamic>)?,
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
    bool isPreview = false,
    bool inMenu = true,
    Function(Map<String, dynamic>)? onSave,
  }) {
    final bool isSmall = isPreview || inMenu;
    final List<double> SizeInOutMenu = _getControlSizeById(id);
    // final double widgetSize = isSmall ? 80.0 : size.height * baseSize;
    final double widgetSize =
        isSmall
            ? (SizeInOutMenu[0]) // <== dùng theo tỷ lệ size khai báo
            : (size.height * SizeInOutMenu[1]);

    switch (id) {
      case "joystick360":
        return Container(
          width: widgetSize,
          height: widgetSize,
          decoration: BoxDecoration(
            color: Colors.cyanAccent.withOpacity(isPreview ? 0.7 : 1),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text('🎮', style: TextStyle(fontSize: 24)),
          ),
        );

      // case "SwitchControlWidget":
      //   return SizedBox(
      //     width: widgetSize,
      //     height: widgetSize,
      //     child: SwitchControlWidget(
      //       title: config?['title'] ?? 'Công tắc',
      //       bluetoothKey: config?['bluetoothKey'] ?? '',
      //     ),
      //   );

      default:
        final builder = getWidgetBuilderById(id);
        if (builder != null) {
          return builder(widgetSize, config ?? {}, onSave);
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
