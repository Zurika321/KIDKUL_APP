// import 'dart:math' as math; // <- thêm cái này để xử lý xoay 3D

//other libraries - thư viện khác
// libraries Flutter basic
import 'package:flutter/material.dart'; // Giao diện Material Design cơ bản
import 'package:flutter/services.dart'; // Tương tác với hệ thống (Clipboard, SystemChrome,...)
// Thư viện Flutter quốc tế hóa
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // 🌐 Đa ngôn ngữ (auto-generate từ l10n.yaml)
import 'package:Kulbot/l10n/l10n.dart';
// Quản lý trạng thái toàn cục
import 'package:provider/provider.dart'; // 📦 Quản lý trạng thái (Provider pattern, IsDarkMode)
import 'package:Kulbot/provider/provider.dart';
// Thư viện tiện ích khác
import 'package:carousel_slider/carousel_slider.dart'; // Tạo carousel/slider cuộn ngang
import 'package:lottie/lottie.dart'; // Thêm import Lottie
// import 'package:path_provider/path_provider.dart'; // Lấy đường dẫn thư mục nội bộ (dùng để lưu file local)
import 'package:wakelock_plus/wakelock_plus.dart'; //giữ màn hình sáng - keep screen on

//get Widget Build - lấy widget build
import 'package:Kulbot/widgets/Home/ButtonHomeScreen.dart';

//get page - lấy trang
import 'package:Kulbot/widgets/IOT/IOT/IOT.dart';
import 'package:Kulbot/widgets/Control/Control.dart';
import 'package:Kulbot/widgets/Setting/settingScreen.dart';

import 'package:Kulbot/widgets/programing/MenuPrograning.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentPage = 0;
  bool _initCarousel = false;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();

    // Gọi async sau khi widget đã dựng xong
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initAsyncTasks();
    });

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> _initAsyncTasks() async {
    await _preloadAssets();

    if (mounted) {
      setState(() {
        _initCarousel = true;
      });
    }
  }

  Future<void> _preloadAssets() async {
    try {
      await precacheImage(
        const AssetImage('lib/assets/images/steering-wheel.png'),
        context,
      );
      await precacheImage(
        const AssetImage('lib/assets/images/program.png'),
        context,
      );
      await precacheImage(
        const AssetImage('lib/assets/images/iot.png'),
        context,
      );
    } catch (e) {
      debugPrint("❗Lỗi preload ảnh: $e");
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = 0.0;
          const end = 1.0;
          const curve = Curves.easeInOut;
          final tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          final scaleAnimation = animation.drive(tween);

          return ScaleTransition(scale: scaleAnimation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;
    // final provider = Provider.of<LocaleProvider>(context);
    // final locale = provider.locale ?? const Locale('en');

    final List<ButtonHomeScreenConfig> buttonConfigs = [
      ButtonHomeScreenConfig(
        icon: Icons.control_camera,
        title: AppLocalizations.of(context)!.control,
        imgPath: 'lib/assets/images/steering-wheel.png',
        navigator: Control(),
      ),
      ButtonHomeScreenConfig(
        icon: Icons.code,
        title: AppLocalizations.of(context)!.programming + " new",
        imgPath: 'lib/assets/images/program.png',
        // imgPath: 'lib/assets/animations/programming_animation.json',
        navigator: const Menuprograning(),
      ),
      ButtonHomeScreenConfig(
        icon: Icons.devices,
        title: AppLocalizations.of(context)!.iot + " 2",
        imgPath: 'lib/assets/images/iot.png',
        navigator: IOT(),
      ),
      // ButtonHomeScreenConfig(
      //   icon:
      //       Icons.settings,
      //   title: AppLocalizations.of(context)!.setting,
      //   imgPath: 'lib/assets/images/setting.png',
      //   navigator: SettingScreen(),
      // ),
    ];

    final items =
        buttonConfigs
            .map(
              (btn) => ButtonHomeScreen(
                imgPath: btn.imgPath,
                textButton: btn.title,
                navigator: () => _navigateToScreen(context, btn.navigator),
              ),
            )
            .toList();
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 250, 250),
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Center(
                child: Wrap(
                  spacing: 10,
                  alignment: WrapAlignment.center,
                  children:
                      buttonConfigs.asMap().entries.map((entry) {
                        int index = entry.key;
                        final btn = entry.value;
                        final selected = _currentPage == index;

                        final color =
                            selected
                                ? const Color.fromARGB(255, 67, 224, 255)
                                : (isDarkMode
                                    ? const Color.fromARGB(255, 150, 150, 150)
                                    : Colors.grey);

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _currentPage = index;
                                _carouselController.animateToPage(index);
                              });
                            },
                            borderRadius: BorderRadius.circular(30),
                            splashColor: color.withOpacity(
                              0.3,
                            ), // hiệu ứng splash
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(
                                      0.1,
                                    ), // nền mờ của nút
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(btn.icon, color: color),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),

            // === Carousel nằm bên dưới ===
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SizedBox(
                    height: constraints.maxHeight,
                    child:
                        _initCarousel
                            ? _buildCarousel(items, buttonConfigs)
                            : const Center(child: CircularProgressIndicator()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarousel(
    List<Widget> items,
    List<ButtonHomeScreenConfig> configs,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: CarouselSlider.builder(
            carouselController: _carouselController,
            itemCount: items.length,
            options: CarouselOptions(
              height: MediaQuery.of(context).size.height,
              viewportFraction: 0.4,
              enlargeCenterPage: false,
              enableInfiniteScroll: true,
              scrollPhysics: BouncingScrollPhysics(),
              padEnds: true,
              enlargeStrategy: CenterPageEnlargeStrategy.zoom,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentPage = index;
                });
              },
            ),
            itemBuilder: (context, index, realIdx) {
              // double diff = (index - _currentPage).toDouble();
              // if (diff > items.length / 2) diff -= items.length;
              // if (diff < -items.length / 2) diff += items.length;
              // double value = diff;
              // double rotationY =
              //     _currentPage < index
              //         ? -10
              //         : _currentPage == index
              //         ? 0
              //         : 10; // Xoay theo hướng cuộn
              // double scale = _currentPage == index ? 1 : 0.95;

              return
              // Transform(
              //   alignment: Alignment.center,
              //   transform:
              //       Matrix4.identity()
              //         // ..setEntry(3, 2, 0.001)
              //         // ..rotateY(rotationY)
              //         ..scale(scale),
              //   child:
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    // decoration: BoxDecoration(
                    //   color: const Color.fromARGB(255, 255, 255, 255),
                    //   // boxShadow: [
                    //   //   BoxShadow(
                    //   //     color:
                    //   //         _currentPage == index
                    //   //             ? Color(0xFF3D5BFF)
                    //   //             : Colors.black12,
                    //   //     // blurRadius: 10,
                    //   //     spreadRadius: 2,
                    //   //     // offset: Offset(0, 5),
                    //   //   ),
                    //   // ],
                    //   // borderRadius: BorderRadius.circular(20),
                    // ),
                    child: items[index],
                  ),
                  const SizedBox(height: 10),
                ],
                // ),
              );
            },
          ),
        );
      },
    );
  }
}

