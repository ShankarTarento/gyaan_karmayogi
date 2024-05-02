import 'package:flutter/material.dart';

import '../../../constants/index.dart';
import '../index.dart';

class TocAboutSkeletonPage extends StatefulWidget {
  const TocAboutSkeletonPage({Key key}) : super(key: key);
  TocAboutSkeletonPageState createState() => TocAboutSkeletonPageState();
}

class TocAboutSkeletonPageState extends State<TocAboutSkeletonPage>
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
            SizedBox(
              height:  30,
            ),
            TabOverviewIconSkeleton(color: animation.value),
            SizedBox(
              height:  30,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ContainerSkeleton(
                  height: 16,
                  width: MediaQuery.of(context).size.width * 0.2,
                  color: animation.value,
                ),
                SizedBox(height: 4),
                ContainerSkeleton(
                  height: 16,
                  width: MediaQuery.of(context).size.width,
                  color: animation.value,
                ),
                SizedBox(height: 4),
                ContainerSkeleton(
                  height: 16,
                  width: MediaQuery.of(context).size.width,
                  color: animation.value,
                ),
              ],
            ),
            SizedBox(
              height:  30,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ContainerSkeleton(
                  height: 16,
                  width: MediaQuery.of(context).size.width * 0.2,
                  color: animation.value,
                ),
                SizedBox(height: 4),
                ContainerSkeleton(
                  height: 16,
                  width: MediaQuery.of(context).size.width,
                  color: animation.value,
                ),
                SizedBox(height: 4),
                ContainerSkeleton(
                  height: 16,
                  width: MediaQuery.of(context).size.width,
                  color: animation.value,
                ),
              ],
            ),
            SizedBox(
              height:  30,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ContainerSkeleton(
                  height: 16,
                  width: MediaQuery.of(context).size.width * 0.25,
                  color: animation.value,
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    ContainerSkeleton(
                      height: 16,
                      width: MediaQuery.of(context).size.width * 0.2,
                      color: animation.value,
                    ),
                    SizedBox(width: 4),
                    ContainerSkeleton(
                      height: 16,
                      width: MediaQuery.of(context).size.width * 0.2,
                      color: animation.value,
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Container(
                  height: 90,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 2,
                    itemBuilder: (context, index) {
                      return ContainerSkeleton(
                        height: 84,
                        width: MediaQuery.of(context).size.width * 0.8,
                        color: animation.value,
                      );
                    },
                  ),
                ),
              ],
            ),
            SizedBox(
              height:  30,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ContainerSkeleton(
                  height: 16,
                  width: MediaQuery.of(context).size.width * 0.15,
                  color: animation.value,
                ),
                SizedBox(height: 4),
                ContainerSkeleton(
                  height: 16,
                  width: MediaQuery.of(context).size.width,
                  color: animation.value,
                ),
                SizedBox(height: 4),
                ContainerSkeleton(
                  height: 16,
                  width: MediaQuery.of(context).size.width,
                  color: animation.value,
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 2,
                itemBuilder: (context, index) {
                  return ContainerSkeleton(
                    height: 64,
                    width: MediaQuery.of(context).size.width * 0.8,
                    color: animation.value,
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            ContainerSkeleton(
              height: 16,
              width: MediaQuery.of(context).size.width,
              color: animation.value,
            ),
            SizedBox(height: 8),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: animation.value,
                  radius: 16,
                ),
                SizedBox(width: 4),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ContainerSkeleton(
                      height: 16,
                      width: MediaQuery.of(context).size.width * 0.4,
                      color: animation.value,
                    ),
                    SizedBox(height: 4),
                    ContainerSkeleton(
                      height: 16,
                      width: MediaQuery.of(context).size.width * 0.15,
                      color: animation.value,
                    ),
                  ],
                )
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: animation.value,
                  radius: 16,
                ),
                SizedBox(width: 4),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ContainerSkeleton(
                      height: 16,
                      width: MediaQuery.of(context).size.width * 0.4,
                      color: animation.value,
                    ),
                    SizedBox(height: 4),
                    ContainerSkeleton(
                      height: 16,
                      width: MediaQuery.of(context).size.width * 0.15,
                      color: animation.value,
                    ),
                  ],
                )
              ],
            ),
            SizedBox(height: 8),
            ContainerSkeleton(
              height: 150,
              width: MediaQuery.of(context).size.width,
              color: animation.value,
            ),
          ],
        ),
      ),
    );
  }
}
