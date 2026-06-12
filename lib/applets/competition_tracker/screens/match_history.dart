import 'package:flutter/material.dart';
import 'package:wills_generic_app/applets/competition_tracker/models.dart';
import 'package:wills_generic_app/applets/competition_tracker/repositories/player_repository.dart';
import 'package:wills_generic_app/applets/competition_tracker/repositories/match_repository.dart';

class MatchHistoryScreen extends StatefulWidget {
  final int tournamentId;
  final MatchRepository matchRepo;
  final PlayerRepository playerRepo;

  const MatchHistoryScreen({
    super.key,
    required this.tournamentId,
    required this.matchRepo,
    required this.playerRepo,
  });

  @override
  State<MatchHistoryScreen> createState() => _MatchHistoryScreenState();
}

class _MatchHistoryScreenState extends State<MatchHistoryScreen> {
  List<Match> _matches = [];
  List<Player> _players = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final matches = await widget.matchRepo.getMatches(widget.tournamentId);
    final players = await widget.playerRepo.getPlayers(widget.tournamentId);
    setState(() {
      _matches = matches;
      _players = players;
      _loading = false;
    });
  }

  String _playerName(int playerId) {
    final player = _players.firstWhere(
      (p) => p.id == playerId,
      orElse: () => Player(
        tournamentId: 0,
        name: 'Unknown',
        createdAt: DateTime.now(),
      ),
    );
    return player.name;
  }

  Future<void> _resolveMatch(Match match) async {
    int? winnerId;

    await showDialog<int?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resolve Match'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.emoji_events),
              title: Text(_playerName(match.player1Id)),
              onTap: () {
                winnerId = match.player1Id;
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.emoji_events),
              title: Text(_playerName(match.player2Id)),
              onTap: () {
                winnerId = match.player2Id;
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.handshake),
              title: const Text('Tie'),
              onTap: () {
                winnerId = null;
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );

    if (winnerId != null || (winnerId == null && context.mounted)) {
      await widget.matchRepo.resolveMatch(match.id, winnerId);
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_matches.isEmpty) {
      return const Center(child: Text('No matches yet'));
    }

    return ListView.builder(
      itemCount: _matches.length,
      itemBuilder: (context, index) {
        final match = _matches[index];
        final p1Name = _playerName(match.player1Id);
        final p2Name = _playerName(match.player2Id);

        String resultText;
        Widget? trailing;

        if (match.status == MatchStatus.inProgress) {
          resultText = 'In Progress';
          trailing = FilledButton.tonal(
            onPressed: () => _resolveMatch(match),
            child: const Text('Resolve'),
          );
        } else {
          if (match.winnerId == null) {
            resultText = 'Tie';
          } else if (match.winnerId == match.player1Id) {
            resultText = '$p1Name won';
          } else {
            resultText = '$p2Name won';
          }
        }

        return Dismissible(
          key: Key('match_${match.id}'),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (direction) async {
            return await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete Match'),
                content: const Text('Delete this match?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: FilledButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            );
          },
          onDismissed: (direction) async {
            await widget.matchRepo.deleteMatch(match.id);
            await _loadData();
          },
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: ListTile(
              leading: Icon(
                match.status == MatchStatus.inProgress
                    ? Icons.pending
                    : Icons.check_circle,
                color:
                    match.status == MatchStatus.inProgress
                        ? Colors.orange
                        : Colors.green,
              ),
              title: Text('$p1Name vs $p2Name'),
              subtitle: Text(
                '${match.gameName} • ${_formatDate(match.timestamp)}',
              ),
              trailing: trailing ?? Text(resultText),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
