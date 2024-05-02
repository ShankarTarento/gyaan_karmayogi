import 'dart:async';
import 'dart:convert';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:karmayogi_mobile/models/index.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../../../constants/_constants/telemetry_constants.dart';
import '../../../pages/_pages/toc/pages/services/toc_services.dart';
import '../../../pages/index.dart';
import './../../../widgets/index.dart';
// import './../../../../util/faderoute.dart';
import './../../../../constants/index.dart';
import './../../../../services/index.dart';
import './../../../../util/telemetry.dart';
import './../../../../util/telemetry_db_helper.dart';

class CourseVideoPlayer extends StatefulWidget {
  CourseVideoPlayer(
      {this.course,
      this.identifier,
      this.fileUrl,
      this.mimeType,
      this.updateProgress = false,
      this.currentProgress,
      this.status,
      this.batchId,
      this.parentAction,
      this.isPlatformWalkThrough = false,
      this.isFeatured = false,
      this.primaryCategory,
      this.parentCourseId,
      this.playNextResource});

  final String batchId;
  final course;
  final currentProgress;
  final String fileUrl;
  final String identifier;
  final bool isFeatured;
  final bool isPlatformWalkThrough;
  final String mimeType;
  final ValueChanged<Map> parentAction;
  final String primaryCategory;
  final int status;
  final bool updateProgress;
  final String parentCourseId;
  final ValueChanged<bool> playNextResource;

  @override
  _CourseVideoPlayerState createState() => _CourseVideoPlayerState();
}

