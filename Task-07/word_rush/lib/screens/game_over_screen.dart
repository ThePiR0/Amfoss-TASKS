import 'package:flutter/material.dart';

class GameOverScreen extends StatefulWidget {
  const GameOverScreen({Key? key}) : super(key: key);

  @override
  _GameOverScreenState createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 1, end: 0.6).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
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
      backgroundColor: const Color.fromARGB(214, 226, 0, 34),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('💀 Game Over 💀',
                  style: TextStyle(fontSize: 32, color: const Color.fromARGB(242, 255, 160, 50), fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              Text('Your Score: $score', style: TextStyle(fontSize: 24, color: const Color.fromARGB(241, 50, 255, 193), fontWeight: FontWeight.bold)),
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
      ),
    );
  }
}
