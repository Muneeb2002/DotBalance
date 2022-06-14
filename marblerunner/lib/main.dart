import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/geometry.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:sensors_plus/sensors_plus.dart';
// import 'package:flame/image.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/services.dart';

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

int pausecount = 0;
bool pauseMovement = false;

double width = 0;
double height = 0;
var triggerList = List.generate(
    3, (_) => List.generate(3, (_) => List.generate(4, (_) => 0.0)));

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
    SystemUiOverlay.bottom
  ]); 
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((value) => runApp(HomeWidget()));

  // runApp(HomeWidget());
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

class gyro extends _HomeWidgetState {
  @override
  void initState() {
    super.initState();
    gyroscopeEvents.listen((GyroscopeEvent event) {
      ballGame.move([event.x, event.y, event.z]);
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

    triggerX = width / 2;
    triggerY = height / 2;

    triggerListInit();

    textb.text = "test2";
    textb.position = Vector2(width / 2, 200);
    textb.size = Vector2(400, 400);
    add(textb);

    recalibrateButton
      ..sprite = await loadSprite('ball.png')
      ..position = Vector2(width - 50, height - 50)
      ..size = Vector2(50, 50);
    add(recalibrateButton);
  }

  void triggerListInit() {
    for (int i = 1; i <= 3; i++) {
      for (int j = 1; j <= 3; j++) {
        triggerList[i - 1][j - 1][0] = i * (width / 3);
        triggerList[i - 1][j - 1][1] = j * (height / 3);
        triggerList[i - 1][j - 1][2] = -2 + i * 1.0;
        triggerList[i - 1][j - 1][3] = -2 + j * 1.0;
      }
    }

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
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
      ..size = Vector2(4000, 4000)
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
    gyro().initState();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
  }

  void move(List gyro) {
    if (recalibrate) {
      recalibrate = false;
      triggerX = width / 2;
      triggerY = height / 2;
    }

    // print(size[0]);
    try {
      // print(size[0]);
      if (triggerX > 0 && triggerX < width) {
        triggerX += gyro[0] / 3;
      } else if (triggerX <= 0) {
        triggerX = 5;
      } else if (triggerX >= width) {
        triggerX = width - 5;
      }

      if (triggerY > 0 && triggerY < height) {
        triggerY -= gyro[1] / 3;
      } else if (triggerY <= 0) {
        triggerY = 5;
      } else if (triggerY >= height) {
        triggerY = height - 5;
      }
    } catch (e) {
      print(e);
      // todo: fuck der det her en god cowboy løsning
    }

    // if(){

    // }

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

    circle.position.x = triggerX;
    circle.position.y = triggerY;

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if ((triggerX < triggerList[i][j][0] &&
                triggerX > triggerList[i][j][0] - (width / 3)) &&
            (triggerY < triggerList[i][j][1] &&
                triggerY > triggerList[i][j][1] - (height / 3))) {
          // textb.text = '${triggerList[i][j][2]} && ${triggerList[i][j][3]}';
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