// Thay thế hàm _showLanguageDialog bằng _showSettingsDialog
// void _showSettingsDialog(BuildContext context, Locale locale) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: Text('Cài đặt / Settings'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               leading: Icon(Icons.language),
//               title: Text('Ngôn ngữ / Language'),
//               onTap: () {
//                 Navigator.pop(context);
//                 _showLanguageDialog(context, locale);
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.login),
//               title: Text('Đăng nhập / Login'),
//               onTap: () {
//                 Navigator.pop(context);
//                 _showLoginDialog(context);
//               },
//             ),
//           ],
//         ),
//       );
//     },
//   );
// }

// void _showLanguageDialog(BuildContext context, Locale locale) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: Text('Chọn ngôn ngữ / Select Language'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             DropdownButtonHideUnderline(
//               child: DropdownButton(
//                 value: locale,
//                 icon: Container(width: 12),
//                 items:
//                     L10n.all.map((locale) {
//                       final flag = L10n.getflag(locale.languageCode);

//                       return DropdownMenuItem(
//                         value: locale,
//                         onTap: () {
//                           final provider = Provider.of<LocaleProvider>(
//                             context,
//                             listen: false,
//                           );

//                           provider.setLocale(locale);
//                         },
//                         child: Center(
//                           child: Text(flag, style: TextStyle(fontSize: 32)),
//                         ),
//                       );
//                     }).toList(),
//                 onChanged: (_) {},
//               ),
//             ),
//           ],
//         ),
//       );
//     },
//   );
// }

// void _showLoginDialog(BuildContext context) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: Text('Đăng nhập / Login'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               decoration: InputDecoration(
//                 labelText: 'Email',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 16),
//             TextField(
//               obscureText: true,
//               decoration: InputDecoration(
//                 labelText: 'Mật khẩu / Password',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: () {
//                 // TODO: Xử lý đăng nhập
//                 Navigator.pop(context);
//               },
//               child: Text('Đăng nhập / Login'),
//               style: ElevatedButton.styleFrom(
//                 minimumSize: Size(double.infinity, 45),
//               ),
//             ),
//           ],
//         ),
//       );
//     },
//   );
// }
