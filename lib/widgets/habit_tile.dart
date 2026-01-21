import 'package:flutter/material.dart';
import '../models/habit.dart';

class HabitTile extends StatelessWidget {
  final Habit habit;
  final VoidCallback onToggle;

  const HabitTile({
    super.key,
    required this.habit,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Checkbox(
              value: habit.completedToday,
              onChanged: (_) => onToggle(),
            ),
            Expanded(
              child: Text(
                habit.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Text(
              '${habit.streak} 🔥',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
