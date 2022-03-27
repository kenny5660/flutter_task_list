class UserTask {
  UserTask({
    required this.name,
    this.reminderDateTime,
  });

  String name;
  bool isDone = false;
  DateTime? reminderDateTime;
  UserTask copy() {
    var newObj =
        UserTask(name: this.name, reminderDateTime: this.reminderDateTime);
    newObj.isDone = this.isDone;
    return newObj;
  }
}
