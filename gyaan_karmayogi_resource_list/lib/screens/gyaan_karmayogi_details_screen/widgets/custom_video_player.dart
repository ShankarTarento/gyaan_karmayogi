import 'dart:async';

import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:gyaan_karmayogi_resource_list/data_models/gyaan_karmayogi_resource_details.dart';
import 'package:video_player/video_player.dart';

import '../../../widgets/video_player_skeleton_loading.dart';

class CustomVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final ResourceDetails resourceDetails;
  final bool isAudio;
  final Function(Map<String, dynamic> data) contentStartTelemetry;
  final Function(Map<String, dynamic> data) contentEndTelemetry;

  const CustomVideoPlayer({
    Key key,
    @required this.resourceDetails,
    @required this.videoUrl,
    @required this.isAudio,
    @required this.contentEndTelemetry,
    @required this.contentStartTelemetry,
  }) : super(key: key);

  @override
  _CustomVideoPlayerState createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  VideoPlayerController _videoPlayerController;
  ChewieController _chewieController;
  bool _isVideoEnded = false;
  bool _isVideoLoading = true;
  bool _isVideoPlaying = false;
  int _start = 0;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.network(widget.videoUrl)
      ..addListener(_videoListener)
      ..initialize().then((_) {
        setState(() {
          _isVideoLoading = false;
        });
      });
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: false,
      looping: false,
      aspectRatio: 16 / 9,
      autoInitialize: true,
      allowPlaybackSpeedChanging: false,
      showOptions: false,
      showControls: true,
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(
            errorMessage,
            style: TextStyle(color: Colors.white),
          ),
        );
      },
    );
    triggerTelemetryEvent();
  }

  String pageUri;
  triggerTelemetryEvent() {
    if (_start == 0) {
      pageUri =
          'viewer/pdf/${widget.resourceDetails.identifier}?primaryCategory=Learning%20Resource&collectionId=${widget.resourceDetails.identifier}&collectionType=Course&batchId=';
      widget.contentStartTelemetry({"pageUri": pageUri});
    }

    _startTimer();
  }

  void _startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        _start++;
      },
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    _timer.cancel();
    super.dispose();
    widget.contentEndTelemetry({"pageUri": pageUri, "time": _start});
  }

  void _videoListener() {
    if (_videoPlayerController.value.position ==
        _videoPlayerController.value.duration) {
      setState(() {
        _isVideoEnded = true;
      });
    } else {
      setState(() {
        _isVideoEnded = false;
      });
    }
  }

  void _replayVideo() {
    setState(() {
      _isVideoEnded = false;
      _videoPlayerController.seekTo(Duration.zero);
      _videoPlayerController.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    print("------------------${widget.videoUrl}");
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: widget.isAudio ? Colors.black : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      width: MediaQuery.of(context).size.width,
      child: _isVideoLoading
          ? const VideoPlayerSkeleton()
          : Chewie(
              controller: _chewieController,
            ),
    );
  }
}
