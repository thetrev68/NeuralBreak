# NeuralBreak
 To run emulator, open command prompt, type
 ``` 
    cd %ANDROID_HOME%\emulator 
``` 
and hit enter. At that command prompt, type: 
``` 
    emulator -avd Medium_Phone_API_36.0             ``` home pc ```
    emulator -avd Medium_Phone_API_36               ``` laptop  ```
```
## Development Progress

### [2025-06-08] - Core Player Controls & Game Foundation

Today's session focused on establishing the fundamental player interactions and setting up a more modular Flame architecture.

**Key Achievements:**

* **Game Initialization:** Confirmed core Flame setup, rendering a black screen and logging game load.
* **Player Component:** Created the basic `Player` entity, represented as a white square.
* **Horizontal Movement:** Implemented smooth, lane-based left and right movement using screen taps.
* **Jump Mechanic:** Added a basic jump ability for the player with physics (gravity, jump force).
* **Intuitive Input System:**
    * Centralized screen tap handling to the `NeuralBreakGame` class.
    * Implemented dynamic tap zones:
        * Tapping **left/right of the player** controls horizontal lane changes.
        * Tapping **directly above the player** triggers a jump, making controls intuitive regardless of the player's current lane.
* **Code Modularization:**
    * Introduced `PlayerMovement` mixin to manage horizontal motion logic.
    * Introduced `PlayerJump` mixin to encapsulate jump physics and state.
    * Created `game_constants.dart` for easily configurable game parameters (player size, speed, jump force, gravity, lane logic, tap zones).

The player can now move horizontally between lanes and jump, providing the basic interactive loop for the game.