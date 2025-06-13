// File: lib/core/app/root_widget.dart

// Flame and Flutter packages
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Project imports
import 'package:neural_break/features/gameplay/engine/neural_break_game.dart';
import 'package:neural_break/features/gameplay/presentation/widgets/game_overlay_widget.dart';

class NeuralBreakRoot extends StatefulWidget {
  const NeuralBreakRoot({super.key});

  @override
  State<NeuralBreakRoot> createState() => _NeuralBreakRootState();
}

class _NeuralBreakRootState extends State<NeuralBreakRoot>
    with SingleTickerProviderStateMixin {
  NeuralBreakGame? game;
  bool _isGameReady =
      false; // Renamed for clarity: signifies game.onLoad() completed and layout known

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

      // We wait for game.loaded to complete. This means game.onLoad() has finished.
      // After game.onLoad() finishes, the GameWidget will receive its layout.
      game!.loaded.then((_) {
        if (mounted) {
          // This setState ensures the UI rebuilds after onLoad is done,
          // allowing GameWidget to get its size and hasLayout to become true.
          // Then the overlay can be added.
          setState(() {
            _isGameReady = true; // Mark game as loaded and ready for layout
            if (kDebugMode) {
              print(
                  'NeuralBreakRootState: Game.onLoad() completed. _isGameReady set to true.');
            }
          });
          // After setState, the build method will run again.
          // The GameWidget will then have its layout, and game.size will be available.
          // We can then add the overlay in a post-frame callback to ensure layout is done.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted &&
                game!.hasLayout &&
                !game!.overlays.isActive('gameOverlay')) {
              game!.overlays.add('gameOverlay');
              if (kDebugMode) {
                print(
                    'NeuralBreakRootState: gameOverlay activated after layout.');
              }
            }
          });
        }
      }).catchError((e, s) {
        // Catch any errors during game.onLoad()
        if (kDebugMode) {
          print('NeuralBreakRootState: ERROR during game.onLoad(): $e');
          print('Stack Trace: $s');
        }
        // You might want to set an error state here and show an error UI
      });
    } catch (e, s) {
      // This catches errors during the *creation* of NeuralBreakGame instance, not its onLoad.
      if (kDebugMode) {
        print(
            'NeuralBreakRootState: ERROR creating NeuralBreakGame instance: $e');
        print('Stack Trace: $s');
      }
      // You might want to set an error state here and show an error UI
    }
  }

  @override
  void dispose() {
    game?.pauseEngine();
    game?.onRemove(); // Ensure Flame game lifecycle is handled
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (game == null) {
      // Should ideally not happen if initState succeeds, but a fallback.
      return const Scaffold(
        body: Center(child: Text('Initializing game...')),
      );
    }

    if (kDebugMode) {
      print(
          'NeuralBreakRootState: Building GameWidget. _isGameReady: $_isGameReady');
    }

    return Scaffold(
      body: Stack(
        // Use Stack to put loading indicator on top if needed
        children: [
          GameWidget(
            game: game!,
            // The loadingBuilder is great for showing *initial* loading for onLoad()
            loadingBuilder: (context) {
              if (kDebugMode) {
                print('GameWidget: Showing loadingBuilder.');
              }
              return const Center(child: CircularProgressIndicator());
            },
            errorBuilder: (context, ex) {
              if (kDebugMode) {
                print('GameWidget: Error loading game: $ex');
              }
              return Center(
                child: Text('Error loading game: $ex'),
              );
            },
            overlayBuilderMap: {
              'gameOverlay': (BuildContext context, NeuralBreakGame game) {
                // This builder creates the GameOverlayWidget.
                // It will only be visible when game.overlays.add('gameOverlay') is called.
                return GameOverlayWidget(
                  scoreManager: game.scoreManager,
                  lifeManager: game.lifeManager,
                  uiManager: game.uiManager,
                  gameSize: game.size,
                );
              },
            },
          ),
          // You could add another overlay for a more persistent 'loading game data'
          // spinner if game.onLoad() finishes, but other data loads are ongoing.
          // For now, rely on GameWidget's loadingBuilder for the initial phase.
        ],
      ),
    );
  }
}
