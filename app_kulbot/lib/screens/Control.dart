import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Kulbot/widgets/RobotControlScreen.dart';

class Control extends StatefulWidget {
  const Control({super.key});

  @override
  State<Control> createState() => _ControlState();
}

class _ControlState extends State<Control> {
  List<String> savedProjects = [];
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    loadProjects();
  }

  Future<void> loadProjects() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      savedProjects = prefs.getStringList('saved_projects') ?? [];
    });
  }

  void openNewProjectDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 600,
              maxHeight: 600,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RobotControlScreen(
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
                  const SizedBox(height: 16),
                  const Text(
                    "Các bảng điều khiển cơ bản",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 80,
                        child: CustomBox(
                          title: "Robot xe",
                          icon: Icons.toys,
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RobotControlScreen(
                                  projectName: "",
                                  type: "Robot_Car",
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
                          title: "Robot chó",
                          icon: Icons.pets,
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RobotControlScreen(
                                  projectName: "",
                                  type: "Robot_Dog",
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Hủy"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredProjects = savedProjects
        .where((p) => p.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

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
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: InputBorder.none,
                ),
                onChanged: (value) => setState(() => searchQuery = value),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            ...filteredProjects.map((name) => SizedBox(
                  width: 200,
                  height: 150,
                  child: CustomBox(
                    title: name,
                    icon: Icons.folder,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            RobotControlScreen(projectName: name, type: ""),
                      ),
                    ),
                  ),
                )),
            SizedBox(
              width: 200,
              height: 150,
              child: CustomBox(
                title: "New",
                icon: Icons.add,
                onTap: openNewProjectDialog,
              ),
            ),
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
              child: Text(title,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }
}
