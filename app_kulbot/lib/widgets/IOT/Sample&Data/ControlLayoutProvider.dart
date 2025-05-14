import 'package:Kulbot/widgets/IOT/IOT/IOTSrceen.dart';
import 'package:flutter/material.dart';

class ControlLayoutProvider {
  // Danh sách các mẫu và layout tương ứng
  static final Map<String, List<ControlItem>> _layouts = {
    'IOT1': [
      ControlItem(id: 'light', relativePosition: const Offset(0.8, 0.7)),
    ],
    'IOT2': [
      ControlItem(
        id: 'SCSWidget',
        relativePosition: const Offset(0.5, 0.2),
        config: {'title': 'Nhiệt độ', 'unit': '°C', 'value': 36.5},
      ),
      ControlItem(id: 'light', relativePosition: const Offset(0.7, 0.7)),
      ControlItem(id: 'horn', relativePosition: const Offset(0.85, 0.7)),
    ],
  };

  /// Trả về layout của một mẫu theo `type`
  static List<ControlItem> getLayout(String type) {
    return _layouts[type] ?? [];
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
