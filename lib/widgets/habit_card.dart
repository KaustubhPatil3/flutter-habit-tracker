import 'package:flutter/material.dart';
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
    final doneToday = HabitStorage.isDoneToday(habit);
    final streak = HabitStorage.streak(habit);
    final total = HabitStorage.total(habit);
    final progress = HabitStorage.consistencyRate(habit);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFF162235),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 25,
              offset: const Offset(0, 15),
            ),
          ],
          border: Border.all(
            color: doneToday
                ? const Color(0xFF4F8CFF).withOpacity(0.4)
                : Colors.white.withOpacity(0.04),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= TOP ROW =================
            Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    await HabitStorage.toggleToday(habit);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: doneToday
                          ? const LinearGradient(
                              colors: [
                                Color(0xFF4F8CFF),
                                Color(0xFF6C63FF),
                              ],
                            )
                          : null,
                      color: doneToday ? null : Colors.white.withOpacity(0.06),
                    ),
                    child: Icon(
                      doneToday ? Icons.check : Icons.circle_outlined,
                      color: doneToday ? Colors.white : Colors.white54,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    habit.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white54),
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 0, child: Text("Edit")),
                    PopupMenuItem(value: 1, child: Text("Archive")),
                  ],
                  onSelected: (v) {
                    if (v == 0) onEdit();
                    if (v == 1) onDelete();
                  },
                ),
              ],
            ),

            const SizedBox(height: 18),

            // ================= STATS =================
            Row(
              children: [
                _stat("🔥", "Streak", streak.toString()),
                const SizedBox(width: 20),
                _stat("✅", "Done", total.toString()),
                const Spacer(),
                if (doneToday)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      "Today ✓",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // ================= PROGRESS =================
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.white.withOpacity(0.05),
                valueColor: const AlwaysStoppedAnimation(Color(0xFF4F8CFF)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String icon, String label, String value) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 11,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
