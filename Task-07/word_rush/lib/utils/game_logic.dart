import 'dart:math';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'leaderboard_manager.dart';

class GameLogic {
  int score = 0;
  int wordsUsed = 0;
  String currentDifficulty = 'easy';
  final int wordsPerDifficulty = 10;

  List<Map<String, dynamic>> allWords = [];
  List<Map<String, dynamic>> usedWords = [];

  final String playerId;
  final String playerName;
  

  final Function(int score) onGameOver;  // <-- pass score now
  final Function(int score) onWin;

  GameLogic({
    required this.onGameOver,
    required this.onWin,
    required this.playerId,
    required this.playerName,
  });

  Future<void> loadWords() async {
    String data = await rootBundle.loadString('assets/data/WordList.json');
    List<dynamic> jsonResult = json.decode(data);
    allWords = jsonResult.map((e) => e as Map<String, dynamic>).toList();
  }

  Map<String, String> getNextWord() {
    List<Map<String, dynamic>> filtered = allWords
        .where((w) =>
            w['difficulty'] == currentDifficulty && !usedWords.contains(w))
        .toList();

    if (filtered.isEmpty) {
      if (currentDifficulty == 'easy') {
        currentDifficulty = 'medium';
        return getNextWord();
      } else if (currentDifficulty == 'medium') {
        currentDifficulty = 'hard';
        return getNextWord();
      } else {
        // Game won, notify with score
        onWin(score);
        return {};
      }
    }

    var wordData = filtered[Random().nextInt(filtered.length)];
    usedWords.add(wordData);
    wordsUsed++;

    if (wordsUsed % wordsPerDifficulty == 0) {
      if (currentDifficulty == 'easy') currentDifficulty = 'medium';
      else if (currentDifficulty == 'medium') currentDifficulty = 'hard';
    }

    String scrambled = scrambleWord(wordData['word']);

    return {
      'scrambled': scrambled,
      'hint': wordData['hint'],
      'word': wordData['word'],
    };
  }

  bool checkAnswer(String answer) {
    var correctWord = usedWords.last['word'];
    if (answer == correctWord) {
      score += 10;
      return true;
    }
    return false;
  }

  String scrambleWord(String word) {
    List<String> chars = word.split('');
    chars.shuffle();
    if (chars.join() == word && word.length > 1) {
      chars.shuffle();
    }
    return chars.join();
  }

  Future<void> handleGameOver() async {
    await _updateLeaderboard();
    onGameOver(score);
  }

  Future<void> handleWin() async {
    await _updateLeaderboard();
    onWin(score);
  }

  Future<void> _updateLeaderboard() async {
    await LeaderboardManager().updateScore(
      playerId,
      playerName,
      score,
    );
  }
}
