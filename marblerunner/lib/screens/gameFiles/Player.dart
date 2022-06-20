
import 'package:flame/game.dart';
import 'package:marblerunner/screens/gameFiles/traps.dart';
import 'package:marblerunner/screens/gameFiles/wall.dart';
import 'package:marblerunner/screens/gameFiles/endGoal.dart';

import 'game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

class Player extends CircleComponent with CollisionCallbacks {
  Player() {
    radius = 1333.333 / 44.44443333;
    // position = Vector2(
    //     ballGame.gridCellSize * ballGame.gridSize - ballGame.gridCellSize / 2,
    //     ballGame.gridCellSize * ballGame.gridSize - ballGame.gridCellSize / 2);
    // position = Vector2(0,0);
    anchor = Anchor.center;
    this.paint = BasicPalette.blue.paint()..style = PaintingStyle.fill;
    add(CircleHitbox());
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Wall) {
      Vector2 posDiff = Vector2((intersectionPoints.first.x - position.x).abs(),
          (intersectionPoints.first.y - position.y).abs());
      if (position.x < intersectionPoints.first.x && posDiff[0] > posDiff[1]) {
        // tjekker om spilleren rammer en væg til højre
        // right
        ballGame.stopmovingRight = true; // stopper at bevæge sig til højre
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

    if (other is EndGoal) {
      newMaze = true;
    }

    // if (other is Traps) {
    //   // ballGame.gameOver();
    // }
  }

  void onCollisionEnd(PositionComponent other) {
    ballGame.stopmovingRight = false;
    ballGame.stopmovingLeft = false;
    ballGame.stopmovingUp = false;
    ballGame.stopmovingDown = false;
  }
}
