import 'package:catch_me/services/game_state_provider.dart';
import 'package:catch_me/utils/socket_methods.dart';
import 'package:catch_me/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  final TextEditingController _controller = TextEditingController();
  final SocketMethods _methods = SocketMethods.instance;

  bool _listenersInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_listenersInitialized) {
      final gameStateProvider = Provider.of<GameStateProvider>(
        context,
        listen: false,
      );

      _methods.resetPlayingFlag();  // Reset flag when entering create screen

      _methods.initializeListeners(context, gameStateProvider);

      _listenersInitialized = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _methods.clearAllListeners();
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
                      Image.asset('assets/images/create_cat.png'),
                      const SizedBox(height: 25),
                      Text(
                        "Create Room",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 20),
                      CustomTextfield(
                        textcontroller: _controller,
                        hint: "Enter your nickname",
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          final nickname = _controller.text.trim();
                          _methods.createGame(nickname, context);
                        },
                        child: Image.asset(
                          'assets/images/create.png',
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
