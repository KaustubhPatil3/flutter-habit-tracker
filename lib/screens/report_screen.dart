import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/habit.dart';
import '../services/habit_storage.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reports"),
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Habit>('habits').listenable(),
        builder: (_, box, __) {
          final habits = box.values.toList();

          if (habits.isEmpty) {
            return const Center(
              child: Text("No data available"),
            );
          }

          int totalDone = 0;
          int totalTarget = habits.length * 30;

          for (var h in habits) {
            totalDone += HabitStorage.total(h);
          }

          double percent = totalTarget == 0 ? 0 : totalDone / totalTarget;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // ================= SUMMARY CARD =================
              _summaryCard(totalDone, totalTarget, percent),

              const SizedBox(height: 20),

              // ================= HABITS =================
              const Text(
                "Habit Performance",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              ...habits.map((h) => _habitCard(h)).toList(),
            ],
          );
        },
      ),
    );
  }

  // ===================================================
  // SUMMARY CARD
  // ===================================================

  Widget _summaryCard(int done, int target, double percent) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Monthly Summary",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              "$done / $target Completed",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: percent.clamp(0, 1),
              minHeight: 10,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 10),
            Text(
              "${(percent * 100).toStringAsFixed(1)} %",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================================================
  // HABIT CARD
  // ===================================================

  Widget _habitCard(Habit h) {
    final total = HabitStorage.total(h);
    final streak = HabitStorage.streak(h);
    final best = HabitStorage.best(h);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        title: Text(
          h.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _mini("🔥", streak),
              _mini("🏆", best),
              _mini("✅", total),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Widget _mini(String icon, int value) {
    return Row(
      children: [
        Text(icon),
        const SizedBox(width: 4),
        Text(value.toString()),
      ],
    );
  }
}
