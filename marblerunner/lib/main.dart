import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/geometry.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
// import 'package:sensors_plus/sensors_plus.dart';
// import 'package:flame/image.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_sensors/flutter_sensors.dart';
// import 'package:sensors/sensors.dart';
import 'package:motion_sensors/motion_sensors.dart';
import 'package:stack/stack.dart' as stack;
import 'dart:async';
import 'dart:math';

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

bool recalibrate = true;
//TODO : skal sættes til true igen;

List startAcceleration = [0, 0, 0];

double width = 0;
double height = 0;

double gridCellSize = 30; //150
int gridSize = 10;
List<Wall> walls = [];
Player player = Player();
Vector2 vel = Vector2(0, 0);

List<List<List<int>>> grid = List.generate(gridSize,
    (_) => List.generate(gridSize, (_) => List.generate(6, (_) => 0)));

var triggerList = List.generate(
    3, (_) => List.generate(3, (_) => List.generate(4, (_) => 0.0)));

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom]);
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
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Container(
            child: GameWidget(game: BallGame()),
          ),
        ));
  }
}

class Accelerometer extends _HomeWidgetState {
  @override
  void initState() {
    super.initState();
    // gyroscopeEvents.listen((GyroscopeEvent event) {
    //   ballGame.move([event.x, event.y, event.z]);
    // });
    // userAccelerometerEvents.listen((UserAccelerometerEvent event) {
    //   ballGame.move([event.x, event.y, event.z]);
    // });
    // motionSensors.gyroscope.listen((GyroscopeEvent event) {
    //   ballGame.move([event.x, event.y, event.z]);
    // });
    motionSensors.accelerometerUpdateInterval =
        Duration.microsecondsPerSecond ~/ 30;
    motionSensors.accelerometer.listen((AccelerometerEvent event) {
      ballGame.move([event.y, event.x, event.z]);
    });
  }
}

class BallGame extends FlameGame with HasTappables, HasCollisionDetection {
  // var triggerList = List<List<Vector4>>;
  RecalibrateButton recalibrateButton = RecalibrateButton();
  Color backgroundColor() => Colors.orange;

  bool stopmovingUp = false,
      stopmovingDown = false,
      stopmovingLeft = false,
      stopmovingRight = false;

  @override
  Future<void> onLoad() async {
    if (size[0] > size[1]) {
      width = size[0];
      height = size[1];
    } else {
      width = size[1];
      height = size[0];
    }
    loadPictures();

    createGrid();
    createMaze(Vector2(0, 0));
    drawMaze();
    createTraps();
    // drawTraps();

    player.position = Vector2(width / 2, height / 2);
    add(player);

    add(circle);
    double middelx = size[0] / 2;
    double middely = size[1] / 2;

    circle.position = Vector2(middelx, middely);
    circle.size = Vector2(width / 66.667, height / (188 / 5));

    triggerX = width / 2;
    triggerY = height / 2;

    triggerListInit();

    textb.text = "test2";

    textb.position = Vector2(width / 2, 2 * height / 6);
    textb.size = Vector2(width / 3.333, height / (47 / 25));

    add(textb);

    recalibrateButton
      ..sprite = await loadSprite('ball.png')
      ..size = Vector2(width / 26.666, height / (376 / 25))
      ..position = Vector2(
          width - recalibrateButton.size.x, height - recalibrateButton.size.y);
    add(recalibrateButton);

    Accelerometer().initState();
  }

