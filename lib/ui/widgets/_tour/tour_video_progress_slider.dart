import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoProgressSlider extends StatelessWidget {
  const VideoProgressSlider({
    @required this.position,
    @required this.duration,
    @required this.controller,
    @required this.swatch,
  });

  final VideoPlayerController controller;
  final Duration position;
  final Duration duration;
  final Color swatch;

  @override
  Widget build(BuildContext context) {
    final max = duration.inMilliseconds.toDouble();
    final value = position.inMilliseconds.clamp(0, max).toDouble();
    return Theme(
      data: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(seedColor: swatch),
        useMaterial3: true,
      ),
      child: Slider(
        min: 0,
        max: max,
        value: value,
        onChanged: (value) =>
            controller.seekTo(Duration(milliseconds: value.toInt())),
      ),
    );
  }
}
