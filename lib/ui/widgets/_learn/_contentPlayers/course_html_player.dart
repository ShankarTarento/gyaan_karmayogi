import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:karmayogi_mobile/env/env.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/models/index.dart';
import 'package:webview_flutter/webview_flutter.dart' as Webview;
import 'package:flutter_inappwebview/flutter_inappwebview.dart' as InAppWebview;
import '../../../../constants/_constants/telemetry_constants.dart';
import './../../../../constants/index.dart';
import './../../../../services/index.dart';
import './../../../../util/telemetry.dart';
import './../../../../util/telemetry_db_helper.dart';

class CourseHtmlPlayer extends StatefulWidget {
  final course;
  final String identifier;
  final String url;
  final String batchId;
  final ValueChanged<bool> parentAction1;
  final ValueChanged<Map> parentAction2;
  final parentAction3;
  final bool isLearningResource;
  final bool isFeaturedCourse;
  final String streamingUrl;
  final String primaryCategory;
  final String initFile;
  final duration;
  final String parentCourseId;

  CourseHtmlPlayer(this.course, this.identifier, this.url, this.batchId,
      this.parentAction1, this.parentAction2,
      {this.isLearningResource = false,
      this.parentAction3,
      this.isFeaturedCourse = false,
      this.primaryCategory,
      this.streamingUrl,
      this.initFile,
      this.duration,
      this.parentCourseId});

  _CourseHtmlPlayerState createState() => _CourseHtmlPlayerState();
}

class _CourseHtmlPlayerState extends State<CourseHtmlPlayer> {
  final LearnService learnService = LearnService();
  final TelemetryService telemetryService = TelemetryService();
  Webview.WebViewController controller;
  InAppWebview.InAppWebViewController inAppWebviewcontroller;
  int startTime;
  // bool _fullScreen = false;
  String _initFile;
  String _identifier;
  List _identifiers = [];

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
  String deviceIdentifier;
  var telemetryEventData;

  final Completer<InAppWebview.InAppWebViewController> _inAppWebviewController =
      Completer<InAppWebview.InAppWebViewController>();
  final Completer<Webview.WebViewController> _webviewController =
      Completer<Webview.WebViewController>();

  void initState() {
    super.initState();
    _identifier = widget.identifier;
    if (widget.initFile != null) {
      _initFile = widget.initFile;
    } else {
      _initFile = 'index.html';
    }

    if (_start == 0) {
      pageIdentifier = TelemetryPageIdentifier.htmlPlayerPageId;
      telemetryType = TelemetryType.player;
      var batchId = widget.course['batches'] != null
          ? (widget.course['batches'].runtimeType == String
              ? jsonDecode(widget.course['batches'])
              : widget.course['batches'])[0]['batchId']
          : '';
      pageUri =
          'viewer/html/${widget.identifier}?primaryCategory=Learning%20Resource&collectionId=${widget.parentCourseId}&collectionType=Course&batchId=$batchId';
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
        objectId: widget.identifier,
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
        objectId: widget.identifier,
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

  generateUrl(oldUrl) {
    var chunk = oldUrl.split('/');
    String host = Env.host;
    String bucket = Env.bucket;
    var newChunk = host.split('/');
    var newLink = [];
    for (var i = 0; i < chunk.length; i += 1) {
      if (i == 2) {
        newLink.add(newChunk[i]);
      } else if (i == 3) {
        newLink.add(bucket.substring(1));
      } else {
        newLink.add(chunk[i]);
      }
    }
    String newUrl = newLink.join('/');
    return newUrl;
  }

  String _getContentEntryPage(url, identifier) {
    String entryPage;
    if (widget.streamingUrl != null &&
        widget.streamingUrl != '' &&
        widget.streamingUrl.contains('latest')) {
      entryPage = (Env.host +
          Env.bucket +
          '/content/html/' +
          identifier +
          '-latest/$_initFile?timestamp=\'' +
          DateTime.now().millisecondsSinceEpoch.toString());
    } else {
      if (widget.streamingUrl != null) {
        entryPage = generateUrl(widget.streamingUrl +
            '/$_initFile' +
            '?timestamp=\'' +
            DateTime.now().millisecondsSinceEpoch.toString());
      } else {
        entryPage = Env.host +
            Env.bucket +
            '/content/html/' +
            identifier +
            '-snapshot/$_initFile?timestamp=\'' +
            DateTime.now().millisecondsSinceEpoch.toString();
      }
    }
    // print('Entry page: ' + entryPage.toString());
    if (!widget.isFeaturedCourse) {
      _updateContentProgress();
    }
    return entryPage;
  }

  @override
  void dispose() async {
    super.dispose();
    if (!widget.isFeaturedCourse) {
      await _updateContentProgress();
    }
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
        objectId: widget.identifier,
        objectType: widget.primaryCategory,
        env: TelemetryEnv.learn,
        isPublic: widget.isFeaturedCourse,
        l1: widget.parentCourseId);
    allEventsData.add(eventData);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap(),
        isPublic: widget.isFeaturedCourse);
    // telemetryService.triggerEvent(allEventsData);
    _timer.cancel();
    // controller?.clearCache();
  }

