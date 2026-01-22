import 'package:flutter/material.dart';

import '../models/habit.dart';
import '../services/habit_storage.dart';

class HabitCheckbox extends StatelessWidget {
  final Habit habit;
  final String date;

  const HabitCheckbox({
    super.key,
    required this.habit,
    required this.date,
  });

  bool get _isDone {
    return habit.completedDates.contains(date);
  }

  void _toggle() {
    if (_isDone) {
      habit.completedDates.remove(date);
    } else {
      habit.completedDates.add(date);
    }

    HabitStorage.updateHabit(habit);
  }

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: _isDone,
      onChanged: (_) => _toggle(),
    );
  }
}
