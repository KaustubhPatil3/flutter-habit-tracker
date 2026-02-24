import 'dart:math';
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

  // ================= LAST 7 DAYS =================
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

  int _thisMonthTotal(List<Habit> habits) {
    final now = DateTime.now();
    int total = 0;

    for (var h in habits) {
      for (var d in h.completedDates) {
        final date = DateTime.parse(d);
        if (date.month == now.month && date.year == now.year) {
          total++;
        }
      }
    }
    return total;
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

          int doneToday = 0;
          int totalDone = 0;

          for (var h in habits) {
            totalDone += HabitStorage.total(h);
            if (h.completedDates.contains(todayKey)) {
              doneToday++;
            }
          }

          final weekly = _last7DaysTotals(habits);
          final weeklyValues = weekly.values.toList();
          final monthTotal = _thisMonthTotal(habits);

          final double percent =
              habits.isEmpty ? 0.0 : doneToday / habits.length;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // ================= TODAY SUMMARY =================
              _card(
                child: Column(
                  children: [
                    const Text(
                      "Today's Performance",
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 20),

                    // Custom Modern Ring
                    SizedBox(
                      height: 170,
                      width: 170,
                      child: CustomPaint(
                        painter: _RingPainter(percent),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "${(percent * 100).toInt()}%",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "$doneToday / ${habits.length}",
                                style: const TextStyle(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // ================= WEEKLY BAR CHART =================
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
                      height: 190,
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
                                  final today = DateTime.now();
                                  final date = today.subtract(
                                      Duration(days: 6 - value.toInt()));
                                  final label = DateFormat.E().format(date);

                                  return Text(
                                    label.substring(0, 1),
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
                                  width: 16,
                                  color: accent,
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

              const SizedBox(height: 25),

              // ================= STATS ROW =================
              Row(
                children: [
                  Expanded(
                    child: _statTile("This Month", monthTotal.toString()),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _statTile("All Time", totalDone.toString()),
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _statTile(String title, String value) {
    return _card(
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 10),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ================= CUSTOM RING PAINTER =================
class _RingPainter extends CustomPainter {
  final double percent;

  _RingPainter(this.percent);

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = 14.0;
    final radius = (size.width / 2) - stroke;

    final center = Offset(size.width / 2, size.height / 2);

    final backgroundPaint = Paint()
      ..color = Colors.white12
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;

    final progressPaint = Paint()
      ..color = ReportScreen.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    final sweep = 2 * pi * percent;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweep,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
