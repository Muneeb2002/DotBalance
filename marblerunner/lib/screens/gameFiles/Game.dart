import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:motion_sensors/motion_sensors.dart';
import 'dart:async';
import 'dart:math';
//packgage filer
import 'traps.dart';
import 'wall.dart';
import 'player.dart';
import 'endGoal.dart';

// import

BallGame ballGame = BallGame();



TextPaint textPaint = TextPaint();

SpriteComponent background = SpriteComponent();


bool recalibrate = true;


double width = 0;
double height = 0;


Player player = Player();
Vector2 vel = Vector2(0, 0);



bool newMaze = false;

var triggerList = List.generate(
    5,
    (_) => List.generate(
        5,
        (_) => List.generate(
            4, (_) => 0.0))); //denne liste laver vores trigger point hvor
//[0] er x koordinaten på skræmen
//[1] er y koordinaten på skærmen
//[2] er hvilken hastighed bolden skal bevæge sig med i x-retning
//[3] er hvilken hastighed bolden skal bevæge sig med i y-retning


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
    motionSensors.accelerometerUpdateInterval = Duration
            .microsecondsPerSecond ~/
        30; //Sætter hvor ofte accelerometer skal opdatere (30 gange i sekundet)
    motionSensors.accelerometer.listen((AccelerometerEvent event) {
      ballGame.move(
          [event.y, event.x, event.z]); //kalder move metoden i BallGame klassen
    });
  }
}

class BallGame extends FlameGame with HasTappables, HasCollisionDetection {

  RecalibrateButton recalibrateButton = RecalibrateButton();
  Color backgroundColor() => Colors.white;

  double triggerX = 0, triggerY = 0;



  Random rand = Random();

  bool recalibrate = true;
//TODO : skal sættes til true igen;

  List startAcceleration = [0, 0, 0];

  bool stopmovingUp = false,
      stopmovingDown = false,
      stopmovingLeft = false,
      stopmovingRight = false;

  double gridCellSize = 1333.333 / 8.888867; //150
  // double gridCellSize = 15;
  int gridSize = 20;
  List<Wall> walls = [];
  List<Traps> traps = [];

  List<List<List<int>>> grid =
      []; //initialisere grid med en liste af liste af liste af ints


  @override
  Future<void> onLoad() async {
    if (size[0] > size[1]) {
      //tager højde for om længden af skærmen er større end højden
      width = size[0];
      height = size[1];
    } else {
      width = size[1];
      height = size[0];
    }
    loadPictures();

    startGame(); //kalder startGame metoden (som laver grid, labyrint, traps, sætter player, endGoal)
    add(player);

    

    triggerX = width / 2;
    triggerY = height / 2;

    triggerListInit();



    recalibrateButton
      ..sprite = await loadSprite('recalibrate.png')
      ..size = Vector2(width*2 / 26.666, height*2 / (376 / 25))
      ..position = Vector2(
          width - recalibrateButton.size.x, height - recalibrateButton.size.y)
      ..positionType = PositionType.viewport;

    add(recalibrateButton);

    camera.followComponent(
        player); //sørger for at kameraet følger player componenten
    Accelerometer().initState();
  }

  void startGame() {
    int x = rand.nextInt(gridSize);
    int y = rand.nextInt(gridSize);
    // rand
    createGrid();
    createMaze(Vector2(x.toDouble(), y.toDouble()));
    drawMaze();
    createTraps();
    createEndGoal();

    player.position = Vector2(gridCellSize * gridSize - gridCellSize / 2,
        gridCellSize * gridSize - gridCellSize / 2);
  }

