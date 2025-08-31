import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import '../utils/game_logic.dart';

class GameScreen extends StatefulWidget {
  final String playerId;
  final String playerName;

  GameScreen({required this.playerId, required this.playerName});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late AudioPlayer _bgmPlayer;
  late AudioPlayer _sfxPlayer;

  late GameLogic gameLogic;
  Timer? timer;
  int timeLeft = 20;
  String scrambledWord = '';
  String hint = '';
  String userAnswer = '';
  bool isLoading = true;
  bool _gameOverHandled = false;
  bool _winHandled = false;
  String _currentHint = "";
  bool _showHint = false;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  Set<int> usedTileIndexes = {};

  List<int> selectedIndexes = [];

  late AnimationController _bgAnimationController;

  bool _isShaking = false; // shake guard

  @override
  void initState() {
    super.initState();
    _initAudio();

    _shakeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 8)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);

    _shakeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (!mounted) return;
        setState(() {
          userAnswer = '';
          usedTileIndexes.clear();
          selectedIndexes.clear();
          _isShaking = false;
        });
      }
    });

    _bgAnimationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 10),
    )..repeat(reverse: true);

    gameLogic = GameLogic(
      onGameOver: handleGameOver,
      onWin: handleWin,
      playerId: widget.playerId,
      playerName: widget.playerName,
    );

    gameLogic.loadWords().then((_) {
      startNewWord();
      startTimer();
      if (!mounted) return;
      setState(() => isLoading = false);
    });
  }

  Future<void> _initAudio() async {
    _bgmPlayer = AudioPlayer();
    _sfxPlayer = AudioPlayer();

    try {
      final session = await AudioSession.instance;
      await session.configure(AudioSessionConfiguration.music());

      session.becomingNoisyEventStream.listen((_) {
        _bgmPlayer.pause();
      });
    } catch (e) {
      // ignore if audio session config fails on some platforms
    }

    try {
      await _bgmPlayer.setAsset('assets/sfx/bgm.mp3');
      _bgmPlayer.setLoopMode(LoopMode.one);
      await _bgmPlayer.play();
    } catch (e) {
      print('Error initializing BGM: $e');
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    _bgmPlayer.dispose();
    _sfxPlayer.dispose();
    _shakeController.dispose();
    _bgAnimationController.dispose();
    super.dispose();
  }

  void startNewWord() {
    final wordData = gameLogic.getNextWord();
    scrambledWord = wordData['scrambled'] ?? '';
    hint = wordData['hint'] ?? '';
    // store current hint in internal var and hide it by default
    _currentHint = hint;
    _showHint = false;

    userAnswer = '';
    usedTileIndexes.clear();
    selectedIndexes.clear();
    if (!mounted) return;
    setState(() {});
  }

  void startTimer() {
    timeLeft = 20;
    timer?.cancel();
    timer = Timer.periodic(Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        timeLeft--;
        if (timeLeft <= 0) {
          t.cancel();
          handleGameOver(gameLogic.score);
        }
      });
    });
  }

  Future<void> playSfx(String assetPath, {double volume = 1.0}) async {
    try {
      await _sfxPlayer.setAsset(assetPath);
      await _sfxPlayer.setVolume(volume);
      await _sfxPlayer.play();
    } catch (e) {
      print('Error playing SFX $assetPath: $e');
    }
  }

  void onTileTap(String letter, int index) async {
    if (usedTileIndexes.contains(index)) return; // already used
    if (userAnswer.length >= scrambledWord.length) return; // full
    if (_isShaking) return; // prevent input while shake animation active

    await playSfx('assets/sfx/click.mp3', volume: 0.6);

    if (!mounted) return;
    setState(() {
      userAnswer += letter;
      usedTileIndexes.add(index);
      selectedIndexes.add(index);
    });

    // check when full length
    if (userAnswer.length == scrambledWord.length) {
      if (gameLogic.checkAnswer(userAnswer)) {
        await playSfx('assets/sfx/correct.mp3', volume: 0.7);
        timer?.cancel();
        startNewWord();
        startTimer();
      } else {
        _isShaking = true;
        await playSfx('assets/sfx/incorrect.mp3', volume: 1.0);
        _shakeController.forward(from: 0);
      }
    }
  }

  /// Remove a selected tile by its position in the selectedIndexes list.
  void removeSelectedAt(int selectedPos) {
    if (selectedPos < 0 || selectedPos >= selectedIndexes.length) return;
    setState(() {
      final idx = selectedIndexes.removeAt(selectedPos);
      usedTileIndexes.remove(idx);

      // rebuild userAnswer from selectedIndexes to preserve order correctly
      userAnswer = selectedIndexes.map((i) => scrambledWord[i]).join('');
    });
  }

  void clearAnswer() {
    if (!mounted) return;
    setState(() {
      userAnswer = '';
      usedTileIndexes.clear();
      selectedIndexes.clear();
      _showHint = false; // also hide hint if user clears
    });
  }

  Future<void> handleGameOver(int score) async {
    if (_gameOverHandled) return;
    _gameOverHandled = true;

    timer?.cancel();
    _shakeController.stop();
    _shakeController.reset();
    _isShaking = false;

    try {
      await _bgmPlayer.stop();
    } catch (_) {}

    await gameLogic.handleGameOver();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/game_over',
      (route) => false,
      arguments: {'score': score},
    );
  }

  Future<void> handleWin(int score) async {
    if (_winHandled) return;
    _winHandled = true;

    timer?.cancel();
    _shakeController.stop();
    _shakeController.reset();
    _isShaking = false;

    try {
      await _bgmPlayer.stop();
    } catch (_) {}

    await gameLogic.handleWin();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/winning',
      (route) => false,
      arguments: {'score': score},
    );
  }

  void _revealHint() {
    setState(() {
      _showHint = true;
    });
    // optional: play a small sfx if you have one, e.g. 'assets/sfx/hint.mp3'
    // playSfx('assets/sfx/hint.mp3', volume: 0.8);
  }

  /// Build selected-tiles wrap (shrinking based on count) — uses selectedIndexes to get chars from scrambledWord
  Widget _buildSelectedTilesWidget(BoxConstraints constraints) {
    final int n = selectedIndexes.length;
    final double spacing = 8;
    final double availableWidth = constraints.maxWidth;
    final double sideReserve = 24;
    final double usable = max(0, availableWidth - sideReserve);
    double tileSize = n > 0 ? (usable - (n - 1) * spacing) / n : 50;
    tileSize = tileSize.clamp(28.0, 64.0);
    double fontSize = (tileSize * 0.45).clamp(12.0, 28.0);

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: spacing,
      children: selectedIndexes.asMap().entries.map((entry) {
        final int pos = entry.key;
        final int idx = entry.value;
        final String char = (idx >= 0 && idx < scrambledWord.length) ? scrambledWord[idx] : '';
        return GestureDetector(
          onTap: () => removeSelectedAt(pos),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: tileSize,
            height: tileSize,
            margin: EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2,2))],
            ),
            alignment: Alignment.center,
            child: AnimatedDefaultTextStyle(
              duration: Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              child: Text(char),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      body: Stack(
        children: [
          // animated background
          AnimatedBuilder(
            animation: _bgAnimationController,
            builder: (context, child) => CustomPaint(
              painter: GradientBlobsPainter(_bgAnimationController.value),
              child: Container(),
            ),
          ),

          SafeArea(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Info
                  Column(
                    children: [
                      Text('⏳ Time: $timeLeft s', style: TextStyle(fontSize: 20, color: Colors.white)),
                      SizedBox(height: 8),
                      Text('⭐ Score: ${gameLogic.score}', style: TextStyle(fontSize: 20, color: Colors.white)),
                      SizedBox(height: 20),
                      Text(scrambledWord, style: TextStyle(fontSize: 40, letterSpacing: 2, color: Colors.white)),
                      SizedBox(height: 8),
                      // Hint area: only show when requested
                      if (_showHint)
                        Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text('💡 Hint: $_currentHint', style: TextStyle(fontSize: 16, color: Colors.white70)),
                        ),
                    ],
                  ),

                  // Letter Tiles (top)
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(scrambledWord.length, (index) {
                      final letter = scrambledWord[index];
                      final isUsed = usedTileIndexes.contains(index);
                      return isUsed
                          ? SizedBox(width: 50, height: 50)
                          : ElevatedButton(
                              onPressed: () => onTileTap(letter, index),
                              child: Text(letter, style: TextStyle(fontSize: 24, color: Colors.black)),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                backgroundColor: Colors.white,
                                shadowColor: Colors.grey.withOpacity(0.4),
                                elevation: 4,
                              ),
                            );
                    }),
                  ),

                  // Selected tiles + buttons area
                  Column(
                    children: [
                      // Selected tiles first (shrinking)
                      LayoutBuilder(builder: (context, constraints) {
                        return _buildSelectedTilesWidget(constraints);
                      }),

                      const SizedBox(height: 12),

                      // Hint + Clear buttons below
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _revealHint,
                            icon: Icon(Icons.lightbulb),
                            label: Text(_showHint ? 'Hint Shown' : 'Show Hint'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _showHint ? Colors.grey : Colors.deepPurpleAccent.shade700,
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: clearAnswer,
                            child: const Text('Clear'),
                            style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 179, 255, 79)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GradientBlobsPainter extends CustomPainter {
  final double animationValue;
  GradientBlobsPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    final rect = Offset.zero & size;
    final baseGradient = LinearGradient(
      colors: [const Color.fromARGB(255, 31, 208, 252), const Color.fromARGB(255, 28, 13, 58)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    paint.shader = baseGradient.createShader(rect);
    canvas.drawRect(rect, paint);

    final blobPaint = Paint()..color = Colors.purpleAccent.withOpacity(0.3);

    final blob1X = size.width * (0.3 + 0.1 * animationValue);
    final blob1Y = size.height * 0.3;
    canvas.drawCircle(Offset(blob1X, blob1Y), 90, blobPaint);

    final blob2X = size.width * 0.7;
    final blob2Y = size.height * (0.5 + 0.1 * animationValue);
    canvas.drawCircle(Offset(blob2X, blob2Y), 120, blobPaint..color = Colors.pinkAccent.withOpacity(0.25));

    final blob3X = size.width * (0.5 - 0.15 * animationValue);
    final blob3Y = size.height * (0.8 - 0.15 * animationValue);
    canvas.drawCircle(Offset(blob3X, blob3Y), 80, blobPaint..color = const Color.fromARGB(255, 134, 245, 83).withOpacity(0.2));
  }

  @override
  bool shouldRepaint(covariant GradientBlobsPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
