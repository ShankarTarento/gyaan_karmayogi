import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class VegaYoutubePlayer extends StatefulWidget {
  final String url;
  const VegaYoutubePlayer({Key key, this.url}) : super(key: key);

  @override
  State<VegaYoutubePlayer> createState() => _VegaYoutubePlayerState();
}

class _VegaYoutubePlayerState extends State<VegaYoutubePlayer> {
  YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: YoutubePlayerController.convertUrlToId(widget.url),
      autoPlay: true,
      startSeconds: 0,
      params: const YoutubePlayerParams(showFullscreenButton: true),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4)),
        side: BorderSide(
          color: AppColors.grey08,
        ),
      ),
      shadowColor: Colors.black.withOpacity(0.5),
      elevation: 5,
      color: Colors.white,
      child: YoutubePlayer(
        controller: _controller,
        aspectRatio: 16 / 9,
        enableFullScreenOnVerticalDrag: false,
      ),
    );
  }
}
