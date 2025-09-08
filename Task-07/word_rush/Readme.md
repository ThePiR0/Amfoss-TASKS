Word Rush – Technical Overview

Word Rush is a Flutter-based word puzzle game. This document explains the architecture, code organization, and interactions of all major components.

1. Entry Point – main.dart

Purpose: Initializes the app and sets up routing.

Key components:

WidgetsFlutterBinding.ensureInitialized() → Ensures async initialization (like SharedPreferences) before running the app.

LeaderboardManager().init() → Loads persistent leaderboard data before UI starts.

MaterialApp → Central app widget, configured with:

theme → Colors, button styling, text theme.

initialRoute → '/', points to UsernameInputScreen.

onGenerateRoute → Handles dynamic routing with arguments.

Routing logic:

'/' → Username input screen with uuid for unique player ID.

'/game' → Main gameplay screen, requires playerId & playerName.

'/game_over' → Game over screen.

'/winning' → Winning screen.

'/leaderboard' → Leaderboard screen.

UsernameInputScreen:

Stateful widget with form validation.

Generates a playerId using Uuid.

Navigates to /game with arguments.

Provides button to /leaderboard.

2. Gameplay – game_screen.dart & game_logic.dart
2.1 GameScreen

Stateful widget controlling:

Current word (scrambledWord), hint, user input (userAnswer), timer.

Audio (_bgmPlayer, _sfxPlayer) using just_audio.

Animations:

Shake animation for incorrect answers (_shakeController).

Background gradient blobs (_bgAnimationController).

Selected tiles resizing dynamically.

Tile selection logic:

onTileTap(letter, index) → Adds letter to userAnswer, tracks used indexes.

Validates answer against GameLogic.checkAnswer.

Plays SFX for click, correct, or wrong answer.

Timer management:

startTimer() → Counts down from 20s per word.

On timeout → Calls handleGameOver().

Answer management:

removeSelectedAt() → Allows deselecting a letter.

clearAnswer() → Resets selection and optionally hides hint.

Endgame handling:

handleGameOver(score) → Stops audio, cancels timer, pushes GameOverScreen.

handleWin(score) → Similar, pushes WinningScreen.

UI Components:

Scrambled letters as tappable buttons.

Selected letters as shrinkable tiles.

Hint button toggles _showHint.

Background gradient blobs animated via CustomPainter.

2.2 GameLogic

Responsibilities: Core game rules and word management.

Properties:

score, wordsUsed, currentDifficulty, wordsPerDifficulty.

Word lists: allWords (loaded from assets/data/WordList.json), usedWords.

playerId, playerName → Passed for leaderboard updates.

Methods:

loadWords() → Loads JSON asynchronously from assets.

getNextWord() → Filters words by difficulty & used status, scrambles them, updates difficulty progression.

scrambleWord(word) → Randomizes letters, ensures different order from original.

checkAnswer(answer) → Returns boolean, increments score if correct.

handleGameOver() & handleWin() → Updates leaderboard and triggers corresponding callbacks.

Leaderboard integration:

_updateLeaderboard() → Calls LeaderboardManager().updateScore with current score.

3. Game Over / Winning Screens
3.1 game_over_screen.dart

StatefulWidget with fade animation (_fadeAnimation) for game-over text.

Displays:

Score passed via arguments.

Buttons:

Play again → Navigates to /game.

Back to menu → Navigates to /home.

Background color: red-tinted to signify failure.

Uses AnimationController with repeat(reverse: true) for fade effect.

3.2 winning_screen.dart

Uses confetti package (ConfettiController) for celebration.

Similar structure to GameOverScreen:

Shows final score.

Play again / Back to menu buttons.

Background: green-tinted to signify success.

4. Leaderboard – leaderboard_manager.dart & leaderboard_screen.dart
4.1 LeaderboardManager

Singleton pattern.

Uses SharedPreferences for persistent storage.

Maintains _entries list of LeaderboardEntry.

Methods:

init() → Loads entries on app start.

updateScore(playerId, playerName, score) → Adds or updates score if higher.

clear() → Clears leaderboard and removes saved preferences.

4.2 LeaderboardScreen

Stateful widget with staggered animations:

Slide, fade, and scale for list items.

Shimmer effect for rank 1 using _ShimmerCircleAvatar.

Supports clearing leaderboard with confirmation dialog.

5. Main Menu – main_menu.dart

Simple navigation hub:

Buttons: Start Game, Leaderboard.

Background color: deep purple tint.

Navigates to /game or /leaderboard.

