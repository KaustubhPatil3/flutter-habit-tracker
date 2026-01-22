import '../models/habit.dart';
import 'habit_storage.dart';

class AchievementService {
  static List<String> get(Habit h) {
    final list = <String>[];

    final total = HabitStorage.total(h);
    final streak = HabitStorage.streak(h);

    if (total >= 10) list.add("Beginner 💪");
    if (total >= 50) list.add("Consistent 🔥");
    if (total >= 100) list.add("Master 🏆");

    if (streak >= 7) list.add("7 Day Streak ⚡");
    if (streak >= 30) list.add("30 Day Legend 👑");

    return list;
  }
}
