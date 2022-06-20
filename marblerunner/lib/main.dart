// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:marblerunner/screens/startscreen.dart';
import 'package:marblerunner/screens/gameFiles/game.dart';
import 'package:flutter/services.dart';

// void main() => runApp(MaterialApp(
//       initialRoute: '/',
//       routes: {
//         '/': (context) => StartScreen(),
//         '/game': (context) => GameScreen(),
//       },
//     ));

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom]);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((value) => runApp(MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => StartScreen(),
          '/game': (context) => HomeWidget(),
        },
      )));
}
