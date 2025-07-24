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
      'control_jt': loc.control_jt,
      'control_jt360': loc.control_jt360,
      'control_jth': loc.control_jth,
      'control_jtv': loc.control_jtv,
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
      'sk_editmode': loc.sk_EditMode,
      'sk_huongdan': loc.sk_Huongdan,
      'sk_saveprojectiot': loc.sk_SaveProjectIOT,
      'sk_tonglebluetooth': loc.sk_TongLeBluetooth,
      'sk_button': loc.sk_button,
      'sk_chart': loc.sk_chart,
      'sk_hold_button': loc.sk_hold_button,
      'sk_jt360': loc.sk_jt360,
      'sk_jth': loc.sk_jth,
      'sk_jtv': loc.sk_jtv,
      'sk_label_double': loc.sk_label_double,
      'sk_label_string': loc.sk_label_string,
      'sk_light': loc.sk_light,
      'sk_listbox': loc.sk_listbox,
      'sk_listbox_tester': loc.sk_listbox_tester,
      'sk_mic': loc.sk_mic,
      'sk_scs': loc.sk_scs,
      'sk_switch_button': loc.sk_switch_button,
      'sk_volume': loc.sk_volume,
    };

    return localizedMap[formattedKey] ?? key;
  }

  static String IOT_get(BuildContext context, String key) {
    String newKey = get(context, "iot_" + key);
    return newKey == "iot_" + key ? key : newKey;
  }
  static String Control_get(BuildContext context, String key) {
    String newKey = get(context, "control_" + key);
    return newKey == "control_" + key ? key : newKey;
  }
  static String showkey_get(BuildContext context, String key) {
    String newKey = get(context, "sk_" + key);
    return newKey == "sk_" + key ? key : newKey;
  }
}