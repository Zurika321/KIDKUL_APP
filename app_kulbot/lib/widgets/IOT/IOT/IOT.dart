import 'package:flutter/material.dart';
import 'package:Kulbot/widgets/IOT/IOT/IOTSrceen.dart';

import 'package:flutter/foundation.dart'; //xem người dùng đang dùng web hay ko

import 'package:Kulbot/widgets/IOT/Sample%26Data/ControlLayoutProvider.dart'; //Mẫu Layout
import 'package:Kulbot/widgets/IOT/Sample%26Data/IotLayoutProvider.dart';
import 'package:geolocator/geolocator.dart'; //Lưu Layout

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

  final List<Color> customColors = [
    Color.fromARGB(247, 164, 217, 255),
    Color.fromARGB(255, 255, 221, 136),
    Color.fromARGB(255, 129, 218, 129),
    Color.fromARGB(255, 255, 153, 153),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 250, 250),
      appBar: AppBar(
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
              // if (allProjects.isNotEmpty) ...[
              // PHẦN 1: Dự án đã lưu
              const Text(
                "IOT Projects",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: 200,
                    height: 120,
                    child: CustomBox(
                      color: customColors[2],
                      size: const Size(200, 120),
                      title: "",
                      icon: Icons.add,
                      onTap: () async {
                        // final shouldReload = await
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

                        // if (shouldReload == true) {
                        //   _loadSavedProjects(); // <- đã có sẵn rồi, gọi lại để reload
                        // }
                      },
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    height: 120,
                    child: CustomBox(
                      color: customColors[3],
                      size: const Size(200, 120),
                      title: "",
                      icon: Icons.upload_file,
                      onTap: () {
                        // TODO
                      },
                    ),
                  ),
                  ...allProjects.asMap().entries.map((entry) {
                    final index = entry.key;
                    final name = entry.value;
                    final color = customColors[index % customColors.length];

                    return SizedBox(
                      width: 200,
                      height: 120,
                      child: CustomBox(
                        key: ValueKey(
                          "name:" +
                              name +
                              DateTime.now().millisecondsSinceEpoch.toString(),
                        ),
                        color: color,
                        title: name,
                        size: const Size(200, 120),
                        icon: Icons.folder,
                        onTap: () async {
                          // final shouldReload = await
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

                          // if (shouldReload == true) {
                          //   _loadSavedProjects(); // <- đã có sẵn rồi, gọi lại để reload
                          // }
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
                          if (!mounted) return;
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
                    );
                  }),
                ],
              ),
              const SizedBox(height: 24), // khoảng cách giữa các phần
              // ],

              // // PHẦN 2: Loại bảng điều khiển
              // const Text(
              //   "Chọn loại bảng điều khiển",
              //   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              // ),
              // const SizedBox(height: 12),
              // Wrap(
              //   spacing: 16,
              //   runSpacing: 16,
              //   children: [
              //     // SizedBox(
              //     //   width: 120,
              //     //   height: 80,
              //     //   child:
              //     CustomBox(
              //       size: const Size(120, 80),
              //       title: "",
              //       icon: Icons.add,
              //       onTap: () async {
              //         final shouldReload = await Navigator.push(
              //           context,
              //           MaterialPageRoute(
              //             builder:
              //                 (_) => RobotControlScreen(
              //                   projectName: "",
              //                   type: "new",
              //                 ),
              //           ),
              //         );

              //         if (shouldReload == true) {
              //           _loadSavedProjects(); // <- đã có sẵn rồi, gọi lại để reload
              //         }
              //       },
              //     ),
              //     // ),
              //     // SizedBox(
              //     //   width: 120,
              //     //   height: 80,
              //     //   child:
              //     CustomBox(
              //       size: const Size(120, 80),
              //       title: "",
              //       icon: Icons.upload_file,
              //       onTap: () {
              //         // TODO
              //       },
              //     ),
              //     // ),
              //   ],
              // ),
              // const SizedBox(height: 24),

              // PHẦN 3: Các bảng điều khiển cơ bản
              if (modelsLayoutIOT.isNotEmpty) ...[
                const Text(
                  "IOT Patterns",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    ...modelsLayoutIOT.asMap().entries.map((entry) {
                      final index = entry.key;
                      final model = entry.value;
                      final color = customColors[index % customColors.length];
                      return SizedBox(
                        width: 200,
                        height: 120,
                        child: CustomBox(
                          key: ValueKey("model:" + model),
                          color: color,
                          title: model,
                          icon: Icons.toys,
                          size: const Size(200, 120),
                          onTap: () async {
                            // final shouldReload = await
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

                            // if (shouldReload == true) {
                            //   _loadSavedProjects(); // <- đã có sẵn rồi, gọi lại để reload
                            // }
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ] else ...[
              // ==== PHẦN KẾT QUẢ TÌM KIẾM ====
              const Text(
                "🔍 Search Results",
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
                        key: ValueKey("name:" + name),
                        color: color,
                        title: name,
                        icon: Icons.folder,
                        size: const Size(200, 120),
                        onTap: () async {
                          // final shouldReload = await
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

                          // if (shouldReload == true) {
                          //   _loadSavedProjects(); // <- đã có sẵn rồi, gọi lại để reload
                          // }
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
                          if (!mounted) return;
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
                    );
                  }),
                  ...filteredModels.asMap().entries.map((entry) {
                    final index = entry.key;
                    final model = entry.value;
                    final color = customColors[index % customColors.length];

                    return SizedBox(
                      width: 200,
                      height: 120,
                      child: CustomBox(
                        key: ValueKey("model:" + model),
                        color: color,
                        title: model,
                        icon: Icons.toys,
                        size: const Size(200, 120),
                        onTap: () async {
                          // final shouldReload = await
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

                          // if (shouldReload == true) {
                          //   _loadSavedProjects(); // <- đã có sẵn rồi, gọi lại để reload
                          // }
                        },
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
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: onTap,
          child: Stack(
            children: [
              // Positioned(
              //   left: 0,
              //   top: 0,
              //   child:
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

              // ),
              if (showMenuIcon)
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4, right: 4),
                    child: PopupMenuWrapper(
                      onRename: onRename,
                      onDelete: onDelete,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class PopupMenuWrapper extends StatefulWidget {
  final VoidCallback? onRename;
  final VoidCallback? onDelete;

  const PopupMenuWrapper({super.key, this.onRename, this.onDelete});

  @override
  State<PopupMenuWrapper> createState() => _PopupMenuWrapperState();
}

class _PopupMenuWrapperState extends State<PopupMenuWrapper> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert, size: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        onSelected: (value) {
          // Thực thi trực tiếp, không dùng addPostFrameCallback
          if (value == 'rename') {
            widget.onRename?.call();
          } else if (value == 'delete') {
            widget.onDelete?.call();
          }
        },
        itemBuilder:
            (context) => const [
              PopupMenuItem(value: 'rename', child: Text('Đổi tên')),
              PopupMenuItem(value: 'delete', child: Text('Xóa')),
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
