import 'package:flutter/material.dart';
import 'package:habit_tracker/models/app_settings.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class HabitDatabase extends ChangeNotifier {
  static late Isar isar;
  /*
 SETUP

  */

  // INITIALIZE DATABASE
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar =
        await Isar.open([HabitSchema, AppSettingsSchema], directory: dir.path);
  }

  // save the first date of app start up: (for heatmap)
  Future<void> saveFirstLaunchDate() async {
    final existingSettings = await isar.appSettings.where().findFirst();
    if (existingSettings == null) {
      final settings = AppSettings()..firstLaunchDate = DateTime.now();
      await isar.writeTxn(() => isar.appSettings.put(settings));
    }
  }

  // get first date of app start up (for heatmap)
  Future<DateTime?> getFirstLaunchDate() async {
    final settings = await isar.appSettings.where().findFirst();
    return settings?.firstLaunchDate;
  }

/*
CRUD OPERATIONS
 */

// list of habits
  final List<Habit> currentHabits = [];

// CREATE- add new habit to db
  Future<void> addHabit(String habitName) async {
    // create new habit
    final newHabit = Habit()..name = habitName;
    // save to db
    await isar.writeTxn(() => isar.habits.put(newHabit));

    // re-read from db
    readHabits();
  }

// READ- available habits from db
  Future<void> readHabits() async {
    // fetch all habits from the db
    List<Habit> allHabits = await isar.habits.where().findAll();

    // give to current habits
    currentHabits.clear();
    currentHabits.addAll(allHabits);

    // update UI
    notifyListeners();
  }

// UPDATE- check habit on and off
  Future<void> updateHabitCompletion(int id, bool isCompleted) async {
    // find the specific habit
    final habit = await isar.habits.get(id);
// update completion status
    if (habit != null) {
      await isar.writeTxn(() async {
        // if the habit is completed -> add the current days to the completed days list
        if (isCompleted && !habit.completedDays.contains(DateTime.now())) {
// today
          final today = DateTime.now();
          // add the current date if it's not already in the list
          habit.completedDays.add(DateTime(today.year, today.month, today.day));
        } else {
          // if the habit is not completed -> remove the current date from the list
          habit.completedDays.removeWhere((date) =>
              date.year == DateTime.now().year &&
              date.month == DateTime.now().month &&
              date.day == DateTime.now().day);
        }

        // save the updated habit back to the db
        await isar.habits.put(habit);
      });
    }
    // re-read from db
    readHabits();
  }

// UPDATE- habit name on db
  Future<void> updateHabitName(int id, String newName) async {
    // find the specific habit
    final habit = await isar.habits.get(id);

    // update habits name
    if (habit != null) {
      // update name
      await isar.writeTxn(() async {
        habit.name = newName;
        // save the updated habit back to the db
        await isar.habits.put(habit);
      });
    }
    // re-read from db
    readHabits();
  }

// DELETE- a habit from db
  Future<void> deleteHabit(int id) async {
    // delete it from db
    await isar.writeTxn(() async {
      await isar.habits.delete(id);
    });

    // re-read from db
    readHabits();
  }
}
