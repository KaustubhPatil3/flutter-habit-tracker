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
    final total = HabitStorage.total(habit);

    return ListTile(
      leading: const Icon(Icons.track_changes),
      title: Text(habit.name),
      subtitle: Text("Completed: $total"),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
