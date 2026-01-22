import '../models/habit.dart';
import '../SERVICES/habit_storage.dart';

class AchievementService {
  /// Returns earned badges for a habit
  static List<String> getBadges(Habit habit) {
    final List<String> badges = [];

    final total = HabitStorage.total(habit);
    final streak = HabitStorage.streak(habit);
    final best = HabitStorage.best(habit);

    // Beginner
    if (total >= 1) badges.add("Starter");

    // Consistency
    if (streak >= 7) badges.add("7 Day Streak");
    if (streak >= 30) badges.add("30 Day Streak");

    // Champion
    if (best >= 15) badges.add("Champion");
    if (best >= 50) badges.add("Legend");

    // Dedication
    if (total >= 100) badges.add("Century Club");
    if (total >= 500) badges.add("Ultra Dedicated");

    return badges;
  }
}
