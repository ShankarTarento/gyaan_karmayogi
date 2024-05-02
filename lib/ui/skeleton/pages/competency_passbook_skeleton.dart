import 'package:flutter/material.dart';

import '../../../constants/index.dart';
import '../index.dart';

class CompetencyPassbookSkeletonPage extends StatefulWidget {
  @required
  final double height, width;
  const CompetencyPassbookSkeletonPage({Key key, this.height, this.width})
      : super(key: key);
  CompetencyPassbookSkeletonPageState createState() =>
      CompetencyPassbookSkeletonPageState();
}

class CompetencyPassbookSkeletonPageState
    extends State<CompetencyPassbookSkeletonPage>
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.3,
              width: double.infinity,
              decoration: BoxDecoration(
                color: animation.value,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40.0),
                  bottomRight: Radius.circular(40.0),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: ContainerSkeleton(
                  height: 40,
                  width: MediaQuery.of(context).size.width,
                  color: animation.value,
                  radius: 8),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 15),
              child: ContainerSkeleton(
                  height: MediaQuery.of(context).size.height * 0.2,
                  width: MediaQuery.of(context).size.width,
                  color: animation.value,
                  radius: 8),
            ),
            ContainerSkeleton(
                height: MediaQuery.of(context).size.height * 0.2,
                width: MediaQuery.of(context).size.width,
                color: animation.value,
                radius: 8),
          ],
        ),
      ),
    );
  }
}
