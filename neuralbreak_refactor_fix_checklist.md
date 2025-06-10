
# ✅ NeuralBreak Refactor Fix Checklist

This checklist will help you resolve the Dart/Flutter errors after refactoring your game code.

---

## 1️⃣ Declare Missing Managers

In `neural_break_game.dart`, **inside the `NeuralBreakGame` class**, add:

```dart
late final ScoreManager scoreManager;
late final LifeManager lifeManager;
late final GameStateManager gameStateManager;
late final UIManager uiManager;
late final GameController gameController;
late final ComponentManager componentManager;
late final InputManager inputManager;
late final SceneManager sceneManager;

int _currentLevelScoreTarget = 0;
```

---

## 2️⃣ Replace Removed Fields

Find and replace all instances of:

| Old             | Replace With                   |
|----------------|---------------------------------|
| `score`         | `scoreManager.score`           |
| `lives`         | `lifeManager.lives`            |
| `currentLevel`  | `scoreManager.level`           |

Do this in all methods, including:
- `_updateScoreText()`
- `_checkGameOver()`
- `onCollision(...)` or scoring logic

---

## 3️⃣ Fix Missing Imports in `component_manager.dart`

At the top of `component_manager.dart`, add:

```dart
import 'package:flame/game.dart';
import 'package:neural_break/game/components/obstacle.dart';
```

---

## 4️⃣ Rename `is()` in `scene_manager.dart`

In `scene_manager.dart`, change:

```dart
bool is(Scene scene) => _current == scene;
```

To:

```dart
bool isScene(Scene scene) => _current == scene;
```

Then update any usage to:

```dart
sceneManager.isScene(Scene.gameplay)
```

---

## 5️⃣ Replace `HasGameRef` With `HasGameReference`

Find all lines like:

```dart
with HasGameRef<MyGame>
```

And replace with:

```dart
with HasGameReference<MyGame>
```

Do this in:
- `obstacle.dart`
- `obstacle_spawner.dart`
- `player.dart`
- `player_movement.dart`

---

## 6️⃣ Update Deprecated `RawKeyEvent`

In `input_manager.dart`, update:

```dart
void handleKeyboard(RawKeyEvent event)
```

To:

```dart
void handleKeyboard(KeyEvent event)
```

Then fix any code that relies on `RawKeyEvent`.

---

## 7️⃣ Clean Up Type Checks and Casts

If you have code like:

```dart
if (game is NeuralBreakGame) {
  (game as NeuralBreakGame).score += 10;
}
```

Replace with:

```dart
final myGame = game as NeuralBreakGame;
myGame.scoreManager.onScore(10);
```

Or remove the cast/check if you’re sure of the type.

---

## 8️⃣ Delete Unused Imports

From any file with warnings like:

> Unused import: '...'

Just delete the line. For example:

```dart
// DELETE THIS
import 'package:neural_break/game/components/firewall.dart';
```

---

You’ve got this! When you’re stuck, just bring this back in a new chat and I’ll guide you through your edits one by one.
