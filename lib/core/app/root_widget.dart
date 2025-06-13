// File: lib/core/app/root_widget.dart

import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:neural_break/core/constants/game_constants.dart';
import 'package:neural_break/features/gameplay/presentation/pages/neural_break_game.dart';

import '../../features/gameplay/presentation/widgets/avatars/avatar_display_widget.dart';

class NeuralBreakRoot extends StatefulWidget {
  const NeuralBreakRoot({super.key});

  @override
  State<NeuralBreakRoot> createState() => _NeuralBreakRootState();
}

class _NeuralBreakRootState extends State<NeuralBreakRoot>
    with SingleTickerProviderStateMixin {
  NeuralBreakGame? game;
  bool _isGameLayoutReady = false;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      print(
          'NeuralBreakRootState: initState called (STEP 1: Attempting Game Init)');
    }

    try {
      game = NeuralBreakGame(tickerProvider: this);
      if (kDebugMode) {
        print(
            'NeuralBreakRootState: Game instance created (STEP 2: Instance OK)');
      }

      game!.loaded.then((_) {
        if (mounted) {
          setState(() {
            _isGameLayoutReady = true;
            if (kDebugMode) {
              print('NeuralBreakRootState: Game layout is ready.');
            }
          });
        }
      });
    } catch (e, s) {
      if (kDebugMode) {
        print('NeuralBreakRootState: ERROR creating NeuralBreakGame: $e');
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (kDebugMode) {
      print('NeuralBreakRootState: Building GameWidget and overlays.');
    }

    double playerGameY = 0;
    double avatarWidgetBottomPadding = 0;
    double avatarWidgetLeft = 0;

    double scoreTextTop = 0;
    double scoreTextLeft = 0;
    double livesTextTop = 0;
    double livesTextRight = 0;
    double levelTextTop = 0;
    double levelTextLeft = 0;

    if (_isGameLayoutReady && game!.hasLayout) {
      playerGameY = getGroundY(game!.size.y, playerSize);
      avatarWidgetBottomPadding =
          (game!.size.y - playerGameY) - (playerSize / 2);
      avatarWidgetLeft = (game!.size.x / 2) - (playerSize * 0.8 / 2);

      final textPadding = game!.size.y * 0.03;
      final horizontalMargin = game!.size.x * 0.05;

      scoreTextTop = textPadding;
      scoreTextLeft = horizontalMargin;

      livesTextTop = textPadding;
      livesTextRight = horizontalMargin;

      levelTextTop = textPadding;
      levelTextLeft = (game!.size.x / 2) - 50;
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: GameWidget(game: game!)),
          if (!_isGameLayoutReady)
            const Positioned.fill(
              child: Center(child: CircularProgressIndicator()),
            ),
          if (_isGameLayoutReady)
            Positioned(
              bottom: avatarWidgetBottomPadding,
              left: avatarWidgetLeft,
              child: AvatarDisplayWidget(
                uiManager: game!.uiManager,
                avatarSize: playerSize,
              ),
            ),
          if (_isGameLayoutReady)
            Positioned(
              top: scoreTextTop,
              left: scoreTextLeft,
              child: ValueListenableBuilder<int>(
                valueListenable: game!.scoreManager.scoreNotifier,
                builder: (_, score, __) => Text(
                  'Score: $score',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: game!.size.y * 0.05,
                  ),
                ),
              ),
            ),
          if (_isGameLayoutReady)
            Positioned(
              top: livesTextTop,
              right: livesTextRight,
              child: ValueListenableBuilder<int>(
                valueListenable: game!.lifeManager.livesNotifier,
                builder: (_, lives, __) => Text(
                  'Lives: $lives',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: game!.size.y * 0.05,
                  ),
                ),
              ),
            ),
          if (_isGameLayoutReady)
            Positioned(
              top: levelTextTop,
              left: levelTextLeft,
              child: ValueListenableBuilder<int>(
                valueListenable: game!.scoreManager.levelNotifier,
                builder: (_, level, __) => Text(
                  'Level: $level',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: game!.size.y * 0.05,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
