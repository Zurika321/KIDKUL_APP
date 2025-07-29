import 'package:flutter/material.dart';
import 'package:KulBlock/provider/Sample&Data/IotLayoutProject.dart'; //Lưu Layout IOT

import 'package:KulBlock/provider/Sample&Data/Control&IOTLayoutProvider.dart'; //Mẫu Layout Control&IOT

import 'package:KulBlock/provider/Sample&Data/SaveProjectPrograming.dart'; //Lưu Layout IOT

import 'package:KulBlock/widgets/3programing/WebViewApp.dart';
import 'package:KulBlock/widgets/2IOT&Control/ControlSrceen.dart';

class UnifiedMenuScreen {
  final Future<List<String>> Function()? haveProject;
  final List<String>? haveModel;
  final Function({
    required BuildContext context,
    String? projectName,
    String? type,
    bool? create,
  })
  navigatorTo;
  final Future<bool> Function(String name)? delete;
  final Future<bool> Function(String name, String newName)? rename;

  UnifiedMenuScreen({
    required this.haveProject,
    required this.haveModel,
    required this.navigatorTo,
    required this.delete,
    required this.rename,
  });

  /// Danh sách các key hợp lệ
  static const List<String> validKeys = [
    "Menu IOT",
    "Menu Control",
    "Menu Prograning",
  ];

  /// Hàm khởi tạo từ key
  static UnifiedMenuScreen of(String menuKey) {
    switch (menuKey) {
      case "Menu IOT":
        return UnifiedMenuScreen(
          haveProject: IotLayoutProject.getSavedLayoutNames,
          haveModel: ControlLayoutProvider.getAvailableTypes(false),
          navigatorTo: ({
            required BuildContext context,
            String? projectName,
            String? type,
            bool? create,
          }) async {
            // Kiểm tra logic nhập
            if (create != null && create) {
              projectName = "";
              type = "new";
            }
            if (projectName != null && projectName.isNotEmpty) {
              type = "";
            }
            if (type != null && type.isNotEmpty) {
              projectName = "";
            }

            // Điều kiện logic: chỉ 1 trong 2 có giá trị
            if ((projectName?.isEmpty ?? true) && (type?.isEmpty ?? true)) {
              // Cả hai đều rỗng, không hợp lệ
              return false;
            }

            final shouldReload = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder:
                    (_) => RobotControlScreen(
                      type: type ?? "",
                      projectName: projectName ?? "",
                      isControl: false,
                    ),
              ),
            );

            return shouldReload;
          },
          delete: IotLayoutProject.deleteLayout,
          rename: IotLayoutProject.renameLayout,
        );
      case "Menu Control":
        return UnifiedMenuScreen(
          haveProject: null,
          haveModel: ControlLayoutProvider.getAvailableTypes(true),
          navigatorTo: ({
            required BuildContext context,
            String? projectName,
            String? type,
            bool? create,
          }) async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => RobotControlScreen(
                      type: type ?? "",
                      projectName: projectName ?? "",
                      isControl: true,
                    ),
              ),
            );
            return false;
          },
          delete: null,
          rename: null,
        );
      case "Menu Prograning":
        return UnifiedMenuScreen(
          haveProject: ProgamingLayoutProvider.getSavedLayoutNames,
          haveModel: null,
          navigatorTo: ({
            required BuildContext context,
            String? projectName,
            String? type,
            bool? create,
          }) async {
            if (create != null && create) {
              projectName = null;
            }
            final shouldReload = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WebViewApp(projectName: projectName),
              ),
            );
            return shouldReload;
          },
          delete: ProgamingLayoutProvider.deleteLayout,
          rename: ProgamingLayoutProvider.renameLayout,
        );
      default:
        // Nếu key không hợp lệ, mặc định về MenuIOT
        return UnifiedMenuScreen.of("Menu IOT");
    }
  }
}
