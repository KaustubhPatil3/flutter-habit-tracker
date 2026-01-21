class Habit {
  final String id;
  final String name;
  int streak;
  bool completedToday;

  Habit({
    required this.id,
    required this.name,
    this.streak = 0,
    this.completedToday = false,
  });
}
