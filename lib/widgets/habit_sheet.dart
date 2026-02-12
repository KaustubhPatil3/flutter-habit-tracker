import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/habit.dart';
import '../services/habit_storage.dart';

class HabitSheet extends StatefulWidget {
  final Habit? habit;

  const HabitSheet({super.key, this.habit});

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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();

    if (_isEdit) {
      final h = widget.habit!;
      h.name = name;
      await HabitStorage.save(h);
    } else {
      final habit = Habit(
        id: const Uuid().v4(),
        name: name,
      );
      await HabitStorage.save(habit);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF111827),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 45,
                height: 5,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Text(
                _isEdit ? "Edit Habit" : "Create New Habit",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Habit Name",
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  prefixIcon: const Icon(Icons.edit, color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
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
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F8CFF),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _isEdit ? "Save Changes" : "Create Habit",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
