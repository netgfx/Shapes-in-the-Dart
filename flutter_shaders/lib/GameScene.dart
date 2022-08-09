import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_shaders/LetterParticles.dart';
import 'package:flutter_shaders/ParticleEmitter.dart';
import 'package:flutter_native_image/flutter_native_image.dart' as uiImage;
import 'package:flutter_shaders/game_classes/EntitySystem/Camera.dart';
import 'package:flutter_shaders/game_classes/EntitySystem/ShapeMaker.dart';
import 'package:flutter_shaders/game_classes/EntitySystem/TDSprite.dart';
import 'package:flutter_shaders/game_classes/EntitySystem/TDSpriteAnimator.dart';
import 'package:flutter_shaders/game_classes/EntitySystem/group_controller.dart';
import 'package:flutter_shaders/game_classes/EntitySystem/sprite_archetype.dart';
import 'package:flutter_shaders/game_classes/sprite_driver.dart';
import 'package:flutter_shaders/helpers/action_manager.dart';
import 'package:flutter_shaders/helpers/sprite_cache.dart';
import 'package:flutter_shaders/helpers/tween_manager.dart';
import 'package:performance/performance.dart';
import 'package:flutter_shaders/game_classes/EntitySystem/ShapeMaker.dart';

class GameScene extends StatefulWidget {
  GameScene({required Key key}) : super(key: key);

  @override
  _GameSceneState createState() => _GameSceneState();
}

class _GameSceneState extends State<GameScene> with TickerProviderStateMixin {
  late AnimationController _controller;
  BoxConstraints? viewportConstraints;

  //
  Map<String, dynamic> spriteCache = {};
  // entity stuff
  ActionManager actions = ActionManager();
  SpriteCache cache = SpriteCache();
  bool cacheReady = false;
  List<dynamic> spritesArr = [];
  late TweenManager _tween;

