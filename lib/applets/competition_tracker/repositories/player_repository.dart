import 'package:wills_generic_app/app/applet_repository.dart';
import 'package:wills_generic_app/applets/competition_tracker/models.dart';

class PlayerRepository extends AppletRepository<Player> {
  PlayerRepository(super.db);

  @override
  String get tableName => 'players';

  @override
  Map<String, dynamic> toMap(Player item) => item.toMap();

  @override
  Player fromMap(Map<String, dynamic> map) => Player.fromMap(map);

  @override
  Player copyWithId(Player item, int id) => item.copyWith(id: id);

  @override
  int getId(Player item) => item.id;

  Future<List<Player>> getPlayers(int tournamentId) => getAll(
    where: 'tournament_id = ?',
    whereArgs: [tournamentId],
    orderBy: 'name ASC',
  );

  Future<Player> createPlayer(Player player) => create(player);

  Future<void> deletePlayer(int id) => delete(id);
}
