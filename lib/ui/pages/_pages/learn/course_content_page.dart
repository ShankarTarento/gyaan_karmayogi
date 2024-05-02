// import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:karmayogi_mobile/feedback/pages/_pages/_cbpSurvey/content_feedback.dart';
import 'package:karmayogi_mobile/localization/index.dart';
import 'package:karmayogi_mobile/models/index.dart';
import '../../../../constants/_constants/telemetry_constants.dart';
import '../../../widgets/certificate.dart';
import './../../../../util/helper.dart';
import './../../../../services/index.dart';
// import './../../../../ui/pages/index.dart';
// import './../../../../util/faderoute.dart';
import './../../../../constants/index.dart';
import './../../../../ui/widgets/index.dart';
import './../../../../util/telemetry.dart';
import './../../../../util/telemetry_db_helper.dart';
// import 'dart:developer' as developer;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CourseContentPage extends StatefulWidget {
  final course;
  final bool isContinueLearning;
  final String batchId;
  final contentProgress;
  final ValueChanged<String> parentAction;
  final bool isFeatured;
  final bool isBlendedProgram;
  final List<Course> enrollmentList;
  final bool isProgram;
  final String identifier;

  CourseContentPage(
      {this.course,
      this.isContinueLearning = false,
      this.batchId,
      this.contentProgress,
      this.parentAction,
      this.isFeatured = false,
      this.isBlendedProgram = false,
      this.enrollmentList,
      this.isProgram = false,
      this.identifier});

  @override
  _CourseContentPageState createState() => _CourseContentPageState();
}

class _CourseContentPageState extends State<CourseContentPage> {
  final LearnService learnService = LearnService();
  final TelemetryService telemetryService = TelemetryService();
  List navigationItems = [];
  double progress = 0.0;
  var contentProgress = Map();
  var _contentProgressResponse;

  String userId;
  String userSessionId;
  String messageIdentifier;
  String departmentId;
  String pageIdentifier;
  String deviceIdentifier;
  List<Map> showCertificate = [];
  var telemetryEventData;
  bool isCuratedProgram = false;
  bool showCertificateIcon = false;
  bool showProgress = false;

  @override
  void initState() {
    super.initState();
    if (widget.course['cumulativeTracking'] != null) {
      if (widget.course['cumulativeTracking']) {
        isCuratedProgram = true;
      }

      if (isCuratedProgram) {
        // if (widget.course['children'] != null) {
        //   for (int index = 0;
        //       index < widget.course['children'].length;
        //       index++) {
        if (widget.enrollmentList != null) {
          widget.enrollmentList.forEach((course) async {
            if (course.raw['courseId'] == widget.identifier) {
              showCertificateIcon = true;
            }
          });
        }
        //   }
        // }
      }
    }
    if (widget.course['primaryCategory'] != EnglishLang.program &&
        !isCuratedProgram) {
      showProgress = true;
    } else if (isCuratedProgram && showCertificateIcon) {
      showProgress = true;
    } else if (widget.isProgram) {
      showProgress = true;
    }
    _generateNavigation();
    if (widget.batchId != null && !widget.isFeatured) {
      _readCourseContentProgress(
          true, widget.course['identifier'], widget.batchId);
    }
    if (isCuratedProgram) {
      if (widget.course['children'] != null) {
        for (int index = 0; index < widget.course['children'].length; index++) {
          if (widget.enrollmentList != null) {
            widget.enrollmentList.forEach((course) async {
              if (course.raw['courseId'] ==
                  widget.course['children'][index]['identifier']) {
                await _readCourseContentProgress(true, course.raw['courseId'],
                    course.raw['batch']['batchId']);
              }
            });
          }
        }
      }
    }
    _generateTelemetryData();
  }

