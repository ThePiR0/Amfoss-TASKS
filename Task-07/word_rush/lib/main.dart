import 'package:flutter/material.dart';
import 'screens/game_screen.dart';
import 'screens/game_over_screen.dart';
import 'screens/winning_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'utils/leaderboard_manager.dart';
import 'package:uuid/uuid.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LeaderboardManager().init();
  runApp(WordRushApp());
}

class WordRushApp extends StatelessWidget {
  final Uuid uuid = Uuid();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Word Rush',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.deepPurple[50],
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 18, color: Colors.black87),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
              builder: (context) => UsernameInputScreen(uuid: uuid),
            );
          case '/game':
            final args = settings.arguments as Map<String, dynamic>?;
            if (args == null || args['playerId'] == null || args['playerName'] == null) {
              return MaterialPageRoute(
                builder: (context) => UsernameInputScreen(uuid: uuid),
              );
            }
            return MaterialPageRoute(
              builder: (context) => GameScreen(
                playerId: args['playerId'],
                playerName: args['playerName'],
              ),
            );
          case '/game_over':
            return MaterialPageRoute(
              builder: (context) => GameOverScreen(),
              settings: settings,
            );
          case '/winning':
            return MaterialPageRoute(
              builder: (context) => WinningScreen(),
              settings: settings,
            );
          case '/leaderboard':
            return MaterialPageRoute(
              builder: (context) => const LeaderboardScreen(),
            );
          default:
            return MaterialPageRoute(
              builder: (context) => UsernameInputScreen(uuid: uuid),
            );
        }
      },
    );
  }
}

class UsernameInputScreen extends StatefulWidget {
  final Uuid uuid;
  const UsernameInputScreen({Key? key, required this.uuid}) : super(key: key);

  @override
  _UsernameInputScreenState createState() => _UsernameInputScreenState();
}

class _UsernameInputScreenState extends State<UsernameInputScreen> {
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _startGame() {
    if (_formKey.currentState!.validate()) {
      final playerId = widget.uuid.v4();
      final playerName = _nameController.text.trim();

      Navigator.pushNamed(
        context,
        '/game',
        arguments: {'playerId': playerId, 'playerName': playerName},
      );
    }
  }

  void _goToLeaderboard() {
    Navigator.pushNamed(context, '/leaderboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Color.fromARGB(255, 16, 133, 60)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SingleChildScrollView(
                    child: Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.flash_on, color: Colors.deepPurple, size: 60),
                            const SizedBox(height: 10),
                            const Text(
                              "🚀 Welcome to Word Rush!",
                              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Enter your username to start playing.\nLet’s see if you’ve got the word power!",
                              style: TextStyle(fontSize: 18, color: Colors.black54),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 30),
                            Form(
                              key: _formKey,
                              child: TextFormField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  labelText: 'Username',
                                  prefixIcon: const Icon(Icons.person, color: Colors.deepPurple),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Please enter a username';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 30),
                            ElevatedButton.icon(
                              onPressed: _startGame,
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Start Game'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                                backgroundColor: const Color.fromARGB(255, 103, 216, 10),
                              ),
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: _goToLeaderboard,
                              icon: const Icon(Icons.leaderboard),
                              label: const Text('View Leaderboard'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                                side: const BorderSide(color: Colors.deepPurple),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "© 2025 Word Rush",
                style: const TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
