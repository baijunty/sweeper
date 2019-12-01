import 'dart:async';
import 'dart:math';

import 'package:stagexl/stagexl.dart';

import 'cell.dart';
import 'statebar.dart';

class TamaSweep extends Sprite {
  final StateBar _stateBar;
  final List<Cell> _cells = [];
  TamaSweep(this._stateBar) {
    final bg = _stateBar.manager.background()
      ..scaleX = 0.5
      ..scaleY = 0.5;
    addChild(bg);
    // pivotX = bg.width / 2;
    // pivotY = bg.height / 2;
    _stateBar.success = _playAnima;
    _stateBar.failed = _realMines;
    _stateBar.start = initMine;
    _stateBar.width = bg.width;
  }

  void _playAnima() async {
    final childenSize = numChildren;
    var frame = 0;
    await for (var _ in stage.juggler.interval(0.2)) {
      if (_stateBar.forzen) {
        if (numChildren > childenSize) {
          removeChildAt(childenSize);
        }
        final bitmap = _stateBar.manager.animateFrame(frame % 7)
          ..scaleX = 0.5
          ..scaleY = 0.5;
        addChild(bitmap
          ..x = (this.width - bitmap.width) / 2
          ..y = (this.height - bitmap.height) / 2);
        frame++;
      } else {
        break;
      }
    }
  }

   
   List<Cell> _realMines(Cell cell) {
    return _cells.where((c) => c.isMine&&c!=cell).toList();
  }

  void initMine() async {
    removeChildren(1);
    _cells.clear();
    final height = this.height;
    final width = this.width;
    final size = _stateBar.config;
    final w = width ~/ size.item1;
    final h = height ~/ size.item2;
    // final paddingLeft = (width - w * size.item1) / 2;
    // final paddingTop = (height - h * size.item2) / 2;
    // x = paddingLeft + width / 2;
    // y = paddingTop + height / 2;
    for (var j = 0; j < size.item2; j++) {
      for (var i = 0; i < size.item1; i++) {
        Cell cell = Cell(i, j, size, _stateBar, w, h, _cells)
          ..addChild(_stateBar.manager.bg()
            ..width = w - 1
            ..height = h - 1)
          ..width = w
          ..height = h
          ..x = i * w
          ..y = j * h;
        _cells.add(cell);
        this.addChild(cell);
        ;
      }
    }
    final mines = _stateBar.mines;
    var count = 0;
    final random = Random();
    while (count < mines) {
      final n = random.nextInt(_cells.length);
      if (!_cells[n].isMine) {
        final cell = _cells[n];
        cell.mine = true;
        count++;
      }
    }
  }
}
