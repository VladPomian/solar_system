import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_ar/core/constants/simulation_constants.dart';
import 'package:flutter_ar/core/models/celestial_body.dart';
import 'package:flutter_ar/core/models/orbit.dart';
import 'package:flutter_ar/core/services/mesh_generator.dart';
import 'package:flutter_cube/flutter_cube.dart';

class SimulationPage extends StatefulWidget {
  const SimulationPage({super.key, this.title = 'Planet'});

  final String title;

  @override
  State<SimulationPage> createState() => _SimulationPageState();
}

class _SimulationPageState extends State<SimulationPage> with SingleTickerProviderStateMixin {
  late Scene _scene;
  late CelestialBody _sun;
  late CelestialBody _earth;
  late CelestialBody _mercury;
  late CelestialBody _venus;
  late CelestialBody _mars;
  late CelestialBody _jupiter;
  late CelestialBody _saturn;
  late CelestialBody _uranus;
  late CelestialBody _neptune;
  late CelestialBody _stars;
  late CelestialBody _saturnRings;
  late CelestialBody _moon;
  late Orbit _earthOrbit;
  late Orbit _mercuryOrbit;
  late Orbit _venusOrbit;
  late Orbit _marsOrbit;
  late Orbit _jupiterOrbit;
  late Orbit _saturnOrbit;
  late Orbit _uranusOrbit;
  late Orbit _neptuneOrbit;
  late Orbit _moonOrbit;
  late AnimationController _controller;
  double _earthOrbitAngle = 0.0;
  double _mercuryOrbitAngle = 0.0;
  double _venusOrbitAngle = 0.0;
  double _marsOrbitAngle = 0.0;
  double _jupiterOrbitAngle = 0.0;
  double _saturnOrbitAngle = 0.0;
  double _uranusOrbitAngle = 0.0;
  double _neptuneOrbitAngle = 0.0;
  double _moonOrbitAngle = 0.0;

  Future<void> _addObjectToScene({
    required Object parent,
    required String name,
    required double radius,
    required bool backfaceCulling,
    String? texturePath,
    bool isOrbit = false,
    bool isRing = false,
    bool isMoonOrbit = false,
  }) async {
    Mesh mesh;
    if (isOrbit) {
      mesh = await generateTorusMesh(
        majorRadius: radius,
        minorRadius: isMoonOrbit ? SimulationConstants.moonOrbitMinorRadius : 0.05,
        texturePath: texturePath,
        context: context,
      );
    } else if (isRing) {
      mesh = await generateTorusMesh(
        majorRadius: SimulationConstants.saturnRingsMajorRadius,
        minorRadius: SimulationConstants.saturnRingsMinorRadius,
        yScale: SimulationConstants.saturnRingsYScale,
        texturePath: texturePath,
        context: context,
      );
    } else {
      mesh = await generateSphereMesh(
        radius: radius,
        texturePath: texturePath,
        context: context,
      );
    }
    parent.add(Object(name: name, mesh: mesh, backfaceCulling: backfaceCulling));
  }

