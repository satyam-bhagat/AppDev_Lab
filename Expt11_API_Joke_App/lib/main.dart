import 'package:flutter/material.dart';
import 'package:joke_app/Screens/joke_screen.dart';

void main() {
  runApp(const JokeApp());
}

class JokeApp extends StatelessWidget {
  const JokeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: JokeScreen(),
    );
  }
}
