// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart'; // Import for kDebugMode

import 'package:neural_break/features/gameplay/presentation/pages/neural_break_game.dart';
import 'package:neural_break/widgets/avatars/avatar_display_widget.dart';
import 'package:neural_break/core/constants/game_constants.dart';

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
    return MaterialApp(
      title: 'Neural Break',
      theme: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(primary: Colors.blue),
      ),
      home: const RootWidget(),
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
  NeuralBreakGame? game;
  bool _isGameLayoutReady =
      false; // Still needed to conditionally show overlays

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      print('RootWidgetState: initState called (STEP 1: Attempting Game Init)');
    }

    try {
      game = NeuralBreakGame(tickerProvider: this);
      if (kDebugMode) {
        print(
            'RootWidgetState: NeuralBreakGame instance created (STEP 2: Instance OK)');
      }

      // Listen for when the game's layout is ready (after its onLoad completes)
      game!.loaded.then((_) {
        if (mounted) {
          // Check if the widget is still in the tree
          setState(() {
            _isGameLayoutReady = true; // Mark game layout as ready
            if (kDebugMode) {
              print(
                  'RootWidgetState: Game layout is ready (game.size available).');
            }
          });
        }
      });
    } catch (e, s) {
      if (kDebugMode) {
        print(
            'RootWidgetState: ERROR creating NeuralBreakGame instance (STEP 2 FAILED): $e');
        print('Stack Trace: $s');
      }
    }
  }

  @override
  void dispose() {
    game?.pauseEngine();
    game?.onRemove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (game == null) {
      if (kDebugMode) {
        print(
            'RootWidgetState: Building CircularProgressIndicator (Game instance is null)');
      }
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (kDebugMode) {
      print('RootWidgetState: Building GameWidget and potentially overlays.');
    }

    // Calculate positions only if layout is ready.
    // Initialize with safe defaults or null.
    double playerGameY = 0;
    double avatarWidgetBottomPadding = 0;
    double avatarWidgetLeft = 0;

    // These will be relative to the game.size, not screen size for text overlays
    double scoreTextTop = 0;
    double scoreTextLeft = 0;
    double livesTextTop = 0;
    double livesTextRight = 0;
    double levelTextTop = 0;
    double levelTextLeft = 0;

    // Check if game.size is available before calculating positions for positioned widgets
    if (_isGameLayoutReady && game!.hasLayout) {
      playerGameY = getGroundY(game!.size.y, playerSize);
      avatarWidgetBottomPadding =
          (game!.size.y - playerGameY) - (playerSize / 2);
      avatarWidgetLeft = (game!.size.x / 2) -
          (playerSize * 0.8 / 2); // Center player based on its actual width

      // TEXT OVERLAY POSITIONS:
      // Scale text positions relative to game.size
      final textPadding =
          game!.size.y * 0.03; // 3% of game height (y) for padding
      final horizontalMargin =
          game!.size.x * 0.05; // 5% of game width (x) for margin

      scoreTextTop = textPadding;
      scoreTextLeft = horizontalMargin;

      livesTextTop = textPadding;
      livesTextRight = horizontalMargin;

      levelTextTop = textPadding;
      levelTextLeft = (game!.size.x / 2) -
          (50); // Approximate center, will need fine-tuning font size
    }

    return Scaffold(
      body: Stack(
        children: [
          // Layer 1: The Flame Game - ALWAYS PRESENT
          Positioned.fill(
            child: GameWidget(game: game!),
          ),

          // Layer 2: Circular Progress Indicator OVERLAY (if layout is NOT ready)
          if (!_isGameLayoutReady)
            const Positioned.fill(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),

          // Layer 3: The Avatar Display Widget (only if layout is ready)
          if (_isGameLayoutReady)
            Positioned(
              bottom: avatarWidgetBottomPadding,
              left: avatarWidgetLeft,
              child: AvatarDisplayWidget(
                uiManager: game!.uiManager,
                avatarSize: playerSize, // This is 40.0
              ),
            ),
          // Score Text Widget (only if layout is ready)
          if (_isGameLayoutReady)
            Positioned(
              top: scoreTextTop,
              left: scoreTextLeft,
              child: ValueListenableBuilder<int>(
                valueListenable: game!.scoreManager.scoreNotifier,
                builder: (context, score, child) {
                  return Text(
                    'Score: $score',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: game!.size.y *
                            0.05), // Scale font size based on game height (y)
                  );
                },
              ),
            ),
          // Lives Text Widget (only if layout is ready)
          if (_isGameLayoutReady)
            Positioned(
              top: livesTextTop,
              right: livesTextRight,
              child: ValueListenableBuilder<int>(
                valueListenable: game!.lifeManager.livesNotifier,
                builder: (context, lives, child) {
                  return Text(
                    'Lives: $lives',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: game!.size.y *
                            0.05), // Scale font size based on game height (y)
                  );
                },
              ),
            ),
          // Level Text Widget (only if layout is ready)
          if (_isGameLayoutReady)
            Positioned(
              top: levelTextTop,
              left: levelTextLeft, // Position using calculated value
              child: ValueListenableBuilder<int>(
                valueListenable: game!.scoreManager.levelNotifier,
                builder: (context, level, child) {
                  return Text(
                    'Level: $level',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: game!.size.y *
                            0.05), // Scale font size based on game height (y)
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
