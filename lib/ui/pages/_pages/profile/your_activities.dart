import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gyaan_karmayogi_resource_list/utils/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/models/_models/discuss_model.dart';
import 'package:karmayogi_mobile/models/_models/telemetry_event_model.dart';
import 'package:karmayogi_mobile/respositories/_respositories/discuss_repository.dart';
import 'package:karmayogi_mobile/respositories/_respositories/learn_repository.dart';
import 'package:karmayogi_mobile/respositories/_respositories/network_respository.dart';
import 'package:karmayogi_mobile/respositories/_respositories/profile_repository.dart';
import 'package:karmayogi_mobile/services/_services/report_service.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/discussion/new_discussion_page.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/discussion_page.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/network/network_request_page.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/discussion_hub.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/network_hub.dart';
import 'package:karmayogi_mobile/ui/skeleton/widgets/discuss_skeleton.dart';
import 'package:karmayogi_mobile/ui/skeleton/widgets/stats_skeleton.dart';
import 'package:karmayogi_mobile/ui/skeleton/widgets/weeklyclap_skeleton.dart';
import 'package:karmayogi_mobile/ui/widgets/_activities/_leaderboard/leaderboard_frame_widget.dart';
import 'package:karmayogi_mobile/ui/widgets/_activities/weeklyclap_title_widget.dart';
import 'package:karmayogi_mobile/ui/widgets/_activities/your_stats.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion/trending_discuss_card.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion/updates_on_discussion_card.dart';
import 'package:karmayogi_mobile/ui/widgets/_network/see_all_connection_requests.dart';
import 'package:karmayogi_mobile/ui/widgets/title_regular_grey60.dart';
import 'package:karmayogi_mobile/ui/widgets/title_semibold_size16.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:karmayogi_mobile/util/telemetry.dart';
import 'package:karmayogi_mobile/util/telemetry_db_helper.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class YourActivities extends StatefulWidget {
  const YourActivities({Key key}) : super(key: key);

  @override
  _YourActivitiesState createState() => _YourActivitiesState();
}

class _YourActivitiesState extends State<YourActivities> {
  List _data = [];
  int pageNo = 1;
  List _flaggedDiscussions = [];
  var telemetryEventData;

  Future<Map<dynamic, dynamic>> getEnrolledCoursesFuture;
  Future<dynamic> getUserInsightFuture;
  Future<dynamic> getLatestDiscussionFuture;
  Future<dynamic> getConnectionRequestFuture;

  final _controller = PageController();

  final ReportService reportService = ReportService();
  @override
  void initState() {
    super.initState();
    _getFutureData();
    getConnectionRequestFuture = _getConnectionRequest(context);
  }

  void _getFutureData() {
    getUserInsights();
    getEnrolledCourse();
    getLatestDiscussion();
  }

  void getUserInsights() {
    getUserInsightFuture =
        Provider.of<ProfileRepository>(context, listen: false)
            .getInsights(context);
  }

  void getLatestDiscussion() {
    getLatestDiscussionFuture = _getLatestDiscussion();
  }

