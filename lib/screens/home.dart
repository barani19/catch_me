import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {


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
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 600),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Spacer(),
                  Image.asset('assets/images/logo.png', height: 130),
                  Spacer(),
                  Image.asset('assets/images/charac_bg.png'),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed('/create-game');
                    },
                    child: Image.asset(
                      'assets/images/create.png', // Use your join button image
                      width: 300, // Adjust as needed
                      fit: BoxFit.contain,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed('/join-game');
                    },
                    child: Image.asset(
                      'assets/images/join.png', // Use your join button image
                      width: 300, // Adjust as needed
                      fit: BoxFit.contain,
                    ),
                  ),
                  Spacer(),
                  
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
