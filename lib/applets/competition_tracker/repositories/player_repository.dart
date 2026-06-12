import '../database.dart';
import '../models.dart';

class PlayerRepository {
  final CompetitionTrackerDB _db;

  PlayerRepository(this._db);

  Future<Player> createPlayer(Player player) async {
    final id = await _db.insert('players', player.toMap());
    return player.copyWith(id: id);
  }

  Future<List<Player>> getPlayers(int tournamentId) async {
    final maps = await _db.query(
      'players',
      where: 'tournament_id = ?',
      whereArgs: [tournamentId],
      orderBy: 'name ASC',
    );
    return maps.map((m) => Player.fromMap(m)).toList();
  }

  Future<void> deletePlayer(int id) async {
    await _db.delete('players', where: 'id = ?', whereArgs: [id]);
  }
}
