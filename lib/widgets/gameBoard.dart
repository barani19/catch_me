import 'package:catch_me/services/game_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Gameboard extends StatefulWidget {
  final int? catX;
  final int? catY;
  final int? ratX;
  final int? ratY;

  const Gameboard({super.key, this.catX, this.catY, this.ratX, this.ratY});

  @override
  State<Gameboard> createState() => _GameboardState();
}

class _GameboardState extends State<Gameboard> {
  // Define obstacle positions (x, y)
  final List<List<int>> obstacles = [
    [1, 1],
    [1, 3],
    [3, 2],
    [3, 0],
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<GameStateProvider>(
      builder: (context, game, child) {
        return Column(
          children: [
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.zero, // Removes outer spacing
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 0, // No vertical spacing
                  crossAxisSpacing: 0, // No horizontal spacing
                ),
                itemCount: 5 * 5,
                itemBuilder: (context, index) {
                  int x = index % 5;
                  int y = index ~/ 5;

                  bool isCat = (x == widget.catX && y == widget.catY);
                  bool isRat = (x == widget.ratX && y == widget.ratY);
                  bool isObstacle = obstacles.any(
                    (pos) => pos[0] == x && pos[1] == y,
                  );

                  return Container(
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: AssetImage("assets/images/board.png"),
                        fit: BoxFit.cover, // Ensures full coverage
                      ),
                    ),
                    child: Center(
                      child:
                          isCat
                              ? Image.asset(
                                "assets/images/cat.png",
                                width: 75,
                                height: 75,
                              )
                              : isRat
                              ? Image.asset(
                                "assets/images/rat.png",
                                width: 75,
                                height: 75,
                              )
                              : isObstacle
                              ? Image.asset(
                                "assets/images/obstacle.png",
                                width: 50,
                                height: 150,
                                // fit: BoxFit.cover,
                              ) // Obstacle image
                              : null,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