  double getCompletionPercentage(courseinfo) {
    String values = courseinfo['duration'].substring(
        courseinfo['duration'].indexOf('-') + 1, courseinfo['duration'].length);
    int hour = 0;
    int min = 0;
    double percentage, completionPercentage;
    if (values.contains('h')) {
      hour = int.parse(values.substring(0, values.indexOf('h'))) * 60;
      values = values.substring(values.indexOf('h') + 1, values.length);
    }
    if (values.contains('m')) {
      min = int.parse(values.substring(0, values.indexOf('m')));
    }
    int courseDuration = (hour + min) * 60;
    DateTime time = DateTime.fromMillisecondsSinceEpoch(startTime);
    var diff = (DateTime.fromMillisecondsSinceEpoch(
                DateTime.now().millisecondsSinceEpoch)
            .difference(time))
        .inSeconds;
    percentage = (diff / courseDuration) * 100;

    //mark scorm progress as completed if course completion is more then 20%
    if ((double.parse(courseinfo['currentProgress'].toString()) * 100) > 20 ||
        percentage > 20) {
      return 100.0;
    }
    //mark scorm completion using current progress plus previous progress
    else if ((double.parse(courseinfo['currentProgress'].toString()) * 100) <
        20) {
      return completionPercentage =
          (double.parse(courseinfo['currentProgress'].toString()) * 100) +
              percentage;
    }

    // if (((double.parse(courseinfo['currentProgress'].toString()) * 100) > 20 &&
    //         percentage > 10) ||
    //     ((double.parse(courseinfo['currentProgress'].toString()) * 100) < 20)) {
    //   return completionPercentage =
    //       (double.parse(courseinfo['currentProgress'].toString()) * 100) +
    //           percentage;
    // }
    return double.parse(courseinfo['currentProgress'].toString()) * 100;
  }

