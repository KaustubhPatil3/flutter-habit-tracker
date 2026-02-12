import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/habit.dart';
import '../services/habit_storage.dart';
import '../widgets/habit_card.dart';
import '../widgets/habit_sheet.dart';
import 'habit_detail_screen.dart';
import 'archive_screen.dart';

enum FilterType { all, completed, pending }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FilterType _filter = FilterType.all;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1220),
        elevation: 0,
      ),
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: Hive.box<Habit>('habits').listenable(),
          builder: (_, box, __) {
            final habits = HabitStorage.active();

            final filtered = habits.where((h) {
              final done = HabitStorage.isDoneToday(h);

              if (_filter == FilterType.completed) return done;
              if (_filter == FilterType.pending) return !done;
              return true;
            }).toList();

            final todayDone =
                habits.where((h) => HabitStorage.isDoneToday(h)).length;

            final double percent = habits.isEmpty
                ? 0.0
                : (todayDone / habits.length).clamp(0.0, 1.0);

            return Column(
              children: [
                _header(todayDone, habits.length, percent),
                _filters(),
                const SizedBox(height: 10),
                Expanded(
                  child: filtered.isEmpty
                      ? _emptyFilteredState(habits.isEmpty)
                      : RefreshIndicator(
                          onRefresh: () async {
                            setState(() {});
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                            itemCount: filtered.length,
                            itemBuilder: (context, i) {
                              final h = filtered[i];

                              return HabitCard(
                                habit: h,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          HabitDetailScreen(habit: h),
                                    ),
                                  );
                                },
                                onEdit: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (_) => HabitSheet(habit: h),
                                  );
                                },
                                onDelete: () async {
                                  await HabitStorage.archive(h);

                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text("Habit archived"),
                                        action: SnackBarAction(
                                          label: "Undo",
                                          onPressed: () {
                                            HabitStorage.restore(h);
                                          },
                                        ),
                                      ),
                                    );
                                  }
                                },
                              );
                            },
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4F8CFF),
        elevation: 6,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const HabitSheet(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // ================= HEADER =================

  Widget _header(int done, int total, double percent) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Today",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ArchiveScreen(),
                    ),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.archive_outlined,
                        size: 16,
                        color: Colors.white70,
                      ),
                      SizedBox(width: 6),
                      Text(
                        "Archive",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "$done / $total completed",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 10,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation(Color(0xFF4F8CFF)),
            ),
          ),
        ],
      ),
    );
  }

  // ================= FILTERS =================

  Widget _filters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _chip("All", FilterType.all),
          const SizedBox(width: 8),
          _chip("Done", FilterType.completed),
          const SizedBox(width: 8),
          _chip("Pending", FilterType.pending),
        ],
      ),
    );
  }

  Widget _chip(String label, FilterType type) {
    final selected = _filter == type;

    return GestureDetector(
      onTap: () => setState(() => _filter = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF4F8CFF)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );
  }

  // ================= EMPTY STATES =================

  Widget _emptyFilteredState(bool noHabitsAtAll) {
    if (noHabitsAtAll) {
      return _emptyState();
    }

    return const Center(
      child: Text(
        "No habits in this filter",
        style: TextStyle(
          color: Colors.white54,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "No habits yet 🚀",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F8CFF),
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const HabitSheet(),
              );
            },
            child: const Text("Create Habit"),
          )
        ],
      ),
    );
  }
}
