import 'package:stagexl/stagexl.dart';
import 'package:tuple/tuple.dart';

import 'level.dart';

class Manager {
  BitmapData _origin;
  BitmapData _mark;
  BitmapData _mine;
  BitmapData _normal;
  BitmapData _failed;
  BitmapData _success;
  Level _level = Level.Hard;

  void setLevel(Level level) {
    this._level = level;
  }

  final ResourceManager _manager;
  final List<Tuple3<int, int, int>> _levelConfig = [
    Tuple3(10, 10, 10),
    Tuple3(16, 16, 40),
    Tuple3(24, 20, 99)
  ];
  final List<Tuple2<int, int>> circles = [
    Tuple2(568, 0),
    Tuple2(324, 520),
    Tuple2(404, 260),
    Tuple2(568, 260),
    Tuple2(0, 130),
    Tuple2(80, 0),
    Tuple2(80, 520),
    Tuple2(160, 390)
  ];
  Manager(this._manager) {
    _manager.addSound("wa", "audio/wa.ogg");
    _manager.addSound("boom", "audio/karasu.ogg");
    _manager.addBitmapData("bg", "images/background.jpg");
    _manager.addBitmapData("sakura", "images/sakura.png");
    _manager.addBitmapData("ui", "images/ui.png");
    _manager.addBitmapData("karasu", "images/karasu.png");
    _manager.addBitmapData("normal", "images/normal.png");
    _manager.addBitmapData("failed", "images/failed.png");
    _manager.addBitmapData("success", "images/success.png");
    for (var i = 1; i < 8; i++) {
      _manager.addBitmapData("frame$i", "images/$i.png");
    }
  }

  void initResource() async {
    await _manager.load();
    this._origin = _manager.getBitmapData("ui");
    this._mark = _manager.getBitmapData("sakura");
    this._mine = _manager.getBitmapData("karasu");
    this._normal = _manager.getBitmapData("normal");
    this._failed = _manager.getBitmapData("failed");
    this._success = _manager.getBitmapData("success");
  }

  Sound get wa=>_manager.getSound("wa");
  Sound get boom=>_manager.getSound("boom");

  Bitmap get normal=> Bitmap(_normal);
  Bitmap get failed=> Bitmap(_failed);
  Bitmap get success=> Bitmap(_success);

  Bitmap bg() {
    return Bitmap(
        BitmapData.fromBitmapData(_origin, Rectangle(242, 390, 82, 130)));
  }

  Bitmap background() {
    return Bitmap(_manager.getBitmapData("bg"));
  }

  Bitmap blank() {
    return Bitmap(
        BitmapData.fromBitmapData(_origin, Rectangle(0, 390, 81, 130)));
  }

  Bitmap mark() {
    return Bitmap(_mark);
  }

  Bitmap mine() {
    return Bitmap(_mine);
  }

  Bitmap numBitmap(int number) {
    final tuple = circles[number - 1];
    return Bitmap(BitmapData.fromBitmapData(
        _origin, Rectangle(tuple.item1, tuple.item2, 80, 130)));
  }

  Bitmap animateFrame(int frame) {
    return Bitmap(_manager.getBitmapData("frame${frame + 1}"));
  }

  Tuple3<int, int, int> sweeperConfig() {
    return _levelConfig[Level.values.indexOf(_level)];
    // return Tuple3(8, 8, 3);
  }
}
