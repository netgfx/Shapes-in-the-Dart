[![Open in Visual Studio Code](https://open.vscode.dev/badges/open-in-vscode.svg)](https://open.vscode.dev/organization/repository)

# flutter_shaders

Experiments with Shaders, Custom Draw, Canvas and Sprites

- To run the blend mode set `initialRoute: "BlendMode",` on `main.dart`

## Todo

✔️ (done)
❗ (important)
❌ (problem)
🚩 (revisit)
🚀 (launch)
🔨 (fix)
👾 (bug)
🏭(in progress)

### Release v0.1

- Custom events on canvas elements 🏭
- keyboard events (https://api.flutter.dev/flutter/widgets/KeyboardListener-class.html)
- Depth sorting ✔️
  - Event honoring depth, so only first is supported ✔️
  - Make drag event 
- Tweens 🏭
  - Add enumerable properties e.g (x, y) or make it read dot notation
  - Tween working with item Id now (so all items should have an id)
- Sprite rotation
- Pooling 🚩
- port Arcade physics ❗
- create master Sprite class for all game objects to inherit basic properties via mixin ✔️
- cache ✔️
- loader class for all assets ✔️
- audio (https://pub.dev/packages/audioplayers)
- Shapes ✔️
- Group component 🏭
- Plugin template
- Proper tilemap and culling
- Autoscroll tile-sprite
- Camera 🏭
  - need to test with scrolling sprite (WIP)
  - need to test moving sprite
- Get name for library...❗
  - Prime engine
  - Archengine
  - Arcus ✔️


### Sample games for v0.1

- whack a mole
- auto-runner
- Bullet-hell
