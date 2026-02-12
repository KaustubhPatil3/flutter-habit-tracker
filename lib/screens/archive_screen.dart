import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/habit.dart';
import '../services/habit_storage.dart';

class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1220),
        title: const Text("Archived Habits"),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Habit>('habits').listenable(),
        builder: (_, box, __) {
          final archived = box.values.where((h) => h.isArchived).toList();

          if (archived.isEmpty) {
            return const Center(
              child: Text(
                "No archived habits",
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: archived.length,
            itemBuilder: (_, i) {
              final h = archived[i];

              return ListTile(
                title: Text(
                  h.name,
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.restore, color: Colors.blue),
                  onPressed: () async {
                    h.isArchived = false;
                    await h.save();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
