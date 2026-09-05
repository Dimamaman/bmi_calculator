import 'dart:math';

import 'package:flutter/material.dart';

const _bg = Color(0xFFF5F7FA);
const _wave = Color(0xFF6C63FF);
const _waveDark = Color(0xFF524BD0);
const _success = Color(0xFF00C853);

class PullToRefreshPage extends StatefulWidget {
  const PullToRefreshPage({super.key});

  @override
  State<PullToRefreshPage> createState() => _PullToRefreshPageState();
}

class _PullToRefreshPageState extends State<PullToRefreshPage>
    with TickerProviderStateMixin {
  late AnimationController _snapBackCtrl;
  late AnimationController _spinCtrl;
  late AnimationController _doneCtrl;

  late Animation<double> _snapBack;
  late Animation<double> _spinAnim;
  late Animation<double> _checkAnim;

  double _dragOffset = 0;
  bool _refreshing = false;
  bool _done = false;

  static const _threshold = 140.0;
  static const _maxDrag = 200.0;

  @override
  void initState() {
    super.initState();

    _snapBackCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _snapBack = CurvedAnimation(
      parent: _snapBackCtrl,
      curve: Curves.easeOutCubic,
    );

    _spinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _spinAnim = CurvedAnimation(
      parent: _spinCtrl,
      curve: Curves.linear,
    );

    _doneCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _checkAnim = CurvedAnimation(
      parent: _doneCtrl,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _snapBackCtrl.dispose();
    _spinCtrl.dispose();
    _doneCtrl.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails d) {
    if (_refreshing || _done) return;
    setState(() {
      _dragOffset = (_dragOffset + d.delta.dy).clamp(0, _maxDrag);
    });
  }

  void _onDragEnd(DragEndDetails d) {
    if (_refreshing || _done) return;

    if (_dragOffset >= _threshold) {
      _startRefresh();
    } else {
      _animateBack();
    }
  }

  void _animateBack() {
    final startOffset = _dragOffset;
    _snapBackCtrl.forward(from: 0);
    _snapBackCtrl.addListener(() {
      setState(() {
        _dragOffset = startOffset * (1 - _snapBack.value);
      });
    });
  }

  Future<void> _startRefresh() async {
    _refreshing = true;
    final startOffset = _dragOffset;
    final holdOffset = 80.0;

    _snapBackCtrl.reset();
    _snapBackCtrl.forward(from: 0);

    void snapListener() {
      setState(() {
        _dragOffset =
            startOffset - (startOffset - holdOffset) * _snapBack.value;
      });
    }

    _snapBackCtrl.addListener(snapListener);
    await _snapBackCtrl.forward(from: 0);
    _snapBackCtrl.removeListener(snapListener);

    _spinCtrl.repeat();
    await Future.delayed(const Duration(milliseconds: 1800));
    _spinCtrl.stop();

    _done = true;
    await _doneCtrl.forward(from: 0);
    await Future.delayed(const Duration(milliseconds: 600));

    _done = false;
    _refreshing = false;
    _doneCtrl.reset();

    final holdStart = _dragOffset;
    _snapBackCtrl.reset();

    void finalListener() {
      setState(() {
        _dragOffset = holdStart * (1 - _snapBack.value);
      });
    }

    _snapBackCtrl.addListener(finalListener);
    await _snapBackCtrl.forward(from: 0);
    _snapBackCtrl.removeListener(finalListener);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: AnimatedBuilder(
        animation: Listenable.merge([_spinCtrl, _doneCtrl]),
        builder: (context, _) {
          final progress = (_dragOffset / _threshold).clamp(0.0, 1.0);

          return GestureDetector(
            onVerticalDragUpdate: _onDragUpdate,
            onVerticalDragEnd: _onDragEnd,
            behavior: HitTestBehavior.opaque,
            child: Stack(
              children: [
                if (_dragOffset > 0)
                  ClipPath(
                    clipper: _WaveClipper(
                      waveHeight: _dragOffset,
                      phase: _refreshing ? _spinAnim.value : 0,
                    ),
                    child: Container(
                      height: _dragOffset + 50,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [_waveDark, _wave],
                        ),
                      ),
                    ),
                  ),
                if (_dragOffset > 20)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: _dragOffset * 0.5 - 20,
                    child: Center(child: _buildIndicator(progress)),
                  ),
                Transform.translate(
                  offset: Offset(0, _dragOffset),
                  child: _buildContent(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildIndicator(double progress) {
    if (_done) {
      final v = _checkAnim.value.clamp(0.0, 1.0);
      return Transform.scale(
        scale: v,
        child: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: _success,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 24),
        ),
      );
    }

    if (_refreshing) {
      return SizedBox(
        width: 36,
        height: 36,
        child: CustomPaint(
          painter: _SpinPainter(
            progress: _spinAnim.value,
            color: Colors.white,
          ),
        ),
      );
    }

    final rotation = progress * 2 * pi;
    return Transform.rotate(
      angle: rotation,
      child: Icon(
        Icons.arrow_downward_rounded,
        color: Colors.white.withValues(alpha: 0.8),
        size: 28,
      ),
    );
  }

  Widget _buildContent() {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 24),
          const Text(
            'Pull down to refresh',
            style: TextStyle(
              color: Color(0xFF9E9E9E),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 32),
          ...List.generate(6, (i) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
              child: Container(
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: _wave.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _itemIcons[i % _itemIcons.length],
                        color: _wave,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _itemTitles[i % _itemTitles.length],
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Updated just now',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  static const _itemIcons = [
    Icons.notifications_outlined,
    Icons.mail_outlined,
    Icons.calendar_today_rounded,
    Icons.star_outline_rounded,
    Icons.folder_outlined,
    Icons.bookmark_outline_rounded,
  ];

  static const _itemTitles = [
    'Notifications',
    'Messages',
    'Calendar',
    'Favorites',
    'Documents',
    'Bookmarks',
  ];
}

class _WaveClipper extends CustomClipper<Path> {
  final double waveHeight;
  final double phase;

  _WaveClipper({required this.waveHeight, required this.phase});

  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, waveHeight);

    final waveAmplitude = 12.0 + waveHeight * 0.05;
    final waveLength = size.width / 2;

    for (var x = 0.0; x <= size.width; x += 1) {
      final y = waveHeight +
          sin((x / waveLength) * 2 * pi + phase * 2 * pi) * waveAmplitude;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_WaveClipper old) =>
      old.waveHeight != waveHeight || old.phase != phase;
}

class _SpinPainter extends CustomPainter {
  final double progress;
  final Color color;

  _SpinPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.width / 2;

    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = color.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    final startAngle = 2 * pi * progress * 3 - pi / 2;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      startAngle,
      pi * 0.8,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_SpinPainter old) => old.progress != progress;
}
