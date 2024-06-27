import 'package:flutter/material.dart';
import 'package:habit_tracker/components/my_drawer.dart';
import 'package:habit_tracker/components/my_habit_tile.dart';
import 'package:habit_tracker/components/my_heat_map.dart';
import 'package:habit_tracker/database/habit_database.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/util/habit_util.dart';
import 'package:isar/isar.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
// read the existing habit on start up
  @override
  void initState() {
    Provider.of<HabitDatabase>(context, listen: false).readHabits();
    super.initState();
  }

// text controller
  final textController = TextEditingController();

// create new habit
  void createNewHabit() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: TextField(
                controller: textController,
                decoration: const InputDecoration(hintText: 'Create New Habit'),
              ),
              actions: [
                // save button
                MaterialButton(
                    child: const Text('Save'),
                    onPressed: () {
                      // get the new habit name
                      final newHabitName = textController.text;

                      // save to db
                      context.read<HabitDatabase>().addHabit(newHabitName);

                      // pop the dialog
                      Navigator.pop(context);

                      // clear the controller
                      textController.clear();
                    }),
                // cancel button
                MaterialButton(
                    child: const Text('cancel'),
                    onPressed: () {
                      // pop the dialog
                      Navigator.pop(context);

                      // clear the controller
                      textController.clear();
                    })
              ],
            ));
  }

// check habit on and off
  void checkHabitOnOff(bool? value, Habit habit) {
// update the habit completion status
    if (value != null) {
      context.read<HabitDatabase>().updateHabitCompletion(habit.id, value);
    }
  }

  // edit habit box
  void editHabitBox(Habit habit) {
    // set the controllers text to the current habit's name
    textController.text = habit.name;
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: TextField(
                controller: textController,
              ),
              actions: [
                // save button
                MaterialButton(
                  onPressed: () {
                    // get the updated habit name
                    final updatedHabitName = textController.text;
                    // save to db
                    context
                        .read<HabitDatabase>()
                        .updateHabitName(habit.id, updatedHabitName);
                    // pop the dialog
                    Navigator.pop(context);

                    // clear the controller
                    textController.clear();
                  },
                  child: const Text('save'),
                ),
                // cancel button
                MaterialButton(
                  onPressed: () {
                    // pop the dialog
                    Navigator.pop(context);

                    // clear the controller
                    textController.clear();
                  },
                  child: const Text('cancel'),
                )
              ],
            ));
  }

  // delete habit box
  void deleteHabitBox(habit) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: Text('Are you sure to delete this habit?'),
              actions: [
                // Delete button
                MaterialButton(
                  onPressed: () {
                    // delete from db
                    context.read<HabitDatabase>().deleteHabit(habit.id);
                    // pop the dialog
                    Navigator.pop(context);
                  },
                  child: const Text('Delete'),
                ),
                // cancel button
                MaterialButton(
                  onPressed: () {
                    // pop the dialog
                    Navigator.pop(context);

                    // clear the controller
                    textController.clear();
                  },
                  child: const Text('cancel'),
                )
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    // created instance of the theme provider
    var theme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: theme.surface,
      appBar: AppBar(),
      body: ListView(
        children: [
          // H E A T M A P
          _buildHeatMap(),
          // H A B I T L I S T
          _buildHabitList()
        ],
      ),
      drawer: const MyDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewHabit,
        elevation: 0,
        backgroundColor: theme.tertiary,
        child: Icon(
          Icons.add,
          color: theme.inversePrimary,
        ),
      ),
    );
  }

  // build habit list
  Widget _buildHabitList() {
    // habit db
    final habitDatabase = context.watch<HabitDatabase>();

    // current habits
    final List<Habit> currentHabits = habitDatabase.currentHabits;

    // return a list of Habit UI
    return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: currentHabits.length,
        itemBuilder: (context, index) {
          // get individual habit
          final habit = currentHabits[index];

          // check if the habit is completed today
          bool isCompletedToday = isHabitCompletedToday(habit.completedDays);

          // return a Habit Tile UI
          return MyHabitTile(
            text: habit.name,
            isCompleted: isCompletedToday,
            onChanged: (value) => checkHabitOnOff(value, habit),
            onEditPressed: (context) => editHabitBox(habit),
            onDeletePressed: (context) => deleteHabitBox(habit),
          );
        });
  }

  // build heat map

  Widget _buildHeatMap() {
    // access habit database
    final habitDatabase = context.watch<HabitDatabase>();

    // current habit
    List<Habit> currentHabits = habitDatabase.currentHabits;

    // return heat map ui
    return FutureBuilder<DateTime?>(
        future: habitDatabase.getFirstLaunchDate(),
        builder: (context, snapshot) {
          // once the data is available -> build the heat map
          if (snapshot.hasData) {
            return MyHeatMap(
                startDate: snapshot.data!,
                datasets: prepareHeatMapDataset(currentHabits));
          }
          // handle the case when no data is returned
          else {
            return Container();
          }
        });
  }
}
