import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class _MeshGradientPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // 1-qatlam: asosiy fon — yuqoridan pastga iliq gradient
    final basePaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, 0),
        Offset(size.width, size.height),
        [
          Color(0xFFD5BFB0), // och beige-kulrang
          Color(0xFFE09068), // shaftoli
          Color(0xFFC85530), // to'q apelsin
        ],
        [0.0, 0.45, 1.0],
      );
    canvas.drawRect(rect, basePaint);

    // 2-qatlam: yuqori-chap kulrang-kumush dog'
    final topLeftPaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(size.width * 0.15, size.height * 0.1),
        size.width * 0.55,
        [Color(0xFFBBB0A5), Color(0x88C0B5AA), Color(0x00C0B5AA)],
        [0.0, 0.35, 1.0],
      );
    canvas.drawRect(rect, topLeftPaint);

    // 3-qatlam: o'ng pastdagi to'q apelsin dog'
    final bottomRightPaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(size.width * 0.75, size.height * 0.7),
        size.width * 0.6,
        [Color(0xFFB84820), Color(0xAAC85530), Color(0x00C85530)],
        [0.0, 0.3, 1.0],
      );
    canvas.drawRect(rect, bottomRightPaint);

    // 4-qatlam: markaziy shaftoli aksent
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

class InsuranceExample extends StatefulWidget {
  const InsuranceExample();

  @override
  State<InsuranceExample> createState() => _InsuranceExampleState();
}

