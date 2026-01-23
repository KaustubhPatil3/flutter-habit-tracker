import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/habit.dart';
import '../services/achievement_service.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Habit>('habits');
    final habits = box.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Achievements"),
      ),
      body: habits.isEmpty
          ? const Center(
              child: Text("No habits yet"),
            )
          : ListView.builder(
              itemCount: habits.length,
              itemBuilder: (context, index) {
                final habit = habits[index];
                final badges = AchievementService.getBadges(habit);

                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(habit.name),
                    subtitle: badges.isEmpty
                        ? const Text("No badges yet")
                        : Wrap(
                            spacing: 6,
                            children: badges
                                .map(
                                  (b) => Chip(
                                    label: Text(b),
                                  ),
                                )
                                .toList(),
                          ),
                  ),
                );
              },
            ),
    );
  }
}
