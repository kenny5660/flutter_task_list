import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'EditUserTaskScreen.dart';
import 'UserTask.dart';

class UserTaskListItem extends StatelessWidget {
  UserTaskListItem({
    required this.userTask,
    this.onClickDone,
    this.onClickEdit,
    this.onClickDelete,
  }) : super(key: ObjectKey(userTask));

  final UserTask userTask;
  final Function(UserTask userTask)? onClickDone;
  final Function(UserTask userTask)? onClickEdit;
  final Function(UserTask userTask)? onClickDelete;

  Color _getColor(BuildContext context) {
    // The theme depends on the BuildContext because different
    // parts of the tree can have different themes.
    // The BuildContext indicates where the build is
    // taking place and therefore which theme to use.

    return userTask.isDone //
        ? Colors.black54
        : Theme.of(context).primaryColor;
  }

  TextStyle? _getTextStyle(BuildContext context) {
    if (!userTask.isDone) return null;

    return const TextStyle(
      color: Colors.black54,
      decoration: TextDecoration.lineThrough,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
        onTap: () {
          if (onClickDone != null) {
            onClickDone!(userTask);
          }
        },
        leading: CircleAvatar(
          backgroundColor: _getColor(context),
          child: Text(userTask.name[0]),
        ),
        title: Text(
          userTask.name,
          style: _getTextStyle(context),
        ),
        subtitle: userTask.reminderDateTime == null
            ? null
            : Text("Remind at " +
                DateFormat("yyyy-MM-dd HH:mm")
                    .format(userTask.reminderDateTime as DateTime)),
        trailing: PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (onClickEdit != null && value == "Edit") {
                onClickEdit!(userTask);
              }
              if (onClickDelete != null && value == "Delete") {
                onClickDelete!(userTask);
              }
            },
            itemBuilder: (context) => [
                  const PopupMenuItem(child: const Text("Edit"), value: "Edit"),
                  const PopupMenuItem(
                    child: const Text("Delete"),
                    value: "Delete",
                  ),
                ]));
  }
}

class UserTaskListScreen extends StatefulWidget {
  UserTaskListScreen({Key? key}) : super(key: key);
  static const String id = "UserTaskListScreen";
  final List<UserTask> userTaskList = [
    UserTask(name: "Get up", reminderDateTime: DateTime.utc(2021, 7, 23, 7)),
    UserTask(
        name: "Breakfast", reminderDateTime: DateTime.utc(2021, 7, 23, 7, 15)),
    UserTask(name: "Go work"),
    UserTask(
        name: "dinner", reminderDateTime: DateTime.utc(2021, 7, 23, 13, 00)),
    UserTask(
        name: "meeting at 7 floor",
        reminderDateTime: DateTime.utc(2021, 7, 23, 14, 00)),
    UserTask(name: "Buy milk"),
    UserTask(name: "Buy butter"),
  ];

  // The framework calls createState the first time
  // a widget appears at a given location in the tree.
  // If the parent rebuilds and uses the same type of
  // widget (with the same key), the framework re-uses
  // the State object instead of creating a new State object.

  @override
  _UserTaskListState createState() => _UserTaskListState();
}

class _UserTaskListState extends State<UserTaskListScreen> {
  void _handleTaskOnClickDone(UserTask userTask) {
    setState(() {
      userTask.isDone = !userTask.isDone;
    });
  }

  void _handleTaskOnClickDelete(UserTask userTask) {
    setState(() {
      widget.userTaskList.remove(userTask);
    });
  }

  void _handleAddTask() async {
    var ats = EditUserTaskScreen();
    await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ats;
    }));
    setState(() {
      if (ats.newUserTask.name.isNotEmpty && ats.isApplaied) {
        widget.userTaskList.add(ats.newUserTask);
      }
    });
  }

  void _handleEditTask(UserTask userTask) async {
    var ats = EditUserTaskScreen(
      initUserTask: userTask,
    );
    await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ats;
    }));
    setState(() {
      if (ats.newUserTask.name.isNotEmpty && ats.isApplaied) {
        widget.userTaskList[widget.userTaskList.indexOf(userTask)] =
            (ats.newUserTask);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Task List'),
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          children: widget.userTaskList.map((UserTask userTask) {
            return UserTaskListItem(
              userTask: userTask,
              onClickDone: _handleTaskOnClickDone,
              onClickDelete: _handleTaskOnClickDelete,
              onClickEdit: _handleEditTask,
            );
          }).toList(),
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: _handleAddTask,
            tooltip: 'Add new task',
            child: const Icon(Icons.add)));
  }
}

void main() {
  runApp(MaterialApp(
    title: 'Task App',
    home: UserTaskListScreen(),
  ));
}
