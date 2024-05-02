import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/ui/widgets/_learn/glance_item_3.dart';

import '../../../constants/_constants/app_constants.dart';
import '../../../constants/_constants/app_routes.dart';
import '../../../constants/_constants/color_constants.dart';
import '../../../constants/_constants/telemetry_constants.dart';
import '../../../models/_arguments/toc_player_model.dart';
import '../../../models/index.dart';
import '../../../respositories/_respositories/in_app_review_repository.dart';
import '../../../services/_services/telemetry_service.dart';
import '../../../util/telemetry.dart';
import '../../../util/telemetry_db_helper.dart';
import '../../pages/_pages/toc/util/toc_helper.dart';
import '../../pages/_pages/toc/widgets/course_at_glance_widget.dart';
import '../../pages/_pages/toc/widgets/linear_progress_indicator.dart';
import '../../pages/_pages/toc/widgets/rate_now_pop_up.dart';
import '../../pages/_pages/toc/widgets/toc_download_certificate.dart';

class ModuleItem extends StatefulWidget {
  final course, navigationItems;
  final int moduleIndex;
  final String moduleName;
  final List glanceListItems;
  final contentProgressResponse;
  final navigation;
  final bool initiallyExpanded;
  final String batchId, lastAccessContentId;
  final ValueChanged<bool> parentAction;
  final isCourse;
  final bool isFeatured, isPlayer;
  final dynamic duration;
  final String parentCourseId;
  final bool showProgress;
  final courseHierarchyInfo;
  final int itemCount;
  final ValueChanged<String> startNewResourse;
  final List<Course> enrolmentList;
  final VoidCallback readCourseProgress;
  final Course enrolledCourse;

  const ModuleItem(
      {Key key,
      this.course,
      this.moduleIndex,
      this.moduleName,
      this.glanceListItems,
      this.contentProgressResponse,
      this.navigation,
      this.initiallyExpanded = false,
      this.batchId,
      this.parentAction,
      this.isCourse = false,
      this.isFeatured = false,
      this.duration,
      this.parentCourseId,
      this.showProgress = false,
      this.courseHierarchyInfo,
      this.itemCount = 0,
      this.lastAccessContentId,
      this.startNewResourse,
      this.isPlayer = false,
      this.navigationItems,
      this.enrolmentList,
      this.readCourseProgress,
      this.enrolledCourse})
      : super(key: key);

  @override
  _ModuleItemState createState() => _ModuleItemState();
}

class _ModuleItemState extends State<ModuleItem> {
  final TelemetryService telemetryService = TelemetryService();
  double _moduleProgress = 0;

  String userId;
  String userSessionId;
  String messageIdentifier;
  String departmentId;
  String pageIdentifier;
  List _glanceListItems;
  String deviceIdentifier;
  var telemetryEventData;
  bool showCertificate = false;
  bool isCuratedProgram = false, isExpanded = false;
  String _lastAccessContentId;

  @override
  void initState() {
    super.initState();
    _lastAccessContentId = widget.lastAccessContentId;
    if (widget.course['cumulativeTracking'] != null) {
      if (widget.course['cumulativeTracking']) {
        isCuratedProgram = true;
      }
    }
    _glanceListItems = widget.glanceListItems;
    if (widget.isPlayer) {
      isLastAccessedContentExist();
    }
    if (!widget.isFeatured) {
      _generateTelemetryData();
    }
  }

  void _generateTelemetryData() async {
    deviceIdentifier = await Telemetry.getDeviceIdentifier();
    userId = await Telemetry.getUserId();
    userSessionId = await Telemetry.generateUserSessionId();
    messageIdentifier = await Telemetry.generateUserSessionId();
    departmentId = await Telemetry.getUserDeptId();
  }

