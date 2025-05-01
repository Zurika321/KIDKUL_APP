// import 'dart:math' as math; // <- thêm cái này để xử lý xoay 3D

//other libraries - thư viện khác
// libraries Flutter basic
import 'package:flutter/material.dart'; // Giao diện Material Design cơ bản
import 'package:flutter/services.dart'; // Tương tác với hệ thống (Clipboard, SystemChrome,...)
// Thư viện Flutter quốc tế hóa
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // 🌐 Đa ngôn ngữ (auto-generate từ l10n.yaml)
// Quản lý trạng thái toàn cục
import 'package:provider/provider.dart'; // 📦 Quản lý trạng thái (Provider pattern, IsDarkMode)
import 'package:Kulbot/provider/provider.dart';
// Thư viện tiện ích khác
import 'package:carousel_slider/carousel_slider.dart'; // Tạo carousel/slider cuộn ngang
import 'package:path_provider/path_provider.dart'; // Lấy đường dẫn thư mục nội bộ (dùng để lưu file local)
import 'package:wakelock/wakelock.dart'; // Giữ màn hình luôn bật (không tắt khi không hoạt động)

//get Widget Build - lấy widget build
import 'package:Kulbot/utils/build/ButtonHomeScreen.dart';

//get page - lấy trang
import 'package:Kulbot/screens/iot_screen/iotScreen.dart';
import 'package:Kulbot/screens/carControll.dart';
import 'package:Kulbot/screens/programingScreen.dart';
import 'package:Kulbot/screens/settingScreen.dart';

//get data - lấy dữ liệu
// import 'package:shared_preferences/shared_preferences.dart'; // Lưu trữ dữ liệu cục bộ (SharedPreferences)

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // String _moveForwardCommand = 'FF';
  // String _moveBackwardCommand = 'BB';
  // AudioPlayer? _audioPlayer;
  int _currentPage = 0; // <-- Thêm biến để tự lưu trang hiện tại
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Wakelock.enable();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // _audioPlayer = AudioPlayer();
    // _playMusic();
    // _audioPlayer?.onPlayerComplete.listen((event) {
    //   _playMusic();
    // });
  }

  @override
  void dispose() {
    // _audioPlayer?.dispose();
    super.dispose();
  }

  // void _playMusic() async {
  //   // Load file nhạc từ assets
  //   final ByteData data =
  //       await rootBundle.load('lib/assets/music/background-music.mp3');
  //   final Uint8List bytes = data.buffer.asUint8List();

  //   // Lưu file nhạc vào thư mục tạm thời
  //   final Directory tempDir = await getTemporaryDirectory();
  //   final String tempPath = tempDir.path;
  //   final File tempFile = File('$tempPath/background-music.mp3');
  //   await tempFile.writeAsBytes(bytes);

  //   // Phát file nhạc từ thư mục tạm thời
  //   await _audioPlayer?.play(DeviceFileSource(tempFile.path));
  // }

  // Future<void> _loadSettings() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     _moveForwardCommand = prefs.getString('moveForward') ?? 'FF';
  //     _moveBackwardCommand = prefs.getString('moveBackward') ?? 'BB';
  //   });
  // }

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = 0.0;
          const end = 1.0;
          const curve = Curves.easeInOut;
          final tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          final scaleAnimation = animation.drive(tween);

          return ScaleTransition(
            scale: scaleAnimation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;
    final List<ButtonHomeScreenConfig> buttonConfigs = [
      ButtonHomeScreenConfig(
        icon: Icons.home,
        title: AppLocalizations.of(context)!.carControl,
        imgPath: 'lib/assets/images/steering-wheel.png',
        navigator: CarControl(),
      ),
      // ButtonHomeScreen(
      //   imgPath: 'lib/assets/images/Bascot_16.png',
      //   textButton: AppLocalizations.of(context)!.bascotControl,
      //   navigator: () => _navigateToScreen(context, const Bascotcontrolscreen()),
      // ),
      ButtonHomeScreenConfig(
        icon: Icons.code,
        title: AppLocalizations.of(context)!.programming,
        imgPath: 'lib/assets/images/program.png',
        navigator: Programingscreen(),
      ),
      ButtonHomeScreenConfig(
        icon: Icons.devices,
        title: AppLocalizations.of(context)!.iot,
        imgPath: 'lib/assets/images/iot.png',
        navigator: Iotscreen(),
      ),
      // ButtonHomeScreen(
      //   imgPath: 'lib/assets/images/kulbot.png',
      //   textButton: AppLocalizations.of(context)!.humanControl,
      //   navigator: () => _navigateToScreen(context, humanControl()),
      // ),
      // ButtonHomeScreen(
      //   imgPath: 'lib/assets/images/TFlogo.png',
      //   textButton: 'TFlite Camera',
      //   navigator: () => _navigateToScreen(context, TFliteCamera()),
      // ),
      // ButtonHomeScreen(
      //   imgPath: 'lib/assets/images/robothead.png',
      //   textButton: AppLocalizations.of(context)!.dogControl,
      //   navigator: () => _navigateToScreen(context, dogControl()),
      // ), mấy cái này là comment của code cũ nên không xóa
      ButtonHomeScreenConfig(
        icon: Icons
            .settings, //mấy icon này có thể chưa đúng có thể sau này sẽ sửa lại
        title: AppLocalizations.of(context)!.setting,
        imgPath: 'lib/assets/images/setting.png',
        navigator: SettingScreen(),
      ),
    ];

    final items = buttonConfigs
        .map((btn) => ButtonHomeScreen(
              imgPath: btn.imgPath,
              textButton: btn.title,
              navigator: () => _navigateToScreen(context, btn.navigator),
            ))
        .toList();

    return Scaffold(
      // backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        bottom: true,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              height: constraints.maxHeight,
              child: _buildCarousel(items, buttonConfigs),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPage,
        onTap: (index) {
          setState(() {
            _currentPage = index;
            _carouselController.animateToPage(index);
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color.fromARGB(255, 200, 200, 200),
        selectedItemColor: Color.fromARGB(255, 67, 224, 255),
        unselectedItemColor: Colors.grey,
        items: buttonConfigs
            .map((btn) =>
                BottomNavigationBarItem(icon: Icon(btn.icon), label: btn.title))
            .toList(),
      ),
    );
  }

  Widget _buildCarousel(
      List<Widget> items, List<ButtonHomeScreenConfig> configs) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableHeight = constraints.maxHeight;
        return Center(
          child: CarouselSlider.builder(
            carouselController: _carouselController,
            itemCount: items.length,
            options: CarouselOptions(
              height: MediaQuery.of(context).size.height,
              viewportFraction: 0.55,
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
              double diff = (index - _currentPage).toDouble();
              if (diff > items.length / 2) diff -= items.length;
              if (diff < -items.length / 2) diff += items.length;
              double value = diff;
              double rotationY = value * 0.3;
              double scale = 1 - (value.abs() * 0.15);

              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(rotationY)
                  ..scale(scale),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 181, 181, 181),
                        boxShadow: [
                          BoxShadow(
                            color: _currentPage == index
                                ? Color(0xFF3D5BFF)
                                : Colors.black12,
                            blurRadius: 10,
                            spreadRadius: 2,
                            offset: Offset(0, 5),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: items[index],
                    ),
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
