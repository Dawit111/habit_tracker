import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class MyHabitTile extends StatelessWidget {
  final String text;
  final bool isCompleted;
  final void Function(bool?)? onChanged;
  final void Function(BuildContext)? onEditPressed;
  final void Function(BuildContext)? onDeletePressed;

  const MyHabitTile({
    super.key,
    required this.text,
    required this.isCompleted,
    required this.onChanged,
    required this.onEditPressed,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
      child: Slidable(
        endActionPane: ActionPane(motion: StretchMotion(), children: [
          // edit option
          SlidableAction(
            onPressed: onEditPressed,
            backgroundColor: Colors.grey.shade800,
            icon: Icons.settings,
            borderRadius: BorderRadius.circular(8),
          ),
          // delete option
          SlidableAction(
            onPressed: onDeletePressed,
            backgroundColor: Colors.red,
            icon: Icons.delete,
            borderRadius: BorderRadius.circular(8),
          ),
        ]),
        child: GestureDetector(
          onTap: () {
            if (onChanged != null) {
              // toggle the completion status
              onChanged!(!isCompleted);
            }
          },
          child: Container(
            decoration: BoxDecoration(
                color: isCompleted
                    ? Colors.green
                    : Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.all(12),
            child: ListTile(
              title: Text(
                text,
                style: TextStyle(
                    color: isCompleted
                        ? Colors.white
                        : Theme.of(context).colorScheme.inversePrimary),
              ),
              leading: Checkbox(
                value: isCompleted,
                onChanged: onChanged,
                activeColor: Colors.green,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
