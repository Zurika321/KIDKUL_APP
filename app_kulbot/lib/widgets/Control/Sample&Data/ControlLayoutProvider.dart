import 'package:Kulbot/widgets/Control/Control/ControlSrceen.dart';
import 'package:flutter/material.dart';

class ControlLayoutProvider {
  // Danh sách các mẫu và layout tương ứng
  static final Map<String, List<ControlItem>> _layouts = {
    'Car Robot': [
      ControlItem(
        id: 'JoyStickH',
        realId: 'JoyStickH1',
        relativePosition: const Offset(0.1, 0.7),
        lock: true,
        canMove: true,
      ),
      ControlItem(
        id: 'JoyStickV',
        realId: 'JoyStickV1',
        relativePosition: const Offset(0.8, 0.7),
        lock: true,
        canMove: true,
      ),
    ],
    'Human Robot': [
      ControlItem(
        id: 'SCSWidget',
        realId: 'SCSWidget1',
        relativePosition: const Offset(0.5, 0.2),
        config: {'title': 'Nhiệt độ', 'unit': '°C'},
        lock: true,
        canMove: true,
      ),
      ControlItem(
        id: 'Button_light',
        realId: 'Button_light1',
        relativePosition: const Offset(0.7, 0.7),
        lock: true,
        canMove: true,
      ),
      ControlItem(
        id: 'HoldLight',
        realId: 'HoldLight1',
        relativePosition: const Offset(0.85, 0.7),
        lock: true,
        canMove: true,
      ),
    ],
  };

  /// Trả về layout của một mẫu theo `type`
  static List<ControlItem> getLayout(String type) {
    final original = _layouts[type];
    if (original == null) return [];

    return original.map((item) => item.clone()).toList();
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