class _CourseVideoPlayerState extends State<CourseVideoPlayer>
    with AutomaticKeepAliveClientMixin {
  List allEventsData = [];
  String departmentId;
  String deviceIdentifier;
  final LearnService learnService = LearnService();
  String messageIdentifier;
  String pageIdentifier;
  String pageUri;
  bool showLoader = true;
  bool showVideo = false, replayVideo = false, allowFullscreenFlag = true;
  var telemetryEventData;
  final TelemetryService telemetryService = TelemetryService();
  String telemetryType;
  String userId;
  String userSessionId;

  ChewieController _chewieController;

  int _currentProgress;
  String _identifier;
  ValueNotifier<bool> _playerStatus = ValueNotifier(false);
  int _progressStatus;
  int _start = 0;
  Timer _timer;
  VideoPlayerController _videoPlayerController1;
  ValueNotifier<bool> isVideoCompleted = ValueNotifier(false);
  ValueNotifier<bool> showResume = ValueNotifier(false);

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() async {
    super.dispose();
    _videoPlayerController1.dispose();
    // _videoPlayerController2.dispose();
    if (widget.updateProgress && !widget.isFeatured) {
      await _updateContentProgress(_identifier, _progressStatus);
    }
    if (_chewieController != null) {
      _chewieController.pause();
      _chewieController.dispose();
    }
    _triggerEndTelemetryData(widget.identifier);
  }

  @override
  void initState() {
    super.initState();
    _identifier = widget.identifier;
    _progressStatus = widget.status;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      initializePlayer();
    });

    _triggerTelemetryData();
  }

  @override
  void didUpdateWidget(CourseVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.identifier != widget.identifier) {
      _updateContentProgress(oldWidget.identifier, _progressStatus);
      _triggerEndTelemetryData(_identifier);
      _identifier = widget.identifier;
      _start = 0;
      _triggerTelemetryData();
      _progressStatus = widget.status;
      showLoader = true;
      if (_chewieController != null) {
        _chewieController.pause();
        _chewieController.dispose();
        _chewieController = null; // Reset chewie controller
      }
      if (_videoPlayerController1 != null) {
        _videoPlayerController1.pause();
        _videoPlayerController1.dispose();
        _videoPlayerController1 = null; // Reset video player controller
      }
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        initializePlayer();
      });
    }
  }

  Future<void> initializePlayer() async {
   replayVideo = false;
    if (widget.identifier != '' &&
        widget.currentProgress.toString() != '0' &&
        widget.status != 2) {
      _currentProgress = int.parse((widget.currentProgress).split('.').first);
    } else {
      _currentProgress = 0;
    }

    _videoPlayerController1 =
        VideoPlayerController.networkUrl(Uri.parse(widget.fileUrl));
    await Future.wait([
      _videoPlayerController1.initialize(),
    ]);
    initializeChewieController();
    _videoPlayerController1.seekTo(Duration(seconds: _currentProgress));
    setState(() {
      showLoader = false;
    });

    _videoPlayerController1.addListener(() {
      if (_videoPlayerController1.value.position ==
              _videoPlayerController1.value.duration &&
          widget.identifier == '' &&
          !showVideo) {
        setState(() {
          showVideo = true;
        });
      } else if (_videoPlayerController1.value.position ==
          _videoPlayerController1.value.duration) {
        _updateContentProgress(_identifier, _progressStatus);
        if (_chewieController.isFullScreen) {
          _chewieController.exitFullScreen();
        }

        if (!_playerStatus.value && !replayVideo) {
          isVideoCompleted.value = true;
          setState(() {
            allowFullscreenFlag = false;
            initializeChewieController();
          });
        }
      } else {
        if (_playerStatus.value != _videoPlayerController1.value.isPlaying) {
          replayVideo = false;
          if (_videoPlayerController1.value.isPlaying) {
            _generateInteractTelemetryData(widget.identifier,
                subType: TelemetrySubType.playButton);
          } else {
            _generateInteractTelemetryData(widget.identifier,
                subType: TelemetrySubType.pauseButton);
          }
        }
        _playerStatus.value = _videoPlayerController1.value.isPlaying;
      }
    });
  }

  void initializeChewieController() {
    _chewieController = ChewieController(
        deviceOrientationsOnEnterFullScreen: widget.isPlatformWalkThrough
            ? ([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
            : null,
        deviceOrientationsAfterFullScreen: [
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown
        ],
        videoPlayerController: _videoPlayerController1,
        autoPlay: widget.identifier == '' && !showVideo ? false : true,
        looping: false,
        showOptions: false,
        allowedScreenSleep: false,
        allowFullScreen: allowFullscreenFlag);
  }

  _triggerTelemetryData() {
    if ((_start == 0 && widget.course['batches'] != null)) {
      allEventsData = [];
      pageIdentifier = TelemetryPageIdentifier.videoPlayerPageId;
      telemetryType = TelemetryType.player;
      String assetFile =
          widget.fileUrl.contains(EMimeTypes.mp4) ? 'video' : 'audio';
      var batchId = widget.course['batches'] != null
          ? (widget.course['batches'].runtimeType == String
              ? jsonDecode(widget.course['batches'])[0]['batchId']
              : widget.course['batches'][0]['batchId'])
          : '';
      pageUri =
          'viewer/$assetFile/${widget.identifier}?primaryCategory=Learning%20Resource&collectionId=${widget.parentCourseId}&collectionType=Course&batchId=$batchId';
      _generateTelemetryData();
    }
    _startTimer();
  }

  void _startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        _start++;
      },
    );
  }

  void _generateTelemetryData() async {
    deviceIdentifier = await Telemetry.getDeviceIdentifier();
    userId = await Telemetry.getUserId(isPublic: widget.isFeatured);
    userSessionId = await Telemetry.generateUserSessionId();
    messageIdentifier = await Telemetry.generateUserSessionId();
    departmentId = await Telemetry.getUserDeptId(isPublic: widget.isFeatured);

    Map eventData1 = Telemetry.getStartTelemetryEvent(
        deviceIdentifier,
        userId,
        departmentId,
        pageIdentifier,
        userSessionId,
        messageIdentifier,
        telemetryType,
        pageUri,
        objectId: widget.identifier,
        objectType: widget.primaryCategory,
        env: TelemetryEnv.learn,
        isPublic: widget.isFeatured,
        l1: widget.parentCourseId);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData1);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap(),
        isPublic: widget.isFeatured);
    Map eventData2 = Telemetry.getImpressionTelemetryEvent(
        deviceIdentifier,
        userId,
        departmentId,
        pageIdentifier,
        userSessionId,
        messageIdentifier,
        telemetryType,
        pageUri,
        objectId: widget.identifier,
        objectType: widget.primaryCategory,
        env: TelemetryEnv.learn,
        isPublic: widget.isFeatured);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData2);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap(),
        isPublic: widget.isFeatured);
    allEventsData.add(eventData1);
    allEventsData.add(eventData2);
    // await telemetryService.triggerEvent(allEventsData);
  }

  void _generateInteractTelemetryData(String contentId,
      {String subType = ''}) async {
    Map eventData = Telemetry.getInteractTelemetryEvent(
        deviceIdentifier,
        userId,
        departmentId,
        pageIdentifier,
        userSessionId,
        messageIdentifier,
        contentId,
        subType,
        objectType: widget.primaryCategory,
        env: TelemetryEnv.learn,
        isPublic: widget.isFeatured);
    allEventsData.add(eventData);
  }

  _triggerEndTelemetryData(String identifier) async {
    if (widget.identifier != '' && widget.course['batches'] != null) {
      Map eventData = Telemetry.getEndTelemetryEvent(
          deviceIdentifier,
          userId,
          departmentId,
          pageIdentifier,
          userSessionId,
          messageIdentifier,
          _start,
          telemetryType,
          pageUri,
          {},
          objectId: identifier,
          objectType: widget.primaryCategory,
          env: TelemetryEnv.learn,
          isPublic: widget.isFeatured,
          l1: widget.parentCourseId);
      allEventsData.add(eventData);
      telemetryEventData =
          TelemetryEventModel(userId: userId, eventData: eventData);
      await TelemetryDbHelper.insertEvent(telemetryEventData.toMap(),
          isPublic: widget.isFeatured);
      _timer.cancel();
    }
  }

  Future<void> _updateContentProgress(
      String contentIdentifier, int progressStatus) async {
    if (widget.batchId != null && !widget.isFeatured && widget.status != 2) {
      List<String> current = [];
      double currentPosition = 0.0;
      double duration = 0.0;
      List position =
          _videoPlayerController1.value.position.toString().split(':');
      List totalTime =
          _videoPlayerController1.value.duration.toString().split(':');
      // print(totalTime);
      currentPosition = double.parse(position[0]) * 60 * 60 +
          double.parse(position[1]) * 60 +
          double.parse(position[2]);
      duration = double.parse(totalTime[0]) * 60 * 60 +
          double.parse(totalTime[1]) * 60 +
          double.parse(totalTime[2]);
      duration = duration == 0 ? 1 : duration;
      current.add(currentPosition.toString());
      String courseId = widget.parentCourseId;
      String batchId = widget.batchId;
      String contentId = contentIdentifier;
      int status = progressStatus != 2
          ? currentPosition == duration
              ? 2
              : 1
          : 2;
      String contentType = widget.fileUrl.split('.').last == 'mp3'
          ? EMimeTypes.mp3
          : EMimeTypes.mp4;
      var maxSize = duration;
      double completionPercentage = (currentPosition / duration) * 100;
      if (completionPercentage >= 99) {
        completionPercentage = 100;
        status = 2;
      }
      await learnService.updateContentProgress(courseId, batchId, contentId,
          status, contentType, current, maxSize, completionPercentage);
      Map data = {
        'identifier': contentId,
        'mimeType': EMimeTypes.mp4,
        'current': currentPosition.toString(),
        'completionPercentage': completionPercentage / 100
      };
      widget.parentAction(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TocServices>(builder: (context, tocServices, _) {
     return !showLoader
          ? Column(children: <Widget>[
              Expanded(
                child: Center(
                  child: _chewieController != null
                      ? Stack(
                          children: [
                            Chewie(
                              controller: _chewieController,
                            ),
                            ValueListenableBuilder(
                                valueListenable: isVideoCompleted,
                                builder: (context, value, child) {
                                  return value
                                      ? Center(
                                          child: SizedBox(
                                            height: MediaQuery.of(context)
                                                .size
                                                .height,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: ValueListenableBuilder(
                                                valueListenable: showResume,
                                                builder:
                                                    (context, isResume, child) {
                                                  _chewieController.pause();
                                                  return isResume
                                                      ? ReplayWidget(
                                                          onPressed: () {
                                                            replayVideo = true;
                                                            isVideoCompleted
                                                                .value = false;
                                                            showResume.value =
                                                                false;
                                                            resumePlayer();
                                                          },
                                                        )
                                                      : AutoplayNextResource(
                                                          clickedPlayNextResource:
                                                              () {
                                                            isVideoCompleted
                                                                .value = false;
                                                            showResume.value =
                                                                false;
                                                            widget
                                                                .playNextResource(
                                                                    value);
                                                          },
                                                          cancelTimer: () {
                                                            showResume.value =
                                                                true;
                                                          },
                                                        );
                                                }),
                                          ),
                                        )
                                      : Center();
                                })
                          ],
                        )
                      : PageLoader(),
                ),
              ),
            ])
          : PageLoader();
    });
  }

  resumePlayer() {
    setState(() {
      allowFullscreenFlag = true;
    });
    initializeChewieController();
    _videoPlayerController1.seekTo(Duration.zero);
    _videoPlayerController1.play();
    _chewieController.play();
  }
}
