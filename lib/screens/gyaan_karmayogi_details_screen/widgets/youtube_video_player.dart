import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../data_models/gyaan_karmayogi_resource_details.dart';
import '../../../utils/app_colors.dart';

class YouTubePlayerWidget extends StatefulWidget {
  final String videoUrl;
  final ResourceDetails resourceDetails;
  final Function(Map<String, dynamic> data) contentStartTelemetry;
  final Function(Map<String, dynamic> data) contentEndTelemetry;

  const YouTubePlayerWidget({
    Key key,
    @required this.videoUrl,
    @required this.resourceDetails,
    @required this.contentEndTelemetry,
    @required this.contentStartTelemetry,
  }) : super(key: key);

  @override
  _YouTubePlayerWidgetState createState() => _YouTubePlayerWidgetState();
}

class _YouTubePlayerWidgetState extends State<YouTubePlayerWidget> {
  YoutubePlayerController _controller;

  bool _fullScreen = false;

  Orientation screenOrientation;
  int _start = 0;
  Timer _timer;

  @override
  void initState() {
    super.initState();

    _controller = YoutubePlayerController.fromVideoId(
      videoId: YoutubePlayerController.convertUrlToId(widget.videoUrl),
      autoPlay: true,
      startSeconds: 0,
      params: const YoutubePlayerParams(showFullscreenButton: true),
    );

    _controller.listen(
      (event) async {
        if (event.fullScreenOption.enabled) {
          // developer.log("Entered full screen....");
          await _setLandscape();
        } else if (event.fullScreenOption.locked) {
          await _setAllOrientation();
        }
      },
    );
    triggerTelemetryEvent();
  }

  String pageUri;
  triggerTelemetryEvent() {
    if (_start == 0) {
      pageUri =
          'viewer/youtube/${widget.resourceDetails.identifier}?primaryCategory=Learning%20Resource&collectionId=${widget.resourceDetails.identifier}&collectionType=Course&batchId=';
      widget.contentStartTelemetry({"pageUri": pageUri});
    }

    _startTimer();
  }

  void _startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        _start++;
      },
    );
  }

  _setLandscape() async {
    await SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    setState(() {
      _fullScreen = true;
    });
  }

  _setAllOrientation({bool isFromDisposeFunction = false}) async {
    // await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge,
    //     overlays: []);
    await SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
    if (!isFromDisposeFunction) {
      setState(() {
        _fullScreen = true;
      });
    }
  }

  @override
  void dispose() async {
    super.dispose();
    await _setAllOrientation(isFromDisposeFunction: true);
    try {
      _controller.close();
    } catch (e) {
      print(e);
    }
    widget.contentEndTelemetry({"pageUri": pageUri, "time": _start});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (screenOrientation == Orientation.landscape) {
          _controller.exitFullScreen();
        } else {
          Navigator.pop(context);
        }
        return false;
      },
      child: OrientationBuilder(
          builder: (BuildContext context, Orientation orientation) {
        screenOrientation = orientation;
        return Scaffold(
            backgroundColor: Colors.black,
            body: SafeArea(
              child: NestedScrollView(
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverAppBar(
                        backgroundColor: Colors.transparent,
                        pinned: false,
                        automaticallyImplyLeading: false,
                        // expandedHeight: 112,
                        flexibleSpace: InkWell(
                          onTap: () async {
                            if (orientation == Orientation.landscape) {
                              _controller.exitFullScreen();
                            } else {
                              Navigator.pop(context);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 16, left: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Padding(
                                  padding: const EdgeInsets.only(right: 16),
                                  child: Icon(
                                    Icons.arrow_back,
                                    color: AppColors.white70,
                                  ),
                                ),
                                Text(
                                  "Back",
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.lato(
                                    color: AppColors.white70,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                  ];
                },
                body: Center(
                  child: Container(
                    width: double.infinity,
                    child: YoutubePlayer(
                      controller: _controller,
                      aspectRatio: 9 / 16,
                    ),
                  ),
                ),
              ),
            ));
      }),
    );
  }
}
