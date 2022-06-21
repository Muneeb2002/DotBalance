import 'game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

class Traps extends CircleComponent with CollisionCallbacks {
  Traps({position}) {
    radius = ballGame.gridCellSize / 2 - ballGame.gridCellSize / 5;
    this.position =
        Vector2(position[0] + ballGame.gridCellSize / 2, position[1] + ballGame.gridCellSize / 2);
    anchor = Anchor.center;
    Paint color = Paint()..color = Color.fromRGBO(74, 81, 84, 1);
    this.paint = color..style = PaintingStyle.fill;

    add(CircleHitbox());
  }
}