  void _generateInteractTelemetryData(
      String contentId, String primaryType) async {
    Map eventData = Telemetry.getInteractTelemetryEvent(
        deviceIdentifier,
        userId,
        departmentId,
        TelemetryPageIdentifier.courseDetailsPageId,
        userSessionId,
        messageIdentifier,
        contentId,
        TelemetrySubType.contentCard,
        env: TelemetryEnv.learn,
        objectType: primaryType,
        isPublic: widget.isFeatured);
    List allEventsData = [];
    allEventsData.add(eventData);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());
  }

  void _calculateModuleProgress() {
    double _moduleProgressSum = 0.0;
    for (int i = 0; i < _glanceListItems.length; i++) {
      if (_glanceListItems[i]['status'] == 2) {
        _moduleProgressSum = _moduleProgressSum + 1;
      } else if (_glanceListItems[i]['completionPercentage'] != '0' &&
          _glanceListItems[i]['completionPercentage'] != null) {
        _moduleProgressSum = _moduleProgressSum +
            double.parse(
                _glanceListItems[i]['completionPercentage'].toString());
      }
    }
    _moduleProgress = _moduleProgressSum / _glanceListItems.length;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ModuleItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((_lastAccessContentId != widget.lastAccessContentId) &&
        widget.isPlayer) {
      _lastAccessContentId = widget.lastAccessContentId;
      setState(() {
        isExpanded = false;
      });
      isLastAccessedContentExist();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isFeatured) {
      _calculateModuleProgress();
    }
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
              color: isExpanded && widget.isCourse
                  ? AppColors.darkBlue
                  : AppColors.appBarBackground),
          color: isExpanded
              ? widget.isCourse
                  ? AppColors.darkBlue
                  : AppColors.whiteGradientOne
              : AppColors.appBarBackground),
      child: Column(
        children: [
          ExpansionTile(
              key: UniqueKey(),
              onExpansionChanged: (value) {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              childrenPadding: EdgeInsets.zero,
              initiallyExpanded: isExpanded,
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      child: Container(
                    padding: const EdgeInsets.only(left: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        !widget.isCourse &&
                                widget.enrolledCourse != null &&
                                widget.showProgress
                            ? Padding(
                                padding:
                                    const EdgeInsets.only(top: 4, right: 6),
                                child: _moduleProgress == 1 ||
                                        widget.enrolledCourse
                                                .completionPercentage ==
                                            100
                                    ? Icon(Icons.check_circle,
                                        size: 22, color: AppColors.darkBlue)
                                    : Container(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          backgroundColor: AppColors.grey16,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            _moduleProgress > 0 &&
                                                    _moduleProgress < 1
                                                ? AppColors.primaryOne
                                                : AppColors.appBarBackground,
                                          ),
                                          strokeWidth: 3,
                                          value: double.parse(
                                              _moduleProgress.toString()),
                                        ),
                                      ))
                            : Center(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.7,
                                  child: Text(
                                    '${widget.moduleIndex + 1}.  ${widget.moduleName}',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: GoogleFonts.montserrat(
                                        height: 1.5,
                                        decoration: TextDecoration.none,
                                        color: isExpanded
                                            ? widget.isCourse
                                                ? AppColors.appBarBackground
                                                : AppColors.darkBlue
                                            : AppColors.greys87,
                                        fontSize: 16,
                                        fontWeight: isExpanded
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        letterSpacing: 0.12),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                CourseAtGlanceWidget(
                                    courseInfo: widget
                                        .navigation[widget.moduleIndex][0],
                                    courseHierarchyInfo:
                                        widget.courseHierarchyInfo,
                                    isExpanded: isExpanded,
                                    isCourse: widget.isCourse,
                                    duration: widget.duration,
                                    itemCount: widget.itemCount),
                              ],
                            ),
                            SizedBox(height: 8),
                            widget.enrolledCourse == null
                                ? Center()
                                : widget.showProgress
                                    ? (_moduleProgress >= 1 ||
                                                widget.enrolledCourse
                                                        .completionPercentage ==
                                                    100) &&
                                            widget.isCourse
                                        ? TocDownloadCertificateWidget(
                                            courseId: widget.parentCourseId,
                                            isPlayer: widget.isPlayer,
                                            isExpanded: isExpanded)
                                        : _moduleProgress <= 0
                                            ? Center()
                                            : widget.isCourse
                                                ? LinearProgressIndicatorWidget(
                                                    value: _moduleProgress,
                                                    isExpnaded: isExpanded,
                                                    isCourse: widget.isCourse,
                                                  )
                                                : Center()
                                    : Center()
                          ],
                        ),
                      ],
                    ),
                  )),
                ],
              ),
              trailing: isExpanded
                  ? Icon(
                      widget.isCourse ? Icons.arrow_drop_up : Icons.minimize,
                      color: widget.isCourse
                          ? AppColors.appBarBackground
                          : AppColors.darkBlue,
                    )
                  : Icon(
                      widget.isCourse ? Icons.arrow_drop_down : Icons.add,
                      color: AppColors.darkBlue,
                    ),
              children: [
                for (int i = 0; i < _glanceListItems.length; i++)
                  if (_glanceListItems[i][0] == null) ...[
                    Container(
                      width: MediaQuery.of(context).size.width,
                      color: isExpanded
                          ? AppColors.whiteGradientOne
                          : AppColors.appBarBackground,
                      child: InkWell(
                        onTap: () async {
                          if (!widget.isFeatured) {
                            _generateInteractTelemetryData(
                                _glanceListItems[i]['identifier'],
                                _glanceListItems[i]['primaryCategory']);
                          }
                          if (widget.isPlayer) {
                            widget.startNewResourse(
                                _glanceListItems[i]['contentId']);
                          } else if (widget.showProgress) {
                            var result;
                            if ((widget.course['courseCategory'] ==
                                        PrimaryCategory.moderatedProgram ||
                                    widget.course['courseCategory'] ==
                                        PrimaryCategory.blendedProgram) &&
                                TocHelper()
                                    .isProgramLive(widget.enrolledCourse)) {
                              result = await Navigator.pushNamed(
                                context,
                                AppUrl.tocPlayer,
                                arguments: TocPlayerModel.fromJson(
                                  {
                                    'enrolmentList': widget.enrolmentList,
                                    'navigationItems': widget.navigationItems,
                                    'isCuratedProgram': isCuratedProgram,
                                    'batchId': widget.batchId,
                                    'lastAccessContentId': _glanceListItems[i]
                                        ['contentId'],
                                    'courseId': widget.course['identifier']
                                  },
                                ),
                              );
                            } else if (widget.course['courseCategory'] !=
                                    PrimaryCategory.moderatedProgram &&
                                widget.course['courseCategory'] !=
                                    PrimaryCategory.blendedProgram) {
                              result = await Navigator.pushNamed(
                                context,
                                AppUrl.tocPlayer,
                                arguments: TocPlayerModel.fromJson(
                                  {
                                    'enrolmentList': widget.enrolmentList,
                                    'navigationItems': widget.navigationItems,
                                    'isCuratedProgram': isCuratedProgram,
                                    'batchId': widget.batchId,
                                    'lastAccessContentId': _glanceListItems[i]
                                        ['contentId'],
                                    'courseId': widget.course['identifier']
                                  },
                                ),
                              );
                            }
                            if (result != null && result is Map<String, bool>) {
                              Map<String, dynamic> response = result;
                              if (response['isFinished']) {
                                showModalBottomSheet(
                                        isScrollControlled: true,
                                        context: context,
                                        backgroundColor: AppColors.greys60,
                                        builder: (ctx) => RateNowPopUp(
                                            courseDetails:
                                                Course.fromJson(widget.course)))
                                    .whenComplete(() => InAppReviewRespository()
                                        .triggerInAppReviewPopup());
                              }
                            }
                            widget.readCourseProgress();
                          }
                        },
                        child: _glanceListItems[i]['mimeType'] != null
                            ? _glanceListItems[i]['mimeType'] ==
                                    EMimeTypes.offline
                                ? Center()
                                : GlanceItem3(
                                    icon: _glanceListItems[i]['mimeType'] ==
                                                EMimeTypes.mp4 ||
                                            _glanceListItems[i]['mimeType'] ==
                                                EMimeTypes.m3u8
                                        ? 'assets/img/icons-av-play.svg'
                                        : _glanceListItems[i]['mimeType'] ==
                                                EMimeTypes.mp3
                                            ? 'assets/img/audio.svg'
                                            : (_glanceListItems[i]
                                                            ['mimeType'] ==
                                                        EMimeTypes
                                                            .externalLink ||
                                                    _glanceListItems[i]
                                                            ['mimeType'] ==
                                                        EMimeTypes.youtubeLink)
                                                ? 'assets/img/link.svg'
                                                : _glanceListItems[i]
                                                            ['mimeType'] ==
                                                        EMimeTypes.pdf
                                                    ? 'assets/img/icons-file-types-pdf-alternate.svg'
                                                    : (_glanceListItems[i]['mimeType'] ==
                                                                EMimeTypes
                                                                    .assessment ||
                                                            _glanceListItems[i]
                                                                    ['mimeType'] ==
                                                                EMimeTypes.newAssessment)
                                                        ? 'assets/img/assessment_icon.svg'
                                                        : 'assets/img/resource.svg',
                                    text: _glanceListItems[i]['name'],
                                    status: widget.enrolledCourse != null &&
                                            widget.enrolledCourse
                                                    .completionPercentage ==
                                                100
                                        ? 2
                                        : _glanceListItems[i]['status'],
                                    duration: _glanceListItems[i]['duration'],
                                    isFeaturedCourse: widget.isFeatured,
                                    currentProgress:
                                        widget.enrolledCourse != null &&
                                                widget.enrolledCourse
                                                        .completionPercentage ==
                                                    100
                                            ? 1
                                            : _glanceListItems[i]
                                                ['completionPercentage'],
                                    showProgress: widget.showProgress,
                                    isExpanded: isExpanded,
                                    isLastAccessed:
                                        widget.lastAccessContentId ==
                                            _glanceListItems[i]['contentId'],
                                    isEnrolled: widget.isPlayer
                                        ? true
                                        : widget.enrolledCourse != null,
                                    maxQuestions: (_glanceListItems[i]
                                                ['maxQuestions'] ??
                                            '')
                                        .toString(),
                                    mimeType:
                                        (_glanceListItems[i]['mimeType'] ?? '')
                                            .toString(),
                                  )
                            : Container(
                                padding: EdgeInsets.all(8),
                                child: Text('No contents available')),
                      ),
                    ),
                  ],
                !widget.isCourse
                    ? Container(
                        height: 4,
                        width: double.infinity,
                        color: Colors.grey,
                      )
                    : Center(),
              ]),
          !widget.isCourse &&
                  !isExpanded &&
                  widget.course['cumulativeTracking'] != null &&
                  widget.course['cumulativeTracking']
              ? Container(
                  height: 4,
                  width: MediaQuery.of(context).size.width,
                  color: AppColors.grey08,
                )
              : Center()
        ],
      ),
    );
  }

  void isLastAccessedContentExist() {
    for (var content in _glanceListItems) {
      if (content['contentId'] == widget.lastAccessContentId) {
        setState(() {
          isExpanded = true;
        });
        break;
      }
    }
  }
}
