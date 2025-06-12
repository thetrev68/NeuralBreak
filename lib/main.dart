import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neural_break/game/neural_break_game.dart';
import 'package:neural_break/game/managers/score_manager.dart';
import 'package:neural_break/game/managers/life_manager.dart';
import 'package:neural_break/game/managers/ui_manager.dart';
import 'package:neural_break/screens/game_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const NeuralBreakApp());
}

class NeuralBreakApp extends StatelessWidget {
  const NeuralBreakApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize Flame game & UIManager here because we need both for GameScreen
    return MaterialApp(
      title: 'Neural Break',
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(primary: Colors.blue),
      ),
      home: const RootWidget(), // We delegate to a RootWidget to setup game
      debugShowCheckedModeBanner: false,
    );
  }
}

class RootWidget extends StatefulWidget {
  const RootWidget({super.key});

  @override
  State<RootWidget> createState() => _RootWidgetState();
}

class _RootWidgetState extends State<RootWidget>
    with SingleTickerProviderStateMixin {
  late final NeuralBreakGame game;
  late final ScoreManager scoreManager;
  late final LifeManager lifeManager;

  UIManager? uiManager;

  @override
  void initState() {
    super.initState();

    scoreManager = ScoreManager(levelUpThreshold: 100);
    lifeManager = LifeManager(initialLives: 3);

    game = NeuralBreakGame(tickerProvider: this);

    // Wait until game.onLoad() is complete and player is ready
    game.loaded.then((_) {
      setState(() {
        uiManager = UIManager(
          scoreManager: scoreManager,
          lifeManager: lifeManager,
          player: game.player,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (uiManager == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return GameScreen(game: game, uiManager: uiManager!);
  }
}
