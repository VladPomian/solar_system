import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart';

Future<Mesh> generateSphereMesh({
  num radius = 0.5,
  int latSegments = 32,
  int lonSegments = 64,
  String? texturePath,
  required BuildContext context,
}) async {
  final count = (latSegments + 1) * (lonSegments + 1);
  final vertices = List<Vector3>.filled(count, Vector3.zero());
  final texcoords = List<Offset>.filled(count, Offset.zero);
  final indices =
      List<Polygon>.filled(latSegments * lonSegments * 2, Polygon(0, 0, 0));

  var i = 0;
  for (var y = 0; y <= latSegments; ++y) {
    final v = y / latSegments;
    final sv = math.sin(v * math.pi);
    final cv = math.cos(v * math.pi);
    for (var x = 0; x <= lonSegments; ++x) {
      final u = x / lonSegments;
      vertices[i] = Vector3(
        radius * math.cos(u * math.pi * 2.0) * sv,
        radius * cv,
        radius * math.sin(u * math.pi * 2.0) * sv,
      );
      texcoords[i] = Offset(u, 1.0 - v);
      i++;
    }
  }

  i = 0;
  for (var y = 0; y < latSegments; ++y) {
    final base1 = (lonSegments + 1) * y;
    final base2 = (lonSegments + 1) * (y + 1);
    for (var x = 0; x < lonSegments; ++x) {
      indices[i++] = Polygon(base1 + x, base1 + x + 1, base2 + x);
      indices[i++] = Polygon(base1 + x + 1, base2 + x + 1, base2 + x);
    }
  }

  ui.Image? texture;
  if (texturePath != null) {
    try {
      texture = await loadImageFromAsset(texturePath, context);
    } catch (e) {
      texture = await createSolidColorTexture(Colors.grey);
    }
  }
  return Mesh(
    vertices: vertices,
    texcoords: texcoords,
    indices: indices,
    texture: texture,
    texturePath: texturePath,
  );
}

Future<Mesh> generateTorusMesh({
  num majorRadius = 8.0,
  num minorRadius = 0.05,
  int majorSegments = 64,
  int minorSegments = 8,
  double yScale = 1.0,
  String? texturePath,
  required BuildContext context,
}) async {
  final count = (majorSegments + 1) * (minorSegments + 1);
  final vertices = List<Vector3>.filled(count, Vector3.zero());
  final texcoords = List<Offset>.filled(count, Offset.zero);
  final indices =
      List<Polygon>.filled(majorSegments * minorSegments * 2, Polygon(0, 0, 0));

  var i = 0;
  for (var major = 0; major <= majorSegments; ++major) {
    final u = major / majorSegments;
    final majorAngle = u * 2 * math.pi;
    for (var minor = 0; minor <= minorSegments; ++minor) {
      final v = minor / minorSegments;
      final minorAngle = v * 2 * math.pi;
      vertices[i] = Vector3(
        (majorRadius + minorRadius * math.cos(minorAngle)) *
            math.cos(majorAngle),
        minorRadius * math.sin(minorAngle) * yScale,
        (majorRadius + minorRadius * math.cos(minorAngle)) *
            math.sin(majorAngle),
      );
      texcoords[i] = Offset(u, v);
      i++;
    }
  }

  i = 0;
  for (var major = 0; major < majorSegments; ++major) {
    final base1 = (minorSegments + 1) * major;
    final base2 = (minorSegments + 1) * (major + 1);
    for (var minor = 0; minor < minorSegments; ++minor) {
      indices[i++] = Polygon(base1 + minor, base1 + minor + 1, base2 + minor);
      indices[i++] =
          Polygon(base1 + minor + 1, base2 + minor + 1, base2 + minor);
    }
  }

  ui.Image? texture;
  if (texturePath != null) {
    try {
      texture = await loadImageFromAsset(texturePath, context);
    } catch (e) {
      texture = await createSolidColorTexture(Colors.transparent);
    }
  } else {
    texture = await createSolidColorTexture(Colors.white);
  }
  return Mesh(
    vertices: vertices,
    texcoords: texcoords,
    indices: indices,
    texture: texture,
    texturePath: texturePath,
  );
}

Future<ui.Image> loadImageFromAsset(
    String assetPath, BuildContext context) async {
  final data = await DefaultAssetBundle.of(context).load(assetPath);
  final bytes = data.buffer.asUint8List();
  final codec = await ui.instantiateImageCodec(bytes);
  final frameInfo = await codec.getNextFrame();
  return frameInfo.image;
}

Future<ui.Image> createSolidColorTexture(Color color) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, 1, 1));
  canvas.drawRect(const Rect.fromLTWH(0, 0, 1, 1), Paint()..color = color);
  final picture = recorder.endRecording();
  return picture.toImage(1, 1);
}