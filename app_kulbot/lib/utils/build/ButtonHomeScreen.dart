import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
    // Lấy màu nền và màu chữ dựa trên chế độ (dark/light mode)
    // final backgroundColor = Theme.of(context).colorScheme.surface;
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Column(
      children: [
        GestureDetector(
          onTap: navigator,
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.4,
              height: MediaQuery.of(context).size.height * 0.45,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
                // Box shadow cái này thì chắc không cần vì làm ở bên trang home rồi
                // boxShadow: [
                //   BoxShadow(
                //     color: Colors.grey.shade400,
                //     blurRadius: 20,
                //     spreadRadius: 10,
                //   )
                // ]
              ),
              child: Center(
                child: Image.asset(imgPath),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          textButton,
          style: TextStyle(
            fontSize: 30,
            color: textColor, // Màu chữ theo theme
          ),
        )
      ],
    );
  }
}
