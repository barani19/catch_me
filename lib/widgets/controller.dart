import 'package:catch_me/utils/socket_methods.dart';
import 'package:flutter/material.dart';

class GameController extends StatefulWidget {
  final int r;
  final int c;
  final int len;
  final String playerId;
  final String gameId;

  const GameController({
    super.key,
    required this.r,
    required this.c,
    required this.len,
    required this.playerId,
    required this.gameId,
  });

  @override
  State<GameController> createState() => _GameControllerState();
}

class _GameControllerState extends State<GameController> {
  late int playerX;
  late int playerY;
  final _sockmethods = SocketMethods();

  // List of obstacles
  final List<List<int>> obstacles = [
    [1, 1],
    [1, 3],
    [3, 2],
    [3, 0],
  ];

  @override
  void initState() {
    super.initState();
    playerX = widget.r;
    playerY = widget.c;
  }

  void movePlayer(int dx, int dy) {
    int newX = playerX + dx;
    int newY = playerY + dy;

    // Check boundaries and if the new position is NOT an obstacle
    if (newX >= 0 &&
        newX < widget.len &&
        newY >= 0 &&
        newY < widget.len &&
        !obstacles.any((pos) => pos[0] == newX && pos[1] == newY)) {
      setState(() {
        playerX = newX;
        playerY = newY;
        _sockmethods.updatePos(
          widget.playerId,
          widget.gameId,
          playerX,
          playerY,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Text(
        //   "Player Position: ($playerX, $playerY)",
        //   style: TextStyle(fontSize: 20),
        // ),
        // const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => movePlayer(0, -1),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.yellow,
                ),
                child: const Icon(Icons.arrow_drop_up, size: 30),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => movePlayer(-1, 0),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.yellow,
                ),
                child: const Icon(Icons.arrow_left, size: 30),
              ),
            ),
            const SizedBox(width: 50),
            GestureDetector(
              onTap: () => movePlayer(1, 0),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.yellow,
                ),
                child: const Icon(Icons.arrow_right, size: 30),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => movePlayer(0, 1),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.yellow,
                ),
                child: const Icon(Icons.arrow_drop_down, size: 30),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
