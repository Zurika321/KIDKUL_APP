import 'package:flutter/material.dart';

class CarControlScreen extends StatelessWidget {
  const CarControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Điều khiển ô tô robot'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Spacer(),

            // Điều hướng chính
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_upward, size: 80),
                  onPressed: () {
                    // gửi lệnh tiến
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.rotate_left, size: 80),
                      onPressed: () {
                        // gửi lệnh quay trái
                      },
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      icon: const Icon(Icons.arrow_back, size: 80),
                      onPressed: () {
                        // gửi lệnh rẽ trái
                      },
                    ),
                    const SizedBox(width: 20),
                    const Icon(
                      Icons.radio_button_checked,
                      size: 80,
                    ), // joystick giả lập
                    const SizedBox(width: 20),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward, size: 80),
                      onPressed: () {
                        // gửi lệnh rẽ phải
                      },
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      icon: const Icon(Icons.rotate_right, size: 80),
                      onPressed: () {
                        // gửi lệnh quay phải
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                IconButton(
                  icon: const Icon(Icons.arrow_downward, size: 80),
                  onPressed: () {
                    // gửi lệnh lùi
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Hàng chức năng thêm
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // còi
                  },
                  icon: const Icon(Icons.volume_up, size: 45),
                  label: const Text("Còi", style: TextStyle(fontSize: 20)),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // đèn
                  },
                  icon: const Icon(Icons.lightbulb, size: 45),
                  label: const Text("Đèn", style: TextStyle(fontSize: 20)),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // dừng xe
                  },
                  icon: const Icon(Icons.stop_circle, size: 45),
                  label: const Text("Dừng", style: TextStyle(fontSize: 20)),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // tăng tốc độ
                  },
                  icon: const Icon(Icons.speed, size: 45),
                  label: const Text("Tăng tốc", style: TextStyle(fontSize: 20)),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // giảm tốc độ
                  },
                  icon: const Icon(Icons.remove_circle, size: 45),
                  label: const Text("Giảm tốc", style: TextStyle(fontSize: 20)),
                ),
              ],
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}
