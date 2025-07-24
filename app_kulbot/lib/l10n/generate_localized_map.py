import json
import os

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
ARB_FILE = os.path.join(BASE_DIR, 'app_en.arb')
OUTPUT_FILE = os.path.join(BASE_DIR, 'localized_map.dart')

# //////////////////////////////////////////////
# File này dùng để tạo hoặc cập nhật class LocalizedStringGetter với tất cả key mới nhất từ file app_en.arb
# Lưu ý khi chạy: đảm bảo dòng thứ 2 từ dưới đếm lên của app_en.arb không được có dấu phẩy "," ( quy tắc json chứ hỏi thì i dont know :)) )
# Create By: Kha (tts)
# //////////////////////////////////////////////

def format_key(key: str) -> str:
    return key.lower().replace('.', '_').replace(' ', '')

def generate_dart_map(keys):
    lines = [
        '  static String get(BuildContext context, String key) {',
        '    final loc = AppLocalizations.of(context)!;',
        '    final formattedKey = formatKey(key);',
        '',
        '    final Map<String, String> localizedMap = {'
    ]

    for key in keys:
        dart_key = format_key(key)
        lines.append(f'      \'{dart_key}\': loc.{key},')

    lines += [
        '    };',
        '',
        '    return localizedMap[formattedKey] ?? key;',
        '  }\n'
    ]

    return '\n'.join(lines)

def generate_class_code(keys):
    class_code = f'''
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LocalizedStringGetter {{
  static String formatKey(String input) {{
    return input.toLowerCase().replaceAll(' ', '_');
  }}

{generate_dart_map(keys)}
  static String IOT_get(BuildContext context, String key) {{
    String newKey = get(context, "iot_" + key);
    return newKey == "iot_" + key ? key : newKey;
  }}
  static String Control_get(BuildContext context, String key) {{
    String newKey = get(context, "control_" + key);
    return newKey == "control_" + key ? key : newKey;
  }}
  static String showkey_get(BuildContext context, String key) {{
    String newKey = get(context, "sk_" + key);
    return newKey == "sk_" + key ? key : newKey;
  }}
}}
'''.strip()
    return class_code

def main():
    if not os.path.exists(ARB_FILE):
        print(f'❌ File không tồn tại: {ARB_FILE}')
        return

    with open(ARB_FILE, 'r', encoding='utf-8') as f:
        data = json.load(f)

    keys = [k for k in data.keys() if not k.startswith('@')]  # Bỏ các metadata keys
    keys.sort()

    output_code = generate_class_code(keys)

    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        f.write(output_code)

    print(f'✅ Đã tạo file: {OUTPUT_FILE} với {len(keys)} khóa.')

if __name__ == '__main__':
    main()