class _InsuranceExampleState extends State<InsuranceExample>
    with SingleTickerProviderStateMixin {
  late final AnimationController expandedAnimationController;

  @override
  void initState() {
    expandedAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );
    super.initState();
  }

  Widget _buildPremiumItem(
    String name,
    String id,
    String amount,
    Color avatarColor,
  ) {
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

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final collapsedHeight = screenHeight * 0.55;
    final expandedExtra = 195.0;
    return Scaffold(
      body: AnimatedBuilder(
        animation: expandedAnimationController,
        builder: (context, child) {
          final currentHeight =
              collapsedHeight +
              (expandedExtra * expandedAnimationController.value);
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
            Padding(
              padding: EdgeInsets.only(top: 60, left: 8, right: 8),
              child: SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                    AnimatedBuilder(
                      animation: expandedAnimationController,
                      builder: (context, _) {
                        final curvedT = Curves.easeInOut.transform(
                          expandedAnimationController.value,
                        );
                        return SizedBox(height: (1 - curvedT) * 20);
                      },
                    ),
                    AnimatedBuilder(
                      animation: expandedAnimationController,
                      builder: (context, child) {
                        final curvedT = Curves.easeInOut.transform(
                          expandedAnimationController.value,
                        );
                        final claimsOpacity = (1.0 - curvedT * 2.5).clamp(
                          0.0,
                          1.0,
                        );
                        return ClipRect(
                          child: SizedBox(
                            height: (1 - curvedT) * 70,
                            child: Opacity(
                              opacity: claimsOpacity,
                              child: child,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
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
                                  colors: [
                                    Color(0xFFE8B87A),
                                    Color(0xFFD4935A),
                                  ],
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
                            Icon(
                              Icons.chevron_right,
                              color: Color(0xFF888888),
                              size: 24,
                            ),
                            SizedBox(width: 8),
                          ],
                        ),
                      ),
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
                    Container(
                      // width: double.infinity,
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
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                            Icon(
                                              Icons.access_time,
                                              color: Color(0xFF8E8E93),
                                              size: 18,
                                            ),
                                            SizedBox(width: 6),
                                            Text(
                                              'Due in 27 days',
                                              style: TextStyle(
                                                color: Color(0xFF8E8E93),
                                                fontSize: 15,
                                              ),
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
                                    child: Image.asset(
                                      'images/receipt.webp',
                                      width: 102,
                                      height: 102,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                return AnimatedBuilder(
                                  animation: expandedAnimationController,
                                  builder: (context, _) {
                                    final t = expandedAnimationController.value;
                                    final curvedT = Curves.easeInOut.transform(
                                      t,
                                    );
                                    final maxW = constraints.maxWidth;
                                    final buttonW = 160.0;
                                    final currentW = ui.lerpDouble(
                                      buttonW,
                                      maxW,
                                      curvedT,
                                    )!;

                                    final textOpacity = (1.0 - curvedT * 3)
                                        .clamp(0.0, 1.0);

                                    double itemSlide(double start, double end) {
                                      final itemT =
                                          ((t - start) / (end - start)).clamp(
                                            0.0,
                                            1.0,
                                          );
                                      return Curves.easeOut.transform(itemT);
                                    }

                                    final item1T = itemSlide(0.2, 0.6);
                                    final item2T = itemSlide(0.3, 0.7);
                                    final item3T = itemSlide(0.4, 0.8);
                                    final payT = itemSlide(0.5, 0.9);

                                    return Column(
                                      children: [
                                        // $2,322.98 — yopilganda ko'rinadi
                                        SizedBox(
                                          height: (1 - curvedT) * 40,
                                          child: Opacity(
                                            opacity: textOpacity,
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                  left: 8,
                                                ),
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
                                        // Yoyiladigan to'q container
                                        GestureDetector(
                                          onTap: () {
                                            if (expandedAnimationController
                                                .isCompleted) {
                                              expandedAnimationController
                                                  .reverse();
                                            } else {
                                              expandedAnimationController
                                                  .forward();
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
                                              height: ui.lerpDouble(
                                                46,
                                                380,
                                                curvedT,
                                              ),
                                              clipBehavior: Clip.antiAlias,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    Color(0xFF4A4A4A),
                                                    Color(0xFF2C2C2C),
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(40),
                                              ),
                                              child: OverflowBox(
                                                maxWidth: maxW,
                                                maxHeight: 400,
                                                alignment: Alignment.topCenter,
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: ui.lerpDouble(
                                                      28,
                                                      10,
                                                      curvedT,
                                                    )!,
                                                    vertical: 14,
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Opacity(
                                                        opacity: textOpacity,
                                                        child: Center(
                                                          child: Text(
                                                            'View Premium',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      if (t > 0) ...[
                                                        SizedBox(height: 8),
                                                        Transform.translate(
                                                          offset: Offset(
                                                            (1 - item1T) * maxW,
                                                            0,
                                                          ),
                                                          child: Opacity(
                                                            opacity: item1T,
                                                            child: _buildPremiumItem(
                                                              'Willie Schulist',
                                                              'HI1418872904-BB',
                                                              '\$1,232.98',
                                                              Color(0xFF7B6B8A),
                                                            ),
                                                          ),
                                                        ),
                                                        Transform.translate(
                                                          offset: Offset(
                                                            (1 - item2T) * maxW,
                                                            0,
                                                          ),
                                                          child: Opacity(
                                                            opacity: item2T,
                                                            child: _buildPremiumItem(
                                                              'Anne Marquardt',
                                                              'HI1418872904-BB',
                                                              '\$1,232.98',
                                                              Color(0xFF8A7B6B),
                                                            ),
                                                          ),
                                                        ),
                                                        Transform.translate(
                                                          offset: Offset(
                                                            (1 - item3T) * maxW,
                                                            0,
                                                          ),
                                                          child: Opacity(
                                                            opacity: item3T,
                                                            child: _buildPremiumItem(
                                                              'Kristine Gibson',
                                                              'HI1418872904-BB',
                                                              '\$1,232.98',
                                                              Color(0xFF6B7B8A),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(height: 8),
                                                        Transform.translate(
                                                          offset: Offset(
                                                            0,
                                                            (1 - payT) * 30,
                                                          ),
                                                          child: Opacity(
                                                            opacity: payT,
                                                            child: Row(
                                                              children: [
                                                                Container(
                                                                  padding:
                                                                      EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            24,
                                                                        vertical:
                                                                            12,
                                                                      ),
                                                                  decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          30,
                                                                        ),
                                                                  ),
                                                                  child: Text(
                                                                    'Pay Now',
                                                                    style: TextStyle(
                                                                      color: Color(
                                                                        0xFF1C1C1E,
                                                                      ),
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Spacer(),
                                                                Text(
                                                                  'Slide to Confirm Payment',
                                                                  style: TextStyle(
                                                                    color: Color(
                                                                      0xFF8E8E93,
                                                                    ),
                                                                    fontSize:
                                                                        13,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 8,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 90,
              right: 10,
              child: AnimatedBuilder(
                animation: expandedAnimationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: expandedAnimationController.value,
                    child: child,
                  );
                },
                child: GestureDetector(
                  onTap: () {
                    expandedAnimationController.reverse();
                  },
                  child: Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Icon(Icons.close, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
