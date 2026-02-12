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

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 8,
      ),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF4F8CFF).withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.track_changes,
              color: Color(0xFF4F8CFF),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Completed $total times",
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: Colors.white38,
          )
        ],
      ),
    );
  }
}
