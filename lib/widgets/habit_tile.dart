import 'package:flutter/material.dart';

import '../models/habit.dart';
import '../services/habit_storage.dart';

class HabitTile extends StatelessWidget {
  final Habit habit;

  const HabitTile({
    super.key,
    required this.habit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      child: ListTile(
        title: Text(
          habit.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () {
            HabitStorage.archiveHabit(habit);
          },
        ),
      ),
    );
  }
}
