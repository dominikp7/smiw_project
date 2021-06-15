import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smiw_project/Bat2.dart';
import 'ball.dart';
import 'bat.dart';
import 'Bat2.dart';
import 'menuoptionsscreen.dart';
import 'main.dart';

enum Direction { up, down, left, right }

class Pong extends StatefulWidget {
  @override
  _PongState createState() => _PongState();
}

class _PongState extends State<Pong> with SingleTickerProviderStateMixin {

  double width;
  double height;
  double posX;
  double posY;
  double batWidth;
  double batHeight;
  double batPosition = 0;
  double bat2Width;
  double bat2Height;
  double bat2Position = 0;
  Direction vDir = Direction.down;
  Direction hDir = Direction.right;
  Animation<double> animation;
  AnimationController controller;
  double increment = 5;
  double randX = 1;
  double randY = 1;
  int score = 0;

  @override
  void initState() {
    super.initState();
    posX = 0;
    posY = 0;
    controller = AnimationController(
      duration: const Duration(hours: 999999),
      vsync: this,
    );

    animation = Tween<double>(begin: 0, end: 100).animate(controller);
    animation.addListener(() {
      setState(() {
        checkBorders();
        (hDir == Direction.right)
            ? posX += ((increment * randX).round())
            : posX -= ((increment * randX).round());
        (vDir == Direction.down)
            ? posY += ((increment * randY).round())
            : posY -= ((increment * randY).round());
      });

      checkBorders();
    });


    controller.forward();
  }

  Future<bool> _onWillPop() async {
    controller.stop();
    return (await showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Are you sure?'),
        content: new Text('Do you want to exit an App'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              controller.forward();
              Navigator.of(context).pop(false);

            },
            child: new Text('No'),
          ),
          TextButton(
            onPressed: () {
              controller.stop();
              Navigator.of(context).pop(true);
            },
            child: new Text('Yes'),
          ),
        ],
      ),
    )) ?? false;
  }



  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPop,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            height = constraints.maxHeight;
            width = constraints.maxWidth;
            batWidth = width / 5;
            batHeight = height / 20;
            bat2Width = batWidth;
            bat2Height = batHeight;

            return Stack(
              children: <Widget>[
                Positioned(
                  top: 0,
                  right: 24,
                  child: Text('Score: ' + score.toString()),
                ),

                Positioned(
                  child: Ball(),
                  top: posY,
                  left: posX,
                ),
                Positioned(
                    bottom: 7,
                    left: batPosition,
                    child: GestureDetector(
                        onHorizontalDragUpdate: (DragUpdateDetails update) =>
                            moveBat(update, context),
                        child: Bat(batWidth, batHeight))),
                Positioned(
                    top: 7,
                    left: bat2Position,
                    child: GestureDetector(
                        onHorizontalDragUpdate: (DragUpdateDetails update) =>
                            moveBat2(update, context),
                        child: Bat2(bat2Width, bat2Height))),
              ],
            );
          }
      ),
    );
  }

  void checkBorders() {
    double diameter = 50;
    if (posX <= 0 && hDir == Direction.left) {
      hDir = Direction.right;
      randX = randomNumber();
    }
    if (posX >= width - diameter && hDir == Direction.right) {
      hDir = Direction.left;
      randX = randomNumber();
    }
    if (posY >= height - diameter - batHeight && vDir == Direction.down) {
      if (posX >= (batPosition - diameter) &&
          posX <= (batPosition + batWidth + diameter)) {
        vDir = Direction.up;
        randY = randomNumber();
        setState(() {
          score++;
        });
      } else {
        controller.stop();
        showMessage(context);
      }
    }



    if (posY <= 0 && vDir == Direction.up) {
      vDir = Direction.down;
      randX = randomNumber();
    }
  }

  void moveBat(DragUpdateDetails update, BuildContext context) {
    setState(() {
      batPosition += update.delta.dx;
    });
  }

  void moveBat2(DragUpdateDetails update, BuildContext context) {
    setState(() {
      bat2Position += update.delta.dx;
    });
  }

  double randomNumber() {
    var ran = new Random();
    int myNum = ran.nextInt(100);
    return (50 + myNum) / 100;
  }

  void showMessage(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Game Over'),
            content: Text('Would you like to play again?'),
            actions: <Widget>[
              // ignore: deprecated_member_use
              FlatButton(
                child: Text('Yes'),
                onPressed: () {
                  setState(() {
                    posX = 0;
                    posY = 0;
                    score = 0;
                  });
                  Navigator.of(context).pop();
                  controller.repeat();
                },
              ),
              // ignore: deprecated_member_use
              FlatButton(
                child: Text('No'),
                onPressed: () {
                  controller.stop();
                  controller.dispose();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();


                },)
            ],
          );
        }
    );
  }

}