import 'Game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

class EndGoal extends RectangleComponent with CollisionCallbacks {
  EndGoal() {
    position = Vector2(0, 0);
    size = Vector2(ballGame.gridCellSize, ballGame.gridCellSize);
    anchor = Anchor.topLeft;
    var paint1 = BasicPalette.green.paint()..style = PaintingStyle.fill;

    var hitbox = RectangleHitbox()
      ..paint = paint1
      ..renderShape = true
      ..collisionType = CollisionType.passive;
    add(hitbox);
  }
}
