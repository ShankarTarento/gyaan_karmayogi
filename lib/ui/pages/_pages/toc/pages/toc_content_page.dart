import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';

import '../../../../../constants/index.dart';
import '../../../../../models/index.dart';
import '../../../../../services/index.dart';
import '../../../../../util/telemetry.dart';
import '../../../../../util/telemetry_db_helper.dart';
import '../../../../widgets/index.dart';
import '../../../index.dart';
import '../util/toc_helper.dart';

class TocContentPage extends StatefulWidget {
  const TocContentPage(
      {Key key,
      @required this.courseId,
      @required this.course,
      @required this.enrolmentList,
      @required this.courseHierarchy,
      @required this.navigationItems,
      @required this.contentProgressResponse,
      @required this.lastAccessContentId,
      this.isFeatured = false,
      this.isProgram = false,
      this.isPlayer = false,
      this.startNewResourse,
      this.readCourseProgress,
      this.enrolledCourse})
      : super(key: key);

  final course;
  final List navigationItems;
  final List<Course> enrolmentList;
  final String courseId;
  final bool isFeatured;
  final bool isProgram, isPlayer;
  final courseHierarchy;
  final contentProgressResponse;
  final String lastAccessContentId;
  final ValueChanged<String> startNewResourse;
  final VoidCallback readCourseProgress;
  final Course enrolledCourse;

  @override
  State<TocContentPage> createState() => _TocContentPageState();
}

class _TocContentPageState extends State<TocContentPage> {
  final LearnService learnService = LearnService();
  final TelemetryService telemetryService = TelemetryService();
  double progress = 0.0;
  int totalCourseProgress = 0;
  var contentProgress = Map();
  var courseHierarchyInfo;

  String userId;
  String userSessionId;
  String messageIdentifier;
  String departmentId;
  String pageIdentifier;
  String deviceIdentifier;
  String batchId;
  var telemetryEventData;
  bool isCuratedProgram = false,
      showCertificateIcon = false,
      isContentsAdded = false,
      showProgress = false;
  List navigationItems;

  @override
  void initState() {
    super.initState();
    courseHierarchyInfo = widget.courseHierarchy;
    navigationItems = widget.navigationItems;
    if (courseHierarchyInfo['cumulativeTracking'] != null) {
      if (courseHierarchyInfo['cumulativeTracking']) {
        isCuratedProgram = true;
      }
    }

    getProgressInfo();
    if (widget.course['batches'] != null &&
        widget.course['batches'].isNotEmpty) {
      batchId = widget.course['batches'].first['batchId'];
    }
    Course courseDetails = Course.fromJson(widget.course);
    if (widget.isPlayer) {
      showProgress = true;
    } else if (courseDetails.raw['primaryCategory'] == EnglishLang.program) {
      showProgress = TocHelper()
          .checkInviteOnlyProgramIsActive(courseDetails, widget.enrolledCourse);
    }

    _generateTelemetryData();
  }

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(TocContentPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    navigationItems = widget.navigationItems;
    if (widget.enrolledCourse != null) {
      if (isCuratedProgram) {
        showCertificateIcon = true;
      }
      Course courseDetails = Course.fromJson(widget.course);

      setState(() {
        if (courseDetails.raw['primaryCategory'] == EnglishLang.program) {
          showProgress = TocHelper().checkInviteOnlyProgramIsActive(
              courseDetails, widget.enrolledCourse);
        } else {
          showProgress = true;
        }
      });
      totalCourseProgress = widget.enrolledCourse.raw['completionPercentage'];
    }
  }

