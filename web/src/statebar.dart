import 'dart:async';
import 'dart:math';

import 'package:stagexl/stagexl.dart';
import 'package:tuple/tuple.dart';

import 'cell.dart';
import 'config.dart';

class StateBar extends Sprite {
  final Manager _manager;
  Tuple3<int, int, int> _config;
  int total;
  int _opened = 0;
  int _marked = 0;
  int _mines;
  TextField _mineIndex;
  TextField _timeIndex;
  Function _onSuccess;
  Function _onFailed;
  Function _onStart;
  Sprite _emoji;
  bool _isFinish = false;
  StreamSubscription<int> _timeSchedu;
  StreamSubscription<Cell> _failedAnime;
  get config => _config;

  get mines => _mines;

  get manager => _manager;

  set success(void f()) => _onSuccess = f;
  set failed(List<Cell> f(Cell cell)) => _onFailed = f;
  set start(void f()) => _onStart = f;
  StateBar(this._manager) {
    this._config = _manager.sweeperConfig();
    total = _config.item1 * _config.item2;
    _mines = _config.item3;
    _addStateBar();
  }

  void _addStateBar() {
    final markBg = _manager.mark();
    final size = min(markBg.width, markBg.height) * 0.75;
    final mark = markBg
      ..width = size
      ..height = size;
    addChild(mark);
    addChildAt(
        Bitmap(BitmapData(
            _manager.background().width / 2, height, Color.BlueViolet)),
        0);
    _mineIndex = TextField(_mines.toString())
      ..x = mark.width
      ..height = mark.height
      ..defaultTextFormat =
          TextFormat('Arial', 25, Color.Red, verticalAlign: 'center');
    addChild(_mineIndex);
    _emoji = Sprite()..height = mark.height;
    final chibiTama = _manager.success;
    _setChibiTama(chibiTama);
    _emoji.x = (width - _emoji.width) / 2;
    _emoji.onMouseClick.listen(_onGameStart);
    addChild(_emoji);
    _timeIndex = TextField("00:00")
      ..height = mark.height
      ..defaultTextFormat = TextFormat('Arial', 25, Color.Red,
          align: 'right', verticalAlign: 'center');
    addChild(_timeIndex);
    _timeIndex.x = width - _timeIndex.width;
  }

  void _onGameStart(Event e) {
    if (_onStart != null) {
      _onStart();
    }
    if (_failedAnime != null) {
      _failedAnime.cancel();
    }
     _opened = 0;
     _marked = 0;
     _mineIndex.text=_mines.toString();
    _isFinish = false;
    _setChibiTama(_manager.success);
  }

  void _setChibiTama(Bitmap tama) {
    if (!_isFinish) {
      _emoji.removeChildren();
      _emoji.addChild(tama
        ..scaleX = height / tama.height
        ..scaleY = height / tama.height);
    }
  }

  void _scheduleTime() async {
    if (_timeSchedu != null) {
      await _timeSchedu.cancel();
    }
    _timeIndex.text = "00:00";
    _timeSchedu = stage.juggler.interval(1).listen((sec) {
      final useTime = Duration(seconds: sec);
      _timeIndex.text = _printDuration(useTime);
    });
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  void onMarkedChange(bool marked) {
    if (marked) {
      _marked++;
      if (_opened == total - _mines) {
        _success();
      }
    } else {
      _marked--;
    }
    _mineIndex.text = (_mines - _marked).toString();
  }

  void onCellOpen() {
    _opened++;
    if (_opened == total - _mines) {
      _success();
    }
  }

  get clickAble => !_isFinish;

  void _success() async {
    if (_timeSchedu != null) {
      await _timeSchedu.cancel();
      _timeSchedu = null;
    }
    _isFinish = true;
    if (_onSuccess != null) {
      await _onSuccess();
    }
  }

  void fail(Cell cell) async {
    print("failed");
    if (_timeSchedu != null) {
      await _timeSchedu.cancel();
      _timeSchedu = null;
    }
    _setChibiTama(_manager.failed);
    _isFinish = true;
    if (_onFailed != null) {
      final cells = _onFailed(cell);
      _failedAnime = _showMines(cells)
          .listen((cell) => cell.openMine(), cancelOnError: true);
    }
  }

  Stream<Cell> _showMines(Iterable<Cell> cells) async* {
    for (var cell in cells) {
      await Future.delayed(Duration(milliseconds: 200)).then((Void) => {});
      yield cell;
    }
  }

  get forzen => _isFinish;

  void onDown() {
    if (_timeSchedu == null) {
      _scheduleTime();
    }
    _setChibiTama(_manager.normal);
  }

  void onUp() {
    _setChibiTama(_manager.success);
  }
}
