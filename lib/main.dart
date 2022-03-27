import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'EditUserTaskScreen.dart';
import 'UserTask.dart';
import 'DataBaseHelper.dart';
import 'NotificationService.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

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
                  const PopupMenuItem(child: Text("Edit"), value: "Edit"),
                  const PopupMenuItem(
                    child: Text("Delete"),
                    value: "Delete",
                  ),
                ]));
  }
}

class UserTaskListScreen extends StatefulWidget {
  UserTaskListScreen({Key? key}) : super(key: key);
  static const String id = "UserTaskListScreen";
  List<UserTask> userTaskList = List<UserTask>.empty();
  DatabaseHelper dbHelper = DatabaseHelper();
  NotificationService notificationService = NotificationService();

  void AddUserTask(UserTask newUserTask) {
    userTaskList.add(newUserTask);
    dbHelper.insertUserTask(newUserTask);
    AddNotification(newUserTask);
  }

  void UpdateUsertask(UserTask newUserTask) {
    userTaskList[userTaskList
        .indexWhere((element) => element.id == newUserTask.id)] = newUserTask;
    dbHelper.updateUserTask(newUserTask);
    RemoveNotification(newUserTask);
    AddNotification(newUserTask);
  }

  void RemoveUsertask(UserTask userTaskforRemove) {
    RemoveNotification(userTaskforRemove);
    userTaskList.removeWhere((userTask) => userTask.id == userTaskforRemove.id);
    dbHelper.deleteUserTask(userTaskforRemove.id!);
  }

  void retrieveUserTaskList() async {
    userTaskList = await dbHelper.retrieveUserTasks();
    for (var i = 0; i < userTaskList.length; i++) {
      AddNotification(userTaskList[i]);
    }
  }

  void RemoveNotification(UserTask userTask) async {
    notificationService.flutterLocalNotificationsPlugin
        .cancel(userTask.id ?? 0);
  }

  void AddNotification(UserTask userTask) async {
    var androidDetails = AndroidNotificationDetails(
        "Channel ID", "Desi programmer",
        channelDescription: "This is my channel");
    var iOSDetails = new IOSNotificationDetails();
    var generalNotificationDetails =
        new NotificationDetails(android: androidDetails, iOS: iOSDetails);
    if (userTask.reminderDateTime != null &&
        userTask.reminderDateTime!.isAfter(DateTime.now())) {
      await notificationService.flutterLocalNotificationsPlugin.zonedSchedule(
          userTask.id ?? 0,
          "Reminder",
          userTask.name +
              " at " +
              DateFormat("yyyy-MM-dd HH:mm")
                  .format(userTask.reminderDateTime as DateTime),
          tz.TZDateTime.from(userTask.reminderDateTime!, tz.local),
          generalNotificationDetails,
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime);
    }
  }

  // The framework calls createState the first time
  // a widget appears at a given location in the tree.
  // If the parent rebuilds and uses the same type of
  // widget (with the same key), the framework re-uses
  // the State object instead of creating a new State object.

  @override
  _UserTaskListState createState() => _UserTaskListState();
}

class _UserTaskListState extends State<UserTaskListScreen> {
  @override
  void initState() {
    super.initState();
    widget.notificationService.init();
    tz.initializeTimeZones();
    this.widget.dbHelper.initDB().whenComplete(() async {
      setState(() {
        widget.retrieveUserTaskList();
      });
    });
  }

  void _handleTaskOnClickDone(UserTask userTask) {
    setState(() {
      userTask.isDone = !userTask.isDone;
      widget.UpdateUsertask(userTask);
    });
  }

  void _handleTaskOnClickDelete(UserTask userTask) {
    setState(() {
      widget.RemoveUsertask(userTask);
    });
  }

  void _handleAddTask() async {
    var ats = EditUserTaskScreen();
    await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ats;
    }));
    setState(() {
      if (ats.newUserTask.name.isNotEmpty && ats.isApplaied) {
        widget.AddUserTask(ats.newUserTask);
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
        widget.UpdateUsertask(ats.newUserTask);
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
