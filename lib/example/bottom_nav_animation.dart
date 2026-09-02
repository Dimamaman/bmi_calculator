import 'dart:ui';

import 'package:flutter/material.dart';

class BottomNavAnimationPage extends StatefulWidget {
  const BottomNavAnimationPage({super.key});

  @override
  State<BottomNavAnimationPage> createState() => _BottomNavAnimationPageState();
}

class _BottomNavAnimationPageState extends State<BottomNavAnimationPage>
    with TickerProviderStateMixin {
  late AnimationController _ctrl;
  late AnimationController _selectCtrl;

  late Animation<double> _rise;
  late Animation<double> _expand;
  late Animation<double> _iconsFade;

  int _selected = 0;
  int _prevSelected = 0;

  static const _circle = 56.0;
  static const _barH = 68.0;
  static const _fullW = 280.0;

  static const _circlePositions = [6.0, 85.0, 144.0, 203.0];

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _rise = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOutCubic),
    );
    _expand = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.25, 0.65, curve: Curves.easeOutCubic),
    );
    _iconsFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.5, 0.85, curve: Curves.easeOut),
    );

    _selectCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _selectCtrl.dispose();
    super.dispose();
  }

  void _replay() {
    _selected = 0;
    _prevSelected = 0;
    _selectCtrl.reset();
    _ctrl.reset();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _ctrl.forward();
    });
  }

  void _selectItem(int index) {
    if (index == _selected || !_ctrl.isCompleted) return;
    setState(() {
      _prevSelected = _selected;
      _selected = index;
    });
    _selectCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FC),
      body: GestureDetector(
        onTap: _replay,
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: Listenable.merge([_ctrl, _selectCtrl]),
          builder: (context, _) => Stack(
            children: [
              const SafeArea(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.touch_app_outlined,
                        size: 48,
                        color: Color(0xFFCCCCDD),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Tap to replay',
                        style: TextStyle(
                          color: Color(0xFFAAAAAA),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildNavBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavBar() {
    final riseV = _rise.value;
    final expV = _expand.value;
    final icV = _iconsFade.value;

    final w = _circle + (_fullW - _circle) * expV;
    final bottom = lerpDouble(-_barH - 20, 36.0, riseV)!;

    final entranceHomeLeft = lerpDouble((w - _circle) / 2, 6, expV)!;

    double circleLeft;
    if (_ctrl.isCompleted) {
      final t = Curves.easeInOutCubic.transform(_selectCtrl.value);
      circleLeft = lerpDouble(
        _circlePositions[_prevSelected],
        _circlePositions[_selected],
        t,
      )!;
    } else {
      circleLeft = entranceHomeLeft;
    }

    return Positioned(
      left: 0,
      right: 0,
      bottom: bottom,
      child: Center(
        child: GestureDetector(
          onTap: () {},
          child: Container(
            width: w,
            height: _barH,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(_barH / 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.07),
                  blurRadius: 28,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  left: circleLeft,
                  top: (_barH - _circle) / 2,
                  child: Container(
                    width: _circle,
                    height: _circle,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFE0B0FF), Color(0xFFA78BFA)],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: _ctrl.isCompleted ? _circlePositions[0] : entranceHomeLeft,
                  top: (_barH - _circle) / 2,
                  child: _navTap(
                    index: 0,
                    child: SizedBox(
                      width: _circle,
                      height: _circle,
                      child: Icon(
                        Icons.home_rounded,
                        color: _iconColor(0),
                        size: 28,
                      ),
                    ),
                  ),
                ),
                if (expV > 0.9)
                  Positioned(
                    left: _circle + 20,
                    right: 12,
                    top: 0,
                    bottom: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _animatedNavItem(
                          Icons.bar_chart_rounded,
                          1,
                          icV,
                          Offset(30 * (1 - icV), 0),
                        ),
                        _animatedNavItem(
                          Icons.account_balance_wallet_outlined,
                          2,
                          icV,
                          Offset.zero,
                        ),
                        _animatedNavItem(
                          Icons.question_answer_outlined,
                          3,
                          icV,
                          Offset(-30 * (1 - icV), 0),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _animatedNavItem(
    IconData icon,
    int index,
    double fadeV,
    Offset offset,
  ) {
    return Opacity(
      opacity: fadeV,
      child: Transform.translate(
        offset: offset,
        child: _navTap(
          index: index,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(icon, size: 26, color: _iconColor(index)),
          ),
        ),
      ),
    );
  }

  Widget _navTap({required int index, required Widget child}) {
    return GestureDetector(
      onTap: () => _selectItem(index),
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }

  Color _iconColor(int index) {
    return _selected == index
        ? const Color(0xFF1A1A2E)
        : const Color(0xFF9CA3AF);
  }
}
