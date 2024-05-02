import 'dart:async';
import 'dart:convert';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/util/telemetry.dart';
import 'package:karmayogi_mobile/util/telemetry_db_helper.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../../../constants/_constants/app_constants.dart';
import '../../../../constants/_constants/telemetry_constants.dart';
import '../../../../models/_models/telemetry_event_model.dart';
import '../../../../services/_services/learn_service.dart';
import '../../../pages/_pages/learn/course_video_assessment.dart';
import '../../../pages/_pages/toc/pages/services/toc_services.dart';
import './../../../widgets/index.dart';

class CourseAudioPlayer extends StatefulWidget {
  final String identifier;
  final String fileUrl;
  final String batchId;
  final int status;
  final bool updateProgress;
  final course;
  final ValueChanged<Map> parentAction;
  final bool isFeaturedCourse;
  final String primaryCategory;
  final String parentCourseId;
  final currentProgress;
  CourseAudioPlayer(
      {this.identifier,
      this.fileUrl,
      this.batchId,
      this.course,
      this.status,
      this.updateProgress,
      this.parentAction,
      this.isFeaturedCourse = false,
      this.primaryCategory,
      this.parentCourseId,
      this.currentProgress});
  @override
  _CourseAudioPlayerState createState() => _CourseAudioPlayerState();
}

class _CourseAudioPlayerState extends State<CourseAudioPlayer> {
  VideoPlayerController _videoPlayerController1;
  // VideoPlayerController _videoPlayerController2;
  final LearnService learnService = LearnService();
  ChewieController _chewieController;
  String _identifier;
  int _progressStatus;

  bool showVideo = false;

  String userId;
  String userSessionId;
  String messageIdentifier;
  String departmentId;
  Timer _timer;
  int _start = 0;
  String pageIdentifier;
  String telemetryType;
  String pageUri;
  List allEventsData = [];
  bool _playerStatus = false, replayVideo = false;
  String deviceIdentifier;
  var telemetryEventData;
  int _currentProgress;

