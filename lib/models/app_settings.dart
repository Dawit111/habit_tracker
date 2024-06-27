import 'package:isar/isar.dart';

//run this command to generate Isar compatible file: dart run build_runner build
part 'app_settings.g.dart';

@collection
class AppSettings {
  Id id = Isar.autoIncrement;
  DateTime? firstLaunchDate;
}
