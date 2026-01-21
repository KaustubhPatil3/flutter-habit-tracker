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
          id: DateTime.now().toString(),
          name: name,
        ),
      );
      HabitStorage.saveHabits(habits);
    });
  }

  void toggleHabit(Habit habit) {
    setState(() {
      habit.completedToday = !habit.completedToday;
      habit.streak += habit.completedToday ? 1 : -1;
      if (habit.streak < 0) habit.streak = 0;

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
          ? const Center(child: Text('No habits yet'))
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
        decoration: const InputDecoration(
          hintText: 'Habit name',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (controller.text.isNotEmpty) {
              onAdd(controller.text);
              Navigator.pop(context);
            }
          },
          child: const Text('ADD'),
        ),
      ],
    );
  }
}