  void createGrid() {
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        for (int k = 0; k < 4; k++) {
          grid[i][j][k] = 1;
        }
      }
    }
  }

  void createMaze(Vector2 position) {
    //metoden til at lave labyrinten er rekursiv backtracking
    //Følgende kode er lavet taget løst ud fra følgende link: http://weblog.jamisbuck.org/2010/12/27/maze-generation-recursive-backtracking
    grid[position[0].toInt()][position[1].toInt()][4] = 1;
    Vector2 N = Vector2(0, -1),
        S = Vector2(0, 1),
        E = Vector2(1, 0),
        W = Vector2(-1, 0);

    List directions = [N, E, S, W];
    directions.shuffle();

    for (int i = 0; i < directions.length; i++) {
      Vector2 newPosition = position + directions[i];
      if (newPosition[0] >= 0 &&
          newPosition[0] < gridSize &&
          newPosition[1] >= 0 &&
          newPosition[1] < gridSize &&
          grid[newPosition[0].toInt()][newPosition[1].toInt()][4] == 0) {
        if (directions[i] == N) {
          grid[position[0].toInt()][position[1].toInt()][0] = 0;
          grid[newPosition[0].toInt()][newPosition[1].toInt()][2] = 0;
        } else if (directions[i] == S) {
          grid[position[0].toInt()][position[1].toInt()][2] = 0;
          grid[newPosition[0].toInt()][newPosition[1].toInt()][0] = 0;
        } else if (directions[i] == E) {
          grid[position[0].toInt()][position[1].toInt()][1] = 0;
          grid[newPosition[0].toInt()][newPosition[1].toInt()][3] = 0;
        } else if (directions[i] == W) {
          grid[position[0].toInt()][position[1].toInt()][3] = 0;
          grid[newPosition[0].toInt()][newPosition[1].toInt()][1] = 0;
        }
        createMaze(newPosition);
      }
    }
  }

  void drawMaze() {
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        for (int k = 0; k < 4; k++) {
          if ((k == 0 && grid[i][j][0] == 1) ||
              (k == 2 && grid[i][j][2] == 1)) {
            Vector2 size = Vector2(gridCellSize, 5);
            Vector2 position = Vector2(i * gridCellSize, j * gridCellSize);
            if (k == 2) {
              position =
                  Vector2(i * gridCellSize, j * gridCellSize + gridCellSize);
            }

            Anchor anchor = Anchor.centerLeft;
            walls.add(Wall(position, size, anchor));
          }
          if ((k == 1 && grid[i][j][1] == 1) ||
              (k == 3 && grid[i][j][3] == 1)) {
            Vector2 size = Vector2(5, gridCellSize);

            Vector2 position = Vector2(i * gridCellSize, j * gridCellSize);
            if (k == 1) {
              position =
                  Vector2(i * gridCellSize + gridCellSize, j * gridCellSize);
            }
            Anchor anchor = Anchor.topCenter;
            walls.add(Wall(position, size, anchor));
          }
        }
      }
    }
    for (int i = 0; i < walls.length; i++) {
      for (int j = i; j < walls.length; j++) {
        if (walls[i].position == walls[j].position &&
            i != j &&
            walls[j].anchor == walls[i].anchor) {
          walls.remove(walls[j]);
        }
      }
    }

    for (int i = 0; i < walls.length; i++) {
      add(walls[i]);
    }
  }

  void createTraps() {
    getSolution(
      Vector2(gridSize - 1, gridSize - 1),
    );
    grid[0][0][5] = 1;
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (grid[i][j][5] == 0 ) {
          if(Random().nextInt(10) == 1 ){
          add(Traps(position: Vector2(i * gridCellSize, j * gridCellSize)));
        }
        }
      }
    }
  }

  bool getSolution(Vector2 position) {
    grid[position[0].toInt()][position[1].toInt()][4] = 0;
    if (position == Vector2(0, 0)) {
      return true;
    }
    Vector2 N = Vector2(0, -1),
        S = Vector2(0, 1),
        E = Vector2(1, 0),
        W = Vector2(-1, 0);
    List directions = [N, E, S, W];
    for (int i = 0; i < directions.length; i++) {
      Vector2 newPosition = position + directions[i];

      if (newPosition[0] >= 0 &&
          newPosition[0] < gridSize &&
          newPosition[1] >= 0 &&
          newPosition[1] < gridSize &&
          grid[position[0].toInt()][position[1].toInt()][i] == 0 &&
          grid[newPosition[0].toInt()][newPosition[1].toInt()][4] == 1) {
        if (getSolution(newPosition)) {
          grid[position[0].toInt()][position[1].toInt()][5] = 1;
          return true;
        }
      }
    }
    return false;
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
  }

  void loadPictures() async {}

  @override
  update(double dt) {
    super.update(dt);
    // print("${walls[0].position.x} +  ${walls[0].position.y}");
    // move();
    // move(getGyro());
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
  }

  void move(List gyro) {
    // print(gyro);
    // List gyro =

    if (recalibrate) {
      print("this should be recalibrated");
      recalibrate = false;
      startAcceleration = gyro;
      triggerX = width / 2;
      triggerY = height / 2;
      for (int i = 0; i < walls.length; i++) {
        // walls.visible = false;
        walls[i].position.x++;
      }
    }

    List tal = [
      startAcceleration[0] - gyro[0],
      startAcceleration[1] - gyro[1],
      startAcceleration[2] - gyro[2]
    ];

    triggerX =
        ((gyro[0] - startAcceleration[0]) * (width / 13.333) + width / 2);
    triggerY =
        ((gyro[1] - startAcceleration[1]) * (height / (188 / 25)) + height / 2);
    if (triggerX <= 2 * circle.size.x) {
      triggerX = 6 * circle.size.x;
    } else if (triggerX >= width - 2 * circle.size.x) {
      triggerX = width - 6 * circle.size.x;
    }

    if (triggerY <= 2 * circle.size.y) {
      triggerY = 6 * circle.size.y;
    } else if (triggerY >= height - 2 * circle.size.y) {
      triggerY = height - 6 * circle.size.y;
    }

    circle.position.x = triggerX;
    circle.position.y = triggerY;

    // player.onCollisionStartCallback();

    // print(
    //     "$stopmovingDown   $stopmovingUp   $stopmovingLeft   $stopmovingRight");

    if (vel.y > 0 && stopmovingDown) {
      vel.y = 0;
    }
    if (vel.y < 0 && stopmovingUp) {
      vel.y = 0;
    }
    if (vel.x < 0 && stopmovingLeft) {
      vel.x = 0;
    }
    if (vel[0] > 0 && stopmovingRight) {
      vel.x = 0;
    }

    for (int i = 0; i < walls.length; i++) {
      walls[i].position -= vel;
    }

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if ((triggerX < triggerList[i][j][0] &&
                triggerX > triggerList[i][j][0] - (width / 3)) &&
            (triggerY < triggerList[i][j][1] &&
                triggerY > triggerList[i][j][1] - (height / 3))) {
          // for (int k = 0; k < walls.length; k++) {
          // walls[k].position.x -=
          //     triggerList[i][j][2] * 1 * (width / 1333.3);
          // walls[k].position.y -= triggerList[i][j][3] * 1 * (height / 752);

          vel = Vector2(triggerList[i][j][2] * 4 * (width / 1333.3),
              triggerList[i][j][3] * 4 * (height / 752));
          // walls[k].position -= vel;
          // }
          // break;
        }
      }
    }
  }
}

