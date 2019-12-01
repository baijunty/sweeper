import 'dart:math';

import 'package:stagexl/stagexl.dart';
import 'package:tuple/tuple.dart';

import 'statebar.dart';
import 'sweep.dart';

class Cell extends Sprite {
  final int _x;
  final int _y;
  final Tuple3<int, int, int> limit;
  final StateBar _stateBar;
  bool _isMine = false;
  bool _isOpen = false;
  bool _isMark = false;
  bool _leftDown = false;
  bool _rightDown = false;
  bool _matchMark = false;
  final int _width;
  final int _height;
  int _mineNum = 0;
  List<Cell> _neighbors = [];
  final List<Cell> _cells;
  Cell(this._x, this._y, this.limit, this._stateBar, this._width, this._height,
      this._cells) {
    this.onMouseOver.listen(_onMouseOver);
    this.onMouseOut.listen(_onMouseOut);
    this.onMouseClick.listen(_onMouseClick);
    this.onMouseRightClick.listen(_onMouseRightClick);
    this.onMouseRightDown.listen(_onRightDown);
    this.onMouseDown.listen(_onLeftDown);
    this.onMouseUp.listen(_onLeftUp);
    this.onMouseRightUp.listen(_onRightUp);
  }

  void _onLeftUp(MouseEvent e) {
    if (_stateBar.clickAble) {
      _leftDown = false;
      _resetNeighbors();
      _stateBar.onUp();
    }
  }

  void _onRightUp(MouseEvent e) {
    if (_stateBar.clickAble) {
      _leftDown = false;
      _resetNeighbors();
    }
  }

  void _resetNeighbors() {
    if (!_matchMark) {
      neighbors.where((c) => !c._isOpen && !c._isMark).forEach((c) {
        c._onMouseOut(null);
      });
    }
  }

  void _onRightDown(MouseEvent e) {
    if (_stateBar.clickAble) {
      _leftDown = true;
      _checkAndTryOpen();
    }
  }

  void _onLeftDown(MouseEvent e) {
    if (_stateBar.clickAble) {
      _rightDown = true;
      _stateBar.onDown();
      _checkAndTryOpen();
    }
  }

  void _checkAndTryOpen() {
    if (_leftDown && _rightDown && _isOpen) {
      _matchMark = neighbors.where((c) => c._isMark).length == _mineNum;
      neighbors.where((c) => !c._isOpen && !c._isMark).forEach((c) {
        if (_matchMark) {
          c._onMouseClick(null);
        } else {
          c._onMouseOver(null);
        }
      });
    }
  }

  set mine(bool b) {
    this._isMine = b;
    _mineNum = 0;
    neighbors.where((cell) => !cell._isMine).forEach((cell) {
      cell._mineNum++;
    });
  }

  List<Cell> get neighbors {
    if (_neighbors.isEmpty) {
      _fillNeighbors();
    }
    return _neighbors;
  }

  List<Cell> _fillNeighbors() {
    bool preLine = _y - 1 >= 0;
    bool nextLine = _y + 1 < limit.item2;
    bool preCol = _x - 1 >= 0;
    bool nextCol = _x + 1 < limit.item1;
    final index = _y * limit.item1 + _x;
    if (preLine) {
      //top
      _neighbors.add(_cells[index - limit.item1]);
      if (preCol) {
        _neighbors.add(_cells[index - limit.item1 - 1]);
      }
      if (nextCol) {
        _neighbors.add(_cells[index - limit.item1 + 1]);
      }
    }
    if (preCol) {
      _neighbors.add(_cells[index - 1]);
    }
    if (nextCol) {
      _neighbors.add(_cells[index + 1]);
    }
    if (nextLine) {
      //bottom
      _neighbors.add(_cells[index + limit.item1]);
      if (preCol) {
        _neighbors.add(_cells[index + limit.item1 - 1]);
      }
      if (nextCol) {
        _neighbors.add(_cells[index + limit.item1 + 1]);
      }
    }
    return _neighbors;
  }

  get isMine => _isMine;

  void _onMouseOver(MouseEvent e) {
    if (!_isOpen && _stateBar.clickAble) {
      this.filters.add(BlurFilter(10, 10, 5));
    }
  }

  void _onMouseOut(MouseEvent e) {
    this.filters.clear();
  }

  void _onMouseClick(MouseEvent e) {
    if (_isOpen || !_stateBar.clickAble || _isMark) {
      return;
    }
    if (_open()) {
      Sound wa = _stateBar.manager.wa;
      wa.play();
    } else {
      Sound boom = _stateBar.manager.boom;
      boom.play();
    }
    _open();
  }

  bool _open() {
    this.filters.clear();
    removeChildren();
    _isOpen = true;
    if (_isMine) {
      addChild(Bitmap(BitmapData(_width, _height, Color.Red)));
      _addBitmap(_stateBar.manager.mine());
      _stateBar.fail(this);
      return false;
    } else if (_mineNum > 0) {
      _stateBar.onCellOpen();
      addChild(TextField(_mineNum.toString())
        ..width = _width
        ..height = _height
        ..defaultTextFormat = TextFormat("Arial", 15, Color.DodgerBlue,
            align: 'center', verticalAlign: 'center')
        ..multiline = false
        ..wordWrap = false);
    } else {
      _tryOpen();
      _stateBar.onCellOpen();
    }
    return true;
  }

  void _tryOpen() {
    if (_mineNum == 0) {
      neighbors.where((c) => !c._isOpen && !c._isMark).forEach((c) {
        c._open();
      });
    } else if (_mineNum > 0) {
      _open();
    }
    ;
  }

  void openMine() {
    removeChildren();
    _addBitmap(_stateBar.manager.mine());
  }

  void _onMouseRightClick(MouseEvent e) {
    if (!_isOpen && _stateBar.clickAble) {
      if (_isMark) {
        _isMark = false;
        removeChildAt(1);
      } else {
        _isMark = true;
        _addBitmap(_stateBar.manager.mark());
      }
      _stateBar.onMarkedChange(_isMark);
    }
  }

  void _addBitmap(Bitmap bitmap) {
    final scale = min(_width / bitmap.width, _height / bitmap.height);
    final size = min(_width, _height);
    addChild(bitmap
      ..scaleX = scale
      ..scaleY = scale
      ..x = (_width - size) / 2
      ..y = (_height - size) / 2);
  }

  @override
  bool operator ==(other) => other is Cell && other._x == _x && other._y == _y;

  @override
  String toString() {
    return "{$_x $_y $isMine $_mineNum ${width} ${_height} $x $y}";
  }
}
