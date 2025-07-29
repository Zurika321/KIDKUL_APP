import 'package:KulBlock/l10n/l10n.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:KulBlock/provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return SettingWidget();
  }
}

class SettingWidget extends StatefulWidget {
  const SettingWidget({super.key});

  @override
  State<SettingWidget> createState() => _SettingWidgetState();
}

class _SettingWidgetState extends State<SettingWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final provider = Provider.of<LocaleProvider>(context);
    final locale = provider.locale ?? const Locale('en');
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
                      style: const TextStyle(fontSize: 16),
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButton(
                        value: locale,
                        icon: Container(width: 12),
                        items:
                            L10n.all.map((locale) {
                              final flag = L10n.getflag(locale.languageCode);

                              return DropdownMenuItem(
                                value: locale,
                                onTap: () {
                                  final provider = Provider.of<LocaleProvider>(
                                    context,
                                    listen: false,
                                  );

                                  provider.setLocale(locale);
                                },
                                child: Center(
                                  child: Text(
                                    flag,
                                    style: TextStyle(fontSize: 32),
                                  ),
                                ),
                              );
                            }).toList(),
                        onChanged: (_) {},
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
