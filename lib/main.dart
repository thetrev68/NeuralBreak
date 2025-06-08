import 'package:flutter/material.dart';
import 'package:flame/game.dart'; // Import Flame's GameWidget

import 'package:neural_break/game/neural_break_game.dart'; // Import your main game class

void main() {
  // Ensure Flutter widgets are initialized before the game.
  WidgetsFlutterBinding.ensureInitialized();

  // Create an instance of your main game class.
  final neuralBreakGame = NeuralBreakGame();

  // Run the Flutter app.
  // We'll eventually manage multiple screens (Main Menu, Game Over) here.
  // For now, we directly show the game.
  runApp(
    GameWidget(game: neuralBreakGame), // GameWidget hosts your Flame game
  );
}