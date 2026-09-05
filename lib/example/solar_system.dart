import 'dart:math';

import 'package:flutter/material.dart';

const _spaceBg = Color(0xFF0B0E1A);
const _sunColor = Color(0xFFFFB300);
const _sunGlow = Color(0xFFFF8F00);
const _orbitColor = Color(0x22FFFFFF);

class _Planet {
  final String name;
  final double orbitRadius;
  final double size;
  final Color color;
  final double speed;
  final String info;

  const _Planet({
    required this.name,
    required this.orbitRadius,
    required this.size,
    required this.color,
    required this.speed,
    required this.info,
  });
}

const _planets = [
  _Planet(
    name: 'Mercury',
    orbitRadius: 65,
    size: 8,
    color: Color(0xFFB0BEC5),
    speed: 4.2,
    info: '58M km · 88 kun · Eng kichik',
  ),
  _Planet(
    name: 'Venus',
    orbitRadius: 100,
    size: 12,
    color: Color(0xFFFFCC80),
    speed: 3.0,
    info: '108M km · 225 kun · Eng issiq',
  ),
  _Planet(
    name: 'Earth',
    orbitRadius: 140,
    size: 13,
    color: Color(0xFF64B5F6),
    speed: 2.0,
    info: '150M km · 365 kun · Bizning uy',
  ),
  _Planet(
    name: 'Mars',
    orbitRadius: 178,
    size: 10,
    color: Color(0xFFEF5350),
    speed: 1.4,
    info: '228M km · 687 kun · Qizil planeta',
  ),
];

class SolarSystemPage extends StatefulWidget {
  const SolarSystemPage({super.key});

  @override
  State<SolarSystemPage> createState() => _SolarSystemPageState();
}

class _SolarSystemPageState extends State<SolarSystemPage>
    with TickerProviderStateMixin {
  late AnimationController _orbitCtrl;
  late AnimationController _selectCtrl;
  late Animation<double> _selectAnim;

  int? _selectedIndex;
  int? _prevSelected;

  @override
  void initState() {
    super.initState();

    _orbitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 35000),
    )..repeat();

    _selectCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _selectAnim = CurvedAnimation(
      parent: _selectCtrl,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _orbitCtrl.dispose();
    _selectCtrl.dispose();
    super.dispose();
  }

  void _onTapPlanet(int index) {
    if (_selectCtrl.isAnimating) return;

    setState(() {
      if (_selectedIndex == index) {
        _prevSelected = _selectedIndex;
        _selectedIndex = null;
        _selectCtrl.reverse();
      } else {
        _prevSelected = _selectedIndex;
        _selectedIndex = index;
        _selectCtrl.forward(from: 0);
      }
    });
  }

  Offset _planetPosition(int index, double loopValue, Offset center) {
    final p = _planets[index];
    final angle = loopValue * 2 * pi * p.speed;
    return Offset(
      center.dx + cos(angle) * p.orbitRadius,
      center.dy + sin(angle) * p.orbitRadius,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _spaceBg,
      body: AnimatedBuilder(
        animation: Listenable.merge([_orbitCtrl, _selectCtrl]),
        builder: (context, _) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final center = Offset(
                constraints.maxWidth / 2,
                constraints.maxHeight * 0.42,
              );

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (details) {
                  final tap = details.localPosition;
                  for (var i = _planets.length - 1; i >= 0; i--) {
                    final pos = _planetPosition(i, _orbitCtrl.value, center);
                    if ((tap - pos).distance <= _planets[i].size + 16) {
                      _onTapPlanet(i);
                      return;
                    }
                  }
                  if (_selectedIndex != null) {
                    _onTapPlanet(_selectedIndex!);
                  }
                },
                child: Stack(
                  children: [
                    CustomPaint(
                      size: Size(constraints.maxWidth, constraints.maxHeight),
                      painter: _SolarPainter(
                        loopValue: _orbitCtrl.value,
                        center: center,
                        selectedIndex: _selectedIndex,
                        selectProgress: _selectAnim.value,
                      ),
                    ),
                    _buildTitle(),
                    if (_selectedIndex != null || _selectCtrl.isAnimating)
                      _buildInfoCard(center),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTitle() {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Text(
            'Solar System',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w300,
              color: Colors.white.withValues(alpha: 0.7),
              letterSpacing: 3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(Offset center) {
    final idx = _selectedIndex ?? _prevSelected;
    if (idx == null) return const SizedBox.shrink();

    final planet = _planets[idx];
    final v = _selectAnim.value.clamp(0.0, 1.0);

    return Positioned(
      left: 32,
      right: 32,
      bottom: 80,
      child: Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, 30 * (1 - v)),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: planet.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: planet.color.withValues(alpha: 0.3)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: planet.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      planet.name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: planet.color,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  planet.info,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w300,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SolarPainter extends CustomPainter {
  final double loopValue;
  final Offset center;
  final int? selectedIndex;
  final double selectProgress;

  _SolarPainter({
    required this.loopValue,
    required this.center,
    required this.selectedIndex,
    required this.selectProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawStars(canvas, size);
    _drawOrbits(canvas);
    _drawSun(canvas);
    _drawPlanets(canvas);
  }

  void _drawStars(Canvas canvas, Size size) {
    final rng = Random(99);
    for (var i = 0; i < 80; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final r = 0.5 + rng.nextDouble() * 1.2;
      final twinkle =
          0.4 + 0.6 * ((sin(loopValue * 2 * pi * 3 + i * 1.7) + 1) / 2);

      canvas.drawCircle(
        Offset(x, y),
        r,
        Paint()..color = Colors.white.withValues(alpha: twinkle * 0.7),
      );
    }
  }

  void _drawSun(Canvas canvas) {
    for (var i = 3; i >= 1; i--) {
      final glowR = 22.0 + i * 14;
      final pulse = 1 + sin(loopValue * 2 * pi * 2) * 0.08;
      canvas.drawCircle(
        center,
        glowR * pulse,
        Paint()
          ..color = _sunGlow.withValues(alpha: 0.08 * (4 - i))
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 12.0 + i * 6),
      );
    }

    canvas.drawCircle(center, 22, Paint()..color = _sunColor);

    canvas.drawCircle(
      center,
      22,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
  }

  void _drawOrbits(Canvas canvas) {
    final paint = Paint()
      ..color = _orbitColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (final p in _planets) {
      canvas.drawCircle(center, p.orbitRadius, paint);
    }
  }

  void _drawPlanets(Canvas canvas) {
    for (var i = 0; i < _planets.length; i++) {
      final p = _planets[i];
      final angle = loopValue * 2 * pi * p.speed;
      final px = center.dx + cos(angle) * p.orbitRadius;
      final py = center.dy + sin(angle) * p.orbitRadius;

      final isSelected = selectedIndex == i;
      final scaleMul = isSelected ? 1.0 + selectProgress * 0.5 : 1.0;
      final drawR = p.size * scaleMul;

      if (isSelected && selectProgress > 0) {
        canvas.drawCircle(
          Offset(px, py),
          drawR + 8,
          Paint()
            ..color = p.color.withValues(alpha: 0.2 * selectProgress)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
        );
      }

      canvas.drawCircle(Offset(px, py), drawR, Paint()..color = p.color);

      final highlight = Offset(px - drawR * 0.3, py - drawR * 0.3);
      canvas.drawCircle(
        highlight,
        drawR * 0.35,
        Paint()..color = Colors.white.withValues(alpha: 0.25),
      );
    }
  }

  @override
  bool shouldRepaint(_SolarPainter old) => true;
}
