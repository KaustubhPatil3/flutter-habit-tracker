import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/habit.dart';

class HabitDetailScreen extends StatefulWidget {
  final Habit habit;

  const HabitDetailScreen({
    super.key,
    required this.habit,
  });

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
  }

  // Build month calendar
  List<DateTime?> _buildMonthDays(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);

    final lastDay = DateTime(month.year, month.month + 1, 0);

    final daysInMonth = lastDay.day;

    final firstWeekday = firstDay.weekday; // Mon = 1

    final List<DateTime?> days = [];

    // Empty before first day
    for (int i = 1; i < firstWeekday; i++) {
      days.add(null);
    }

    // Add all days
    for (int i = 1; i <= daysInMonth; i++) {
      days.add(DateTime(month.year, month.month, i));
    }

    return days;
  }

  @override
  Widget build(BuildContext context) {
    final days = _buildMonthDays(_currentMonth);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habit.name),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ================= MONTH HEADER =================

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      _currentMonth = DateTime(
                        _currentMonth.year,
                        _currentMonth.month - 1,
                      );
                    });
                  },
                ),
                Text(
                  DateFormat('MMMM yyyy').format(_currentMonth),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      _currentMonth = DateTime(
                        _currentMonth.year,
                        _currentMonth.month + 1,
                      );
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 15),

            // ================= WEEK LABELS =================

            Row(
              children: const [
                _DayLabel("Mon"),
                _DayLabel("Tue"),
                _DayLabel("Wed"),
                _DayLabel("Thu"),
                _DayLabel("Fri"),
                _DayLabel("Sat"),
                _DayLabel("Sun"),
              ],
            ),

            const SizedBox(height: 8),

            // ================= CALENDAR =================

            Expanded(
              child: GridView.builder(
                itemCount: days.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                ),
                itemBuilder: (_, i) {
                  final date = days[i];

                  if (date == null) {
                    return const SizedBox();
                  }

                  final key = DateFormat('yyyy-MM-dd').format(date);

                  final done = widget.habit.completedDates.contains(key);

                  final isToday = _isToday(date);

                  return Container(
                    decoration: BoxDecoration(
                      color: done ? Colors.green : Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(8),
                      border: isToday
                          ? Border.all(
                              color: Colors.orange,
                              width: 2,
                            )
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        date.day.toString(),
                        style: TextStyle(
                          color: done ? Colors.white : Colors.grey.shade400,
                          fontWeight:
                              isToday ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isToday(DateTime d) {
    final now = DateTime.now();

    return d.year == now.year && d.month == now.month && d.day == now.day;
  }
}

// ================= DAY LABEL =================

class _DayLabel extends StatelessWidget {
  final String text;

  const _DayLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
