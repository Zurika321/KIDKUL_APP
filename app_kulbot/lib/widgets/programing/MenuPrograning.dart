import 'package:flutter/material.dart';
import 'package:Kulbot/widgets/programing/WebViewApp.dart';
import 'package:flutter/foundation.dart'; //xem người dùng đang dùng web hay ko

import './SaveProjectPrograming.dart';

class Menuprograning extends StatefulWidget {
  const Menuprograning({super.key});

  @override
  State<Menuprograning> createState() => _MenuprograningState();
}

class _MenuprograningState extends State<Menuprograning> {
  List<String> allProjects = [];
  List<String> filteredProjects = [];
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadSavedProjects();
  }

  Future<void> _loadSavedProjects() async {
    final projectNames =
        await ProgamingLayoutProvider.getSavedLayoutNames(); // lưu
    setState(() {
      allProjects = projectNames;
    });
  }

  void _filterProjects() {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      filteredProjects = List.from(allProjects);
    } else {
      filteredProjects =
          allProjects.where((p) => p.toLowerCase().contains(query)).toList();
    }
  }

  final List<Color> customColors = [
    Color.fromARGB(247, 164, 217, 255),
    Color.fromARGB(255, 255, 221, 136),
    Color.fromARGB(255, 129, 218, 129),
    Color.fromARGB(255, 255, 153, 153),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        // title: const Text("Điều khiển Robot"),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            size: 40.0,
            color: Color.fromARGB(255, 190, 190, 190),
          ),
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
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: Colors.black),
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
              // PHẦN 1: Dự án đã lưu
              // const Text(
              //   "Chọn bảng điều khiển đã lưu",
              //   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              // ),

              // const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: 200,
                    height: 120,
                    child: CustomBox(
                      size: const Size(200, 120),
                      title: "",
                      color: customColors[3],
                      icon: Icons.add_circle_sharp,
                      onTap: () async {
                        final shouldReload = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const WebViewApp(projectName: null),
                          ),
                        );

                        if (shouldReload == true) {
                          _loadSavedProjects(); // <- đã có sẵn rồi, gọi lại để reload
                        }
                      },
                    ),
                  ),
                  if (allProjects.isNotEmpty) ...[
                    ...allProjects.asMap().entries.map((entry) {
                      final index = entry.key;
                      final name = entry.value;

                      final color =
                          customColors[index %
                              customColors
                                  .length]; // Lặp lại màu nếu ít hơn số project

                      return SizedBox(
                        width: 200,
                        height: 120,
                        child: CustomBox(
                          size: const Size(200, 120),
                          title: name,
                          icon: Icons.folder,
                          color: color,
                          onTap: () async {
                            final shouldReload = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => WebViewApp(projectName: name),
                              ),
                            );

                            if (shouldReload == true) {
                              _loadSavedProjects();
                            }
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
                                  await ProgamingLayoutProvider.renameLayout(
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
                                  final idx = allProjects.indexOf(name);
                                  if (idx != -1) {
                                    allProjects.removeAt(idx);
                                    allProjects.insert(idx, newName);
                                  }
                                });
                              }
                            }
                          },
                          showMenuIcon: true,
                        ),
                      );
                    }),
                  ],
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
                  ...filteredProjects.asMap().entries.map((entry) {
                    final index = entry.key;
                    final name = entry.value;
                    final color = customColors[index % customColors.length];

                    return SizedBox(
                      width: 200,
                      height: 120,
                      child: CustomBox(
                        size: const Size(200, 120),
                        title: name,
                        icon: Icons.folder,
                        color: color,
                        onTap: () async {
                          final shouldReload = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WebViewApp(projectName: name),
                            ),
                          );
                          if (shouldReload == true) {
                            _loadSavedProjects();
                          }
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
                                await ProgamingLayoutProvider.renameLayout(
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
                                final idx = allProjects.indexOf(name);
                                if (idx != -1) {
                                  allProjects.removeAt(idx);
                                  allProjects.insert(idx, newName);
                                }
                              });
                            }
                          }
                        },
                        showMenuIcon: true,
                      ),
                    );
                  }),
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
  final Size size;
  final Color color;

  const CustomBox({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.showMenuIcon = false,
    this.onRename,
    this.onDelete,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: size.width,
            height: size.height,
            padding: const EdgeInsets.all(8),

            decoration: BoxDecoration(
              color: color.withOpacity(0.8),
              borderRadius: BorderRadius.circular(30),
              // border: Border.all(color: const Color.fromARGB(255, 0, 0, 0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(2, 2),
                  spreadRadius: 2,
                ),
              ],

              // gradient: LinearGradient(
              //   begin: Alignment.centerLeft,
              //   end: Alignment.centerRight,
              //   colors: [
              //     Color.fromARGB(255, 255, 255, 255).withOpacity(0.1),
              //     Color.fromARGB(255, 226, 228, 255).withOpacity(0.15),
              //   ],
              // ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 50,
                  color: const Color.fromARGB(255, 255, 255, 255),
                ),
                if (title.isNotEmpty) const SizedBox(height: 8),
                if (title.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      title,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
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
                color: Colors.indigo[20],
                icon: const Icon(Icons.more_vert, size: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // 👈 Bo tròn 10px
                ),
                onSelected: (value) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (value == 'rename') onRename?.call();
                    if (value == 'delete') onDelete?.call();
                  });
                },

                itemBuilder:
                    (context) => [
                      const PopupMenuItem(
                        value: 'rename',
                        child: Text('Rename'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
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
                final deleted = await ProgamingLayoutProvider.deleteLayout(
                  name,
                );
                Navigator.pop(context, deleted); // trả về true nếu xóa được
              },
              child: const Text("Xoá"),
            ),
          ],
        ),
  );
  return result ?? false;
}
