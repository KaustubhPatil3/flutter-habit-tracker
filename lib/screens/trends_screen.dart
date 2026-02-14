import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/habit.dart';

class TrendsScreen extends StatelessWidget {
  const TrendsScreen({super.key});

  static const bgColor = Color(0xFF0F172A);
  static const cardColor = Color(0xFF1E293B);

  Map<String, int> _dailyCount(List<Habit> habits) {
    final map = <String, int>{};
    for (var h in habits) {
      for (var d in h.completedDates) {
        map[d] = (map[d] ?? 0) + 1;
      }
    }
    return map;
  }

  Color _heatColor(int count) {
    if (count == 0) return Colors.white10;
    if (count == 1) return Colors.lightBlueAccent.withOpacity(0.3);
    if (count == 2) return Colors.lightBlueAccent.withOpacity(0.5);
    if (count <= 4) return Colors.lightBlueAccent.withOpacity(0.7);
    return Colors.lightBlueAccent;
  }

  int _calculateCurrentStreak(Map<String, int> map) {
    int streak = 0;
    DateTime day = DateTime.now();

    while (true) {
      final key = day.toIso8601String().substring(0, 10);
      if ((map[key] ?? 0) > 0) {
        streak++;
        day = day.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  int _calculateLongestStreak(Map<String, int> map) {
    final dates = map.keys.toList()..sort();
    int longest = 0;
    int current = 0;

    for (int i = 0; i < dates.length; i++) {
      if (map[dates[i]]! > 0) {
        current++;
        longest = current > longest ? current : longest;
      } else {
        current = 0;
      }
    }
    return longest;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        title: const Text("Trends", style: TextStyle(color: Colors.white)),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Habit>('habits').listenable(),
        builder: (_, box, __) {
          final habits = box.values.where((h) => !h.isArchived).toList();
          final map = _dailyCount(habits);

          final today = DateTime.now();
          final start = today.subtract(const Duration(days: 140));

          final days = List.generate(140, (i) => start.add(Duration(days: i)));

          final total = map.values.fold(0, (a, b) => a + b);

          final bestDay = map.values.isEmpty
              ? 0
              : map.values.reduce((a, b) => a > b ? a : b);

          final avg = days.isEmpty ? 0 : (total / days.length);

          final currentStreak = _calculateCurrentStreak(map);

          final longestStreak = _calculateLongestStreak(map);

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== SUMMARY CARDS =====

                Row(
                  children: [
                    _summaryCard("Total", total.toString()),
                    const SizedBox(width: 12),
                    _summaryCard("Current", "$currentStreak 🔥"),
                    const SizedBox(width: 12),
                    _summaryCard("Longest", "$longestStreak ⭐"),
                  ],
                ),

                const SizedBox(height: 28),

                const Text(
                  "Activity Heatmap",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),

                const SizedBox(height: 6),

                const Text(
                  "Mon → Sun (like calendar)",
                  style: TextStyle(color: Colors.white70),
                ),

                const SizedBox(height: 20),

                // ===== WEEKDAY LABELS =====

                Row(
                  children: const [
                    SizedBox(width: 28),
                    Expanded(
                        child: Text("Mon",
                            style: TextStyle(color: Colors.white54))),
                    Expanded(
                        child: Text("Tue",
                            style: TextStyle(color: Colors.white54))),
                    Expanded(
                        child: Text("Wed",
                            style: TextStyle(color: Colors.white54))),
                    Expanded(
                        child: Text("Thur",
                            style: TextStyle(color: Colors.white54))),
                    Expanded(
                        child: Text("Fri",
                            style: TextStyle(color: Colors.white54))),
                    Expanded(
                        child: Text("Sat",
                            style: TextStyle(color: Colors.white54))),
                    Expanded(
                        child: Text("Sun",
                            style: TextStyle(color: Colors.white54))),
                  ],
                ),

                const SizedBox(height: 8),

                // ===== HEATMAP =====

                Expanded(
                  child: GridView.builder(
                    itemCount: days.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 6,
                    ),
                    itemBuilder: (_, i) {
                      final d = days[i];
                      final key = d.toIso8601String().substring(0, 10);
                      final count = map[key] ?? 0;

                      final isToday = key ==
                          DateTime.now().toIso8601String().substring(0, 10);

                      return Tooltip(
                        message: "$key → $count completions",
                        child: Container(
                          decoration: BoxDecoration(
                            color: _heatColor(count),
                            borderRadius: BorderRadius.circular(6),
                            border: isToday
                                ? Border.all(color: Colors.white, width: 1.5)
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // ===== LEGEND =====

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Less", style: TextStyle(color: Colors.white70)),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: _heatColor(i),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const Text("More", style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _summaryCard(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
