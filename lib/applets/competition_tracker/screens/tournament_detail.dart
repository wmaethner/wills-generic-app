import 'package:flutter/material.dart';
import 'package:wills_generic_app/applets/competition_tracker/database.dart';
import 'package:wills_generic_app/applets/competition_tracker/models.dart';
import 'package:wills_generic_app/applets/competition_tracker/repositories/player_repository.dart';
import 'package:wills_generic_app/applets/competition_tracker/repositories/match_repository.dart';
import 'leaderboard.dart';
import 'match_history.dart';
import 'record_match.dart';

class TournamentDetailScreen extends StatelessWidget {
  final Tournament tournament;

  const TournamentDetailScreen({super.key, required this.tournament});

  @override
  Widget build(BuildContext context) {
    final db = CompetitionTrackerDB.instance;
    final playerRepo = PlayerRepository(db);
    final matchRepo = MatchRepository(db, playerRepo);

    return Scaffold(
      appBar: AppBar(
        title: Text(tournament.name),
        actions: [
          if (tournament.isArchived)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.archive, color: Colors.grey),
            ),
        ],
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Record Match', icon: Icon(Icons.add_circle_outline)),
                Tab(text: 'Leaderboard', icon: Icon(Icons.leaderboard)),
                Tab(text: 'History', icon: Icon(Icons.history)),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  tournament.isArchived
                      ? const _ArchivedNotice()
                      : RecordMatchScreen(
                          tournamentId: tournament.id,
                          playerRepo: playerRepo,
                        ),
                  LeaderboardScreen(
                    tournamentId: tournament.id,
                    matchRepo: matchRepo,
                    playerRepo: playerRepo,
                  ),
                  MatchHistoryScreen(
                    tournamentId: tournament.id,
                    matchRepo: matchRepo,
                    playerRepo: playerRepo,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArchivedNotice extends StatelessWidget {
  const _ArchivedNotice();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.archive,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Tournament Archived',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Unarchive to record new matches',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
