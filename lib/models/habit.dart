class Habit {
  final String id;
  final String name;
  int streak;
  bool completedToday;
  final int colorValue;

  Habit({
    required this.id,
    required this.name,
    this.streak = 0,
    this.completedToday = false,
    required this.colorValue,
  });
}
