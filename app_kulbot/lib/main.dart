//ngôn ngữ - language
import 'package:KulBlock/l10n/l10n.dart';
import 'package:KulBlock/provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; //ngôn ngữ - language
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; //ngôn ngữ - language

import 'package:lottie/lottie.dart';
// import 'package:flutter/foundation.dart'; // để dùng defaultTargetPlatform

//page chính - main page
import 'package:KulBlock/widgets/4Home/homeScreen.dart';

//các dịch vụ khác - other services
// import 'package:Kulbot/service/bluetooth_service.dart';
import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart'; //giữ màn hình sáng - keep screen on

//dữ liệu - data
import 'package:provider/provider.dart'; //provider - nhà cung cấp dữ liệu
//mục đích: lấy dữ liệu từ trạng thái cho các widget khác sử dụng
//vd: Provider.of<LocaleProvider>(context); //lấy dữ liệu ngôn ngữ từ trạng thái
//vd: Provider.of<ThemeNotifier>(context); //lấy dữ liệu sáng/tối từ trạng thái

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  final themeNotifier = ThemeNotifier();
  final localeProvider = LocaleProvider();

  await themeNotifier.loadTheme(); //Get Data from SharedPreferences IsDarkMode
  await localeProvider
      .loadLocale(); //Get Data from SharedPreferences LanguageCode

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => themeNotifier),
        ChangeNotifierProvider(create: (_) => localeProvider),
      ],
      child: const Kulbot(),
    ),
  );
}

class Kulbot extends StatelessWidget {
  const Kulbot({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KulBot',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeNotifier.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      locale:
          localeProvider.locale ??
          const Locale('en'), //hơi thừa ?? nhưng cho chắc
      supportedLocales:
          L10n.all, //những ngôn ngữ đc hỗ trợ - supported languages
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home:
          const SplashState(), //hiển thị khi vừa bật ứng dụng - show when just turn on the app
    );
  }
}

class SplashState extends StatefulWidget {
  const SplashState({super.key});

  @override
  State<SplashState> createState() => _SplashStaKulbotate();
}

class _SplashStaKulbotate extends State<SplashState> {
  @override
  void initState() {
    super.initState();

    WakelockPlus.enable();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 300,
              width: 400,
              child: Lottie.asset(
                'lib/assets/animations/Loading_animation.json',
                repeat: true,
                animate: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
