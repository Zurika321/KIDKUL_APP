class ControlValueManager {
  static final Map<String, dynamic> values = {};

  static dynamic getValue(String id) => values[id];

  static void setValue(String id, dynamic newValue) => values[id] = newValue;

  static bool hasValue(String id) => values.containsKey(id);

  static void clearAll() {
    values.clear();
  }

  static void printAllKeys() {
    if (values.isEmpty) {
      print('ControlValueManager: Không có key nào trong values.');
    } else {
      print('ControlValueManager: Danh sách tất cả key:');
      for (var key in values.keys) {
        print(' - $key');
      }
    }
  }

  static void removeValuesForRealId(String realId) {
    values.removeWhere((key, _) => key.startsWith('$realId\_'));
  }
}
