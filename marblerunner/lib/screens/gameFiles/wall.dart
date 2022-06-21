import 'game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

class Wall extends RectangleComponent with CollisionCallbacks {
  Wall(Vector2 position, Vector2 size, Anchor anchor) {
    this.position = position;
    this.size = size;
    this.anchor = anchor;
    var paint1 = BasicPalette.black.paint()..style = PaintingStyle.fill;

    var hitbox = RectangleHitbox()
      ..paint = paint1
      ..renderShape = true
      ..collisionType = CollisionType.passive;
    add(hitbox);
  }
}
