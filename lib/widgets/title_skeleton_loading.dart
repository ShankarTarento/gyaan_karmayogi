import 'package:flutter/material.dart';
import 'package:gyaan_karmayogi_resource_list/utils/app_colors.dart';

class TitleSkeletonLoading extends StatefulWidget {
  const TitleSkeletonLoading({Key key}) : super(key: key);

  @override
  _TitleSkeletonLoadingState createState() => _TitleSkeletonLoadingState();
}

class _TitleSkeletonLoadingState extends State<TitleSkeletonLoading>
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
            begin: AppColors.grey08,
            end: AppColors.grey16,
          ),
        ),
        TweenSequenceItem(
          weight: 1.0,
          tween: ColorTween(
            begin: AppColors.grey08,
            end: AppColors.grey16,
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
    return Row(
      children: [
        Container(
          height: 30,
          width: MediaQuery.of(context).size.width / 2.2,
          decoration: BoxDecoration(
            color: animation.value,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Spacer(),
        Container(
          height: 30,
          width: MediaQuery.of(context).size.width / 4,
          decoration: BoxDecoration(
            color: animation.value,
            borderRadius: BorderRadius.circular(4),
          ),
        )
      ],
    );
  }
}
