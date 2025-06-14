import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'task_model.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get db async {
    _db ??= await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'tasks.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE tasks(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            titulo TEXT,
            descripcion TEXT,
            fechaHora TEXT
          )
        ''');
      },
    );
  }

  static Future<int> insertTask(Task task) async {
    final dbClient = await db;
    return dbClient.insert('tasks', task.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Task>> getTasks() async {
    final dbClient = await db;
    final res = await dbClient.query('tasks');
    return res.map((e) => Task.fromMap(e)).toList();
  }

  static Future<int> updateTask(Task task) async {
    final dbClient = await db;
    return dbClient.update('tasks', task.toMap(), where: 'id = ?', whereArgs: [task.id]);
  }

  static Future<int> deleteTask(int id) async {
    final dbClient = await db;
    return dbClient.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}
