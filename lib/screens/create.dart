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
  final SocketMethods _methods = SocketMethods();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final gameStateProvider = Provider.of<GameStateProvider>(
      context,
      listen: false,
    );

    // ✅ Pass the provider instance instead of calling Provider.of in the method
    _methods.updateGameListener(context, gameStateProvider);
  }

  @override
  void dispose() {
    _controller.dispose();
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
                      Image.asset('assets/images/create_cat.png'),
                      SizedBox(height: 25),
                      Text(
                        "Create Room",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      SizedBox(height: 20),
                      CustomTextfield(
                        textcontroller: _controller,
                        hint: "Enter ur nickname",
                      ),
                      SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          _methods.createGame(_controller.text, context);
                        },
                        child: Image.asset(
                          'assets/images/create.png', // Use your join button image
                          width: 300, // Adjust as needed
                          fit: BoxFit.contain,
                        ),
                      ),
                      // MyButton(
                      //   value: "Create",
                      //   onTap: () {
                      //     _methods.createGame(_controller.text, context);
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
