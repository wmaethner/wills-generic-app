import 'package:wills_generic_app/app/applet_database.dart';

abstract class AppletRepository<T> {
  AppletRepository(this.db);

  final AppletDatabase db;

  String get tableName;

  Map<String, dynamic> toMap(T item);
  T fromMap(Map<String, dynamic> map);
  T copyWithId(T item, int id);
  int getId(T item);

  Future<T> create(T item) async {
    final id = await db.insert(tableName, toMap(item));
    return copyWithId(item, id);
  }

  Future<List<T>> getAll({
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
  }) async {
    final maps = await db.query(
      tableName,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
    );
    return maps.map(fromMap).toList();
  }

  Future<T?> getById(int id) async {
    final maps = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return fromMap(maps.first);
  }

  Future<void> update(T item) async {
    await db.update(
      tableName,
      toMap(item),
      where: 'id = ?',
      whereArgs: [getId(item)],
    );
  }

  Future<void> delete(int id) async {
    await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }
}
