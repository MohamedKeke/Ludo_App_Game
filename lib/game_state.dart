import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'column_area.dart';
import 'constants.dart';
import 'slot.dart';
import 'custom_box.dart';
import 'player_piece.dart';

class GameState extends ChangeNotifier {
  List<Slot> slotList = List.generate(13 * 4, (index) => Slot(id: index + 1));
  List<int> movesList = [];
  bool killToken = false;

  setStop(int id) {
    slotList[id - 1].isStop = true;
  }

  Slot getSlot(int id) {
    return slotList[id - 1];
  }

  Slot getRedEndSlot(int id) {
    return redEndList[id - 1];
  }

  Slot getBlueEndSlot(int id) {
    return blueEndList[id - 1];
  }

  Slot getYellowEndSlot(int id) {
    return yellowEndList[id - 1];
  }

  Slot getGreenEndSlot(int id) {
    return greenEndList[id - 1];
  }

  updateColDate(PieceType piece) {
//    sheesh += 1;
    switch (piece) {
      case PieceType.Red:
//        addPlayerPiece(2);
        break;
      case PieceType.Blue:
        break;
      case PieceType.Green:
        break;
      case PieceType.Yellow:
        break;
    }
    notifyListeners();
  }

  initialize() {
    generatePlayerPieces();
    initColumn();
    // 1 - 13 green
    setStop(4);
    setStop(9);
    // 14 - 26 blue
    setStop(17);
    setStop(22);
    // 27 - 39 red
    setStop(30);
    setStop(35);
    // 40 - 52 yellow
    setStop(43);
    setStop(48);
  }

  List<PieceType> pieceTurn = [
    PieceType.Green,
    PieceType.Blue,
    PieceType.Red,
    PieceType.Yellow
  ];

  PieceType getTurn() {
    return pieceTurn[0];
  }

  pieceTap(PlayerPiece pp) {
    print('Tapped Piece');
    if (pp.pieceType == getTurn()) {
      if (movesList.length > 0) {
        if (pp.location == 0) {
          if (movesList.contains(6)) {
            addPiece(pp.pieceType);
          }
        } else {
          movePiece(pp, movesList[0]);
        }
      } else {
        print('No moves available. Tap Dice for moves');
      }
    } else {
      print('Please wait your turn sir');
    }
  }

  void diceTap() {
    PieceType turn = getTurn();
    bool canThrow = canThrowDice();
    if (!canThrow) return;
//    if (canThrow) {
    int diceNum = throwDice();
    movesList.add(diceNum);
//    }
    canThrow = canThrowDice();
    bool allPiecesAtHome;
    switch (turn) {
      case PieceType.Green:
        allPiecesAtHome =
            greenPlayerPieces.every((element) {
              print(element.toString());
               return element.isAtHome();
            });
        break;
      case PieceType.Blue:
        allPiecesAtHome = bluePlayerPieces.every((element) => element.isAtHome());
        break;
      case PieceType.Red:
        allPiecesAtHome = redPlayerPieces.every((element) => element.isAtHome());
        break;
      case PieceType.Yellow:
        allPiecesAtHome =
            yellowPlayerPieces.every((element) => element.isAtHome());
        break;
    }
    print('ALL HOME: $allPiecesAtHome');
    if (allPiecesAtHome && !canThrow && !movesList.contains(6)) {
      print('clearing: $movesList');
      movesList.clear();
    }
    if (movesList.isEmpty) {
      changeTurn();
//      movesList.clear();
    }
    notifyListeners();
  }

  canThrowDice() {
    if (killToken) {
      killToken = false;
      return true;
    }
//    bool returnResult = true;
    if (movesList.isEmpty) return true;
    if (movesList.last != 6) return false;
    int len = movesList.length;
    if (len >= 3) {
      if (movesList[len - 1] == 6 &&
          movesList[len - 2] == 6 &&
          movesList[len - 3] == 6) {
        movesList.removeLast();
        movesList.removeLast();
        movesList.removeLast();
        notifyListeners();
        return false;
      }
    }
    notifyListeners();
    return true;
//    return returnResult;
  }

  playTurn() {
    // starting

    // turn end
  }

  changeTurn() {
    PieceType pt = pieceTurn.removeAt(0);
    pieceTurn.add(pt);
    movesList.clear();
  }

  bool canDelete(int slotId) {
    if (getSlot(slotId).isStop) return false;
    var pieceList = getSlot(slotId).playerPieceList;
    if (pieceList.length <= 1) return false;
    int playerPieceCount = 0;
    int otherPieceCount = 0;
    PlayerPiece topPiece = pieceList.last;
    for (int i = 0; i < pieceList.length; i++) {
      if (pieceList[i].pieceType == topPiece.pieceType) {
        ++playerPieceCount;
      } else {
        ++otherPieceCount;
      }
    }
    if (otherPieceCount <= 0) return false;
    if (playerPieceCount >= otherPieceCount) {
      print('CanDelete() true');
    }
    return playerPieceCount >= otherPieceCount;
  }

