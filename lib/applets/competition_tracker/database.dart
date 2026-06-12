import 'package:sqflite/sqflite.dart';
import 'package:wills_generic_app/app/applet_database.dart';

class CompetitionTrackerDB extends AppletDatabase {
  static final CompetitionTrackerDB instance = CompetitionTrackerDB._init();

  CompetitionTrackerDB._init() : super();

  @override
  String get dbName => 'competition_tracker.db';

  @override
  OnCreateCallback get onCreate => _createDB;

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
}
