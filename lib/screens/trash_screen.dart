import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/habit.dart';
import '../services/habit_storage.dart';

class TrashScreen extends StatelessWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Habit>('habits');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trash'),
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<Habit> box, _) {
          final habits = HabitStorage.getTrash();

          if (habits.isEmpty) {
            return const Center(
              child: Text('Trash is empty'),
            );
          }

          return ListView.builder(
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final habit = habits[index];

              return ListTile(
                title: Text(habit.name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.restore),
                      onPressed: () {
                        HabitStorage.restoreHabit(habit);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        HabitStorage.deleteForever(habit);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
