import 'dart:async';
import 'UserTask.dart';
import 'package:path/path.dart' as Path;
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _databaseHelper = DatabaseHelper._();

  DatabaseHelper._();

  late Database db;

  factory DatabaseHelper() {
    return _databaseHelper;
  }
  static const String _tableName = "user_tasks";
  Future<void> initDB() async {
    String path = await getDatabasesPath();
    db = await openDatabase(
      Path.join(path, 'user_tasks.db'),
      onCreate: (database, version) async {
        await database.execute(
          """
            CREATE TABLE $_tableName (
              id INTEGER PRIMARY KEY AUTOINCREMENT, 
              name TEXT NOT NULL,
              isDone INT NOT NULL, 
              reminderDateTime INT
            )
          """,
        );
        await database.insert(
            _tableName,
            UserTask(
                    name: "Get up",
                    reminderDateTime: DateTime.now().add(Duration(seconds: 5)))
                .toMap());
        await database.insert(
            _tableName,
            UserTask(
                    name: "Breakfast",
                    reminderDateTime: DateTime.now().add(Duration(seconds: 10)))
                .toMap());
        await database.insert(_tableName, UserTask(name: "Buy bread").toMap());
        await database.insert(_tableName, UserTask(name: "Buy milk").toMap());
      },
      version: 1,
    );
  }

  Future<int> insertUserTask(UserTask userTask) async {
    int result = await db.insert(_tableName, userTask.toMap());
    return result;
  }

  Future<int> updateUserTask(UserTask userTask) async {
    int result = await db.update(
      _tableName,
      userTask.toMap(),
      where: "id = ?",
      whereArgs: [userTask.id],
    );
    return result;
  }

  Future<List<UserTask>> retrieveUserTasks() async {
    final List<Map<String, Object?>> queryResult = await db.query(_tableName);
    return queryResult.map((e) => UserTask.fromMap(e)).toList();
  }

  Future<void> deleteUserTask(int id) async {
    await db.delete(
      _tableName,
      where: "id = ?",
      whereArgs: [id],
    );
  }
}
