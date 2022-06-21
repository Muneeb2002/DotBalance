// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:marblerunner/screens/startscreen.dart';
import 'package:marblerunner/screens/gameFiles/game.dart';
import 'package:flutter/services.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,  //fjerner status bar
      overlays: [SystemUiOverlay.bottom]);
  SystemChrome.setPreferredOrientations([  //gør til landscape
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((value) => runApp(MaterialApp(
        debugShowCheckedModeBanner: false,   //fjerner debug banner fra hjørnet
        initialRoute: '/',
        routes: {
          '/': (context) => StartScreen(),
          '/game': (context) => HomeWidget(),
        },
      )));
}
