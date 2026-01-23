import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/habit.dart';
import '../services/achievement_service.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Habit>('habits');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Achievements"),
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<Habit> box, _) {
          final habits = box.values.toList();

          // No habits case
          if (habits.isEmpty) {
            return const Center(
              child: Text(
                "No habits yet 😴\nStart tracking to earn achievements!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final habit = habits[index];

              final badges = AchievementService.getBadges(habit);

              return Card(
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Habit Name
                      Text(
                        habit.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // No achievements
                      if (badges.isEmpty)
                        const Text(
                          "No achievements yet",
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),

                      // Show badges
                      if (badges.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: badges.map((badge) {
                            return Chip(
                              label: Text(badge),
                              avatar: const Icon(
                                Icons.emoji_events,
                                size: 18,
                              ),
                            );
                          }).toList(),
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
}
