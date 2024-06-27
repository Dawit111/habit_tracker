import 'package:isar/isar.dart';

//run this command to generate Isar compatible file: dart run build_runner build
part 'habit.g.dart';

@collection
class Habit {
  // habit id
  Id id = Isar.autoIncrement;

  // habit name
  late String name;

  // completed date
  List<DateTime> completedDays = [];
}
