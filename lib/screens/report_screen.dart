import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/habit.dart';
import '../services/habit_storage.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  static const bgColor = Color(0xFF0B1220);
  static const cardColor = Color(0xFF162235);
  static const accent = Color(0xFF4F8CFF);

  Map<String, int> _last7DaysTotals(List<Habit> habits) {
    final map = <String, int>{};
    final today = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final key = DateFormat('yyyy-MM-dd').format(date);

      int count = 0;
      for (var h in habits) {
        if (h.completedDates.contains(key)) {
          count++;
        }
      }

      map[key] = count;
    }

    return map;
  }

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

          final weeklyData = _last7DaysTotals(habits);
          final weeklyValues = weeklyData.values.toList();

          final sortedHabits = [...habits]..sort(
              (a, b) => HabitStorage.total(b).compareTo(HabitStorage.total(a)));

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // ===== TODAY SUMMARY =====
              _card(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Today",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      "$doneToday / ${habits.length} completed",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ===== WEEKLY BAR CHART =====
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Last 7 Days",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 180,
                      child: BarChart(
                        BarChartData(
                          gridData: FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  const labels = [
                                    "M",
                                    "T",
                                    "W",
                                    "T",
                                    "F",
                                    "S",
                                    "S"
                                  ];
                                  return Text(
                                    labels[value.toInt()],
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          barGroups: List.generate(
                            weeklyValues.length,
                            (i) => BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(
                                  toY: weeklyValues[i].toDouble(),
                                  color: accent,
                                  width: 18,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ===== HABIT RANKING =====
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Habit Ranking",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    ...sortedHabits.take(5).map((h) {
                      final total = HabitStorage.total(h);

                      final max = sortedHabits
                          .map((e) => HabitStorage.total(e))
                          .reduce((a, b) => a > b ? a : b);

                      final double percent = max == 0 ? 0.0 : total / max;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              h.name,
                              style: const TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 6),
                            LinearProgressIndicator(
                              value: percent,
                              backgroundColor: Colors.white12,
                              valueColor: const AlwaysStoppedAnimation(accent),
                              minHeight: 8,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          );
        },
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }
}
