import 'package:flutter/material.dart';

import '../../../constants/index.dart';
import '../index.dart';

class WeeklyclapSkeleton extends StatefulWidget {
  const WeeklyclapSkeleton({Key key}) : super(key: key);

  @override
  _WeeklyclapSkeletonState createState() => _WeeklyclapSkeletonState();
}

class _WeeklyclapSkeletonState extends State<WeeklyclapSkeleton>
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
        child: Container(
          padding: EdgeInsets.all(16),
          width: MediaQuery.of(context).size.width,
          color: AppColors.appBarBackground,
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              ContainerSkeleton(height: 25, width: 150, color: animation.value),
              ContainerSkeleton(height: 25, width: 100, color: animation.value)
            ]),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 24,
                  color: animation.value,
                ),
                SizedBox(width: 16),
                Icon(
                  Icons.circle,
                  size: 24,
                  color: animation.value,
                ),
                SizedBox(width: 16),
                Icon(
                  Icons.circle,
                  size: 24,
                  color: animation.value,
                ),
                SizedBox(width: 16),
                Icon(
                  Icons.circle,
                  size: 24,
                  color: animation.value,
                ),
                SizedBox(width: 16),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}
