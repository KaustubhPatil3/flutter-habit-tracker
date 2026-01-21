import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0xFFF4F6FA),
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFFF4F6FA),
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const HabitApp());
}

/// ================= COLORS =================
class AppColors {
  static const background = Color(0xFFF4F6FA);
  static const card = Colors.white;
  static const primary = Color(0xFF5C6CFF);
  static const softBlue = Color(0xFFAEDAE6);
  static const text = Color(0xFF1E1E1E);
  static const muted = Color(0xFF7C7C80);
  static const streak = Color(0xFFFF9800);
  static const total = Color(0xFF2ECC71);
  static const time = Color(0xFF3F51B5);
}

/// ================= MODELS =================
class TimeRange {
  final TimeOfDay from;
  final TimeOfDay to;

  TimeRange(this.from, this.to);

  int get minutes {
    final start = from.hour * 60 + from.minute;
    final end = to.hour * 60 + to.minute;
    return (end - start).clamp(0, 1440);
  }
}

class Habit {
  String name;
  String emoji;
  final Map<DateTime, TimeRange> completed = {};

  Habit(this.name, this.emoji);
}

/// ================= APP =================
class HabitApp extends StatelessWidget {
  const HabitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: const HabitScreen(),
    );
  }
}

/// ================= MAIN SCREEN =================
class HabitScreen extends StatefulWidget {
  const HabitScreen({super.key});

  @override
  State<HabitScreen> createState() => _HabitScreenState();
}

class _HabitScreenState extends State<HabitScreen> {
  final List<Habit> habits = [];

  int totalDays(Habit h) => h.completed.length;

  int streak(Habit h) {
    int s = 0;
    DateTime day = DateTime.now();
    while (h.completed.keys.any((d) => _sameDay(d, day))) {
      s++;
      day = day.subtract(const Duration(days: 1));
    }
    return s;
  }

  String totalTime(Habit h) {
    final minutes =
        h.completed.values.fold<int>(0, (s, r) => s + r.minutes);
    final hrs = minutes ~/ 60;
    final mins = minutes % 60;
    if (hrs > 0) return '${hrs}h ${mins}m';
    return '${mins}m';
  }

  void addOrEditHabit({Habit? habit}) {
    final nameCtrl = TextEditingController(text: habit?.name ?? '');
    final emojiCtrl = TextEditingController(text: habit?.emoji ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(habit == null ? 'New Habit' : 'Edit Habit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emojiCtrl,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20),
              decoration: const InputDecoration(hintText: 'Emoji'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(hintText: 'Habit name'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary),
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) return;
              setState(() {
                if (habit == null) {
                  habits.add(Habit(
                    nameCtrl.text.trim(),
                    emojiCtrl.text.isEmpty
                        ? '•'
                        : emojiCtrl.text.characters.first,
                  ));
                } else {
                  habit.name = nameCtrl.text.trim();
                  habit.emoji = emojiCtrl.text.characters.first;
                }
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void openCalendar(Habit h) {
    showDialog(
      context: context,
      builder: (_) =>
          HabitCalendar(habit: h, onUpdate: () => setState(() {})),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Habits', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: const [
                Expanded(
                    flex: 5,
                    child: Text('Habit',
                        style:
                            TextStyle(fontSize: 12, color: AppColors.muted))),
                Expanded(
  flex: 2,
  child: Center(
    child: Text(
      '🔥',
      style: TextStyle(fontSize: 14),
    ),
  ),
),

Expanded(
  flex: 2,
  child: Center(
    child: Text(
      '✅',
      style: TextStyle(fontSize: 14),
    ),
  ),
),

Expanded(
  flex: 3,
  child: Center(
    child: Text(
      '⏱️',
      style: TextStyle(fontSize: 14),
    ),
  ),
),

              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: habits.length + 1,
                itemBuilder: (context, index) {
                  if (index == habits.length) {
                    return GestureDetector(
                      onTap: () => addOrEditHabit(),
                      child: Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: Text('+ Add Habit',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                    );
                  }

                  final h = habits[index];
                  return GestureDetector(
                    onTap: () => openCalendar(h),
                    onLongPress: () => addOrEditHabit(habit: h),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2)),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: Row(
                              children: [
                                Text(h.emoji,
                                    style:
                                        const TextStyle(fontSize: 16)),
                                const SizedBox(width: 8),
                                Text(h.name,
                                    style:
                                        const TextStyle(fontSize: 13)),
                              ],
                            ),
                          ),
                          Expanded(
                              flex: 2,
                              child: Center(
                                  child: Text('${streak(h)}',
                                      style: const TextStyle(
                                          color: AppColors.streak)))),
                          Expanded(
                              flex: 2,
                              child: Center(
                                  child: Text('${totalDays(h)}',
                                      style: const TextStyle(
                                          color: AppColors.total)))),
                          Expanded(
                              flex: 3,
                              child: Center(
                                  child: Text(totalTime(h),
                                      style: const TextStyle(
                                          color: AppColors.time,
                                          fontSize: 12)))),
                        ],
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
}

/// ================= CALENDAR =================
class HabitCalendar extends StatefulWidget {
  final Habit habit;
  final VoidCallback onUpdate;

  const HabitCalendar(
      {super.key, required this.habit, required this.onUpdate});

  @override
  State<HabitCalendar> createState() => _HabitCalendarState();
}

class _HabitCalendarState extends State<HabitCalendar> {
  DateTime month = DateTime.now();

  Future<void> openTimeDialog(DateTime date) async {
    TimeOfDay? from;
    TimeOfDay? to;

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            backgroundColor: AppColors.softBlue,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Time Duration',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  _timeBox(
                    label: 'Start Time',
                    value: from,
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime:
                            from ?? const TimeOfDay(hour: 8, minute: 0),
                      );
                      if (picked != null) {
                        setDialogState(() => from = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                  _timeBox(
                    label: 'End Time',
                    value: to,
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime:
                            to ?? const TimeOfDay(hour: 9, minute: 0),
                      );
                      if (picked != null) {
                        setDialogState(() => to = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(double.infinity, 44),
                    ),
                    onPressed: (from != null && to != null)
                        ? () {
                            setState(() {
                              widget.habit.completed[date] =
                                  TimeRange(from!, to!);
                              widget.onUpdate();
                            });
                            Navigator.pop(context);
                          }
                        : null,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _timeBox({
    required String label,
    required TimeOfDay? value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              value == null ? '-- : --' : value.format(context),
              style: TextStyle(
                fontSize: 16,
                color:
                    value == null ? AppColors.muted : AppColors.text,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final days = DateUtils.getDaysInMonth(month.year, month.month);
    final offset = DateTime(month.year, month.month, 1).weekday - 1;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: GridView.builder(
          shrinkWrap: true,
          itemCount: days + offset,
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
          itemBuilder: (context, index) {
            if (index < offset) return const SizedBox();
            final day = index - offset + 1;
            final date = DateTime(month.year, month.month, day);

            final done = widget.habit.completed.keys
                .any((d) => _sameDay(d, date));

            return GestureDetector(
              onTap: () async {
                if (done) {
                  setState(() {
                    widget.habit.completed
                        .removeWhere((d, _) => _sameDay(d, date));
                    widget.onUpdate();
                  });
                } else {
                  await openTimeDialog(date);
                }
              },
              child: Container(
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done
                      ? AppColors.primary
                      : Colors.grey.shade200,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        done ? Colors.white : AppColors.text,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// ================= UTILS =================
bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;