  void _generateTelemetryData() async {
    deviceIdentifier = await Telemetry.getDeviceIdentifier();
    userId = await Telemetry.getUserId(isPublic: widget.isFeatured);
    userSessionId = await Telemetry.generateUserSessionId();
    messageIdentifier = await Telemetry.generateUserSessionId();
    departmentId = await Telemetry.getUserDeptId(isPublic: widget.isFeatured);
    String pageUri = (!widget.isFeatured
            ? TelemetryPageIdentifier.courseDetailsPageUri
            : TelemetryPageIdentifier.publicCourseDetailsPageUri)
        .replaceAll(':do_ID', widget.course['identifier']);
    if (widget.batchId != null) {
      pageUri = pageUri + "?batchId=${widget.batchId}";
    }
    Map eventData1 = Telemetry.getImpressionTelemetryEvent(
        deviceIdentifier,
        userId,
        departmentId,
        (!widget.isFeatured
            ? TelemetryPageIdentifier.courseDetailsPageId
            : TelemetryPageIdentifier.publicCourseDetailsPageId),
        userSessionId,
        messageIdentifier,
        !widget.isFeatured ? TelemetryType.public : TelemetryType.page,
        pageUri,
        env: TelemetryEnv.learn,
        objectId: widget.course['identifier'],
        objectType: widget.course['primaryCategory'],
        isPublic: widget.isFeatured);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData1);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());
  }

  void _generateInteractTelemetryData(String contentId, String mimeType) async {
    Map eventData2 = Telemetry.getInteractTelemetryEvent(
        deviceIdentifier,
        userId,
        departmentId,
        (!widget.isFeatured
            ? TelemetryPageIdentifier.courseDetailsPageId
            : TelemetryPageIdentifier.publicCourseDetailsPageId),
        userSessionId,
        messageIdentifier,
        contentId,
        TelemetrySubType.contentCard,
        env: TelemetryEnv.learn,
        objectType: TelemetrySubType.contentCard,
        isPublic: widget.isFeatured);
    // List allEventsData = [];
    // allEventsData.add(eventData2);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData2);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap(),
        isPublic: widget.isFeatured);
    // telemetryService.triggerEvent(allEventsData);
  }

  Future<dynamic> _readCourseContentProgress(
      bool status, courseId, batchId) async {
    // print('readCourseContentProgress...');
    if (!widget.isFeatured) {
      var response = await learnService.readContentProgress(courseId, batchId);
      // var response = widget.contentProgress;
      _contentProgressResponse = response;
      // print('_contentProgressResponse' + _contentProgressResponse.toString());
      for (int i = 0; i < navigationItems.length; i++) {
        if (navigationItems[i][0] == null) {
          for (int j = 0; j < response['result']['contentList'].length; j++) {
            if (navigationItems[i]['contentId'] ==
                response['result']['contentList'][j]['contentId']) {
              if (navigationItems[i][0] == null) {
                progress = response['result']['contentList'][j]
                            ['completionPercentage'] !=
                        null
                    ? response['result']['contentList'][j]
                            ['completionPercentage'] /
                        100
                    : 0;
                contentProgress[response['result']['contentList'][j]
                    ['contentId']] = progress;
                navigationItems[i]['completionPercentage'] = progress;
                if (response['result']['contentList'].length > 0) {
                  navigationItems[i]['currentProgress'] = (response['result']
                                  ['contentList'][j]['progressdetails'] !=
                              null &&
                          (response['result']['contentList'][j]
                                      ['progressdetails']['current'] !=
                                  null &&
                              response['result']['contentList'][j]
                                          ['progressdetails']['current']
                                      .length >
                                  0))
                      ? response['result']['contentList'][j]['progressdetails']
                              ['current']
                          .last
                      : 0;
                  navigationItems[i]['status'] =
                      response['result']['contentList'][j]['status'];
                }
              } else {
                progress = response['result']['contentList'][j]
                        ['completionPercentage'] /
                    100;
                contentProgress[response['result']['contentList'][j]
                    ['contentId']] = progress;
                navigationItems[i][0]['completionPercentage'] = progress;
                if (response['result']['contentList'].length > 0) {
                  navigationItems[i][0]['currentProgress'] = (response['result']
                                  ['contentList'][j]['progressdetails'] !=
                              null &&
                          response['result']['contentList'][j]
                                      ['progressdetails']['current']
                                  .length >
                              0)
                      ? response['result']['contentList'][j]['progressdetails']
                              ['current']
                          .last
                      : 0;
                  navigationItems[i][0]['status'] =
                      response['result']['contentList'][j]['status'];
                }
              }
            }
          }
        } else if (navigationItems[i][0][0] != null) {
          for (var m = 0; m < navigationItems[i].length; m++) {
            for (int k = 0; k < navigationItems[i][m].length; k++) {
              for (int j = 0;
                  j < response['result']['contentList'].length;
                  j++) {
                if (navigationItems[i][m][k] != null) {
                  if (navigationItems[i][m][k]['contentId'] ==
                      response['result']['contentList'][j]['contentId']) {
                    if (navigationItems[i][m][k][0] == null) {
                      if (response['result']['contentList'][j]
                              ['completionPercentage'] !=
                          null) {
                        progress = response['result']['contentList'][j]
                                ['completionPercentage'] /
                            100;
                      } else {
                        progress = 0.0;
                      }
                      contentProgress[response['result']['contentList'][j]
                          ['contentId']] = progress;
                      navigationItems[i][m][k]['completionPercentage'] =
                          progress;
                      if (response['result']['contentList'].length > 0) {
                        navigationItems[i][m][k]['currentProgress'] =
                            ((response['result']['contentList'][j]['progressdetails'] != null &&
                                        response['result']['contentList'][j]
                                                    ['progressdetails']
                                                ['current'] !=
                                            null) &&
                                    response['result']['contentList'][j]
                                                ['progressdetails']['current']
                                            .length >
                                        0)
                                ? response['result']['contentList'][j]
                                        ['progressdetails']['current']
                                    .last
                                : 0;
                        navigationItems[i][m][k]['status'] =
                            response['result']['contentList'][j]['status'];
                      }
                    } else {
                      progress = response['result']['contentList'][j]
                              ['completionPercentage'] /
                          100;
                      contentProgress[response['result']['contentList'][j]
                          ['contentId']] = progress;
                      navigationItems[i][m][k][0]['completionPercentage'] =
                          progress;
                      if (response['result']['contentList'].length > 0) {
                        navigationItems[i][m][k][0]['currentProgress'] =
                            (response['result']['contentList'][j]
                                            ['progressdetails'] !=
                                        null &&
                                    response['result']['contentList'][j]
                                                ['progressdetails']['current']
                                            .length >
                                        0)
                                ? response['result']['contentList'][j]
                                        ['progressdetails']['current']
                                    .last
                                : 0;
                        navigationItems[i][m][k][0]['status'] =
                            response['result']['contentList'][j]['status'];
                      }
                    }
                  }
                }
                //Added this as latest
                else if (navigationItems[i][m][0] == null) {
                  for (int j = 0;
                      j < response['result']['contentList'].length;
                      j++) {
                    if (navigationItems[i][m]['contentId'] ==
                        response['result']['contentList'][j]['contentId']) {
                      if (navigationItems[i][m][0] == null) {
                        progress = response['result']['contentList'][j]
                                    ['completionPercentage'] !=
                                null
                            ? response['result']['contentList'][j]
                                    ['completionPercentage'] /
                                100
                            : 0;
                        contentProgress[response['result']['contentList'][j]
                            ['contentId']] = progress;
                        navigationItems[i][m]['completionPercentage'] =
                            progress;
                        if (response['result']['contentList'].length > 0) {
                          navigationItems[i][m]['currentProgress'] =
                              (response['result']['contentList'][j]['progressdetails'] != null &&
                                      (response['result']['contentList'][j]
                                                      ['progressdetails']
                                                  ['current'] !=
                                              null &&
                                          response['result']['contentList'][j]
                                                          ['progressdetails']
                                                      ['current']
                                                  .length >
                                              0))
                                  ? response['result']['contentList'][j]
                                          ['progressdetails']['current']
                                      .last
                                  : 0;
                          navigationItems[i][m]['status'] =
                              response['result']['contentList'][j]['status'];
                        }
                      } else {
                        progress = response['result']['contentList'][j]
                                ['completionPercentage'] /
                            100;
                        contentProgress[response['result']['contentList'][j]
                            ['contentId']] = progress;
                        navigationItems[i][m][0]['completionPercentage'] =
                            progress;
                        if (response['result']['contentList'].length > 0) {
                          navigationItems[i][m][0]['currentProgress'] =
                              (response['result']['contentList'][j]
                                              ['progressdetails'] !=
                                          null &&
                                      response['result']['contentList'][j]
                                                  ['progressdetails']['current']
                                              .length >
                                          0)
                                  ? response['result']['contentList'][j]
                                          ['progressdetails']['current']
                                      .last
                                  : 0;
                          navigationItems[i][m][0]['status'] =
                              response['result']['contentList'][j]['status'];
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        } else {
          for (int k = 0; k < navigationItems[i].length; k++) {
            for (int j = 0; j < response['result']['contentList'].length; j++) {
              if (navigationItems[i][k]['contentId'] ==
                  response['result']['contentList'][j]['contentId']) {
                if (navigationItems[i][k][0] == null) {
                  if (response['result']['contentList'][j]
                          ['completionPercentage'] !=
                      null) {
                    progress = response['result']['contentList'][j]
                            ['completionPercentage'] /
                        100;
                  } else {
                    progress = 0.0;
                  }
                  contentProgress[response['result']['contentList'][j]
                      ['contentId']] = progress;
                  navigationItems[i][k]['completionPercentage'] = progress;
                  if (response['result']['contentList'].length > 0) {
                    navigationItems[i][k]['currentProgress'] = (response['result']
                                        ['contentList'][j]['progressdetails'] !=
                                    null &&
                                response['result']['contentList'][j]
                                        ['progressdetails']['current'] !=
                                    null) &&
                            response['result']['contentList'][j]
                                        ['progressdetails']['current']
                                    .length >
                                0
                        ? response['result']['contentList'][j]
                                ['progressdetails']['current']
                            .last
                        : 0;
                    navigationItems[i][k]['status'] =
                        response['result']['contentList'][j]['status'];
                  }
                } else {
                  progress = response['result']['contentList'][j]
                          ['completionPercentage'] /
                      100;
                  contentProgress[response['result']['contentList'][j]
                      ['contentId']] = progress;
                  if (response['result']['contentList'].length > 0) {
                    navigationItems[i][k][0]['currentProgress'] =
                        (response['result']['contentList'][j]
                                        ['progressdetails'] !=
                                    null &&
                                response['result']['contentList'][j]
                                            ['progressdetails']['current']
                                        .length >
                                    0)
                            ? response['result']['contentList'][j]
                                    ['progressdetails']['current']
                                .last
                            : 0;
                    navigationItems[i][k][0]['status'] =
                        response['result']['contentList'][j]['status'];
                  }
                }
              }
            }
          }
        }
      }
      if (mounted) {
        setState(() {});
      }
    }
    return navigationItems;
  }

  void _generateNavigation() {
    int index;
    int k = 0;
    if (widget.course['children'] != null) {
      for (index = 0; index < widget.course['children'].length; index++) {
        if ((widget.course['children'][index]['contentType'] == 'Collection' ||
            widget.course['children'][index]['contentType'] == 'CourseUnit')) {
          // Added this
          List temp = [];

          if (widget.course['children'][index]['children'] != null) {
            for (int i = 0;
                i < widget.course['children'][index]['children'].length;
                i++) {
              // Added this
              temp.add({
                'index': k++,
                'moduleName': widget.course['children'][index]['name'],
                'mimeType': widget.course['children'][index]['children'][i]
                    ['mimeType'],
                'identifier': widget.course['children'][index]['children'][i]
                    ['identifier'],
                'name': widget.course['children'][index]['children'][i]['name'],
                'parentCourseId': widget.course['children'][index]
                    ['identifier'],
                'artifactUrl': widget.course['children'][index]['children'][i]
                    ['artifactUrl'],
                'contentId': widget.course['children'][index]['children'][i]
                    ['identifier'],
                'currentProgress': '0',
                'completionPercentage': '0',
                'status': 0,
                // 'duration': '1s',
                'moduleDuration':
                    widget.course['children'][index]['duration'] != null
                        ? Helper.getFullTimeFormat(
                            widget.course['children'][index]['duration'])
                        : '',
                'duration': ((widget.course['children'][index]['children'][i]
                                    ['duration'] !=
                                null &&
                            widget.course['children'][index]['children'][i]['duration'] !=
                                '') ||
                        (widget.course['children'][index]['children'][i]
                                    ['expectedDuration'] !=
                                null &&
                            widget.course['children'][index]['children'][i]
                                    ['expectedDuration'] !=
                                ''))
                    ? widget.course['children'][index]['children'][i]['mimeType'] ==
                            EMimeTypes.pdf
                        ? 'PDF - ' + Helper.getFullTimeFormat(widget.course['children'][index]['children'][i]['duration'])
                        : widget.course['children'][index]['children'][i]['mimeType'] == EMimeTypes.mp4
                            ? 'Video - ' + Helper.getFullTimeFormat(widget.course['children'][index]['children'][i]['duration'])
                            : widget.course['children'][index]['children'][i]['mimeType'] == EMimeTypes.mp3
                                ? 'Audio - ' + Helper.getFullTimeFormat(widget.course['children'][index]['children'][i]['duration'])
                                : widget.course['children'][index]['children'][i]['mimeType'] == EMimeTypes.assessment
                                    ? 'Assessment - ' + Helper.getFullTimeFormat(widget.course['children'][index]['children'][i]['duration'])
                                    : widget.course['children'][index]['children'][i]['mimeType'] == EMimeTypes.survey
                                        ? 'Survey - ' + Helper.getFullTimeFormat(widget.course['children'][index]['children'][i]['duration'])
                                        : widget.course['children'][index]['children'][i]['mimeType'] == EMimeTypes.newAssessment
                                            ? Helper.getFullTimeFormat(widget.course['children'][index]['children'][i]['expectedDuration'].toString())
                                            : 'Resource - ' + Helper.getFullTimeFormat(widget.course['children'][index]['children'][i]['duration'])
                    : 'Link - ' + widget.course['children'][index]['children'][i]['duration'] != null
                        ? Helper.getFullTimeFormat(widget.course['children'][index]['children'][i]['duration'])
                        : ''
              });
            }
          } else {
            temp.add({
              'index': k++,
              'moduleName': widget.course['children'][index]['name'],
              'moduleDuration':
                  widget.course['children'][index]['duration'] != null
                      ? Helper.getFullTimeFormat(
                          widget.course['children'][index]['duration'])
                      : '',
              'identifier': widget.course['children'][index]['identifier'],
            });
          }
          // temp.add({
          //   'index': k++,
          //   'moduleName': widget.course['children'][index]['name'],
          //   'mimeType': 'Survey',
          //   'name': 'Survey',
          //   // 'artifactUrl': widget.course['children'][index]['children'][i]
          //   //     ['artifactUrl'],
          //   // 'contentId': widget.course['children'][index]['children'][i]
          //   //     ['identifier'],
          //   // 'currentProgress': '0',
          //   'completionPercentage': 100,
          //   'status': 0,
          //   // 'duration': '1s',
          //   'duration': 'Survey - ' + Helper.getFullTimeFormat('1200')
          // });
          // Added this
          navigationItems.add(temp);
        }
        //Added below condition to handle course item
        else if (widget.course['children'][index]['contentType'] == 'Course') {
          List courseList = [];
          for (var i = 0;
              i < widget.course['children'][index]['children'].length;
              i++) {
            List temp = [];
            if (widget.course['children'][index]['children'][i]
                        ['contentType'] ==
                    'Collection' ||
                widget.course['children'][index]['children'][i]
                        ['contentType'] ==
                    'CourseUnit') {
              for (var j = 0;
                  j <
                      widget
                          .course['children'][index]['children'][i]['children']
                          .length;
                  j++) {
                temp.add({
                  'index': k++,
                  'courseName': widget.course['children'][index]['name'],
                  'moduleName': widget.course['children'][index]['children'][i]
                      ['name'],
                  'mimeType': widget.course['children'][index]['children'][i]
                      ['children'][j]['mimeType'],
                  'identifier': widget.course['children'][index]['children'][i]
                      ['children'][j]['identifier'],
                  'name': widget.course['children'][index]['children'][i]
                      ['children'][j]['name'],
                  'parentCourseId': widget.course['children'][index]
                      ['identifier'],
                  'artifactUrl': widget.course['children'][index]['children'][i]
                      ['children'][j]['artifactUrl'],
                  'contentId': widget.course['children'][index]['children'][i]
                      ['children'][j]['identifier'],
                  'currentProgress': '0',
                  'completionPercentage': '0',
                  'status': 0,
                  // 'duration': '1s',
                  'moduleDuration': widget.course['children'][index]['children']
                              [i]['duration'] !=
                          null
                      ? Helper.getFullTimeFormat(widget.course['children']
                          [index]['children'][i]['duration'])
                      : '',
                  'courseDuration':
                      widget.course['children'][index]['duration'] != null
                          ? Helper.getFullTimeFormat(
                              widget.course['children'][index]['duration'])
                          : '',
                  'duration': ((widget.course['children'][index]['children'][i]['children'][j]['duration'] != null &&
                              widget.course['children'][index]['children'][i]
                                      ['children'][j]['duration'] !=
                                  '') ||
                          (widget.course['children'][index]['children'][i]
                                      ['children'][j]['expectedDuration'] !=
                                  null &&
                              widget.course['children'][index]['children'][i]
                                      ['children'][j]['expectedDuration'] !=
                                  ''))
                      ? widget.course['children'][index]['children'][i]['children'][j]['mimeType'] == EMimeTypes.pdf
                          ? 'PDF - ' + Helper.getFullTimeFormat(widget.course['children'][index]['children'][i]['children'][j]['duration'])
                          : widget.course['children'][index]['children'][i]['children'][j]['mimeType'] == EMimeTypes.mp4
                              ? 'Video - ' + Helper.getFullTimeFormat(widget.course['children'][index]['children'][i]['children'][j]['duration'])
                              : widget.course['children'][index]['children'][i]['children'][j]['mimeType'] == EMimeTypes.mp3
                                  ? 'Audio - ' + Helper.getFullTimeFormat(widget.course['children'][index]['children'][i]['children'][j]['duration'])
                                  : widget.course['children'][index]['children'][i]['children'][j]['mimeType'] == EMimeTypes.assessment
                                      ? 'Assessment - ' + Helper.getFullTimeFormat(widget.course['children'][index]['children'][i]['children'][j]['duration'])
                                      : widget.course['children'][index]['children'][i]['mimeType'] == EMimeTypes.survey
                                          ? 'Survey - ' + Helper.getFullTimeFormat(widget.course['children'][index]['children'][i]['children'][j]['duration'])
                                          : widget.course['children'][index]['children'][i]['mimeType'] == EMimeTypes.newAssessment
                                              ? Helper.getFullTimeFormat(widget.course['children'][index]['children'][i]['children'][j]['expectedDuration'].toString())
                                              : 'Resource - ' + Helper.getFullTimeFormat(widget.course['children'][index]['children'][i]['children'][j]['duration'] != null ? widget.course['children'][index]['children'][i]['children'][j]['duration'] : '120'.toString())
                      : 'Link - ' + widget.course['children'][index]['children'][i]['children'][j]['duration'] != null
                          ? Helper.getFullTimeFormat(widget.course['children'][index]['children'][i]['children'][j]['duration'])
                          : ''
                });
              }
              courseList.add(temp);
            } else {
              courseList.add({
                'index': k++,
                'courseName': widget.course['children'][index]['name'],
                'parentCourseId': widget.course['children'][index]
                    ['identifier'],
                'mimeType': widget.course['children'][index]['children'][i]
                    ['mimeType'],
                'identifier': widget.course['children'][index]['children'][i]
                    ['identifier'],
                'name': widget.course['children'][index]['children'][i]['name'],
                'artifactUrl': widget.course['children'][index]['children'][i]
                    ['artifactUrl'],
                'contentId': widget.course['children'][index]['children'][i]
                    ['identifier'],
                'currentProgress': '0',
                'completionPercentage': '0',
                'status': 0,
                // 'duration': '1s',
                'courseDuration':
                    widget.course['children'][index]['duration'] != null
                        ? Helper.getFullTimeFormat(
                            widget.course['children'][index]['duration'])
                        : '',
                'duration': ((widget.course['children'][index]['children'][i]
                                    ['duration'] !=
                                null &&
                            widget.course['children'][index]['children'][i]['duration'] !=
                                '') ||
                        (widget.course['children'][index]['children'][i]
                                    ['expectedDuration'] !=
                                null &&
                            widget.course['children'][index]['children'][i]
                                    ['expectedDuration'] !=
                                ''))
                    ? widget.course['children'][index]['children'][i]['mimeType'] ==
                            EMimeTypes.pdf
                        ? 'PDF - ' + Helper.getFullTimeFormat(widget.course['children'][index]['children'][i]['duration'])
                        : widget.course['children'][index]['children'][i]['mimeType'] == EMimeTypes.mp4
                            ? 'Video - ' + Helper.getFullTimeFormat(widget.course['children'][index]['children'][i]['duration'])
                            : widget.course['children'][index]['children'][i]['mimeType'] == EMimeTypes.mp3
                                ? 'Audio - ' + Helper.getFullTimeFormat(widget.course['children'][index]['children'][i]['duration'])
                                : widget.course['children'][index]['children'][i]['mimeType'] == EMimeTypes.assessment
                                    ? 'Assessment - ' + Helper.getFullTimeFormat(widget.course['children'][index]['children'][i]['duration'])
                                    : widget.course['children'][index]['children'][i]['mimeType'] == EMimeTypes.survey
                                        ? 'Survey - ' + Helper.getFullTimeFormat(widget.course['children'][index]['children'][i]['duration'])
                                        : widget.course['children'][index]['children'][i]['mimeType'] == EMimeTypes.newAssessment
                                            ? Helper.getFullTimeFormat(widget.course['children'][index]['children'][i]['expectedDuration'].toString())
                                            : 'Resource - ' + Helper.getFullTimeFormat(widget.course['children'][index]['children'][i]['duration'])
                    : 'Link - ' + widget.course['children'][index]['children'][i]['duration'] != null
                        ? Helper.getFullTimeFormat(widget.course['children'][index]['children'][i]['duration'])
                        : ''
              });
            }
          }
          navigationItems.add(courseList);
        } else {
          // print('duration: '+ widget.course['children'][index]['duration'].toString());
          // print('duration: ' +
          //     widget.course['children'][index]['duration'].toString());
          navigationItems.add({
            'index': k++,
            'mimeType': widget.course['children'][index]['mimeType'],
            'identifier': widget.course['children'][index]['identifier'],
            'name': widget.course['children'][index]['name'],
            'parentCourseId': widget.course['children'][index]['identifier'],
            'artifactUrl': widget.course['children'][index]['artifactUrl'],
            'contentId': widget.course['children'][index]['identifier'],
            'currentProgress': '0',
            'completionPercentage': '0',
            'status': 0,
            // 'duration': '1s',
            'courseDuration':
                widget.course['children'][index]['duration'] != null
                    ? Helper.getFullTimeFormat(
                        widget.course['children'][index]['duration'])
                    : '',
            'duration': ((widget.course['children'][index]['duration'] != null &&
                        widget.course['children'][index]['duration'] != '') ||
                    (widget.course['children'][index]['expectedDuration'] !=
                            null &&
                        widget.course['children'][index]['expectedDuration'] !=
                            ''))
                ? widget.course['children'][index]['mimeType'] == EMimeTypes.pdf
                    ? 'PDF - ' +
                        Helper.getFullTimeFormat(
                            widget.course['children'][index]['duration'])
                    : widget.course['children'][index]['mimeType'] ==
                            EMimeTypes.mp4
                        ? 'Video - ' +
                            Helper.getFullTimeFormat(
                                widget.course['children'][index]['duration'])
                        : widget.course['children'][index]['mimeType'] ==
                                EMimeTypes.mp3
                            ? 'Audio - ' +
                                Helper.getFullTimeFormat(widget.course['children'][index]['duration'])
                            : widget.course['children'][index]['mimeType'] == EMimeTypes.assessment
                                ? 'Assessment - ' + Helper.getFullTimeFormat(widget.course['children'][index]['duration'])
                                : widget.course['children'][index]['mimeType'] == EMimeTypes.survey
                                    ? 'Survey - ' + Helper.getFullTimeFormat(widget.course['children'][index]['duration'])
                                    : widget.course['children'][index]['mimeType'] == EMimeTypes.newAssessment
                                        ? Helper.getFullTimeFormat(widget.course['children'][index]['expectedDuration'].toString())
                                        : 'Resource - ' + Helper.getFullTimeFormat(widget.course['children'][index]['duration'])
                : 'Link - ' + ''
          });
        }
      }
    }

    if (navigationItems.length != 0 && isCuratedProgram) {
      showCertificate.clear();
      for (int i = 0; i < navigationItems.length; i++) {
        if (navigationItems[i][0] != null && navigationItems[i][0][0] != null) {
          showCertificate.add({navigationItems[i][0][0]: false});
        }
      }
    }
  }

  void updateProgress(Map data) {
    for (int i = 0; i < navigationItems.length; i++) {
      if (navigationItems[i][0] == null) {
        if (navigationItems[i]['identifier'] == data['identifier']) {
          Timer.run(() {
            setState(() {
              navigationItems[i]['status'] = 2;
            });
          });
          if (data['completionPercentage'] == 100.0) {
            Timer.run(() {
              setState(() {
                navigationItems[i]['status'] = 2;
              });
            });
          }
        }
      } else if (navigationItems[i][0][0] != null) {
        for (var k = 0; k < navigationItems[i].length; k++) {
          for (int j = 0; j < navigationItems[i][k].length; j++) {
            if (navigationItems[i][k][j]['identifier'] == data['identifier']) {
              Timer.run(() {
                setState(() {
                  navigationItems[i][k][j]['status'] = 2;
                });
              });
              if (data['completionPercentage'] == 100.0) {
                Timer.run(() {
                  setState(() {
                    navigationItems[i][k][j]['status'] = 2;
                  });
                });
              }
            } else if (navigationItems[i][k][0] == null) {
              if (navigationItems[i][k]['identifier'] == data['identifier']) {
                Timer.run(() {
                  setState(() {
                    navigationItems[i][k]['status'] = 2;
                  });
                });
                if (data['completionPercentage'] == 100.0) {
                  Timer.run(() {
                    setState(() {
                      navigationItems[i][k]['status'] = 2;
                    });
                  });
                }
              }
            }
          }
        }
      } else {
        for (int j = 0; j < navigationItems[i].length; j++) {
          if (navigationItems[i][j]['identifier'] == data['identifier']) {
            Timer.run(() {
              setState(() {
                navigationItems[i][j]['status'] = 2;
              });
            });
            if (data['completionPercentage'] == 100.0) {
              Timer.run(() {
                setState(() {
                  navigationItems[i][j]['status'] = 2;
                });
              });
            }
          }
        }
      }
    }
    // for (int i = 0; i < navigationItems.length; i++) {
    //   if (navigationItems[i]['identifier'] == data['identifier']) {
    //     Timer.run(() {
    //       setState(() {
    //         navigationItems[i]['completionPercentage'] =
    //             (data['completionPercentage'] / 100).toString();
    //         navigationItems[i]['currentProgress'] =
    //             data['mimeType'] == EMimeTypes.assessment
    //                 ? (data['completionPercentage']).toString()
    //                 : data['current'];
    //       });
    //     });
    //     if (data['completionPercentage'] == 100.0) {
    //       Timer.run(() {
    //         setState(() {
    //           navigationItems[i]['status'] = 2;
    //         });
    //       });
    //     }
    //   }
    // }
  }

  double _getCourseProgress(glanceListItems) {
    double _courseProgressSum = 0.0;
    if (isCuratedProgram) {
      for (var i = 0; i < glanceListItems.length; i++) {
        double progressSum = _courseProgressSum;
        for (int j = 0; j < glanceListItems[i].length; j++) {
          if (glanceListItems[i][j] != null) {
            if (glanceListItems[i][j]['status'] == 2) {
              progressSum = progressSum + 1;
            } else if (glanceListItems[i][j]['completionPercentage'] != '0' &&
                glanceListItems[i][j]['completionPercentage'] != null)
              progressSum =
                  progressSum + glanceListItems[i][j]['completionPercentage'];
          }
        }
        // if (progressSum == _courseProgressSum) {
        //   if (glanceListItems[i] != null) {
        //     if (glanceListItems[i]['status'] == 2) {
        //       _courseProgressSum = _courseProgressSum + 1;
        //     } else if (glanceListItems[i]['completionPercentage'] != null){
        //       if(glanceListItems[i]['completionPercentage'] != '0'){
        //       _courseProgressSum = _courseProgressSum +
        //           glanceListItems[i]['completionPercentage'];
        //     }}
        //   }
        // } else {
        _courseProgressSum = progressSum;
        // }
      }
    } else {
      for (var i = 0; i < glanceListItems.length; i++) {
        for (int j = 0; j < glanceListItems[i].length; j++) {
          if (glanceListItems[i][j] != null) {
            if (glanceListItems[i][j]['status'] == 2) {
              _courseProgressSum = _courseProgressSum + 1;
            } else if (glanceListItems[i][j]['completionPercentage'] != '0' &&
                glanceListItems[i][j]['completionPercentage'] != null)
              _courseProgressSum = _courseProgressSum +
                  glanceListItems[i][j]['completionPercentage'];
          } else if (glanceListItems[i] != null) {
            if (glanceListItems[i]['status'] == 2) {
              _courseProgressSum = _courseProgressSum + 1;
            } else if (glanceListItems[i]['completionPercentage'] != '0' &&
                glanceListItems[i]['completionPercentage'] != null)
              _courseProgressSum = _courseProgressSum +
                  glanceListItems[i]['completionPercentage'];
          }
        }
      }
    }
    if (isCuratedProgram) {
      return _courseProgressSum / glanceListItems[0].length;
    }
    return _courseProgressSum / glanceListItems.length;
    // return 0.5;
  }

  Widget getContentObject(content) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(const Radius.circular(4.0)),
      ),
      margin: EdgeInsets.only(top: 8, left: 0, right: 0),
      // padding: EdgeInsets.only(top: 5, bottom: 10),
      child: InkWell(
        onTap: widget.course['primaryCategory'] != EnglishLang.program
            ? () {
                _generateInteractTelemetryData(
                    content['identifier'], content['mimeType']);
                // if (!widget.isFeatured) {
                //   if (content['mimeType'] == EMimeTypes.assessment) {
                //     Navigator.push(
                //         context,
                //         FadeRoute(
                //             page: CourseAssessmentPlayer(
                //                 widget.course,
                //                 content['name'],
                //                 content['identifier'],
                //                 content['artifactUrl'],
                //                 updateProgress,
                //                 widget.batchId,
                //                 content['duration']
                //                 )));
                //   } else if (content['mimeType'] == EMimeTypes.survey) {
                //     if (content['status'] != 2) {
                //       Navigator.push(
                //           context,
                //           FadeRoute(
                //               page: ContentFeedback(
                //                   content['artifactUrl'],
                //                   content['name'],
                //                   widget.course,
                //                   content['identifier'],
                //                   widget.batchId)));
                //     } else {
                //       ScaffoldMessenger.of(context).showSnackBar(
                //         SnackBar(
                //           content: Text(EnglishLang.surveyAlreadySubmitted,
                //               style: GoogleFonts.lato(
                //                 color: Colors.white,
                //               )),
                //           backgroundColor: AppColors.positiveLight,
                //         ),
                //       );
                //     }
                //   } else {
                //     Navigator.push(
                //         context,
                //         FadeRoute(
                //             page: CourseNavigationPage(
                //           course: widget.course,
                //           identifier: content['identifier'],
                //           contentProgress: _contentProgressResponse,
                //           navigation: navigationItems,
                //           batchId: widget.batchId,
                //           parentAction: _readCourseContentProgress,
                //         )));
                //   }
                // }
              }
            : null,
        child: content['mimeType'] != null
            ? Column(
                children: [
                  GlanceItem3(
                      icon: (content['mimeType'] == EMimeTypes.mp4 ||
                              content['mimeType'] == EMimeTypes.m3u8 ||
                              content['mimeType'] == EMimeTypes.mp3)
                          ? 'assets/img/icons-av-play.svg'
                          : (content['mimeType'] == EMimeTypes.externalLink ||
                                  content['mimeType'] == EMimeTypes.youtubeLink)
                              ? 'assets/img/link.svg'
                              : content['mimeType'] == EMimeTypes.pdf
                                  ? 'assets/img/icons-file-types-pdf-alternate.svg'
                                  : (content['mimeType'] ==
                                              EMimeTypes.assessment ||
                                          content['mimeType'] ==
                                              EMimeTypes.newAssessment)
                                      ? 'assets/img/assessment_icon.svg'
                                      : 'assets/img/resource.svg',
                      text: content['name'],
                      status: content['status'],
                      duration: content['duration'],
                      isFeaturedCourse: widget.isFeatured,
                      currentProgress: content['completionPercentage'],
                      showProgress: showProgress,
                      mimeType: content['mimeType']),
                ],
              )
            : Center(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    widget.parentAction('update');
    return navigationItems.length != 0
        ? SingleChildScrollView(
            child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < navigationItems.length; i++)
                  if (navigationItems[i].length > 0) ...[
                    if (navigationItems[i][0] == null)
                      getContentObject(navigationItems[i])
                    //Added below condition to handle course item
                    else if (hasModuleInChildren(navigationItems[i])) ...[
                      for (int j = 0; j < navigationItems[i].length; j++)
                        navigationItems[i][j][0] != null
                            ? Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(
                                      const Radius.circular(4.0)),
                                ),
                                margin: EdgeInsets.only(top: 8),
                                child: InkWell(
                                  onTap: () {},
                                  child: ExpansionTile(
                                    title: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 4, left: 8),
                                          child: SvgPicture.asset(
                                            'assets/img/course_icon.svg',
                                            color: AppColors.greys87,
                                          ),
                                        ),
                                        Expanded(
                                            child: Container(
                                          padding:
                                              const EdgeInsets.only(left: 16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                navigationItems[i][j][0]
                                                    ['courseName'],
                                                style: GoogleFonts.lato(
                                                    height: 1.5,
                                                    decoration:
                                                        TextDecoration.none,
                                                    color: AppColors.greys87,
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                      navigationItems[i][j][0]
                                                              ['courseDuration']
                                                          .toString(),
                                                      style: GoogleFonts.lato(
                                                          height: 1.5,
                                                          decoration:
                                                              TextDecoration
                                                                  .none,
                                                          color:
                                                              AppColors.greys87,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w400)),
                                                  (showCertificateIcon &&
                                                              _getCourseProgress(
                                                                      navigationItems[
                                                                          i]) >=
                                                                  1) ||
                                                          (widget.isProgram &&
                                                              _getCourseProgress(
                                                                      navigationItems[
                                                                          i]) >=
                                                                  1)
                                                      ? Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  top: 4,
                                                                  right: 0),
                                                          child: TextButton(
                                                            onPressed: () {
                                                              setState(() {
                                                                if (showCertificate
                                                                    .isNotEmpty) {
                                                                  showCertificate[
                                                                      i][navigationItems[
                                                                          i][j][
                                                                      0]] = !showCertificate[
                                                                          i][
                                                                      navigationItems[
                                                                              i]
                                                                          [j][0]];
                                                                }
                                                              });
                                                            },
                                                            child: Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                      border:
                                                                          Border
                                                                              .all(
                                                                        color: AppColors
                                                                            .primaryThree,
                                                                        width:
                                                                            1.5,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              4.0)),
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(5),
                                                              child: Row(
                                                                children: [
                                                                  SvgPicture
                                                                      .asset(
                                                                    'assets/img/curated_certificate_icon.svg',
                                                                    width: 24.0,
                                                                    height:
                                                                        24.0,
                                                                  ),
                                                                  SizedBox(
                                                                      width: 8),
                                                                  Text(
                                                                    EnglishLang
                                                                        .viewCertificate,
                                                                    style: GoogleFonts.lato(
                                                                        height:
                                                                            1.429,
                                                                        decoration:
                                                                            TextDecoration
                                                                                .none,
                                                                        color: AppColors
                                                                            .primaryThree,
                                                                        fontSize:
                                                                            14,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w700,
                                                                        letterSpacing:
                                                                            0.5),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      : Center()
                                                ],
                                              ),
                                              showCertificate.isNotEmpty &&
                                                      i < showCertificate.length
                                                  ? showCertificate[i][
                                                                  navigationItems[i]
                                                                      [j][0]] !=
                                                              null &&
                                                          showCertificate[i][
                                                              navigationItems[i]
                                                                  [j][0]]
                                                      ? CertificateWidget(
                                                          courseId:
                                                              navigationItems[i]
                                                                      [j][0]
                                                                  ['parentCourseId'])
                                                      : Center()
                                                  : Center()
                                            ],
                                          ),
                                        )),
                                        !widget.isFeatured && !isCuratedProgram
                                            ? Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 12, right: 0, left: 4),
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  height: 20,
                                                  width: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                          backgroundColor:
                                                              AppColors.grey16,
                                                          valueColor:
                                                              AlwaysStoppedAnimation<
                                                                  Color>(
                                                            _getCourseProgress(
                                                                        navigationItems[
                                                                            i]) <
                                                                    1
                                                                ? AppColors
                                                                    .primaryOne
                                                                : AppColors
                                                                    .positiveLight,
                                                          ),
                                                          strokeWidth: 3,
                                                          value:
                                                              _getCourseProgress(
                                                                  navigationItems[
                                                                      i])),
                                                ),
                                              )
                                            : Center()
                                      ],
                                    ),
                                    children: [
                                      for (var k = 0;
                                          k < navigationItems[i].length;
                                          k++, j++)
                                        (navigationItems[i][k][0] != null
                                            ? ModuleItem(
                                                course: widget.course,
                                                moduleIndex: k,
                                                moduleName: navigationItems[i]
                                                    [k][0]['moduleName'],
                                                glanceListItems:
                                                    navigationItems[i][k],
                                                contentProgressResponse:
                                                    _contentProgressResponse,
                                                navigation: navigationItems,
                                                batchId: widget.batchId,
                                                // parentAction:
                                                //     readCourseProgress,
                                                isFeatured: widget.isFeatured,
                                                duration: navigationItems[i][k]
                                                    [0]['moduleDuration'],
                                                parentCourseId:
                                                    navigationItems[i][k][0]
                                                        ['parentCourseId'],
                                                showProgress: showProgress)
                                            : (navigationItems[i][k] != null)
                                                ? getContentObject(
                                                    navigationItems[i][k])
                                                : Center())
                                    ],
                                  ),
                                ),
                              )
                            : Center()
                    ] else
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.all(const Radius.circular(4.0)),
                        ),
                        margin: EdgeInsets.only(top: 8),
                        child: InkWell(
                          onTap: () {},
                          child: Column(
                            children: [
                              navigationItems[i].length > 0
                                  ? ModuleItem(
                                      course: widget.course,
                                      moduleIndex: i,
                                      moduleName: navigationItems[i][0]
                                                  ['moduleName'] !=
                                              null
                                          ? navigationItems[i][0]['moduleName']
                                          : navigationItems[i][0]['courseName'],
                                      glanceListItems: navigationItems[i],
                                      contentProgressResponse:
                                          _contentProgressResponse,
                                      navigation: navigationItems,
                                      batchId: widget.batchId,
                                      // parentAction: readCourseProgress,
                                      isCourse: navigationItems[i][0]
                                                  ['moduleName'] !=
                                              null
                                          ? false
                                          : true,
                                      isFeatured: widget.isFeatured,
                                      duration: navigationItems[i][0]
                                                  ['moduleDuration'] !=
                                              null
                                          ? navigationItems[i][0]
                                              ['moduleDuration']
                                          : navigationItems[i][0]
                                              ['courseDuration'],
                                      parentCourseId: navigationItems[i][0]
                                          ['parentCourseId'],
                                      showProgress: showProgress)
                                  : Center(),
                            ],
                          ),
                        ),
                      ),
                  ]
              ],
            ),
          ))
        : Center(
            child: Text(
              AppLocalizations.of(context).mLearnNoContentForCourse,
              style: GoogleFonts.lato(
                  color: AppColors.greys60,
                  fontSize: 16,
                  fontWeight: FontWeight.w700),
            ),
          );
  }

  readCourseProgress(value) async {
    _readCourseContentProgress(
        value, widget.course['identifier'], widget.batchId);
    if (isCuratedProgram) {
      if (widget.course['children'] != null) {
        for (int index = 0; index < widget.course['children'].length; index++) {
          if (widget.enrollmentList != null) {
            widget.enrollmentList.forEach((course) async {
              if (course.raw['courseId'] ==
                  widget.course['children'][index]['identifier']) {
                await _readCourseContentProgress(value, course.raw['courseId'],
                    course.raw['batch']['batchId']);
              }
            });
          }
        }
      }
    }
  }

  bool hasModuleInChildren(navigationItem) {
    for (var item in navigationItem) {
      if (item is List) {
        return true;
      }
    }
    return false;
  }
}
