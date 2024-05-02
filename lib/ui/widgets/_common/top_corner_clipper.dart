import 'package:flutter/material.dart';

class TopCornerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double radius = 20;

    Path path = Path()
      ..moveTo(0, radius)
      ..arcToPoint(
        Offset(radius, 0),
        radius: Radius.circular(radius),
        clockwise: false,
      )
      ..lineTo(size.width, 0)
      ..lineTo(size.width - 20, 0)
      ..arcToPoint(
        Offset(size.width, radius),
        radius: Radius.circular(radius),
        clockwise: false,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class TocTopCornerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double radius = 9;

    Path path = Path()
      ..moveTo(0, radius)
      ..arcToPoint(
        Offset(radius, 0),
        radius: Radius.circular(radius),
        clockwise: false,
      )
      ..lineTo(size.width, 0)
      ..lineTo(size.width - 9, 0)
      ..arcToPoint(
        Offset(size.width, radius),
        radius: Radius.circular(radius),
        clockwise: false,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
