import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class InsuranceExample extends StatefulWidget {
  const InsuranceExample();

  @override
  State<InsuranceExample> createState() => _InsuranceExampleState();
}

class User {
  final String name;
  final int age;
  const User(this.name, {this.age = 4});
}

class _InsuranceExampleState extends State<InsuranceExample>
    with TickerProviderStateMixin {
  late final AnimationController expandedAnimationController;
  late final AnimationController servicePageController;

  @override
  void initState() {
    expandedAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    servicePageController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    super.initState();
  }

  @override
  void dispose() {
    expandedAnimationController.dispose();
    servicePageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    const a = 4;
    var b = 5;
    const list = [a, 4, 3, 4];
    const list2 = [4, 3, 4, 5];

    return Scaffold(
      body: AnimatedBuilder(
        animation: expandedAnimationController,
        builder: (context, child) {
          return Container(
            height: screenHeight,
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(30)),
            ),
            child: child,
          );
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _MeshGradientPainter()),
            ),
            AnimatedBuilder(
              animation: servicePageController,
              builder: (context, _) {
                final t = servicePageController.value;
                final curvedT = Curves.easeInOut.transform(t);
                final topOpacity = (1.0 - curvedT * 2.5).clamp(0.0, 1.0);
                final bottomOpacity = (1.0 - curvedT * 2.5).clamp(0.0, 1.0);
                return Padding(
                  padding: EdgeInsets.only(top: 60, left: 8, right: 8),
                  child: SingleChildScrollView(
                    physics: NeverScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _WelcomeHeader(),
                        AnimatedBuilder(
                          animation: expandedAnimationController,
                          builder: (context, _) {
                            final curvedT = Curves.easeInOut.transform(
                              expandedAnimationController.value,
                            );
                            return SizedBox(height: (1 - curvedT) * 20);
                          },
                        ),
                        SizedBox(height: 18),
                        Transform.translate(
                          offset: Offset(0, -curvedT * 80),
                          child: Opacity(
                            opacity: topOpacity,
                            child: Column(
                              children: [
                                _ClaimsRow(
                                  controller: expandedAnimationController,
                                ),
                                AnimatedBuilder(
                                  animation: expandedAnimationController,
                                  builder: (context, _) {
                                    final curvedT = Curves.easeInOut.transform(
                                      expandedAnimationController.value,
                                    );
                                    return SizedBox(height: (1 - curvedT) * 8);
                                  },
                                ),
                                _UpcomingPremiumsCard(
                                  controller: expandedAnimationController,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Transform.translate(
                          offset: Offset(0, curvedT * 100),
                          child: Opacity(
                            opacity: bottomOpacity,
                            child: _ServicesSection(
                              onServiceTap: () {
                                servicePageController.forward();
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                      ],
                    ),
                  ),
                );
              },
            ),
            AnimatedBuilder(
              animation: servicePageController,
              builder: (context, _) {
                final t = servicePageController.value;
                if (t == 0) return SizedBox.shrink();
                final headerT = Curves.easeOut.transform(
                  ((t - 0.2) / 0.5).clamp(0.0, 1.0),
                );
                final contentScaleT = Curves.easeOut.transform(
                  ((t - 0.3) / 0.7).clamp(0.0, 1.0),
                );
                final card1T = Curves.easeOut.transform(
                  ((t - 0.35) / 0.4).clamp(0.0, 1.0),
                );
                final card2T = Curves.easeOut.transform(
                  ((t - 0.45) / 0.4).clamp(0.0, 1.0),
                );
                final card3T = Curves.easeOut.transform(
                  ((t - 0.55) / 0.4).clamp(0.0, 1.0),
                );
                return Positioned.fill(
                  child: Stack(
                    children: [
                      Transform.scale(
                        scale: ui.lerpDouble(0.8, 1.0, contentScaleT)!,
                        child: Opacity(
                          opacity: contentScaleT,
                          child: _MapPlaceholder(),
                        ),
                      ),
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 10,
                        left: 0,
                        right: 0,
                        child: Opacity(
                          opacity: headerT,
                          child: Transform.translate(
                            offset: Offset(0, (1 - headerT) * 20),
                            child: _HospitalsHeader(
                              onBack: () => servicePageController.reverse(),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 12,
                        right: 12,
                        bottom: 0,
                        child: SafeArea(
                          child: Column(
                            children: [
                              _SlidingHospitalCard(
                                slideT: card1T,
                                category: 'General & Primary Care',
                                categoryColor: Color(0xFFE8A65A),
                                name: 'Harmony General Hospital',
                                address: 'Fenimore St 22A (2.3km)',
                              ),
                              SizedBox(height: 10),
                              _SlidingHospitalCard(
                                slideT: card2T,
                                category: 'Dental & Oral Health',
                                categoryColor: Color(0xFFD4837A),
                                name: 'VitalSpring Medical',
                                address: 'Fenimore St 22A (2.3km)',
                              ),
                              SizedBox(height: 10),
                              _SlidingHospitalCard(
                                slideT: card3T,
                                category: 'Behavioral Health',
                                categoryColor: Color(0xFF7AAFCF),
                                name: 'ClearPath Wellness Center',
                                address: 'Maple St 15B (3.1km)',
                              ),
                              SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            _CloseButton(controller: expandedAnimationController),
          ],
        ),
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Welcome Back',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Willie Schulist',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ClaimsRow extends StatelessWidget {
  const _ClaimsRow({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final curvedT = Curves.easeInOut.transform(controller.value);
        final claimsOpacity = (1.0 - curvedT * 2.5).clamp(0.0, 1.0);
        return ClipRect(
          child: SizedBox(
            height: (1 - curvedT) * 70,
            child: Opacity(opacity: claimsOpacity, child: child),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFE8B87A), Color(0xFFD4935A)],
                ),
              ),
              child: Center(
                child: Text(
                  '2',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'You have 2 claims in progress',
                style: TextStyle(
                  color: Color(0xFF2C2C2C),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Color(0xFF888888), size: 24),
            SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

class _UpcomingPremiumsCard extends StatelessWidget {
  const _UpcomingPremiumsCard({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Color(0xFFF5F2EF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PremiumsHeader(),
            SizedBox(height: 16),
            _ExpandablePremiumSection(controller: controller),
          ],
        ),
      ),
    );
  }
}

class _PremiumsHeader extends StatelessWidget {
  const _PremiumsHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '3 Upcoming Premiums',
                  style: TextStyle(
                    color: Color(0xFF1C1C1E),
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time, color: Color(0xFF8E8E93), size: 18),
                    SizedBox(width: 6),
                    Text(
                      'Due in 27 days',
                      style: TextStyle(color: Color(0xFF8E8E93), fontSize: 15),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Transform.flip(
          flipX: true,
          child: Transform.translate(
            offset: Offset(0, -9),
            child: Image.asset('images/receipt.webp', width: 102, height: 102),
          ),
        ),
      ],
    );
  }
}

class _ExpandablePremiumSection extends StatelessWidget {
  const _ExpandablePremiumSection({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final t = controller.value;
            final curvedT = Curves.easeInOut.transform(t);
            final maxW = constraints.maxWidth;
            final buttonW = 160.0;
            final currentW = ui.lerpDouble(buttonW, maxW, curvedT)!;
            final textOpacity = (1.0 - curvedT * 3).clamp(0.0, 1.0);
            // log("NNNNNN  $currentW ~~~~~~ $textOpacity");

            double itemSlide(double start, double end) {
              final itemT = ((t - start) / (end - start)).clamp(0.0, 1.0);
              return Curves.easeOut.transform(itemT);
            }

            final item1T = itemSlide(0.2, 0.6);
            final item2T = itemSlide(0.3, 0.7);
            final item3T = itemSlide(0.4, 0.8);
            final payT = itemSlide(0.5, 0.9);

            return Column(
              children: [
                Row(
                  children: [
                    _AnimatedPriceLabel(
                      curvedT: curvedT,
                      textOpacity: textOpacity,
                    ),
                    GestureDetector(
                      onTap: () {
                        if (controller.isCompleted) {
                          controller.reverse();
                        } else {
                          controller.forward();
                        }
                      },
                      child: Align(
                        alignment: Alignment.lerp(
                          Alignment.centerRight,
                          Alignment.center,
                          curvedT,
                        )!,
                        child: Container(
                          width: currentW,
                          height: ui.lerpDouble(46, 320, curvedT),
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF4A4A4A), Color(0xFF2C2C2C)],
                            ),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: OverflowBox(
                            maxWidth: maxW,
                            maxHeight: 400,
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: ui.lerpDouble(28, 10, curvedT)!,
                                vertical: ui.lerpDouble(12, 4, curvedT)!,
                              ),
                              child: Column(
                                children: [
                                  Opacity(
                                    opacity: textOpacity,
                                    child: Center(
                                      child: Text(
                                        'View Premium',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (t > 0) ...[
                                    _SlidingPremiumItem(
                                      slideT: item1T,
                                      maxW: maxW,
                                      name: 'Willie Schulist',
                                      id: 'HI1418872904-BB',
                                      amount: '\$1,232.98',
                                      avatarColor: Color(0xFF7B6B8A),
                                    ),
                                    _SlidingPremiumItem(
                                      slideT: item2T,
                                      maxW: maxW,
                                      name: 'Anne Marquardt',
                                      id: 'HI1418872904-BB',
                                      amount: '\$1,232.98',
                                      avatarColor: Color(0xFF8A7B6B),
                                    ),
                                    _SlidingPremiumItem(
                                      slideT: item3T,
                                      maxW: maxW,
                                      name: 'Kristine Gibson',
                                      id: 'HI1418872904-BB',
                                      amount: '\$1,232.98',
                                      avatarColor: Color(0xFF6B7B8A),
                                    ),
                                    SizedBox(height: 8),
                                    _PayNowRow(payT: payT),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _AnimatedPriceLabel extends StatelessWidget {
  const _AnimatedPriceLabel({required this.curvedT, required this.textOpacity});

  final double curvedT;
  final double textOpacity;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ClipRect(
        child: SizedBox(
          height: ui.lerpDouble(40, 0, curvedT),
          child: Opacity(
            opacity: textOpacity,
            child: Padding(
              padding: EdgeInsets.only(left: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '\$2,322.98',
                  style: TextStyle(
                    color: Color(0xFF1C1C1E),
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SlidingPremiumItem extends StatelessWidget {
  const _SlidingPremiumItem({
    required this.slideT,
    required this.maxW,
    required this.name,
    required this.id,
    required this.amount,
    required this.avatarColor,
  });

  final double slideT;
  final double maxW;
  final String name;
  final String id;
  final String amount;
  final Color avatarColor;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset((1 - slideT) * maxW, 0),
      child: Opacity(
        opacity: slideT,
        child: _PremiumItemTile(
          name: name,
          id: id,
          amount: amount,
          avatarColor: avatarColor,
        ),
      ),
    );
  }
}

class _PremiumItemTile extends StatelessWidget {
  const _PremiumItemTile({
    required this.name,
    required this.id,
    required this.amount,
    required this.avatarColor,
  });

  final String name;
  final String id;
  final String amount;
  final Color avatarColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF5A5A5A), Color(0xFF3A3A3A)],
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: avatarColor,
                  child: Text(
                    name[0],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Color(0xFFE87A2E),
                      shape: BoxShape.circle,
                      border: Border.all(color: Color(0xFF3A3A3A), width: 2),
                    ),
                    child: Icon(Icons.check, color: Colors.white, size: 10),
                  ),
                ),
              ],
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    id,
                    style: TextStyle(color: Color(0xFF9A9A9A), fontSize: 12),
                  ),
                ],
              ),
            ),
            Flexible(
              child: Text(
                amount,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PayNowRow extends StatelessWidget {
  const _PayNowRow({required this.payT});

  final double payT;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, (1 - payT) * 30),
      child: Opacity(
        opacity: payT,
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                'Pay Now',
                style: TextStyle(
                  color: Color(0xFF1C1C1E),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Spacer(),
            Text(
              'Slide to Confirm Payment',
              style: TextStyle(color: Color(0xFF8E8E93), fontSize: 13),
            ),
            SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

class _ServicesSection extends StatelessWidget {
  const _ServicesSection({required this.onServiceTap});

  final VoidCallback onServiceTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF5F2EF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Services',
            style: TextStyle(
              color: Color(0xFF1C1C1E),
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              _ServiceItem(
                icon: Icons.payment,
                label: 'Payment',
                onTap: onServiceTap,
              ),
              SizedBox(width: 10),
              _ServiceItem(
                icon: Icons.download_rounded,
                label: 'Statement Download',
                onTap: onServiceTap,
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              _ServiceItem(
                icon: Icons.chat_bubble_outline,
                label: 'Chat with Us',
                onTap: onServiceTap,
              ),
              SizedBox(width: 10),
              _ServiceItem(
                icon: Icons.star_outline,
                label: 'Top Up',
                onTap: onServiceTap,
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              _ServiceItem(
                icon: Icons.local_hospital_outlined,
                label: 'Hospitals',
                onTap: onServiceTap,
              ),
              SizedBox(width: 10),
              _ServiceItem(
                icon: Icons.video_call_outlined,
                label: 'Teleconsult',
                onTap: onServiceTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ServiceItem extends StatelessWidget {
  const _ServiceItem({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(icon, color: Color(0xFF4A4A4A), size: 22),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFF4A4A4A),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
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

class _HospitalsHeader extends StatelessWidget {
  const _HospitalsHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Icon(Icons.arrow_back, color: Color(0xFF1C1C1E), size: 24),
          ),
          SizedBox(width: 12),
          Text(
            'Hospitals',
            style: TextStyle(
              color: Color(0xFF1C1C1E),
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          Spacer(),
          _HeaderIcon(Icons.splitscreen),
          SizedBox(width: 12),
          _HeaderIcon(Icons.menu),
        ],
      ),
    );
  }
}

class _SlidingHospitalCard extends StatelessWidget {
  const _SlidingHospitalCard({
    required this.slideT,
    required this.category,
    required this.categoryColor,
    required this.name,
    required this.address,
  });

  final double slideT;
  final String category;
  final Color categoryColor;
  final String name;
  final String address;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, (1 - slideT) * 60),
      child: Opacity(
        opacity: slideT,
        child: _HospitalCard(
          category: category,
          categoryColor: categoryColor,
          name: name,
          address: address,
        ),
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon(this.icon);

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFE8E4E0),
      ),
      child: Icon(icon, color: Color(0xFF4A4A4A), size: 18),
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Color(0xFFE8E4DF),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _MapGridPainter())),
          Positioned(top: 100, left: 80, child: _MapPin(Color(0xFFE8A65A))),
          Positioned(top: 160, left: 200, child: _MapPin(Color(0xFFD4837A))),
          Positioned(top: 220, left: 130, child: _MapPin(Color(0xFF7AAFCF))),
        ],
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin(this.color);

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Icon(Icons.local_hospital, color: Colors.white, size: 14),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFFD5D0CB)
      ..strokeWidth = 0.5;

    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (double x = 0; x < size.width; x += 50) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    final roadPaint = Paint()
      ..color = Color(0xFFF5F2EF)
      ..strokeWidth = 8;

    canvas.drawLine(
      Offset(0, size.height * 0.35),
      Offset(size.width, size.height * 0.4),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.3, 0),
      Offset(size.width * 0.35, size.height),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.7, 0),
      Offset(size.width * 0.65, size.height),
      roadPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.7),
      Offset(size.width, size.height * 0.65),
      roadPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HospitalCard extends StatelessWidget {
  const _HospitalCard({
    required this.category,
    required this.categoryColor,
    required this.name,
    required this.address,
  });

  final String category;
  final Color categoryColor;
  final String name;
  final String address;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: categoryColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.local_hospital, color: categoryColor, size: 30),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: categoryColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  name,
                  style: TextStyle(
                    color: Color(0xFF1C1C1E),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, color: Color(0xFF8E8E93), size: 14),
                    SizedBox(width: 4),
                    Text(
                      address,
                      style: TextStyle(color: Color(0xFF8E8E93), fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 90,
      right: 10,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Transform.scale(scale: controller.value, child: child);
        },
        child: GestureDetector(
          onTap: () => controller.reverse(),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Icon(Icons.close, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}

class _MeshGradientPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final basePaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, 0),
        Offset(size.width, size.height),
        [Color(0xFFD5BFB0), Color(0xFFE09068), Color(0xFFC85530)],
        [0.0, 0.45, 1.0],
      );
    canvas.drawRect(rect, basePaint);

    final topLeftPaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(size.width * 0.15, size.height * 0.1),
        size.width * 0.55,
        [Color(0xFFBBB0A5), Color(0x88C0B5AA), Color(0x00C0B5AA)],
        [0.0, 0.35, 1.0],
      );
    canvas.drawRect(rect, topLeftPaint);

    final bottomRightPaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(size.width * 0.75, size.height * 0.7),
        size.width * 0.6,
        [Color(0xFFB84820), Color(0xAAC85530), Color(0x00C85530)],
        [0.0, 0.3, 1.0],
      );
    canvas.drawRect(rect, bottomRightPaint);

    final centerPaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(size.width * 0.45, size.height * 0.45),
        size.width * 0.4,
        [Color(0x66E89565), Color(0x00E89565)],
        [0.0, 1.0],
      );
    canvas.drawRect(rect, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
