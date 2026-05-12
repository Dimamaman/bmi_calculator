import 'package:bmi_calculator/example/example.dart';
import 'package:bmi_calculator/example/example_clock.dart';
import 'package:bmi_calculator/fade_route.dart';
import 'package:bmi_calculator/input_page/input_page_styles.dart';
import 'package:bmi_calculator/widget_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BmiAppBar extends StatelessWidget {
  final bool isInputPage;
  static const String wavingHandEmoji = "\uD83D\uDC4B";
  static const String whiteSkinTone = "\uD83C\uDFFB";

  const BmiAppBar({Key? key, this.isInputPage = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 1.0,
      child: Container(
        height: appBarHeight(context),
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(screenAwareSize(16.0, context)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[_buildLabel(context), _buildIcons(context)],
          ),
        ),
      ),
    );
  }

  Row _buildIcons(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              ScaleRoute(builder: (context) => const ExampleClock()),
            );
          },
          child: Padding(
            padding: EdgeInsets.only(
              bottom: screenAwareSize(11.0, context),
              right: screenAwareSize(12.0, context),
            ),
            child: Icon(
              Icons.access_time,
              size: screenAwareSize(22.0, context),
            ),
          ),
        ),
        GestureDetector(
          onDoubleTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ExampleGender()),
            );
          },
          child: Padding(
            padding: EdgeInsets.only(bottom: screenAwareSize(11.0, context)),
            child: SvgPicture.asset(
              'images/user.svg',
              height: screenAwareSize(20.0, context),
              width: screenAwareSize(20.0, context),
            ),
          ),
        ),
      ],
    );
  }

  RichText _buildLabel(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style.copyWith(fontSize: 34.0),
        children: [
          TextSpan(
            text: isInputPage ? "Hi Johny " : "Your BMI",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: isInputPage ? getEmoji(context) : ""),
        ],
      ),
    );
  }

  // https://github.com/flutter/flutter/issues/9652
  String getEmoji(BuildContext context) {
    return Theme.of(context).platform == TargetPlatform.iOS
        ? wavingHandEmoji
        : wavingHandEmoji + whiteSkinTone;
  }
}
