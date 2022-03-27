import 'package:flutter/material.dart';
import 'UserTask.dart';
import 'package:date_field/date_field.dart';

class EditUserTaskScreen extends StatelessWidget {
  static const String id = "edit_usertask";
  EditUserTaskScreen({this.initUserTask}) {
    if (initUserTask != null) {
      newUserTask = initUserTask!.copy();
    }
  }

  UserTask? initUserTask;
  UserTask newUserTask = UserTask(name: "");
  bool isApplaied = false;

  void apply(BuildContext context) {
    isApplaied = true;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add task")),
      body: Column(
        children: [
          const Text("Description:"),
          TextFormField(
              initialValue: newUserTask.name,
              onChanged: (value) => {newUserTask.name = value}),
          DateTimeFormField(
            initialValue: newUserTask.reminderDateTime,
            decoration: const InputDecoration(
              hintStyle: TextStyle(color: Colors.black45),
              errorStyle: TextStyle(color: Colors.redAccent),
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.event_note),
              labelText: 'Remind time',
            ),
            mode: DateTimeFieldPickerMode.dateAndTime,
            onDateSelected: (DateTime value) {
              newUserTask.reminderDateTime = value;
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Text("Done"),
        onPressed: () {
          apply(context);
        },
      ),
    );
  }
}
