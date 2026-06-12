import 'package:wills_generic_app/app/applet_repository.dart';
import 'package:wills_generic_app/applets/competition_tracker/models.dart';
import 'player_repository.dart';

class MatchRepository extends AppletRepository<Match> {
  final PlayerRepository _playerRepo;

  MatchRepository(super.db, this._playerRepo);

  @override
  String get tableName => 'matches';

  @override
  Map<String, dynamic> toMap(Match item) => item.toMap();

  @override
  Match fromMap(Map<String, dynamic> map) => Match.fromMap(map);

  @override
  Match copyWithId(Match item, int id) => item.copyWith(id: id);

  @override
  int getId(Match item) => item.id;

  Future<Match> createMatch(Match match) => create(match);

  Future<void> deleteMatch(int id) => delete(id);

  Future<List<Match>> getMatches(int tournamentId) async {
    final maps = await db.query(
      tableName,
      where: 'tournament_id = ?',
      whereArgs: [tournamentId],
      orderBy: 'timestamp DESC',
    );
    return maps.map(fromMap).toList();
  }

  Future<void> resolveMatch(int matchId, int? winnerId) async {
    await db.update(
      tableName,
      {'status': 'completed', 'winner_id': winnerId},
      where: 'id = ?',
      whereArgs: [matchId],
    );
  }

  Future<List<PlayerStats>> getLeaderboardStats(int tournamentId) async {
    final players = await _playerRepo.getPlayers(tournamentId);
    final matches = await getMatches(tournamentId);
    final completedMatches =
        matches.where((m) => m.status == MatchStatus.completed).toList();

    final stats = <int, PlayerStats>{};

    for (final player in players) {
      int wins = 0;
      int losses = 0;
      int ties = 0;
      int currentStreak = 0;
      int longestWinStreak = 0;
      int tempWinStreak = 0;

      final playerMatches = completedMatches
          .where((m) => m.player1Id == player.id || m.player2Id == player.id)
          .toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

      for (final match in playerMatches) {
        if (match.winnerId == null) {
          ties++;
          tempWinStreak = 0;
        } else if (match.winnerId == player.id) {
          wins++;
          tempWinStreak++;
          if (tempWinStreak > longestWinStreak) {
            longestWinStreak = tempWinStreak;
          }
        } else {
          losses++;
          tempWinStreak = 0;
        }
      }

      currentStreak = tempWinStreak;

      final totalGames = wins + losses + ties;
      final winRate = totalGames > 0 ? wins / totalGames : 0.0;

      stats[player.id] = PlayerStats(
        playerId: player.id,
        playerName: player.name,
        wins: wins,
        losses: losses,
        ties: ties,
        winRate: winRate,
        currentStreak: currentStreak,
        longestWinStreak: longestWinStreak,
      );
    }

    return stats.values.toList()
      ..sort((a, b) {
        if (b.wins != a.wins) return b.wins.compareTo(a.wins);
        return b.winRate.compareTo(a.winRate);
      });
  }

  Future<Map<String, int>> getHeadToHead(
    int tournamentId,
    int playerId,
    int opponentId,
  ) async {
    final matches = await getMatches(tournamentId);
    final completedMatches =
        matches.where((m) => m.status == MatchStatus.completed).toList();

    final h2h = completedMatches.where((m) =>
        (m.player1Id == playerId && m.player2Id == opponentId) ||
        (m.player1Id == opponentId && m.player2Id == playerId));

    int wins = 0;
    int losses = 0;
    int ties = 0;

    for (final match in h2h) {
      if (match.winnerId == null) {
        ties++;
      } else if (match.winnerId == playerId) {
        wins++;
      } else {
        losses++;
      }
    }

    return {'wins': wins, 'losses': losses, 'ties': ties};
  }
}
