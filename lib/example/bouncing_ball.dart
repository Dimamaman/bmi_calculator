import 'dart:math';

import 'package:flutter/material.dart';

const _bg = Color(0xFFF0F4F8);
const _ballColor = Color(0xFFE53935);
const _ballHighlight = Color(0xFFEF9A9A);
const _shadow = Color(0x33000000);
const _ground = Color(0xFFBDBDBD);

class BouncingBallPage extends StatefulWidget {
  const BouncingBallPage({super.key});

  @override
  State<BouncingBallPage> createState() => _BouncingBallPageState();
}

class _BouncingBallPageState extends State<BouncingBallPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  static const _gravity = 2200.0;
  static const _bounceFactor = 0.65;
  static const _ballR = 28.0;
  static const _totalBounces = 7;

  final List<_Bounce> _bounces = [];
  double _totalDuration = 0;

  @override
  void initState() {
    super.initState();
    _buildBounces(500);
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (_totalDuration * 1000).toInt()),
    );
  }

  void _buildBounces(double dropH) {
    _bounces.clear();
    _totalDuration = 0;

    var h = dropH;
    for (var i = 0; i <= _totalBounces; i++) {
      final dur = sqrt(2 * h / _gravity) * (i == 0 ? 1 : 2);
      _bounces.add(_Bounce(height: h, duration: dur, startTime: _totalDuration));
      _totalDuration += dur;
      h *= _bounceFactor * _bounceFactor;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTap() {
    _ctrl.forward(from: 0);
  }

  double _getY(double t) {
    final elapsed = t * _totalDuration;

    for (var i = 0; i < _bounces.length; i++) {
      final b = _bounces[i];
      final localT = elapsed - b.startTime;
      if (localT < 0) continue;
      if (localT > b.duration && i < _bounces.length - 1) continue;

      if (i == 0) {
        final frac = (localT / b.duration).clamp(0.0, 1.0);
        return b.height * frac * frac;
      } else {
        final halfDur = b.duration / 2;
        if (localT <= halfDur) {
          final frac = localT / halfDur;
          return b.height * (1 - frac) * (1 - frac);
        } else {
          final frac = ((localT - halfDur) / halfDur).clamp(0.0, 1.0);
          return b.height * frac * frac;
        }
      }
    }
    return 0;
  }

  double _getVelocity(double t) {
    const dt = 0.002;
    final y1 = _getY((t - dt).clamp(0, 1));
    final y2 = _getY((t + dt).clamp(0, 1));
    return (y2 - y1) / (dt * 2 * _totalDuration);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: GestureDetector(
        onTap: _onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final groundY = constraints.maxHeight * 0.78;
                final maxDrop = groundY - 140 - _ballR;
                final normalizedY = _getY(_ctrl.value);
                final ballBottom =
                    groundY - _ballR - (1 - normalizedY / 500) * maxDrop;
                final ballY = 140 + (normalizedY / 500) * maxDrop;
                final clampedBallY = ballY.clamp(140.0, groundY - _ballR);

                final vel = _getVelocity(_ctrl.value);
                final speed = vel.abs();
                final squashAmt = (speed / 800).clamp(0.0, 0.35);

                final nearGround =
                    (groundY - _ballR - clampedBallY).abs() < 6;
                final scaleX =
                    nearGround ? 1.0 + squashAmt : 1.0 - squashAmt * 0.3;
                final scaleY =
                    nearGround ? 1.0 - squashAmt : 1.0 + squashAmt * 0.3;

                final shadowScale =
                    1.0 - ((groundY - _ballR - clampedBallY) / maxDrop).clamp(0.0, 0.7);

                return CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: _BallPainter(
                    ballY: clampedBallY,
                    groundY: groundY,
                    scaleX: scaleX,
                    scaleY: scaleY,
                    shadowScale: shadowScale,
                    progress: _ctrl.value,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _Bounce {
  final double height;
  final double duration;
  final double startTime;

  _Bounce({
    required this.height,
    required this.duration,
    required this.startTime,
  });
}

class _BallPainter extends CustomPainter {
  final double ballY;
  final double groundY;
  final double scaleX;
  final double scaleY;
  final double shadowScale;
  final double progress;

  _BallPainter({
    required this.ballY,
    required this.groundY,
    required this.scaleX,
    required this.scaleY,
    required this.shadowScale,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final ballR = _BouncingBallPageState._ballR;

    // Ground
    canvas.drawLine(
      Offset(40, groundY),
      Offset(size.width - 40, groundY),
      Paint()
        ..color = _ground
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );

    // Shadow
    if (progress > 0) {
      final shadowW = ballR * 1.5 * shadowScale;
      final shadowH = 6.0 * shadowScale;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx, groundY - 1),
          width: shadowW * 2,
          height: shadowH * 2,
        ),
        Paint()
          ..color = _shadow.withValues(alpha: 0.25 * shadowScale)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }

    // Ball
    canvas.save();
    canvas.translate(cx, ballY);
    canvas.scale(scaleX, scaleY);

    canvas.drawCircle(
      Offset.zero,
      ballR,
      Paint()..color = _ballColor,
    );

    canvas.drawCircle(
      Offset(-ballR * 0.25, -ballR * 0.3),
      ballR * 0.35,
      Paint()..color = _ballHighlight.withValues(alpha: 0.5),
    );

    canvas.drawCircle(
      Offset(-ballR * 0.15, -ballR * 0.2),
      ballR * 0.12,
      Paint()..color = Colors.white.withValues(alpha: 0.6),
    );

    canvas.restore();

    // Tap instruction
    if (progress == 0) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'Tap to drop',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(cx - textPainter.width / 2, groundY + 30),
      );
    }
  }

  @override
  bool shouldRepaint(_BallPainter old) => true;
}
