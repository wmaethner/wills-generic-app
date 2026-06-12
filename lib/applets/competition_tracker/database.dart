import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class CompetitionTrackerDB {
  static final CompetitionTrackerDB instance = CompetitionTrackerDB._init();
  static Database? _database;

  CompetitionTrackerDB._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('competition_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tournaments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        start_date TEXT,
        end_date TEXT,
        is_archived INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE players (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tournament_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (tournament_id) REFERENCES tournaments (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE matches (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tournament_id INTEGER NOT NULL,
        game_name TEXT NOT NULL,
        player1_id INTEGER NOT NULL,
        player2_id INTEGER NOT NULL,
        winner_id INTEGER,
        status TEXT NOT NULL DEFAULT 'in_progress',
        timestamp TEXT NOT NULL,
        FOREIGN KEY (tournament_id) REFERENCES tournaments (id) ON DELETE CASCADE,
        FOREIGN KEY (player1_id) REFERENCES players (id),
        FOREIGN KEY (player2_id) REFERENCES players (id)
      )
    ''');
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
  }) async {
    final db = await database;
    return db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
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
