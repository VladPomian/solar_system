import 'package:flutter_cube/flutter_cube.dart';

class Orbit {
  final String name;
  final Object object;

  Orbit({
    required this.name,
    required double radius,
    double rotationX = 0.0,
  }) : object = Object(name: name, scale: Vector3.all(1.0)) {
    object.rotation.x = rotationX;
    object.updateTransform();
  }
}