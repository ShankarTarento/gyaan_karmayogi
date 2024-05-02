import 'package:flutter/material.dart';

import '../../../constants/index.dart';
import '../index.dart';

class HomeSkeletonPage extends StatefulWidget {
  const HomeSkeletonPage({Key key}) : super(key: key);
  HomeSkeletonPageState createState() => HomeSkeletonPageState();
}

class HomeSkeletonPageState extends State<HomeSkeletonPage>
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
    return Column(
      children: [
        Container(
          color: AppColors.appBarBackground,
          height: 90,
          width: double.infinity,
          child: ListView.separated(
            itemBuilder: (context, index) => TabSkeleton(
                iconHeight: 50,
                iconWidth: 50,
                radius: 60,
                color: animation.value),
            separatorBuilder: (context, index) => SizedBox(width: 4),
            itemCount: 6,
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
          ),
        ),
        Container(
            margin: EdgeInsets.all(16), child: MyacticitiesCardSkeleton()),
        Container(
          padding: EdgeInsets.fromLTRB(16, 16, 0, 10),
          color: AppColors.appBarBackground,
          height: 330,
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                ContainerSkeleton(
                    height: 25, width: 150, color: animation.value),
                ContainerSkeleton(
                    height: 25, width: 100, color: animation.value)
              ]),
              SizedBox(height: 8),
              Container(
                height: 270,
                child: ListView.separated(
                  itemBuilder: (context, index) =>
                      CourseCardSkeleton(color: animation.value),
                  separatorBuilder: (context, index) => SizedBox(width: 4),
                  itemCount: 2,
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
