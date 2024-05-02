import 'package:flutter/material.dart';

class BottomCornerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double radius = 20;

    Path path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height - 20)
      ..arcToPoint(
        Offset(size.width - 20, size.height),
        radius: Radius.circular(radius),
        clockwise: false,
      )
      ..lineTo(size.width - radius, size.height)
      ..lineTo(radius, size.height)
      ..arcToPoint(
        Offset(0, size.height - 20),
        radius: Radius.circular(radius),
        clockwise: false,
      )
      ..lineTo(0, size.height - 20);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class TocBottomCornerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double radius = 9;

    Path path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height - 9)
      ..arcToPoint(
        Offset(size.width - 9, size.height),
        radius: Radius.circular(radius),
        clockwise: false,
      )
      ..lineTo(size.width - radius, size.height)
      ..lineTo(radius, size.height)
      ..arcToPoint(
        Offset(0, size.height - 9),
        radius: Radius.circular(radius),
        clockwise: false,
      )
      ..lineTo(0, size.height - 9);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
