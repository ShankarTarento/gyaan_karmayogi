import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gyaan_karmayogi_resource_list/utils/app_colors.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/models/_models/course_model.dart';
import 'package:karmayogi_mobile/models/_models/telemetry_event_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/my_learnings/no_data_widget.dart';
import 'package:karmayogi_mobile/ui/widgets/_learn/course_progress_card.dart';
import 'package:karmayogi_mobile/ui/widgets/_learn/my_learn_main_tab.dart';
import 'package:karmayogi_mobile/ui/widgets/custom_tabs.dart';
import 'package:karmayogi_mobile/ui/widgets/title_semibold_size16.dart';
import 'package:karmayogi_mobile/util/telemetry.dart';
import 'package:karmayogi_mobile/util/telemetry_db_helper.dart';

class HomeMylearningPage extends StatefulWidget {
  final List<Course> courses;
  const HomeMylearningPage({Key key, this.courses}) : super(key: key);

  @override
  _HomeMylearningPageState createState() => _HomeMylearningPageState();
}

class _HomeMylearningPageState extends State<HomeMylearningPage>
    with SingleTickerProviderStateMixin {
  TabController _controller;
  List<Course> completedCourse = [];
  List<Course> inprogressCourse = [];
  String userId;
  String userSessionId;
  String messageIdentifier;
  String departmentId;
  List allEventsData;
  bool dataSent;
  String deviceIdentifier;
  var telemetryEventData;

  @override
  void initState() {
    super.initState();

    _getContinueLearningCourses();
  }

  @override
  void didChangeDependencies() {
    _controller = TabController(
        length: MyLearnMainTab.items(context: context).length,
        vsync: this,
        initialIndex: 0);
    super.didChangeDependencies();
  }

  void _generateInteractTelemetryData(String contentId,
      {String subType,
      String primaryCategory,
      String objectType,
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
        objectType: primaryCategory != null ? primaryCategory : objectType,
        clickId: clickId);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());
  }

  Future<dynamic> _getContinueLearningCourses() async {
    try {
      completedCourse = [];
      inprogressCourse = [];
      if (widget.courses != null) {
        widget.courses.forEach((course) {
          if (course.raw['completionPercentage'] == 100) {
            completedCourse.add(course);
          } else {
            inprogressCourse.add(course);
          }
        });
      }
      return widget.courses;
    } catch (err) {
      return err;
    }
  }

  void switchIntoYourLearningTab() {
    setState(() {
      _controller.index = 1;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
            child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 17),
              child: TitleSemiboldSize16(
                  AppLocalizations.of(context).mStaticMyLearning),
            ),
            Spacer(),
            InkWell(
                onTap: () {
                  _generateInteractTelemetryData(TelemetryIdentifier.showAll,
                      subType: TelemetrySubType.myLearning);
                  CustomTabs.setTabItem(context, 3);
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 18.0),
                  child: SizedBox(
                    width: 60,
                    child: Text(
                      AppLocalizations.of(context).mCommonShowAll,
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
          height: 304,
          child: DefaultTabController(
            length: MyLearnMainTab.items(context: context).length,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 50, // Height of the TabBar
                  child: TabBar(
                    padding: EdgeInsets.only(left: 20),
                    isScrollable: false,
                    controller: _controller,
                    indicator: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.darkBlue,
                          width: 2.0,
                        ),
                      ),
                    ),
                    onTap: (value) {
                      _generateInteractTelemetryData(
                          _controller.index == 0
                              ? TelemetryIdentifier.inProgressTab
                              : TelemetryIdentifier.completedTab,
                          subType: TelemetrySubType.myLearning);
                    },
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
                      // for (var tabItem
                      //     in MyLearnMainTab.items(context: context))
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Tab(
                          child: Padding(
                            padding: EdgeInsets.all(5.0),
                            child: SizedBox(
                              child: Center(
                                  child: Text(AppLocalizations.of(context)
                                          .mStaticInprogress +
                                      ' (' +
                                      inprogressCourse.length.toString() +
                                      ')')),
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
                                child: Text(AppLocalizations.of(context)
                                        .mCommoncompleted +
                                    ' (' +
                                    completedCourse.length.toString() +
                                    ')'),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _controller,
                    children: [courseProgress(false), courseProgress(true)],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget courseProgress(bool isCompleted) {
    List<Course> _continueLearningcourses = [];
    if (isCompleted) {
      _continueLearningcourses = completedCourse;
    } else {
      _continueLearningcourses = inprogressCourse;
    }

    return _continueLearningcourses.length > 0
        ? Padding(
            padding: const EdgeInsets.only(left: 16),
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _continueLearningcourses.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Container(
                      margin: EdgeInsets.fromLTRB(0, 16, 0, 16),
                      width: MediaQuery.of(context).size.width * 0.9,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.grey08, width: 1),
                        color: Colors.white,
                      ),
                      child: CourseProgressCard(_continueLearningcourses[index],
                          continueLearningCourse: _continueLearningcourses,
                          completed: isCompleted),
                    ),
                  );
                }),
          )
        : NoDataWidget(isCompleted: isCompleted);
  }
}
