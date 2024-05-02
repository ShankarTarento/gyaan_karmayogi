import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gyaan_karmayogi_resource_list/utils/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/app_routes.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/models/_arguments/course_toc_model.dart';
import 'package:karmayogi_mobile/models/_models/cbplan_model.dart';
import 'package:karmayogi_mobile/models/_models/course_model.dart';
import 'package:karmayogi_mobile/models/_models/telemetry_event_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/cbp/mycbp_plan_page.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/my_learnings/no_data_widget.dart';
import 'package:karmayogi_mobile/ui/skeleton/pages/course_card_skeleton_page.dart';
import 'package:karmayogi_mobile/ui/widgets/_home/course_card.dart';
import 'package:karmayogi_mobile/ui/widgets/_learn/trending_course_widget.dart';
import 'package:karmayogi_mobile/ui/widgets/title_semibold_size16.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:karmayogi_mobile/util/telemetry.dart';
import 'package:karmayogi_mobile/util/telemetry_db_helper.dart';

class CbpCoursePage extends StatefulWidget {
  final CbPlanModel cbpCourseData;
  final List<Course> enrolledCourseList;

  CbpCoursePage(
      {Key key,
      @required this.cbpCourseData,
      @required this.enrolledCourseList})
      : super(key: key);

  @override
  CbpCoursePageState createState() => CbpCoursePageState();
}

