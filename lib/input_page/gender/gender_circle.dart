import 'package:bmi_calculator/input_page/gender/gender_styles.dart';
import 'package:flutter/material.dart';

class GenderCircle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: circleSize(context),
      height: circleSize(context),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color.fromRGBO(95, 246, 120, 1.0),
      ),
    );
  }
}
