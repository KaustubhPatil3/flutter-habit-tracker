import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/habit.dart';
import '../services/habit_storage.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const HabitCard({
    super.key,
    required this.habit,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final doneToday = habit.completedDates.contains(today);

    // ✅ FIX: use HabitStorage
    final total = HabitStorage.total(habit);
    final streak = HabitStorage.streak(habit);

    final progress = total == 0 ? 0.0 : habit.completedDates.length / total;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [
              Colors.grey.shade900,
              Colors.grey.shade800,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= TOP ROW =================

            Row(
              children: [
                // CHECK BUTTON
                InkWell(
                  borderRadius: BorderRadius.circular(50),
                  onTap: () async {
                    final today =
                        DateFormat('yyyy-MM-dd').format(DateTime.now());

                    if (habit.completedDates.contains(today)) {
                      habit.completedDates.remove(today);
                    } else {
                      habit.completedDates.add(today);
                    }

                    await habit.save();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: doneToday ? Colors.green : Colors.grey.shade700,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      color: doneToday ? Colors.white : Colors.grey.shade400,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // TITLE
                Expanded(
                  child: Text(
                    habit.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // MENU
                PopupMenuButton(
                  icon: const Icon(
                    Icons.more_vert,
                    color: Colors.white70,
                  ),
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 0,
                      child: Text("Edit"),
                    ),
                    PopupMenuItem(
                      value: 1,
                      child: Text("Delete"),
                    ),
                  ],
                  onSelected: (v) {
                    if (v == 0) onEdit();
                    if (v == 1) onDelete();
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ================= STATS =================

            Row(
              children: [
                _Stat(
                  icon: "🔥",
                  label: "Streak",
                  value: streak.toString(), // ✅ FIXED
                ),
                const SizedBox(width: 20),
                _Stat(
                  icon: "✅",
                  label: "Done",
                  value: habit.completedDates.length.toString(),
                ),
                const Spacer(),
                if (doneToday)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Today ✓",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 10),

            // ================= PROGRESS =================

            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 7,
                backgroundColor: Colors.grey.shade700,
                valueColor: const AlwaysStoppedAnimation(Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= STAT WIDGET =================

class _Stat extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _Stat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade400,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
