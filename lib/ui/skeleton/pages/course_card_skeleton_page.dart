import 'package:flutter/material.dart';

import '../../../constants/index.dart';
import '../index.dart';

class CourseCardSkeletonPage extends StatefulWidget {
  const CourseCardSkeletonPage({Key key}) : super(key: key);
  CourseCardSkeletonPageState createState() => CourseCardSkeletonPageState();
}

class CourseCardSkeletonPageState extends State<CourseCardSkeletonPage>
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
      height: 320,
      margin: EdgeInsets.only(top: 16),
      child: ListView.separated(
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: CourseCardSkeleton(color: animation.value),
        ),
        separatorBuilder: (context, index) => SizedBox(width: 8),
        itemCount: 3,
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
      ),
    );
  }
}
