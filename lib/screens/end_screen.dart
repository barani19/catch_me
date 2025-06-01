import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:catch_me/screens/home.dart';
import 'package:catch_me/services/clientstate.dart';
import 'package:catch_me/services/game_state_provider.dart';
import 'package:catch_me/utils/socket_methods.dart';

class EndScreen extends StatefulWidget {
  const EndScreen({super.key});

  @override
  State<EndScreen> createState() => _EndScreenState();
}

class _EndScreenState extends State<EndScreen> {
  String winner = "";
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();

    // Safely access context after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gameStateProvider = Provider.of<GameStateProvider>(
        context,
        listen: false,
      );

      setState(() {
        winner = gameStateProvider.gameState['winner'] ?? "";
      });
    });
  }

  Future<void> _navigateToHome() async {
    if (_isNavigating || !mounted) return;
    setState(() {
      _isNavigating = true;
    });

    try {
      // Clear socket listeners using singleton
      SocketMethods.instance.clearAllListeners();

      // Reset game and client state
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
          SafeArea(
            child: Center(
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
                  const SizedBox(height: 20),
                  // Debug only: show winner text
                  Text(
                    'Winner: $winner',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
