import 'dart:async';

import 'package:flutter/material.dart';
import 'package:untitled/cake.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //cake (fake bird XD) variables
  static double birdY =0;
  double initialPos = birdY;
  double height = 0 ;
  double time = 0 ;
  double gravity = -4.9;
  double velocity = 30 ;
  void jump() {
    Timer.periodic(Duration(milliseconds: 50), (timer) {

      height = gravity* time * time + velocity * time;
      setState(() {
  birdY = initialPos - height;
});
      //keep time going

      time+=0.1;
    });
  }
  @override


  Widget build(BuildContext context) {
    return GestureDetector(
       onTap: jump,
      child: Scaffold(
      body:Column(
        children:[
          Expanded(flex:3,child: Container(color: Colors.blue,
          child: Center(child: Stack(
            children: [
              MyBird(birdY: birdY,)
            ],
          )),
          )),
      
          Expanded(child: Container(color:Colors.brown,)),
        ],
      ),
      ),
    );
  }
  
}
