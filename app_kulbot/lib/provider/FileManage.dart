import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileManager {
  /// Lấy thư mục lưu trữ theo tên (ví dụ: "IOT", "Control")
  static Future<Directory> _getDirectory(String folder) async {
    final baseDir = await getApplicationDocumentsDirectory();
    final targetDir = Directory('${baseDir.path}/$folder');
    if (!(await targetDir.exists())) {
      await targetDir.create(recursive: true);
    }
    return targetDir;
  }

  /// Lưu file .txt với tên không trùng lặp (nếu trùng sẽ thêm số)
  static Future<File> saveWithUniqueName(
    String baseName,
    String content,
    String folder,
  ) async {
    final dir = await _getDirectory(folder);
    int count = 0;
    String fileName;
    File file;

    do {
      final suffix = count == 0 ? '' : ' ${count + 1}';
      fileName = '$baseName$suffix.txt';
      file = File('${dir.path}/$fileName');
      count++;
    } while (await file.exists());

    return file.writeAsString(content);
  }

  /// Ghi đè nội dung file đã tồn tại trong thư mục
  static Future<bool> updateFile(
    String fileName,
    String content,
    String folder,
  ) async {
    final dir = await _getDirectory(folder);
    final file = File('${dir.path}/$fileName');

    if (await file.exists()) {
      await file.writeAsString(content);
      return true;
    } else {
      return false;
    }
  }

  /// Xoá file trong thư mục nếu tồn tại
  static Future<bool> deleteFile(String fileName, String folder) async {
    final dir = await _getDirectory(folder);
    final file = File('${dir.path}/$fileName');

    if (await file.exists()) {
      await file.delete();
      return true;
    } else {
      return false;
    }
  }

  /// Đổi tên file trong thư mục (nếu file cũ tồn tại và tên mới chưa bị trùng)
  static Future<bool> renameFile(
    String oldName,
    String newName,
    String folder,
  ) async {
    final dir = await _getDirectory(folder);
    final oldFile = File('${dir.path}/$oldName');
    final newFile = File('${dir.path}/$newName');

    if (await oldFile.exists()) {
      if (await newFile.exists()) return false; // Không ghi đè
      await oldFile.rename(newFile.path);
      return true;
    } else {
      return false;
    }
  }

  /// Lấy tất cả tên file .txt trong thư mục chỉ định
  static Future<List<String>> getAllFileNames(String folder) async {
    final dir = await _getDirectory(folder);
    final files = await dir.list().toList();
    return files
        .whereType<File>()
        .where((f) => f.path.endsWith('.txt'))
        .map((f) => f.uri.pathSegments.last)
        .toList();
  }

  /// Đọc nội dung file từ tên và thư mục
  static Future<String> readFile(String fileName, String folder) async {
    final dir = await _getDirectory(folder);
    final file = File('${dir.path}/$fileName');
    if (await file.exists()) {
      print("Lưu thành công file $fileName");
      return file.readAsString();
    } else {
      throw Exception('File $fileName không tồn tại trong thư mục $folder');
    }
  }
}