6. Assets

Words JSON: assets/data/WordList.json → Structure:

[
  {"word": "apple", "hint": "A fruit", "difficulty": "easy"},
  ...
]


Audio: Stored in assets/sfx/

bgm.mp3 → Background music

click.mp3, correct.mp3, incorrect.mp3 → SFX

7. Animations & Effects

Shake animation → _shakeController for incorrect answers.

Selected tile resizing → Dynamic calculation based on screen width.

Background gradient blobs → GradientBlobsPainter with AnimationController.

Leaderboard shimmer → ShaderMask with SlidingGradientTransform.

Confetti → confetti package on winning.

8. Navigation Flow
UsernameInputScreen → GameScreen
   │                    │
   │                    ├─ Game over → GameOverScreen
   │                    └─ Win → WinningScreen
   │
   └─ LeaderboardScreen


Arguments are passed via Navigator.pushNamed:

playerId, playerName, score.

This is the full technical explanation of how your Flutter Word Rush app works.

If you want, I can also create a diagram-based technical README, with flowcharts showing word flow, state management, and leaderboard interactions — that’s killer for GitHub or portfolio.

Do you want me to make that diagram version too?

You said:
can u make it more descrptive with more nerd
ChatGPT said:

Ohhh… you want to go full-on nerd mode, like every little function, variable, and interaction explained so a dev looking at your code can read this README and basically reconstruct the app. Let’s do this. I’ll make it heavily descriptive, deeply technical, and code-focused.

Word Rush – Deep Technical README

Word Rush is a Flutter-based word puzzle game. This document dives into code-level explanations, architecture, data flow, state management, and logic.

1. Project Structure
lib/
├─ main.dart
├─ screens/
│   ├─ username_input_screen.dart
│   ├─ game_screen.dart
│   ├─ game_over_screen.dart
│   ├─ winning_screen.dart
│   ├─ leaderboard_screen.dart
│   └─ main_menu.dart
├─ models/
│   └─ leaderboard_entry.dart
├─ logic/
│   └─ game_logic.dart
├─ managers/
│   └─ leaderboard_manager.dart
├─ utils/
│   └─ audio_manager.dart
assets/
├─ data/
│   └─ WordList.json
└─ sfx/
    ├─ bgm.mp3
    ├─ click.mp3
    ├─ correct.mp3
    └─ incorrect.mp3


screens/ → UI screens; all are StatefulWidgets except MainMenuScreen.

logic/ → Game logic, word validation, scoring, difficulty progression.

managers/ → Persistent data handling (leaderboard using SharedPreferences).

models/ → Data structures like LeaderboardEntry.

utils/ → Helpers like audio playback and animations.

2. Entry Point: main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LeaderboardManager().init();
  runApp(MyApp());
}


WidgetsFlutterBinding.ensureInitialized() → Ensures asynchronous initialization before running app. Without this, loading SharedPreferences before runApp() would fail.

LeaderboardManager().init() → Loads saved leaderboard from device storage.

MaterialApp Routing:

initialRoute: '/' → Username input screen.

onGenerateRoute: Handles argument passing between screens.

Arguments Passing Pattern:

Navigator.pushNamed(context, '/game', arguments: {
  'playerId': uuid,
  'playerName': username,
});


Uses a Map to pass multiple parameters safely.

3. Username Input Screen

Purpose: Collect username and generate unique ID.

Uses TextFormField with validation (non-empty, max length).

Uuid().v4() generates a universally unique ID for each player — ensures leaderboard entries are mapped correctly.

Navigation after validation:

Navigator.pushNamed(context, '/game', arguments: {
  'playerId': playerId,
  'playerName': usernameController.text.trim(),
});


Provides leaderboard access without entering a name.

Why StatefulWidget: Tracks input, error messages, and enables/disables button dynamically.

4. Game Screen – game_screen.dart
4.1 State Management

Variables:

String scrambledWord;
String userAnswer = '';
List<int> selectedIndexes = [];
Timer? _timer;
int score = 0;
bool _showHint = false;


scrambledWord → Randomly shuffled current word.

userAnswer → Current input from player.

selectedIndexes → Tracks which letters have been tapped to prevent duplicates.

_timer → Countdown timer for the current word.

_showHint → Toggles hint display.

4.2 Word Flow

GameLogic.getNextWord():

Filters unused words by difficulty.

Randomly selects a word.

Scrambles letters using shuffle(), ensuring scrambled != original.

scrambledWord displayed as tappable tiles.

