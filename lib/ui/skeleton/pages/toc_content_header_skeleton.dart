import 'package:flutter/material.dart';

import '../../../constants/index.dart';
import '../index.dart';

class TocContentHeaderSkeletonPage extends StatefulWidget {
  const TocContentHeaderSkeletonPage({Key key}) : super(key: key);
  TocContentHeaderSkeletonPageState createState() =>
      TocContentHeaderSkeletonPageState();
}

class TocContentHeaderSkeletonPageState
    extends State<TocContentHeaderSkeletonPage>
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
            begin: AppColors.white016,
            end: AppColors.white,
          ),
        ),
        TweenSequenceItem(
          weight: 1.0,
          tween: ColorTween(begin: AppColors.white016, end: AppColors.white),
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
      color: AppColors.darkBlue,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ContainerSkeleton(
                height: 16,
                width: MediaQuery.of(context).size.width * 0.2,
              ),
              SizedBox(height: 18),
              ContainerSkeleton(
                height: 16,
                width: MediaQuery.of(context).size.width * 0.7,
              ),
              SizedBox(height: 18),
              ContainerSkeleton(
                height: 16,
                width: MediaQuery.of(context).size.width * 0.5,
              ),
              SizedBox(height: 18),
              ContainerSkeleton(
                height: 16,
                width: MediaQuery.of(context).size.width * 0.6,
              ),
              SizedBox(height: 18),
              Row(
                children: [
                  ContainerSkeleton(
                    height: 27,
                    width: MediaQuery.of(context).size.width * 0.2,
                  ),
                  SizedBox(width: 4),
                  ContainerSkeleton(
                    height: 16,
                    width: MediaQuery.of(context).size.width * 0.15,
                  ),
                ],
              ),
              SizedBox(height: 18),
              ContainerSkeleton(
                height: 16,
                width: MediaQuery.of(context).size.width * 0.4,
              ),
              SizedBox(height: 18),
            ]),
      ),
    );
  }
}
