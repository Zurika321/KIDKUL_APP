import 'package:flutter/material.dart';
import './FileManage.dart';
import 'dart:convert';

class BlockList {
  final String name;
  String xml;

  BlockList({required this.name, required this.xml});

  factory BlockList.fromJson(Map<String, dynamic> json) {
    return BlockList(name: json['name'], xml: json['xml'] ?? "");
  }

  Map<String, dynamic> toJson() => {'name': name, 'xml': xml};

  BlockList clone() {
    return BlockList(name: name, xml: xml);
  }
}

class ProgamingLayoutProvider {
  /// Lưu danh sách ControlItem vào file txt trong thư mục "IOT"
  static Future<String> saveLayout(
    String baseName,
    List<BlockList> items,
  ) async {
    final jsonList = items.map((e) => e.toJson()).toList();
    final content = jsonEncode(jsonList);
    debugPrint('[SAVE] Content:\n$content');

    final file = await FileManager.saveWithUniqueName(
      baseName,
      content,
      'PROGRMING',
    );
    debugPrint('[SAVE] Đã lưu tại: ${file.path}');

    final savedName = file.path.split('/').last.replaceAll('.txt', '');
    return savedName; // Trả về tên thật đã lưu
  }

  /// Tải layout từ file .txt trong thư mục "PROGRMING"
  static Future<List<BlockList>> loadLayout(String projectName) async {
    try {
      final content = await FileManager.readFile(
        '$projectName.txt',
        'PROGRMING',
      );
      print("===> content loaded:\n$content");

      final List<dynamic> jsonList = jsonDecode(content);
      final items =
          jsonList.map((item) {
            return BlockList.fromJson(item);
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
    final files = await FileManager.getAllFileNames('PROGRMING');
    return files.map((name) => name.replaceAll('.txt', '')).toList();
  }

  ///Cập nhật nội dung cho file đã có sẵn
  static Future<bool> updateLayout(String name, List<BlockList> items) async {
    final content = jsonEncode(items.map((e) => e.toJson()).toList());
    return FileManager.updateFile('$name.txt', content, 'PROGRMING');
  }

  ///Xóa file theo tên
  static Future<bool> deleteLayout(String name) async {
    return FileManager.deleteFile('$name.txt', 'PROGRMING');
  }

  ///Đổi tên file
  static Future<bool> renameLayout(String oldName, String newName) async {
    return FileManager.renameFile('$oldName.txt', '$newName.txt', 'PROGRMING');
  }
}