  ///
  CharacterParticleEffect lettersEffect = CharacterParticleEffect.SPREAD;
  @override
  void initState() {
    super.initState();
    _tween = TweenManager(ticker: this);
    _controller = AnimationController(vsync: this, duration: Duration(seconds: 1));
    //_spriteController = AnimationController(vsync: this, duration: Duration(seconds: 1));
    //_controller.addListener(() {setState(() {});}); no need to setState
    //_controller.drive(CurveTween(curve: Curves.bounceIn));
    //_spriteController.repeat();

    SchedulerBinding.instance!.addPostFrameCallback((_) {
      _controller.repeat();

      // cache
      cache.addItem(
        "mage1",
        texturePath: "assets/mage1.png",
      );
      cache.addItem(
        "boom",
        texturePath: "assets/boom.png",
        dataPath: "assets/boom.json",
        delimiters: ["Boom-1"],
      );
      cache.addItem(
        "bat",
        texturePath: "assets/flying_monster.png",
        dataPath: "assets/flying_monster.json",
        delimiters: ["death/Death_animations", "fly/Fly2_Bats"],
      );

      cache.addItem("bg", texturePath: "assets/bg_07.jpg");

      var result = cache.loadItems();
      result.then((value) => {
            print("Items loaded? $value"),
            setState(() => {
                  cacheReady = true,
                }),
            init()
          });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    actions.actionController.close();
    super.dispose();
  }

  void init() {
    List<dynamic> sprites = [];

    GroupController group = GroupController(
      position: Point(100.0, 400.0),
      startAlive: true,
    );
    group.zIndex = 1;
    group.enableDebug = true;

    group.addItem(
      Point<double>(0.0, 0.0),
      TDSprite(
        position: Point<double>(0.0, 0.0),
        textureName: "mage1",
        startAlive: true,
        scale: 0.8,
        fitParent: false,
        centerOffset: Offset(0, 0),
      ),
    );

    sprites = [
      TDSprite(
        position: Point<double>(0.0, 0.0),
        textureName: "bg",
        startAlive: true,
        scale: 1.0,
      ),
      TDSpriteAnimator(
        position: Point<double>(100.0, 100.0),
        textureName: "bat",
        currentFrame: "fly/Fly2_Bats",
        id: "bat",
        centerOffset: Offset(0.0, 0.0),
        loop: LoopMode.Repeat,
        scale: 0.5,
        zIndex: 2,
        startAlive: true,
        fps: 24,
        onEvent: (Point event, SpriteArchetype sprite) => {
          print("I'm tapped!!!"),
          _tween.addTween(
            TweenOptions(
              target: "bat",
              collection: sprites,
              property: "scale",
              to: 0.8,
              autostart: true,
              animationProperties: AnimationProperties(
                duration: 2000,
                delay: 0,
                ease: Curves.easeOutBack,
              ),
            ),
            () => {print("tween complete!")},
            null,
          )
        },
        interactive: true,
      ),
      ShapeMaker(
        type: ShapeType.Circle,
        position: Point<double>(200.0, 250.0),
        radius: 40,
        zIndex: 1,
        interactive: false,
        paintOptions: {
          "color": Colors.red,
          "paintingStyle": ui.PaintingStyle.fill,
        },
        startAlive: true,
      ),
      group
    ];

    setState(() {
      spritesArr = sprites;
    });
  }

  void playFly() {
    setState(() {
      //batFirstFrame = "fly/Fly2_Bats";
      //batLoop = true;
    });
  }

  void playExplode() {
    setState(() {
      //batFirstFrame = "death/Death_animations";
      //batLoop = false;
    });
  }

  void _onPanUpdate(BuildContext context, TapDownDetails details) {
    //checkCollision();
    // setState(() {
    //   lightSource = Point(details.localPosition.dx, details.localPosition.dy);
    // });
    // early iteration, sprite should be responsible for sending events
    //actions.sendAnimation(details.localPosition.dx, details.localPosition.dy, "boom", "Boom-1");
    actions.sendClick(details.localPosition.dx, details.localPosition.dy);
  }

  @override
  Widget build(BuildContext context) {
    return CustomPerformanceOverlay(
      child: Scaffold(
          backgroundColor: ui.Color.fromARGB(255, 17, 17, 17),
          // bottomNavigationBar: Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: Container(
          //       padding: const EdgeInsets.only(left: 8.0, right: 8.0),
          //       decoration: BoxDecoration(borderRadius: BorderRadius.circular(50.0), color: Colors.black),
          //       child: Padding(
          //         padding: const EdgeInsets.all(8.0),
          //         child: Column(
          //           mainAxisSize: MainAxisSize.min,
          //           children: <Widget>[
          //             Row(
          //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //               children: <Widget>[],
          //             ),
          //           ],
          //         ),
          //       )),
          // ),
          body: LayoutBuilder(builder: (BuildContext context, BoxConstraints viewportConstraints) {
            this.viewportConstraints = viewportConstraints;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) => _onPanUpdate(context, details),
              child: Stack(children: [
                this.cacheReady == false
                    ? Center(
                        child: CircularProgressIndicator(
                        key: UniqueKey(),
                        strokeWidth: 10,
                      ))
                    : Positioned(
                        top: 0,
                        left: 0,
                        child: Padding(
                          padding: EdgeInsets.only(top: 0, left: 0),
                          child: Stack(children: [
                            CustomPaint(
                              key: UniqueKey(),
                              painter: SpriteDriverCanvas(
                                controller: _controller,
                                fps: 30,
                                sprites: this.spritesArr,
                                cache: this.cache,
                                actions: this.cache.isEmpty() ? null : actions,
                                width: viewportConstraints.maxWidth,
                                height: viewportConstraints.maxHeight,
                                cameraProps: CameraProps(
                                  enabled: true,
                                  canvasSize: Size(
                                    viewportConstraints.maxWidth,
                                    viewportConstraints.maxHeight,
                                  ),
                                  mapSize: Size(viewportConstraints.maxWidth, viewportConstraints.maxHeight),
                                  followObject: Rect.fromLTWH(200.0, 180.0, 80, 80),
                                  offset: Point<double>(0.0, 0.0),
                                ),
                              ),
                            ),
                          ]),
                        ),
                      ),
              ]),
            );
            //);
          })),
    );
  }
}
