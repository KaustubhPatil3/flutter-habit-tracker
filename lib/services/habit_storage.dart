import 'package:hive/hive.dart';
import '../models/habit.dart';
import 'package:flutter/material.dart';

class HabitStorage {
  static final Box box = Hive.box('habitsBox');

  /// Load habits from Hive
  static List<Habit> loadHabits() {
    final List data = box.get('habits', defaultValue: []);

    return data.map((e) {
      return Habit(
        id: e['id'] as String,
        name: e['name'] as String,
        streak: e['streak'] as int,
        completedToday: e['completedToday'] as bool,
        colorValue: e['colorValue'] as int? ??
            Colors.blue.value, // fallback for old data
      );
    }).toList();
  }

  /// Save habits to Hive
  static void saveHabits(List<Habit> habits) {
    final data = habits
        .map(
          (h) => {
            'id': h.id,
            'name': h.name,
            'streak': h.streak,
            'completedToday': h.completedToday,
            'colorValue': h.colorValue,
          },
        )
        .toList();

    box.put('habits', data);
  }
}
