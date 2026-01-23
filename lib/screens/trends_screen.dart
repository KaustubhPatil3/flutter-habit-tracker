import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/habit.dart';

class TrendsScreen extends StatelessWidget {
  const TrendsScreen({super.key});

  Map<String, int> _dailyCount(List<Habit> habits) {
    final map = <String, int>{};

    for (var h in habits) {
      for (var d in h.completedDates) {
        final key = d.substring(0, 10);
        map[key] = (map[key] ?? 0) + 1;
      }
    }

    return map;
  }

  Color _color(int count) {
    if (count == 0) return Colors.grey.shade300;
    if (count == 1) return Colors.green.shade200;
    if (count == 2) return Colors.green.shade400;
    if (count <= 4) return Colors.green.shade600;
    return Colors.green.shade800;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trends"),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Habit>('habits').listenable(),
        builder: (_, box, __) {
          // ✅ FILTER ARCHIVED
          final habits = box.values.where((h) => !h.isArchived).toList();

          final map = _dailyCount(habits);

          final today = DateTime.now();
          final start = today.subtract(const Duration(days: 140));

          final days = List.generate(
            140,
            (i) => start.add(Duration(days: i)),
          );

          final total = map.values.fold(0, (a, b) => a + b);

          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Last 5 Months",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Total: $total",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _legend(0),
                    _legend(1),
                    _legend(2),
                    _legend(3),
                    _legend(5),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: GridView.builder(
                    itemCount: days.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemBuilder: (_, i) {
                      final d = days[i];

                      final key = d.toIso8601String().substring(0, 10);

                      final count = map[key] ?? 0;

                      return Tooltip(
                        message: "$key → $count habits",
                        child: Container(
                          decoration: BoxDecoration(
                            color: _color(count),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _legend(int count) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: _color(count),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