  void createGrid() {
    grid.clear();

    grid = List.generate(
        gridSize,
        (_) => List.generate(
            gridSize,
            (_) => List.generate(
                6,
                (_) =>
                    0))); //genere et gridsize x gridsize grid, som har en liste med 6 elementer
    //de 4 første elementer symboliserer om der en væg på den del af de enkelte celler
    //[0] om der er væg over
    //[1] om der er væg til højre
    //[2] om der er væg under
    //[3] om der er væg til venstre
    //[4] om den er cellen er besøgt,(bruges til maze generation og traps generation)
    //[5] om cellen udgør vejen til målet

    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        for (int k = 0; k < 4; k++) {
          grid[i][j][k] =
              1; //starter med at sørge for at der er væg over i alle celler
        }
      }
    }
  }

  void createMaze(Vector2 position) {
    //metoden til at lave labyrinten er rekursiv backtracking
    //Følgende kode er lavet taget løst ud fra følgende link: http://weblog.jamisbuck.org/2010/12/27/maze-generation-recursive-backtracking
    grid[position[0].toInt()][position[1].toInt()][4] =
        1; //sætter cellen til at være besøgt

    Vector2 N = Vector2(0, -1), //finder de næste celler hvor mazen kan gå hen
        S = Vector2(0, 1),
        E = Vector2(1, 0),
        W = Vector2(-1, 0);

    List directions = [
      N,
      E,
      S,
      W
    ]; //tilføjer alle de 4 mulige retninger til en liste
    directions.shuffle(); //blander listen for at undgå bias
    // print("dir ${directions}");

    for (int i = 0; i < directions.length; i++) {
      Vector2 newPosition = position + directions[i];
      if (newPosition[0] >= 0 &&
          newPosition[0] < gridSize &&
          newPosition[1] >= 0 &&
          newPosition[1] <
              gridSize && //de fire linjer over sørger for at den ikke kan gå ud af griden
          grid[newPosition[0].toInt()][newPosition[1].toInt()][4] == 0) {
        //hvis den næste celler ikke er besøgt
        if (directions[i] == N) {
          //fjerner væggene for denne celle og den næste celle i den retning der er valgt(modsat for den anden celle)
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
        createMaze(
            newPosition); //kalder metoden igen for at lave den næste celle
      }
    }
  }

  void drawMaze() {
    for (int i = 0; i < walls.length; i++) {
      remove(walls[
          i]); //clear alle instancer af vægge der kunne være lavet i forvejen (bruges til genstart)
    }
    walls.clear(); //sørger for at listen med vægge er tom

    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        for (int k = 0; k < 4; k++) {
          if ((k == 0 && grid[i][j][0] == 1) ||
              (k == 2 && grid[i][j][2] == 1)) {
            ///tjekker hvilken retning der er valgt og om der er væg over eller under og om der skal være en væg eller ej
            Vector2 size = Vector2(gridCellSize, 5);
            Vector2 position = Vector2(i * gridCellSize, j * gridCellSize);
            if (k == 2) {
              //hvis væggen er under sættes positionen af væggen til følgende
              position =
                  Vector2(i * gridCellSize, j * gridCellSize + gridCellSize);
            }

            Anchor anchor = Anchor.centerLeft;
            walls.add(Wall(position, size,
                anchor)); // tilføjer væggen til listen med vægge
          }
          if ((k == 1 && grid[i][j][1] == 1) ||
              (k == 3 && grid[i][j][3] == 1)) {
            //tjekker hvilken retning der er valgt og om der er væg til højre eller venstre og om der skal være en væg eller ej
            Vector2 size = Vector2(5, gridCellSize);

            Vector2 position = Vector2(i * gridCellSize, j * gridCellSize);
            if (k == 1) {
              //hvis væggen er til højre sættes positionen af væggen til følgende
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
      //følgende tjekker om der er 2 vægge på samme celle og fjerner så den ekstra væg
      for (int j = i; j < walls.length; j++) {
        if (walls[i].position == walls[j].position &&
            i != j &&
            walls[j].anchor == walls[i].anchor) {
          walls.remove(walls[j]);
        }
      }
    }
    for (int i = 0; i < walls.length; i++) {
      add(walls[i]); //tilføjer væggen til scenen
    }
  }

  
  void createTraps() {
    for (int i = 0; i < traps.length; i++) {
      //fjerner alle instancer af trapene
      remove(traps[i]);
    }
    traps.clear();
    getSolution(
      //finder løsningen til mazeen
      Vector2(gridSize - 1, gridSize - 1),
    );
    grid[0][0][5] = 1;
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (grid[i][j][5] == 0) {
          if (Random().nextInt(10) == 1) {
            // hvis det er en tilfældigt tal mellem 0 og x så tilføjes en trap
            traps.add(Traps(position: Vector2(i * gridCellSize, j * gridCellSize)));
          }
        }
      }
    }

    for (int i = 0; i < traps.length; i++) {
      add(traps[i]);
    }
  }

  bool getSolution(Vector2 position) {
    // en rekursiv metode der finder løsningen til mazeen
    // løsning inspireret af https://en.wikipedia.org/wiki/Maze-solving_algorithm#Recursive_algorithm
    grid[position[0].toInt()][position[1].toInt()][4] =
        0; //sætter denne celle til at være besøgt
    if (position == Vector2(0, 0)) {
      return true; //returner true hvis den er kommet til målet
    }
    Vector2 N = Vector2(0, -1), //finder mulige retninger
        S = Vector2(0, 1),
        E = Vector2(1, 0),
        W = Vector2(-1, 0);
    List directions = [N, E, S, W];
    for (int i = 0; i < directions.length; i++) {
      Vector2 newPosition = position + directions[i];

      if (newPosition[0] >= 0 &&
          newPosition[0] < gridSize &&
          newPosition[1] >= 0 &&
          newPosition[1] <
              gridSize && //hvis den nye position er indenfor griden
          grid[position[0].toInt()][position[1].toInt()][i] ==
              0 && //hvis den nye position er indenfor griden
          grid[newPosition[0].toInt()][newPosition[1].toInt()][4] == 1) {
        //tjeckker om den nye celle ikke er besøgt
        if (getSolution(newPosition)) {
          //kalder metoden igen for at finde løsningen
          grid[position[0].toInt()][position[1].toInt()][5] =
              1; //sætter denne celle til at være en del af løsningen
          return true;
        }
      }
    }
    return false;
  }

  void createEndGoal() {
    // tilføjer et slut punkt
    add(EndGoal());
  }

  void triggerListInit() {
    for (int i = 1; i <= 5; i++) {
      // udfylder trigger list
      for (int j = 1; j <= 5; j++) {
        triggerList[i - 1][j - 1][0] = i * (width / 5);
        triggerList[i - 1][j - 1][1] = j * (height / 5);
        triggerList[i - 1][j - 1][2] = -3 + i * 1.0;
        triggerList[i - 1][j - 1][3] = -3 + j * 1.0;
      }
    }


  }

  void loadPictures() async {}

  @override
  update(double dt) {
    super.update(dt);
    if (newMaze) {
      startGame();
      newMaze = false;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
  }

  void move(List gyro) {

    if (recalibrate) {
      recalibrate = false;
      startAcceleration = gyro;
      triggerX = width / 2;
      triggerY = height / 2;
    }

    triggerX = //opdatere positionen af triggersne
        ((gyro[0] - startAcceleration[0]) * (width / 13.333) + width / 2);
    triggerY =
        ((gyro[1] - startAcceleration[1]) * (height / (188 / 25)) + height / 2);

    if (triggerX <= 2 * (width / 66.667)) {
      //sørger for triggerne ikke kan gå ud af skærmen
      triggerX = 6 * (width / 66.667);
    } else if (triggerX >= width - 2 * (width / 66.667)) {
      triggerX = width - 6 * (width / 66.667);
    }

    if (triggerY <= 2 * height/(188/5)) {
      triggerY = 6 * height/(188/5);
    } else if (triggerY >= height - 2 * height/(188/5)) {
      triggerY = height - 6 * height/(188/5);
    }



    if (vel.y > 0 && stopmovingDown) {
      //stop bevægelsen i en specifik retning
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

    player.position += vel; //opdatere spillerens position

    for (int i = 0; i < 5; i++) {
      for (int j = 0; j < 5; j++) {
        if ((triggerX < triggerList[i][j][0] &&
                triggerX > triggerList[i][j][0] - (width / 5)) &&
            (triggerY < triggerList[i][j][1] &&
                triggerY > triggerList[i][j][1] - (height / 5))) {
          //tjekker hvilken triggerfelt triggeren er i
          vel = Vector2(triggerList[i][j][2] * 4 * (width / 1333.3),
              triggerList[i][j][3] * 4 * (height / 752));
        }
      }
    }
  }
  // void gameOver() {
  //   isGameOver = true;
  //   final style = TextStyle(
  //       color: BasicPalette.black.color,
  //       fontSize: 50,
  //       fontFamily: 'Labyrinthism');
  //   final regular = TextPaint(style: style);
  //   TextBoxComponent gameOverText = TextBoxComponent(
  //       text: "Game Over",
  //       position: Vector2(width / 2, height / 2 - height / 3),
  //       anchor: Anchor.center);
  //   gameOverText.positionType = PositionType.viewport;
  //   gameOverText.textRenderer = regular;
  //   add(gameOverText);
  // }
}

// class gameOverButton extends RectangleComponent with Tappable {
//   gameOverButton() {
//     positionType = PositionType.viewport;
//     this.width = width/10;
//     this.height = height/10;
//     position = Vector2(width/2, height/2+height/10);
//     anchor = Anchor.center;
//     this.paint = BasicPalette.blue.paint()..style = PaintingStyle.fill;
//   }
//   @override
//   bool onTapDown(TapDownInfo info) {
//     return true;
//   }
// }

class RecalibrateButton extends SpriteComponent with Tappable {
  @override
  bool onTapDown(TapDownInfo info) {
    ballGame.recalibrate = true;
    
    return true;
  }
}
