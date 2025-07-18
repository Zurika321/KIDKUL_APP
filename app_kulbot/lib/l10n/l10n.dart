import 'package:flutter/material.dart';

class L10n {
  static final all = [
    const Locale('en'),
    const Locale('vi'),
    const Locale('ja'),
  ];

  static String getflag(String code) {
    switch (code) {
      case 'vi':
        return '🇻🇳';
      case 'en':
        return '🇬🇧';
      case 'ja':
        return '🇯🇵';
      default:
        return '🇻🇳';
    }
  }
}