class CbpCoursePageState extends State<CbpCoursePage>
    with SingleTickerProviderStateMixin {
  List cbpCourseList = [];
  List<Course> allCourse = [], upcomingCourse = [], overdueCourse = [];
  TabController cbptabController;
  List<Course> enrolmentList;
  bool isLoad = false;

  @override
  void initState() {
    super.initState();
    cbpCourseList = widget.cbpCourseData.content;
    enrolmentList = widget.enrolledCourseList;
  }

  @override
  void dispose() {
    cbptabController.dispose();
    super.dispose();
  }

  void _generateInteractTelemetryData(String contentId,
      {String subType,
      String primaryCategory,
      String objectType,
      String clickId}) async {
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
        objectType: primaryCategory != null ? primaryCategory : objectType,
        clickId: clickId);
    var telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());
  }

  @override
  Widget build(BuildContext context) {
    List tabNames = [
      AppLocalizations.of(context).mStaticAll,
      AppLocalizations.of(context).mStaticUpcoming,
      AppLocalizations.of(context).mStaticOverdue
    ];
    if (!isLoad) {
      cbptabController =
          TabController(length: tabNames.length, vsync: this, initialIndex: 0);
      getCourseCategoryList();
      isLoad = true;
    }
    return Container(
      color: AppColors.whiteGradientOne,
      child: Column(
        children: [
          Container(
              padding: EdgeInsets.fromLTRB(17, 8, 17, 16),
              child: Row(
                children: [
                  TitleSemiboldSize16(
                      AppLocalizations.of(context).mStaticAcbpBannerTitle),
                  Spacer(),
                  InkWell(
                      onTap: () {
                        _generateInteractTelemetryData(
                            TelemetryIdentifier.showAll,
                            subType: TelemetrySubType.myIgot);
                        Navigator.push(
                          context,
                          FadeRoute(
                              page: MyCbpPlanPage(
                            allCourseList: allCourse,
                            upcomingCourseList: upcomingCourse,
                            overdueCourseList: overdueCourse,
                          )),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 2.0),
                        child: SizedBox(
                          width: 60,
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
              )),
          Container(
            height: 400,
            width: double.infinity,
            margin: const EdgeInsets.only(left: 0, top: 5, bottom: 15),
            child: DefaultTabController(
              length: tabNames.length,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: 50, // Height of the TabBar
                    child: TabBar(
                      padding: EdgeInsets.only(left: 20),
                      isScrollable: false,
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
                      onTap: (value) {
                        _generateInteractTelemetryData(
                            cbptabController.index == 0
                                ? TelemetryIdentifier.allTab
                                : cbptabController.index == 1
                                    ? TelemetryIdentifier.upcomingTab
                                    : TelemetryIdentifier.overdueTab,
                            subType: TelemetrySubType.myIgot);
                      },
                      tabs: [
                        for (var tabItem in tabNames)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Tab(
                              child: Padding(
                                padding: EdgeInsets.all(5.0),
                                child: SizedBox(
                                  child: Center(
                                    child: Text(tabItem ==
                                            AppLocalizations.of(context)
                                                .mStaticAll
                                        ? allCourse.length > 0
                                            ? tabItem +
                                                ' (' +
                                                allCourse.length.toString() +
                                                ')'
                                            : tabItem
                                        : tabItem ==
                                                AppLocalizations.of(context)
                                                    .mStaticUpcoming
                                            ? upcomingCourse.length > 0
                                                ? tabItem +
                                                    ' (' +
                                                    upcomingCourse.length
                                                        .toString() +
                                                    ')'
                                                : tabItem
                                            : overdueCourse.length > 0
                                                ? tabItem +
                                                    ' (' +
                                                    overdueCourse.length
                                                        .toString() +
                                                    ')'
                                                : tabItem),
                                  ),
                                ),
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: TabBarView(
                        controller: cbptabController,
                        children: [
                          courseCardWidget(allCourse,
                              AppLocalizations.of(context).mCommonAll),
                          courseCardWidget(upcomingCourse,
                              AppLocalizations.of(context).mStaticUpcoming),
                          courseCardWidget(overdueCourse,
                              AppLocalizations.of(context).mStaticOverdue)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget courseCardWidget(List courseList, String category) {
    return courseList.length > 0
        ? Padding(
            padding: const EdgeInsets.only(left: 16),
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: courseList.length,
                itemBuilder: (context, index) {
                  return Row(children: [
                    InkWell(
                        onTap: () async {
                          _generateInteractTelemetryData(courseList[index].id,
                              primaryCategory: courseList[index].contentType,
                              subType: TelemetrySubType.myIgot,
                              clickId: TelemetryIdentifier.cardContent);
                          Navigator.pushNamed(
                            context,
                            AppUrl.courseTocPage,
                            arguments: CourseTocModel.fromJson(
                              {'courseId': courseList[index].id},
                            ),
                          );
                        },
                        child: CourseCard(course: courseList[index])),
                  ]);
                }),
          )
        : NoDataWidget(
            message: category == AppLocalizations.of(context).mStaticUpcoming
                ? AppLocalizations.of(context).mStaticDueDateWithin30DaysMessage
                : AppLocalizations.of(context)
                    .mStaticSeeContentForWhichDueDatePassed);
  }

  void getCourseCategoryList() {
    allCourse = [];
    upcomingCourse = [];
    overdueCourse = [];
    //Filter unique courses
    cbpCourseList.forEach((contents) {
      if (contents != null) {
        contents.contentList.forEach((content) {
          if (checkUniqueCourse(content) &&
              content.raw['status'] != 'Retired') {
            allCourse.add(content);
          }
        });
      }
    });
    if (allCourse.isNotEmpty) {
      // Sort courses based on time stamp ascending order
      allCourse.sort(((a, b) =>
          DateTime.parse(a.endDate).compareTo(DateTime.parse(b.endDate))));

      // If course is overdue sort courses based on time stamp descending order
      List<Course> upcomingList = [], overdueList = [];
      allCourse.forEach((content) {
        int dateDiff = getTimeDiff(content.endDate, DateTime.now().toString());
        if (dateDiff >= 0) {
          upcomingList.add(content);
        } else {
          overdueList.add(content);
        }
      });
      overdueList.sort(((a, b) =>
          DateTime.parse(b.endDate).compareTo(DateTime.parse(a.endDate))));
      allCourse.clear();
      allCourse.addAll(overdueList);
      allCourse.addAll(upcomingList);
      // If two course have same end date sort ascending order of name
      allCourse.sort(((a, b) {
        int overdueDate1 = getTimeDiff(a.endDate, DateTime.now().toString());
        int overdueDate2 = getTimeDiff(b.endDate, DateTime.now().toString());
        if (overdueDate1 == overdueDate2) {
          String name1 = a.name != null
              ? a.name
              : a.raw['name'] != null
                  ? a.raw['name']
                  : '';
          String name2 = b.name != null
              ? b.name
              : b.raw['name'] != null
                  ? b.raw['name']
                  : '';
          return name2.compareTo(name1);
        } else {
          return 0;
        }
      }));

      // If course is overdue and already completed move to end of list
      int allCourseLength = allCourse.length;
      for (int index = 0; index < allCourseLength; index++) {
        if (getTimeDiff(allCourse[index].endDate, DateTime.now().toString()) <
            0) {
          if (enrolmentList != null) {
            for (int enrollIndex = 0;
                enrollIndex < enrolmentList.length;
                enrollIndex++) {
              var course = enrolmentList[enrollIndex];
              if (course.raw['courseId'] == allCourse[index].id &&
                  course.raw['completionPercentage'] == 100) {
                moveItemToEnd(index);
                index--;
                allCourseLength--;
                break;
              }
            }
          }
        } else {
          break;
        }
      }
      // update upcoming and overdue course list
      allCourse.forEach((content) {
        bool isEnrolled = false;
        int dateDiff = getTimeDiff(content.endDate, DateTime.now().toString());
        if (enrolmentList != null) {
          for (int enrollIndex = 0;
              enrollIndex < enrolmentList.length;
              enrollIndex++) {
            var course = enrolmentList[enrollIndex];
            if (course.raw['courseId'] == content.id) {
              if (course.raw['completionPercentage'] != 100) {
                if (dateDiff >= 0) {
                  if (dateDiff <= CBP_UPCOMING_SHOW_DATE_DIFF) {
                    upcomingCourse.add(content);
                  }
                } else {
                  overdueCourse.add(content);
                }
              }
              isEnrolled = true;
              break;
            }
          }
        }
        if (!isEnrolled) {
          if (dateDiff >= 0) {
            if (dateDiff <= CBP_UPCOMING_SHOW_DATE_DIFF) {
              upcomingCourse.add(content);
            }
          } else {
            overdueCourse.add(content);
          }
        }
      });
      if (upcomingCourse.isNotEmpty) {
        cbptabController.index = 1;
      }
    }
  }

  int getTimeDiff(String date1, String date2) {
    return DateTime.parse(
            DateFormat('yyyy-MM-dd').format(DateTime.parse(date1)))
        .difference(DateTime.parse(
            DateFormat('yyyy-MM-dd').format(DateTime.parse(date2))))
        .inDays;
  }

  bool checkUniqueCourse(Course newItem) {
    bool isUnique = true;
    if (allCourse.isNotEmpty) {
      for (Course element in allCourse) {
        if (element.id == newItem.id) {
          if (getTimeDiff(element.endDate, newItem.endDate) < 0) {
            allCourse.remove(element);
            break;
          } else {
            isUnique = false;
          }
        }
      }
    }
    return isUnique;
  }

  Widget courseWidget({dynamic courseList, String title, bool showShowAll}) {
    return courseList == null
        ? const CourseCardSkeletonPage()
        : courseList.runtimeType == String
            ? Center()
            : courseList.isEmpty
                ? Center()
                : TrendingCourseWidget(
                    trendingList: courseList,
                    title: title,
                    showShowAll: showShowAll ?? true,
                    enrolmentList: widget.enrolledCourseList != null &&
                            widget.enrolledCourseList.isNotEmpty
                        ? widget.enrolledCourseList
                        : []);
  }

  void moveItemToEnd(int currentIndex) {
    if (currentIndex >= 0 && currentIndex < allCourse.length - 1) {
      dynamic item = allCourse.removeAt(currentIndex);
      allCourse.add(item);
    }
  }
}
