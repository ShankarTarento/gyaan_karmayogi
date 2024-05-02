import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';

import '../index.dart';

class CourseProgressSkeletonPage extends StatefulWidget {
  const CourseProgressSkeletonPage({Key key}) : super(key: key);

  @override
  _CourseProgressSkeletonPageState createState() =>
      _CourseProgressSkeletonPageState();
}

class _CourseProgressSkeletonPageState extends State<CourseProgressSkeletonPage>
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
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Container(
          margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.grey16, width: 1),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ContainerSkeleton(
                              width: 107, height: 72, color: animation.value),
                          Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Column(
                              children: [
                                ContainerSkeleton(
                                    width: 170,
                                    height: 20,
                                    color: animation.value),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    ContainerSkeleton(
                                      height: 24,
                                      width: 24,
                                      color: animation.value,
                                    ),
                                    SizedBox(width: 4),
                                    ContainerSkeleton(
                                        height: 20,
                                        width: 130,
                                        color: animation.value)
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          children: [
                            Container(
                                width: 100, height: 20, color: animation.value),
                            Spacer(),
                            Container(
                                width: 100, height: 20, color: animation.value),
                          ],
                        ),
                      ),
                      Container(
                          margin: EdgeInsets.only(top: 16),
                          width: MediaQuery.of(context).size.width,
                          height: 40,
                          color: animation.value)
                    ]),
              )
            ],
          )),
    );
  }
}
