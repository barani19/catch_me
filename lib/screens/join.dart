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
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _gameIdController = TextEditingController();

  final SocketMethods _socketMethods = SocketMethods.instance;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final gameStateProvider = Provider.of<GameStateProvider>(
      context,
      listen: false,
    );

    // Use the new initializeListeners method that sets up all listeners at once
    _socketMethods.initializeListeners(context, gameStateProvider);
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _gameIdController.dispose();
    _socketMethods.clearAllListeners(); // Clear socket listeners to avoid leaks
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
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/join_rat.png'),
                      const SizedBox(height: 25),
                      Text(
                        "Join Room",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 20),
                      CustomTextfield(
                        textcontroller: _nicknameController,
                        hint: "Enter your nickname",
                      ),
                      const SizedBox(height: 20),
                      CustomTextfield(
                        textcontroller: _gameIdController,
                        hint: "Enter Room ID",
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          final nickname = _nicknameController.text.trim();
                          final gameId = _gameIdController.text.trim();

                          _socketMethods.joinGame(nickname, gameId, context);
                        },
                        child: Image.asset(
                          'assets/images/join.png',
                          width: 300,
                          fit: BoxFit.contain,
                        ),
                      ),
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
