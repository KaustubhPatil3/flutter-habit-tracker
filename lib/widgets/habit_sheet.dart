import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/habit.dart';
import '../services/habit_storage.dart';

class HabitSheet extends StatefulWidget {
  final Habit? habit;

  const HabitSheet({
    super.key,
    this.habit,
  });

  @override
  State<HabitSheet> createState() => _HabitSheetState();
}

class _HabitSheetState extends State<HabitSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;

  bool _isEdit = false;

  @override
  void initState() {
    super.initState();

    _isEdit = widget.habit != null;

    _nameController = TextEditingController(text: widget.habit?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // ================= SAVE =================

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();

    if (_isEdit) {
      // Update
      final h = widget.habit!;
      h.name = name;

      await HabitStorage.save(h);
    } else {
      // Create
      final id = const Uuid().v4();

      final habit = Habit(
        id: id,
        name: name,
        completedDates: [],
        isArchived: false,
      );

      await HabitStorage.save(habit);
    }

    if (mounted) Navigator.pop(context);
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(
          20,
          24,
          20,
          24,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ================= DRAG HANDLE =================

              Container(
                width: 45,
                height: 5,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // ================= TITLE =================

              Text(
                _isEdit ? "Edit Habit" : "New Habit",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 18),

              // ================= INPUT =================

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Habit Name",
                  prefixIcon: Icon(Icons.edit),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return "Enter habit name";
                  }

                  if (v.trim().length < 2) {
                    return "Too short";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 22),

              // ================= BUTTON =================

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: Icon(
                    _isEdit ? Icons.save : Icons.add,
                  ),
                  label: Text(
                    _isEdit ? "Save Changes" : "Create Habit",
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _save,
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
