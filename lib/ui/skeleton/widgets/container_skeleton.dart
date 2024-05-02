import 'package:flutter/material.dart';

import '../../../constants/index.dart';

class ContainerSkeleton extends StatelessWidget {
  final double height;
  final double width;
  final Color color;
  final double padding;
  final Widget child;
  final double radius;

  const ContainerSkeleton(
      {Key key,
      this.height,
      this.width,
      this.color = AppColors.grey04,
      this.child,
      this.padding = 0,
      this.radius = 8})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: width,
        height: height,
        padding: EdgeInsets.all(padding),
        child: child != null ? child : Center(),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(radius),
        ));
  }
}
