import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

const _bg = Color(0xFF0B0B1A);
const _purple = Color(0xFFB07FD0);
const _purpleDark = Color(0xFF6B3FA0);
const _gray = Color(0xFF6E6E80);
const _cardBg = Color(0xFF1C1C2E);

class NfcPaymentAnimationPage extends StatefulWidget {
  const NfcPaymentAnimationPage({super.key});

  @override
  State<NfcPaymentAnimationPage> createState() =>
      _NfcPaymentAnimationPageState();
}

class _NfcPaymentAnimationPageState extends State<NfcPaymentAnimationPage>
    with TickerProviderStateMixin {
  late AnimationController _rippleCtrl;
  late AnimationController _transCtrl;
  late AnimationController _successCtrl;

  late Animation<double> _fadeOut;
  late Animation<double> _fadeIn;

  late Animation<double> _checkAnim;
  late Animation<double> _titleAnim;
  late Animation<double> _subAnim;
  late Animation<double> _receiptAnim;
  late Animation<double> _footerAnim;

  int _dots = 1;
  Timer? _dotTimer;
  bool _isProcessing = true;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startProcessing();
  }

  void _initAnimations() {
    _rippleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();

    _transCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeOut = CurvedAnimation(
      parent: _transCtrl,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );
    _fadeIn = CurvedAnimation(
      parent: _transCtrl,
      curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
    );

    _successCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _checkAnim = CurvedAnimation(
      parent: _successCtrl,
      curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
    );
    _titleAnim = CurvedAnimation(
      parent: _successCtrl,
      curve: const Interval(0.15, 0.45, curve: Curves.easeOutCubic),
    );
    _subAnim = CurvedAnimation(
      parent: _successCtrl,
      curve: const Interval(0.25, 0.55, curve: Curves.easeOutCubic),
    );
    _receiptAnim = CurvedAnimation(
      parent: _successCtrl,
      curve: const Interval(0.35, 0.75, curve: Curves.easeOutCubic),
    );
    _footerAnim = CurvedAnimation(
      parent: _successCtrl,
      curve: const Interval(0.6, 0.9, curve: Curves.easeOutCubic),
    );
  }

  void _startProcessing() {
    _dotTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted && _isProcessing) {
        setState(() => _dots = (_dots % 3) + 1);
      }
    });
    Future.delayed(const Duration(seconds: 3), _toSuccess);
  }

  void _toSuccess() {
    if (!mounted) return;
    _isProcessing = false;
    _dotTimer?.cancel();
    _transCtrl.forward().then((_) {
      _rippleCtrl.stop();
      _successCtrl.forward();
    });
  }

  void _restart() {
    _transCtrl.reset();
    _successCtrl.reset();
    _isProcessing = true;
    _dots = 1;
    _rippleCtrl.repeat();
    _startProcessing();
  }

  @override
  void dispose() {
    _rippleCtrl.dispose();
    _transCtrl.dispose();
    _successCtrl.dispose();
    _dotTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: AnimatedBuilder(
        animation: Listenable.merge([_rippleCtrl, _transCtrl, _successCtrl]),
        builder: (context, _) {
          final procOpacity = (1 - _fadeOut.value).clamp(0.0, 1.0);
          final successOpacity = _fadeIn.value.clamp(0.0, 1.0);

          return Stack(
            children: [
              // _buildBgCard(),
              if (procOpacity > 0) ...[
                _buildPurpleGlow(procOpacity),
                Opacity(opacity: procOpacity, child: _buildProcessing()),
              ],
              if (successOpacity > 0)
                Opacity(opacity: successOpacity, child: _buildSuccess()),
            ],
          );
        },
      ),
    );
  }

  // ── Background card (partially visible, lower-left) ──

  Widget _buildBgCard() {
    return Positioned(
      left: -140,
      bottom: 100,
      child: Transform.rotate(
        angle: -0.15,
        child: Container(
          width: 320,
          height: 200,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF161628), Color(0xFF1E1E38)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '•••• •••• •••• 8590',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 16,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'EXPIRY DATE',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 8,
                  letterSpacing: 1,
                ),
              ),
              Text(
                '02/30',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Purple glow behind NFC area ──

  Widget _buildPurpleGlow(double opacity) {
    return Positioned.fill(
      child: Opacity(
        opacity: opacity,
        child: Align(
          alignment: const Alignment(0, -0.1),
          child: Container(
            width: 350,
            height: 350,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _purpleDark.withValues(alpha: 0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Processing screen ──

  Widget _buildProcessing() {
    return SafeArea(
      child: SizedBox.expand(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text('Charge amount', style: TextStyle(color: _gray, fontSize: 16)),
            const SizedBox(height: 8),
            _amount(48),
            const Spacer(),
            _buildNfcRipple(),
            const SizedBox(height: 40),
            Text(
              'Processing${'.' * _dots}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 16,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: _toSuccess,
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _amount(double size, {bool center = true}) {
    return Row(
      mainAxisAlignment: center
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          '\$135',
          style: TextStyle(
            color: _purple,
            fontSize: size,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          '.43',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: size,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ── NFC icon + ripple circles ──

  Widget _buildNfcRipple() {
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(280, 280),
            painter: _RipplePainter(
              progress: _rippleCtrl.value,
              color: _purple,
            ),
          ),
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _purple.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: CustomPaint(
              painter: _NfcIconPainter(color: _purple.withValues(alpha: 0.8)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Success screen ──

  Widget _buildSuccess() {
    return SafeArea(
      child: GestureDetector(
        onTap: _restart,
        behavior: HitTestBehavior.opaque,
        child: SizedBox.expand(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 40),
            child: Column(
              children: [
                const SizedBox(height: 60),
                _buildCheckmark(),
                const SizedBox(height: 24),
                _slide(
                  _titleAnim,
                  child: const Text(
                    'Thank you!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _slide(
                  _subAnim,
                  child: Text(
                    'Your payment was\nsuccesfully paid!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _gray, fontSize: 15),
                  ),
                ),
                const SizedBox(height: 40),
                _slide(_receiptAnim, distance: 80, child: _buildReceipt()),
                const SizedBox(height: 24),
                _slide(
                  _footerAnim,
                  child: Text(
                    'Thank you for your purchase!',
                    style: TextStyle(color: _gray, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckmark() {
    final v = _checkAnim.value.clamp(0.0, 1.0);
    return SizedBox(
      width: 130,
      height: 130,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (v > 0)
            Opacity(
              opacity: ((1 - v) * 0.6).clamp(0.0, 1.0),
              child: Container(
                width: 65 + 60 * v,
                height: 65 + 60 * v,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _purple.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
              ),
            ),
          Transform.scale(
            scale: v,
            child: Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                color: _purple.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                color: _purple.withValues(alpha: 0.9),
                size: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _slide(
    Animation<double> anim, {
    required Widget child,
    double distance = 20,
  }) {
    final v = anim.value.clamp(0.0, 1.0);
    return Opacity(
      opacity: v,
      child: Transform.translate(
        offset: Offset(0, distance * (1 - v)),
        child: child,
      ),
    );
  }

  // ── Receipt card ──

  Widget _buildReceipt() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: ClipPath(
        clipper: _ScallopTopClipper(),
        child: Container(
          color: _cardBg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transaction receipt',
                      style: TextStyle(color: _gray, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    _amount(32, center: false),
                    const SizedBox(height: 14),
                    Divider(
                      color: Colors.white.withValues(alpha: 0.1),
                      height: 1,
                    ),
                    const SizedBox(height: 14),
                    _infoRow('Merchant', 'Coffee CornerMiami'),
                    const SizedBox(height: 10),
                    _infoRow('Date', '12 Dec 2025, 14:32'),
                    const SizedBox(height: 10),
                    _infoRow('Transaction ID', '#A7F4-92KD'),
                    const SizedBox(height: 10),
                    _statusRow(),
                  ],
                ),
              ),
              _dashedLine(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'VISA',
                        style: TextStyle(
                          color: Color(0xFF1A1F71),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Visa ending in 4242',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Expiry: 10/27',
                          style: TextStyle(color: _gray, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: _gray, fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _statusRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Status', style: TextStyle(color: _gray, fontSize: 14)),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 16),
            const SizedBox(width: 4),
            const Text(
              'Approved',
              style: TextStyle(
                color: Colors.green,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _dashedLine() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const dw = 6.0;
          const gap = 4.0;
          final count = (constraints.maxWidth / (dw + gap)).floor();
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              count,
              (_) => Container(
                width: dw,
                height: 1,
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Ripple circles ──

class _RipplePainter extends CustomPainter {
  final double progress;
  final Color color;

  _RipplePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxR = size.width / 2;
    const minR = 35.0;

    for (int i = 0; i < 3; i++) {
      final p = (progress + i / 3) % 1.0;
      final r = minR + (maxR - minR) * p;
      final a = (1 - p) * 0.25;
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..color = color.withValues(alpha: a.clamp(0.0, 1.0))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
    }
  }

  @override
  bool shouldRepaint(_RipplePainter old) => old.progress != progress;
}

// ── NFC contactless icon ──

class _NfcIconPainter extends CustomPainter {
  final Color color;

  _NfcIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final cx = size.width * 0.35;
    final cy = size.height * 0.45;

    for (int i = 0; i < 3; i++) {
      final r = 5.0 + i * 5.0;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        -pi / 3,
        2 * pi / 3,
        false,
        paint,
      );
    }

    canvas.save();
    canvas.translate(size.width * 0.62, size.height * 0.5);
    canvas.rotate(-0.25);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: 16, height: 11),
        const Radius.circular(2),
      ),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();

    final hand = Path()
      ..moveTo(size.width * 0.52, size.height * 0.6)
      ..quadraticBezierTo(
        size.width * 0.62,
        size.height * 0.68,
        size.width * 0.7,
        size.height * 0.62,
      );
    canvas.drawPath(
      hand,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ── Scalloped top edge for receipt ──

class _ScallopTopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const sr = 5.0;
    const br = 16.0;
    final count = (size.width / (sr * 2)).floor();
    final totalW = count * sr * 2;
    final startX = (size.width - totalW) / 2;

    final path = Path();
    path.moveTo(0, sr);
    path.lineTo(0, size.height - br);
    path.arcToPoint(Offset(br, size.height), radius: const Radius.circular(br));
    path.lineTo(size.width - br, size.height);
    path.arcToPoint(
      Offset(size.width, size.height - br),
      radius: const Radius.circular(br),
    );
    path.lineTo(size.width, sr);
    path.lineTo(startX + totalW, sr);

    for (int i = count - 1; i >= 0; i--) {
      final x = startX + i * sr * 2;
      path.arcToPoint(
        Offset(x, sr),
        radius: const Radius.circular(sr),
        clockwise: true,
      );
    }

    path.lineTo(0, sr);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> old) => false;
}
