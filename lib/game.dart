import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_2d_snake_game/control_panel.dart';
import 'package:flutter_2d_snake_game/piece.dart';
import 'dart:math';
import 'package:flutter_2d_snake_game/direction.dart';

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late int upperBoundX, upperBoundY, lowerBoundX, lowerBoundY;
  late double screenWidth, screenHeight;
  int step = 30;
  int length = 5;
  Direction direction = Direction.right;
  Offset? foodPosition;
  late Piece food;
  //List is the variable type , Offset is the array object, Offset is more like a point. Point has X and Y values.
  List<Offset> positions = []; // Initialize it to an empty array.
  int score = 0;
  double speed = 1.0;
  Timer? timer;

  void changeSpeed() {
    // ! is the null operator
    if (timer != null && timer!.isActive) {
      timer!.cancel();
    }
    timer = Timer.periodic(Duration(milliseconds: 200), (timer) {
      setState(() {});
    });
  }

  Widget getControls() {
    return ControlPanel(
      onTapped: (Direction newDirection) {
        direction = newDirection;
      },
    );
  }

  void restart() {
    // Default values to be used when the game gets restarted.
    length = 5;
    score = 0;
    speed = 1;
    positions = [];
    direction = getRandomDirection();
    changeSpeed();
  }

  Direction getRandomDirection() {
    int val = Random().nextInt(4);
    direction = Direction.values[val];
    return direction;
  }

  @override
  initState() {
    super.initState();
    restart();
  }

  int getNearestTens(int num) {
    int output;
    // ~/ - returns nearest complete integer
    output = (num ~/ step) * step;
    if (output == 0) {
      output += step;
    }
    return output;
  }

  // To draw something on the screen first we need to have position then we can create an object create draw()
  void draw() async {
    if (positions.isEmpty) {
      positions.add(getRandomPosition());
    }
    // By while loop the length becomes 5 but it has some positions.
    while (length > positions.length) {
      positions.add(positions[positions.length - 1]);
    }
    // To change their positions it should look like the snake is moving.
    // To move it we need to change the position.

    for (var i = positions.length - 1; i > 0; i--) {
      positions[i] = positions[i - 1];
    }
    // if i is 5 -1 = 4 so i positions[4] = positions[4-1] = positions[3]
    // 4 <-3
    // 3 <-2
    // 2 <-1
    // 1 <-0
    positions[0] = getNextPosition(positions[0]) as Offset;
  }

  void drawFood() {
    if (foodPosition == null) {
      foodPosition = getRandomPosition();
    }

    if (foodPosition == positions[0]) {
      length++;
      score = score + 5;
      speed = speed + 0.25;
      foodPosition = getRandomPosition();
    }

    food = Piece(
        isAnimated: true,
        color: Colors.red,
        size: step,
        posX: foodPosition!.dx.toInt(),
        posY: foodPosition!.dy.toInt());
  }

  bool detectCollision(Offset position) {
    if (timer != null && timer!.isActive) {
      timer!.cancel();
    }

    if (position.dx >= upperBoundX && direction == Direction.right) {
      return true;
    } else if (position.dx <= lowerBoundX && direction == Direction.left) {
      return true;
    } else if (position.dy >= upperBoundY && direction == Direction.down) {
      return true;
    } else if (position.dy <= lowerBoundY && direction == Direction.up) {
      return true;
    }
    return false;
  }

  void showGameOverDialog() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (ctx) {
          return AlertDialog(
            backgroundColor: Colors.red,
            shape: const RoundedRectangleBorder(
              side: BorderSide(
                color: Colors.blue,
                width: 30,
              ),
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            title: const Text(
              "Game Over",
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              "Your game is over but you played well. Your score is" +
                  score.toString() +
                  '.',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  restart();
                },
                child: const Text(
                  "Restart",
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          );
        });
  }

  Future<Offset> getNextPosition(Offset position) async {
    late Offset nextPosition;
    if (direction == Direction.right) {
      nextPosition = Offset(position.dx + step, position.dy);
    } else if (direction == Direction.left) {
      nextPosition = Offset(position.dx - step, position.dy);
    } else if (direction == Direction.up) {
      nextPosition = Offset(position.dx, position.dy - step);
    } else if (direction == Direction.down) {
      nextPosition = Offset(position.dx, position.dy + step);
    }

    if (detectCollision(position) == true) {
      await Future.delayed(
          Duration(milliseconds: 200), () => showGameOverDialog());
    }

    return nextPosition;
  }

  Offset getRandomPosition() {
    Offset position;

    // It makes sure everything stays between upX and lowX, same applies to posY
    int posX = Random().nextInt(upperBoundX) + lowerBoundX;
    int posY = Random().nextInt(upperBoundY) + lowerBoundY;

    // Wrap everything of Offset
    position = Offset(
        getNearestTens(posX).toDouble(), getNearestTens(posY).toDouble());

    detectCollision(position) == true;

    return position;
  }

  // List is the type of function , Piece is the object
  List<Piece> getPieces() {
    final pieces = <Piece>[];
    draw(); //5
    drawFood(); //5
    for (var i = 0; i < length; ++i) {
      // Error occurs when the snake eats the food length of snake is 5 and by eating it. It cannot become 6 so define a if condition in for loop in getPieces()
      if (i >= positions.length) {
        continue;
      }
      pieces.add(Piece(
        posX: positions[i].dx.toInt(),
        posY: positions[i].dy.toInt(),
        size: step,
        // Ternary operator is used. To show different colors.
        color: i.isEven ? Colors.red : Colors.green,
        isAnimated: false,
      ));
    }
    return pieces;
  }

  Widget getScore() {
    return Positioned(
      child: Text(
        "Score :" + score.toString(),
        style: const TextStyle(fontSize: 30, color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    lowerBoundX = step;
    lowerBoundY = step;
    upperBoundX = getNearestTens(screenWidth.toInt() - step);
    upperBoundY = getNearestTens(screenHeight.toInt() - step);

    return Scaffold(
      body: Container(
        color: Colors.amber,
        child: Stack(
          children: [
            Stack(
              children: getPieces(),
            ),
            getControls(),
            food,
            getScore(),
          ],
        ),
      ),
    );
  }
}
