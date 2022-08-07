import 'dart:convert';
import 'package:async/async.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter_shaders/helpers/utils.dart';

class SpriteCache {
  String textureLoadState = "none";
  Map<String, dynamic> _cache = {};
  FutureGroup _group = FutureGroup();
  // constructor
  SpriteCache() {}

  /**
   * Add item to the loader queue
   */
  void addItem(
    String key, {
    String? texturePath = null,
    String? dataPath = null,
    List<String>? delimiters = null,
  }) {
    _cache[key] = {
      "loadedState": "none",
      "texturePath": texturePath,
      "dataPath": dataPath,
      "texture": null,
      "spriteData": null,
      "delimiters": delimiters,
    };
  }

  /**
   * Initiate the loading of the added sprites and textures
   * 
   * returns bool
   */
  Future<bool> loadItems() async {
    _cache.forEach((key, item) {
      if (item["loadedState"] == "none") {
        if (item["dataPath"] == null) {
          // load static img
          _group.add(loadImage(key));
        } else {
          _group.add(loadSprite(key));
        }
      }
    });

    _group.close();
    var val = await _group.future;

    return true;
  }

  /**
   * Load a sprite, texture first and then .json metadata
   */
  Future<void> loadSprite(String key) async {
    _cache[key]["loadedState"] = "loading";
    String texturePath = _cache[key]["texturePath"];
    String dataPath = _cache[key]["dataPath"];
    final ByteData data = await rootBundle.load(texturePath);
    _cache[key]["texture"] = await Utils.shared.imageFromBytes(data);
    if (dataPath != "") {
      var data = await loadJsonData(dataPath);
      _cache[key]["spriteData"] = parseJSON(key, data);

      _cache[key]["loadedState"] = "done";
    } else {
      _cache[key]["loadedState"] = "none";
    }
  }

  /**
   * Load the json metadata of the sprite atlas
   */
  Future<Map<String, dynamic>> loadJsonData(String path) async {
    var jsonText = await rootBundle.loadString(path);
    Map<String, dynamic> data = json.decode(jsonText);
    return data;
  }

  /**
   * Parse the json metadata into proper dictionary structure
   */
  Map<String, List<Map<String, dynamic>>> parseJSON(String key, Map<String, dynamic> data) {
    Map<String, List<Map<String, dynamic>>> sprites = {};
    List<String> delimiters = _cache[key]["delimiters"];
    for (var key in delimiters) {
      sprites[key] = [];
      data["frames"].forEach((innerKey, value) {
        final frameData = value['frame'];
        final int x = frameData['x'];
        final int y = frameData['y'];
        final int width = frameData['w'];
        final int height = frameData['h'];
        final int sourceWidth = value['sourceSize']['w'];
        final int sourceHeight = value['sourceSize']['h'];
        if ((innerKey as String).contains(key) == true) {
          sprites[key]!.add({
            "x": x,
            "y": y,
            "width": width,
            "height": height,
            "sourceWidth": sourceWidth,
            "sourceHeight": sourceHeight,
          });
        }
      });
    }

    return sprites;
  }

  /**
   * Load a single image
   */
  Future<void> loadImage(String key) async {
    /// cache these externally
    String texturePath = _cache[key]["texturePath"];
    final ByteData data = await rootBundle.load(texturePath);
    _cache[key]["texture"] = await Utils.shared.imageFromBytes(data);
    // making sure we got something back
    if (_cache[key]["texture"] != null) {
      _cache[key]["textureWidth"] = _cache[key]["texture"]!.width;
      _cache[key]["textureHeight"] = _cache[key]["texture"]!.height;
      _cache[key]["loadedState"] = "done";
    } else {
      _cache[key]["loadedState"] = "none";
    }
  }

  /**
   * Get an item from the cache
   */
  Map<String, dynamic>? getItem(String key) {
    return _cache[key];
  }

  /**
   * Check if the cache is empty
   */
  bool isEmpty() {
    return _cache.isEmpty;
  }
}
