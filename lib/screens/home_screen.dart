import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/habit.dart';
import '../widgets/habit_tile.dart';
import '../widgets/habit_sheet.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Habit>('habits');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habits'),
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<Habit> box, _) {
          final habits = box.values.where((h) => !h.isArchived).toList();

          if (habits.isEmpty) {
            return const Center(
              child: Text('No habits yet'),
            );
          }

          return ListView.builder(
            itemCount: habits.length,
            itemBuilder: (context, i) {
              return HabitTile(habit: habits[i]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => const AddHabitSheet(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
