import 'package:hive/hive.dart';
import '../models/habit.dart';

class HabitStorage {
  static final Box _box = Hive.box('habitsBox');

  static List<Habit> loadHabits() {
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
  }
}
