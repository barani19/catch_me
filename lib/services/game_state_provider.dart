import 'package:catch_me/models/gameState.dart';
import 'package:flutter/material.dart';

class GameStateProvider extends ChangeNotifier {
  GameState _gameState =
      GameState(id: '', players: [], isJoin: true, isOver: false, winner: 'rat');

  Map<String, dynamic> get gameState => _gameState.toJson();

  bool _mounted = true;

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  bool get isMounted => _mounted;

  void updateGame({
    required String? id,
    required List<dynamic>? players,
    required bool? isJoin,
    required bool? isOver,
    String winner = 'rat',
  }) {
    if (!_mounted) return; // Prevent updating after disposal

    // Check for null and ignore update if any required param is null
    if (id == null || players == null || isJoin == null || isOver == null) {
      print('Warning: updateGame called with null or incomplete values. Update ignored.');
      return;
    }

    print("Updating Game State:");
    print("ID: $id, Players: $players, isJoin: $isJoin, isOver: $isOver, winner: $winner");

    _gameState = GameState(
      id: id,
      players: players,
      isJoin: isJoin,
      isOver: isOver,
      winner: winner,
    );

    notifyListeners();
  }

  void resetGameState() {
    _gameState = GameState(id: '', players: [], isJoin: true, isOver: false, winner: 'rat');
    notifyListeners();
  }
}
