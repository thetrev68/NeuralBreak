import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';

import 'package:neural_break/game/neural_break_game.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock to portrait mode for consistency
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const NeuralBreakApp());
}

class NeuralBreakApp extends StatelessWidget {
  const NeuralBreakApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neural Break',
      theme: ThemeData.dark().copyWith(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const GameScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final NeuralBreakGame game;

  @override
  void initState() {
    super.initState();
    game = NeuralBreakGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget<NeuralBreakGame>.controlled(
        gameFactory: () => game,
      ),
    );
  }
}