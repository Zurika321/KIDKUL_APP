import 'package:flutter/material.dart';

class ListBoxTester extends StatefulWidget {
  final Map<String, dynamic> value;
  final void Function(Map<String, dynamic>)? onSave;
  final VoidCallback? onDelete;
  final Map<String, dynamic> config;

  const ListBoxTester({
    super.key,
    required this.value,
    required this.config,
    this.onSave,
    this.onDelete,
  });

  @override
  State<ListBoxTester> createState() => _ListBoxTesterState();
}

class _ListBoxTesterState extends State<ListBoxTester>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late double width;
  late double height;

  @override
  void initState() {
    super.initState();
    width = (widget.config['width'] ?? 300).toDouble();
    height = (widget.config['height'] ?? 370).toDouble();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  dynamic get currentValue {
    switch (_tabController.index) {
      case 0:
        return widget.value["value1"] ?? "";
      case 1:
        return widget.value["value2"] ?? "";
      case 2:
        String value3 = "";
        widget.value["value3"].forEach((key, value) {
          value3 += "$key : $value \n";
        });
        return value3;
      default:
        return "Không xác định tab";
    }
  }

  void _showDeleteConfirmDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xác nhận xoá'),
            content: const Text('Bạn có chắc chắn muốn xoá phần tử này không?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Huỷ'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onDelete?.call();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Xoá', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      // borderRadius: BorderRadius.circular(8),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.blueAccent, width: 2),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              left: 0,
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: "Send Bluetooth"),
                  Tab(text: "Voice"),
                  Tab(text: "Update_PT"),
                ],
                onTap: (_) => setState(() {}),
              ),
            ),
            Positioned(
              top: 60,
              right: 0,
              left: 0,
              child: Text(
                "Dữ liệu từ phần tử: "
                "${(_tabController.index == 1
                    ? "mic"
                    : _tabController.index == 0
                    ? widget.value["valueofid1"]
                    : widget.value["valueofid2"])}",
                style: const TextStyle(fontSize: 15, color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ),
            Positioned(
              top: 100,
              right: 0,
              left: 0,
              child: SingleChildScrollView(
                child: SizedBox(
                  width: width - 20,
                  height: height - 120,
                  child: Text(
                    currentValue.isEmpty ? "Chưa có dữ liệu" : currentValue,
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            if (widget.config["lock"] == false)
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      width += details.delta.dx;
                      height += details.delta.dy;
                      width = width.clamp(150, 300);
                      height = height.clamp(200, 370);
                    });
                  },
                  onPanEnd: (_) {
                    widget.onSave?.call({
                      ...widget.config,
                      'width': width,
                      'height': height,
                    });
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.7),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: const Icon(
                      Icons.open_in_full,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            if (widget.config["lock"] == false)
              Positioned(
                left: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: _showDeleteConfirmDialog,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(
                        255,
                        255,
                        0,
                        0,
                      ).withOpacity(0.7),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: const Icon(
                      Icons.delete,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
