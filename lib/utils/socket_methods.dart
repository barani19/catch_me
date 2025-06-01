import 'package:catch_me/services/clientstate.dart';
import 'package:catch_me/services/game_state_provider.dart';
import 'package:catch_me/utils/socket.dart';
import 'package:catch_me/widgets/bottom_alert.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SocketMethods {
  // Singleton Implementation
  SocketMethods._internal();
  static final SocketMethods _instance = SocketMethods._internal();
  static SocketMethods get instance => _instance;

  final _socketClient = SocketClient.instance.socket!;
  bool _isPlaying = false;

  // ------------------------
  // Setup socket event listeners
  // ------------------------
  void initializeListeners(BuildContext context, GameStateProvider gameStateProvider) {
    // Clear previous listeners before adding new ones to avoid duplicates
    clearAllListeners();

    _socketClient.on('updateGame', (data) {
      debugPrint('updateGame: $data');

      gameStateProvider.updateGame(
        id: data['_id'],
        players: data['players'],
        isJoin: data['isJoin'],
        isOver: data['isOver'],
      );

      final String gameId = (data['_id'] ?? '').toString();

      if (gameId.isNotEmpty && !_isPlaying) {
        Navigator.pushNamed(context, '/game-screen');
        _isPlaying = true;
      }
    });

    _socketClient.on('room-full', (data) {
      BottomAlert(context, data?.toString() ?? 'Room full');
    });

    _socketClient.on('timer', (data) {
      final clientStateProvider = Provider.of<ClientstateProvider>(
        context,
        listen: false,
      );
      clientStateProvider.setClientState(data);
    });

    _socketClient.on("done", (data) {
      debugPrint('Game done: $data');

      // Remove listeners to prevent duplicate firing
      clearAllListeners();

      Provider.of<ClientstateProvider>(
        context,
        listen: false,
      ).resetClientState();

      final gameStateProvider = Provider.of<GameStateProvider>(
        context,
        listen: false,
      );

      gameStateProvider.updateGame(
        id: gameStateProvider.gameState['id'],
        players: gameStateProvider.gameState['players'],
        isJoin: gameStateProvider.gameState['isJoin'],
        isOver: true,
      );

      _isPlaying = false;
    });
  }

  // ------------------------
  // Clear all socket listeners
  // ------------------------
  void clearAllListeners() {
    _socketClient.off('updateGame');
    _socketClient.off('room-full');
    _socketClient.off('timer');
    _socketClient.off('done');
  }

  // ------------------------
  // Reset the _isPlaying flag manually if needed
  // ------------------------
  void resetPlayingFlag() {
    _isPlaying = false;
  }

  // ------------------------
  // Other socket emit methods unchanged
  // ------------------------

  void createGame(String name, BuildContext context) {
    if (_isPlaying) return;
    if (name.trim().isNotEmpty) {
      resetPlayingFlag(); // Reset before starting new game
      _socketClient.emit('create-game', {'NickName': name.trim()});
    } else {
      BottomAlert(context, 'Please enter the user name');
    }
  }

  void joinGame(String nickName, String gameId, BuildContext context) {
    if (nickName.trim().isNotEmpty && gameId.trim().isNotEmpty) {
      resetPlayingFlag(); // Reset before joining new game
      _socketClient.emit('join-game', {
        'NickName': nickName.trim(),
        'gameId': gameId.trim(),
      });
    } else {
      BottomAlert(context, "Please enter the valid room ID!");
    }
  }

  void startTimer(String playerId, String gameId) {
    _socketClient.emit('timer', {
      'playerId': playerId,
      'gameId': gameId,
    });
  }

  void updatePos(String playerId, String gameId, int row, int col) {
    _socketClient.emit('move', {
      'playerId': playerId,
      'gameId': gameId,
      'row': row,
      'col': col,
    });
  }

  void gameOver(String gameId) {
    _socketClient.emit('game-over', {'gameId': gameId});
  }
}
