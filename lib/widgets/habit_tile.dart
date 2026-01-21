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
    return ListTile(
      leading: Checkbox(
        value: habit.completedToday,
        onChanged: (_) => onToggle(),
      ),
      title: Text(habit.name),
      subtitle: Text('Streak: ${habit.streak} 🔥'),
    );
  }
}
