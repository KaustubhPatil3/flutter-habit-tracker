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
  final Set<Habit> _selected = {};

  bool get _isSelecting => _selected.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),

      // ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1220),
        elevation: 0,
        centerTitle: false,
        title: Text(
          _isSelecting ? "${_selected.length} selected" : "Today",
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
        leading: _isSelecting
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _selected.clear()),
              )
            : null,
        actions: !_isSelecting
            ? [
                IconButton(
                  icon: const Icon(Icons.archive_outlined),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ArchiveScreen(),
                      ),
                    );
                  },
                ),
              ]
            : [],
      ),

      // ================= BODY =================
      body: SafeArea(
        top: false,
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

            final percent = habits.isEmpty ? 0.0 : (todayDone / habits.length);

            return Column(
              children: [
                _header(todayDone, habits.length, percent),
                _filters(),
                const SizedBox(height: 10),
                Expanded(
                  child: habits.isEmpty
                      ? _emptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                          itemCount: filtered.length,
                          itemBuilder: (context, i) {
                            final h = filtered[i];
                            final isSelected = _selected.contains(h);

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: isSelected
                                    ? const Color(0xFF4F8CFF).withOpacity(0.15)
                                    : Colors.transparent,
                                border: isSelected
                                    ? Border.all(
                                        color: const Color(0xFF4F8CFF),
                                        width: 1.5,
                                      )
                                    : null,
                              ),
                              child: GestureDetector(
                                onLongPress: () {
                                  setState(() => _selected.add(h));
                                },
                                onTap: () {
                                  if (_isSelecting) {
                                    setState(() {
                                      isSelected
                                          ? _selected.remove(h)
                                          : _selected.add(h);
                                    });
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            HabitDetailScreen(habit: h),
                                      ),
                                    );
                                  }
                                },
                                child: HabitCard(
                                  habit: h,
                                  onTap: () {},
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
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),

      // ================= FLOATING ACTION =================
      floatingActionButton: !_isSelecting
          ? FloatingActionButton(
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
            )
          : null,

      // ================= BOTTOM ACTION BAR (SELECTION MODE) =================
      bottomNavigationBar: _isSelecting
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF111827),
                border: Border(
                  top: BorderSide(color: Colors.white10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: _moveSelectedToTrash,
                    icon:
                        const Icon(Icons.delete_outline, color: Colors.orange),
                    label: const Text("Move to Trash",
                        style: TextStyle(color: Colors.orange)),
                  ),
                  TextButton.icon(
                    onPressed: _confirmPermanentDelete,
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                    label: const Text("Delete",
                        style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _header(int done, int total, double percent) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$done / $total completed",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 8,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation(Color(0xFF4F8CFF)),
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _emptyState() {
    return const Center(
      child: Text(
        "No habits yet 🚀",
        style: TextStyle(
          color: Colors.white70,
          fontSize: 18,
        ),
      ),
    );
  }

  Future<void> _moveSelectedToTrash() async {
    for (var h in _selected) {
      await HabitStorage.archive(h);
    }
    setState(() => _selected.clear());
  }

  void _confirmPermanentDelete() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        title: const Text("Delete Forever?"),
        content: const Text(
          "This action cannot be undone.",
        ),
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
              for (var h in _selected) {
                await HabitStorage.delete(h);
              }
              Navigator.pop(context);
              setState(() => _selected.clear());
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
