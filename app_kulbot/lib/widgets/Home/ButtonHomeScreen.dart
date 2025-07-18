import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

// Cấu hình cho các nút trên màn hình chính
class ButtonHomeScreenConfig {
  final IconData icon;
  final String title;
  final String imgPath;
  final Widget navigator;

  ButtonHomeScreenConfig({
    required this.icon,
    required this.title,
    required this.imgPath,
    required this.navigator,
  });
}

// Widget tạo nút trên màn hình chính với thiết kế nhỏ gọn
class ButtonHomeScreen extends StatelessWidget {
  final String imgPath;
  final String textButton;
  final VoidCallback navigator;

  ButtonHomeScreen({
    super.key,
    required this.imgPath,
    required this.textButton,
    required this.navigator,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      // 👈 Thêm Center để canh giữa dọc
      child: GestureDetector(
        onTap: navigator,
        child: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment:
                MainAxisAlignment.center, // 👈 Canh giữa dọc trong Column
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Center(
                    child: Container(
                      width: MediaQuery.of(context).size.height * 0.55,
                      height: MediaQuery.of(context).size.height * 0.55,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.purple[50], // 🎨 Màu nền bạn muốn
                        shape: BoxShape.circle,
                      ),
                      child:
                      // ClipOval(
                      //   child:
                      Image.asset(
                        imgPath,
                        // fit:
                        //     BoxFit
                        //         .cover, // 👈 Giúp ảnh đầy container mà không méo
                      ),
                      // ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      const Color(0xFFCE93D8).withOpacity(0.1),
                      const Color.fromARGB(
                        255,
                        255,
                        255,
                        255,
                      ).withOpacity(0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  textButton,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF7B1FA2),
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
