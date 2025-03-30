import 'package:catch_me/services/game_state_provider.dart';
import 'package:catch_me/utils/socket_methods.dart';
import 'package:catch_me/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class JoinScreen extends StatefulWidget {
  const JoinScreen({super.key});

  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _gameIdcontroller = TextEditingController();

  final SocketMethods _socketMethods = SocketMethods();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _socketMethods.RoomFull(context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final gameStateProvider = Provider.of<GameStateProvider>(
      context,
      listen: false,
    );

    // ✅ Pass the provider instance instead of calling Provider.of in the method
    _socketMethods.updateGameListener(context, gameStateProvider);
  }

  @override
  void dispose() {
    _controller.dispose();
    _gameIdcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/catch_me_bg.jpeg",
              fit: BoxFit.cover,
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 600),
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/join_rat.png'),
                      SizedBox(height: 25),
                      Text(
                        "Join Room",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      SizedBox(height: 20),
                      CustomTextfield(
                        textcontroller: _controller,
                        hint: "Enter ur nickname",
                      ),
                      SizedBox(height: 20),
                      CustomTextfield(
                        textcontroller: _gameIdcontroller,
                        hint: "Enter ur GameId",
                      ),
                      SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          _socketMethods.JoinGame(
                            _controller.text,
                            _gameIdcontroller.text,
                            context,
                          );
                        },
                        child: Image.asset(
                          'assets/images/join.png', // Use your join button image
                          width: 300, // Adjust as needed
                          fit: BoxFit.contain,
                        ),
                      ),
                      // MyButton(
                      //   value: "Join",
                      //   onTap: () {
                      //     _socketMethods.JoinGame(
                      //       _controller.text,
                      //       _gameIdcontroller.text,
                      //       context,
                      //     );
                      //   },
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
