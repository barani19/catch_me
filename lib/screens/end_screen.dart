import 'package:catch_me/screens/home.dart';
import 'package:catch_me/services/clientstate.dart';
import 'package:catch_me/services/game_state_provider.dart';
import 'package:catch_me/utils/socket_methods.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EndScreen extends StatefulWidget {
  const EndScreen({super.key});

  @override
  State<EndScreen> createState() => _EndScreenState();
}

class _EndScreenState extends State<EndScreen> {
  String winner = "";
  bool _isNavigating = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final gameStateProvider = Provider.of<GameStateProvider>(
      context,
      listen: false,
    );
    winner = gameStateProvider.gameState['winner'];
  }

  Future<void> _navigateToHome() async {
  if (_isNavigating || !mounted) return;
  _isNavigating = true;

  try {
    // Clear socket listeners
    SocketMethods().clearAllListeners();

    // Reset states
    Provider.of<GameStateProvider>(context, listen: false).resetGameState();
    Provider.of<ClientstateProvider>(context, listen: false).resetClientState();

    if (!mounted) return;

    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  } catch (e) {
    debugPrint('Navigation error: $e');
    if (mounted) {
      setState(() => _isNavigating = false);
    }
  }
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
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                winner == 'cat'
                    ? Image.asset('assets/images/cat_win_1.png')
                    : Image.asset('assets/images/rat_win.png'),
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: _navigateToHome,
                  child: Image.asset(
                    'assets/images/home.png',
                    width: 300,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
