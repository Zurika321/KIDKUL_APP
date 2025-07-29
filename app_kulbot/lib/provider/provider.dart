import 'package:KulBlock/l10n/l10n.dart';
import 'package:flutter/material.dart';
//dữ liệu - data
import 'package:shared_preferences/shared_preferences.dart';

// class LocaleProvider extends ChangeNotifier {
//   Locale? _locale;

//   Locale? get locale => _locale;

//   void setLocale(Locale locale) {
//     if (!L10n.all.contains(locale)) return;

//     _locale = locale;
//     notifyListeners();
//   }

//   void clearLocale() {
//     _locale = null;
//     notifyListeners();
//   }
// }code cũ

//class trạng thái ngôn ngữ - class language state
class LocaleProvider extends ChangeNotifier {
  Locale? _locale;

  Locale? get locale => _locale;

  Future<void> loadLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? langCode = prefs.getString('languageCode');
    _locale = Locale(langCode ?? 'en');
    notifyListeners();
  }

  void setLocale(Locale locale) async {
    if (!L10n.all.contains(locale)) {
      return; // Kiểm tra xem ngôn ngữ có hỗ trợ không
    }
    _locale = locale;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
    notifyListeners();
  }

  void clearLocale() async {
    //Không hiểu tại sao có hàm này ở đây luôn :)) kí tên: Kha(thực tập)
    _locale = const Locale(
      'en',
    ); //chỗ này cho null thì widget khác phải ?? Locale('en') nên để z lun
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', 'en');
    notifyListeners();
  }
}

//class trạng thái sáng/tối - class light/dark mode
//lưu chung vào provider.dart luôn cho gọn //provider--nhà cung cấp dữ liệu
class ThemeNotifier extends ChangeNotifier {
  bool isDarkMode = false;

  Future<void> loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  ThemeData get currentTheme =>
      isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;

  void toggleTheme() async {
    isDarkMode = !isDarkMode;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', isDarkMode);
    notifyListeners();
  }
}

class AppTheme {
  static const Color primaryColor = Color(0xFF0066CC);
  static const Color secondaryColor = Color(0xFF00CC99);
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color errorColor = Colors.redAccent;

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundLight,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      background: Color.fromARGB(255, 230, 231, 237),
      surface: surfaceLight,
      error: errorColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 1,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    ),
    iconTheme: const IconThemeData(color: Colors.black),
    textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.black)),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundDark,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      background: Color.fromARGB(255, 71, 71, 72),
      surface: surfaceDark,
      error: errorColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    ),
    iconTheme: const IconThemeData(color: Colors.white70),
    textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
  );
}
