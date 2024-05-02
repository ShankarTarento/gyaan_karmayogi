import 'package:flutter/material.dart';

class DisplayWidgetWithDuration extends StatefulWidget {
  final Duration duration;
  final Widget child;

  DisplayWidgetWithDuration({@required this.duration, @required this.child});

  @override
  _DisplayWidgetWithDurationState createState() => _DisplayWidgetWithDurationState();
}

class _DisplayWidgetWithDurationState
    extends State<DisplayWidgetWithDuration>
    with SingleTickerProviderStateMixin {
   AnimationController _controller;
   Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(Duration(seconds: 2), () {
          _controller.reverse();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Visibility(
            visible: _animation.value > 0,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}