import 'package:catch_me/screens/home.dart';
import 'package:catch_me/services/game_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EndScreen extends StatefulWidget {
  const EndScreen({super.key});

  @override
  State<EndScreen> createState() => _EndScreenState();
}

class _EndScreenState extends State<EndScreen> {

  bool _isNavigating = false;

  Future<void> _navigateToHome() async {
    if (_isNavigating || !mounted) return;
    _isNavigating = true;

    try {
      // Wait for current frame to complete
      await Future.delayed(Duration.zero);

      if (!mounted) return;

      // Use root navigator to completely clear the stack
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
      String winner = Provider.of<GameStateProvider>(context).gameState['winner'];
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