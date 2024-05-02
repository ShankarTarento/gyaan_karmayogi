import 'package:flutter/material.dart';

import '../../../constants/index.dart';
import '../index.dart';

class StatsSkeleton extends StatefulWidget {
  const StatsSkeleton({Key key}) : super(key: key);

  @override
  _StatsSkeletonState createState() => _StatsSkeletonState();
}

class _StatsSkeletonState extends State<StatsSkeleton>
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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ContainerSkeleton(color: animation.value, height: 20, width: 100),
            SizedBox(height: 16),
            Container(
              height: 180,
              padding: EdgeInsets.all(14),
              width: MediaQuery.of(context).size.width,
              color: AppColors.appBarBackground,
              child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TabSkeleton(
                        iconHeight: 24,
                        iconWidth: 24,
                        radius: 4,
                        color: animation.value),
                    TabSkeleton(
                        iconHeight: 24,
                        iconWidth: 24,
                        radius: 4,
                        color: animation.value),
                    TabSkeleton(
                        iconHeight: 24,
                        iconWidth: 24,
                        radius: 4,
                        color: animation.value),
                  ],
                ),
                SizedBox(height: 8),
                ContainerSkeleton(
                    color: animation.value,
                    height: 84,
                    width: MediaQuery.of(context).size.width),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
