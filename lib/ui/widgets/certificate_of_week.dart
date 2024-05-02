import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gyaan_karmayogi_resource_list/utils/app_colors.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/app_routes.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/models/_arguments/course_toc_model.dart';
import 'package:karmayogi_mobile/models/_models/course_model.dart';
import 'package:karmayogi_mobile/models/_models/telemetry_event_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/learn/show_all_courses.dart';
import 'package:karmayogi_mobile/ui/skeleton/pages/course_card_skeleton_page.dart';
import 'package:karmayogi_mobile/ui/widgets/_home/course_card.dart';
import 'package:karmayogi_mobile/ui/widgets/title_semibold_size16.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:karmayogi_mobile/util/telemetry.dart';
import 'package:karmayogi_mobile/util/telemetry_db_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class CertificateOfWeek extends StatefulWidget {
  final certificateOfWeekList;
  final List<Course> enrolmentList;
  CertificateOfWeek({Key key, this.certificateOfWeekList, this.enrolmentList})
      : super(key: key);

  @override
  _CertificateOfWeekState createState() => _CertificateOfWeekState();
}

class _CertificateOfWeekState extends State<CertificateOfWeek> {
  final _controller = PageController();

  String userId;
  String userSessionId;
  String messageIdentifier;
  String departmentId;
  List allEventsData;
  bool dataSent;
  String deviceIdentifier;
  var telemetryEventData;
  String courseId = '';
  String batchId = '';
  String sessionId = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _generateInteractTelemetryData(String contentId,
      {String subType,
      String primaryCategory,
      bool isObjectNull = false}) async {
    Map eventData = Telemetry.getInteractTelemetryEvent(
        deviceIdentifier,
        userId,
        departmentId,
        TelemetryPageIdentifier.homePageId,
        userSessionId,
        messageIdentifier,
        contentId,
        subType,
        env: TelemetryEnv.home,
        objectType: primaryCategory != null
            ? primaryCategory
            : (isObjectNull ? null : subType));
    // allEventsData.add(eventData);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());
  }

  @override
  Widget build(BuildContext context) {
    return widget.certificateOfWeekList == null
        ? CourseCardSkeletonPage()
        : widget.certificateOfWeekList.runtimeType == String
            ? Center()
            : widget.certificateOfWeekList.isEmpty
                ? Center()
                : Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(0, 16, 0, 15),
                        child: Row(
                          children: [
                            TitleSemiboldSize16(AppLocalizations.of(context)
                                .mStaticCertificateOfWeek),
                            Spacer(),
                            widget.certificateOfWeekList.length >
                                    SHOW_ALL_DISPLAY_COUNT
                                ? InkWell(
                                    onTap: () {
                                      _generateInteractTelemetryData(
                                          TelemetryIdentifier.showAll,
                                          subType: TelemetrySubType
                                              .certificationsOfTheWeek,
                                          isObjectNull: true);
                                      Navigator.push(
                                        context,
                                        FadeRoute(
                                            page: ShowAllCourses(
                                                courseList: widget
                                                    .certificateOfWeekList,
                                                title: AppLocalizations.of(
                                                        context)
                                                    .mStaticCertificateOfWeek)),
                                      );
                                    },
                                    child: SizedBox(
                                      width: 60,
                                      child: Text(
                                        AppLocalizations.of(context)
                                            .mCommonShowAll,
                                        style: GoogleFonts.lato(
                                          color: AppColors.darkBlue,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14,
                                          letterSpacing: 0.12,
                                        ),
                                      ),
                                    ))
                                : Center()
                          ],
                        ),
                      ),
                      Container(
                        height: 310,
                        width: double.infinity,
                        margin:
                            const EdgeInsets.only(left: 0, top: 5, bottom: 4),
                        child: Column(
                          children: [
                            Expanded(
                              child: PageView.builder(
                                controller: _controller,
                                itemCount: widget.certificateOfWeekList.length <
                                        CERTIFICATE_COUNT
                                    ? widget.certificateOfWeekList.length
                                    : CERTIFICATE_COUNT,
                                itemBuilder: (context, index) {
                                  return courseCardWidget(index);
                                },
                              ),
                            ),
                            SizedBox(height: 16),
                            widget.certificateOfWeekList.length > 1
                                ? SmoothPageIndicator(
                                    controller: _controller,
                                    count: widget.certificateOfWeekList.length <
                                            4
                                        ? widget.certificateOfWeekList.length
                                        : 4,
                                    effect: ExpandingDotsEffect(
                                        activeDotColor:
                                            AppColors.orangeTourText,
                                        dotColor: AppColors.profilebgGrey20,
                                        dotHeight: 4,
                                        dotWidth: 4,
                                        spacing: 4),
                                  )
                                : Center()
                          ],
                        ),
                      ),
                    ],
                  );
  }

  Widget courseCardWidget(int index) {
    return InkWell(
        onTap: () async {
          _generateInteractTelemetryData(widget.certificateOfWeekList[index].id,
              subType: TelemetrySubType.certificationsOfTheWeek,
              primaryCategory: TelemetryObjectType.certificate);
          Navigator.pushNamed(context, AppUrl.courseTocPage,
              arguments: CourseTocModel.fromJson(
                  {'courseId': widget.certificateOfWeekList[index].id}));
        },
        child: CourseCard(course: widget.certificateOfWeekList[index]));
  }

  dynamic checkCourseEnrolled(String id) {
    if (widget.enrolmentList == null && widget.enrolmentList.isEmpty) {
      return null;
    } else {
      return widget.enrolmentList.firstWhere(
        (element) => element.raw['courseId'] == id,
        orElse: () => null,
      );
    }
  }
}