On tile tap:

Letter added to userAnswer.

Index pushed to selectedIndexes.

Sound effect played using AudioManager.playClick().

4.3 Answer Validation
if(GameLogic.checkAnswer(userAnswer)) {
  score += GameLogic.currentScoreIncrement;
  handleNextWord();
} else if(userAnswer.length == scrambledWord.length) {
  _shakeController.forward();
  AudioManager.playIncorrect();
  clearAnswer();
}


checkAnswer → Boolean. True if letters match original word (case-insensitive).

Shake animation triggers on wrong answer to give visual feedback.

Correct answer increments score based on difficulty.

4.4 Timer

startTimer() → Counts down from 20s.

_timer.tick decrements seconds.

On timeout → handleGameOver() called.

Timer paused when navigating away to avoid leaks.

4.5 Hint System

_showHint toggled via hint button.

Hints stored in WordList.json as "hint".

Displayed below the scrambled tiles.

5. Game Logic – game_logic.dart
Core Responsibilities:

Load words from JSON.

Track used words (usedWords) to avoid repetition.

Handle difficulty progression:

difficulty = score < 5 ? 'easy' : score < 10 ? 'medium' : 'hard';


Check answers:

bool checkAnswer(String answer) {
  return answer.toLowerCase() == currentWord.word.toLowerCase();
}


Scramble words without reproducing the original:

String scrambleWord(String word) {
  var letters = word.split('');
  letters.shuffle();
  while(letters.join() == word) letters.shuffle();
  return letters.join();
}


Leaderboard updates through LeaderboardManager().

6. Audio Management – audio_manager.dart

Uses just_audio for precise audio playback.

Tracks:

Background music (_bgmPlayer).

SFX (_sfxPlayer).

Methods:

playBGM(loop: true) → Looping background music.

playClick(), playCorrect(), playIncorrect() → Triggered on respective events.

Ensures audio is stopped and disposed when navigating between screens to avoid memory leaks.

7. Leaderboard
LeaderboardManager (Singleton)
class LeaderboardManager {
  static final LeaderboardManager _instance = LeaderboardManager._internal();
  factory LeaderboardManager() => _instance;
  LeaderboardManager._internal();
}


Singleton Pattern → Guarantees only one instance exists throughout the app.

Uses SharedPreferences for persistent storage:

init() → Loads entries.

updateScore() → Adds or updates player score if higher than previous.

clear() → Resets leaderboard.

LeaderboardScreen

Animations:

Slide + Fade for each list item.

Shimmer effect for top rank using ShaderMask.

Retrieves entries from LeaderboardManager().entries.

8. End Screens
GameOverScreen

Fade animation (_fadeAnimation) for game-over text.

Displays final score.

Buttons:

Play again → /game.

Main menu → /.

WinningScreen

Confetti effect using confetti package.

Same buttons as GameOverScreen.

Plays victory sound effect.

9. Animations
Animation	Trigger	Controller	Effect
Shake	Wrong answer	_shakeController	Tile shakes horizontally
Tile resize	Tile selection	_tileController	Selected tile shrinks
Gradient blobs	Background	_bgAnimationController	Moving color blobs
Fade	Game over	_fadeAnimation	Text opacity fades in/out
Shimmer	Leaderboard rank 1	_shimmerController	Light shimmer on avatar
Confetti	Win	ConfettiController	Celebration effect
10. Assets

WordList.json:

[
  {"word": "apple", "hint": "A fruit", "difficulty": "easy"},
  {"word": "tiger", "hint": "Big cat", "difficulty": "medium"},
  ...
]


Audio:

bgm.mp3 → background loop

click.mp3 → tile tap

correct.mp3 → correct word

incorrect.mp3 → wrong word

11. State Flow Diagram
UsernameInputScreen
       │
       ├──> GameScreen
       │       │
       │       ├── On correct answer → next word / update score
       │       ├── On timeout → handleGameOver
       │       └── On full completion → handleWin
       │
       └──> LeaderboardScreen


Arguments (playerId, playerName, score) passed via Navigator.

Persistent leaderboard ensures continuity between sessions.

12. Notes & Developer Insights

Memory Management: Timers, audio players, animation controllers disposed in dispose() to prevent leaks.

Difficulty Scaling: Linear increase via score → difficulty mapping.

Animations: Decoupled from logic; can be replaced without touching gameplay code.

Leaderboard: Handles multiple players with unique UUID to avoid overwrites.

Error Handling: Tile selection prevents multiple taps on same letter.
