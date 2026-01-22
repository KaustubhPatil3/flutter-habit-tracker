import 'package:flutter/material.dart';

import '../models/habit.dart';
import '../services/habit_storage.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;

  const HabitCard({
    super.key,
    required this.habit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Habit name
            Expanded(
              child: Text(
                habit.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Delete → Move to Trash
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                HabitStorage.archiveHabit(habit);
              },
            ),
          ],
        ),
      ),
    );
  }
}
