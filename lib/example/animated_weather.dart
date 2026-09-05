import 'dart:math';

import 'package:flutter/material.dart';

const _sunny = Color(0xFFFFF3E0);
const _rainy = Color(0xFF546E7A);
const _snowy = Color(0xFFCFD8DC);
const _sunColor = Color(0xFFFF9800);
const _sunRay = Color(0xFFFFC107);
const _rainDrop = Color(0xFF42A5F5);
const _cloudColor = Color(0xFFECEFF1);
const _snowFlake = Color(0xFFFFFFFF);

enum _Weather { sunny, rainy, snowy }

class AnimatedWeatherPage extends StatefulWidget {
  const AnimatedWeatherPage({super.key});

  @override
  State<AnimatedWeatherPage> createState() => _AnimatedWeatherPageState();
}

class _AnimatedWeatherPageState extends State<AnimatedWeatherPage>
    with TickerProviderStateMixin {
  late AnimationController _transCtrl;
  late AnimationController _loopCtrl;

  late Animation<double> _transition;

  _Weather _current = _Weather.sunny;
  _Weather _previous = _Weather.sunny;
  bool _animating = false;

  @override
  void initState() {
    super.initState();

    _transCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _transition = CurvedAnimation(
      parent: _transCtrl,
      curve: Curves.easeInOutCubic,
    );

    _loopCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
  }

  @override
  void dispose() {
    _transCtrl.dispose();
    _loopCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_animating) return;
    _animating = true;
    _previous = _current;

    switch (_current) {
      case _Weather.sunny:
        _current = _Weather.rainy;
      case _Weather.rainy:
        _current = _Weather.snowy;
      case _Weather.snowy:
        _current = _Weather.sunny;
    }

    _transCtrl.forward(from: 0).then((_) {
      _animating = false;
    });
  }

  Color _bgFor(_Weather w) {
    switch (w) {
      case _Weather.sunny:
        return _sunny;
      case _Weather.rainy:
        return _rainy;
      case _Weather.snowy:
        return _snowy;
    }
  }

  String _labelFor(_Weather w) {
    switch (w) {
      case _Weather.sunny:
        return 'Sunny';
      case _Weather.rainy:
        return 'Rainy';
      case _Weather.snowy:
        return 'Snowy';
    }
  }

  String _tempFor(_Weather w) {
    switch (w) {
      case _Weather.sunny:
        return '28°';
      case _Weather.rainy:
        return '16°';
      case _Weather.snowy:
        return '-3°';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _next,
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: Listenable.merge([_transCtrl, _loopCtrl]),
          builder: (context, _) {
            final t = _transition.value;
            final bg = Color.lerp(_bgFor(_previous), _bgFor(_current), t)!;
            final textBright = _current == _Weather.rainy && t > 0.5 ||
                _previous == _Weather.rainy && t <= 0.5;

            return Container(
              color: bg,
              child: SafeArea(
                child: Stack(
                  children: [
                    CustomPaint(
                      size: Size.infinite,
                      painter: _WeatherPainter(
                        weather: t > 0.5 ? _current : _previous,
                        loopValue: _loopCtrl.value,
                        fadeIn: t > 0.5 ? (t - 0.5) * 2 : 1 - t * 2,
                      ),
                    ),
                    Positioned(
                      left: 32,
                      bottom: 120,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _tempFor(t > 0.5 ? _current : _previous),
                            style: TextStyle(
                              fontSize: 72,
                              fontWeight: FontWeight.w200,
                              color: textBright
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                          Text(
                            _labelFor(t > 0.5 ? _current : _previous),
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w500,
                              color: textBright
                                  ? Colors.white70
                                  : Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Tap to change',
                            style: TextStyle(
                              fontSize: 14,
                              color: textBright
                                  ? Colors.white38
                                  : Colors.black26,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _WeatherPainter extends CustomPainter {
  final _Weather weather;
  final double loopValue;
  final double fadeIn;

  _WeatherPainter({
    required this.weather,
    required this.loopValue,
    required this.fadeIn,
  });

  final _rng = Random(42);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final opacity = fadeIn.clamp(0.0, 1.0);

    switch (weather) {
      case _Weather.sunny:
        _drawSun(canvas, w, h, opacity);
      case _Weather.rainy:
        _drawRain(canvas, w, h, opacity);
      case _Weather.snowy:
        _drawSnow(canvas, w, h, opacity);
    }
  }

  void _drawSun(Canvas canvas, double w, double h, double opacity) {
    final cx = w * 0.65;
    final cy = h * 0.25;
    final sunR = 50.0;

    canvas.drawCircle(
      Offset(cx, cy),
      sunR,
      Paint()..color = _sunColor.withValues(alpha: opacity),
    );

    canvas.drawCircle(
      Offset(cx, cy),
      sunR + 15,
      Paint()
        ..color = _sunColor.withValues(alpha: 0.15 * opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );

    final rayCount = 12;
    for (var i = 0; i < rayCount; i++) {
      final angle = (2 * pi / rayCount) * i + loopValue * 2 * pi;
      final inner = sunR + 20;
      final outer = sunR + 35 + 10 * sin(loopValue * 4 * pi + i);

      canvas.drawLine(
        Offset(cx + cos(angle) * inner, cy + sin(angle) * inner),
        Offset(cx + cos(angle) * outer, cy + sin(angle) * outer),
        Paint()
          ..color = _sunRay.withValues(alpha: 0.6 * opacity)
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawRain(Canvas canvas, double w, double h, double opacity) {
    _drawCloud(canvas, w * 0.5, h * 0.18, 80, opacity);
    _drawCloud(canvas, w * 0.2, h * 0.22, 55, opacity * 0.7);
    _drawCloud(canvas, w * 0.78, h * 0.24, 60, opacity * 0.8);

    final rng = Random(42);
    for (var i = 0; i < 30; i++) {
      final x = rng.nextDouble() * w;
      final speed = 0.5 + rng.nextDouble() * 0.5;
      final startY = h * 0.15 + rng.nextDouble() * h * 0.1;
      final rawY = startY + (loopValue * speed * h * 1.5 + i * 37) % (h * 0.8);
      final y = rawY > h ? rawY - h * 0.8 : rawY;
      final len = 15.0 + rng.nextDouble() * 10;

      canvas.drawLine(
        Offset(x, y),
        Offset(x - 3, y + len),
        Paint()
          ..color = _rainDrop.withValues(alpha: 0.5 * opacity)
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawCloud(
      Canvas canvas, double cx, double cy, double r, double opacity) {
    final paint = Paint()..color = _cloudColor.withValues(alpha: 0.9 * opacity);
    canvas.drawCircle(Offset(cx, cy), r * 0.5, paint);
    canvas.drawCircle(Offset(cx - r * 0.35, cy + r * 0.1), r * 0.38, paint);
    canvas.drawCircle(Offset(cx + r * 0.4, cy + r * 0.08), r * 0.42, paint);
    canvas.drawCircle(Offset(cx - r * 0.15, cy - r * 0.2), r * 0.35, paint);
    canvas.drawCircle(Offset(cx + r * 0.15, cy - r * 0.15), r * 0.3, paint);
  }

  void _drawSnow(Canvas canvas, double w, double h, double opacity) {
    _drawCloud(canvas, w * 0.45, h * 0.18, 75, opacity * 0.5);
    _drawCloud(canvas, w * 0.75, h * 0.22, 55, opacity * 0.4);

    final rng = Random(42);
    for (var i = 0; i < 40; i++) {
      final x0 = rng.nextDouble() * w;
      final speed = 0.2 + rng.nextDouble() * 0.3;
      final drift = sin(loopValue * 2 * pi + i) * 20;
      final startY = h * 0.1 + rng.nextDouble() * h * 0.1;
      final rawY =
          startY + (loopValue * speed * h * 1.2 + i * 29) % (h * 0.85);
      final y = rawY > h ? rawY - h * 0.85 : rawY;
      final x = x0 + drift;
      final r = 2.0 + rng.nextDouble() * 3;

      canvas.drawCircle(
        Offset(x, y),
        r,
        Paint()..color = _snowFlake.withValues(alpha: 0.7 * opacity),
      );
    }
  }

  @override
  bool shouldRepaint(_WeatherPainter old) => true;
}
