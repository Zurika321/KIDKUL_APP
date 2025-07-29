import 'package:flutter/material.dart';

import 'package:flutter/foundation.dart'; //xem người dùng đang dùng web hay ko

import 'package:KulBlock/widgets/1Menu/DiagLogFormMenu.dart';
import 'package:KulBlock/widgets/1Menu/UnifiedMenuScreen .dart';
import 'package:KulBlock/widgets/1Menu/CustomBox.dart';

class Menus extends StatefulWidget {
  final String menu;

  Menus({super.key, required String menu}) : menu = _validateMenu(menu);

  static const List<String> validMenus = UnifiedMenuScreen.validKeys;

  // Hàm kiểm tra hợp lệ
  static String _validateMenu(String value) {
    return validMenus.contains(value) ? value : "MenuIOT";
  }

  @override
  State<Menus> createState() => _MenusState();
}

class _MenusState extends State<Menus> {
  late UnifiedMenuScreen IFM_Menu;
  List<String> allProjects = [];
  List<String> filteredProjects = [];
  List<String> modelsLayout = [];
  List<String> filteredModels = [];
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadSavedProjects();
  }

  Future<void> _loadSavedProjects() async {
    IFM_Menu = UnifiedMenuScreen.of(widget.menu);
    final List<String> projects =
        kIsWeb
            ? []
            : (IFM_Menu.haveProject != null
                ? await IFM_Menu.haveProject!()
                : []);

    final List<String> models =
        IFM_Menu.haveModel != null ? IFM_Menu.haveModel! : [];

    setState(() {
      allProjects = projects;
      modelsLayout = models;
    });
  }

  void _filterProjects() {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      filteredProjects = List.from(allProjects);
      filteredModels = List.from(modelsLayout);
    } else {
      filteredProjects =
          allProjects.where((p) => p.toLowerCase().contains(query)).toList();

      filteredModels =
          modelsLayout.where((m) => m.toLowerCase().contains(query)).toList();
    }
  }

  final List<Color> customColors = [
    const Color.fromARGB(247, 164, 217, 255),
    const Color.fromARGB(255, 255, 221, 136),
    const Color.fromARGB(255, 129, 218, 129),
    const Color.fromARGB(255, 255, 153, 153),
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
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color.fromARGB(255, 190, 190, 190),
                ),
              ),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
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
              Text(
                widget.menu,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (IFM_Menu.haveProject != null)
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
                          final shouldReload = await IFM_Menu.navigatorTo(
                            context: context,
                            create: true,
                          );

                          if (shouldReload == true) {
                            _loadSavedProjects();
                          }
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
                          // key: ValueKey(
                          //   "name:" +
                          //       name +
                          //       DateTime.now().millisecondsSinceEpoch
                          //           .toString(),
                          // ),
                          color: color,
                          title: name,
                          size: const Size(200, 120),
                          icon: Icons.folder,
                          onTap: () async {
                            final shouldReload = await IFM_Menu.navigatorTo(
                              context: context,
                              projectName: name,
                              type: "",
                            );

                            if (shouldReload == true) {
                              _loadSavedProjects();
                            }
                          },
                          onDelete: () async {
                            final success = await showDeleteDialog(
                              context,
                              name,
                              IFM_Menu.delete,
                            );
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '✅ Successfully deleted layout "$name"!',
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
                            final controller = TextEditingController(
                              text: name,
                            );
                            final newName = await showRenameDialog(
                              context,
                              controller,
                            );

                            if (newName != null && newName != name) {
                              final success =
                                  await IFM_Menu.rename?.call(name, newName) ??
                                  false;
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '✅ Successfully renamed layout "$name" to "$newName"!',
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
              if (IFM_Menu.haveProject != null)
                const SizedBox(height: 24), // khoảng cách giữa các phần
              // PHẦN 2: Các bảng điều khiển cơ bản
              if (modelsLayout.isNotEmpty) ...[
                if (IFM_Menu.haveProject != null) ...[
                  const Text(
                    "Patterns",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                ],
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    ...modelsLayout.asMap().entries.map((entry) {
                      final index = entry.key;
                      final model = entry.value;
                      final color = customColors[index % customColors.length];
                      return SizedBox(
                        width: 200,
                        height: 120,
                        child: CustomBox(
                          // key: ValueKey("model:" + model),
                          color: color,
                          title: model,
                          icon: Icons.toys,
                          size: const Size(200, 120),
                          onTap: () async {
                            final shouldReload = await IFM_Menu.navigatorTo(
                              context: context,
                              projectName: "",
                              type: model,
                            );

                            if (shouldReload == true) {
                              _loadSavedProjects();
                            }
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
                        // key: ValueKey("name:" + name),
                        color: color,
                        title: name,
                        icon: Icons.folder,
                        size: const Size(200, 120),
                        onTap: () async {
                          final shouldReload = await IFM_Menu.navigatorTo(
                            context: context,
                            projectName: name,
                            type: "",
                          );

                          if (shouldReload == true) {
                            _loadSavedProjects();
                          }
                        },
                        onDelete: () async {
                          final success = await showDeleteDialog(
                            context,
                            name,
                            IFM_Menu.delete,
                          );
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '✅ Successfully deleted layout "$name"!',
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
                                await IFM_Menu.rename?.call(name, newName) ??
                                false;
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '✅ Successfully renamed layout "$name" to "$newName"!',
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
                        // key: ValueKey("model:" + model),
                        color: color,
                        title: model,
                        icon: Icons.toys,
                        size: const Size(200, 120),
                        onTap: () async {
                          final shouldReload = await IFM_Menu.navigatorTo(
                            context: context,
                            projectName: "",
                            type: model,
                          );

                          if (shouldReload == true) {
                            _loadSavedProjects();
                          }
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
