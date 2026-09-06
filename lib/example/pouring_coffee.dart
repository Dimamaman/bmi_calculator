import 'dart:math';

import 'package:flutter/material.dart';

const _bg = Color(0xFFFDF6EC);
const _cup = Color(0xFFE8E0D4);
const _cupDark = Color(0xFFD4C9B8);
const _coffee = Color(0xFF5D3A1A);
const _coffeLight = Color(0xFF7B4F2A);
const _steam = Color(0xFFD4C9B8);

class PouringCoffeePage extends StatefulWidget {
  const PouringCoffeePage({super.key});

  @override
  State<PouringCoffeePage> createState() => _PouringCoffeePageState();
}

class _PouringCoffeePageState extends State<PouringCoffeePage>
    with TickerProviderStateMixin {
  late AnimationController _pourCtrl;
  late AnimationController _steamCtrl;
  late AnimationController _readyCtrl;

  late Animation<double> _pourAnim;
  late Animation<double> _readyAnim;

  bool _pouring = false;
  bool _full = false;

  @override
  void initState() {
    super.initState();

    _pourCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _pourAnim = CurvedAnimation(parent: _pourCtrl, curve: Curves.easeInOutSine);

    _steamCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _readyCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _readyAnim = CurvedAnimation(parent: _readyCtrl, curve: Curves.elasticOut);

    _pourCtrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        setState(() => _full = true);
        _steamCtrl.repeat();
        _readyCtrl.forward();
      }
    });
  }

  @override
  void dispose() {
    _pourCtrl.dispose();
    _steamCtrl.dispose();
    _readyCtrl.dispose();
    super.dispose();
  }

  void _onTap() {
    print("JJJJJJ $_pouring");
    // if (_pouring) return;
    if (_full) {
      _full = false;
      _pouring = false;
      _pourCtrl.reset();
      _steamCtrl.stop();
      _steamCtrl.reset();
      _readyCtrl.reset();
      setState(() {});
      return;
    }
    _pouring = true;
    _pourCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: GestureDetector(
        onTap: _onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: Listenable.merge([_pourCtrl, _steamCtrl, _readyCtrl]),
          builder: (context, _) {
            return Stack(
              children: [
                Center(
                  child: SizedBox(
                    width: 300,
                    height: 400,
                    child: CustomPaint(
                      painter: _CoffeePainter(
                        fillLevel: _pourAnim.value,
                        steamPhase: _steamCtrl.value,
                        showSteam: _full,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SafeArea(
                    child: Column(
                      children: [
                        if (_full)
                          Transform.scale(
                            scale: _readyAnim.value.clamp(0.0, 1.0),
                            child: const Text(
                              'Ready!',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: _coffee,
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        Text(
                          _full ? 'Tap to reset' : 'Tap to pour',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.brown.withValues(alpha: 0.4),
                          ),
                        ),
                        const SizedBox(height: 24),
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
}

class _CoffeePainter extends CustomPainter {
  final double fillLevel;
  final double steamPhase;
  final bool showSteam;

  _CoffeePainter({
    required this.fillLevel,
    required this.steamPhase,
    required this.showSteam,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cupW = 160.0;
    final cupH = 180.0;
    final cupTop = size.height * 0.35;
    final cupLeft = cx - cupW / 2;
    final cupRight = cx + cupW / 2;
    final cupBottom = cupTop + cupH;
    final saucerY = cupBottom + 8;

    // Saucer
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, saucerY),
        width: cupW + 60,
        height: 30,
      ),
      Paint()..color = _cupDark,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, saucerY - 4),
        width: cupW + 60,
        height: 26,
      ),
      Paint()..color = _cup,
    );

    // Cup body
    final cupPath = Path()
      ..moveTo(cupLeft, cupTop)
      ..lineTo(cupLeft + 12, cupBottom)
      ..lineTo(cupRight - 12, cupBottom)
      ..lineTo(cupRight, cupTop)
      ..close();
    canvas.drawPath(cupPath, Paint()..color = _cup);

    // Cup rim
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cupTop), width: cupW, height: 24),
      Paint()..color = _cupDark,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cupTop + 2),
        width: cupW - 8,
        height: 18,
      ),
      Paint()..color = _bg,
    );

    // Handle
    final handlePath = Path()
      ..moveTo(cupRight - 4, cupTop + 30)
      ..cubicTo(
        cupRight + 40,
        cupTop + 30,
        cupRight + 40,
        cupTop + 110,
        cupRight - 4,
        cupTop + 100,
      );
    canvas.drawPath(
      handlePath,
      Paint()
        ..color = _cupDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round,
    );

    // Coffee fill
    if (fillLevel > 0) {
      final maxFill = cupH - 24;
      final fillH = maxFill * fillLevel;
      final fillTop = cupBottom - fillH;

      final taperTop = 12.0 * (1 - fillH / cupH);
      final leftAtFill = cupLeft + 12 - taperTop;
      final rightAtFill = cupRight - 12 + taperTop;

      final coffeePath = Path();
      coffeePath.moveTo(leftAtFill, fillTop);

      // Wave surface
      final waveAmp = 4.0 + fillLevel * 2;
      for (var x = leftAtFill; x <= rightAtFill; x += 1) {
        final norm = (x - leftAtFill) / (rightAtFill - leftAtFill);
        final y =
            fillTop +
            sin(norm * 3 * pi + fillLevel * 8) * waveAmp * (1 - fillLevel);
        coffeePath.lineTo(x, y);
      }

      coffeePath.lineTo(cupRight - 12, cupBottom);
      coffeePath.lineTo(cupLeft + 12, cupBottom);
      coffeePath.close();

      canvas.save();
      canvas.clipPath(cupPath);
      canvas.drawPath(coffeePath, Paint()..color = _coffee);

      // Surface highlight
      if (fillLevel > 0.3) {
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(cx - 10, fillTop + 6),
            width: 40,
            height: 8,
          ),
          Paint()..color = _coffeLight.withValues(alpha: 0.5),
        );
      }
      canvas.restore();
    }

    // Pour stream
    if (fillLevel > 0 && fillLevel < 0.95) {
      final streamX = cx - 5;
      final streamTop = cupTop - 80;
      final streamBottom = cupTop + 10;
      final streamW = 6.0 - fillLevel * 3;

      canvas.drawLine(
        Offset(streamX, streamTop),
        Offset(streamX, streamBottom),
        Paint()
          ..color = _coffee.withValues(alpha: 0.8)
          ..strokeWidth = streamW
          ..strokeCap = StrokeCap.round,
      );
    }

    // Steam
    if (showSteam) {
      final rng = Random(42);
      for (var i = 0; i < 8; i++) {
        final baseX = cx - 30 + rng.nextDouble() * 60;
        final drift = sin(steamPhase * 2 * pi + i * 1.3) * 12;
        final rise = (steamPhase + i * 0.12) % 1.0;
        final x = baseX + drift;
        final y = cupTop - 20 - rise * 80;
        final alpha = (1 - rise) * 0.4;
        final r = 4.0 + rise * 6;

        canvas.drawCircle(
          Offset(x, y),
          r,
          Paint()
            ..color = _steam.withValues(alpha: alpha)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_CoffeePainter old) => true;
}
