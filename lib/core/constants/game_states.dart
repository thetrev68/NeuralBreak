// lib/game/util/game_states.dart
// If these are just enums representing game states, `constants` is fine. If they are more complex state objects, they might belong closer to a state management solution in `core/` or `features/gameplay/presentation/bloc/`. For now, `constants` is a safe bet.

enum GameState { playing, gameOver, levelUpPaused }
