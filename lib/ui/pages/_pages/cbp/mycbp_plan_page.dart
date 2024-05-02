import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../constants/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../models/index.dart';
import '../../../../util/faderoute.dart';
import '../../../widgets/_signup/contact_us.dart';
import '../../../widgets/index.dart';
import '../../index.dart';

class MyCbpPlanPage extends StatefulWidget {
  final List<Course> allCourseList;
  final List<Course> upcomingCourseList;
  final List<Course> overdueCourseList;
  MyCbpPlanPage(
      {Key key,
      @required this.allCourseList,
      @required this.upcomingCourseList,
      @required this.overdueCourseList})
      : super(key: key);

  @override
  _MyCbpPlanPageState createState() => _MyCbpPlanPageState();
}

class _MyCbpPlanPageState extends State<MyCbpPlanPage> {
  ScrollController _scrollController = ScrollController();
  List<Course> allCourseList = [],
      upcomingCourseList = [],
      overdueCourseList = [];
  ValueNotifier<int> allCourseCount = ValueNotifier<int>(0),
      upcomingCourseCount = ValueNotifier<int>(0),
      overdueCourseCount = ValueNotifier<int>(0);
  @override
  void initState() {
    super.initState();
    allCourseList = widget.allCourseList;
    upcomingCourseList = widget.upcomingCourseList;
    overdueCourseList = widget.overdueCourseList;
    allCourseCount.value = allCourseList.length;
    upcomingCourseCount.value = upcomingCourseList.length;
    overdueCourseCount.value = overdueCourseList.length;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll
              .disallowIndicator(); //previous code overscroll.disallowGlow();
          return true;
        },
        child: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 50.0,
                  floating: false,
                  pinned: true,
                  titleSpacing: 0,
                  title: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context).mStaticAcbpBannerTitle,
                        style: GoogleFonts.lato(
                            color: AppColors.greys87,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.12),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            FadeRoute(page: ContactUs()),
                          );
                        },
                        child: SvgPicture.asset(
                          'assets/img/help_icon.svg',
                          width: 56.0,
                          height: 56.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ];
            },
            body: Container(
              color: AppColors.whiteGradientOne,
              height: double.infinity,
              padding: EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    planStatsWidget(),
                    SizedBox(height: 24),
                    CBPSearchPage(
                        allCourseList: allCourseList,
                        upcomingCourseList: upcomingCourseList,
                        overdueCourseList: overdueCourseList),
                    SizedBox(
                      height: 120,
                    )
                  ],
                ),
              ),
            )),
      ),
      bottomSheet: BottomBar(),
    );
  }

  Widget planStatsWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grey04, width: 1),
          color: AppColors.appBarBackground),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TitleBoldWidget(AppLocalizations.of(context).mStaticAcbpBannerTitle),
                // PopupMenuButton<String>(
                //   icon: Icon(
                //     Icons.filter_list,
                //     size: 24,
                //     color: AppColors.darkBlue,
                //   ),
                //   onSelected: (value) {
                //     // Handle the selection
                //     int allCount = 0, upcomingCount = 0, overdueCount = 0;
                //     allCourseList.forEach((course) {
                //       allCount = getCourseCount(value, course, allCount);
                //     });
                //     upcomingCourseList.forEach((course) {
                //       upcomingCount =
                //           getCourseCount(value, course, upcomingCount);
                //     });
                //     overdueCourseList.forEach((course) {
                //       overdueCount = getCourseCount(value, course, overdueCount);
                //     });
                //     allCourseCount.value = allCount;
                //     upcomingCourseCount.value = upcomingCount;
                //     overdueCourseCount.value = overdueCount;
                //     print('Selected: $value');
                //   },
                //   itemBuilder: (BuildContext context) {
                //     List<PopupMenuItem<String>> popupList = [];
                //     CBP_STATS_FILTER.forEach((element) {
                //       popupList.add(
                //         PopupMenuItem<String>(
                //           value: element,
                //           child: Text(element),
                //         ),
                //       );
                //     });
                //     return popupList;
                //   },
                // ),
              ],
            ),
          ),
          Divider(
            color: AppColors.grey08,
            thickness: 1,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ValueListenableBuilder<int>(
                    valueListenable: allCourseCount,
                    builder: (context, value, _) {
                      return statsWidget(
                          title: AppLocalizations.of(context).mCommonAll,
                          count: allCourseCount.value.toString());
                    }),
                ValueListenableBuilder<int>(
                    valueListenable: upcomingCourseCount,
                    builder: (context, value, _) {
                      return statsWidget(
                          title: AppLocalizations.of(context).mStaticUpcoming,
                          count: upcomingCourseCount.value.toString());
                    }),
                ValueListenableBuilder<int>(
                    valueListenable: overdueCourseCount,
                    builder: (context, value, _) {
                      return statsWidget(
                          title: AppLocalizations.of(context).mStaticOverdue,
                          count: overdueCourseCount.value.toString());
                    })
              ],
            ),
          )
        ],
      ),
    );
  }

  int getCourseCount(String value, Course course, int count) {
    if (value == CBPFilterTimeDuration.last3month) {
      if (getTimeDiff(DateTime.now().toString(), course.endDate) <= 90 &&
          getTimeDiff(DateTime.now().toString(), course.endDate) >= 0) {
        count++;
      }
    } else if (value == CBPFilterTimeDuration.last6month) {
      if (getTimeDiff(DateTime.now().toString(), course.endDate) <= 180 &&
          getTimeDiff(DateTime.now().toString(), course.endDate) >= 0) {
        count++;
      }
    } else if (value == CBPFilterTimeDuration.lastYear) {
      if (getTimeDiff(DateTime.now().toString(), course.endDate) <= 365 &&
          getTimeDiff(DateTime.now().toString(), course.endDate) >= 0) {
        count++;
      }
    }
    return count;
  }

  Column statsWidget({String title, String count}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitleRegularGrey60(title),
        SizedBox(height: 4),
        TitleBoldWidget(
          count,
          color: AppColors.darkBlue,
          fontSize: 14,
        )
      ],
    );
  }

  int getTimeDiff(String date1, String date2) {
    return DateTime.parse(
            DateFormat('yyyy-MM-dd').format(DateTime.parse(date1)))
        .difference(DateTime.parse(
            DateFormat('yyyy-MM-dd').format(DateTime.parse(date2))))
        .inDays;
  }
}
