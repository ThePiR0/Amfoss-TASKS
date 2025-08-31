import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class WinningScreen extends StatefulWidget {
  const WinningScreen({Key? key}) : super(key: key);

  @override
  _WinningScreenState createState() => _WinningScreenState();
}

class _WinningScreenState extends State<WinningScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 3));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _confettiController.play();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    int score = 0;
    if (args is Map<String, dynamic> && args['score'] is int) {
      score = args['score'];
    }

    return Scaffold(
      backgroundColor: Colors.green[50],
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              emissionFrequency: 0.05,
              numberOfParticles: 15,
              colors: [Colors.green, Colors.blue, Colors.pink, Colors.orange],
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🎉 You Won! 🎉',
                    style: TextStyle(fontSize: 30, color: Colors.green, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                Text('Final Score: $score', style: TextStyle(fontSize: 20)),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(context, '/game', (route) => false);
                  },
                  child: Text('Play Again'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                  },
                  child: Text('Back to Menu'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
