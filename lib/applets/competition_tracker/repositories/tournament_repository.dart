import 'package:wills_generic_app/app/applet_repository.dart';
import 'package:wills_generic_app/applets/competition_tracker/models.dart';

class TournamentRepository extends AppletRepository<Tournament> {
  TournamentRepository(super.db);

  @override
  String get tableName => 'tournaments';

  @override
  Map<String, dynamic> toMap(Tournament item) => item.toMap();

  @override
  Tournament fromMap(Map<String, dynamic> map) => Tournament.fromMap(map);

  @override
  Tournament copyWithId(Tournament item, int id) => item.copyWith(id: id);

  @override
  int getId(Tournament item) => item.id;

  Future<List<Tournament>> getTournaments() => getAll(orderBy: 'created_at DESC');

  Future<Tournament> createTournament(Tournament tournament) => create(tournament);

  Future<Tournament?> getTournament(int id) => getById(id);

  Future<void> updateTournament(Tournament tournament) => update(tournament);

  Future<void> deleteTournament(int id) => delete(id);
}
