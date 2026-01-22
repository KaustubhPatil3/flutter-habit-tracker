import 'package:hive_flutter/hive_flutter.dart';

class ThemeService {
  static late Box box;

  static Future init() async {
    box = await Hive.openBox('theme');
  }

  static bool isDark() {
    return box.get('dark', defaultValue: true);
  }

  static void toggle() {
    box.put('dark', !isDark());
  }
}
