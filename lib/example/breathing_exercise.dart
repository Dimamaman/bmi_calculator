import 'dart:math';

import 'package:flutter/material.dart';

const _inhaleColor = Color(0xFF1A237E);
const _holdColor = Color(0xFF006064);
const _exhaleColor = Color(0xFF4A148C);
const _circleCore = Color(0xFF64FFDA);
const _circleMid = Color(0xFF80DEEA);
const _particleColor = Color(0xFFB2DFDB);

class BreathingExercisePage extends StatefulWidget {
  const BreathingExercisePage({super.key});

  @override
  State<BreathingExercisePage> createState() => _BreathingExercisePageState();
}

class _BreathingExercisePageState extends State<BreathingExercisePage>
    with TickerProviderStateMixin {
  late AnimationController _breathCtrl;
  late AnimationController _particleCtrl;

  bool _running = false;
  int _cycleCount = 0;

  static const _inhaleDur = 4.0;
  static const _holdDur = 4.0;
  static const _exhaleDur = 4.0;
  static const _totalDur = _inhaleDur + _holdDur + _exhaleDur;

  static const _inhaleEnd = _inhaleDur / _totalDur;
  static const _holdEnd = (_inhaleDur + _holdDur) / _totalDur;

  @override
  void initState() {
    super.initState();

    _breathCtrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (_totalDur * 1000).toInt()),
    );

    _breathCtrl.addStatusListener((s) {
      if (s == AnimationStatus.completed && _running) {
        _cycleCount++;
        _breathCtrl.forward(from: 0);
      }
    });

    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..repeat();
  }

  @override
  void dispose() {
    _breathCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _running = !_running;
      if (_running) {
        _cycleCount = 0;
        _breathCtrl.forward(from: 0);
      } else {
        _breathCtrl.stop();
        _breathCtrl.reset();
      }
    });
  }

  double _circleScale(double t) {
    const minS = 0.55;
    const maxS = 1.0;
    if (t <= _inhaleEnd) {
      final p = Curves.easeInOutSine.transform(t / _inhaleEnd);
      return minS + (maxS - minS) * p;
    } else if (t <= _holdEnd) {
      return maxS;
    } else {
      final p = Curves.easeInOutSine.transform((t - _holdEnd) / (1 - _holdEnd));
      return maxS - (maxS - minS) * p;
    }
  }

  String _phaseLabel(double t) {
    if (t <= _inhaleEnd) return 'Nafas oling';
    if (t <= _holdEnd) return 'Ushlab turing';
    return 'Chiqaring';
  }

  int _phaseSeconds(double t) {
    if (t <= _inhaleEnd) {
      return (_inhaleDur - t * _totalDur).ceil().clamp(1, _inhaleDur.toInt());
    } else if (t <= _holdEnd) {
      return (_holdDur - (t - _inhaleEnd) * _totalDur).ceil().clamp(1, _holdDur.toInt());
    } else {
      return (_exhaleDur - (t - _holdEnd) * _totalDur).ceil().clamp(1, _exhaleDur.toInt());
    }
  }

  Color _bgColor(double t) {
    if (t <= _inhaleEnd) {
      return Color.lerp(_exhaleColor, _inhaleColor, t / _inhaleEnd)!;
    } else if (t <= _holdEnd) {
      final p = (t - _inhaleEnd) / (_holdEnd - _inhaleEnd);
      return Color.lerp(_inhaleColor, _holdColor, p)!;
    } else {
      final p = (t - _holdEnd) / (1 - _holdEnd);
      return Color.lerp(_holdColor, _exhaleColor, p)!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_breathCtrl, _particleCtrl]),
        builder: (context, _) {
          final t = _breathCtrl.value;
          final bg = _running ? _bgColor(t) : _inhaleColor;
          final scale = _running ? _circleScale(t) : 0.55;

          return GestureDetector(
            onTap: _toggle,
            behavior: HitTestBehavior.opaque,
            child: SizedBox.expand(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                color: bg,
                child: SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    Text(
                      _running ? _phaseLabel(t) : 'Boshlash uchun bosing',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w300,
                        color: Colors.white.withValues(alpha: 0.9),
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Opacity(
                      opacity: _running ? 1.0 : 0.0,
                      child: Text(
                        _running ? '${_phaseSeconds(t)}' : '0',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w200,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 280,
                      height: 280,
                      child: CustomPaint(
                        painter: _BreathPainter(
                          scale: scale,
                          particlePhase: _particleCtrl.value,
                          running: _running,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Opacity(
                      opacity: _running ? 1.0 : 0.0,
                      child: Text(
                        _running ? 'Davr: ${_cycleCount + 1}' : 'Davr: 1',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 36, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        _running ? 'To\'xtatish' : 'Boshlash',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.8),
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
            ),
          );
        },
      ),
    );
  }
}

class _BreathPainter extends CustomPainter {
  final double scale;
  final double particlePhase;
  final bool running;

  _BreathPainter({
    required this.scale,
    required this.particlePhase,
    required this.running,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxR = size.width / 2 - 20;
    final r = maxR * scale;

    // Outer glow rings
    for (var i = 3; i >= 1; i--) {
      final glowR = r + i * 18;
      final alpha = 0.04 * (4 - i) * scale;
      canvas.drawCircle(
        center,
        glowR,
        Paint()
          ..color = _circleMid.withValues(alpha: alpha)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 20.0 + i * 8),
      );
    }

    // Main circle gradient
    final gradient = RadialGradient(
      colors: [
        _circleCore.withValues(alpha: 0.6 * scale),
        _circleMid.withValues(alpha: 0.3 * scale),
        _circleMid.withValues(alpha: 0.05 * scale),
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    canvas.drawCircle(
      center,
      r,
      Paint()
        ..shader = gradient.createShader(
          Rect.fromCircle(center: center, radius: r),
        ),
    );

    // Circle edge
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = _circleCore.withValues(alpha: 0.25 * scale)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Inner pulse ring
    final pulseR = r * (0.4 + 0.1 * sin(particlePhase * 4 * pi));
    canvas.drawCircle(
      center,
      pulseR,
      Paint()
        ..color = _circleCore.withValues(alpha: 0.12 * scale)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Particles
    final particleCount = 16;
    for (var i = 0; i < particleCount; i++) {
      final baseAngle = (2 * pi / particleCount) * i;
      final speedMul = 0.7 + (i % 3) * 0.3;
      final angle = baseAngle + particlePhase * 2 * pi * speedMul;

      final orbitR = r + 10 + sin(particlePhase * 2 * pi + i * 0.8) * 14;
      final px = center.dx + cos(angle) * orbitR;
      final py = center.dy + sin(angle) * orbitR;
      final pSize = 2.0 + (i % 4) * 0.8;

      final dist = (orbitR - r).abs() / 24;
      final alpha = (0.7 - dist * 0.3).clamp(0.15, 0.7) * scale;

      canvas.drawCircle(
        Offset(px, py),
        pSize,
        Paint()..color = _particleColor.withValues(alpha: alpha),
      );
    }

    // Secondary orbit — smaller, faster particles
    final innerCount = 10;
    for (var i = 0; i < innerCount; i++) {
      final baseAngle = (2 * pi / innerCount) * i;
      final angle = baseAngle - particlePhase * 2 * pi * 1.4;

      final orbitR = r * 0.7 + cos(particlePhase * 3 * pi + i) * 8;
      final px = center.dx + cos(angle) * orbitR;
      final py = center.dy + sin(angle) * orbitR;

      canvas.drawCircle(
        Offset(px, py),
        1.5,
        Paint()
          ..color = _circleCore.withValues(alpha: 0.3 * scale),
      );
    }
  }

  @override
  bool shouldRepaint(_BreathPainter old) => true;
}