  deleteBottomPieces(int slotId) {
    killToken = true;
    var pieceList = getSlot(slotId).playerPieceList;
    PlayerPiece topPiece = pieceList.last;
    List<PlayerPiece> otherPieces;
    getSlot(slotId).playerPieceList.forEach((element) {
      if (element.pieceType != topPiece.pieceType) {
        otherPieces.add(element);
      }
    });
    otherPieces.forEach((element) => element.location = 0);
    getSlot(slotId)
        .playerPieceList
        .removeWhere((element) => element.pieceType != topPiece.pieceType);
    notifyListeners();
  }

  addPiece(PieceType pt) {
    PlayerPiece pp;
    Iterable<PlayerPiece> availablePieces;
    int homePosition;
    switch (pt) {
      case PieceType.Green: // 9
        availablePieces = greenPlayerPieces
            .where((element) => element.location == kHomeLocation);
        homePosition = 9;
        break;
      case PieceType.Blue: // 22
        availablePieces = bluePlayerPieces
            .where((element) => element.location == kHomeLocation);
        homePosition = 22;
        break;
      case PieceType.Red: // 35
        availablePieces = redPlayerPieces
            .where((element) => element.location == kHomeLocation);
        homePosition = 35;
        break;
      case PieceType.Yellow: // 48
        availablePieces = yellowPlayerPieces
            .where((element) => element.location == kHomeLocation);
        homePosition = 48;
        break;
    }
    if (availablePieces.length > 0) {
        pp = availablePieces.first;
        pp.location = homePosition;
        getSlot(homePosition).playerPieceList.add(pp);
        movesList.remove(6);

    } else {
      print('AddPiece() No available pieces found');
    }
    notifyListeners();
  }

  movePiece(PlayerPiece pp, int moveDistance) {
    int curLocation = pp.location;
    int newLocation = curLocation + moveDistance;
    if (newLocation > 52) {
      newLocation -= 52;
    }
    print('curLoc: ${pp.location}');
    pp.location = newLocation;
    print('afterUpdate: ${pp.location}');
    getSlot(curLocation).playerPieceList.removeLast();
    getSlot(newLocation).playerPieceList.add(pp);
    movesList.remove(moveDistance);
    if (movesList.isEmpty) {
      changeTurn();
    }
    notifyListeners();
  }

  int throwDice() {
    int num = math.Random().nextInt(6) + 1;
    print('threw $num');
    return num;
  }

  static Color getColor(PieceType pt) {
    switch (pt) {
      case PieceType.Green:
        return green;
        break;
      case PieceType.Blue:
        return blue;
        break;
      case PieceType.Red:
        return red1;
        break;
      case PieceType.Yellow:
        return yellow;
        break;
      default:
        return white;
    }
  }

  generatePlayerPieces() {
    redPlayerPieces = List.generate(
      kNumPlayerPieces,
      (index) => PlayerPiece(
        pieceId: index,
        pieceType: PieceType.Red,
        func: pieceTap,
      ),
    );
    bluePlayerPieces = List.generate(
      kNumPlayerPieces,
      (index) => PlayerPiece(
        pieceId: index,
        pieceType: PieceType.Blue,
        func: pieceTap,
      ),
    );
    yellowPlayerPieces = List.generate(
      kNumPlayerPieces,
      (index) => PlayerPiece(
        pieceId: index,
        pieceType: PieceType.Yellow,
        func: pieceTap,
      ),
    );
    greenPlayerPieces = List.generate(
      kNumPlayerPieces,
      (index) => PlayerPiece(
        pieceId: index,
        pieceType: PieceType.Green,
        func: pieceTap,
      ),
    );
  }

  List<PlayerPiece> redPlayerPieces = [];
  List<PlayerPiece> bluePlayerPieces = [];
  List<PlayerPiece> yellowPlayerPieces = [];
  List<PlayerPiece> greenPlayerPieces = [];

  List<Slot> redEndList =
      List.generate(6, (index) => Slot(id: index + 1, isEnd: true));
  List<Slot> blueEndList =
      List.generate(6, (index) => Slot(id: index + 1, isEnd: true));
  List<Slot> yellowEndList =
      List.generate(6, (index) => Slot(id: index + 1, isEnd: true));
  List<Slot> greenEndList =
      List.generate(6, (index) => Slot(id: index + 1, isEnd: true));

  get redCol1 => _redColumn1;

  get redCol2 => _redColumn2;

  get redCol3 => _redColumn3;

  get yellowCol1 => _yellowColumn1;

  get yellowCol2 => _yellowColumn2;

