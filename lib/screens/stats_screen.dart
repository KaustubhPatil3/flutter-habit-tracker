import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/habit.dart';
import 'habit_stats_detail_screen.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  static const bgColor = Color(0xFF0F172A);
  static const cardColor = Color(0xFF1E293B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: const Text(
          "Statistics",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),

      // ================= DATA =================

      body: ValueListenableBuilder(
        valueListenable: Hive.box<Habit>('habits').listenable(),
        builder: (_, box, __) {
          final habits = box.values.toList();

          if (habits.isEmpty) {
            return const Center(
              child: Text(
                "No habits found",
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          // ================= GRID =================

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 per row
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1,
            ),
            itemCount: habits.length,
            itemBuilder: (context, i) {
              final h = habits[i];

              return _HabitTile(
                habit: h,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HabitStatsDetailScreen(habit: h),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// ================= TILE =================

class _HabitTile extends StatelessWidget {
  final Habit habit;
  final VoidCallback onTap;

  const _HabitTile({
    required this.habit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: StatsScreen.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bar_chart,
                color: Colors.lightBlue,
                size: 28,
              ),
            ),

            const SizedBox(height: 12),

            // Name
            Text(
              habit.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 6),

            // Count
            Text(
              "${habit.completedDates.length} done",
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
