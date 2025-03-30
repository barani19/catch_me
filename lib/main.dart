import 'package:catch_me/screens/create.dart';
import 'package:catch_me/screens/game_screen.dart';
import 'package:catch_me/screens/home.dart';
import 'package:catch_me/screens/join.dart';
import 'package:catch_me/screens/splash_screen.dart';
import 'package:catch_me/services/clientstate.dart';
import 'package:catch_me/services/game_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ClientstateProvider()),
        ChangeNotifierProvider(create: (context) => GameStateProvider()),
      ],
      child: MaterialApp(
        home: SplashScreen(),
        theme: ThemeData(
          fontFamily: 'Poppins',
          textTheme: TextTheme(
            bodyLarge: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 25,
              color: Colors.white,
            ), // Default text style for large text
          ),
        ),
        initialRoute: '/',
        routes: {
          '/home': (context) => HomeScreen(),
          '/create-game': (context) => CreateScreen(),
          '/join-game': (context) => JoinScreen(),
          '/game-screen': (context) => GameScreen(),
        },
      ),
    );
  }
}