  get yellowCol3 => _yellowColumn3;

  get blueCol1 => _blueColumn1;

  get blueCol2 => _blueColumn2;

  get blueCol3 => _blueColumn3;

  get greenCol1 => _greenColumn1;

  get greenCol2 => _greenColumn2;

  get greenCol3 => _greenColumn3;

  List<Widget> _redColumn1 = [];
  List<Widget> _redColumn2 = [];
  List<Widget> _redColumn3 = [];

  List<Widget> _yellowColumn1 = [];
  List<Widget> _yellowColumn2 = [];
  List<Widget> _yellowColumn3 = [];

  List<Widget> _greenColumn1 = [];
  List<Widget> _greenColumn2 = [];
  List<Widget> _greenColumn3 = [];

  List<Widget> _blueColumn1 = [];
  List<Widget> _blueColumn2 = [];
  List<Widget> _blueColumn3 = [];

  initColumn() {
    _redColumn1 = [
      CustomBox(getSlot(27)),
      CustomBox(getSlot(28)),
      CustomBox(getSlot(29)),
      CustomBox(getSlot(30), c: red1),
      CustomBox(getSlot(31)),
      CustomBox(getSlot(32)),
    ];
    _redColumn2 = [
      CustomBox(getRedEndSlot(5), c: red1),
      CustomBox(getRedEndSlot(4), c: red1),
      CustomBox(getRedEndSlot(3), c: red1),
      CustomBox(getRedEndSlot(2), c: red1),
      CustomBox(getRedEndSlot(1), c: red1),
      CustomBox(getSlot(33)),
    ];
    _redColumn3 = [
      CustomBox(getSlot(39)),
      CustomBox(getSlot(38)),
      CustomBox(getSlot(37)),
      CustomBox(getSlot(36)),
      CustomBox(getSlot(35), c: red1),
      CustomBox(getSlot(34)),
    ];
    _yellowColumn1 = [
      CustomBox(getSlot(40)),
      CustomBox(getSlot(41)),
      CustomBox(getSlot(42)),
      CustomBox(getSlot(43), c: yellow),
      CustomBox(getSlot(44)),
      CustomBox(getSlot(45)),
    ];
    _yellowColumn2 = [
      CustomBox(getRedEndSlot(5), c: yellow),
      CustomBox(getRedEndSlot(4), c: yellow),
      CustomBox(getRedEndSlot(3), c: yellow),
      CustomBox(getRedEndSlot(2), c: yellow),
      CustomBox(getRedEndSlot(1), c: yellow),
      CustomBox(getSlot(46)),
    ];
    _yellowColumn3 = [
      CustomBox(getSlot(52)),
      CustomBox(getSlot(51)),
      CustomBox(getSlot(50)),
      CustomBox(getSlot(49)),
      CustomBox(getSlot(48), c: yellow),
      CustomBox(getSlot(47)),
    ];

    _greenColumn1 = [
      CustomBox(getSlot(1)),
      CustomBox(getSlot(2)),
      CustomBox(getSlot(3)),
      CustomBox(getSlot(4), c: green),
      CustomBox(getSlot(5)),
      CustomBox(getSlot(6)),
    ];
    _greenColumn2 = [
      CustomBox(getRedEndSlot(5), c: green),
      CustomBox(getRedEndSlot(4), c: green),
      CustomBox(getRedEndSlot(3), c: green),
      CustomBox(getRedEndSlot(2), c: green),
      CustomBox(getRedEndSlot(1), c: green),
      CustomBox(getSlot(7)),
    ];
    _greenColumn3 = [
      CustomBox(getSlot(13)),
      CustomBox(getSlot(12)),
      CustomBox(getSlot(11)),
      CustomBox(getSlot(10)),
      CustomBox(getSlot(9), c: green),
      CustomBox(getSlot(8)),
    ];

    _blueColumn1 = [
      CustomBox(getSlot(14)),
      CustomBox(getSlot(15)),
      CustomBox(getSlot(16)),
      CustomBox(getSlot(17), c: blue),
      CustomBox(getSlot(18)),
      CustomBox(getSlot(19)),
    ];
    _blueColumn2 = [
      CustomBox(getRedEndSlot(5), c: blue),
      CustomBox(getRedEndSlot(4), c: blue),
      CustomBox(getRedEndSlot(3), c: blue),
      CustomBox(getRedEndSlot(2), c: blue),
      CustomBox(getRedEndSlot(1), c: blue),
      CustomBox(getSlot(20)),
    ];
    _blueColumn3 = [
      CustomBox(getSlot(26)),
      CustomBox(getSlot(25)),
      CustomBox(getSlot(24)),
      CustomBox(getSlot(23)),
      CustomBox(getSlot(22), c: blue),
      CustomBox(getSlot(21)),
    ];
  }
}
