import 'package:catch_me/models/gameState.dart';
import 'package:flutter/material.dart';


class GameStateProvider extends ChangeNotifier {
  GameState _gameState =
      GameState(id: '', players: [], isJoin: true, isOver: false, winner : 'rat');

  Map<String, dynamic> get gameState => _gameState.toJson();

  void updateGame({
    required id,
    required players,
    required isJoin,
    required isOver,
     winner = 'rat'
  }) {
    print("Updating Game State:");
    print(
        "ID: $id, Players: $players, isJoin: $isJoin, isOver: $isOver");
    _gameState = GameState(
        id: id, players: players, isJoin: isJoin, isOver: isOver,winner: winner);
    notifyListeners();
  }

  resetGameState(){
      _gameState = GameState(id: '', players: [], isJoin: true, isOver: false,winner: 'rat');
      notifyListeners();
  }

}
