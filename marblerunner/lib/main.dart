import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/geometry.dart';
import 'package:flame/palette.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:sensors_plus/sensors_plus.dart';
// import

BallGame ballGame = BallGame();

final paint = BasicPalette.red.paint()..style = PaintingStyle.fill;
final circle = CircleComponent(
    radius: 200.0,
    position: Vector2(100, 200),
    paint: paint,
    anchor: Anchor.center);

TextPaint textPaint = TextPaint();

void main() {
  runApp(HomeWidget());
}

class HomeWidget extends StatefulWidget {
  const HomeWidget({Key? key}) : super(key: key);

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            body: Container(
      child: GameWidget(game: BallGame()),
    ),
    floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            circle.position = Vector2(200,200);
          });
        },
        child: const Text("recalibrate"),
      )
    ));
  }
}

class gyro extends _HomeWidgetState {
  @override
  void initState() {
    super.initState();
    gyroscopeEvents.listen((GyroscopeEvent event) {
      BallGame.move([event.y, event.x, event.z]);
    });
  }
}

class BallGame extends FlameGame with TapDetector {
  @override
  Color backgroundColor() => Colors.blue;
  @override
  Future<void> onLoad() async {
    add(circle);
    double middelx = size[0] / 2;
    double middely = size[1] / 2;

    circle.position = Vector2(middelx, middely);
    circle.size = Vector2(20, 20);
  }

  @override
  update(double dt) {
    super.update(dt);
    gyro().initState();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
  }

  @override
  void onTap() {
    super.onTap();
    circle.position.x += 10;
  }

  static void move(List gyro) {
    circle.position.x += gyro[0] / 10;
    circle.position.y += gyro[1] / 10;
  }

  // List getGyro() {
  //   double x = 5;
  //   double y = 0;
  //   double z = 0;
  //   List coord = [0, 0, 0];
  //   gyroscopeEvents.listen((GyroscopeEvent event) {
  //     x = event.x;
  //     y = event.y;
  //     z = event.z;
  //     coord = [x, y, z];
  //   });
  //   // print(coord);
  //   return coord;
  // }
}

// class Player extends FlameGame{
    
//     @override
//     Future<void> onLoad() async{
//       add(circle);
//     double middelx = size[0] / 2;
//     double middely = size[1] / 2;

//     }

// }
