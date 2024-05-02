import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/ui/skeleton/index.dart';

import '../../../constants/index.dart';

class CourseCardSkeleton extends StatelessWidget {
  final Color color;

  const CourseCardSkeleton({Key key, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(right: 8),
        height: 250,
        width: MediaQuery.of(context).size.width * 0.7,
        decoration: BoxDecoration(
            color: AppColors.grey08, borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ContainerSkeleton(
              height: 135,
              width: MediaQuery.of(context).size.width,
              color: color,
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ContainerSkeleton(height: 25, width: 150, color: color),
            ),
            SizedBox(height: 8),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ContainerSkeleton(
                  height: 25,
                  width: 200,
                  color: color,
                )),
            SizedBox(height: 8),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(children: [
                  ContainerSkeleton(
                    height: 25,
                    width: 25,
                    color: color,
                  ),
                  SizedBox(width: 4),
                  ContainerSkeleton(
                    height: 25,
                    width: 150,
                    color: color,
                  )
                ])),
            SizedBox(height: 8),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ContainerSkeleton(
                  height: 25,
                  width: 150,
                  color: color,
                ))
          ],
        ));
  }
}
