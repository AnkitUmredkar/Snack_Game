import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';

import 'game_page.dart';

class ContinuePage extends StatefulWidget {
  const ContinuePage({super.key});

  @override
  State<ContinuePage> createState() => _ContinuePageState();
}

class _ContinuePageState extends State<ContinuePage> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      setState(() {
        isShowContinue = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery
        .of(context)
        .size
        .height;
    double width = MediaQuery
        .of(context)
        .size
        .height;
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: height * 0.35),
            child: Image.asset('assets/images/SnackGame/splash.png',width: width * 0.5,),
          ),
          SizedBox(height: height * 0.2),
          (isShowContinue)
              ? GestureDetector(onTap: () async{
            final AudioPlayer player = AudioPlayer();
            await player.play(AssetSource('audio/buttonClick.mp3'));
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const SnackGame()));
          },
              child: Image.asset('assets/images/SnackGame/continueButton.png',
                  width: width * 0.46))
              : SpinKitThreeInOut(
            color: Colors.green.shade400, size: width * 0.064,),
        ],
      ),
    );
  }
}

bool isShowContinue = false;