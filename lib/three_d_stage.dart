import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart' as vm;

enum ThreeDStageStyle { emblem, profile, scoreOrb, blackHole }

/// Small, GPU-rendered 3D stage used for the startup mark, score display,
/// profile handoff, and active scoring state.
class ThreeDStage extends StatefulWidget {
  const ThreeDStage({
    required this.style,
    required this.identity,
    required this.accent,
    required this.surface,
    super.key,
  });

  final ThreeDStageStyle style;
  final String identity;
  final Color accent;
  final Color surface;

  @override
  State<ThreeDStage> createState() => _ThreeDStageState();
}

class _ThreeDStageState extends State<ThreeDStage> {
  final Scene _scene = Scene();
  Node? _rotor;
  final List<(Node node, double speed, double tilt)> _blackHoleRings = [];
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void didUpdateWidget(covariant ThreeDStage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.identity != widget.identity ||
        oldWidget.style != widget.style ||
        oldWidget.accent != widget.accent ||
        oldWidget.surface != widget.surface) {
      final previous = _rotor;
      if (previous != null) _scene.root.remove(previous);
      _blackHoleRings.clear();
      _ready = false;
      _initialize();
    }
  }

  Future<void> _initialize() async {
    try {
      await Scene.initializeStaticResources();
      if (!mounted) return;
      final root = Node(name: 'TrustScore 3D object');
      _rotor = root;
      switch (widget.style) {
        case ThreeDStageStyle.emblem:
          _buildEmblem(root);
        case ThreeDStageStyle.profile:
          _buildProfile(root);
        case ThreeDStageStyle.scoreOrb:
          _buildScoreOrb(root);
        case ThreeDStageStyle.blackHole:
          _buildBlackHole(root);
      }
      _scene.root.add(root);
      if (mounted) setState(() => _ready = true);
    } catch (_) {
      if (mounted) setState(() => _ready = false);
    }
  }

  PhysicallyBasedMaterial _material(Color color, {double metalness = .18}) {
    final material = PhysicallyBasedMaterial()
      ..baseColorFactor = vm.Vector4(
        _linear(color.r),
        _linear(color.g),
        _linear(color.b),
        color.a,
      )
      ..metallicFactor = metalness
      ..roughnessFactor = .28;
    return material;
  }

  double _linear(double component) => component <= .04045
      ? component / 12.92
      : math.pow((component + .055) / 1.055, 2.4).toDouble();

  Node _meshNode({
    required String name,
    required Geometry geometry,
    required PhysicallyBasedMaterial material,
    vm.Vector3? position,
    vm.Vector3? scale,
    vm.Quaternion? rotation,
  }) {
    final node = Node(name: name, mesh: Mesh(geometry, material));
    if (position != null) node.position = position;
    if (scale != null) node.scale = scale;
    if (rotation != null) node.rotation = rotation;
    return node;
  }

  void _buildEmblem(Node root) {
    final coreMaterial = _material(widget.surface, metalness: .7);
    final accentMaterial = _material(widget.accent, metalness: .72);
    final lightMaterial = _material(const Color(0xFFF4F3EF), metalness: .88);
    root.add(_meshNode(
      name: 'carbon core',
      geometry: SphereGeometry(radius: .48, segments: 64, rings: 40),
      material: coreMaterial,
    ));
    root.add(_meshNode(
      name: 'crimson orbit',
      geometry: TorusGeometry(
          radius: .72,
          tubeRadius: .055,
          radialSegments: 96,
          tubularSegments: 32),
      material: accentMaterial,
      rotation: vm.Quaternion.axisAngle(vm.Vector3(1, 0, 0), .82),
    ));
    root.add(_meshNode(
      name: 'silver orbit',
      geometry: TorusGeometry(
          radius: .92,
          tubeRadius: .025,
          radialSegments: 96,
          tubularSegments: 32),
      material: lightMaterial,
      rotation: vm.Quaternion.axisAngle(vm.Vector3(0, 1, 0), .92),
    ));
    root.add(_meshNode(
      name: 'accent satellite',
      geometry: SphereGeometry(radius: .095, segments: 32, rings: 20),
      material: accentMaterial,
      position: vm.Vector3(.78, .34, .12),
    ));
  }

  void _buildBlackHole(Node root) {
    final voidMaterial = _material(const Color(0xFF010105), metalness: .02)
      ..roughnessFactor = .04;
    final red = _material(const Color(0xFFE10600), metalness: .78);
    final white = _material(const Color(0xFFE7F0FF), metalness: .92);
    final silver = _material(const Color(0xFFA2A2A6), metalness: .76);

    root.add(_meshNode(
      name: 'event horizon',
      geometry: SphereGeometry(radius: .76, segments: 80, rings: 52),
      material: voidMaterial,
    ));

    void addDisk({
      required String name,
      required double radius,
      required double tube,
      required PhysicallyBasedMaterial material,
      required double speed,
      required double tilt,
    }) {
      final node = _meshNode(
        name: name,
        geometry: TorusGeometry(
          radius: radius,
          tubeRadius: tube,
          radialSegments: 128,
          tubularSegments: 40,
        ),
        material: material,
        rotation: vm.Quaternion.axisAngle(vm.Vector3(1, 0, 0), tilt),
      );
      _blackHoleRings.add((node, speed, tilt));
      root.add(node);
    }

    addDisk(
      name: 'inner photon ring',
      radius: .9,
      tube: .045,
      material: white,
      speed: -1.5,
      tilt: 1.08,
    );
    addDisk(
      name: 'inner accretion disk',
      radius: 1.12,
      tube: .19,
      material: red,
      speed: 1.15,
      tilt: 1.16,
    );
    addDisk(
      name: 'outer accretion disk',
      radius: 1.52,
      tube: .14,
      material: white,
      speed: -.75,
      tilt: .93,
    );
    addDisk(
      name: 'gravitational lens halo',
      radius: 1.98,
      tube: .045,
      material: silver,
      speed: .42,
      tilt: 1.26,
    );

    final satelliteMaterial = _material(const Color(0xFFE10600), metalness: .6);
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      root.add(_meshNode(
        name: 'orbiting particle $i',
        geometry: SphereGeometry(
            radius: .035 + (i % 3) * .012, segments: 20, rings: 12),
        material: satelliteMaterial,
        position: vm.Vector3(math.cos(angle) * 2.05, math.sin(angle) * .5,
            math.sin(angle) * .42),
      ));
    }
  }

  void _buildScoreOrb(Node root) {
    final core = _material(widget.surface, metalness: .82)
      ..roughnessFactor = .2;
    final crimson = _material(widget.accent, metalness: .86)
      ..roughnessFactor = .19;
    final silver = _material(const Color(0xFFE7EAF0), metalness: .94)
      ..roughnessFactor = .16;
    final dark = _material(const Color(0xFF121318), metalness: .68)
      ..roughnessFactor = .22;

    root.add(_meshNode(
      name: 'sculpted score core',
      geometry: SphereGeometry(radius: .54, segments: 64, rings: 44),
      material: core,
    ));
    root.add(_meshNode(
      name: 'crimson score seal',
      geometry: SphereGeometry(radius: .39, segments: 56, rings: 36),
      material: crimson,
      position: vm.Vector3(0, 0, .22),
      scale: vm.Vector3(.92, .92, .48),
    ));
    root.add(_meshNode(
      name: 'dark inner medallion',
      geometry: SphereGeometry(radius: .3, segments: 48, rings: 32),
      material: dark,
      position: vm.Vector3(0, 0, .34),
      scale: vm.Vector3(.96, .96, .34),
    ));

    void addOrbit({
      required String name,
      required double radius,
      required double tube,
      required PhysicallyBasedMaterial material,
      required double speed,
      required double tilt,
    }) {
      final orbit = _meshNode(
        name: name,
        geometry: TorusGeometry(
          radius: radius,
          tubeRadius: tube,
          radialSegments: 96,
          tubularSegments: 32,
        ),
        material: material,
        rotation: vm.Quaternion.axisAngle(vm.Vector3(1, 0, 0), tilt),
      );
      _blackHoleRings.add((orbit, speed, tilt));
      root.add(orbit);
    }

    addOrbit(
      name: 'outer titanium orbit',
      radius: .86,
      tube: .035,
      material: silver,
      speed: -.48,
      tilt: .84,
    );
    addOrbit(
      name: 'crimson orbital rail',
      radius: .7,
      tube: .052,
      material: crimson,
      speed: .76,
      tilt: 1.23,
    );
    addOrbit(
      name: 'fine score halo',
      radius: 1.04,
      tube: .018,
      material: silver,
      speed: .24,
      tilt: .48,
    );

    for (var i = 0; i < 3; i++) {
      final angle = i * math.pi * 2 / 3;
      root.add(_meshNode(
        name: 'score satellite ${i + 1}',
        geometry: SphereGeometry(radius: .065, segments: 28, rings: 18),
        material: i == 1 ? silver : crimson,
        position: vm.Vector3(
          math.cos(angle) * .93,
          math.sin(angle) * .36,
          math.sin(angle) * .48,
        ),
      ));
    }
  }

  void _buildProfile(Node root) {
    final seed = _stableSeed(widget.identity);
    final skinColors = [
      const Color(0xFFECC4A1),
      const Color(0xFFD79C77),
      const Color(0xFFB97958),
      const Color(0xFF87553F),
      const Color(0xFF684333),
    ];
    final hairColors = [
      const Color(0xFF181916),
      const Color(0xFF35251F),
      const Color(0xFF584436),
      const Color(0xFF252B31),
    ];
    final skin = _material(skinColors[seed % skinColors.length]);
    final hair = _material(hairColors[(seed ~/ 5) % hairColors.length]);
    final jacket = _material(widget.accent, metalness: .12);
    final shadow = _material(widget.surface, metalness: .08);

    root.add(_meshNode(
      name: 'jacket',
      geometry: CapsuleGeometry(
          radius: .48, height: .48, radialSegments: 48, capRings: 16),
      material: jacket,
      position: vm.Vector3(0, -.52, 0),
      scale: vm.Vector3(1.28, 1.05, .74),
    ));
    root.add(_meshNode(
      name: 'shirt panel',
      geometry: CuboidGeometry(vm.Vector3(.62, .7, .12)),
      material: shadow,
      position: vm.Vector3(0, -.47, .335),
      scale: vm.Vector3(.42, .74, .18),
    ));
    root.add(_meshNode(
      name: 'neck',
      geometry: CapsuleGeometry(
          radius: .21, height: .25, radialSegments: 32, capRings: 12),
      material: skin,
      position: vm.Vector3(0, .22, 0),
      scale: vm.Vector3(.47, .55, .5),
    ));
    root.add(_meshNode(
      name: 'head',
      geometry: SphereGeometry(radius: .5, segments: 64, rings: 40),
      material: skin,
      position: vm.Vector3(0, .67, 0),
      scale: vm.Vector3(.78, 1, .72),
    ));
    root.add(_meshNode(
      name: 'hair',
      geometry: SphereGeometry(radius: .5, segments: 48, rings: 28),
      material: hair,
      position: vm.Vector3(0, .94, -.015),
      scale: vm.Vector3(.84, .43, .78),
    ));
    root.add(_meshNode(
      name: 'left ear',
      geometry: SphereGeometry(radius: .15, segments: 24, rings: 16),
      material: skin,
      position: vm.Vector3(-.39, .61, .015),
      scale: vm.Vector3(.22, .32, .28),
    ));
    root.add(_meshNode(
      name: 'right ear',
      geometry: SphereGeometry(radius: .15, segments: 24, rings: 16),
      material: skin,
      position: vm.Vector3(.39, .61, .015),
      scale: vm.Vector3(.22, .32, .28),
    ));
  }

  int _stableSeed(String value) {
    var hash = 0x811c9dc5;
    for (final unit in value.codeUnits) {
      hash = ((hash ^ unit) * 0x01000193) & 0x7fffffff;
    }
    return hash;
  }

  void _onTick(Duration elapsed, double deltaSeconds) {
    final rotor = _rotor;
    if (rotor == null) return;
    final seconds = elapsed.inMicroseconds / 1e6;
    if (widget.style == ThreeDStageStyle.blackHole ||
        widget.style == ThreeDStageStyle.scoreOrb) {
      for (final ring in _blackHoleRings) {
        final rotation = vm.Quaternion.axisAngle(
              vm.Vector3(1, 0, 0),
              ring.$3,
            ) *
            vm.Quaternion.axisAngle(vm.Vector3(0, 0, 1), seconds * ring.$2);
        ring.$1.rotation = rotation;
      }
      final speed = widget.style == ThreeDStageStyle.scoreOrb ? .22 : .16;
      rotor.rotation =
          vm.Quaternion.axisAngle(vm.Vector3(0, 1, 0), seconds * speed);
      if (widget.style == ThreeDStageStyle.scoreOrb) {
        rotor.position = vm.Vector3(0, math.sin(seconds * 1.35) * .045, 0);
      }
      return;
    }
    final angle =
        widget.style == ThreeDStageStyle.emblem ? seconds * .72 : seconds * .34;
    rotor.rotation = vm.Quaternion.axisAngle(vm.Vector3(0, 1, 0), angle);
  }

  @override
  void dispose() {
    _scene.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) return const SizedBox.expand();
    final camera = widget.style == ThreeDStageStyle.emblem
        ? PerspectiveCamera(position: vm.Vector3(2.25, 1.55, 4.3))
        : widget.style == ThreeDStageStyle.scoreOrb
            ? PerspectiveCamera(
                position: vm.Vector3(0, .1, 3.35),
                target: vm.Vector3(0, 0, 0),
              )
            : widget.style == ThreeDStageStyle.blackHole
                ? null
                : PerspectiveCamera(
                    position: vm.Vector3(0, .38, 3.25),
                    target: vm.Vector3(0, .18, 0),
                  );
    return RepaintBoundary(
      child: SceneView(
        _scene,
        camera: camera,
        cameraBuilder: widget.style == ThreeDStageStyle.blackHole
            ? (elapsed) {
                final seconds = elapsed.inMicroseconds / 1e6;
                final approach =
                    math.sin((seconds / 2.6).clamp(0.0, 1.0) * math.pi);
                final distance = 7.2 - 3.4 * approach;
                return PerspectiveCamera(
                  position:
                      vm.Vector3(math.sin(seconds * .18) * .42, .2, distance),
                  target: vm.Vector3.zero(),
                );
              }
            : null,
        maxFrameRate: 60,
        onTick: _onTick,
        pixelRatio: MediaQuery.devicePixelRatioOf(context).clamp(1.0, 1.5),
      ),
    );
  }
}
