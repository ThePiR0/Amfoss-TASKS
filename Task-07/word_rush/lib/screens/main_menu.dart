import 'package:flutter/material.dart';

class MainMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[100],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Word Rush',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/game');
              },
              child: Text('Start Game'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/leaderboard');
              },
              child: Text('Leaderboard'),
            ),
          ],
        ),
      ),
    );
  }
}
