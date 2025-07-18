import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LocalizedStringGetter {
  static String formatKey(String input) {
    return input.toLowerCase().replaceAll(' ', '_');
  }

  static String get(BuildContext context, String key) {
    final loc = AppLocalizations.of(context)!;
    final formattedKey = formatKey(key);

    final Map<String, String> localizedMap = {
      'bascotcontrol': loc.bascotControl,
      'carcontrol': loc.carControl,
      'changelanguage': loc.changelanguage,
      'control': loc.control,
      'darkmode': loc.darkMode,
      'dogcontrol': loc.dogControl,
      'home': loc.home,
      'humancontrol': loc.humanControl,
      'iot': loc.iot,
      'iot_area_chart': loc.iot_area_chart,
      'iot_bluetooth_status': loc.iot_bluetooth_status,
      'iot_button': loc.iot_button,
      'iot_chart': loc.iot_chart,
      'iot_column_chart': loc.iot_column_chart,
      'iot_control_buttons': loc.iot_control_buttons,
      'iot_data_tables': loc.iot_data_tables,
      'iot_hold_button': loc.iot_hold_button,
      'iot_label_double': loc.iot_label_double,
      'iot_label_string': loc.iot_label_string,
      'iot_light': loc.iot_light,
      'iot_line_chart': loc.iot_line_chart,
      'iot_menu': loc.iot_menu,
      'iot_mic': loc.iot_mic,
      'iot_scs': loc.iot_scs,
      'iot_status': loc.iot_status,
      'iot_switch_button': loc.iot_switch_button,
      'iot_volume': loc.iot_volume,
      'lightmode': loc.lightMode,
      'programming': loc.programming,
      'setting': loc.setting,
    };

    return localizedMap[formattedKey] ?? key;
  }

  static String IOT_get(BuildContext context, String key) {
    return get(context, "iot_" + key);
  }
}
