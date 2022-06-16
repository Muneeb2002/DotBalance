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

double gridCellSize = 50;
int gridSize = 20;
List<Wall> walls = [];

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

class gyro extends _HomeWidgetState {
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
    motionSensors.accelerometer.listen((AccelerometerEvent event) {
      ballGame.move([event.y, event.x, event.z]);
    });
  }
}

class BallGame extends FlameGame with HasTappables {
  // var triggerList = List<List<Vector4>>;
  RecalibrateButton recalibrateButton = RecalibrateButton();
  Color backgroundColor() => Colors.orange;
  stack.Stack<Vector2> carvableWalls = stack.Stack<Vector2>();
  stack.Stack<Vector2> cWalls = stack.Stack<Vector2>();

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

    motionSensors.accelerometerUpdateInterval =
        Duration.microsecondsPerSecond ~/ 60;
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

    List directions = [N, S, E, W];
    directions.shuffle();

    for (int i = 0; i < directions.length; i++) {
      Vector2 newPosition = position + directions[i];
      if(newPosition[0] >=0 && newPosition[0] < gridSize && newPosition[1] >=0 && newPosition[1] < gridSize && grid[newPosition[0].toInt()][newPosition[1].toInt()][4] == 0) {
        if(directions[i] == N){
          grid[position[0].toInt()][position[1].toInt()][0] = 0;
          grid[newPosition[0].toInt()][newPosition[1].toInt()][2] = 0;
        } else if(directions[i] == S){
          grid[position[0].toInt()][position[1].toInt()][2] = 0;
          grid[newPosition[0].toInt()][newPosition[1].toInt()][0] = 0;
        } else if(directions[i] == E){
          grid[position[0].toInt()][position[1].toInt()][1] = 0;
          grid[newPosition[0].toInt()][newPosition[1].toInt()][3] = 0;
        } else if(directions[i] == W){
          grid[position[0].toInt()][position[1].toInt()][3] = 0;
          grid[newPosition[0].toInt()][newPosition[1].toInt()][1] = 0;
        }
        createMaze(newPosition);
      }
    }
  }


  // void createMaze(Vector2 position) {
  //   grid[position[0].toInt()][position[1].toInt()][4] = 1;

  //   Wall N, E, S, W;

  //   List availableDirections = [];

  //   if (position[0] != 0) {
  //     if (grid[position[0].toInt() - 1][position[1].toInt()][4] == 0) {
  //       availableDirections.add(Vector2(position[0] - 1, position[1]));
  //     }
  //   }
  //   if (position[0] != gridSize - 1) {
  //     if (grid[position[0].toInt() + 1][position[1].toInt()][4] == 0) {
  //       availableDirections.add(Vector2(position[0] + 1, position[1]));
  //     }
  //   }
  //   if (position[1] != 0) {
  //     if (grid[position[0].toInt()][position[1].toInt() - 1][4] == 0) {
  //       availableDirections.add(Vector2(position[0], position[1] - 1));
  //     }
  //   }
  //   if (position[1] != gridSize - 1) {
  //     if (grid[position[0].toInt()][position[1].toInt() + 1][4] == 0) {
  //       availableDirections.add(Vector2(position[0], position[1] + 1));
  //     }
  //   }

  //   availableDirections.shuffle();

  //   if (availableDirections.isEmpty) {
  //     // print("id ont knowef sdfsdf");
  //     if (carvableWalls.isNotEmpty) {
  //       createMaze(carvableWalls.pop());
  //       return;
  //     }
  //     return;
  //   }

  //   for (int i = 0; i < availableDirections.length; i++) {
  //     carvableWalls
  //         .push(Vector2(availableDirections[i][0], availableDirections[i][1]));
  //   }

  //   if (carvableWalls.isEmpty) {
  //     return;
  //   } else {
  //     // carvableWalls.print();
  //     Vector2 nextCell = carvableWalls.top();
  //     print("${nextCell[0]} ${nextCell[1]}");
  //     Vector2 diff =
  //         Vector2(nextCell[0] - position[0], nextCell[1] - position[1]);
  //     // if (grid[nextCell[0].toInt()][nextCell[1].toInt()][4] == 0) {
  //     if (diff[0] > 0) {
  //       grid[position[0].toInt()][position[1].toInt()][1] = 0;
  //       grid[nextCell[0].toInt()][nextCell[1].toInt()][3] = 0;
  //     } else if (diff[0] < 0) {
  //       grid[position[0].toInt()][position[1].toInt()][3] = 0;
  //       grid[nextCell[0].toInt()][nextCell[1].toInt()][1] = 0;
  //     } else if (diff[1] > 0) {
  //       grid[position[0].toInt()][position[1].toInt()][2] = 0;
  //       grid[nextCell[0].toInt()][nextCell[1].toInt()][0] = 0;
  //     } else if (diff[1] < 0) {
  //       grid[position[0].toInt()][position[1].toInt()][0] = 0;
  //       grid[nextCell[0].toInt()][nextCell[1].toInt()][2] = 0;
  //     }
  //     // }
  //     createMaze(nextCell);
  //   }
  // }

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
            walls.add(Wall(size: size, position: position, anchor: anchor));
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
            walls.add(Wall(size: size, position: position, anchor: anchor));
          }
        }
      }
    }
    for (int i = 0; i < walls.length; i++) {
      add(walls[i]);
      walls[i].position.x += 20;
      walls[i].position.y += 20;
    }
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
      // ..size = Vector2(width / 0.3333, height / (47 / 250))
      ..size = Vector2(0.3333, (47 / 250))
      ..anchor = Anchor.center
      ..position = Vector2(width / 2, height / 2);

    add(background);

    SpriteComponent ball = SpriteComponent()
      ..sprite = await loadSprite('ball.png')
      ..size = Vector2(width / 26.666, height / (376 / 25))
      ..anchor = Anchor.center
      ..position = Vector2(width / 2, height / 2);

    add(ball);

    gyro().initState();
  }

  @override
  update(double dt) {
    super.update(dt);
    // move(getGyro());
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
  }

  void move(List gyro) {
    // print(gyro);

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
    // textb.text = tal.toString();
    textb.text = ((width / 1333.333).toString());

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

    //   try {
    //     if (triggerX > 2*circle.size.x && triggerX < width - 2*circle.size.x) {
    //       triggerX = ((gyro[0] - startAcceleration[0]) * 100 + width / 2);
    //     } else if (triggerX <= 2*circle.size.x) {
    //       triggerX = 6*circle.size.x;
    //     } else if (triggerX >= width - 2*circle.size.x) {
    //       triggerX = width - 6*circle.size.x;
    //     }

    //     if (triggerY > 2*circle.size.y && triggerY < height - 2*circle.size.y) {
    //       triggerY = ((gyro[1] - startAcceleration[1]) * 100 + height / 2);
    //     } else if (triggerY <= 2*circle.size.y) {
    //       triggerY = 6*circle.size.y;
    //     } else if (triggerY >= height - 2*circle.size.y) {
    //       triggerY = height - 6*circle.size.y;
    //     }
    //   } catch (e) {
    //     print(e);
    //     // todo: fuck der det her en god cowboy løsning
    //   }

    circle.position.x = triggerX;
    circle.position.y = triggerY;

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if ((triggerX < triggerList[i][j][0] &&
                triggerX > triggerList[i][j][0] - (width / 3)) &&
            (triggerY < triggerList[i][j][1] &&
                triggerY > triggerList[i][j][1] - (height / 3))) {
          // textb.text = '${triggerList[i][j][2]} && ${triggerList[i][j][3]}';
          background.position.x -= triggerList[i][j][2] * 3 * (width / 1333.3);
          background.position.y -= triggerList[i][j][3] * 3 * (height / 752);
          // for (int k = 0; k < walls.length; k++) {
          //   walls[k].position.x -= triggerList[i][j][2] * 3 * (width / 1333.3);
          //   walls[k].position.y -= triggerList[i][j][3] * 3 * (height / 752);
          // }
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

class Wall extends RectangleComponent {
  Wall({position, size, anchor})
      : super(
            position: position,
            size: size,
            anchor: anchor,
            // visible: true,
            paint: BasicPalette.red.paint()..style = PaintingStyle.fill);
}
