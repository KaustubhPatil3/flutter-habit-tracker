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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: checked ? const Color(0xFF4F8CFF) : Colors.transparent,
          border: Border.all(
            color: checked ? const Color(0xFF4F8CFF) : Colors.white24,
            width: 2,
          ),
          boxShadow: checked
              ? [
                  BoxShadow(
                    color: const Color(0xFF4F8CFF).withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: AnimatedScale(
          scale: checked ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          child: const Icon(
            Icons.check,
            size: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
