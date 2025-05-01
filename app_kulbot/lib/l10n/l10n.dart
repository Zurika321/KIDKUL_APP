import 'dart:convert';

import 'package:flutter/material.dart';

class L10n {
  static final all = [const Locale('en'), const Locale('vi')];

  static String getflag(String code) {
    switch (code) {
      case 'vi':
        return '🇻🇳';
      case 'en':
        return '🇬🇧';
      default:
        return '🇻🇳';
    }
  }
}
