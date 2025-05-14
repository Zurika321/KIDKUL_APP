import 'package:Kulbot/widgets/IOT/IOT/IOTSrceen.dart';
import 'package:flutter/material.dart';
import 'package:Kulbot/provider/FileManage.dart';
import 'dart:convert';

class IotLayoutProvider {
  /// Lưu danh sách ControlItem vào file txt trong thư mục "IOT"
  static Future<String> saveLayout(
    String baseName,
    List<ControlItem> items,
  ) async {
    final jsonList = items.map((e) => e.toJson()).toList();
    final content = jsonEncode(jsonList);

    final file = await FileManager.saveWithUniqueName(baseName, content, 'IOT');
    print('📁 File đã lưu tại: ${file.path}');

    final savedName = file.path.split('/').last.replaceAll('.txt', '');
    return savedName; // Trả về tên thật đã lưu
  }

  /// Tải layout từ file .txt trong thư mục "IOT"
  static Future<List<ControlItem>> loadLayout(String projectName) async {
    try {
      final content = await FileManager.readFile('$projectName.txt', 'IOT');
      print("===> content loaded:\n$content");

      final List<dynamic> jsonList = jsonDecode(content);

      // final items =
      //     jsonList.map((item) {
      //       final id = item['id'];
      //       final dx = item['x']?.toDouble() ?? 0.0;
      //       final dy = item['y']?.toDouble() ?? 0.0;
      //       return ControlItem(id: id, relativePosition: Offset(dx, dy));
      //     }).toList();
      final items =
          jsonList.map((item) {
            return ControlItem.fromJson(item);
          }).toList();

      print("===> loaded items: ${items.length}");
      return items;
    } catch (e) {
      print('Lỗi đọc layout từ file: $e');
      return [];
    }
  }

  /// Lấy danh sách tên file (bỏ đuôi .txt)
  static Future<List<String>> getSavedLayoutNames() async {
    final files = await FileManager.getAllFileNames('IOT');
    return files.map((name) => name.replaceAll('.txt', '')).toList();
  }
}
