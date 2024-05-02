import 'package:flutter/material.dart';

import '../../../constants/index.dart';
import '../index.dart';

class CardSkeletonPage extends StatefulWidget {
  final double height, width;
  const CardSkeletonPage({Key key, @required this.height, @required this.width})
      : super(key: key);
  CardSkeletonPageState createState() => CardSkeletonPageState();
}

class CardSkeletonPageState extends State<CardSkeletonPage>
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
      child: ContainerSkeleton(
          height: widget.height, width: widget.width, color: animation.value),
    );
  }
}
