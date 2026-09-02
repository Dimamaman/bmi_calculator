import 'dart:ui';

import 'package:flutter/material.dart';

class BottomNavAnimationPage extends StatefulWidget {
  const BottomNavAnimationPage({super.key});

  @override
  State<BottomNavAnimationPage> createState() => _BottomNavAnimationPageState();
}

class _BottomNavAnimationPageState extends State<BottomNavAnimationPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  late Animation<double> _rise;
  late Animation<double> _expand;
  late Animation<double> _iconsFade;

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

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _replay() {
    _ctrl.reset();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FC),
      body: GestureDetector(
        onTap: _replay,
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: _ctrl,
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

    const circle = 56.0;
    const barH = 68.0;
    const fullW = 280.0;

    final w = circle + (fullW - circle) * expV;
    final bottom = lerpDouble(-barH - 20, 36.0, riseV)!;

    final homeLeft = lerpDouble((w - circle) / 2, 6, expV)!;

    return Positioned(
      left: 0,
      right: 0,
      bottom: bottom,
      child: Center(
        child: Container(
          width: w,
          height: barH,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(barH / 2),
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
                left: homeLeft,
                top: (barH - circle) / 2,
                child: Container(
                  width: circle,
                  height: circle,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFE0B0FF), Color(0xFFA78BFA)],
                    ),
                  ),
                  child: const Icon(
                    Icons.home_rounded,
                    color: Color(0xFF1A1A2E),
                    size: 28,
                  ),
                ),
              ),
              if (expV > 0.05)
                Positioned(
                  left: circle + 20,
                  right: 12,
                  top: 0,
                  bottom: 0,
                  child: Opacity(
                    opacity: icV,
                    child: Transform.translate(
                      offset: Offset(20 * (1 - icV), 0),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(
                            Icons.bar_chart_rounded,
                            size: 26,
                            color: Color(0xFF3A3A4A),
                          ),
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 26,
                            color: Color(0xFF3A3A4A),
                          ),
                          Icon(
                            Icons.question_answer_outlined,
                            size: 26,
                            color: Color(0xFF3A3A4A),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
