import 'package:flutter/material.dart';

class HabitCheckbox extends StatelessWidget {
  final bool checked;
  final VoidCallback onTap;

  const HabitCheckbox({
    super.key,
    required this.checked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: checked ? Colors.green : Colors.transparent,
          border: Border.all(
            color: Colors.green,
            width: 2,
          ),
        ),
        child: checked
            ? const Icon(
                Icons.check,
                size: 18,
                color: Colors.white,
              )
            : null,
      ),
    );
  }
}
