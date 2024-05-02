import 'package:flutter/material.dart';

import '../../../constants/index.dart';
import '../index.dart';

class CompetencyPassbookThemeSkeletonPage extends StatefulWidget {
  const CompetencyPassbookThemeSkeletonPage({
    Key key,
  }) : super(key: key);
  CompetencyPassbookThemeSkeletonPageState createState() =>
      CompetencyPassbookThemeSkeletonPageState();
}

class CompetencyPassbookThemeSkeletonPageState
    extends State<CompetencyPassbookThemeSkeletonPage>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<Color> animation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    animation = TweenSequence<Color>(
      [
        TweenSequenceItem(
          weight: 1.0,
          tween: ColorTween(
            begin: AppColors.grey04,
            end: AppColors.grey08,
          ),
        ),
        TweenSequenceItem(
          weight: 1.0,
          tween: ColorTween(
            begin: AppColors.grey04,
            end: AppColors.grey08,
          ),
        ),
      ],
    ).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
    _controller.repeat();
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(16),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ContainerSkeleton(
                height: MediaQuery.of(context).size.height * 0.1,
                width: MediaQuery.of(context).size.width * 0.7,
                color: animation.value),
            ContainerSkeleton(
                height: 70,
                width: MediaQuery.of(context).size.width * 0.2,
                color: animation.value)
          ],
        ),
        SizedBox(height: 16),
        ContainerSkeleton(
            height: MediaQuery.of(context).size.height * 0.3,
            width: MediaQuery.of(context).size.width,
            color: animation.value),
        SizedBox(height: 16),
        ContainerSkeleton(
            height: MediaQuery.of(context).size.height * 0.4,
            width: MediaQuery.of(context).size.width,
            color: animation.value),
      ]),
    );
  }
}
