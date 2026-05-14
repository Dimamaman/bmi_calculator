import 'dart:developer';

import 'package:bmi_calculator/input_page/gender/gender_styles.dart';
import 'package:bmi_calculator/input_page/pacman_slider.dart';
import 'package:bmi_calculator/model/gender.dart';
import 'package:bmi_calculator/widget_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ExampleGender extends StatefulWidget {
  const ExampleGender({super.key});

  @override
  State<ExampleGender> createState() => _ExampleGenderState();
}

class _ExampleGenderState extends State<ExampleGender>
    with SingleTickerProviderStateMixin {
  Gender gender = Gender.other;
  double _pacmanX = 0;
  late AnimationController _returnController;
  late Animation<double> _returnAnimation;

  @override
  void initState() {
    super.initState();
    _returnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _returnController.dispose();
    super.dispose();
  }

  void _returnToStart() {
    _returnAnimation =
        Tween<double>(begin: _pacmanX, end: 0).animate(
          CurvedAnimation(parent: _returnController, curve: Curves.easeOut),
        )..addListener(() {
          setState(() => _pacmanX = _returnAnimation.value);
        });
    _returnController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    log("JJJJJJ $_pacmanX");
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.greenAccent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              ExampleGenderCard(
                gender: Gender.other,
                onChanged: (Gender value) {},
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 18.0),
                    width: constraints.maxWidth,
                    height: 160,
                    child: Stack(
                      children: [
                        Positioned(
                          left: _pacmanX,
                          child: GestureDetector(
                            onHorizontalDragUpdate: (details) {
                              _returnController.stop();
                              setState(() {
                                _pacmanX += details.delta.dx;
                                _pacmanX = _pacmanX.clamp(
                                  0,
                                  constraints.maxWidth - 50,
                                );
                              });
                            },
                            // onHorizontalDragEnd: (_) => _returnToStart(),
                            child: PacmanIcon(),
                          ),
                        ),

                        Positioned(
                          bottom: 10,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadiusTween(
                                    begin: BorderRadius.circular(40),
                                    end: BorderRadius.zero,
                                  ).lerp(
                                    (constraints.maxWidth - 50) > 0
                                        ? (_pacmanX /
                                                  (constraints.maxWidth - 50))
                                              .clamp(0.0, 1.0)
                                        : 0.0,
                                  ),
                              color: Colors.purple,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          left: 100,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration:
                                DecorationTween(
                                      begin: BoxDecoration(
                                        borderRadius: BorderRadius.circular(40),
                                        color: Colors.blue,
                                        boxShadow: [],
                                      ),
                                      end: BoxDecoration(
                                        borderRadius: BorderRadius.zero,
                                        color: Colors.orange,
                                        boxShadow: [
                                          BoxShadow(
                                            blurRadius: 16,
                                            color: Colors.orange.withValues(
                                              alpha: 0.6,
                                            ),
                                            spreadRadius: 4,
                                          ),
                                        ],
                                      ),
                                    ).lerp(
                                      (constraints.maxWidth - 50) > 0
                                          ? (_pacmanX /
                                                    (constraints.maxWidth - 50))
                                                .clamp(0.0, 1.0)
                                          : 0.0,
                                    )
                                    as BoxDecoration,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
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
      color: Colors.amber.withOpacity(0.5),
      padding: EdgeInsets.all(20),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          // Container(
          //   width: circleSize(context),
          //   height: circleSize(context),
          //   decoration: BoxDecoration(
          //     shape: BoxShape.circle,
          //     color: Color.fromRGBO(95, 246, 120, 1.0),
          //   ),
          // ),
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
                Expanded(
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
                Expanded(
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
