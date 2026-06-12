import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

typedef OnCreateCallback = Future<void> Function(Database db, int version);

abstract class AppletDatabase {
  AppletDatabase();

  String get dbName;
  OnCreateCallback get onCreate;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(dbName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return openDatabase(path, version: 1, onCreate: onCreate);
  }

  Future<void> init() async {
    await database;
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return db.insert(table, data);
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    return db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    required String where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return db.update(table, data, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(
    String table, {
    required String where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<void> execute(String sql) async {
    final db = await database;
    await db.execute(sql);
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
