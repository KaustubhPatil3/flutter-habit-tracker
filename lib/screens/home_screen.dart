import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../widgets/habit_tile.dart';
import '../services/habit_storage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Habit> habits = [];

  @override
  void initState() {
    super.initState();
    habits.addAll(HabitStorage.loadHabits());
  }

  void addHabit(String name) {
    setState(() {
      habits.add(
        Habit(
          id: DateTime.now().toIso8601String(),
          name: name,
          colorValue:
              Colors.primaries[habits.length % Colors.primaries.length].value,
        ),
      );
      HabitStorage.saveHabits(habits);
    });
  }

  void toggleHabit(Habit habit) {
    setState(() {
      habit.completedToday = !habit.completedToday;
      if (habit.completedToday) {
        habit.streak += 1;
      } else {
        habit.streak = habit.streak > 0 ? habit.streak - 1 : 0;
      }
      HabitStorage.saveHabits(habits);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Habits'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => AddHabitDialog(onAdd: addHabit),
        ),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          _CalendarStrip(),
          Expanded(
            child: habits.isEmpty
                ? const Center(
                    child: Text(
                      'No habits yet.\nTap + to add one.',
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    itemCount: habits.length,
                    itemBuilder: (context, index) {
                      return HabitTile(
                        habit: habits[index],
                        onToggle: () => toggleHabit(habits[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/* ---------------- CALENDAR STRIP ---------------- */

class _CalendarStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          final date = today.subtract(Duration(days: 6 - index));
          final bool isToday = date.day == today.day &&
              date.month == today.month &&
              date.year == today.year;

          return Container(
            width: 60,
            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
            decoration: BoxDecoration(
              color: isToday
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _weekday(date),
                  style: TextStyle(
                    color: isToday ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  date.day.toString(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isToday ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _weekday(DateTime d) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[d.weekday - 1];
  }
}

/* ---------------- ADD HABIT DIALOG ---------------- */

class AddHabitDialog extends StatelessWidget {
  final Function(String) onAdd;
  final TextEditingController controller = TextEditingController();

  AddHabitDialog({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Habit'),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Habit name',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          onPressed: () {
            if (controller.text.trim().isNotEmpty) {
              onAdd(controller.text.trim());
              Navigator.pop(context);
            }
          },
          child: const Text('ADD'),
        ),
      ],
    );
  }
}