  // Latest Discussion
  Future<dynamic> _getLatestDiscussion() async {
    List<dynamic> response = [];
    var res = await Provider.of<DiscussRepository>(context, listen: false)
        .getMyDiscussions();
    if (res['latestPosts'] == null) {
      return 'No Data found';
    } else if (res['latestPosts'].isEmpty) {
      return 'No Data found';
    }
    response = [for (final item in res['latestPosts']) Discuss.fromJson(item)];
    response.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));
    return response.first;
  }

  /// Get connection request response
  Future<dynamic> _getConnectionRequest(context) async {
    try {
      return await Provider.of<NetworkRespository>(context, listen: false)
          .getCrList();
    } catch (err) {
      return err;
    }
  }

  // Get trending discussions
  Future<dynamic> _trendingDiscussion() async {
    try {
      if (pageNo == 1) {
        _data = await Provider.of<DiscussRepository>(context, listen: false)
            .getRecentDiscussions(pageNo);
      } else {
        _data.addAll(
            await Provider.of<DiscussRepository>(context, listen: false)
                .getRecentDiscussions(pageNo));
      }
      _flaggedDiscussions.forEach((flagged) {
        _data.removeWhere((data) =>
            data.tid == int.parse(flagged['contextTypeId']) ||
            data.user['uid'] == int.parse(flagged['contextTypeId']));
      });
    } catch (err) {
      return err;
    }
    return _data;
  }

  _navigateToDiscussionDetail(tid, userName, title, uid) {
    _generateInteractTelemetryData(tid.toString(), EnglishLang.discuss,
        primaryCategory: TelemetrySubType.discussionCard,
        subType: TelemetrySubType.discussionCard);
    Navigator.push(
      context,
      FadeRoute(
          page: ChangeNotifierProvider<DiscussRepository>(
        create: (context) => DiscussRepository(),
        child: DiscussionPage(
          tid: tid,
          userName: userName,
          title: title,
          uid: uid,
          updateFlaggedContents: _updateReportStatus,
        ),
      )),
    );
  }

  _updateReportStatus() async {
    await _getFlaggedContent();
    await _trendingDiscussion();
  }

  _getFlaggedContent() async {
    final response = await reportService.getFlaggedDataByUserId();
    if (mounted) {
      setState(() {
        _flaggedDiscussions = response;
      });
    }
  }

  void getEnrolledCourse() {
    getEnrolledCoursesFuture =
        Provider.of<LearnRepository>(context, listen: false)
            .getEnrollmentList();
  }

  void _generateInteractTelemetryData(String contentId, String env,
      {String subType = '', String primaryCategory}) async {
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
        objectType: primaryCategory != null ? primaryCategory : subType);
    // allEventsData.add(eventData);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder(
              future: getUserInsightFuture,
              builder: (context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasData) {
                  var userInsights = snapshot.data;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Your stats
                      FutureBuilder(
                          future: getEnrolledCoursesFuture,
                          builder: (context, AsyncSnapshot<dynamic> snapshot) {
                            if (snapshot.hasData && snapshot.data != null) {
                              var data =
                                  snapshot.data['userCourseEnrolmentInfo'];
                              return Column(
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: TitleSemiboldSize16(
                                        AppLocalizations.of(context)
                                            .mStaticYourStats),
                                  ),
                                  Container(
                                      margin: EdgeInsets.only(top: 16),
                                      padding:
                                          EdgeInsets.fromLTRB(16, 20, 16, 20),
                                      decoration: BoxDecoration(
                                        color: AppColors.appBarBackground,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(16)),
                                      ),
                                      child: Column(
                                        children: [
                                          YourStats(
                                            data != null
                                                ? data['coursesInProgress']
                                                : 0,
                                            data != null
                                                ? data['certificatesIssued']
                                                : 0,
                                            Helper.getTimeFormat(data != null
                                                ? data['timeSpentOnCompletedCourses']
                                                    .toString()
                                                : '0'),
                                            data != null
                                                ? data['karmaPoints']
                                                : 0,
                                          ),
                                          userInsights != null &&
                                                  userInsights.runtimeType !=
                                                      String
                                              ? userInsights['nudges']
                                                      .isNotEmpty
                                                  ? Container(
                                                      margin: EdgeInsets.only(
                                                          top: 16),
                                                      padding: EdgeInsets.only(
                                                          bottom: 16),
                                                      height: 84,
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      decoration: BoxDecoration(
                                                          color: AppColors
                                                              .orangeShadow,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          12))),
                                                      child: Column(
                                                        children: [
                                                          Expanded(
                                                            child: PageView
                                                                .builder(
                                                                    controller:
                                                                        _controller,
                                                                    itemCount: userInsights[
                                                                            'nudges']
                                                                        .length,
                                                                    itemBuilder:
                                                                        (context,
                                                                            pageIndex) {
                                                                      return Container(
                                                                        margin:
                                                                            EdgeInsets.all(16),
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            SizedBox(
                                                                              width: userInsights['nudges'][pageIndex]['growth'] == 'negative' || userInsights['nudges'][pageIndex]['progress'] < 1 ? MediaQuery.of(context).size.width - 100 : MediaQuery.of(context).size.width - 170,
                                                                              child: TitleRegularGrey60(
                                                                                trimQuotes(userInsights['nudges'][pageIndex]['label']),
                                                                                color: AppColors.greys87,
                                                                                maxLines: 2,
                                                                              ),
                                                                            ),
                                                                            Spacer(),
                                                                            userInsights['nudges'][pageIndex]['growth'] != 'negative'
                                                                                ? userInsights['nudges'][pageIndex]['progress'] >= 1
                                                                                    ? Row(
                                                                                        children: [
                                                                                          Icon(
                                                                                            Icons.arrow_upward,
                                                                                            size: 18,
                                                                                            color: AppColors.positiveLight,
                                                                                          ),
                                                                                          TitleRegularGrey60('+${userInsights['nudges'][pageIndex]['progress']}%', color: AppColors.positiveLight)
                                                                                        ],
                                                                                      )
                                                                                    : Center()
                                                                                : Center()
                                                                          ],
                                                                        ),
                                                                      );
                                                                    }),
                                                          ),
                                                          SmoothPageIndicator(
                                                            controller:
                                                                _controller,
                                                            count: userInsights[
                                                                    'nudges']
                                                                .length,
                                                            effect: ExpandingDotsEffect(
                                                                activeDotColor:
                                                                    AppColors
                                                                        .orangeTourText,
                                                                dotColor: AppColors
                                                                    .profilebgGrey20,
                                                                dotHeight: 4,
                                                                dotWidth: 4,
                                                                spacing: 4),
                                                          )
                                                        ],
                                                      ),
                                                    )
                                                  : Center()
                                              : Center(),
                                        ],
                                      )),
                                ],
                              );
                            } else {
                              return StatsSkeleton();
                            }
                          }),

                      /** Leader board started**/
                      LeaderboardFameWidget(),
                      /** Leader board end**/

                      // Weekl claps
                      userInsights != null
                          ? Container(
                              margin: EdgeInsets.only(top: 16),
                              padding: EdgeInsets.fromLTRB(16, 16, 16, 20),
                              decoration: BoxDecoration(
                                color: AppColors.appBarBackground,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(16)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  WeeklyclapTitleWidget(
                                    weeklyClaps:
                                        userInsights.runtimeType != String
                                            ? userInsights['weekly-claps']
                                            : {},
                                    showInRow: true,
                                    enableNavigationForWeeklyClaps: false,
                                  ),
                                  SizedBox(height: 4),
                                  userInsights.runtimeType != String
                                      ? TitleRegularGrey60(getFormattedDate(
                                          userInsights['weekly-claps']
                                              ['startDate'],
                                          userInsights['weekly-claps']
                                              ['endDate']))
                                      : Center(),
                                  SizedBox(height: 20),
                                  userInsights.runtimeType != String
                                      ? Row(
                                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            weekwiseClapWidget(
                                                userInsights['weekly-claps'],
                                                'w1'),
                                            SizedBox(width: 24),
                                            weekwiseClapWidget(
                                                userInsights['weekly-claps'],
                                                'w2'),
                                            SizedBox(width: 24),
                                            weekwiseClapWidget(
                                                userInsights['weekly-claps'],
                                                'w3'),
                                            SizedBox(width: 24),
                                            weekwiseClapWidget(
                                                userInsights['weekly-claps'],
                                                'w4')
                                          ],
                                        )
                                      : Row(
                                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            weekwiseClapWidget({}, 'w1'),
                                            SizedBox(width: 24),
                                            weekwiseClapWidget({}, 'w2'),
                                            SizedBox(width: 24),
                                            weekwiseClapWidget({}, 'w3'),
                                            SizedBox(width: 24),
                                            weekwiseClapWidget({}, 'w4')
                                          ],
                                        )
                                ],
                              ))
                          : Center(),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      StatsSkeleton(),
                      WeeklyclapSkeleton(),
                      DiscussSkeleton()
                    ],
                  );
                }
              }),

          // My discussion
          FutureBuilder(
              future: _myDiscussion(),
              builder: (context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  if (snapshot.data.runtimeType != String &&
                      snapshot.data.isNotEmpty) {
                    List myDiscussionList = snapshot.data;
                    return Container(
                      margin: EdgeInsets.only(top: 32),
                      padding: EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: AppColors.appBarBackground,
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
                            child: Row(
                              children: [
                                Text(
                                  AppLocalizations.of(context)
                                      .mStaticMyDiscussions,
                                  style: GoogleFonts.montserrat(
                                    color: AppColors.greys87,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    letterSpacing: 0.12,
                                  ),
                                ),
                                Spacer(),
                                InkWell(
                                    onTap: () => Navigator.push(
                                          context,
                                          FadeRoute(
                                              page: DiscussionHub(
                                            title: EnglishLang.myDiscussions,
                                          )),
                                        ),
                                    child: Text(
                                      AppLocalizations.of(context)
                                          .mStaticShowAll,
                                      style: GoogleFonts.lato(
                                        color: AppColors.darkBlue,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14,
                                        letterSpacing: 0.12,
                                      ),
                                    ))
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 8),
                            child: ListView.separated(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: myDiscussionList.length > 2
                                    ? 2
                                    : myDiscussionList.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 16),
                                    child: InkWell(
                                        onTap: () =>
                                            _navigateToDiscussionDetail(
                                                myDiscussionList[index].tid,
                                                myDiscussionList[index]
                                                    .user['fullname'],
                                                myDiscussionList[index].title,
                                                myDiscussionList[index]
                                                    .user['uid']),
                                        child: TrendingDiscussCard(
                                            data: myDiscussionList[index],
                                            isProfile: true)),
                                  );
                                },
                                separatorBuilder: (context, index) {
                                  return Divider(
                                      thickness: 1, color: AppColors.grey08);
                                }),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.appBarBackground,
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                        width: MediaQuery.of(context).size.width,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  AppLocalizations.of(context)
                                      .mStaticMyDiscussions,
                                  style: GoogleFonts.lato(
                                    color: AppColors.greys87,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    letterSpacing: 0.12,
                                  )),
                              SizedBox(height: 24),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 16, right: 16),
                                child: Center(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.question_answer,
                                        color: AppColors.orangeTourText,
                                        size: 30,
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                          AppLocalizations.of(context)
                                              .mStaticNoDiscussions,
                                          maxLines: 2,
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.lato(
                                              color: AppColors.greys60,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 12,
                                              letterSpacing: 0.25,
                                              height: 1.3)),
                                      SizedBox(height: 6),
                                      ElevatedButton(
                                        onPressed: () => Navigator.push(
                                          context,
                                          FadeRoute(page: NewDiscussionPage()),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.darkBlue,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16.0),
                                              side: BorderSide(
                                                  color: AppColors.darkBlue),
                                            )),
                                        child: Text(
                                          AppLocalizations.of(context)
                                              .mDiscussStartDiscuss,
                                          maxLines: 2,
                                          style: GoogleFonts.lato(
                                              color: AppColors.appBarBackground,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                } else {
                  return DiscussSkeleton();
                }
              }),
          // Updates on your post
          FutureBuilder(
              future: getLatestDiscussionFuture,
              builder: (context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data != null) {
                    if (snapshot.data.runtimeType == String) {
                      return Center();
                    }
                    Discuss latestDiscussion = snapshot.data;
                    return Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.fromLTRB(0, 24, 0, 15),
                          child: Row(
                            children: [
                              Text(
                                AppLocalizations.of(context)
                                    .mHomeDiscussUpdateOnPost,
                                style: GoogleFonts.montserrat(
                                  color: AppColors.greys87,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  letterSpacing: 0.12,
                                ),
                              ),
                              Spacer(),
                              InkWell(
                                  onTap: () => Navigator.push(
                                        context,
                                        FadeRoute(
                                            page: DiscussionHub(
                                          title: EnglishLang.myDiscussions,
                                        )),
                                      ),
                                  child: Text(
                                    AppLocalizations.of(context).mStaticShowAll,
                                    style: GoogleFonts.lato(
                                      color: AppColors.darkBlue,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      letterSpacing: 0.12,
                                    ),
                                  ))
                            ],
                          ),
                        ),
                        UpdatesOnDiscussionCard(
                            latestDiscussion: latestDiscussion),
                      ],
                    );
                  } else
                    return Center();
                } else {
                  return DiscussSkeleton();
                }
              }),
          NetworkRequestPage(parentAction: () {
            setState(() {
              getConnectionRequestFuture = _getConnectionRequest(context);
            });
          }),
          SizedBox(
            height: 18,
          ),
          FutureBuilder(
              future: getConnectionRequestFuture,
              builder: (context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data != null) {
                    return Wrap(
                      children: [
                        SeeAllConnectionRequests(snapshot.data,
                            parentAction: () {
                          Navigator.push(
                            context,
                            FadeRoute(
                                page: NetworkHub(
                              title:
                                  AppLocalizations.of(context).mStaticRequests,
                            )),
                          );
                        }),
                      ],
                    );
                  } else
                    return Container(height: 30, child: SizedBox.shrink());
                } else {
                  return Container(height: 30, child: SizedBox.shrink());
                }
              }),
          SizedBox(
            height: 100,
          )
        ],
      ),
    );
  }

  Widget weekwiseClapWidget(Map<String, dynamic> weeklyClaps, String week) {
    return Row(
      children: [
        TitleRegularGrey60(
          week.toUpperCase(),
          color: week == 'w4' ? AppColors.darkBlue : AppColors.greys60,
        ),
        SizedBox(width: 4),
        weeklyClaps.isEmpty
            ? appNotUsed()
            : weeklyClaps[week] == null
                ? appNotUsed()
                : weeklyClaps[week].isEmpty
                    ? appNotUsed()
                    : weeklyClaps[week]['timespent'] >= CLAP_DURATION
                        ? clapRecieved()
                        : week == 'w4'
                            ? Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color:
                                            AppColors.verifiedBadgeIconColor)),
                                child: SvgPicture.asset(
                                  'assets/img/circle_grey.svg',
                                  color: AppColors.verifiedBadgeIconColor
                                      .withOpacity(0.5),
                                  width: 24,
                                  height: 24,
                                ),
                              )
                            : appNotUsed()
      ],
    );
  }

  String trimQuotes(String input) {
    if (input.startsWith('"') && input.endsWith('"')) {
      return input.substring(1, input.length - 1);
    }
    return input;
  }

  String getFormattedDate(String startDate, String endDate) {
    try {
      return '${DateFormat('EEE, d MMM').format(DateTime.parse(startDate))} - ${DateFormat('EEE, d MMM').format(DateTime.parse(endDate))}';
    } catch (e) {
      return '';
    }
  }

  /// Get recent discussions
  Future<dynamic> _myDiscussion() async {
    List<dynamic> response = [];
    List<dynamic> data = [];
    try {
      var res = await Provider.of<DiscussRepository>(context, listen: false)
          .getMyDiscussions();
      if (res['posts'] != null && res['posts'].isNotEmpty) {
        response = [for (final item in res['posts']) Discuss.fromJson(item)];
      }
      List<int> tids = [];
      for (int i = 0; i < response.length; i++) {
        if (!tids.contains(response[i].tid)) {
          data.add(response[i]);
        }
        tids.add(response[i].tid);
      }
    } catch (err) {
      return err;
    }
    return data;
  }

  Widget appNotUsed() {
    return SvgPicture.asset(
      'assets/img/decline_icon.svg',
      color: AppColors.grey40,
      width: 24,
      height: 24,
    );
  }

  Widget clapRecieved() {
    return SvgPicture.asset(
      'assets/img/check_icon.svg',
      width: 24,
      height: 24,
    );
  }
}
