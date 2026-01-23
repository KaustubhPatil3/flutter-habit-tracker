import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/habit.dart';
import '../services/habit_storage.dart';

class TrashScreen extends StatelessWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trash"),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Habit>('habits').listenable(),
        builder: (_, box, __) {
          final trash = HabitStorage.trash();

          if (trash.isEmpty) {
            return const Center(
              child: Text("Trash is empty"),
            );
          }

          return ListView.builder(
            itemCount: trash.length,
            itemBuilder: (_, i) {
              final h = trash[i];

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: Text(h.name),
                  subtitle: Text(
                    "Completed: ${h.completedDates.length}",
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ✅ RESTORE
                      IconButton(
                        icon: const Icon(
                          Icons.restore,
                          color: Colors.green,
                        ),
                        onPressed: () async {
                          await HabitStorage.restore(h);
                        },
                      ),

                      // ❌ DELETE FOREVER
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          _confirmDelete(context, h);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, Habit h) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Forever?"),
        content: const Text("This cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              await HabitStorage.delete(h);

              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
