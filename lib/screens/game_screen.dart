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
  final SocketMethods _socketMethods = SocketMethods();
  Map<String, dynamic>? playerMe;
  Map<String, dynamic>? anotherPlayer;
  Map<String, dynamic>? cat;
  Map<String, dynamic>? rat;
  late GameStateProvider game;

  @override
  void initState() {
    super.initState();
    _socketMethods.updateGame(context);
    _socketMethods.updateTimer(context);
    _socketMethods.gameFinishedListener(context);
  }

  // @override
  // void dispose() {
  //   game.dispose();
  //   super.dispose();
  // }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    game = Provider.of<GameStateProvider>(context);
    findPlayerMe(game);

    if (playerMe != null && game.gameState['players'].length >= 2) {
      anotherPlayer = game.gameState['players'].firstWhere(
        (player) => player['socketId'] != playerMe!['socketId'],
        orElse: () => null,
      );

      if (anotherPlayer != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              if (playerMe!['isPartyLeader'] == true) {
                cat = playerMe!;
                rat = anotherPlayer!;
              } else {
                rat = playerMe!;
                cat = anotherPlayer!;
              }
            });

            if (cat != null &&
                rat != null &&
                cat!['currRow'] == rat!['currRow'] &&
                cat!['currCol'] == rat!['currCol']) {
              _socketMethods.gameOver(context, game.gameState['id']);
              game.updateGame(
                id: game.gameState['id'],
                players: game.gameState['players'],
                isJoin: game.gameState['isJoin'],
                isOver: true,
                winner: 'cat',
              );
            }
          }
        });
      }
    }
  }

  void findPlayerMe(GameStateProvider game) {
    playerMe = game.gameState['players'].firstWhere(
      (player) => player['socketId'] == SocketClient.instance.socket?.id,
      orElse: () => null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameStateProvider>(context, listen: false);
    final client = Provider.of<ClientstateProvider>(context); // 👈 Rebuilds on timer updates

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
                        Text(
                          client.clientState['timer']['Msg']?.toString() ?? game.gameState['id'],
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Text(
                          client.clientState['timer']['countDown']?.toString() ?? game.gameState['id'].toString(),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 10),
                        game.gameState['isJoin']
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Copy room Id',
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      Clipboard.setData(
                                        ClipboardData(text: game.gameState['id'] ?? ''),
                                      ).then((value) {
                                        BottomAlert(context, 'Game code copied to clipboard!!');
                                      });
                                    },
                                    icon: const Icon(Icons.copy),
                                  ),
                                ],
                              )
                            : SizedBox(
                                height: MediaQuery.of(context).size.width * 0.7,
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
                            : GameController(
                                r: int.tryParse(playerMe?['currRow']?.toString() ?? '0') ?? 0,
                                c: int.tryParse(playerMe?['currCol']?.toString() ?? '0') ?? 0,
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
