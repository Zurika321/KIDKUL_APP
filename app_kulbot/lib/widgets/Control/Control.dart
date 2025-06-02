import 'package:Kulbot/widgets/Control/CarControlScreen.dart';
import 'package:Kulbot/widgets/Control/DogControlScreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:Kulbot/widgets/Control/RobotControlScreen.dart';
import 'package:Kulbot/widgets/Control/control_widget.dart';

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

  @override
  Widget build(BuildContext context) {
    final filteredProjects =
        savedProjects
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
            ...filteredProjects.map(
              (name) => SizedBox(
                width: 200,
                height: 150,
                child: CustomBox(
                  title: name,
                  icon: Image.asset(
                    'lib/assets/images/', // đường dẫn tới ảnh trong thư mục assets
                    width: 40,
                    height: 40,
                  ),
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => ControlWidget(
                                checkAvailability:
                                    true, // hoặc false tùy logic bạn muốn
                              ),
                        ),
                      ),
                  backgroundColor: const Color.fromARGB(255, 228, 234, 184),
                ),
              ),
            ),
            SizedBox(
              height: 300,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    SizedBox(width: 8),
                    SizedBox(
                      width: 300,
                      height: 300,
                      child: CustomBox(
                        title: "Robot xe",
                        backgroundColor: const Color.fromARGB(
                          255,
                          236,
                          164,
                          135,
                        ),
                        icon: Image.asset(
                          'lib/assets/images/xe.png', // Thay bằng đường dẫn ảnh của bạn
                          width: 300,
                          height: 250,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CarControlScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 16),
                    SizedBox(
                      width: 300,
                      height: 300,
                      child: CustomBox(
                        title: "Robot người",
                        icon: Image.asset(
                          'lib/assets/images/kul_bot.png', // Thay bằng đường dẫn ảnh của bạn
                          width: 300,
                          height: 250,
                        ),
                        backgroundColor: const Color.fromARGB(
                          255,
                          108,
                          165,
                          191,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => ControlWidget(
                                    checkAvailability:
                                        true, // hoặc false tùy logic bạn muốn
                                  ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 16),
                    SizedBox(
                      width: 300,
                      height: 300,
                      child: CustomBox(
                        title: "Robot chó",
                        backgroundColor: const Color.fromARGB(
                          255,
                          113,
                          200,
                          113,
                        ),
                        icon: Image.asset(
                          'lib/assets/images/dog.jpg', // Thay bằng đường dẫn ảnh của bạn
                          width: 300,
                          height: 250,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => DogWidget()),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                  ],
                ),
              ),
            ),

            // SizedBox(
            //   width: 200,
            //   height: 150,
            //   child: CustomBox(
            //     title: "New",
            //     icon: Icons.add,
            //     onTap: openNewProjectDialog,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

class CustomBox extends StatelessWidget {
  final String title;
  final Widget icon;
  final VoidCallback onTap;
  final Color backgroundColor;

  const CustomBox({
    Key? key,
    required this.title,
    required this.icon,
    required this.onTap,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
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
            icon,
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
