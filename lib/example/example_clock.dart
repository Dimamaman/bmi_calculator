import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class ExampleClock extends StatefulWidget {
  const ExampleClock({super.key});

  @override
  State<ExampleClock> createState() => _ExampleClockState();
}

class _ExampleClockState extends State<ExampleClock> {
  late DateTime _now;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    // Har soniyada vaqtni yangilaydi
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black,
      appBar: AppBar(),
      body: Center(child: ClockFace(now: _now)),
    );
  }
}

class ClockFace extends StatelessWidget {
  final DateTime now;
  const ClockFace({super.key, required this.now});

  // Sekund qo'li: 60 soniyada to'liq aylanadi
  double get _secondAngle => (now.second / 60) * 2 * pi;

  // Minut qo'li: sekundni ham hisobga oladi (silliq harakat)
  double get _minuteAngle => ((now.minute + now.second / 60) / 60) * 2 * pi;

  // Soat qo'li: minutni ham hisobga oladi (silliq harakat)
  double get _hourAngle => (((now.hour % 12) + now.minute / 60) / 12) * 2 * pi;

  @override
  Widget build(BuildContext context) {
    const size = 320.0;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Soat yuzi
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),
          // 12 ta belgi
          ...List.generate(12, (i) => _HourMarker(index: i, clockSize: size)),
          // Soat raqamlari
          ...List.generate(12, (i) => _HourLabel(index: i, clockSize: size)),
          // Soat qo'li (qalin, qisqa)
          ClockHand(
            angle: _hourAngle,
            length: size * 0.25,
            width: 7,
            color: Colors.black,
          ),
          // Minut qo'li (o'rta)
          ClockHand(
            angle: _minuteAngle,
            length: size * 0.35,
            width: 4,
            color: Colors.black,
          ),
          // Sekund qo'li (ingichka, qizil)
          ClockHand(
            angle: _secondAngle,
            length: size * 0.40,
            width: 2,
            color: Colors.red,
          ),
          // Markazdagi nuqta
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}

// Soat qo'li — ExampleGenderArrow bilan bir xil mantiq
class ClockHand extends StatelessWidget {
  final double angle;
  final double length;
  final double width;
  final Color color;

  const ClockHand({
    super.key,
    required this.angle,
    required this.length,
    required this.width,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle, // 1-qadam: hozirgi vaqt burchagiga aylantir
      child: Transform.translate(
        offset: Offset(
          0,
          -length / 2,
        ), // 2-qadam: qo'lni yuqoriga ko'tar (dum markaz, uchi yuqorida)
        child: Container(
          width: width,
          height: length,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(width),
          ),
        ),
      ),
    );
  }
}

// Soat belgilari (chiziqchalar)
class _HourMarker extends StatelessWidget {
  final int index;
  final double clockSize;

  const _HourMarker({required this.index, required this.clockSize});

  @override
  Widget build(BuildContext context) {
    final angle = (index / 12) * 2 * pi;
    final isMajor = index % 3 == 0; // 12, 3, 6, 9 — qalin
    return Transform.rotate(
      angle: angle,
      child: Transform.translate(
        offset: Offset(0, -(clockSize / 2 - (isMajor ? 10 : 6))),
        child: Container(
          width: isMajor ? 4 : 2,
          height: isMajor ? 14 : 8,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

// Soat raqamlari (1–12)
class _HourLabel extends StatelessWidget {
  final int index;
  final double clockSize;

  const _HourLabel({required this.index, required this.clockSize});

  @override
  Widget build(BuildContext context) {
    final label = index == 0 ? 12 : index;
    final angle = (index / 12) * 2 * pi;
    final radius = clockSize / 2 - 32;
    final x = radius * sin(angle);
    final y = -radius * cos(angle);
    return Transform.translate(
      offset: Offset(x, y),
      child: Text(
        '$label',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
}
