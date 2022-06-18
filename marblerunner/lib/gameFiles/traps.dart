import 'main.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

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
