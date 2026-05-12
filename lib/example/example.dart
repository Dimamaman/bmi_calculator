import 'package:bmi_calculator/input_page/gender/gender_styles.dart';
import 'package:bmi_calculator/model/gender.dart';
import 'package:bmi_calculator/widget_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ExampleGender extends StatefulWidget {
  const ExampleGender({super.key});

  @override
  State<ExampleGender> createState() => _ExampleGenderState();
}

class _ExampleGenderState extends State<ExampleGender> {
  Gender gender = Gender.other;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ExampleGenderCard(
          gender: Gender.other,
          onChanged: (Gender value) {},
        ),
      ),
    );
  }
}

class ExampleGenderCard extends StatefulWidget {
  final Gender gender;
  final ValueChanged<Gender> onChanged;

  const ExampleGenderCard({
    super.key,
    required this.gender,
    required this.onChanged,
  });

  @override
  State<ExampleGenderCard> createState() => _ExampleGenderCardState();
}

class _ExampleGenderCardState extends State<ExampleGenderCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _arrowAnimationController;

  @override
  void initState() {
    _arrowAnimationController = AnimationController(
      vsync: this,
      lowerBound: -defaultGenderAngle,
      value: genderAngles[widget.gender],
      upperBound: defaultGenderAngle,
    );
    super.initState();
  }

  @override
  void dispose() {
    _arrowAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      color: Colors.blue.withOpacity(0.5),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            width: circleSize(context),
            height: circleSize(context),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromRGBO(95, 246, 120, 1.0),
            ),
          ),
          ExampleGenderArrow(animation: _arrowAnimationController),
          ExampleGenderIconTranslated(
            gender: Gender.female,
            isSelected: widget.gender == Gender.female,
          ),
          ExampleGenderIconTranslated(
            gender: Gender.other,
            isSelected: widget.gender == Gender.female,
          ),
          ExampleGenderIconTranslated(
            gender: Gender.male,
            isSelected: widget.gender == Gender.female,
          ),
          Positioned.fill(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    color: Colors.red.withOpacity(0.3),
                    child: GestureDetector(
                      onTap: () {
                        widget.onChanged(Gender.female);
                        _arrowAnimationController.animateTo(
                          genderAngles[Gender.female]!,
                          duration: Duration(milliseconds: 150),
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.amber.withOpacity(0.3),
                    child: GestureDetector(
                      onTap: () {
                        widget.onChanged(Gender.other);
                        _arrowAnimationController.animateTo(
                          genderAngles[Gender.other]!,
                          duration: Duration(milliseconds: 150),
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.purpleAccent.withOpacity(0.3),
                    child: GestureDetector(
                      onTap: () {
                        widget.onChanged(Gender.male);
                        _arrowAnimationController.animateTo(
                          genderAngles[Gender.male]!,
                          duration: Duration(milliseconds: 150),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ExampleGenderArrow extends AnimatedWidget {
  ExampleGenderArrow({required Animation<double> animation})
    : super(listenable: animation);

  Animation<double> get animation => listenable as Animation<double>;

  double _arrowLength(BuildContext context) => screenAwareSize(32, context);

  double _translationOffset(BuildContext context) =>
      _arrowLength(context) * -0.4;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: animation.value,
      child: Transform.translate(
        offset: Offset(0.0, _translationOffset(context)),
        child: Transform.rotate(
          angle: -defaultGenderAngle,
          child: SvgPicture.asset(
            "images/gender_arrow.svg",
            height: _arrowLength(context),
            width: _arrowLength(context),
          ),
        ),
      ),
    );
  }
}

class ExampleGenderIconTranslated extends StatelessWidget {
  final Gender gender;
  final bool isSelected;

  const ExampleGenderIconTranslated({
    super.key,
    required this.gender,
    required this.isSelected,
  });

  static final Map<Gender, String> _genderImages = {
    Gender.female: "images/gender_female.svg",
    Gender.other: "images/gender_other.svg",
    Gender.male: "images/gender_male.svg",
  };

  bool get _isOtherGender => gender == Gender.other;

  String get _assetName => _genderImages[gender]!;

  double _iconSize(BuildContext context) {
    return screenAwareSize(_isOtherGender ? 22 : 16, context);
  }

  double _genderLeftPadding(BuildContext context) {
    return screenAwareSize(_isOtherGender ? 8 : 0, context);
  }

  @override
  Widget build(BuildContext context) {
    Widget icon = Padding(
      padding: EdgeInsets.only(left: _genderLeftPadding(context)),
      child: SvgPicture.asset(
        _assetName,
        height: _iconSize(context),
        width: _iconSize(context),
        colorFilter: isSelected
            ? null
            : ColorFilter.mode(
                Color.fromRGBO(143, 144, 156, 1.0),
                BlendMode.srcIn,
              ),
      ),
    );

    Widget rotatedIcon = Transform.rotate(
      angle: -genderAngles[gender]!,
      child: icon,
    );

    Widget iconWithALine = Padding(
      padding: EdgeInsetsGeometry.only(bottom: circleSize(context) / 2),
      child: Column(children: <Widget>[rotatedIcon]),
    );

    Widget rotateIconWithALine = Transform.rotate(
      angle: genderAngles[gender]!,
      alignment: Alignment.bottomCenter,
      child: iconWithALine,
    );

    Widget centeredIconWithALine = Padding(
      padding: EdgeInsets.only(bottom: circleSize(context) / 2),
      child: rotateIconWithALine,
    );

    return centeredIconWithALine;
  }
}
