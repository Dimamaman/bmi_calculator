import 'dart:ui';

import 'package:flutter/material.dart';

class PremiumCardAnimationPage extends StatefulWidget {
  const PremiumCardAnimationPage({super.key});

  @override
  State<PremiumCardAnimationPage> createState() =>
      _PremiumCardAnimationPageState();
}

class _PremiumCardAnimationPageState extends State<PremiumCardAnimationPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _overlayAnimation;
  late Animation<double> _cardExpandAnimation;
  late Animation<double> _closeButtonAnimation;
  late Animation<double> _item1Animation;
  late Animation<double> _item2Animation;
  late Animation<double> _item3Animation;
  late Animation<double> _bottomAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _overlayAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    );
    _cardExpandAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic),
    );
    _closeButtonAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.15, 0.4, curve: Curves.easeOut),
    );
    _item1Animation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.25, 0.5, curve: Curves.easeOutCubic),
    );
    _item2Animation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 0.6, curve: Curves.easeOutCubic),
    );
    _item3Animation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 0.7, curve: Curves.easeOutCubic),
    );
    _bottomAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.55, 0.85, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _expand() => _controller.forward();
  void _collapse() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED),
      body: Stack(
        children: [_buildMainContent(), _buildOverlay(), _buildExpandedCard()],
      ),
    );
  }

  Widget _buildMainContent() {
    return SizedBox.expand(
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildClaimsBanner(),
            const SizedBox(height: 16),
            _buildPremiumCard(),
            const SizedBox(height: 24),
            _buildServicesSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE8644A),
            Color(0xFFE87E3E),
            Color(0xFFD4A574),
            Color(0xFFB8A9C8),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome Back',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Willie Schulist',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClaimsBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFFFA726),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  '2',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'You have 2 claims in progress',
              style: TextStyle(fontSize: 14, color: Color(0xFF333333)),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Color(0xFF999999)),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '3 Upcoming Premiums',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Color(0xFF999999),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Due in 27 days',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF999999),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  width: 60,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '\$2,322.98',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                GestureDetector(
                  onTap: _expand,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Text(
                      'View Premium',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Services',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _serviceChip(Icons.payment, 'Payment'),
              _serviceChip(Icons.download, 'Statement Download'),
              _serviceChip(Icons.chat_bubble_outline, 'Chat with'),
              _serviceChip(Icons.local_hospital, 'Hospitals'),
              _serviceChip(Icons.video_call, 'Teleconsult'),
              _serviceChip(Icons.trending_up, 'Top Up'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _serviceChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF666666)),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlay() {
    return AnimatedBuilder(
      animation: _overlayAnimation,
      builder: (context, child) {
        if (_overlayAnimation.value == 0) return const SizedBox.shrink();
        return Positioned.fill(
          child: GestureDetector(
            onTap: _collapse,
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 8 * _overlayAnimation.value,
                sigmaY: 8 * _overlayAnimation.value,
              ),
              child: Container(
                color: Colors.black.withValues(
                  alpha: 0.3 * _overlayAnimation.value,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpandedCard() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (_controller.value == 0) return const SizedBox.shrink();

        final screenHeight = MediaQuery.of(context).size.height;
        final collapsedTop = screenHeight * 0.35;
        final expandedTop = screenHeight * 0.12;
        final currentTop = lerpDouble(
          collapsedTop,
          expandedTop,
          _cardExpandAnimation.value,
        )!;

        final collapsedHeight = 160.0;
        final expandedHeight = 460.0;
        final currentHeight = lerpDouble(
          collapsedHeight,
          expandedHeight,
          _cardExpandAnimation.value,
        )!;

        return Positioned(
          top: currentTop,
          left: 16,
          right: 16,
          height: currentHeight,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildExpandedHeader(),
                            const SizedBox(height: 20),
                            _buildPremiumItem(
                              animation: _item1Animation,
                              name: 'Willie Schulist',
                              id: 'HI1418872904-BB',
                              amount: '\$1,232.98',
                              avatarColor: const Color(0xFFE8B4A0),
                            ),
                            const SizedBox(height: 10),
                            _buildPremiumItem(
                              animation: _item2Animation,
                              name: 'Anne Marquardt',
                              id: 'HI1418872904-BB',
                              amount: '\$1,232.98',
                              avatarColor: const Color(0xFF8EC5C0),
                            ),
                            const SizedBox(height: 10),
                            _buildPremiumItem(
                              animation: _item3Animation,
                              name: 'Kristine Gibson',
                              id: 'HI1418872904-BB',
                              amount: '\$1,232.98',
                              avatarColor: const Color(0xFF7EC8D4),
                            ),
                            const SizedBox(height: 20),
                            _buildBottomSection(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _buildCloseButton(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpandedHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '3 Upcoming Premiums',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.access_time, size: 14, color: Color(0xFF999999)),
            const SizedBox(width: 4),
            const Text(
              'Due in 27 days',
              style: TextStyle(fontSize: 13, color: Color(0xFF999999)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPremiumItem({
    required Animation<double> animation,
    required String name,
    required String id,
    required String amount,
    required Color avatarColor,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - animation.value)),
          child: Opacity(
            opacity: animation.value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF3A3A3A),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: avatarColor,
                  child: Icon(Icons.person, color: Colors.white, size: 24),
                ),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF9800),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    id,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              amount,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCloseButton() {
    return Positioned(
      top: 12,
      right: 12,
      child: AnimatedBuilder(
        animation: _closeButtonAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _closeButtonAnimation.value,
            child: Opacity(
              opacity: _closeButtonAnimation.value.clamp(0.0, 1.0),
              child: child,
            ),
          );
        },
        child: GestureDetector(
          onTap: _collapse,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Icon(Icons.close, size: 20, color: Color(0xFF333333)),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return AnimatedBuilder(
      animation: _bottomAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _bottomAnimation.value)),
          child: Opacity(
            opacity: _bottomAnimation.value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Column(
        children: [
          Text(
            'Slide to Confirm Payment',
            style: TextStyle(fontSize: 13, color: Color(0xFF999999)),
          ),
          const SizedBox(height: 10),
          _SlideToConfirm(onConfirmed: _collapse),
        ],
      ),
    );
  }
}

class _SlideToConfirm extends StatefulWidget {
  final VoidCallback onConfirmed;

  const _SlideToConfirm({required this.onConfirmed});

  @override
  State<_SlideToConfirm> createState() => _SlideToConfirmState();
}

class _SlideToConfirmState extends State<_SlideToConfirm>
    with SingleTickerProviderStateMixin {
  double _dragPosition = 0;
  late AnimationController _returnController;
  late Animation<double> _returnAnimation;

  @override
  void initState() {
    super.initState();
    _returnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _returnController.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details, double maxDrag) {
    setState(() {
      _dragPosition = (_dragPosition + details.delta.dx).clamp(0.0, maxDrag);
    });
  }

  void _onDragEnd(double maxDrag) {
    if (_dragPosition > maxDrag * 0.7) {
      widget.onConfirmed();
      setState(() => _dragPosition = 0);
    } else {
      _returnAnimation =
          Tween<double>(begin: _dragPosition, end: 0).animate(
            CurvedAnimation(parent: _returnController, curve: Curves.easeOut),
          )..addListener(() {
            setState(() => _dragPosition = _returnAnimation.value);
          });
      _returnController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final thumbWidth = 70.0;
        final maxDrag = constraints.maxWidth - thumbWidth;

        return Container(
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F0),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  'Pay Now',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF666666),
                  ),
                ),
              ),
              Positioned(
                left: _dragPosition,
                top: 4,
                child: GestureDetector(
                  onHorizontalDragUpdate: (d) => _onDragUpdate(d, maxDrag),
                  onHorizontalDragEnd: (_) => _onDragEnd(maxDrag),
                  child: Container(
                    width: thumbWidth,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Color(0xFF333333),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
