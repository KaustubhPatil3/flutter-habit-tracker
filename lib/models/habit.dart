import 'package:hive/hive.dart';

part 'habit.g.dart';

@HiveType(typeId: 0)
class Habit extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<String> completedDates;

  @HiveField(3)
  bool isArchived;

  @HiveField(4)
  DateTime createdAt;

  Habit({
    required this.id,
    required this.name,
    List<String>? completedDates,
    this.isArchived = false,
    DateTime? createdAt,
  })  : completedDates = completedDates ?? [],
        createdAt = createdAt ?? DateTime.now();
}
