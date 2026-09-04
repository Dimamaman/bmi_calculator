import 'dart:math';

import 'package:flutter/material.dart';

const _bgColor = Color(0xFFF5F0EB);
const _envelopeBody = Color(0xFFD4A574);
const _envelopeDark = Color(0xFFC0935E);
const _envelopeFlap = Color(0xFFE0B888);
const _letterBg = Color(0xFFFFFDF8);
const _textColor = Color(0xFF3A2E22);
const _accent = Color(0xFF8B5E3C);

class EnvelopeOpenPage extends StatefulWidget {
  const EnvelopeOpenPage({super.key});

  @override
  State<EnvelopeOpenPage> createState() => _EnvelopeOpenPageState();
}

class _EnvelopeOpenPageState extends State<EnvelopeOpenPage>
    with TickerProviderStateMixin {
  late AnimationController _flapCtrl;
  late AnimationController _letterCtrl;
  late AnimationController _textCtrl;

  late Animation<double> _flapAngle;
  late Animation<double> _letterRise;
  late Animation<double> _replyBtn;

  bool _isOpen = false;

  final _lineKeys = List.generate(4, (_) => GlobalKey<_FadeLineState>());
  final _lines = [
    'Dear Friend,',
    'Hope this finds you well.',
    'Great news about our trip!',
    'Warm regards, Alex',
  ];

  @override
  void initState() {
    super.initState();

    _flapCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _flapAngle = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(parent: _flapCtrl, curve: Curves.easeInOutCubic),
    );

    _letterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _letterRise = CurvedAnimation(
      parent: _letterCtrl,
      curve: Curves.easeOutCubic,
    );

    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _replyBtn = CurvedAnimation(
      parent: _textCtrl,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _flapCtrl.dispose();
    _letterCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    _isOpen = true;
    await _flapCtrl.forward();
    await _letterCtrl.forward();
    for (var i = 0; i < _lineKeys.length; i++) {
      await Future.delayed(const Duration(milliseconds: 60));
      _lineKeys[i].currentState?.show();
    }
    await Future.delayed(const Duration(milliseconds: 80));
    _textCtrl.forward();
  }

  Future<void> _close() async {
    _isOpen = false;
    _textCtrl.reverse();
    for (var i = _lineKeys.length - 1; i >= 0; i--) {
      await Future.delayed(const Duration(milliseconds: 40));
      _lineKeys[i].currentState?.hide();
    }
    await Future.delayed(const Duration(milliseconds: 200));
    await _letterCtrl.reverse();
    await _flapCtrl.reverse();
  }

  void _onTap() {
    if (_flapCtrl.isAnimating ||
        _letterCtrl.isAnimating ||
        _textCtrl.isAnimating) return;
    _isOpen ? _close() : _open();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: AnimatedBuilder(
        animation: Listenable.merge([_flapCtrl, _letterCtrl, _textCtrl]),
        builder: (context, _) {
          return GestureDetector(
            onTap: _onTap,
            behavior: HitTestBehavior.opaque,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final h = constraints.maxHeight;
                final envH = 170.0;
                final envTop = h * 0.45;
                final rise = _letterRise.value;
                final letterH = 150.0 * rise;

                return Stack(
                  children: [
                    if (rise > 0)
                      Positioned(
                        left: 0,
                        right: 0,
                        top: envTop - letterH - 4 + 30 * (1 - rise),
                        child: Center(
                          child: Opacity(
                            opacity: rise,
                            child: Container(
                              width: 270,
                              height: letterH,
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                color: _letterBg,
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: rise > 0.4
                                  ? SingleChildScrollView(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: List.generate(
                                            _lineKeys.length, (i) {
                                          return Padding(
                                            padding: EdgeInsets.only(
                                                bottom: i == 0 ? 10 : 4),
                                            child: _FadeLine(
                                              key: _lineKeys[i],
                                              text: _lines[i],
                                              isBold: i == 0 ||
                                                  i == _lineKeys.length - 1,
                                            ),
                                          );
                                        }),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      left: 0,
                      right: 0,
                      top: envTop,
                      child: Center(child: _buildEnvelope()),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      top: envTop + envH + 32,
                      child: Center(child: _buildReplyButton()),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEnvelope() {
    return SizedBox(
      width: 300,
      height: 170,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Envelope body
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: const Size(300, 140),
              painter: _EnvelopeBodyPainter(),
            ),
          ),
          // Flap
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Transform(
              alignment: Alignment.topCenter,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(_flapAngle.value),
              child: CustomPaint(
                size: const Size(300, 80),
                painter: _EnvelopeFlapPainter(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyButton() {
    final v = _replyBtn.value;
    if (v == 0) return const SizedBox(height: 48);

    return Opacity(
      opacity: v.clamp(0.0, 1.0),
      child: Transform.scale(
        scale: v,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          decoration: BoxDecoration(
            color: _accent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.reply_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Reply',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FadeLine extends StatefulWidget {
  final String text;
  final bool isBold;

  const _FadeLine({super.key, required this.text, this.isBold = false});

  @override
  State<_FadeLine> createState() => _FadeLineState();
}

class _FadeLineState extends State<_FadeLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  int _direction = 1;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void show() {
    _direction = 1;
    _ctrl.forward();
  }

  void hide() {
    _direction = -1;
    _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        final v = _anim.value;
        return Opacity(
          opacity: v,
          child: Transform.translate(
            offset: Offset(0, 20 * _direction * (1 - v)),
            child: Text(
              widget.text,
              style: TextStyle(
                color: _textColor,
                fontSize: 15,
                fontWeight: widget.isBold ? FontWeight.w600 : FontWeight.w400,
                height: 1.4,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EnvelopeBodyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final body = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(body, Paint()..color = _envelopeBody);

    final vShape = Path()
      ..moveTo(0, 0)
      ..lineTo(w / 2, h * 0.6)
      ..lineTo(w, 0)
      ..lineTo(w, 4)
      ..lineTo(w / 2, h * 0.6 + 4)
      ..lineTo(0, 4)
      ..close();
    canvas.drawPath(vShape, Paint()..color = _envelopeDark);

    canvas.drawLine(
      Offset(0, 0),
      Offset(w / 2, h * 0.6),
      Paint()
        ..color = _envelopeDark
        ..strokeWidth = 2,
    );
    canvas.drawLine(
      Offset(w, 0),
      Offset(w / 2, h * 0.6),
      Paint()
        ..color = _envelopeDark
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _EnvelopeFlapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final flap = Path()
      ..moveTo(0, 0)
      ..lineTo(w / 2, h)
      ..lineTo(w, 0)
      ..close();
    canvas.drawPath(flap, Paint()..color = _envelopeFlap);

    canvas.drawLine(
      Offset(0, 0),
      Offset(w / 2, h),
      Paint()
        ..color = _envelopeDark
        ..strokeWidth = 1.5,
    );
    canvas.drawLine(
      Offset(w, 0),
      Offset(w / 2, h),
      Paint()
        ..color = _envelopeDark
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
