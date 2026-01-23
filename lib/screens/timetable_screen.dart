import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  late PageController controller;
  late Box box;

  final int base = 5000;
  int current = 5000;

  DateTime selected = DateTime.now();

  /* ===== DARK THEME COLORS ===== */

  final Color primary = const Color(0xFF5C6BC0);
  final Color secondary = const Color(0xFF3949AB);

  final Color bg = const Color(0xFF121212);
  final Color card = const Color(0xFF1E1E1E);

  final Color textLight = Colors.white;
  final Color textGrey = Colors.white70;

  @override
  void initState() {
    super.initState();

    controller = PageController(initialPage: base);
    box = Hive.box('timetable');

    _applyDailyRepeat();
    _fixOldTimeFormat();
  }

  /* ================= DATE ================= */

  DateTime getDate(int i) {
    return DateTime.now().add(Duration(days: i - base));
  }

  String get key => DateFormat('yyyy-MM-dd').format(selected);

  /* ================= TASKS ================= */

  List<Map> get tasks {
    final list = List<Map>.from(box.get(key, defaultValue: []));
    list.sort((a, b) => a['from'].compareTo(b['from']));
    return list;
  }

  /* ================= TIME ================= */

  int timeToMin(TimeOfDay t) => t.hour * 60 + t.minute;

  TimeOfDay minToTime(int m) {
    return TimeOfDay(hour: m ~/ 60, minute: m % 60);
  }

  String formatMin(int m) {
    final now = DateTime.now();

    return DateFormat.jm().format(
      DateTime(now.year, now.month, now.day, m ~/ 60, m % 60),
    );
  }

  Future<TimeOfDay?> pick(TimeOfDay t) {
    return showTimePicker(
      context: context,
      initialTime: t,
      builder: (c, child) {
        return Theme(
          data: ThemeData.dark(),
          child: child!,
        );
      },
    );
  }

  /* ================= FIX OLD DATA ================= */

  void _fixOldTimeFormat() async {
    for (var k in box.keys) {
      final list = List.from(box.get(k, defaultValue: []));

      bool changed = false;

      for (var t in list) {
        if (t['from'] is String) {
          final d1 = DateFormat.jm().parse(t['from']);
          final d2 = DateFormat.jm().parse(t['to']);

          t['from'] = d1.hour * 60 + d1.minute;
          t['to'] = d2.hour * 60 + d2.minute;

          changed = true;
        }
      }

      if (changed) await box.put(k, list);
    }

    setState(() {});
  }

  /* ================= DAILY REPEAT ================= */

  void _applyDailyRepeat() async {
    final yesterday = DateFormat('yyyy-MM-dd')
        .format(DateTime.now().subtract(const Duration(days: 1)));

    final today = key;

    if (box.get(today) != null) return;

    final prev = List<Map>.from(box.get(yesterday, defaultValue: []));

    final repeatTasks = prev.where((t) => t['repeat'] == 'Daily').toList();

    if (repeatTasks.isNotEmpty) {
      await box.put(today, repeatTasks);
      setState(() {});
    }
  }

  /* ================= ADD / EDIT ================= */

  Future<void> editor({Map? old, int? i}) async {
    final ctrl = TextEditingController(text: old?['title'] ?? '');

    TimeOfDay from = old == null ? TimeOfDay.now() : minToTime(old['from']);

    TimeOfDay to = old == null
        ? from.replacing(hour: (from.hour + 1) % 24)
        : minToTime(old['to']);

    bool important = old?['important'] ?? false;
    bool done = old?['done'] ?? false;
    String repeat = old?['repeat'] ?? 'None';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            20,
            16,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: StatefulBuilder(
            builder: (c, setM) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      "Schedule Task",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textLight,
                      ),
                    ),
                    const SizedBox(height: 20),

                    /// TITLE
                    TextField(
                      controller: ctrl,
                      style: TextStyle(color: textLight),
                      decoration: InputDecoration(
                        labelText: "Task Name",
                        labelStyle: TextStyle(color: textGrey),
                        filled: true,
                        fillColor: bg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: timeBox("From", from, () async {
                            final t = await pick(from);
                            if (t != null) setM(() => from = t);
                          }),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: timeBox("To", to, () async {
                            final t = await pick(to);
                            if (t != null) setM(() => to = t);
                          }),
                        ),
                      ],
                    ),

                    SwitchListTile(
                      value: important,
                      activeColor: primary,
                      title: Text(
                        "Important",
                        style: TextStyle(color: textLight),
                      ),
                      onChanged: (v) => setM(() => important = v),
                    ),

                    SwitchListTile(
                      value: done,
                      activeColor: primary,
                      title: Text(
                        "Completed",
                        style: TextStyle(color: textLight),
                      ),
                      onChanged: (v) => setM(() => done = v),
                    ),

                    /// REPEAT
                    DropdownButtonFormField<String>(
                      value: repeat,
                      dropdownColor: card,
                      iconEnabledColor: primary,
                      style: TextStyle(color: textLight),
                      decoration: InputDecoration(
                        labelText: "Repeat",
                        labelStyle: TextStyle(color: textGrey),
                        filled: true,
                        fillColor: bg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: "None",
                          child: Text("No Repeat"),
                        ),
                        DropdownMenuItem(
                          value: "Daily",
                          child: Text("Repeat Daily"),
                        ),
                      ],
                      onChanged: (v) => setM(() => repeat = v!),
                    ),

                    const SizedBox(height: 20),

                    /// SAVE
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          padding: const EdgeInsets.all(14),
                        ),
                        onPressed: () async {
                          if (ctrl.text.trim().isEmpty) return;

                          if (timeToMin(to) <= timeToMin(from)) return;

                          final list =
                              List.from(box.get(key, defaultValue: []));

                          final task = {
                            "title": ctrl.text.trim(),
                            "from": timeToMin(from),
                            "to": timeToMin(to),
                            "important": important,
                            "done": done,
                            "repeat": repeat,
                          };

                          if (old == null) {
                            list.add(task);
                          } else {
                            list[i!] = task;
                          }

                          await box.put(key, list);

                          setState(() {});

                          Navigator.pop(context);
                        },
                        child: const Text("SAVE"),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  /* ================= DELETE ================= */

  void remove(int i) async {
    final list = List.from(box.get(key, defaultValue: []));
    list.removeAt(i);
    await box.put(key, list);
    setState(() {});
  }

  /* ================= UI ================= */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      floatingActionButton: FloatingActionButton(
        backgroundColor: primary,
        child: const Icon(Icons.add),
        onPressed: () => editor(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            header(),
            Expanded(
              child: tasks.isEmpty
                  ? Center(
                      child: Text(
                        "No Tasks Today",
                        style: TextStyle(color: textGrey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: tasks.length,
                      itemBuilder: (_, i) {
                        final t = tasks[i];

                        return taskCard(
                          t,
                          () => editor(old: t, i: i),
                          i,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /* ================= WIDGETS ================= */

  Widget header() {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [secondary, primary],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Timetable",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            DateFormat("EEE, dd MMM yyyy").format(selected),
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 85,
            child: PageView.builder(
              controller: controller,
              onPageChanged: (i) {
                setState(() {
                  current = i;
                  selected = getDate(i);
                });
              },
              itemBuilder: (_, i) {
                return dateCard(getDate(i), i == current);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget timeBox(String label, TimeOfDay t, VoidCallback tap) {
    return InkWell(
      onTap: tap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: card,
          border: Border.all(color: primary),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(color: textGrey)),
            const SizedBox(height: 4),
            Text(
              t.format(context),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget taskCard(Map t, VoidCallback edit, int i) {
    final important = t['important'] == true;
    final done = t['done'] == true;

    final repeatText = t['repeat'] == 'Daily' ? ' • Daily' : '';

    return Card(
      color: card,
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        onTap: edit,
        leading: CircleAvatar(
          backgroundColor: important ? Colors.red : primary,
          child: Icon(
            done ? Icons.check : Icons.schedule,
            color: Colors.white,
          ),
        ),
        title: Text(
          t['title'],
          style: TextStyle(
            color: textLight,
            decoration: done ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          "${formatMin(t['from'])} - ${formatMin(t['to'])}$repeatText",
          style: TextStyle(color: textGrey),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => remove(i),
        ),
      ),
    );
  }

  Widget dateCard(DateTime d, bool active) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.white24,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DateFormat('dd').format(d),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: active ? primary : Colors.white,
            ),
          ),
          Text(
            DateFormat('MMM').format(d),
            style: TextStyle(
              color: active ? primary : Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
