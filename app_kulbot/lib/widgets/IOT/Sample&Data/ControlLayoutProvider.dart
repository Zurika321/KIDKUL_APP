import 'package:Kulbot/widgets/IOT/IOT/IOTSrceen.dart';
import 'package:flutter/material.dart';

class ControlLayoutProvider {
  // Danh sách các mẫu và layout tương ứng
  static final Map<String, List<ControlItem>> _layouts = {
    'IOT1': [
      ControlItem(
        id: 'light',
        realId: 'light1',
        relativePosition: const Offset(0.8, 0.7),
        lock: true,
        canMove: false,
      ),
    ],
    'IOT2': [
      ControlItem(
        id: 'SCSWidget',
        realId: 'SCSWidget1',
        relativePosition: const Offset(0.5, 0.2),
        config: {'title': 'Nhiệt độ', 'unit': '°C'},
        lock: true,
        canMove: true,
      ),
      ControlItem(
        id: 'joystick360',
        realId: 'joystick3601',
        relativePosition: const Offset(0.5, 0.7),
        lock: true,
        canMove: false,
      ),
      ControlItem(
        id: 'light',
        realId: 'light1',
        relativePosition: const Offset(0.7, 0.7),
        lock: true,
        canMove: false,
      ),
      ControlItem(
        id: 'horn',
        realId: 'horn1',
        relativePosition: const Offset(0.85, 0.7),
        lock: true,
        canMove: false,
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
