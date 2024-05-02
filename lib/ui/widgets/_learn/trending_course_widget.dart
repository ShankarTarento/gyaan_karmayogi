import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../constants/_constants/app_constants.dart';
import '../../../constants/_constants/app_routes.dart';
import '../../../constants/_constants/color_constants.dart';
import '../../../constants/_constants/telemetry_constants.dart';
import '../../../models/_arguments/course_toc_model.dart';
import '../../../models/_models/course_model.dart';
import '../../../models/_models/telemetry_event_model.dart';
import '../../../util/faderoute.dart';
import '../../../util/telemetry.dart';
import '../../../util/telemetry_db_helper.dart';
import '../../pages/_pages/learn/show_all_courses.dart';
import '../_home/course_card.dart';
import '../title_semibold_size16.dart';

class TrendingCourseWidget extends StatelessWidget {
  final List<dynamic> trendingList;
  final List<Course> enrolmentList;
  final String title;
  final bool showShowAll;
  final String telemetrySubType;

  TrendingCourseWidget(
      {Key key,
      this.trendingList,
      this.title,
      this.showShowAll = true,
      this.enrolmentList,
      this.telemetrySubType})
      : super(key: key);

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

  void _generateInteractTelemetryData(String contentId,
      {String subType,
      String primaryCategory,
      bool isObjectNull = false,
      String clickId}) async {
    deviceIdentifier = await Telemetry.getDeviceIdentifier();
    userId = await Telemetry.getUserId();
    userSessionId = await Telemetry.generateUserSessionId();
    messageIdentifier = await Telemetry.generateUserSessionId();
    departmentId = await Telemetry.getUserDeptId();
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
            : (isObjectNull ? null : subType),
        clickId: clickId);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 15),
          child: Row(
            children: [
              Container(
                  width: MediaQuery.of(context).size.width - 100,
                  child: TitleSemiboldSize16(
                    title,
                    maxLines: 2,
                  )),
              Spacer(),
              trendingList.length > SHOW_ALL_DISPLAY_COUNT
                  ? Visibility(
                      visible: showShowAll,
                      child: Container(
                        width: 60,
                        child: InkWell(
                            onTap: () {
                              _generateInteractTelemetryData(
                                  TelemetryIdentifier.showAll,
                                  subType: telemetrySubType,
                                  isObjectNull: true);
                              Navigator.push(
                                context,
                                FadeRoute(
                                    page: ShowAllCourses(
                                        courseList: trendingList,
                                        title: title)),
                              );
                            },
                            child: Text(
                              AppLocalizations.of(context).mStaticShowAll,
                              textAlign: TextAlign.right,
                              style: GoogleFonts.lato(
                                color: AppColors.darkBlue,
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                letterSpacing: 0.12,
                              ),
                            )),
                      ),
                    )
                  : Center()
            ],
          ),
        ),
        Container(
            height: 296,
            width: double.infinity,
            margin: const EdgeInsets.only(left: 0, top: 5, bottom: 15),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: !showShowAll
                  ? trendingList.length
                  : trendingList.length < SHOW_ALL_CHECK_COUNT
                      ? trendingList.length
                      : SHOW_ALL_CHECK_COUNT,
              itemBuilder: (context, index) {
                if ((trendingList.length >
                        (showShowAll
                            ? SHOW_ALL_CHECK_COUNT
                            : trendingList.length) &&
                    index == SHOW_ALL_CHECK_COUNT - 1)) {
                  return Row(
                    children: [
                      InkWell(
                          onTap: () async {
                            _generateInteractTelemetryData(
                                trendingList[index].id,
                                subType: telemetrySubType,
                                primaryCategory:
                                    trendingList[index].contentType,
                                clickId: TelemetryIdentifier.cardContent);
                            Navigator.pushNamed(context, AppUrl.courseTocPage,
                                arguments: CourseTocModel.fromJson(
                                    {'courseId': trendingList[index].id}));
                          },
                          child: CourseCard(course: trendingList[index])),
                      InkWell(
                          onTap: () {
                            _generateInteractTelemetryData(
                              TelemetryIdentifier.showAll,
                              subType: telemetrySubType,
                            );
                            Navigator.push(
                              context,
                              FadeRoute(
                                  page: ShowAllCourses(
                                      courseList: trendingList, title: title)),
                            );
                          },
                          child: Container(
                            height: COURSE_CARD_HEIGHT,
                            width: COURSE_CARD_WIDTH,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.darkBlue)),
                            child: Center(
                              child: Text(
                                AppLocalizations.of(context).mStaticShowAll,
                                style: GoogleFonts.lato(
                                  color: AppColors.darkBlue,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  letterSpacing: 0.12,
                                ),
                              ),
                            ),
                          ))
                    ],
                  );
                } else {
                  return InkWell(
                      onTap: () async {
                        _generateInteractTelemetryData(trendingList[index].id,
                            subType: telemetrySubType,
                            primaryCategory: trendingList[index].contentType,
                            clickId: TelemetryIdentifier.cardContent);
                        Navigator.pushNamed(context, AppUrl.courseTocPage,
                            arguments: CourseTocModel.fromJson(
                                {'courseId': trendingList[index].id}));
                      },
                      child: CourseCard(course: trendingList[index]));
                }
              },
            )),
      ],
    );
  }

  dynamic checkCourseEnrolled(String id) {
    if (enrolmentList == null && enrolmentList.isEmpty) {
      return null;
    } else {
      return enrolmentList.firstWhere(
        (element) => element.raw['contentId'] == id,
        orElse: () => null,
      );
    }
  }
}
