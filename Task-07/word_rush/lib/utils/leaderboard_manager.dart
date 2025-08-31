import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LeaderboardEntry {
  final String playerId;
  final String playerName;
  final int score;

  LeaderboardEntry({
    required this.playerId,
    required this.playerName,
    required this.score,
  });

  Map<String, dynamic> toJson() => {
        'playerId': playerId,
        'playerName': playerName,
        'score': score,
      };

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      playerId: json['playerId'],
      playerName: json['playerName'],
      score: json['score'],
    );
  }
}

class LeaderboardManager {
  static final LeaderboardManager _instance = LeaderboardManager._internal();
  factory LeaderboardManager() => _instance;
  LeaderboardManager._internal();

  static const _storageKey = 'leaderboard_entries';
  List<LeaderboardEntry> _entries = [];

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString != null) {
      final List<dynamic> jsonData = json.decode(jsonString);
      _entries = jsonData
          .map((entryJson) => LeaderboardEntry.fromJson(entryJson))
          .toList();
    }
  }

  List<LeaderboardEntry> get entries => List.unmodifiable(_entries);

  Future<void> updateScore(
      String playerId, String playerName, int newScore) async {
    final index = _entries.indexWhere((e) => e.playerId == playerId);
    if (index == -1) {
      // New player, add
      _entries.add(LeaderboardEntry(
          playerId: playerId, playerName: playerName, score: newScore));
    } else {
      // Existing player, update if newScore is higher
      if (newScore > _entries[index].score) {
        _entries[index] = LeaderboardEntry(
            playerId: playerId, playerName: playerName, score: newScore);
      }
    }
    // Sort descending by score
    _entries.sort((a, b) => b.score.compareTo(a.score));

    // Persist updated leaderboard
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString =
        json.encode(_entries.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }

  void clear() {
    _entries.clear();
    SharedPreferences.getInstance()
        .then((prefs) => prefs.remove(_storageKey));
  }
}
