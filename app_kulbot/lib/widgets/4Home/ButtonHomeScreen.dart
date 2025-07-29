import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Cấu hình cho các nút trên màn hình chính
class ButtonHomeScreenConfig {
  final IconData icon;
  final String title;
  final String imgPath;
  final Widget navigator;
  final Color color;

  ButtonHomeScreenConfig({
    required this.icon,
    required this.title,
    required this.imgPath,
    required this.navigator,
    required this.color,
  });
}

// Widget tạo nút trên màn hình chính với thiết kế nhỏ gọn
class ButtonHomeScreen extends StatelessWidget {
  final String imgPath;
  final String textButton;
  final VoidCallback navigator;
  final Color color;
  final double sizeheight;

  ButtonHomeScreen({
    super.key,
    required this.imgPath,
    required this.textButton,
    required this.navigator,
    required this.color,
    required this.sizeheight,
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
                      width: sizeheight - 150,
                      height: sizeheight - 150,
                      padding: EdgeInsets.all(sizeheight * 0.1),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          const BoxShadow(
                            color: Color.fromARGB(60, 0, 0, 0),
                            offset: Offset(0, 4),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                          BoxShadow(
                            color: color.withOpacity(0.25),
                            offset: const Offset(0, 1),
                            blurRadius: 2,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child:
                      // ClipOval(
                      //   child:
                      Image.asset(imgPath),
                      // ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                // decoration: BoxDecoration(
                //   gradient: LinearGradient(
                //     begin: Alignment.centerLeft,
                //     end: Alignment.centerRight,
                //     colors: [
                //       const Color(0xFFCE93D8).withOpacity(0.1),
                //       const Color.fromARGB(
                //         255,
                //         255,
                //         255,
                //         255,
                //       ).withOpacity(0.15),
                //     ],
                //   ),
                //   borderRadius: BorderRadius.circular(10),
                // ),
                child: Text(
                  textButton,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
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