  @override
  void initState() {
    super.initState();
    _identifier = widget.parentCourseId;
    _progressStatus = widget.status;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      initializePlayer();
    });
    _triggerTelemetryEvent();
  }

  _triggerTelemetryEvent() {
    if ((_start == 0 && widget.course['batches'] != null)) {
      allEventsData = [];
      pageIdentifier = TelemetryPageIdentifier.audioPlayerPageId;
      telemetryType = TelemetryType.player;
      String assetFile =
          widget.fileUrl.contains(EMimeTypes.mp4) ? 'video' : 'audio';
      var batchId = widget.course['batches'] != null
          ? (widget.course['batches'].runtimeType == String
              ? jsonDecode(widget.course['batches'])[0]['batchId']
              : widget.course['batches'][0]['batchId'])
          : '';
      pageUri =
          'viewer/$assetFile/${widget.parentCourseId}?primaryCategory=Learning%20Resource&collectionId=${widget.parentCourseId}&collectionType=Course&batchId=$batchId';
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
    userId = await Telemetry.getUserId(isPublic: widget.isFeaturedCourse);
    userSessionId = await Telemetry.generateUserSessionId();
    messageIdentifier = await Telemetry.generateUserSessionId();
    departmentId =
        await Telemetry.getUserDeptId(isPublic: widget.isFeaturedCourse);

    Map eventData1 = Telemetry.getStartTelemetryEvent(
        deviceIdentifier,
        userId,
        departmentId,
        pageIdentifier,
        userSessionId,
        messageIdentifier,
        telemetryType,
        pageUri,
        objectId: widget.parentCourseId,
        objectType: widget.primaryCategory,
        env: TelemetryEnv.learn,
        isPublic: widget.isFeaturedCourse,
        l1: widget.parentCourseId);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData1);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap(),
        isPublic: widget.isFeaturedCourse);
    Map eventData2 = Telemetry.getImpressionTelemetryEvent(
        deviceIdentifier,
        userId,
        departmentId,
        pageIdentifier,
        userSessionId,
        messageIdentifier,
        telemetryType,
        pageUri,
        env: TelemetryEnv.learn,
        objectId: widget.parentCourseId,
        objectType: widget.primaryCategory,
        isPublic: widget.isFeaturedCourse);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData2);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap(),
        isPublic: widget.isFeaturedCourse);
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
        env: TelemetryEnv.learn,
        objectType: widget.primaryCategory,
        isPublic: widget.isFeaturedCourse);
    allEventsData.add(eventData);
  }

  _triggerEndTelemetryEvent(String identifier) async {
    if (widget.parentCourseId != '' && widget.course['batches'] != null) {
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
          env: TelemetryEnv.learn,
          objectId: identifier,
          objectType: widget.primaryCategory,
          isPublic: widget.isFeaturedCourse,
          l1: widget.parentCourseId);
      allEventsData.add(eventData);
      telemetryEventData =
          TelemetryEventModel(userId: userId, eventData: eventData);
      await TelemetryDbHelper.insertEvent(telemetryEventData.toMap(),
          isPublic: widget.isFeaturedCourse);
      // telemetryService.triggerEvent(allEventsData);
      _timer.cancel();
    }
  }

  @override
  void dispose() async {
    super.dispose();
    if (widget.updateProgress && !widget.isFeaturedCourse) {
     await _updateContentProgress(_identifier, _progressStatus);
    }
    _videoPlayerController1?.dispose();
    _chewieController?.dispose();
    _triggerEndTelemetryEvent(widget.parentCourseId);
  }

  @override
  void didUpdateWidget(CourseAudioPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.identifier != widget.identifier) {
      _triggerEndTelemetryEvent(oldWidget.identifier);
      _updateContentProgress(oldWidget.identifier, _progressStatus);
      _identifier = widget.parentCourseId;
      _start = 0;
      _triggerTelemetryEvent();
      _progressStatus = widget.status;
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
      initializePlayer();
    }
  }

  Future<void> initializePlayer() async {
    replayVideo = false;
    if (widget.identifier != '' && widget.currentProgress.toString() != '0') {
      _currentProgress = int.parse((widget.currentProgress).split('.').first);
    } else {
      _currentProgress = 0;
    }
    _videoPlayerController1 =
        VideoPlayerController.networkUrl(Uri.parse(widget.fileUrl));
    await Future.wait([
      _videoPlayerController1.initialize(),
    ]);
    _videoPlayerController1.seekTo(Duration(seconds: _currentProgress));

    _videoPlayerController1.addListener(() {
      if (_videoPlayerController1.value.position ==
              _videoPlayerController1.value.duration &&
          widget.parentCourseId == '' &&
          !showVideo) {
        setState(() {
          showVideo = true;
        });
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CourseVideoAssessment()),
        );
      } else {
        if (_playerStatus != _videoPlayerController1.value.isPlaying) {
          if (_videoPlayerController1.value.isPlaying) {
            _generateInteractTelemetryData(widget.parentCourseId,
                subType: TelemetrySubType.playButton);
          } else {
            _generateInteractTelemetryData(widget.parentCourseId,
                subType: TelemetrySubType.pauseButton);
          }
        }
        _playerStatus = _videoPlayerController1.value.isPlaying;
      }
    });

    _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController1,
        autoPlay: true,
        looping: false,
        showOptions: false,
        allowFullScreen: false);
    setState(() {});
  }

  Future<void> _updateContentProgress(
      String contentIdentifier, int progressStatus) async {
    if (widget.batchId != null && !widget.isFeaturedCourse) {
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
      current.add(currentPosition.toString());
      String courseId = widget.parentCourseId;
      String batchId = widget.batchId;
      String contentId =
          widget.identifier != null ? widget.identifier : contentIdentifier;
      int status = progressStatus != 2
          ? currentPosition == duration
              ? 2
              : 1
          : 2;
      String contentType = EMimeTypes.mp3;
      var maxSize = duration;
      if (duration != 0) {
        double completionPercentage = (currentPosition / duration) * 100;
        if (completionPercentage >= 99) {
          completionPercentage = 100;
          status = 2;
        }
        await learnService.updateContentProgress(courseId, batchId, contentId,
            status, contentType, current, maxSize, completionPercentage);
        Map data = {
          'identifier': contentId,
          'mimeType': EMimeTypes.mp3,
          'current': currentPosition.toString(),
          'completionPercentage': completionPercentage / 100
        };
        widget.parentAction(data);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TocServices>(builder: (context, tocServices, _) {
      return Column(children: <Widget>[
        Expanded(
          child: Center(
            child: _chewieController != null
                ? Chewie(
                    controller: _chewieController,
                  )
                : PageLoader(),
          ),
        ),
      ]);
    });
  }
}