class RecalibrateButton extends SpriteComponent with Tappable {
  @override
  bool onTapDown(TapDownInfo info) {
    recalibrate = true;
    return true;
  }
}

class Wall extends RectangleComponent with CollisionCallbacks {
  Wall(Vector2 position, Vector2 size, Anchor anchor) {
    this.position = position;
    this.size = size;
    this.anchor = anchor;
    var paint1 = BasicPalette.blue.paint()..style = PaintingStyle.fill;

    var hitbox = RectangleHitbox()
      ..paint = paint1
      ..renderShape = true;
    add(hitbox);
  }
}

class Player extends CircleComponent with CollisionCallbacks {
  Player() {
    radius = 1333.333 / 44.44443333;
    position = Vector2(width / 2, height / 2);
    anchor = Anchor.center;
    this.paint = BasicPalette.green.paint()..style = PaintingStyle.fill;
    add(CircleHitbox());
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    Vector2 posDiff = Vector2((intersectionPoints.first.x - position.x).abs(),
        (intersectionPoints.first.y - position.y).abs());
    if (position.x < intersectionPoints.first.x && posDiff[0] > posDiff[1]) {
      // right
      // backlash = Vector2(-1, 0);
      ballGame.stopmovingRight = true;
    }
    if (position.x > intersectionPoints.first.x && posDiff[0] > posDiff[1]) {
      // left
      // backlash = Vector2(1, 0);
      ballGame.stopmovingLeft = true;
    }
    if (position.y > intersectionPoints.first.y && posDiff[0] < posDiff[1]) {
      //up
      // backlash = Vector2(0, 1);
      ballGame.stopmovingUp = true;
    }
    if (position.y < intersectionPoints.first.y && posDiff[0] < posDiff[1]) {
      //down
      // backlash = Vector2(0, -1);
      ballGame.stopmovingDown = true;
    }
  }

  void onCollisionEnd(PositionComponent other) {
    ballGame.stopmovingRight = false;
    ballGame.stopmovingLeft = false;
    ballGame.stopmovingUp = false;
    ballGame.stopmovingDown = false;
  }
}

class Traps extends CircleComponent with CollisionCallbacks {
  Traps({position}) {
    radius = gridCellSize / 2 - gridCellSize / 9;
    this.position =
        Vector2(position[0] + gridCellSize / 2, position[1] + gridCellSize / 2);
    anchor = Anchor.center;
    this.paint = BasicPalette.black.paint()..style = PaintingStyle.fill;
    add(CircleHitbox());
  }
}
