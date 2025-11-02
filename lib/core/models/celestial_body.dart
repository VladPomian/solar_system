import 'package:flutter_cube/flutter_cube.dart';

class CelestialBody {
  final String name;
  final Object object;

  CelestialBody({
    required this.name,
    required double scale,
    double rotationZ = 0.0,
  }) : object = Object(name: name, scale: Vector3.all(scale)) {
    object.rotation.z = rotationZ;
    object.updateTransform();
  }
}