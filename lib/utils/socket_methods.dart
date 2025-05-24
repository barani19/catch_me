import 'package:catch_me/services/clientstate.dart';
import 'package:provider/provider.dart';
import 'package:catch_me/services/game_state_provider.dart';
import 'package:catch_me/utils/socket.dart';
import 'package:catch_me/widgets/bottom_alert.dart';
import 'package:flutter/material.dart';

class SocketMethods {
  final _socketClient = SocketClient.instance.socket!;
  bool _isPlaying = false;

  createGame(String name, BuildContext context) {
    if (_isPlaying) return;
    if (name.isNotEmpty) {
      _socketClient.emit('create-game', {'NickName': name});
    } else {
      BottomAlert(context, 'Please enter the user name');
    }
  }

  JoinGame(String NickName, String GameId, BuildContext context) {
    if (NickName.isNotEmpty && GameId.isNotEmpty) {
      _socketClient.emit('join-game', {'NickName': NickName, 'gameId': GameId});
    } else {
      BottomAlert(context, "Please enter the valid room Id!!!");
    }
  }

  updateGameListener(
    BuildContext context,
    GameStateProvider gameStateProvider,
  ) {
    _socketClient.on('updateGame', (data) {
      print(data);

      // ✅ Use the provided GameStateProvider instead of looking it up
      gameStateProvider.updateGame(
        id: data['_id'],
        players: data['players'],
        isJoin: data['isJoin'],
        isOver: data['isOver'],
      );

      if (data['_id'].isNotEmpty && !_isPlaying) {
        Navigator.pushNamed(context, '/game-screen');
        _isPlaying = true;
      }
    });
  }

  updateGame(BuildContext context) {
    _socketClient.on('updateGame', (data) {
      print(data);
      final gameState = Provider.of<GameStateProvider>(
        context,
        listen: false,
      );
       // ignore: invalid_use_of_protected_member
       if (!gameState.hasListeners) {
      debugPrint("GameStateProvider is disposed, skipping update.");
      return;
    }
      gameState.updateGame(
        id: data['_id'],
        players: data['players'],
        isJoin: data['isJoin'],
        isOver: data['isOver'],
      );
    });
  }

  RoomFull(BuildContext context) {
    _socketClient.on('room-full', (data) => {BottomAlert(context, data)});
  }

  startTimer(playerId, gameId) {
    _socketClient.emit('timer', {'playerId': playerId, 'gameId': gameId});
  }

  updateTimer(BuildContext context) {
    final clientstateProvider = Provider.of<ClientstateProvider>(
      context,
      listen: false,
    );
    _socketClient.on('timer', (data) {
      clientstateProvider.setClientState(data);
    });
  }

  updatePos(playerId, gameId, row, col) {
    _socketClient.emit('move', {
      'playerId': playerId,
      'gameId': gameId,
      'row': row,
      'col': col,
    });
  }

  gameOver(BuildContext context, gameId) {
    _socketClient.emit('game-over', {'gameId': gameId});
  }

  gameFinishedListener(BuildContext context) {
  _socketClient.on("done", (data) {
    _socketClient.off('timer');
    _socketClient.off('updateGame');

    // ✅ Reset timer state
    Provider.of<ClientstateProvider>(
      context,
      listen: false,
    ).resetClientState();

    // ✅ Mark game as over
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

    // ✅ Reset _isPlaying flag so a new game can be started
    _isPlaying = false;
  });
}

void clearAllListeners() {
  _socketClient.off('updateGame');
  _socketClient.off('room-full');
  _socketClient.off('timer');
  _socketClient.off('done');
  // Add more as needed (e.g., player-move, player-disconnect, etc.)
}


}
