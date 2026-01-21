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
        habit.streak -= 1;
        if (habit.streak < 0) habit.streak = 0;
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
      body: habits.isEmpty
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
    );
  }
}

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
          hintText: 'Enter habit name',
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
