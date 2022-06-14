import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:sensors_plus/sensors_plus.dart';

// import
BallGame ballGame = BallGame();

final paint = BasicPalette.red.paint()..style = PaintingStyle.fill;
final circle = CircleComponent(
    radius: 200.0,
    position: Vector2(10, 10),
    paint: paint,
    anchor: Anchor.center);

TextPaint textPaint = TextPaint();

SpriteComponent background = SpriteComponent();

TextBoxComponent textb = TextBoxComponent();

double triggerX = 0, triggerY = 0;

bool recalibrate = false;

double width = 0;
double height = 0;
var triggerList = List.generate(
    5, (_) => List.generate(5, (_) => List.generate(4, (_) => 0.0)));

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
    ));
  }
}

class Gyro extends _HomeWidgetState {
  @override
  void initState() {
    super.initState();
    gyroscopeEvents.listen((GyroscopeEvent event) {
      ballGame.move([event.x, event.y]);
    });
  }
}

class BallGame extends FlameGame with HasTappables {
  // var triggerList = List<List<Vector4>>;
  RecalibrateButton recalibrateButton = RecalibrateButton();
  Color backgroundColor() => Colors.orange;

  @override
  Future<void> onLoad() async {
    width = size[0];

    height = size[1];
    loadPictures();

    add(circle);
    double middelx = size[0] / 2;
    double middely = size[1] / 2;

    circle.position = Vector2(middelx, middely);
    circle.size = Vector2(20, 20);

    triggerListInit();

    textb.text = "sike";
    textb.position = Vector2(width / 2, 200);
    textb.size = Vector2(400, 400);
    add(textb);

    recalibrateButton
      ..sprite = await loadSprite('ball.png')
      ..position = Vector2(width - 50, height - 50)
      ..size = Vector2(50, 50);
    add(recalibrateButton);
  }

  // creates the points/corners for the movement areas
  void triggerListInit() {
    for (int i = 0; i < 5; i++) {
      for (int j = 0; j < 5; j++) {
        triggerList[i][j][0] = (i + 1) * (width / 5); // x-coordinate
        triggerList[i][j][1] = (j + 1) * (height / 5); // y-coordinate
        triggerList[i][j][2] = -3 + (i + 1) * 1.0; // movement val for x
        triggerList[i][j][3] = -3 + (j + 1) * 1.0; // movement val for y

        add(CircleComponent(
            radius: 20,
            position: Vector2(triggerList[i][j][0], triggerList[i][j][1]),
            paint: paint,
            anchor: Anchor.center));
      }
    }

    // print(triggerList);
    // add(CircleComponent(
    //         radius: 20,
    //         position: Vector2(0,0),
    //         paint: paint,
    //         anchor: Anchor.center));
    //   }
  }

  void loadPictures() async {
    background = SpriteComponent()
      ..sprite = await loadSprite('test.png')
      ..size = Vector2(1000, 1000)
      ..anchor = Anchor.center
      ..position = Vector2(width / 2, height / 2);

    add(background);

    SpriteComponent ball = SpriteComponent()
      ..sprite = await loadSprite('ball.png')
      ..size = Vector2(50, 50)
      ..anchor = Anchor.center
      ..position = Vector2(width / 2, height / 2);

    add(ball);
  }

  @override
  update(double dt) {
    super.update(dt);
    Gyro().initState();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
  }

  void move(List gyro) {
    if (recalibrate) {
      recalibrate = false;
      circle.position.x = width / 2;
      circle.position.y = height / 2;
    }
    // print(size[0]);
    try {
      // print(size[0]);
      print(gyro);
      if (circle.position.x > 0 &&
              circle.position.x < width &&
              gyro[1] / 2 > 0.002 ||
          gyro[1] / 2 < -0.002) {
        circle.position.x += gyro[1] / 2;
      } else if (circle.position.x <= 0) {
        circle.position.x = 5;
      } else if (circle.position.x >= width) {
        circle.position.x = width - 5;
      }

      if (circle.position.y > 0 &&
              circle.position.y < height &&
              gyro[0] / 2 > 0.002 ||
          gyro[0] / 2 < -0.002) {
        circle.position.y += gyro[0] / 2;
      } else if (circle.position.y <= 0) {
        circle.position.y = 5;
      } else if (circle.position.y >= height) {
        circle.position.y = height - 5;
      }
    } catch (e) {
      print(e);
      // todo: fuck der det her en god cowboy løsning
    }

    // if(circle.position.x > 0 && circle.position.x < width) {
    // circle.position.x += gyro[0] / 2;
    // }

    // if(circle.position.y > 0 && circle.position.y < height) {
    // circle.position.y += gyro[1] / 2;
    // }
    // background.position.x -= gyro[0] / 20;
    // background.position.y += gyro[1] / 20;
    // print(triggerList);
    // textb.text = "x: ${gyro[0]} y: ${gyro[1]} ";
    for (int i = 0; i < 5; i++) {
      for (int j = 0; j < 5; j++) {
        if ((circle.position.x < triggerList[i][j][0] &&
                circle.position.x > triggerList[i][j][0] - (width / 5)) &&
            (circle.position.y < triggerList[i][j][1] &&
                circle.position.y > triggerList[i][j][1] - (height / 5))) {
          textb.text = '${triggerList[i][j][2]} && ${triggerList[i][j][3]}';

          background.position.x -= triggerList[i][j][2] / 50;
          background.position.y -= triggerList[i][j][3] / 50;
        }
      }
    }
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

class RecalibrateButton extends SpriteComponent with Tappable {
  @override
  bool onTapDown(TapDownInfo info) {
    recalibrate = true;
    return true;
  }
}
