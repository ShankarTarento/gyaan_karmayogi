import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../constants/_constants/telemetry_constants.dart';
import '../../../../constants/index.dart';
import '../../../../localization/index.dart';
import '../../../../models/_arguments/index.dart';
import '../../../../models/index.dart';
import '../../../../util/telemetry.dart';
import '../../../../util/telemetry_db_helper.dart';
import '../../../pages/index.dart';
import '../../index.dart';

class TimelinesViewWidget extends StatefulWidget {
  const TimelinesViewWidget(
      {Key key,
      @required this.allCourseList,
      @required this.upcomingCourseList,
      @required this.overdueCourseList,
      @required this.filterParentAction})
      : super(key: key);

  final List<Course> allCourseList;
  final List<Course> upcomingCourseList;
  final List<Course> overdueCourseList;
  final ValueChanged<List<dynamic>> filterParentAction;

  @override
  State<TimelinesViewWidget> createState() => _TimelinesViewWidgetState();
}

class _TimelinesViewWidgetState extends State<TimelinesViewWidget>
    with SingleTickerProviderStateMixin {
  TabController cbptabController;
  bool isLoad = false;

  @override
  void initState() {
    super.initState();
  }

  void _generateInteractTelemetryData(String contentId,
      {String subType, String primaryCategory, String clickId}) async {
    String deviceIdentifier = await Telemetry.getDeviceIdentifier();
    String userId = await Telemetry.getUserId();
    String userSessionId = await Telemetry.generateUserSessionId();
    String messageIdentifier = await Telemetry.generateUserSessionId();
    String departmentId = await Telemetry.getUserDeptId();
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
        objectType: primaryCategory != null ? primaryCategory : subType,
        clickId: clickId);
    // allEventsData.add(eventData);
    log(eventData.toString());
    var telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());
  }

  @override
  Widget build(BuildContext context) {
    List tabNames = [
      AppLocalizations.of(context).mStaticUpcoming,
      AppLocalizations.of(context).mStaticOverdue
    ];
    if (!isLoad) {
      if (widget.upcomingCourseList.length > 0 ||
          (widget.upcomingCourseList.length == 0 &&
              widget.overdueCourseList.length == 0)) {
        cbptabController = TabController(
            length: tabNames.length, vsync: this, initialIndex: 0);
      } else {
        cbptabController = TabController(
            length: tabNames.length, vsync: this, initialIndex: 1);
      }
      isLoad = true;
    }
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 500,
      margin: const EdgeInsets.only(left: 0, top: 5, bottom: 15),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.darkBlue, width: 1),
          color: AppColors.darkBlueGradient8),
      child: DefaultTabController(
        length: tabNames.length,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 50, // Height of the TabBar
              child: TabBar(
                padding: EdgeInsets.only(left: 20),
                isScrollable: true,
                controller: cbptabController,
                indicator: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.darkBlue,
                      width: 2.0,
                    ),
                  ),
                ),
                indicatorColor: Colors.white,
                labelPadding: EdgeInsets.only(right: 8.0),
                unselectedLabelColor: AppColors.greys60,
                labelColor: Colors.black,
                labelStyle: GoogleFonts.lato(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w700,
                  color: AppColors.greys87,
                ),
                indicatorSize: TabBarIndicatorSize.label,
                unselectedLabelStyle: GoogleFonts.lato(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400,
                  color: AppColors.greys60,
                ),
                tabs: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Tab(
                      child: Padding(
                        padding: EdgeInsets.all(5.0),
                        child: SizedBox(
                          child: Center(
                              child: Text(widget.upcomingCourseList.length > 0
                                  ? AppLocalizations.of(context)
                                          .mStaticUpcoming +
                                      ' (' +
                                      widget.upcomingCourseList.length
                                          .toString() +
                                      ')'
                                  : AppLocalizations.of(context)
                                      .mStaticUpcoming)),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Tab(
                      child: Padding(
                        padding: EdgeInsets.all(5.0),
                        child: SizedBox(
                          child: Center(
                            child: Text(widget.overdueCourseList.length > 0
                                ? AppLocalizations.of(context).mStaticOverdue +
                                    ' (' +
                                    widget.overdueCourseList.length.toString() +
                                    ')'
                                : AppLocalizations.of(context).mStaticOverdue),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: TabBarView(
                  controller: cbptabController,
                  children: [
                    courseCardWidget(widget.upcomingCourseList,
                        AppLocalizations.of(context).mStaticUpcoming),
                    courseCardWidget(widget.overdueCourseList,
                        AppLocalizations.of(context).mStaticOverdue)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget courseCardWidget(List courseList, String category) {
    return courseList.length > 0
        ? Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount:
                          courseList.length >= CBP_COURSE_ON_TIMELINE_LIST_LIMIT
                              ? CBP_COURSE_ON_TIMELINE_LIST_LIMIT
                              : courseList.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                            onTap: () async {
                              _generateInteractTelemetryData(
                                  courseList[index].id,
                                  primaryCategory:
                                      courseList[index].contentType,
                                  clickId: TelemetryIdentifier.cardContent,
                                  subType: TelemetrySubType.myIgot);
                              Navigator.pushNamed(context, AppUrl.courseTocPage,
                                  arguments: CourseTocModel.fromJson(
                                      {'courseId': courseList[index].id}));
                            },
                            child: CbpCourseCard(course: courseList[index]));
                      }),
                ),
                courseList.length > CBP_COURSE_ON_TIMELINE_LIST_LIMIT
                    ? Consumer<CBPFilter>(
                        builder: (context, filterProvider, _) {
                        var filtersList = List.from(filterProvider.filters);
                        return InkWell(
                          onTap: () {
                            filtersList.forEach((element) {
                              element.filters.forEach((item) {
                                if (item.isSelected) {
                                  item.isSelected = false;
                                }
                              });
                            });
                            filtersList.forEach((element) {
                              if (cbptabController.index == 0) {
                                if (element.category ==
                                        CBPFilterCategory.status ||
                                    element.category ==
                                        CBPFilterCategory.timeDuration) {
                                  for (int filterIndex = 0;
                                      filterIndex < element.filters.length;
                                      filterIndex++) {
                                    var item = element.filters[filterIndex];
                                    if (item.name ==
                                            CBPCourseStatus.notStarted ||
                                        item.name ==
                                            CBPCourseStatus.inProgress ||
                                        item.name ==
                                            CBPCourseStatus.completed ||
                                        item.name ==
                                            CBPFilterTimeDuration
                                                .upcoming30days) {
                                      filterProvider.toggleFilter(
                                          element.category, filterIndex);
                                    }
                                  }
                                }
                              } else {
                                if (element.category ==
                                        CBPFilterCategory.status ||
                                    element.category ==
                                        CBPFilterCategory.timeDuration) {
                                  for (int filterIndex = 0;
                                      filterIndex < element.filters.length;
                                      filterIndex++) {
                                    var item = element.filters[filterIndex];
                                    if (item.name ==
                                            CBPCourseStatus.notStarted ||
                                        item.name ==
                                            CBPCourseStatus.inProgress ||
                                        item.name ==
                                            CBPFilterTimeDuration.last3month) {
                                      filterProvider.toggleFilter(
                                          element.category, filterIndex);
                                    }
                                  }
                                }
                              }
                            });
                            widget.filterParentAction(filtersList);
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              AppLocalizations.of(context).mLearnShowAll,
                              style: GoogleFonts.lato(
                                color: AppColors.darkBlue,
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                letterSpacing: 0.12,
                              ),
                            ),
                          ),
                        );
                      })
                    : Center()
              ],
            ),
          )
        : NoDataWidget(
            message: category == AppLocalizations.of(context).mStaticUpcoming
                ? AppLocalizations.of(context).mStaticDueDateWithin30DaysMessage
                : AppLocalizations.of(context)
                    .mStaticSeeContentForWhichDueDatePassed);
  }
}
