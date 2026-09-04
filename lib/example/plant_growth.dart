import 'dart:math';

import 'package:flutter/material.dart';

const _skyTop = Color(0xFFE8F4FD);
const _skyBot = Color(0xFFB8DCF0);
const _soil = Color(0xFF5D4037);
const _soilDark = Color(0xFF3E2723);
const _stem = Color(0xFF4CAF50);
const _stemDark = Color(0xFF388E3C);
const _leaf = Color(0xFF66BB6A);
const _leafDark = Color(0xFF43A047);
const _petalPink = Color(0xFFE91E63);
const _petalYellow = Color(0xFFFFC107);
const _petalCenter = Color(0xFFFF9800);
const _dropColor = Color(0xFF42A5F5);

class PlantGrowthPage extends StatefulWidget {
  const PlantGrowthPage({super.key});

  @override
  State<PlantGrowthPage> createState() => _PlantGrowthPageState();
}

class _PlantGrowthPageState extends State<PlantGrowthPage>
    with TickerProviderStateMixin {
  late AnimationController _growCtrl;
  late AnimationController _dropCtrl;

  late Animation<double> _seedPhase;
  late Animation<double> _stemPhase;
  late Animation<double> _leafPhase;
  late Animation<double> _flowerPhase;
  late Animation<double> _dropFall;

  int _stage = 0;
  bool _animating = false;

  @override
  void initState() {
    super.initState();

    _growCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _seedPhase = CurvedAnimation(
      parent: _growCtrl,
      curve: const Interval(0.0, 0.25, curve: Curves.easeOutCubic),
    );
    _stemPhase = CurvedAnimation(
      parent: _growCtrl,
      curve: const Interval(0.15, 0.55, curve: Curves.easeOutCubic),
    );
    _leafPhase = CurvedAnimation(
      parent: _growCtrl,
      curve: const Interval(0.45, 0.75, curve: Curves.easeOutBack),
    );
    _flowerPhase = CurvedAnimation(
      parent: _growCtrl,
      curve: const Interval(0.65, 1.0, curve: Curves.easeOutBack),
    );

    _dropCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _dropFall = CurvedAnimation(
      parent: _dropCtrl,
      curve: Curves.bounceOut,
    );
  }

  @override
  void dispose() {
    _growCtrl.dispose();
    _dropCtrl.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    if (_animating) return;
    _animating = true;

    if (_stage >= 4) {
      _growCtrl.reset();
      _stage = 0;
      setState(() {});
      await Future.delayed(const Duration(milliseconds: 300));
      _animating = false;
      return;
    }

    await _dropCtrl.forward(from: 0);
    await Future.delayed(const Duration(milliseconds: 200));

    _stage++;
    final target = _stage / 4.0;
    await _growCtrl.animateTo(target);

    _animating = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: Listenable.merge([_growCtrl, _dropCtrl]),
          builder: (context, _) {
            return Stack(
              children: [
                // Sky gradient
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [_skyTop, _skyBot],
                    ),
                  ),
                ),
                // Plant scene
                CustomPaint(
                  size: Size.infinite,
                  painter: _PlantPainter(
                    seed: _seedPhase.value,
                    stem: _stemPhase.value,
                    leaf: _leafPhase.value,
                    flower: _flowerPhase.value,
                    drop: _dropFall.value,
                    showDrop: _dropCtrl.isAnimating || _dropCtrl.value < 1,
                  ),
                ),
                // Instructions
                SafeArea(
                  child: Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        Icon(
                          _stage >= 4
                              ? Icons.refresh_rounded
                              : Icons.water_drop_rounded,
                          color: _stage >= 4
                              ? _stemDark.withValues(alpha: 0.5)
                              : _dropColor.withValues(alpha: 0.5),
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _stage >= 4 ? 'Tap to restart' : 'Tap to water',
                          style: TextStyle(
                            color: _soilDark.withValues(alpha: 0.5),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _stageName(),
                          style: TextStyle(
                            color: _soilDark.withValues(alpha: 0.35),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _stageName() {
    switch (_stage) {
      case 0:
        return 'Seed';
      case 1:
        return 'Sprout';
      case 2:
        return 'Stem';
      case 3:
        return 'Leaves';
      case 4:
        return 'Bloom!';
      default:
        return '';
    }
  }
}

class _PlantPainter extends CustomPainter {
  final double seed;
  final double stem;
  final double leaf;
  final double flower;
  final double drop;
  final bool showDrop;

  _PlantPainter({
    required this.seed,
    required this.stem,
    required this.leaf,
    required this.flower,
    required this.drop,
    required this.showDrop,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final soilY = h * 0.72;
    final stemBottom = soilY - 10;
    final stemHeight = 180.0;
    final stemTop = stemBottom - stemHeight * stem;

    _drawSoil(canvas, w, h, soilY);

    if (showDrop && drop < 1) {
      _drawDrop(canvas, cx, soilY, drop);
    }

    if (seed > 0) {
      _drawSeed(canvas, cx, soilY, seed);
    }

    if (stem > 0) {
      _drawStem(canvas, cx, stemBottom, stemTop, stem);
    }

    if (leaf > 0 && stem > 0.5) {
      _drawLeaves(canvas, cx, stemBottom, stemTop, leaf);
    }

    if (flower > 0 && stem > 0.8) {
      _drawFlower(canvas, cx, stemTop, flower);
    }
  }

  void _drawSoil(Canvas canvas, double w, double h, double soilY) {
    final soilPath = Path()
      ..moveTo(0, soilY)
      ..quadraticBezierTo(w * 0.3, soilY - 15, w / 2, soilY - 8)
      ..quadraticBezierTo(w * 0.7, soilY - 2, w, soilY - 12)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(soilPath, Paint()..color = _soil);

    final topLine = Path()
      ..moveTo(0, soilY)
      ..quadraticBezierTo(w * 0.3, soilY - 15, w / 2, soilY - 8)
      ..quadraticBezierTo(w * 0.7, soilY - 2, w, soilY - 12);
    canvas.drawPath(
      topLine,
      Paint()
        ..color = _soilDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  void _drawDrop(Canvas canvas, double cx, double soilY, double v) {
    final startY = soilY - 200;
    final endY = soilY - 20;
    final y = startY + (endY - startY) * v;

    final dropPath = Path()
      ..moveTo(cx, y - 12)
      ..quadraticBezierTo(cx + 7, y, cx, y + 7)
      ..quadraticBezierTo(cx - 7, y, cx, y - 12)
      ..close();

    canvas.drawPath(dropPath, Paint()..color = _dropColor.withValues(alpha: 1 - v * 0.5));
  }

  void _drawSeed(Canvas canvas, double cx, double soilY, double v) {
    final r = 6.0 * v;
    final y = soilY - 8;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, y), width: r * 2, height: r * 1.3),
      Paint()..color = Color.lerp(_soilDark, _stemDark, v)!,
    );
  }

  void _drawStem(Canvas canvas, double cx, double bottom, double top, double v) {
    final path = Path()..moveTo(cx, bottom);

    final ctrlX = cx + 8 * sin(v * pi);
    final midY = bottom + (top - bottom) * 0.5;

    path.quadraticBezierTo(ctrlX, midY, cx, top);

    canvas.drawPath(
      path,
      Paint()
        ..color = _stem
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = _stemDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawLeaves(Canvas canvas, double cx, double bottom, double top, double v) {
    final midY = bottom + (top - bottom) * 0.45;

    _drawOneLeaf(canvas, cx, midY, v, isLeft: true);
    _drawOneLeaf(canvas, cx, midY - 35, v * 0.8, isLeft: false);
  }

  void _drawOneLeaf(
    Canvas canvas,
    double cx,
    double y,
    double v, {
    required bool isLeft,
  }) {
    if (v <= 0) return;
    final dir = isLeft ? -1.0 : 1.0;
    final leafLen = 35.0 * v;
    final tipX = cx + dir * leafLen;

    final path = Path()
      ..moveTo(cx, y)
      ..quadraticBezierTo(
        cx + dir * leafLen * 0.5,
        y - 18 * v,
        tipX,
        y - 5 * v,
      )
      ..quadraticBezierTo(
        cx + dir * leafLen * 0.5,
        y + 10 * v,
        cx,
        y,
      )
      ..close();

    canvas.drawPath(path, Paint()..color = _leaf);
    canvas.drawPath(
      path,
      Paint()
        ..color = _leafDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  void _drawFlower(Canvas canvas, double cx, double top, double v) {
    final centerY = top - 5;
    final petalCount = 6;
    final petalR = 16.0 * v;

    for (var i = 0; i < petalCount; i++) {
      final angle = (2 * pi / petalCount) * i - pi / 2;
      final px = cx + cos(angle) * petalR;
      final py = centerY + sin(angle) * petalR;

      canvas.drawCircle(
        Offset(px, py),
        8 * v,
        Paint()..color = i.isEven ? _petalPink : _petalYellow,
      );
    }

    canvas.drawCircle(
      Offset(cx, centerY),
      7 * v,
      Paint()..color = _petalCenter,
    );
  }

  @override
  bool shouldRepaint(_PlantPainter old) =>
      old.seed != seed ||
      old.stem != stem ||
      old.leaf != leaf ||
      old.flower != flower ||
      old.drop != drop ||
      old.showDrop != showDrop;
}
