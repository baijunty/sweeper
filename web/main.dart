import 'dart:async';
import 'dart:html' as html;
import 'package:stagexl/stagexl.dart';

import 'src/config.dart';
import 'src/statebar.dart';
import 'src/sweep.dart';

Future<Null> main() async {
  StageOptions options = StageOptions()
    ..backgroundColor = Color.White
    ..renderEngine = RenderEngine.WebGL;

  var canvas = html.querySelector('#stage');
  var stage = Stage(canvas, width: 1280, height: 800, options: options);
  var renderLoop = RenderLoop();
  renderLoop.addStage(stage);
  var resourceManager = ResourceManager();
  final manger = Manager(resourceManager);
  await manger.initResource();
  Sprite3D game=Sprite3D();
  final bar = StateBar(manger);
  final sprite = TamaSweep(bar)
  ..y=bar.height;
  game.addChild(bar);
  game.addChild(sprite);
  game.addTo(stage);
  sprite.initMine();
  print("w ${stage.width} h ${stage.height} ${bar.width} ${bar.height} ${sprite.width} ${sprite.height} ${sprite.x} ${sprite.y}");
  game.x = stage.sourceWidth / 2;
  game.y = stage.sourceHeight / 2;
  game.pivotX = game.width / 2;
  game.pivotY = game.height / 2;
}
