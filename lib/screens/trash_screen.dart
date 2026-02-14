import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/habit.dart';
import '../services/habit_storage.dart';

class TrashScreen extends StatefulWidget {
  const TrashScreen({super.key});

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
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
        title: Text(
          _isSelecting ? "${_selected.length} selected" : "Trash",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        leading: _isSelecting
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _selected.clear()),
              )
            : null,
        actions: [
          if (_isSelecting)
            TextButton(
              onPressed: _toggleSelectAll,
              child: Text(
                _selected.length == HabitStorage.trash().length
                    ? "Deselect All"
                    : "Select All",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          if (!_isSelecting && HabitStorage.trash().isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              onPressed: _confirmDeleteAll,
            ),
        ],
      ),

      // ================= BODY =================
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Habit>('habits').listenable(),
        builder: (_, box, __) {
          final trash = HabitStorage.trash();

          if (trash.isEmpty) {
            return _emptyState();
          }

          return Column(
            children: [
              _header(trash.length),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                  itemCount: trash.length,
                  itemBuilder: (_, i) {
                    final h = trash[i];
                    final isSelected = _selected.contains(h);

                    return Dismissible(
                      key: ValueKey(h.key),
                      direction: DismissDirection.startToEnd,
                      background: _restoreBackground(),
                      onDismissed: (_) async {
                        await HabitStorage.restore(h);
                        _showUndo(h);
                      },
                      child: GestureDetector(
                        onLongPress: () => setState(() => _selected.add(h)),
                        onTap: () {
                          if (_isSelecting) {
                            setState(() {
                              isSelected
                                  ? _selected.remove(h)
                                  : _selected.add(h);
                            });
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.red.withOpacity(0.15)
                                : const Color(0xFF111827),
                            borderRadius: BorderRadius.circular(16),
                            border: isSelected
                                ? Border.all(color: Colors.red)
                                : null,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                color: isSelected ? Colors.red : Colors.white54,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  h.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              if (_isSelecting)
                                Icon(
                                  isSelected
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  color: isSelected ? Colors.red : Colors.grey,
                                ),
                            ],
                          ),
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

      // ================= BOTTOM ACTION BAR =================
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
                    onPressed: _restoreSelected,
                    icon: const Icon(Icons.restore, color: Colors.green),
                    label: const Text(
                      "Restore",
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _confirmDeleteSelected,
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                    label: const Text(
                      "Delete",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  // ================= HEADER =================

  Widget _header(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$count habits in trash",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Items here can be restored or permanently deleted.",
            style: TextStyle(
              color: Colors.white60,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _restoreBackground() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.restore, color: Colors.white),
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete_outline, size: 60, color: Colors.white24),
          SizedBox(height: 12),
          Text(
            "Trash is empty",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  // ================= ACTIONS =================

  void _toggleSelectAll() {
    final trash = HabitStorage.trash();
    setState(() {
      if (_selected.length == trash.length) {
        _selected.clear();
      } else {
        _selected.addAll(trash);
      }
    });
  }

  Future<void> _restoreSelected() async {
    for (var h in _selected) {
      await HabitStorage.restore(h);
    }
    setState(() => _selected.clear());
  }

  void _confirmDeleteSelected() {
    _confirmDelete(() async {
      for (var h in _selected) {
        await HabitStorage.delete(h);
      }
      setState(() => _selected.clear());
    });
  }

  void _confirmDeleteAll() {
    _confirmDelete(() async {
      final trash = HabitStorage.trash();
      for (var h in trash) {
        await HabitStorage.delete(h);
      }
    });
  }

  void _confirmDelete(Future<void> Function() action) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        title: const Text("Delete Permanently?"),
        content: const Text("This action cannot be undone."),
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
              await action();
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void _showUndo(Habit habit) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${habit.name} restored"),
        action: SnackBarAction(
          label: "Undo",
          onPressed: () async {
            await HabitStorage.archive(habit);
          },
        ),
      ),
    );
  }
}
