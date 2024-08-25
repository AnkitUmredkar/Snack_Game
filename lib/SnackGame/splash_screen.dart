import 'dart:async';
import 'package:flutter/material.dart';

import 'continue_page.dart';
import 'game_page.dart';

class SnackGameSplashScreen extends StatefulWidget {
  const SnackGameSplashScreen({super.key});

  @override
  State<SnackGameSplashScreen> createState() => _SnackGameSplashScreenState();
}

class _SnackGameSplashScreenState extends State<SnackGameSplashScreen> {
  @override
  void initState(){
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) => const ContinuePage()));
    });
    super.initState();
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
      body: Center(
        child: Image.asset('assets/images/SnackGame/splash.png',width: width * 0.5,),
      ),
    );
  }
}
