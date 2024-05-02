import 'package:flutter/material.dart';
import 'package:flutter_2d_snake_game/game.dart';

void main() => runApp(SnakeGame());

class SnakeGame extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GamePage(),
    );
  }
}
