import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String value;
  final VoidCallback onTap;
  const MyButton({super.key, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          fixedSize: Size(width, 50),
        ),
        onPressed: onTap,
        child: Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
