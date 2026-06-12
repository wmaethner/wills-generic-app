enum MatchStatus { inProgress, completed }

class Tournament {
  final int id;
  final String name;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isArchived;
  final DateTime createdAt;

  Tournament({
    this.id = 0,
    required this.name,
    this.startDate,
    this.endDate,
    this.isArchived = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != 0) 'id': id,
      'name': name,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'is_archived': isArchived ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Tournament.fromMap(Map<String, dynamic> map) {
    return Tournament(
      id: map['id'] as int,
      name: map['name'] as String,
      startDate: map['start_date'] != null
          ? DateTime.parse(map['start_date'] as String)
          : null,
      endDate: map['end_date'] != null
          ? DateTime.parse(map['end_date'] as String)
          : null,
      isArchived: (map['is_archived'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

class Player {
  final int id;
  final int tournamentId;
  final String name;
  final DateTime createdAt;

  Player({
    this.id = 0,
    required this.tournamentId,
    required this.name,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != 0) 'id': id,
      'tournament_id': tournamentId,
      'name': name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id'] as int,
      tournamentId: map['tournament_id'] as int,
      name: map['name'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

class Match {
  final int id;
  final int tournamentId;
  final String gameName;
  final int player1Id;
  final int player2Id;
  final int? winnerId;
  final MatchStatus status;
  final DateTime timestamp;

  Match({
    this.id = 0,
    required this.tournamentId,
    required this.gameName,
    required this.player1Id,
    required this.player2Id,
    this.winnerId,
    this.status = MatchStatus.inProgress,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != 0) 'id': id,
      'tournament_id': tournamentId,
      'game_name': gameName,
      'player1_id': player1Id,
      'player2_id': player2Id,
      'winner_id': winnerId,
      'status': status == MatchStatus.inProgress ? 'in_progress' : 'completed',
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Match.fromMap(Map<String, dynamic> map) {
    return Match(
      id: map['id'] as int,
      tournamentId: map['tournament_id'] as int,
      gameName: map['game_name'] as String,
      player1Id: map['player1_id'] as int,
      player2Id: map['player2_id'] as int,
      winnerId: map['winner_id'] as int?,
      status: map['status'] == 'completed'
          ? MatchStatus.completed
          : MatchStatus.inProgress,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
}

class PlayerStats {
  final int playerId;
  final String playerName;
  final int wins;
  final int losses;
  final int ties;
  final double winRate;
  final int currentStreak;
  final int longestWinStreak;

  PlayerStats({
    required this.playerId,
    required this.playerName,
    required this.wins,
    required this.losses,
    required this.ties,
    required this.winRate,
    required this.currentStreak,
    required this.longestWinStreak,
  });
}

extension TournamentCopy on Tournament {
  Tournament copyWith({
    int? id,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    bool? isArchived,
    DateTime? createdAt,
  }) {
    return Tournament(
      id: id ?? this.id,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

extension PlayerCopy on Player {
  Player copyWith({
    int? id,
    int? tournamentId,
    String? name,
    DateTime? createdAt,
  }) {
    return Player(
      id: id ?? this.id,
      tournamentId: tournamentId ?? this.tournamentId,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

extension MatchCopy on Match {
  Match copyWith({
    int? id,
    int? tournamentId,
    String? gameName,
    int? player1Id,
    int? player2Id,
    int? winnerId,
    MatchStatus? status,
    DateTime? timestamp,
  }) {
    return Match(
      id: id ?? this.id,
      tournamentId: tournamentId ?? this.tournamentId,
      gameName: gameName ?? this.gameName,
      player1Id: player1Id ?? this.player1Id,
      player2Id: player2Id ?? this.player2Id,
      winnerId: winnerId ?? this.winnerId,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
