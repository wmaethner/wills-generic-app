import 'package:flutter/material.dart';
import 'package:wills_generic_app/applets/competition_tracker/models.dart';
import 'package:wills_generic_app/applets/competition_tracker/repositories/player_repository.dart';
import 'package:wills_generic_app/applets/competition_tracker/repositories/match_repository.dart';

class LeaderboardScreen extends StatefulWidget {
  final int tournamentId;
  final MatchRepository matchRepo;
  final PlayerRepository playerRepo;

  const LeaderboardScreen({
    super.key,
    required this.tournamentId,
    required this.matchRepo,
    required this.playerRepo,
  });

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<PlayerStats> _stats = [];
  List<Player> _players = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final stats = await widget.matchRepo.getLeaderboardStats(widget.tournamentId);
    final players = await widget.playerRepo.getPlayers(widget.tournamentId);
    setState(() {
      _stats = stats;
      _players = players;
      _loading = false;
    });
  }

  void _showHeadToHead(PlayerStats player) async {
    final opponents = _players.where((p) => p.id != player.playerId).toList();
    final h2hData = <Map<String, dynamic>>[];

    for (final opponent in opponents) {
      final h2h = await widget.matchRepo.getHeadToHead(
        widget.tournamentId,
        player.playerId,
        opponent.id,
      );
      h2hData.add({
        'opponent': opponent.name,
        'wins': h2h['wins']!,
        'losses': h2h['losses']!,
        'ties': h2h['ties']!,
      });
    }

    if (mounted) {
      showModalBottomSheet(
        context: context,
        builder: (context) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${player.playerName} - Head to Head',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              if (h2hData.isEmpty)
                const Text('No opponents yet')
              else
                ...h2hData.map(
                  (h) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            h['opponent'] as String,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          '${h['wins']}W - ${h['losses']}L - ${h['ties']}T',
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_stats.isEmpty) {
      return const Center(child: Text('No players yet'));
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: const [
              SizedBox(width: 32, child: Text('#', textAlign: TextAlign.center)),
              Expanded(
                flex: 2,
                child: Text('Player', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Expanded(child: Text('W', textAlign: TextAlign.center)),
              Expanded(child: Text('L', textAlign: TextAlign.center)),
              Expanded(child: Text('T', textAlign: TextAlign.center)),
              Expanded(child: Text('Win%', textAlign: TextAlign.center)),
              Expanded(child: Text('Streak', textAlign: TextAlign.center)),
            ],
          ),
        ),
        const Divider(),
        ..._stats.asMap().entries.map((entry) {
          final index = entry.key;
          final stat = entry.value;
          return InkWell(
            onTap: () => _showHeadToHead(stat),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 32,
                    child: Text(
                      '${index + 1}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(stat.playerName),
                  ),
                  Expanded(
                    child: Text(
                      '${stat.wins}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.green[700]),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${stat.losses}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${stat.ties}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${(stat.winRate * 100).toStringAsFixed(1)}%',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      stat.currentStreak > 0
                          ? 'W${stat.currentStreak}'
                          : '-',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color:
                            stat.currentStreak > 0 ? Colors.green[700] : null,
                        fontWeight:
                            stat.currentStreak > 0 ? FontWeight.bold : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
