import 'dart:developer';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class LerpExample extends StatefulWidget {
  const LerpExample({super.key});

  @override
  State<LerpExample> createState() => _LerpExampleState();
}

class _LerpExampleState extends State<LerpExample>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                final widthT = Curves.easeInOut.transform(controller.value);
                final heightT = Curves.easeInOut.transform(
                  ((controller.value - 0.5) / 0.9).clamp(0.0, 1.0),
                );
                log("JJJJJJJ $widthT ~~~~~~~ $heightT");
                final width = ui.lerpDouble(100, 300, widthT)!;
                final height = ui.lerpDouble(200, 300, heightT);
                return Container(
                  width: width,
                  height: height,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE09068), Color(0xFFC85530)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${width.toInt()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: () {
                if (controller.isCompleted) {
                  controller.reverse();
                } else {
                  controller.forward();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'Animate',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
