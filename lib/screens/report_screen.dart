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
              child: Text("No data"),
            );
          }

          int totalDone = 0;

          for (var h in habits) {
            totalDone += HabitStorage.total(h);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _summary(totalDone, habits.length),
              const SizedBox(height: 20),
              const Text(
                "Habit Performance",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...habits.map(_habitCard),
            ],
          );
        },
      ),
    );
  }

  // SUMMARY
  Widget _summary(int done, int totalHabits) {
    final target = totalHabits * 30;

    final percent = target == 0 ? 0 : done / target;

    return Card(
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
            const SizedBox(height: 10),
            Text("$done / $target Completed"),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: percent.clamp(0.0, 1.0).toDouble(),
              minHeight: 10,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 10),
            Text("${(percent * 100).toStringAsFixed(1)}%"),
          ],
        ),
      ),
    );
  }

  // HABIT CARD
  Widget _habitCard(Habit h) {
    final total = HabitStorage.total(h);
    final streak = HabitStorage.streak(h);
    final best = HabitStorage.best(h);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(h.name),
        subtitle: Row(
          children: [
            _mini("🔥", streak),
            _mini("🏆", best),
            _mini("✅", total),
          ],
        ),
      ),
    );
  }

  Widget _mini(String icon, int v) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Row(
        children: [
          Text(icon),
          const SizedBox(width: 4),
          Text(v.toString()),
        ],
      ),
    );
  }
}
