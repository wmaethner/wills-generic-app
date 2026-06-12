import 'package:sqflite/sqflite.dart';
import 'package:wills_generic_app/app/applet_database.dart';

class AppletIdeasDB extends AppletDatabase {
  static final AppletIdeasDB instance = AppletIdeasDB._init();

  AppletIdeasDB._init() : super();

  @override
  String get dbName => 'applet_ideas.db';

  @override
  OnCreateCallback get onCreate => _createDB;

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ideas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL
      )
    ''');
  }
}
