import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SnackGame extends StatefulWidget {
  const SnackGame({super.key});

  @override
  State<SnackGame> createState() => _SnackGameState();
}

enum Direction { up, down, left, right }

class _SnackGameState extends State<SnackGame> {
  GameClass gameClass = GameClass();
  int row = 20, column = 20;
  List<int> borderList = [];
  List<int> snackPosition = [];
  int snackHead = 0, score = 0;
  late Direction direction;
  late int foodPosition;

  @override
  void initState() {
    startGame();
    super.initState();
  }

  void startGame() {
    makeBorder();
    generateFood();
    direction = Direction.right;
    snackPosition = [45, 44, 43];
    snackHead = snackPosition.first;
    snakeTimer();
  }

  void snakeTimer() {
    if (isPlay) {
      Timer.periodic(const Duration(milliseconds: 300), (timer) {
        updateSnack();
        if (checkCollision()) {
          timer.cancel();
          showGameOverDialog();
        }
        if (isPause) {
          timer.cancel();
        }
      });
    }
  }

  //todo-----------------------------------> Popup
  void showGameOverDialog() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: bgColor,
            title: const Text('Game Over',style: TextStyle(color: Colors.white),),
            content: const Text('Snack collied !',style: TextStyle(color: Colors.white),),
            actions: [
              TextButton(
                  onPressed: () {
                    setState(() {
                      score = 0;
                    });
                    Navigator.of(context).pop();
                    startGame();
                  },
                  child: const Text('Restart')),
              TextButton(
                  onPressed: () {
                    setState(() {
                      score = 0;
                      isPlay = false;
                    });
                    Navigator.of(context).pop();
                    startGame();
                  },
                  child: const Text('Cancel'))
            ],
          );
        });
  }

  void showGamePauseDialog() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: bgColor,
            title: const Text('Game Paused'),
            actions: [
              TextButton(
                  onPressed: () {
                    setState(() {
                      score = 0;
                      isPlay = false;
                    });
                    Navigator.of(context).pop();
                    startGame();
                  },
                  child: const Text('Home')),
              TextButton(
                  onPressed: () {
                    setState(() {
                      isPause = false;
                    });
                    Navigator.of(context).pop();
                    startGame();
                  },
                  child: const Text('Restart')),
              TextButton(
                  onPressed: () {
                    setState(() {
                      isPause = false;
                    });
                    Navigator.of(context).pop();
                    snakeTimer();
                  },
                  child: const Text('Resume'))
            ],
          );
        });
  }

  bool checkCollision() {
    if (borderList.contains(snackHead)) return true;
    if (snackPosition.sublist(1).contains(snackHead)) return true;
    return false;
  }

  void generateFood() {
    Random random = Random();
    foodPosition = random.nextInt(row * column);
    if (borderList.contains(foodPosition)) {
      generateFood();
    }
  }

  void updateSnack() {
    setState(() {
      switch (direction) {
        case Direction.up:
          snackPosition.insert(0, snackHead - column);
          break;
        case Direction.down:
          snackPosition.insert(0, snackHead + column);
          break;
        case Direction.right:
          snackPosition.insert(0, snackHead + 1);
          break;
        case Direction.left:
          snackPosition.insert(0, snackHead - 1);
          break;
      }
    });
    if (snackHead == foodPosition) {
      score++;
      if(gameClass.highScore < score){
        gameClass.highScore = score;
        gameClass.setHighScore(score);
      }
      generateFood();
    } else {
      snackPosition.removeLast();
    }
    snackHead = snackPosition.first;
  }

  //todo ------------------------------------------> Main Body
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double radius = min(width, height) * 0.0174;
    return SafeArea(
      child: Scaffold(
        backgroundColor: bgColor,
        body: Padding(
          padding: EdgeInsets.fromLTRB(10, height * 0.02, 10, 0),
          child: Column(
            children: [
              Expanded(child: _buildGameView(width,radius)),
              Expanded(child: _buildGameControls(width, height)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameView(double width,double radius) {
    return GridView.builder(
      gridDelegate:
      SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: column),
      itemCount: row * column,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            color: fillBoxColor(index),
          ),
        );
      },
    );
  }

  Widget _buildGameControls(double width, double height) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: (isPlay)
          ? Stack(
        alignment: Alignment.topCenter,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Score : $score',
                    style: TextStyle(fontSize: width * 0.045,color: Colors.white),
                  ),
                  Text(
                    'High Score : ${gameClass.highScore}',
                    style: TextStyle(fontSize: width * 0.045,color: Colors.white),
                  ),
                ],
              ),
              IconButton(
                  onPressed: () {
                    setState(() {
                      isPause = true;
                      showGamePauseDialog();
                    });
                  },
                  icon: Icon(Icons.pause_circle_outline_rounded,
                      size: width * 0.148))
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: height * 0.038),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                    onTap: () {
                      if (direction != Direction.down) {
                        direction = Direction.up;
                      }
                    },
                    child: Icon(
                      Icons.arrow_circle_up,
                      size: width * 0.224,
                      color: Colors.white70,
                    )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                        onTap: () {
                          if (direction != Direction.right) {
                            direction = Direction.left;
                          }
                        },
                        child: Icon(
                          Icons.arrow_circle_left_outlined,
                          size: width * 0.224,
                          color: Colors.white70,
                        )),
                    SizedBox(
                      width: width * 0.19,
                    ),
                    GestureDetector(
                        onTap: () {
                          if (direction != Direction.left) {
                            direction = Direction.right;
                          }
                        },
                        child: Icon(
                          Icons.arrow_circle_right_outlined,
                          size: width * 0.224,
                          color: Colors.white70,
                        )),
                  ],
                ),
                GestureDetector(
                    onTap: () {
                      if (direction != Direction.up) {
                        direction = Direction.down;
                      }
                    },
                    child: Icon(
                      Icons.arrow_circle_down,
                      size: width * 0.224,
                      color: Colors.white70,
                    )),
              ],
            ),
          ),
        ],
      )
          : Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
              onTap: () async {
                final AudioPlayer player = AudioPlayer();
                await player.play(AssetSource('audio/buttonClick.mp3'));
                setState(() {
                  isPlay = true;
                  score = 0;
                  isPause = false;
                });
                startGame();
              },
              child: Image.asset('assets/images/SnackGame/playButton.png')),
          SizedBox(height: height * 0.03),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 13),
                child: Image.asset('assets/images/SnackGame/setting.png',
                    height: height * 0.118),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Image.asset(
                    'assets/images/SnackGame/leaderboards.png',
                    height: height * 0.102),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 18),
                child: Image.asset('assets/images/SnackGame/champ.png',
                    height: height * 0.096),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 11),
                child: Image.asset('assets/images/SnackGame/cart.png',
                    height: height * 0.088),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color fillBoxColor(int index) {
    if (borderList.contains(index)) {
      return Colors.amber;
    } else {
      if (snackPosition.contains(index)) {
        if (snackHead == index) {
          return Colors.green;
        } else {
          return Colors.white.withOpacity(0.9);
        }
      } else {
        if (index == foodPosition && isPlay) {
          return Colors.red;
        }
      }
      return Colors.grey.withOpacity(0.15);
    }
  }

  makeBorder() {
    for (int i = 0; i < column; i++) {
      if (!borderList.contains(i)) {
        borderList.add(i);
      }
    }
    for (int i = 0; i < row * column; i = i + column) {
      if (!borderList.contains(i)) {
        borderList.add(i);
      }
    }
    for (int i = column - 1; i < row * column; i = i + column) {
      if (!borderList.contains(i)) {
        borderList.add(i);
      }
    }
    for (int i = (row * column) - column; i < row * column; i++) {
      if (!borderList.contains(i)) {
        borderList.add(i);
      }
    }
  }
}

bool isPlay = false, isPause = false;
Color bgColor = const Color(0xff101636);
// 101636
// 0C1128

class GameClass {
  late SharedPreferences sharedPreferences;
  int highScore = 0;

  Future<void> setHighScore(int highScore)async {
    sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setInt('show',highScore);
  }

  // void storeHighScore(int score){
  //   setHighScore(score);
  // }

  Future<void> getHighScore()async {
    sharedPreferences = await SharedPreferences.getInstance();
    highScore = sharedPreferences.getInt('show') ?? 0;
  }

  GameClass(){
    getHighScore();
  }
}