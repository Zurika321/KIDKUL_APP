import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Kulbot/widgets/IOT/IOT/IOTSrceen.dart';
import 'package:Kulbot/provider/FileManage.dart';

import 'package:flutter/foundation.dart'; //xem người dùng đang dùng web hay ko

import 'package:Kulbot/widgets/IOT/Sample%26Data/ControlLayoutProvider.dart'; //Mẫu Layout
import 'package:Kulbot/widgets/IOT/Sample%26Data/IotLayoutProvider.dart'; //Lưu Layout

class IOT extends StatefulWidget {
  const IOT({super.key});

  @override
  State<IOT> createState() => _IOTState();
}

class _IOTState extends State<IOT> {
  List<String> allProjects = [];
  List<String> filteredProjects = [];
  List<String> modelsLayoutIOT = ControlLayoutProvider.getAvailableTypes();
  List<String> filteredModels = [];
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadSavedProjects();
  }

  Future<void> _loadSavedProjects() async {
    if (kIsWeb) {
      setState(() {
        allProjects = [
          'TestProject1',
          'Demo123',
          'SampleFile',
          't1',
          't2',
          't3',
        ]; // mock data
      });
    } else {
      final projectNames = await IotLayoutProvider.getSavedLayoutNames();
      setState(() {
        allProjects = projectNames;
      });
    }
  }

  void _filterProjects() {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      filteredProjects = List.from(allProjects);
      filteredModels = List.from(modelsLayoutIOT);
    } else {
      filteredProjects =
          allProjects.where((p) => p.toLowerCase().contains(query)).toList();

      filteredModels =
          modelsLayoutIOT
              .where((m) => m.toLowerCase().contains(query))
              .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 221, 221, 228),
      appBar: AppBar(
        title: const Text("Điều khiển Robot"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Tìm kiếm...',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                    _filterProjects();
                  });
                },
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (searchQuery.trim().isEmpty) ...[
              if (allProjects.isNotEmpty) ...[
                // PHẦN 1: Dự án đã lưu
                const Text(
                  "Chọn bảng điều khiển đã lưu",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children:
                      allProjects.map((name) {
                        return SizedBox(
                          width: 120,
                          height: 80,
                          child: CustomBox(
                            title: name,
                            icon: Icons.folder,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => RobotControlScreen(
                                        projectName: name,
                                        type: "",
                                      ),
                                ),
                              );
                            },
                            onDelete: () async {
                              final success = await showDeleteDialog(
                                context,
                                name,
                              );
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '✅ Đã xóa layout "$name" thành công!',
                                    ),
                                  ),
                                );
                                setState(() {
                                  allProjects.remove(name);
                                });
                              }
                            },
                            onRename: () async {
                              final controller = TextEditingController(
                                text: name,
                              );
                              final newName = await showRenameDialog(
                                context,
                                controller,
                              );

                              if (newName != null && newName != name) {
                                final success =
                                    await IotLayoutProvider.renameLayout(
                                      name,
                                      newName,
                                    );
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '✅ Đã đổi tên layout "$name" thành "$newName" thành công!',
                                      ),
                                    ),
                                  );
                                  setState(() {
                                    final index = allProjects.indexOf(name);
                                    if (index != -1) {
                                      allProjects.removeAt(index);
                                      allProjects.insert(index, newName);
                                    }
                                  });
                                }
                              }
                            },

                            showMenuIcon: true,
                          ),
                        );
                      }).toList(),
                ),
                const SizedBox(height: 24), // khoảng cách giữa các phần
              ],

              // PHẦN 2: Loại bảng điều khiển
              const Text(
                "Chọn loại bảng điều khiển",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: 120,
                    height: 80,
                    child: CustomBox(
                      title: "Create New",
                      icon: Icons.add,
                      onTap: () {
                        // Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => RobotControlScreen(
                                  projectName: "",
                                  type: "new",
                                ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    height: 80,
                    child: CustomBox(
                      title: "Import",
                      icon: Icons.upload_file,
                      onTap: () {
                        // TODO
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // PHẦN 3: Các bảng điều khiển cơ bản
              const Text(
                "Các bảng điều khiển cơ bản",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  ...modelsLayoutIOT.map(
                    (model) => SizedBox(
                      width: 120,
                      height: 80,
                      child: CustomBox(
                        title: model,
                        icon: Icons.toys,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => RobotControlScreen(
                                    projectName: "",
                                    type: model,
                                  ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // ==== PHẦN KẾT QUẢ TÌM KIẾM ====
              const Text(
                "🔍 Kết quả tìm kiếm",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  ...filteredProjects.map(
                    (name) => SizedBox(
                      width: 120,
                      height: 80,
                      child: CustomBox(
                        title: name,
                        icon: Icons.folder,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => RobotControlScreen(
                                    projectName: name,
                                    type: "",
                                  ),
                            ),
                          );
                        },
                        onDelete: () async {
                          final success = await showDeleteDialog(context, name);
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '✅ Đã xóa layout "$name" thành công!',
                                ),
                              ),
                            );
                            setState(() {
                              allProjects.remove(name);
                            });
                          }
                        },
                        onRename: () async {
                          final controller = TextEditingController(text: name);
                          final newName = await showRenameDialog(
                            context,
                            controller,
                          );

                          if (newName != null && newName != name) {
                            final success =
                                await IotLayoutProvider.renameLayout(
                                  name,
                                  newName,
                                );
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '✅ Đã đổi tên layout "$name" thành "$newName" thành công!',
                                  ),
                                ),
                              );
                              setState(() {
                                final index = allProjects.indexOf(name);
                                if (index != -1) {
                                  allProjects.removeAt(index);
                                  allProjects.insert(index, newName);
                                }
                              });
                            }
                          }
                        },
                        showMenuIcon: true,
                      ),
                    ),
                  ),
                  ...filteredModels.map(
                    (model) => SizedBox(
                      width: 120,
                      height: 80,
                      child: CustomBox(
                        title: model,
                        icon: Icons.toys,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => RobotControlScreen(
                                    projectName: "",
                                    type: model,
                                  ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class CustomBox extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool showMenuIcon;
  final VoidCallback? onRename;
  final VoidCallback? onDelete;

  const CustomBox({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.showMenuIcon = false,
    this.onRename,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 32, color: Colors.blueAccent),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          if (showMenuIcon)
            Positioned(
              top: 4,
              right: 4,
              child: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20),
                onSelected: (value) {
                  if (value == 'rename') onRename?.call();
                  if (value == 'delete') onDelete?.call();
                },
                itemBuilder:
                    (context) => [
                      const PopupMenuItem(
                        value: 'rename',
                        child: Text('Đổi tên'),
                      ),
                      const PopupMenuItem(value: 'delete', child: Text('Xoá')),
                    ],
              ),
            ),
        ],
      ),
    );
  }
}

Future<String?> showRenameDialog(
  BuildContext context,
  TextEditingController controller,
) async {
  return showDialog<String>(
    context: context,
    builder:
        (_) => AlertDialog(
          title: const Text("Đổi tên"),
          content: TextField(controller: controller),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text("Huỷ"),
            ),
            ElevatedButton(
              onPressed: () {
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  Navigator.pop(context, newName);
                }
              },
              child: const Text("Đổi tên"),
            ),
          ],
        ),
  );
}

Future<bool> showDeleteDialog(BuildContext context, String name) async {
  final result = await showDialog<bool>(
    context: context,
    builder:
        (_) => AlertDialog(
          title: const Text("Xác nhận xoá"),
          content: Text('Bạn có chắc muốn xoá "$name"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Huỷ"),
            ),
            ElevatedButton(
              onPressed: () async {
                final deleted = await IotLayoutProvider.deleteLayout(name);
                Navigator.pop(context, deleted); // trả về true nếu xóa được
              },
              child: const Text("Xoá"),
            ),
          ],
        ),
  );
  return result ?? false;
}
