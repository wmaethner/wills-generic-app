import 'package:flutter/material.dart';
import 'package:wills_generic_app/applets/competition_tracker/database.dart';
import 'package:wills_generic_app/applets/competition_tracker/models.dart';
import 'package:wills_generic_app/applets/competition_tracker/repositories/tournament_repository.dart';
import 'tournament_detail.dart';

class TournamentListScreen extends StatefulWidget {
  const TournamentListScreen({super.key});

  @override
  State<TournamentListScreen> createState() => _TournamentListScreenState();
}

class _TournamentListScreenState extends State<TournamentListScreen> {
  final _tournamentRepo = TournamentRepository(CompetitionTrackerDB.instance);
  List<Tournament> _tournaments = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTournaments();
  }

  Future<void> _loadTournaments() async {
    final tournaments = await _tournamentRepo.getTournaments();
    setState(() {
      _tournaments = tournaments;
      _loading = false;
    });
  }

  Future<void> _createTournament() async {
    final nameController = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('New Tournament'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      startDate != null
                          ? 'Start: ${startDate!.month}/${startDate!.day}/${startDate!.year}'
                          : 'Start: Not set',
                      style: TextStyle(
                        color: startDate != null ? null : Colors.grey,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        setDialogState(() => startDate = date);
                      }
                    },
                    child: const Text('Set'),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      endDate != null
                          ? 'End: ${endDate!.month}/${endDate!.day}/${endDate!.year}'
                          : 'End: Not set',
                      style: TextStyle(
                        color: endDate != null ? null : Colors.grey,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        setDialogState(() => endDate = date);
                      }
                    },
                    child: const Text('Set'),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: nameController.text.trim().isEmpty
                  ? null
                  : () async {
                      await _tournamentRepo.createTournament(
                        Tournament(
                          name: nameController.text.trim(),
                          startDate: startDate,
                          endDate: endDate,
                          createdAt: DateTime.now(),
                        ),
                      );
                      if (context.mounted) Navigator.pop(context);
                      await _loadTournaments();
                    },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleArchive(Tournament tournament) async {
    await _tournamentRepo.updateTournament(
      tournament.copyWith(isArchived: !tournament.isArchived),
    );
    await _loadTournaments();
  }

  Future<void> _deleteTournament(Tournament tournament) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tournament'),
        content: Text(
          'Delete "${tournament.name}" and all its matches? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _tournamentRepo.deleteTournament(tournament.id);
      await _loadTournaments();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Competition Tracker'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _tournaments.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.gavel,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No tournaments yet',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create one to get started',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _tournaments.length,
                  itemBuilder: (context, index) {
                    final tournament = _tournaments[index];
                    return ListTile(
                      leading: Icon(
                        Icons.emoji_events,
                        color: tournament.isArchived ? Colors.grey : null,
                      ),
                      title: Text(
                        tournament.name,
                        style: TextStyle(
                          decoration:
                              tournament.isArchived
                                  ? TextDecoration.lineThrough
                                  : null,
                        ),
                      ),
                      subtitle: Text(_dateRange(tournament)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (tournament.isArchived)
                            const Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: Chip(
                                label: Text('Archived'),
                                labelStyle: TextStyle(fontSize: 12),
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                          PopupMenuButton(
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                child: Text(
                                  tournament.isArchived
                                      ? 'Unarchive'
                                      : 'Archive',
                                ),
                                onTap: () => _toggleArchive(tournament),
                              ),
                              const PopupMenuItem(
                                onTap: null,
                                child: Text('Delete'),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'delete') {
                                _deleteTournament(tournament);
                              }
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TournamentDetailScreen(
                              tournament: tournament,
                            ),
                          ),
                        ).then((_) => _loadTournaments());
                      },
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createTournament,
        child: const Icon(Icons.add),
      ),
    );
  }

  String _dateRange(Tournament tournament) {
    final parts = <String>[];
    if (tournament.startDate != null) {
      parts.add(
        '${tournament.startDate!.month}/${tournament.startDate!.day}/${tournament.startDate!.year}',
      );
    }
    if (tournament.endDate != null) {
      parts.add(
        '${tournament.endDate!.month}/${tournament.endDate!.day}/${tournament.endDate!.year}',
      );
    }
    return parts.isEmpty ? 'No dates set' : parts.join(' - ');
  }
}
