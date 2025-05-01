import 'package:Kulbot/l10n/l10n.dart';
import 'package:Kulbot/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:Kulbot/provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingWidget extends StatefulWidget {
  //final Function(String) onSendMessage;

  SettingWidget({
    super.key,
  });

  @override
  State<SettingWidget> createState() => _SettingWidgetState();
}

class _SettingWidgetState extends State<SettingWidget> {
  // int _currentStep = 0;
  // final ScrollController _scrollController = ScrollController();
  // final List<GlobalKey> _keys = List.generate(4, (index) => GlobalKey());

  // void _scrollToCurrentStep() {
  //   // Calculate the position of the current step's content and scroll to it
  //   final context = _keys[_currentStep].currentContext;
  //   if (context != null) {
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       Scrollable.ensureVisible(
  //         context,
  //         duration: Duration(milliseconds: 500),
  //         curve: Curves.easeInOut,
  //         alignment: 0.5, // 0.0 means top of the screen
  //       );
  //     });
  //   }
  // }

  final TextEditingController _moveForwardController = TextEditingController();
  final TextEditingController _moveFLeftController = TextEditingController();
  final TextEditingController _moveFRightController = TextEditingController();

  final TextEditingController _moveBackwardController = TextEditingController();
  final TextEditingController _moveBLeftController = TextEditingController();
  final TextEditingController _moveBRightController = TextEditingController();

  final TextEditingController _moveTurnLeftController = TextEditingController();
  final TextEditingController _moveTurnRightController =
      TextEditingController();

  final TextEditingController _moveStopController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _moveForwardController.text = prefs.getString('moveForward') ?? 'FF';
      _moveFLeftController.text = prefs.getString('moveFLeft') ?? 'GG';
      _moveFRightController.text = prefs.getString('moveFRight') ?? 'II';

      _moveBackwardController.text = prefs.getString('moveBackward') ?? 'BB';
      _moveBLeftController.text = prefs.getString('moveBLeft') ?? 'JJ';
      _moveBRightController.text = prefs.getString('moveBRight') ?? 'HH';

      _moveTurnLeftController.text = prefs.getString('moveTurnLeft') ?? 'LL';
      _moveTurnRightController.text = prefs.getString('moveTurnRight') ?? 'RR';

      _moveStopController.text = prefs.getString('moveStop') ?? 'SS';
    });
  }

  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString(
        'moveForward',
        _moveForwardController.text.isNotEmpty
            ? _moveForwardController.text
            : 'FF');

    prefs.setString(
        'moveFLeft',
        _moveFLeftController.text.isNotEmpty
            ? _moveFLeftController.text
            : 'GG');

    prefs.setString(
        'moveFRight',
        _moveFRightController.text.isNotEmpty
            ? _moveFRightController.text
            : 'II');

    prefs.setString(
        'moveBackward',
        _moveBackwardController.text.isNotEmpty
            ? _moveBackwardController.text
            : 'BB');

    prefs.setString(
        'moveBLeft',
        _moveBLeftController.text.isNotEmpty
            ? _moveBLeftController.text
            : 'JJ');

    prefs.setString(
        'moveBRight',
        _moveBRightController.text.isNotEmpty
            ? _moveBRightController.text
            : 'HH');

    prefs.setString(
        'moveTurnLeft',
        _moveTurnLeftController.text.isNotEmpty
            ? _moveTurnLeftController.text
            : 'LL');

    prefs.setString(
        'moveTurnRight',
        _moveTurnRightController.text.isNotEmpty
            ? _moveTurnRightController.text
            : 'RR');

    prefs.setString('moveStop',
        _moveStopController.text.isNotEmpty ? _moveStopController.text : 'SS');
  }

  // void _sendMessage() {
  //   String message;
  //   message = _moveForwardController.text;
  //   message = _moveBackwardController.text;
  //   message = _moveTurnLeftController.text;
  //   message = _moveTurnRightController.text;
  //   if (message.isNotEmpty) {
  //     widget.onSendMessage(message);
  //     _saveSettings();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final provider = Provider.of<LocaleProvider>(context);
    final locale = provider.locale ?? Locale('en');
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(AppLocalizations.of(context)!.setting),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Column(
            children: [
              SwitchListTile(
                title: Text(
                  themeNotifier.isDarkMode
                      ? AppLocalizations.of(context)!.darkMode
                      : AppLocalizations.of(context)!.lightMode,
                ),
                value: themeNotifier.isDarkMode,
                onChanged: (bool value) {
                  themeNotifier.toggleTheme();
                },
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.changelanguage,
                      style: TextStyle(fontSize: 16),
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButton(
                        value: locale,
                        icon: Container(width: 12),
                        items: L10n.all.map(
                          (locale) {
                            final flag = L10n.getflag(locale.languageCode);

                            return DropdownMenuItem(
                              child: Center(
                                child: Text(
                                  flag,
                                  style: TextStyle(fontSize: 32),
                                ),
                              ),
                              value: locale,
                              onTap: () {
                                final provider = Provider.of<LocaleProvider>(
                                    context,
                                    listen: false);

                                provider.setLocale(locale);
                              },
                            );
                          },
                        ).toList(),
                        onChanged: (_) {},
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "Cài đặt chi tiết",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _moveForwardController,
                      decoration: InputDecoration(
                        labelText: "Điền giá trị đi tiến",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _moveFLeftController,
                      decoration: InputDecoration(
                        labelText: "Điền giá trị đi tiến trái",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _moveFRightController,
                      decoration: InputDecoration(
                        labelText: "Điền giá trị đi tiến phải",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _moveBackwardController,
                      decoration: InputDecoration(
                        labelText: "Điền giá trị đi lùi",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _moveBLeftController,
                      decoration: InputDecoration(
                        labelText: "Điền giá trị lùi trái",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _moveBRightController,
                      decoration: InputDecoration(
                        labelText: "Điền giá trị lùi phải",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _moveTurnLeftController,
                      decoration: InputDecoration(
                        labelText: "Điền giá trị rẽ trái",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _moveTurnRightController,
                      decoration: InputDecoration(
                        labelText: "Điền giá trị rẽ phải",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _moveStopController,
                      decoration: InputDecoration(
                        labelText: "Điền giá trị dừng",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Container(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(100, 50),
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    _saveSettings();
                    Fluttertoast.showToast(msg: "Đã Lưu!", fontSize: 20);
                  },
                  child: Text(
                    "Lưu",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              )
            ],
          ),
        ),
      ),
    );
  }
}