  void getProgressInfo() {
    if (widget.enrolmentList != null) {
      widget.enrolmentList.forEach((course) async {
        if (course.raw['courseId'] == widget.courseId) {
          if (isCuratedProgram) {
            showCertificateIcon = true;
          }
          showProgress = true;
          totalCourseProgress = course.raw['completionPercentage'];
        }
      });
    }
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
    if (batchId != null) {
      pageUri = pageUri + "?batchId=$batchId";
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

  @override
  Widget build(BuildContext context) {
    if (courseHierarchyInfo != null) {
      if (courseHierarchyInfo.runtimeType == String) {
        return NoDataWidget(message: 'No course');
      } else {
        if (!isContentsAdded) {
          isContentsAdded = true;
        }
        return navigationItems.length != 0
            ? Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                color: AppColors.scaffoldBackground,
                child: SingleChildScrollView(
                    child: Container(
                        padding: EdgeInsets.only(bottom: 100),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (int i = 0; i < navigationItems.length; i++)
                              if (navigationItems[i].length > 0) ...[
                                if (navigationItems[i][0] == null)
                                  TocContentObjectWidget(
                                      content: navigationItems[i],
                                      course: courseHierarchyInfo,
                                      showProgress: showProgress,
                                      lastAccessContentId:
                                          widget.lastAccessContentId,
                                      startNewResourse: widget.startNewResourse,
                                      isPlayer: widget.isPlayer,
                                      enrolmentList: widget.enrolmentList,
                                      navigationItems: widget.navigationItems,
                                      courseId: widget.courseId,
                                      batchId: batchId,
                                      isCuratedProgram: isCuratedProgram,
                                      readCourseProgress: () =>
                                          widget.readCourseProgress(),
                                      enrolledCourse: widget.enrolledCourse)
                                //Added below condition to handle course item
                                else if (hasModuleInChildren(
                                    navigationItems[i])) ...[
                                  CourseLevelModuleItem(
                                      index: i,
                                      content: navigationItems,
                                      isCuratedProgram: isCuratedProgram,
                                      course: widget.course,
                                      courseHierarchyInfo: courseHierarchyInfo,
                                      batchId: batchId,
                                      contentProgressResponse:
                                          widget.contentProgressResponse,
                                      showCertificateIcon: showCertificateIcon,
                                      showCertificate: [],
                                      showProgress: showProgress,
                                      lastAccessContentId:
                                          widget.lastAccessContentId,
                                      startNewResourse: widget.startNewResourse,
                                      isPlayer: widget.isPlayer,
                                      enrolmentList: widget.enrolmentList,
                                      readCourseProgress: () =>
                                          widget.readCourseProgress(),
                                      enrolledCourse: widget.enrolledCourse)
                                ] else
                                  Container(
                                    padding: EdgeInsets.only(top: 16),
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
                                                      ? navigationItems[i][0]
                                                          ['moduleName']
                                                      : navigationItems[i][0]
                                                          ['courseName'],
                                                  glanceListItems:
                                                      navigationItems[i],
                                                  contentProgressResponse: widget
                                                      .contentProgressResponse,
                                                  navigation: navigationItems,
                                                  batchId: batchId,
                                                  isCourse: navigationItems[i][0]
                                                              ['moduleName'] !=
                                                          null
                                                      ? false
                                                      : true,
                                                  isFeatured: widget.isFeatured,
                                                  duration: navigationItems[i][0]['moduleDuration'] != null
                                                      ? navigationItems[i][0]
                                                          ['moduleDuration']
                                                      : navigationItems[i][0]
                                                          ['courseDuration'],
                                                  parentCourseId: navigationItems[i]
                                                      [0]['parentCourseId'],
                                                  showProgress: showProgress,
                                                  courseHierarchyInfo: courseHierarchyInfo,
                                                  lastAccessContentId: widget.lastAccessContentId,
                                                  startNewResourse: widget.startNewResourse,
                                                  isPlayer: widget.isPlayer,
                                                  navigationItems: navigationItems,
                                                  enrolmentList: widget.enrolmentList,
                                                  readCourseProgress: () => widget.readCourseProgress(),
                                                  enrolledCourse: widget.enrolledCourse)
                                              : Center(),
                                        ],
                                      ),
                                    ),
                                  ),
                              ]
                          ],
                        ))),
              )
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
    } else {
      return Center();
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
