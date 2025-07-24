import 'package:Kulbot/widgets/Control/Control/ControlSrceen.dart';
import 'package:flutter/material.dart';

class ControlLayoutProvider {
  // Danh sách các mẫu và layout tương ứng
  static final Map<String, List<ControlItem>> _layouts = {
    //realid có chuối số ở cuối == 1 sẽ áp dụng showkey
    //nếu sài relativePosition thì vị trí thực của nó trên màn hình chính là ở trung tâm phần tử
    'Car Robot': [
      ControlItem(
        id: 'JoyStickH',
        realId: 'JoyStickH1',
        bottom: 25.0,
        right: 25.0,
        config: {"width": 150.0, "height": 150.0, "stop": "SS"},
        lock: false,
        canMove: true,
      ),
      ControlItem(
        id: 'JoyStickV',
        realId: 'JoyStickV1',
        bottom: 25.0,
        left: 25.0,
        config: {"width": 150.0, "height": 150.0, "stop": "SS"},
        lock: false,
        canMove: false,
      ),
      ControlItem(
        id: 'Button_light',
        realId: 'Button_light1',
        bottom: 185.0,
        right: 25.0,
        config: {"width": 50.0, "height": 50.0},
        lock: false,
        canMove: true,
      ),
      ControlItem(
        id: 'HoldLight',
        realId: 'HoldLight1',
        bottom: 185.0,
        right: 85.0,
        config: {"width": 50.0, "height": 50.0},
        lock: false,
        canMove: true,
      ),
      ControlItem(
        id: 'mic',
        realId: 'mic1',
        relativePosition: Offset(0.5, 0),
        bottom: 25.0,
        config: {"width": 65.0, "height": 65.0},
        lock: false,
        canMove: true,
      ),
    ],
    'Human Robot': [
      ControlItem(
        id: 'JoyStick360_',
        realId: 'JoyStick360_1',
        bottom: 25.0,
        left: 25.0,
        config: {"width": 150.0, "height": 150.0, "stop": "SS"},
        lock: false,
        canMove: true,
      ),
    ],
  };

  static List<ControlItem> getLayout(String type, Size screenSize) {
    final original = _layouts[type];
    if (original == null) return [];

    final List<ControlItem> result = [];
    final Set<String> usedRealIds = {};

    for (var item in original) {
      final clone = item.clone();

      // Đảm bảo realId không bị trùng
      String newRealId = clone.realId;
      int suffix = 1;
      while (usedRealIds.contains(newRealId)) {
        newRealId = '${clone.realId}_$suffix';
        suffix++;
      }
      clone.realId = newRealId;
      usedRealIds.add(newRealId);

      // Lấy kích thước từ config hoặc fallback mặc định
      final width =
          (clone.config["width"] is double)
              ? clone.config["width"] as double
              : 100.0;
      final height =
          (clone.config["height"] is double)
              ? clone.config["height"] as double
              : 100.0;

      // Tính toạ độ Y
      double dy;
      if (clone.top != null) {
        dy = clone.top! / screenSize.height;
      } else if (clone.bottom != null) {
        dy = (screenSize.height - clone.bottom! - height) / screenSize.height;
      } else {
        dy =
            clone.relativePosition.dy +
            ((clone.relativePosition.dy >= 0.5 ? -height : height) /
                screenSize.height /
                2);
      }

      // Tính toạ độ X
      double dx;
      if (clone.left != null) {
        dx = clone.left! / screenSize.width;
      } else if (clone.right != null) {
        dx = (screenSize.width - clone.right! - width) / screenSize.width;
      } else {
        dx =
            clone.relativePosition.dx +
            ((clone.relativePosition.dx >= 0.5 ? -width : width) /
                screenSize.width /
                2);
      }

      clone.relativePosition = Offset(dx, dy);
      result.add(clone);
    }

    return result;
  }

  /// Trả về danh sách tên các mẫu (ví dụ: ['IOT1', 'IOT2'])
  static List<String> getAvailableTypes() {
    return _layouts.keys.toList();
  }

  /// Trả về map toàn bộ layout: { 'IOT1': [...], 'IOT2': [...] }
  static Map<String, List<ControlItem>> getAllLayouts() {
    return Map.from(_layouts);
  }

  /// Kiểm tra một `type` có hợp lệ không
  static bool isValidType(String type) {
    return _layouts.containsKey(type);
  }
}
