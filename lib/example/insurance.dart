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

class _InsuranceExampleState extends State<InsuranceExample> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        height: screenHeight * 0.55,
        width: double.infinity,
        margin: EdgeInsets.only(top: 16, left: 8, right: 8),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(30)),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _MeshGradientPainter()),
            ),
            Padding(
              padding: EdgeInsets.only(top: 60, left: 8, right: 8),
              child: Center(
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
                    Spacer(),
                    Container(
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
                          Icon(
                            Icons.chevron_right,
                            color: Color(0xFF888888),
                            size: 24,
                          ),
                          SizedBox(width: 8),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      // width: double.infinity,
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color(0xFFF5F2EF),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Expanded(
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
                          SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  '\$2,322.98',
                                  style: TextStyle(
                                    color: Color(0xFF1C1C1E),
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 28,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF4A4A4A),
                                      Color(0xFF2C2C2C),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(
                                  'View Premium',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
