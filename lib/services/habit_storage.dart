import 'package:hive/hive.dart';
import '../models/habit.dart';

class HabitStorage {
  static final Box _box = Hive.box('habitsBox');

  static List<Habit> loadHabits() {
    _checkDailyReset();

    final List data = _box.get('habits', defaultValue: []);

    return data.map((e) {
      return Habit(
        id: e['id'],
        name: e['name'],
        streak: e['streak'],
        completedToday: e['completedToday'],
      );
    }).toList();
  }

  static void saveHabits(List<Habit> habits) {
    final List data = habits.map((h) {
      return {
        'id': h.id,
        'name': h.name,
        'streak': h.streak,
        'completedToday': h.completedToday,
      };
    }).toList();

    _box.put('habits', data);
    _box.put('lastDate', _today());
  }

  static void _checkDailyReset() {
    final String today = _today();
    final String? lastDate = _box.get('lastDate');

    if (lastDate != today) {
      final List data = _box.get('habits', defaultValue: []);

      for (var h in data) {
        h['completedToday'] = false;
      }

      _box.put('habits', data);
      _box.put('lastDate', today);
    }
  }

  static String _today() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }
}
