import 'dart:math';

import 'package:flutter/material.dart';

const _bg = Color(0xFF1A1A2E);
const _accent = Color(0xFF6C63FF);
const _fieldBg = Color(0xFF16213E);
const _fieldBorder = Color(0xFF2A2A4A);
const _success = Color(0xFF00C853);

class AnimatedLoginPage extends StatefulWidget {
  const AnimatedLoginPage({super.key});

  @override
  State<AnimatedLoginPage> createState() => _AnimatedLoginPageState();
}

class _AnimatedLoginPageState extends State<AnimatedLoginPage>
    with TickerProviderStateMixin {
  late AnimationController _entranceCtrl;
  late AnimationController _submitCtrl;

  late Animation<double> _logoAnim;
  late Animation<double> _emailAnim;
  late Animation<double> _passAnim;
  late Animation<double> _btnAnim;
  late Animation<double> _forgotAnim;

  late Animation<double> _btnShrink;
  late Animation<double> _spinnerAnim;
  late Animation<double> _checkAnim;

  bool _submitting = false;

  @override
  void initState() {
    super.initState();

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoAnim = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOutCubic),
    );
    _emailAnim = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.15, 0.45, curve: Curves.easeOutCubic),
    );
    _passAnim = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.30, 0.60, curve: Curves.easeOutCubic),
    );
    _btnAnim = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.45, 0.75, curve: Curves.easeOutCubic),
    );
    _forgotAnim = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.55, 0.85, curve: Curves.easeOut),
    );

    _submitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _btnShrink = CurvedAnimation(
      parent: _submitCtrl,
      curve: const Interval(0.0, 0.20, curve: Curves.easeInCubic),
    );
    _spinnerAnim = CurvedAnimation(
      parent: _submitCtrl,
      curve: const Interval(0.20, 0.75, curve: Curves.linear),
    );
    _checkAnim = CurvedAnimation(
      parent: _submitCtrl,
      curve: const Interval(0.75, 1.0, curve: Curves.elasticOut),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _entranceCtrl.forward();
    });
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _submitCtrl.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_submitting) return;
    _submitting = true;
    _submitCtrl.forward().then((_) {
      Future.delayed(const Duration(seconds: 1), _restart);
    });
  }

  void _restart() {
    _submitting = false;
    _submitCtrl.reset();
    _entranceCtrl.reset();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _entranceCtrl.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: AnimatedBuilder(
        animation: Listenable.merge([_entranceCtrl, _submitCtrl]),
        builder: (context, _) {
          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLogo(),
                    const SizedBox(height: 48),
                    _slideIn(_emailAnim, child: _buildField('Email', Icons.email_outlined)),
                    const SizedBox(height: 16),
                    _slideIn(_passAnim, child: _buildField('Password', Icons.lock_outline, obscure: true)),
                    const SizedBox(height: 32),
                    _slideIn(_btnAnim, child: _buildButton()),
                    const SizedBox(height: 20),
                    _slideIn(
                      _forgotAnim,
                      child: Text(
                        'Forgot password?',
                        style: TextStyle(
                          color: _accent.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogo() {
    final v = _logoAnim.value;
    return Opacity(
      opacity: v,
      child: Transform.scale(
        scale: 0.5 + 0.5 * v,
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_open_rounded, color: _accent, size: 36),
            ),
            const SizedBox(height: 16),
            const Text(
              'Welcome Back',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Sign in to continue',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _slideIn(Animation<double> anim, {required Widget child}) {
    final v = anim.value.clamp(0.0, 1.0);
    return Opacity(
      opacity: v,
      child: Transform.translate(
        offset: Offset(0, 30 * (1 - v)),
        child: child,
      ),
    );
  }

  Widget _buildField(String hint, IconData icon, {bool obscure = false}) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: _fieldBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _fieldBorder, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(icon, color: _accent.withValues(alpha: 0.6), size: 22),
          const SizedBox(width: 12),
          Text(
            hint,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton() {
    if (!_submitting) {
      return GestureDetector(
        onTap: _onSubmit,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: _accent,
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: const Text(
            'Login',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    final shrinkV = _btnShrink.value;
    final spinV = _spinnerAnim.value;
    final checkV = _checkAnim.value.clamp(0.0, 1.0);

    final fullWidth = MediaQuery.of(context).size.width - 64;
    final w = fullWidth - (fullWidth - 56) * shrinkV;
    final radius = 14.0 + (28.0 - 14.0) * shrinkV;

    final isSpinning = shrinkV >= 1.0 && checkV == 0.0;
    final showCheck = checkV > 0.0;

    final btnColor = showCheck
        ? Color.lerp(_accent, _success, checkV)!
        : _accent;

    return Center(
      child: Container(
        width: w,
        height: 56,
        decoration: BoxDecoration(
          color: btnColor,
          borderRadius: BorderRadius.circular(radius),
        ),
        alignment: Alignment.center,
        child: _buildButtonContent(isSpinning, showCheck, spinV, checkV),
      ),
    );
  }

  Widget _buildButtonContent(
    bool isSpinning,
    bool showCheck,
    double spinV,
    double checkV,
  ) {
    if (showCheck) {
      return Transform.scale(
        scale: checkV,
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 32),
      );
    }

    if (isSpinning) {
      return SizedBox(
        width: 28,
        height: 28,
        child: CustomPaint(
          painter: _SpinnerPainter(
            progress: spinV,
            color: Colors.white,
          ),
        ),
      );
    }

    final shrinkV = _btnShrink.value;
    return Opacity(
      opacity: (1 - shrinkV * 3).clamp(0.0, 1.0),
      child: const Text(
        'Login',
        style: TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  final double progress;
  final Color color;

  _SpinnerPainter({required this.progress, required this.color});

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

    final sweepAngle = pi * 0.8;
    final startAngle = 2 * pi * progress * 3 - pi / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_SpinnerPainter old) => old.progress != progress;
}
