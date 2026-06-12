import 'package:flutter/material.dart';
import 'package:wills_generic_app/applets/competition_tracker/database.dart';
import 'package:wills_generic_app/applets/competition_tracker/models.dart';
import 'package:wills_generic_app/applets/competition_tracker/repositories/player_repository.dart';
import 'package:wills_generic_app/applets/competition_tracker/repositories/match_repository.dart';

class RecordMatchScreen extends StatefulWidget {
  final int tournamentId;
  final PlayerRepository playerRepo;

  const RecordMatchScreen({
    super.key,
    required this.tournamentId,
    required this.playerRepo,
  });

  @override
  State<RecordMatchScreen> createState() => _RecordMatchScreenState();
}

class _RecordMatchScreenState extends State<RecordMatchScreen> {
  final _gameController = TextEditingController();
  late final MatchRepository _matchRepo;
  List<Player> _players = [];
  int? _player1Id;
  int? _player2Id;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final db = CompetitionTrackerDB.instance;
    _matchRepo = MatchRepository(db, widget.playerRepo);
    _loadPlayers();
  }

  @override
  void dispose() {
    _gameController.dispose();
    super.dispose();
  }

  Future<void> _loadPlayers() async {
    final players = await widget.playerRepo.getPlayers(widget.tournamentId);
    setState(() {
      _players = players;
      _loading = false;
    });
  }

  Future<void> _addPlayer() async {
    final controller = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Add Player'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Player name'),
              autofocus: true,
              onChanged: (_) => setDialogState(() {}),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: controller.text.trim().isEmpty
                    ? null
                    : () => Navigator.pop(context, true),
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );

    if (result == true && controller.text.trim().isNotEmpty) {
      final player = await widget.playerRepo.createPlayer(
        Player(
          tournamentId: widget.tournamentId,
          name: controller.text.trim(),
          createdAt: DateTime.now(),
        ),
      );
      await _loadPlayers();
      setState(() {
        if (_player1Id == null) {
          _player1Id = player.id;
        } else {
          _player2Id = player.id;
        }
      });
    }
  }

  Future<void> _submitMatch() async {
    if (_gameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a game name')),
      );
      return;
    }
    if (_player1Id == null || _player2Id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select both players')),
      );
      return;
    }
    if (_player1Id == _player2Id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Players must be different')),
      );
      return;
    }

    await _matchRepo.createMatch(
      Match(
        tournamentId: widget.tournamentId,
        gameName: _gameController.text.trim(),
        player1Id: _player1Id!,
        player2Id: _player2Id!,
        status: MatchStatus.inProgress,
        timestamp: DateTime.now(),
      ),
    );

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Match recorded')));
      _gameController.clear();
      setState(() {
        _player1Id = null;
        _player2Id = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _gameController,
            decoration: const InputDecoration(
              labelText: 'Game Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Player 1', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            initialValue: _player1Id,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            hint: const Text('Select player'),
            items: [
              ..._players.map(
                (p) => DropdownMenuItem(value: p.id, child: Text(p.name)),
              ),
              const DropdownMenuItem(
                value: -1,
                child: Text('+ Add new player'),
              ),
            ],
            onChanged: (value) {
              if (value == -1) {
                _addPlayer();
              } else {
                setState(() => _player1Id = value);
              }
            },
          ),
          const SizedBox(height: 16),
          const Text('Player 2', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            initialValue: _player2Id,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            hint: const Text('Select player'),
            items: [
              ..._players.map(
                (p) => DropdownMenuItem(value: p.id, child: Text(p.name)),
              ),
              const DropdownMenuItem(
                value: -1,
                child: Text('+ Add new player'),
              ),
            ],
            onChanged: (value) {
              if (value == -1) {
                _addPlayer();
              } else {
                setState(() => _player2Id = value);
              }
            },
          ),
          const Spacer(),
          FilledButton.icon(
            onPressed: _loading ? null : _submitMatch,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Record Match'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}
