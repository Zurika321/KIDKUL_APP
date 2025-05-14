import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Kulbot/widgets/IOT/IOT/IOTSrceen.dart';
import 'package:Kulbot/provider/FileManage.dart';

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
    final projectNames = await IotLayoutProvider.getSavedLayoutNames();
    setState(() {
      allProjects = projectNames;
    });
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
                  children: [
                    ...allProjects.map(
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
                        ),
                      ),
                    ),
                  ],
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

  const CustomBox({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
    );
  }
}
