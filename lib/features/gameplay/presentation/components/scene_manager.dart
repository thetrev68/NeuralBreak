enum Scene { mainMenu, gameplay, paused, gameOver }

class SceneManager {
  Scene _current = Scene.gameplay;

  Scene get current => _current;

  void goTo(Scene scene) {
    _current = scene;
  }

  bool isScene(Scene scene) => _current == scene;
}
