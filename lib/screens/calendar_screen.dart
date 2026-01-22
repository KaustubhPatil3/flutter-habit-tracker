import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/habit.dart';

class CalendarScreen extends StatefulWidget {
  final List<Habit> habits;

  const CalendarScreen({
    super.key,
    required this.habits,
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime selectedDay = DateTime.now();

  static const bg = Color(0xFF0F172A);
  static const card = Color(0xFF1E293B);
  static const accent = Color(0xFF38BDF8);
  static const success = Color(0xFF22C55E);

  // ================= MONTH =================

  List<DateTime> _getDays() {
    final first = DateTime(selectedDay.year, selectedDay.month, 1);

    final total = DateTime(selectedDay.year, selectedDay.month + 1, 0).day;

    return List.generate(
      total,
      (i) => first.add(Duration(days: i)),
    );
  }

  // ================= DATA =================

  List<Habit> _doneOn(DateTime date) {
    final key = DateFormat('yyyy-MM-dd').format(date);

    return widget.habits.where((h) => h.completedDates.contains(key)).toList();
  }

  double _progress(DateTime date) {
    if (widget.habits.isEmpty) return 0;

    return _doneOn(date).length / widget.habits.length;
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    final days = _getDays();

    final done = _doneOn(selectedDay);

    final progress = _progress(selectedDay);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        title: const Text("Calendar"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _monthBar(),
            const SizedBox(height: 16),
            _calendar(days),
            const SizedBox(height: 24),
            _summary(done, progress),
            const SizedBox(height: 24),
            _habitList(done),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ================= MONTH BAR =================

  Widget _monthBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              selectedDay = DateTime(
                selectedDay.year,
                selectedDay.month - 1,
                1,
              );
            });
          },
          icon: const Icon(Icons.chevron_left),
          color: Colors.white,
        ),
        Text(
          DateFormat('MMMM yyyy').format(selectedDay),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              selectedDay = DateTime(
                selectedDay.year,
                selectedDay.month + 1,
                1,
              );
            });
          },
          icon: const Icon(Icons.chevron_right),
          color: Colors.white,
        ),
      ],
    );
  }

  // ================= CALENDAR =================

  Widget _calendar(List<DateTime> days) {
    final today = DateTime.now();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: days.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemBuilder: (_, i) {
        final d = days[i];

        final isToday = _same(d, today);
        final isSelected = _same(d, selectedDay);

        final count = _doneOn(d).length;

        return GestureDetector(
          onTap: () => setState(() => selectedDay = d),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? accent : card,
              borderRadius: BorderRadius.circular(14),
              border: isToday
                  ? Border.all(
                      color: accent,
                      width: 2,
                    )
                  : null,
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    d.day.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isSelected ? bg : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ================= SUMMARY =================

  Widget _summary(List<Habit> done, double progress) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black45,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('EEE, dd MMM yyyy').format(selectedDay),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: progress,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation(success),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "${done.length}/${widget.habits.length} habits done",
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  // ================= LIST =================

  Widget _habitList(List<Habit> done) {
    if (done.isEmpty) {
      return _empty();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Completed",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        ...done.map(
          (h) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.check_circle,
                color: success,
              ),
              title: Text(
                h.name,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ================= EMPTY =================

  Widget _empty() {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        children: const [
          Icon(
            Icons.event_busy,
            size: 48,
            color: Colors.white38,
          ),
          SizedBox(height: 12),
          Text(
            "No habits completed",
            style: TextStyle(
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  // ================= UTILS =================

  bool _same(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
