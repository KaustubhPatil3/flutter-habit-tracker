import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../models/habit.dart';
import '../services/habit_storage.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  static const bgColor = Color(0xFF0B1220);
  static const cardColor = Color(0xFF162235);
  static const accent = Color(0xFF4F8CFF);

  @override
  Widget build(BuildContext context) {
    final todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Reports",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Habit>('habits').listenable(),
        builder: (_, box, __) {
          final habits = box.values.where((h) => !h.isArchived).toList();

          if (habits.isEmpty) {
            return const Center(
              child: Text(
                "No data available",
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          int totalDone = 0;
          int doneToday = 0;

          for (var h in habits) {
            totalDone += HabitStorage.total(h);
            if (h.completedDates.contains(todayKey)) {
              doneToday++;
            }
          }

          final bestHabit = habits.reduce(
              (a, b) => HabitStorage.best(a) > HabitStorage.best(b) ? a : b);

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _monthlySummary(totalDone, habits.length),
              const SizedBox(height: 20),
              _todaySummary(doneToday, habits.length),
              const SizedBox(height: 20),
              _topPerformer(bestHabit),
              const SizedBox(height: 30),
              const Text(
                "Habit Breakdown",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              ...habits.map(_habitCard),
            ],
          );
        },
      ),
    );
  }

  // ================= MONTHLY =================

  Widget _monthlySummary(int done, int totalHabits) {
    final target = totalHabits * 30;
    final percent = target == 0 ? 0 : done / target;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Monthly Completion",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "$done / $target completions",
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent.clamp(0.0, 1.0) as double,
              minHeight: 10,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation(accent),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "${(percent * 100).toStringAsFixed(1)}%",
            style: const TextStyle(
              color: accent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ================= TODAY =================

  Widget _todaySummary(int doneToday, int totalHabits) {
    return _card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Today",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          Text(
            "$doneToday / $totalHabits completed",
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  // ================= TOP PERFORMER =================

  Widget _topPerformer(Habit habit) {
    final best = HabitStorage.best(habit);

    return _card(
      child: Row(
        children: [
          const Text("🏆", style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              habit.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            "Best: $best",
            style: const TextStyle(
              color: accent,
              fontWeight: FontWeight.w600,
            ),
          )
        ],
      ),
    );
  }

  // ================= HABIT CARD =================

  Widget _habitCard(Habit h) {
    final total = HabitStorage.total(h);
    final streak = HabitStorage.streak(h);
    final best = HabitStorage.best(h);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              h.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _mini("🔥 Streak", streak),
                _mini("🏆 Best", best),
                _mini("✅ Total", total),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ================= CARD BASE =================

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
      ),
      child: child,
    );
  }

  Widget _mini(String label, int value) {
    return Padding(
      padding: const EdgeInsets.only(right: 18),
      child: Text(
        "$label: $value",
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 13,
        ),
      ),
    );
  }
}