  Future<void> _onSceneCreated(Scene scene) async {
    _scene = scene;
    _scene.camera.position.z = 60;

    _sun = CelestialBody(name: 'sun', scale: SimulationConstants.sunScale, rotationZ: 7.25);
    _earth = CelestialBody(name: 'earth', scale: SimulationConstants.earthScale, rotationZ: 23.44);
    _mercury = CelestialBody(name: 'mercury', scale: SimulationConstants.mercuryScale, rotationZ: 0.03);
    _venus = CelestialBody(name: 'venus', scale: SimulationConstants.venusScale, rotationZ: 177.4);
    _mars = CelestialBody(name: 'mars', scale: SimulationConstants.marsScale, rotationZ: 25.19);
    _jupiter = CelestialBody(name: 'jupiter', scale: SimulationConstants.jupiterScale, rotationZ: 3.13);
    _saturn = CelestialBody(name: 'saturn', scale: SimulationConstants.saturnScale, rotationZ: 26.73);
    _uranus = CelestialBody(name: 'uranus', scale: SimulationConstants.uranusScale, rotationZ: 97.77);
    _neptune = CelestialBody(name: 'neptune', scale: SimulationConstants.neptuneScale, rotationZ: 28.32);
    _stars = CelestialBody(name: 'stars', scale: SimulationConstants.starsScale);
    _saturnRings = CelestialBody(name: 'saturnRings', scale: SimulationConstants.saturnScale, rotationZ: 26.73);
    _moon = CelestialBody(name: 'moon', scale: SimulationConstants.moonScale, rotationZ: 6.68);
    _earthOrbit = Orbit(name: 'earthOrbit', radius: SimulationConstants.earthOrbitRadius);
    _mercuryOrbit = Orbit(name: 'mercuryOrbit', radius: SimulationConstants.mercuryOrbitRadius);
    _venusOrbit = Orbit(name: 'venusOrbit', radius: SimulationConstants.venusOrbitRadius);
    _marsOrbit = Orbit(name: 'marsOrbit', radius: SimulationConstants.marsOrbitRadius);
    _jupiterOrbit = Orbit(name: 'jupiterOrbit', radius: SimulationConstants.jupiterOrbitRadius);
    _saturnOrbit = Orbit(name: 'saturnOrbit', radius: SimulationConstants.saturnOrbitRadius);
    _uranusOrbit = Orbit(name: 'uranusOrbit', radius: SimulationConstants.uranusOrbitRadius);
    _neptuneOrbit = Orbit(name: 'neptuneOrbit', radius: SimulationConstants.neptuneOrbitRadius);
    _moonOrbit = Orbit(name: 'moonOrbit', radius: SimulationConstants.moonOrbitRadius, rotationX: SimulationConstants.moonOrbitInclination);

    await Future.wait([
      _addObjectToScene(parent: _sun.object, name: 'surface', radius: 0.485, backfaceCulling: true, texturePath: 'assets/simulation/2k_sun.jpg'),
      _addObjectToScene(parent: _earth.object, name: 'surface', radius: 0.485, backfaceCulling: true, texturePath: 'assets/simulation/4096_earth.jpg'),
      _addObjectToScene(parent: _mercury.object, name: 'surface', radius: 0.485, backfaceCulling: true, texturePath: 'assets/simulation/2k_mercury.jpg'),
      _addObjectToScene(parent: _venus.object, name: 'surface', radius: 0.485, backfaceCulling: true, texturePath: 'assets/simulation/2k_venus.jpg'),
      _addObjectToScene(parent: _mars.object, name: 'surface', radius: 0.485, backfaceCulling: true, texturePath: 'assets/simulation/2k_mars.jpg'),
      _addObjectToScene(parent: _jupiter.object, name: 'surface', radius: 0.485, backfaceCulling: true, texturePath: 'assets/simulation/2k_jupiter.jpg'),
      _addObjectToScene(parent: _saturn.object, name: 'surface', radius: 0.485, backfaceCulling: true, texturePath: 'assets/simulation/2k_saturn.jpg'),
      _addObjectToScene(parent: _uranus.object, name: 'surface', radius: 0.485, backfaceCulling: true, texturePath: 'assets/simulation/2k_uranus.jpg'),
      _addObjectToScene(parent: _neptune.object, name: 'surface', radius: 0.485, backfaceCulling: true, texturePath: 'assets/simulation/2k_neptune.jpg'),
      _addObjectToScene(parent: _saturnRings.object, name: 'rings', radius: 0.0, backfaceCulling: false, texturePath: 'assets/simulation/2k_saturn_ring.png', isRing: true),
      _addObjectToScene(parent: _moon.object, name: 'surface', radius: 0.485, backfaceCulling: true, texturePath: 'assets/simulation/2k_moon.jpg'),
      _addObjectToScene(parent: _stars.object, name: 'surface', radius: 0.5, backfaceCulling: false, texturePath: 'assets/simulation/2k_stars.jpg'),
      _addObjectToScene(parent: _earthOrbit.object, name: 'ring', radius: SimulationConstants.earthOrbitRadius, backfaceCulling: false, isOrbit: true),
      _addObjectToScene(parent: _mercuryOrbit.object, name: 'ring', radius: SimulationConstants.mercuryOrbitRadius, backfaceCulling: false, isOrbit: true),
      _addObjectToScene(parent: _venusOrbit.object, name: 'ring', radius: SimulationConstants.venusOrbitRadius, backfaceCulling: false, isOrbit: true),
      _addObjectToScene(parent: _marsOrbit.object, name: 'ring', radius: SimulationConstants.marsOrbitRadius, backfaceCulling: false, isOrbit: true),
      _addObjectToScene(parent: _jupiterOrbit.object, name: 'ring', radius: SimulationConstants.jupiterOrbitRadius, backfaceCulling: false, isOrbit: true),
      _addObjectToScene(parent: _saturnOrbit.object, name: 'ring', radius: SimulationConstants.saturnOrbitRadius, backfaceCulling: false, isOrbit: true),
      _addObjectToScene(parent: _uranusOrbit.object, name: 'ring', radius: SimulationConstants.uranusOrbitRadius, backfaceCulling: false, isOrbit: true),
      _addObjectToScene(parent: _neptuneOrbit.object, name: 'ring', radius: SimulationConstants.neptuneOrbitRadius, backfaceCulling: false, isOrbit: true),
      _addObjectToScene(parent: _moonOrbit.object, name: 'ring', radius: SimulationConstants.moonOrbitRadius, backfaceCulling: false, isOrbit: true, isMoonOrbit: true),
    ]);

    _scene.world
      ..add(_sun.object)
      ..add(_earth.object)
      ..add(_mercury.object)
      ..add(_venus.object)
      ..add(_mars.object)
      ..add(_jupiter.object)
      ..add(_saturn.object)
      ..add(_uranus.object)
      ..add(_neptune.object)
      ..add(_saturnRings.object)
      ..add(_moon.object)
      ..add(_stars.object)
      ..add(_earthOrbit.object)
      ..add(_mercuryOrbit.object)
      ..add(_venusOrbit.object)
      ..add(_marsOrbit.object)
      ..add(_jupiterOrbit.object)
      ..add(_saturnOrbit.object)
      ..add(_uranusOrbit.object)
      ..add(_neptuneOrbit.object)
      ..add(_moonOrbit.object);

    _scene.updateTexture();
    _controller.repeat();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..addListener(() {
        _sun.object.rotation.y = (_sun.object.rotation.y + SimulationConstants.sunRotationSpeed) % 360;
        _sun.object.updateTransform();

        _earth.object.rotation.y = (_earth.object.rotation.y + SimulationConstants.earthRotationSpeed) % 360;
        _earthOrbitAngle -= SimulationConstants.earthOrbitSpeed;
        _earth.object.position
          ..x = SimulationConstants.earthOrbitRadius * math.cos(_earthOrbitAngle)
          ..z = SimulationConstants.earthOrbitRadius * math.sin(_earthOrbitAngle)
          ..y = 0.0;
        _earth.object.updateTransform();

        _mercury.object.rotation.y = (_mercury.object.rotation.y + SimulationConstants.mercuryRotationSpeed) % 360;
        _mercuryOrbitAngle -= SimulationConstants.mercuryOrbitSpeed;
        _mercury.object.position
          ..x = SimulationConstants.mercuryOrbitRadius * math.cos(_mercuryOrbitAngle)
          ..z = SimulationConstants.mercuryOrbitRadius * math.sin(_mercuryOrbitAngle)
          ..y = 0.0;
        _mercury.object.updateTransform();

        _venus.object.rotation.y = (_venus.object.rotation.y + SimulationConstants.venusRotationSpeed) % 360;
        _venusOrbitAngle -= SimulationConstants.venusOrbitSpeed;
        _venus.object.position
          ..x = SimulationConstants.venusOrbitRadius * math.cos(_venusOrbitAngle)
          ..z = SimulationConstants.venusOrbitRadius * math.sin(_venusOrbitAngle)
          ..y = 0.0;
        _venus.object.updateTransform();

        _mars.object.rotation.y = (_mars.object.rotation.y + SimulationConstants.marsRotationSpeed) % 360;
        _marsOrbitAngle -= SimulationConstants.marsOrbitSpeed;
        _mars.object.position
          ..x = SimulationConstants.marsOrbitRadius * math.cos(_marsOrbitAngle)
          ..z = SimulationConstants.marsOrbitRadius * math.sin(_marsOrbitAngle)
          ..y = 0.0;
        _mars.object.updateTransform();

        _jupiter.object.rotation.y = (_jupiter.object.rotation.y + SimulationConstants.jupiterRotationSpeed) % 360;
        _jupiterOrbitAngle -= SimulationConstants.jupiterOrbitSpeed;
        _jupiter.object.position
          ..x = SimulationConstants.jupiterOrbitRadius * math.cos(_jupiterOrbitAngle)
          ..z = SimulationConstants.jupiterOrbitRadius * math.sin(_jupiterOrbitAngle)
          ..y = 0.0;
        _jupiter.object.updateTransform();

        _saturn.object.rotation.y = (_saturn.object.rotation.y + SimulationConstants.saturnRotationSpeed) % 360;
        _saturnOrbitAngle -= SimulationConstants.saturnOrbitSpeed;
        _saturn.object.position
          ..x = SimulationConstants.saturnOrbitRadius * math.cos(_saturnOrbitAngle)
          ..z = SimulationConstants.saturnOrbitRadius * math.sin(_saturnOrbitAngle)
          ..y = 0.0;
        _saturn.object.updateTransform();

        _saturnRings.object.position.setFrom(_saturn.object.position);
        _saturnRings.object.updateTransform();

        _uranus.object.rotation.y = (_uranus.object.rotation.y + SimulationConstants.uranusRotationSpeed) % 360;
        _uranusOrbitAngle -= SimulationConstants.uranusOrbitSpeed;
        _uranus.object.position
          ..x = SimulationConstants.uranusOrbitRadius * math.cos(_uranusOrbitAngle)
          ..z = SimulationConstants.uranusOrbitRadius * math.sin(_uranusOrbitAngle)
          ..y = 0.0;
        _uranus.object.updateTransform();

        _neptune.object.rotation.y = (_neptune.object.rotation.y + SimulationConstants.neptuneRotationSpeed) % 360;
        _neptuneOrbitAngle -= SimulationConstants.neptuneOrbitSpeed;
        _neptune.object.position
          ..x = SimulationConstants.neptuneOrbitRadius * math.cos(_neptuneOrbitAngle)
          ..z = SimulationConstants.neptuneOrbitRadius * math.sin(_neptuneOrbitAngle)
          ..y = 0.0;
        _neptune.object.updateTransform();

        _moon.object.rotation.y = (_moon.object.rotation.y + SimulationConstants.moonRotationSpeed) % 360;
        _moonOrbitAngle -= SimulationConstants.moonOrbitSpeed;

        final double localX = SimulationConstants.moonOrbitRadius * math.cos(_moonOrbitAngle);
        final double localZ = SimulationConstants.moonOrbitRadius * math.sin(_moonOrbitAngle);
        final double inclinationRad = SimulationConstants.moonOrbitInclination * math.pi / 180.0;

        final double rotatedY = -localZ * math.sin(inclinationRad);
        final double rotatedZ = localZ * math.cos(inclinationRad);

        _moon.object.position
          ..x = _earth.object.position.x + localX
          ..y = _earth.object.position.y + rotatedY
          ..z = _earth.object.position.z + rotatedZ;

        _moonOrbit.object.position.setFrom(_earth.object.position);
        _moon.object.updateTransform();
        _moonOrbit.object.updateTransform();

        _scene.update();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Cube(onSceneCreated: _onSceneCreated),
    );
  }
}