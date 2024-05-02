import 'package:flutter/material.dart';

import '../../../constants/index.dart';
import '../index.dart';

class MyacticitiesCardSkeleton extends StatelessWidget {
  final Color color;
  const MyacticitiesCardSkeleton({Key key, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          height: 200,
          decoration: BoxDecoration(
              color: AppColors.appBarBackground,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: ContainerSkeleton(
                  height: 24,
                  width: 200,
                  color: color,
                ),
              ),
              SizedBox(height: 4),
              Divider(
                thickness: 1,
                color: color,
              ),
              SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TabSkeleton(
                      iconHeight: 24, iconWidth: 24, radius: 4, color: color),
                  TabSkeleton(
                      iconHeight: 24, iconWidth: 24, radius: 4, color: color),
                  TabSkeleton(
                      iconHeight: 24, iconWidth: 24, radius: 4, color: color),
                ],
              ),
              Divider(
                thickness: 1,
                color: color,
              ),
              SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ContainerSkeleton(
                    height: 25,
                    width: 150,
                    color: color,
                  ),
                  ContainerSkeleton(
                    height: 25,
                    width: 100,
                    color: color,
                  )
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
          decoration: BoxDecoration(
              color: AppColors.grey08,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  ContainerSkeleton(
                    height: 24,
                    width: 24,
                    color: color,
                  ),
                  SizedBox(width: 8),
                  ContainerSkeleton(
                    height: 25,
                    width: 150,
                    color: color,
                  ),
                ],
              ),
              ContainerSkeleton(
                height: 24,
                width: 24,
                color: color,
              )
            ],
          ),
        )
      ],
    );
  }
}
