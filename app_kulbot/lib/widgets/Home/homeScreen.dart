// import 'dart:math' as math; // <- thêm cái này để xử lý xoay 3D

//other libraries - thư viện khác
// libraries Flutter basic
import 'package:Kulbot/widgets/Control/Control/MenuControl.dart';
import 'package:flutter/material.dart'; // Giao diện Material Design cơ bản
import 'package:flutter/services.dart'; // Tương tác với hệ thống (Clipboard, SystemChrome,...)
// Thư viện Flutter quốc tế hóa
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // 🌐 Đa ngôn ngữ (auto-generate từ l10n.yaml)
// import 'package:Kulbot/l10n/l10n.dart';
// Quản lý trạng thái toàn cục
// import 'package:provider/provider.dart'; // 📦 Quản lý trạng thái (Provider pattern, IsDarkMode)
// import 'package:Kulbot/provider/provider.dart';
// Thư viện tiện ích khác
import 'package:carousel_slider/carousel_slider.dart'; // Tạo carousel/slider cuộn ngang
// import 'package:lottie/lottie.dart'; // Thêm import Lottie
// import 'package:path_provider/path_provider.dart'; // Lấy đường dẫn thư mục nội bộ (dùng để lưu file local)
import 'package:wakelock_plus/wakelock_plus.dart'; //giữ màn hình sáng - keep screen on

//get Widget Build - lấy widget build
import 'package:Kulbot/widgets/Home/ButtonHomeScreen.dart';

//get page - lấy trang
import 'package:Kulbot/widgets/IOT/IOT/IOT.dart';
import 'package:Kulbot/widgets/Control/Control.dart';
// import 'package:Kulbot/widgets/Control/Control/ControlSrceen.dart';
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
    // bool isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;
    // final provider = Provider.of<LocaleProvider>(context);
    // final locale = provider.locale ?? const Locale('en');
    final Size size = MediaQuery.of(context).size;

    final List<ButtonHomeScreenConfig> buttonConfigs = [
      ButtonHomeScreenConfig(
        icon: Icons.control_camera,
        title: AppLocalizations.of(context)!.control,
        imgPath: 'lib/assets/images/steering-wheel.png',
        navigator: Control(),
        color: Color.fromARGB(247, 164, 217, 255),
      ),
      ButtonHomeScreenConfig(
        icon: Icons.control_camera,
        title: AppLocalizations.of(context)!.control + " new",
        imgPath: 'lib/assets/images/steering-wheel.png',
        navigator: Menucontrol(),
        color: Color.fromARGB(247, 164, 217, 255),
      ),
      ButtonHomeScreenConfig(
        icon: Icons.code,
        title: AppLocalizations.of(context)!.programming,
        imgPath: 'lib/assets/images/program.png',
        // imgPath: 'lib/assets/animations/programming_animation.json',
        navigator: const Menuprograning(),
        color: Color.fromARGB(255, 255, 221, 136),
      ),
      ButtonHomeScreenConfig(
        icon: Icons.devices,
        title: AppLocalizations.of(context)!.iot,
        imgPath: 'lib/assets/images/iot.png',
        navigator: IOT(),
        color: Color.fromARGB(255, 129, 218, 129),
      ),
      ButtonHomeScreenConfig(
        icon: Icons.settings,
        title: AppLocalizations.of(context)!.setting,
        imgPath: 'lib/assets/images/setting.png',
        navigator: SettingScreen(),
        color: Color.fromARGB(255, 255, 153, 153),
      ),
    ];

    final items =
        buttonConfigs
            .map(
              (btn) => ButtonHomeScreen(
                imgPath: btn.imgPath,
                textButton: btn.title,
                color: btn.color,
                navigator: () => _navigateToScreen(context, btn.navigator),
                sizeheight: size.height,
              ),
            )
            .toList();
    return Scaffold(
      // backgroundColor: const Color.fromARGB(255, 255, 250, 250),
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
                        var colorselect = btn.color;

                        final color = selected ? colorselect : Colors.grey;

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
                            ? _buildCarousel(items, buttonConfigs, size)
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
    Size size,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: CarouselSlider.builder(
            carouselController: _carouselController,
            itemCount: items.length,
            options: CarouselOptions(
              height: size.height,
              viewportFraction: 0.3,
              enlargeCenterPage: true,
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
              double scale = _currentPage == index ? 1 : 0.85;

              return Transform(
                alignment: Alignment.center,
                transform:
                    Matrix4.identity()
                      // ..setEntry(3, 2, 0.001)
                      // ..rotateY(rotationY)
                      ..scale(scale),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(child: items[index]),
                    const SizedBox(height: 10),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