  Future<void> _updateContentProgress() async {
    List<String> current = [];

    current.add(10.toString());
    String courseId = widget.parentCourseId;
    String batchId = widget.batchId;
    String contentId = widget.identifier;
    String contentType = EMimeTypes.externalLink;
    int status = 0;
    var maxSize = widget.course['duration'];
    double completionPercentage;
    if (widget.duration.runtimeType == List) {
      for (int i = 0; i < widget.duration.length; i++) {
        if (widget.duration[i].runtimeType == List) {
          for (int k = 0; k < widget.duration[i].length; k++) {
            if (widget.duration[i][k].runtimeType == List) {
              for (int index = 0;
                  index < widget.duration[i][k].length;
                  index++) {
                if (widget.duration[i][k][index]['identifier'] ==
                    widget.identifier) {
                  completionPercentage =
                      getCompletionPercentage(widget.duration[i][k][index]);
                  break;
                }
              }
            } else {
              if (widget.duration[i][k]['identifier'] == widget.identifier) {
                completionPercentage =
                    getCompletionPercentage(widget.duration[i][k]);
                break;
              }
            }
          }
        } else {
          if (widget.duration[i]['identifier'] == widget.identifier) {
            completionPercentage = getCompletionPercentage(widget.duration[i]);
            break;
          }
        }
      }
    } else {
      completionPercentage = getCompletionPercentage(widget.duration);
    }
    if (completionPercentage >= 80) {
      status = 2;
    } else if (completionPercentage > 0) {
      status = 1;
    }
    // double completionPercentage =
    //     status == 2 ? 100.0 : (_start / maxSize) * 100;
    await learnService.updateContentProgress(courseId, batchId, contentId,
        status, contentType, current, maxSize, completionPercentage);
    // print('response: ' + response.toString());
    Map data = {
      'identifier': contentId,
      'mimeType': contentType,
      'current': completionPercentage,
      'completionPercentage': completionPercentage
    };
    await widget.parentAction3(data);
  }

  @override
  Widget build(BuildContext context) {
    if (_identifier != widget.identifier) {
      controller.loadUrl(_getContentEntryPage(widget.url, widget.identifier));
      if (!_identifiers.contains(_identifier)) {
        Map data = {
          'identifier': _identifier,
          'surveyCompleted': 100.0,
          'completionPercentage': 100.0
        };
        if (!widget.isFeaturedCourse) {
          widget.parentAction2(data);
        }
      }
      _identifiers.add(_identifier);
    }
    return widget.identifier != null && widget.identifier != ''
        ? Platform.isAndroid
            ? newScromPlayer()
            : oldScromPlayer()
        : Center();
  }

  InAppWebView newScromPlayer() {
    return InAppWebview.InAppWebView(
      initialUrlRequest: URLRequest(
        url: Uri.parse(
          '${ApiUrl.baseUrl}/viewer/mobile/html/${widget.identifier}?embed=true${Platform.isIOS ? '&preview=true' : ''}',
        ),
      ),
      initialOptions: InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(
          javaScriptEnabled: true,
          transparentBackground: true,
        ),
        android: AndroidInAppWebViewOptions(
          useHybridComposition: true,
        ),
      ),
      onWebViewCreated: (webViewController) {
        inAppWebviewcontroller = webViewController;
        _inAppWebviewController.complete(webViewController);
      },
      onLoadStart: (controller, url) {
        startTime = DateTime.now().millisecondsSinceEpoch;
      },
    );
  }

  Stack oldScromPlayer() {
    return Stack(children: [
      Center(
          child: Webview.WebView(
        debuggingEnabled: true,
        initialUrl:
            '${ApiUrl.baseUrl}/viewer/mobile/html/${widget.identifier}?embed=true${Platform.isIOS ? '&preview=true' : ''}',
        javascriptMode: Webview.JavascriptMode.unrestricted,
        onWebViewCreated: (Webview.WebViewController webViewController) {
          // log('page created...');
          controller = webViewController;
          _webviewController.complete(webViewController);
        },
        gestureRecognizers: Set()
          ..add(
            Factory<VerticalDragGestureRecognizer>(
              () => VerticalDragGestureRecognizer(),
            ), // or null
          ),
        onPageStarted: (String url) async {
          startTime = DateTime.now().millisecondsSinceEpoch;
        },
        gestureNavigationEnabled: true,
        allowsInlineMediaPlayback: true,
        initialMediaPlaybackPolicy:
            Webview.AutoMediaPlaybackPolicy.always_allow,
        navigationDelegate: (Webview.NavigationRequest request) {
          return Webview.NavigationDecision.navigate;
        },
      )),
    ]);
  }
}
