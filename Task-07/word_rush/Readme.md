# Word Rush – Technical Overview

Word Rush is a Flutter-based word puzzle game. This document explains the architecture, code organization, and interactions of all major components.

---

## 1. Entry Point – `main.dart`

### Purpose
Initializes the app and sets up routing.

### Key components

- `WidgetsFlutterBinding.ensureInitialized()`  
  Ensures async initialization (like SharedPreferences) before running the app.

- `LeaderboardManager().init()`  
  Loads persistent leaderboard data before UI starts.

- `MaterialApp`  
  Central app widget, configured with:
  - `theme` → Colors, button styling, text theme.
  - `initialRoute` → `'/'`, points to `UsernameInputScreen`.
  - `onGenerateRoute` → Handles dynamic routing with arguments.

### Routing logic

| Route         | Description                    | Arguments                   |
|---------------|-------------------------------|-----------------------------|
| `'/'`         | Username input screen          | `uuid` for unique player ID |
| `'/game'`     | Main gameplay screen           | `playerId`, `playerName`    |
| `'/game_over'`| Game over screen               | Score                       |
| `'/winning'`  | Winning screen                 | Score                       |
| `'/leaderboard'`| Leaderboard screen           | None                        |

### UsernameInputScreen

- Stateful widget with form validation.
- Generates a `playerId` using `Uuid`.
- Navigates to `/game` with arguments.
- Provides button to navigate to `/leaderboard`.

---

## 2. Gameplay – `game_screen.dart` & `game_logic.dart`

### 2.1 GameScreen

- Stateful widget controlling:
  - Current word (`scrambledWord`), hint, user input (`userAnswer`), timer.
- Audio players (`_bgmPlayer`, `_sfxPlayer`) using `just_audio`.
- Animations:
  - Shake animation for incorrect answers (`_shakeController`).
  - Background gradient blobs (`_bgAnimationController`).
  - Selected tiles resizing dynamically.
- Tile selection logic:
  - `onTileTap(letter, index)` → Adds letter to `userAnswer`, tracks used indexes.
  - Validates answer against `GameLogic.checkAnswer`.
  - Plays SFX for click, correct, or wrong answer.
- Timer management:
  - `startTimer()` → Counts down from 20s per word.
  - On timeout → Calls `handleGameOver()`.
- Answer management:
  - `removeSelectedAt()` → Allows deselecting a letter.
  - `clearAnswer()` → Resets selection and optionally hides hint.
- Endgame handling:
  - `handleGameOver(score)` → Stops audio, cancels timer, pushes `GameOverScreen`.
  - `handleWin(score)` → Similar, pushes `WinningScreen`.
- UI Components:
  - Scrambled letters as tappable buttons.
  - Selected letters as shrinkable tiles.
  - Hint button toggles `_showHint`.
  - Background gradient blobs animated via `CustomPainter`.

### 2.2 GameLogic

- Responsibilities: Core game rules and word management.
- Properties:
  - `score`, `wordsUsed`, `currentDifficulty`, `wordsPerDifficulty`.
  - Word lists: `allWords` (loaded from `assets/data/WordList.json`), `usedWords`.
  - `playerId`, `playerName` → Passed for leaderboard updates.
- Methods:
  - `loadWords()` → Loads JSON asynchronously from assets.
  - `getNextWord()` → Filters words by difficulty & used status, scrambles them, updates difficulty progression.
  - `scrambleWord(word)` → Randomizes letters, ensures different order from original.
  - `checkAnswer(answer)` → Returns boolean, increments score if correct.
  - `handleGameOver()` & `handleWin()` → Updates leaderboard and triggers callbacks.
- Leaderboard integration:
  - `_updateLeaderboard()` → Calls `LeaderboardManager().updateScore` with current score.

---

## 3. Game Over / Winning Screens

### 3.1 `game_over_screen.dart`

- StatefulWidget with fade animation (`_fadeAnimation`) for game-over text.
- Displays:
  - Score passed via arguments.
- Buttons:
  - Play again → Navigates to `/game`.
  - Back to menu → Navigates to `/home`.
- Background color: red-tinted to signify failure.
- Uses `AnimationController` with `repeat(reverse: true)` for fade effect.

### 3.2 `winning_screen.dart`

- Uses `confetti` package (`ConfettiController`) for celebration.
- Similar structure to `GameOverScreen`:
  - Shows final score.
  - Play again / Back to menu buttons.
  - Background: green-tinted to signify success.

---

## 4. Leaderboard – `leaderboard_manager.dart` & `leaderboard_screen.dart`

### 4.1 LeaderboardManager

- Singleton pattern.
- Uses `SharedPreferences` for persistent storage.
- Maintains `_entries` list of `LeaderboardEntry`.
- Methods:
  - `init()` → Loads entries on app start.
  - `updateScore(playerId, playerName, score)` → Adds or updates score if higher.
  - `clear()` → Clears leaderboard and removes saved preferences.

### 4.2 LeaderboardScreen

- Stateful widget with staggered animations:
  - Slide, fade, and scale for list items.
  - Shimmer effect for rank 1 using `_ShimmerCircleAvatar`.
- Supports clearing leaderboard with confirmation dialog.

---

## 5. Main Menu – `main_menu.dart`

- Simple navigation hub:
  - Buttons: Start Game, Leaderboard.
- Background color: deep purple tint.
- Navigates to `/game` or `/leaderboard`.

---

## 6. Assets

- Words JSON: `assets/data/WordList.json` → Structure:

```json
[
  {"word": "apple", "hint": "A fruit", "difficulty": "easy"},
  ...
]
