import 'package:hive_flutter/hive_flutter.dart';

import '../models/habit.dart';

class HabitStorage {
  static Box<Habit> get _box => Hive.box<Habit>('habits');

  // Add habit
  static Future<void> addHabit(Habit habit) async {
    await _box.add(habit);
  }

  // Update habit
  static Future<void> updateHabit(Habit habit) async {
    await habit.save();
  }

  // Move to trash
  static Future<void> archiveHabit(Habit habit) async {
    habit.isArchived = true;
    await habit.save();
  }

  // Restore
  static Future<void> restoreHabit(Habit habit) async {
    habit.isArchived = false;
    await habit.save();
  }

  // Delete forever (FIXED)
  static Future<void> deleteForever(Habit habit) async {
    await habit.delete();
  }

  // Get active habits
  static List<Habit> getActive() {
    return _box.values.where((h) => !h.isArchived).toList();
  }

  // Get trashed habits
  static List<Habit> getTrash() {
    return _box.values.where((h) => h.isArchived).toList();
  }
}
