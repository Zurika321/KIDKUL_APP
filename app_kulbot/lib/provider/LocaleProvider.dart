import 'package:Kulbot/l10n/l10n.dart';
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
    if (!L10n.all.contains(locale))
      return; // Kiểm tra xem ngôn ngữ có hỗ trợ không
    _locale = locale;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
    notifyListeners();
  }

  void clearLocale() async {
    //Không hiểu tại sao có hàm này ở đây luôn :)) kí tên: Kha(thực tập)
    _locale = const Locale(
        'en'); //chỗ này cho null thì widget khác phải ?? Locale('en') nên để z lun
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

  void toggleTheme() async {
    isDarkMode = !isDarkMode;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', isDarkMode);
    notifyListeners();
  }
}
