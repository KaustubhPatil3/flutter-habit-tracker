import 'package:flutter/material.dart';

import '../models/habit.dart';
import '../services/habit_storage.dart';

class HabitStatsDetailScreen extends StatelessWidget {
  final Habit habit;

  const HabitStatsDetailScreen({
    super.key,
    required this.habit,
  });

  static const bg = Color(0xFF0F172A);
  static const card = Color(0xFF1E293B);
  static const accent = Color(0xFF38BDF8);

  @override
  Widget build(BuildContext context) {
    final total = HabitStorage.total(habit);
    final streak = HabitStorage.streak(habit);
    final best = HabitStorage.best(habit);
    final rate = _completionRate(habit);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        title: Text(habit.name),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ================= GRID =================

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1.6,
            children: [
              _info("Completion", "${rate.toStringAsFixed(1)}%"),
              _info("Current Streak", "$streak days"),
              _info("Best Streak", "$best days"),
              _info("Total Done", "$total"),
            ],
          ),

          const SizedBox(height: 20),

          // ================= BAR =================

          _successBar(rate),
        ],
      ),
    );
  }

  // ================= UI =================

  Widget _info(String t, String v) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t,
            style: const TextStyle(color: Colors.white60),
          ),
          const Spacer(),
          Text(
            v,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _successBar(double rate) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Success Rate",
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: rate / 100,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation(accent),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "${rate.toStringAsFixed(1)}% completed",
            style: const TextStyle(color: Colors.white60),
          ),
        ],
      ),
    );
  }

  // ================= LOGIC =================

  double _completionRate(Habit h) {
    if (h.completedDates.isEmpty) return 0;

    final start = DateTime.parse(h.completedDates.first);

    final days = DateTime.now().difference(start).inDays + 1;

    return (h.completedDates.length / days) * 100;
  }
}
