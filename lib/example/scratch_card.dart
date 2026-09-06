import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

const _bg = Color(0xFFF5F5F5);
const _scratchColor = Color(0xFFBDBDBD);
const _goldGrad1 = Color(0xFFFFD54F);
const _goldGrad2 = Color(0xFFFFA000);
const _prizeColor = Color(0xFF2E7D32);

class ScratchCardPage extends StatefulWidget {
  const ScratchCardPage({super.key});

  @override
  State<ScratchCardPage> createState() => _ScratchCardPageState();
}

class _ScratchCardPageState extends State<ScratchCardPage>
    with SingleTickerProviderStateMixin {
  final List<Offset> _scratchPoints = [];
  late AnimationController _revealCtrl;
  late Animation<double> _revealAnim;
  bool _revealed = false;
  bool _autoRevealing = false;

  static const _cardW = 300.0;
  static const _cardH = 200.0;
  static const _scratchRadius = 28.0;

  @override
  void initState() {
    super.initState();
    _revealCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _revealAnim = CurvedAnimation(
      parent: _revealCtrl,
      curve: Curves.easeInOut,
    );
    _revealCtrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        setState(() => _revealed = true);
      }
    });
  }

  @override
  void dispose() {
    _revealCtrl.dispose();
    super.dispose();
  }

  double _calcScratchPercent() {
    const gridSize = 8;
    final cellW = _cardW / gridSize;
    final cellH = _cardH / gridSize;
    final scratched = List.generate(
      gridSize * gridSize,
      (_) => false,
    );

    for (final pt in _scratchPoints) {
      for (var gy = 0; gy < gridSize; gy++) {
        for (var gx = 0; gx < gridSize; gx++) {
          if (scratched[gy * gridSize + gx]) continue;
          final cx = gx * cellW + cellW / 2;
          final cy = gy * cellH + cellH / 2;
          if ((pt - Offset(cx, cy)).distance < _scratchRadius + cellW / 2) {
            scratched[gy * gridSize + gx] = true;
          }
        }
      }
    }

    return scratched.where((s) => s).length / scratched.length;
  }

  void _onPan(Offset localPos) {
    if (_autoRevealing || _revealed) return;

    final cardLeft = (_cardW); // will be adjusted in paint coords
    setState(() {
      _scratchPoints.add(localPos);
    });

    if (_calcScratchPercent() > 0.40) {
      _autoRevealing = true;
      _revealCtrl.forward();
    }
  }

  void _reset() {
    setState(() {
      _scratchPoints.clear();
      _revealed = false;
      _autoRevealing = false;
      _revealCtrl.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: AnimatedBuilder(
        animation: _revealCtrl,
        builder: (context, _) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Scratch to reveal!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onPanUpdate: (d) => _onPan(d.localPosition),
                  onPanStart: (d) => _onPan(d.localPosition),
                  child: SizedBox(
                    width: _cardW,
                    height: _cardH,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CustomPaint(
                        painter: _ScratchPainter(
                          scratchPoints: _scratchPoints,
                          revealProgress: _revealAnim.value,
                          revealed: _revealed,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (_revealed)
                  TextButton(
                    onPressed: _reset,
                    child: Text(
                      'Try Again',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ScratchPainter extends CustomPainter {
  final List<Offset> scratchPoints;
  final double revealProgress;
  final bool revealed;

  _ScratchPainter({
    required this.scratchPoints,
    required this.revealProgress,
    required this.revealed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Prize background
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [_goldGrad1, _goldGrad2],
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(16)),
      Paint()..shader = gradient.createShader(rect),
    );

    // Stars decoration
    final rng = Random(77);
    for (var i = 0; i < 12; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      _drawStar(canvas, x, y, 8 + rng.nextDouble() * 6,
          Colors.white.withValues(alpha: 0.3));
    }

    // Prize text
    final prizeStyle = TextStyle(
      fontSize: 48,
      fontWeight: FontWeight.w900,
      color: _prizeColor,
      shadows: [
        Shadow(
          color: Colors.black.withValues(alpha: 0.15),
          offset: const Offset(2, 2),
          blurRadius: 4,
        ),
      ],
    );
    final prizeTp = TextPainter(
      text: TextSpan(text: '\$50', style: prizeStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    prizeTp.paint(
      canvas,
      Offset(
        (size.width - prizeTp.width) / 2,
        (size.height - prizeTp.height) / 2 - 10,
      ),
    );

    final labelTp = TextPainter(
      text: TextSpan(
        text: 'YOU WON!',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: _prizeColor.withValues(alpha: 0.7),
          letterSpacing: 4,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    labelTp.paint(
      canvas,
      Offset(
        (size.width - labelTp.width) / 2,
        (size.height - labelTp.height) / 2 + 32,
      ),
    );

    // Scratch overlay
    if (!revealed) {
      canvas.saveLayer(rect, Paint());

      // Gray scratch layer
      final overlayOpacity = 1.0 - revealProgress;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(16)),
        Paint()..color = _scratchColor.withValues(alpha: overlayOpacity),
      );

      // Scratch pattern
      if (overlayOpacity > 0.8) {
        final patternPaint = Paint()
          ..color = Colors.grey.shade400.withValues(alpha: 0.5)
          ..strokeWidth = 0.5
          ..style = PaintingStyle.stroke;
        for (var x = 0.0; x < size.width; x += 12) {
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), patternPaint);
        }
        for (var y = 0.0; y < size.height; y += 12) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), patternPaint);
        }
      }

      // "SCRATCH HERE" text
      if (scratchPoints.isEmpty && revealProgress == 0) {
        final hintTp = TextPainter(
          text: TextSpan(
            text: 'SCRATCH HERE',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade600,
              letterSpacing: 3,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        hintTp.paint(
          canvas,
          Offset(
            (size.width - hintTp.width) / 2,
            (size.height - hintTp.height) / 2,
          ),
        );
      }

      // Clear scratched areas
      final clearPaint = Paint()..blendMode = BlendMode.clear;
      for (final pt in scratchPoints) {
        canvas.drawCircle(
          pt,
          _ScratchCardPageState._scratchRadius,
          clearPaint,
        );
      }

      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, double cx, double cy, double r, Color color) {
    final path = Path();
    for (var i = 0; i < 5; i++) {
      final outerAngle = -pi / 2 + i * 2 * pi / 5;
      final innerAngle = outerAngle + pi / 5;
      final ox = cx + cos(outerAngle) * r;
      final oy = cy + sin(outerAngle) * r;
      final ix = cx + cos(innerAngle) * r * 0.4;
      final iy = cy + sin(innerAngle) * r * 0.4;

      if (i == 0) {
        path.moveTo(ox, oy);
      } else {
        path.lineTo(ox, oy);
      }
      path.lineTo(ix, iy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_ScratchPainter old) => true;
}
