import 'package:catch_me/screens/end_screen.dart';
import 'package:catch_me/services/clientstate.dart';
import 'package:catch_me/services/game_state_provider.dart';
import 'package:catch_me/utils/socket.dart';
import 'package:catch_me/utils/socket_methods.dart';
import 'package:catch_me/widgets/bottom_alert.dart';
import 'package:catch_me/widgets/controller.dart';
import 'package:catch_me/widgets/gameBoard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final SocketMethods _socketMethods = SocketMethods.instance;

  Map<String, dynamic>? playerMe;
  Map<String, dynamic>? anotherPlayer;
  Map<String, dynamic>? cat;
  Map<String, dynamic>? rat;

  late GameStateProvider game;
  bool _listenersInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_listenersInitialized) {
      game = Provider.of<GameStateProvider>(context);
      _socketMethods.initializeListeners(context, game);
      _listenersInitialized = true;
    }

    game = Provider.of<GameStateProvider>(context);

    playerMe = findPlayerBySocketId(game.gameState['players'], SocketClient.instance.socket?.id);

    assignRoles();

    if (cat != null &&
        rat != null &&
        cat!['currRow'] == rat!['currRow'] &&
        cat!['currCol'] == rat!['currCol']) {
      // Game over, cat caught rat
      _socketMethods.gameOver(game.gameState['id']);
      game.updateGame(
        id: game.gameState['id'],
        players: game.gameState['players'],
        isJoin: game.gameState['isJoin'],
        isOver: true,
        winner: 'cat',
      );
    }
  }

  /// Find player by socket ID safely
  Map<String, dynamic>? findPlayerBySocketId(List players, String? socketId) {
    try {
      return players.firstWhere((p) => p['socketId'] == socketId);
    } catch (_) {
      return null;
    }
  }

  /// Assign cat and rat roles based on party leader
  void assignRoles() {
    if (playerMe == null || game.gameState['players'].length < 2) {
      cat = null;
      rat = null;
      return;
    }

    try {
      anotherPlayer = game.gameState['players']
          .firstWhere((p) => p['socketId'] != playerMe!['socketId']);
    } catch (_) {
      anotherPlayer = null;
    }

    if (anotherPlayer == null) {
      cat = null;
      rat = null;
      return;
    }

    // Assign roles
    if (playerMe!['isPartyLeader'] == true) {
      if (cat != playerMe || rat != anotherPlayer) {
        setState(() {
          cat = playerMe;
          rat = anotherPlayer;
        });
      }
    } else {
      if (rat != playerMe || cat != anotherPlayer) {
        setState(() {
          rat = playerMe;
          cat = anotherPlayer;
        });
      }
    }
  }

  @override
  void dispose() {
    _socketMethods.clearAllListeners();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameStateProvider>(context);
    final client = Provider.of<ClientstateProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                "assets/images/catch_me_bg.jpeg",
                fit: BoxFit.cover,
              ),
            ),
            Center(
              child: game.gameState['isOver']
                  ? const EndScreen()
                  : Column(
                      children: [
                        // Show timer messages or game ID as fallback
                        Text(
                          client.clientState['timer']?['Msg']?.toString() ??
                              game.gameState['id'],
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Text(
                          client.clientState['timer']?['countDown']?.toString() ??
                              game.gameState['id'].toString(),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 10),

                        // Copy Room ID when joined
                        game.gameState['isJoin']
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Copy room Id',
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      Clipboard.setData(
                                        ClipboardData(
                                            text: game.gameState['id'] ?? ''),
                                      ).then((_) {
                                        BottomAlert(
                                            context, 'Game code copied!');
                                      });
                                    },
                                    icon: const Icon(Icons.copy),
                                  ),
                                ],
                              )
                            // Show game board or loading spinner when playing
                            : SizedBox(
                                height:
                                    MediaQuery.of(context).size.width * 0.7,
                                width: MediaQuery.of(context).size.width * 0.7,
                                child: (cat != null && rat != null)
                                    ? Gameboard(
                                        catX: cat!['currRow'],
                                        catY: cat!['currCol'],
                                        ratX: rat!['currRow'],
                                        ratY: rat!['currCol'],
                                      )
                                    : const CircularProgressIndicator(),
                              ),

                        const Spacer(),

                        // Start button if in join mode & players count check
                        game.gameState['isJoin']
                            ? GestureDetector(
                                onTap: () {
                                  if (game.gameState['players'].length == 2) {
                                    _socketMethods.startTimer(
                                      playerMe!['_id'],
                                      game.gameState['id'],
                                    );
                                  } else {
                                    BottomAlert(context, 'Insufficient players..');
                                  }
                                },
                                child: Image.asset(
                                  'assets/images/start.png',
                                  width: 300,
                                  fit: BoxFit.contain,
                                ),
                              )
                            // Game controller UI
                            : GameController(
                                r: int.tryParse(
                                        playerMe?['currRow']?.toString() ?? '0') ??
                                    0,
                                c: int.tryParse(
                                        playerMe?['currCol']?.toString() ?? '0') ??
                                    0,
                                len: 5,
                                gameId: game.gameState['id'],
                                playerId: playerMe?['_id'] ?? '',
                              ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
