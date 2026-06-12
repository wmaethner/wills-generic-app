import '../database.dart';
import '../models.dart';

class TournamentRepository {
  final CompetitionTrackerDB _db;

  TournamentRepository(this._db);

  Future<Tournament> createTournament(Tournament tournament) async {
    final id = await _db.insert('tournaments', tournament.toMap());
    return tournament.copyWith(id: id);
  }

  Future<List<Tournament>> getTournaments() async {
    final maps = await _db.query('tournaments', orderBy: 'created_at DESC');
    return maps.map((m) => Tournament.fromMap(m)).toList();
  }

  Future<Tournament?> getTournament(int id) async {
    final maps = await _db.query(
      'tournaments',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Tournament.fromMap(maps.first);
  }

  Future<void> updateTournament(Tournament tournament) async {
    await _db.update(
      'tournaments',
      tournament.toMap(),
      where: 'id = ?',
      whereArgs: [tournament.id],
    );
  }

  Future<void> deleteTournament(int id) async {
    await _db.delete('tournaments', where: 'id = ?', whereArgs: [id]);
  }
}
