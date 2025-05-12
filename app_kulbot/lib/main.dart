//ngôn ngữ - language
import 'package:Kulbot/l10n/l10n.dart';
import 'package:Kulbot/provider/provider.dart';

//page chính - main page
import 'package:Kulbot/screens/homeScreen.dart';

//các dịch vụ khác - other services
// import 'package:Kulbot/service/bluetooth_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; //ngôn ngữ - language
import 'package:flutter_localizations/flutter_localizations.dart'; //ngôn ngữ - language
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
      theme: ThemeData(
        useMaterial3: true,
        brightness:
            themeNotifier.isDarkMode ? Brightness.dark : Brightness.light,
      ),
      locale: localeProvider.locale ??
          const Locale('en'), //hơi thừa ?? nhưng cho chắc
      supportedLocales:
          L10n.all, //những ngôn ngữ đc hỗ trợ - supported languages
      localizationsDelegates: [
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
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    });
    //Hiển thị build ở dưới (logo công ty) 3 giây rồi chuyển sang trang HomeScreen
    WakelockPlus.enable();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]); //giữ màn hình nằm ngang - keep screen in landscape mode
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'lib/assets/images/kul_bot.png',
              height: 150,
            ),
            const SizedBox(
              height: 30,
            ),
            if (defaultTargetPlatform == TargetPlatform.android)
              const CupertinoActivityIndicator(
                color: Colors.white,
                radius: 20,
              )
            else
              const CircularProgressIndicator(
                color: Colors.white,
              )
            // const LinearProgressIndicator(
            //   color: Colors.white,
            //   backgroundColor: Colors.white30,
            //   minHeight: 6,
            // ),
          ],
        ),
      ),
    );
  }
}
