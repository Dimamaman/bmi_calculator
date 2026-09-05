import 'dart:math';

import 'package:flutter/material.dart';

const _bg = Color(0xFFE8836A);
const _starColor = Color(0xFFF2C872);
const _dimText = Color(0xFFCF6E57);

const _words = [
  'Goal-setting',
  'Dedication',
  'Workflow',
  'Efficiency',
  'Concentration',
  'Discipline',
  'Balance',
  'Productivity',
  'Time-manager',
  'Performance',
  'Focus.',
];

class StarWindowOnboardingPage extends StatefulWidget {
  const StarWindowOnboardingPage({super.key});

  @override
  State<StarWindowOnboardingPage> createState() =>
      _StarWindowOnboardingPageState();
}

class _StarWindowOnboardingPageState extends State<StarWindowOnboardingPage>
    with TickerProviderStateMixin {
  late AnimationController _travelCtrl;
  late AnimationController _rotateCtrl;

  bool _stopped = false;

  @override
  void initState() {
    super.initState();
    _travelCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 14000),
    )..repeat();

    _rotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..repeat();
  }

  @override
  void dispose() {
    _travelCtrl.dispose();
    _rotateCtrl.dispose();
    super.dispose();
  }

  void _onGetStarted() {
    if (_stopped) {
      _stopped = false;
      _travelCtrl.repeat();
      _rotateCtrl.repeat();
    }
  }

  static const _lineHeight = 1.15;
  static const _fontSize = 46.0;
  static const _vertPad = 2.0;
  static const _itemH = _fontSize * _lineHeight + _vertPad * 2;

  double _easedTravel(double t) {
    return Curves.easeOutCubic.transform(t);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: AnimatedBuilder(
        animation: Listenable.merge([_travelCtrl, _rotateCtrl]),
        builder: (context, _) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final screenH = constraints.maxHeight;
              final screenW = constraints.maxWidth;
              final starR = screenW * 0.55;
              final totalTravel = screenH + starR * 2;
              final eased = _easedTravel(_travelCtrl.value);
              final starCenterY = -starR + eased * totalTravel;
              final starCenterX = screenW * 0.22;
              final rotation = _rotateCtrl.value * 2 * pi;

              final topOffset = screenH * 0.08;
              int activeIndex = -1;
              for (var i = 0; i < _words.length; i++) {
                final wordCenterY = topOffset + i * _itemH + _itemH / 2;
                if ((starCenterY - wordCenterY).abs() < _itemH * 0.6) {
                  activeIndex = i;
                  break;
                }
              }

              if (!_stopped &&
                  activeIndex == _words.length - 1 &&
                  _travelCtrl.value > 0.85) {
                _stopped = true;
                _travelCtrl.stop();
                _rotateCtrl.stop();
              }

              return Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _StarPainter(
                        centerX: starCenterX,
                        centerY: starCenterY,
                        radius: starR,
                        rotation: rotation,
                      ),
                    ),
                  ),

                  Positioned.fill(
                    child: Padding(
                      padding: EdgeInsets.only(top: topOffset, left: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(_words.length, (i) {
                          final isActive = i == activeIndex;
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: _vertPad,
                            ),
                            child: Text(
                              _words[i],
                              style: TextStyle(
                                fontSize: _fontSize,
                                fontWeight: isActive
                                    ? FontWeight.w900
                                    : FontWeight.w600,
                                color: isActive ? Colors.black : _dimText,
                                height: _lineHeight,
                                fontStyle: isActive
                                    ? FontStyle.normal
                                    : FontStyle.italic,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),

                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: 50,
                    child: SafeArea(
                      top: false,
                      child: GestureDetector(
                        onTap: _onGetStarted,
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.black.withValues(alpha: 0.15),
                            ),
                            color: _bg.withValues(alpha: 0.5),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Get Started',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(width: 12),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.black87,
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

Path _starPath(double cx, double cy, double r, double rotation) {
  final path = Path();
  final waist = r * 0.10;
  final tipLen = r;

  final cosR = cos(rotation);
  final sinR = sin(rotation);

  Offset rotated(double dx, double dy) {
    return Offset(cx + dx * cosR - dy * sinR, cy + dx * sinR + dy * cosR);
  }

  final top = rotated(0, -tipLen);
  final right = rotated(tipLen, 0);
  final bottom = rotated(0, tipLen);
  final left = rotated(-tipLen, 0);

  final trCtrl1 = rotated(waist, -waist * 1.8);
  final trCtrl2 = rotated(waist * 1.8, -waist);
  final rbCtrl1 = rotated(waist * 1.8, waist);
  final rbCtrl2 = rotated(waist, waist * 1.8);
  final blCtrl1 = rotated(-waist, waist * 1.8);
  final blCtrl2 = rotated(-waist * 1.8, waist);
  final ltCtrl1 = rotated(-waist * 1.8, -waist);
  final ltCtrl2 = rotated(-waist, -waist * 1.8);

  path.moveTo(top.dx, top.dy);
  path.cubicTo(
    trCtrl1.dx,
    trCtrl1.dy,
    trCtrl2.dx,
    trCtrl2.dy,
    right.dx,
    right.dy,
  );
  path.cubicTo(
    rbCtrl1.dx,
    rbCtrl1.dy,
    rbCtrl2.dx,
    rbCtrl2.dy,
    bottom.dx,
    bottom.dy,
  );
  path.cubicTo(
    blCtrl1.dx,
    blCtrl1.dy,
    blCtrl2.dx,
    blCtrl2.dy,
    left.dx,
    left.dy,
  );
  path.cubicTo(ltCtrl1.dx, ltCtrl1.dy, ltCtrl2.dx, ltCtrl2.dy, top.dx, top.dy);
  path.close();
  return path;
}

class _StarPainter extends CustomPainter {
  final double centerX;
  final double centerY;
  final double radius;
  final double rotation;

  _StarPainter({
    required this.centerX,
    required this.centerY,
    required this.radius,
    required this.rotation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final outer = _starPath(centerX, centerY, radius, rotation);
    final inner = _starPath(centerX, centerY, radius * 0.30, rotation);
    final combined = Path.combine(PathOperation.difference, outer, inner);

    canvas.drawPath(combined, Paint()..color = _starColor);

    final linePaint = Paint()
      ..color = _bg.withValues(alpha: 0.25)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final cosR = cos(rotation);
    final sinR = sin(rotation);

    void drawCrossLine(double dx, double dy) {
      canvas.drawLine(
        Offset(
          centerX + dx * cosR - dy * sinR,
          centerY + dx * sinR + dy * cosR,
        ),
        Offset(
          centerX - dx * cosR + dy * sinR,
          centerY - dx * sinR - dy * cosR,
        ),
        linePaint,
      );
    }

    drawCrossLine(0, -radius);
    drawCrossLine(-radius, 0);
  }

  @override
  bool shouldRepaint(_StarPainter old) => true;
}
