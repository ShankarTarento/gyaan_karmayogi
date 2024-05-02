import 'package:flutter/material.dart';

import '../../../constants/index.dart';

class DiscussSkeleton extends StatefulWidget {
  const DiscussSkeleton({Key key}) : super(key: key);
  DiscussSkeletonState createState() => DiscussSkeletonState();
}

class DiscussSkeletonState extends State<DiscussSkeleton>
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
      margin: EdgeInsets.symmetric(vertical: 16),
      height: 158,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.appBarBackground,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(16, 16, 16, 8),
            color: animation.value,
            height: 28,
            width: MediaQuery.of(context).size.width * 0.7,
          ),
          Container(
            margin: EdgeInsets.fromLTRB(16, 8, 16, 8),
            color: animation.value,
            height: 28,
            width: MediaQuery.of(context).size.width * 0.9,
          ),
          Container(
            margin: EdgeInsets.fromLTRB(16, 8, 16, 16),
            color: animation.value,
            height: 28,
            width: MediaQuery.of(context).size.width * 0.8,
          ),
        ],
      ),
    );
  }
}
