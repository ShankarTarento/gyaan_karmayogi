import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/localization/index.dart';
import 'package:karmayogi_mobile/models/_models/learn_config_model.dart';
import 'package:karmayogi_mobile/respositories/_respositories/learn_repository.dart';
import 'package:karmayogi_mobile/services/_services/landing_page_service.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/learn/mandatory_courses_page.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/learn/see_all_courses.dart';
import 'package:karmayogi_mobile/ui/widgets/_learn/content_info.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'package:karmayogi_mobile/ui/widgets/_home/program_item.dart';
import '../../../../constants/_constants/telemetry_constants.dart';
import '../../../../models/_arguments/index.dart';
import '../../../../respositories/_respositories/profile_repository.dart';
import './../../../../ui/pages/index.dart';
import './../../../../util/faderoute.dart';
import './../../../../constants/index.dart';
import './../../../widgets/index.dart';
import './../../../../services/index.dart';
import './../../../../models/index.dart';
import './../../../../util/telemetry.dart';
import './../../../../util/telemetry_db_helper.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class LearningHubPage extends StatefulWidget {
  final parentAction;
  const LearningHubPage({this.parentAction});
  @override
  _LearningHubPageState createState() => _LearningHubPageState();
}

class _LearningHubPageState extends State<LearningHubPage> {
  TelemetryService telemetryService = TelemetryService();
  final LearnService learnService = LearnService();
  final landingPageService = LandingPageService();
  // ScrollController _controller = ScrollController();
  List<Course> _continueLearningcourses;
  List<Course> _notCompletedContinueLearningcourses;
  List<Course> _mandatoryCourses;
  List<dynamic> _selectedTopics = [];
  List<BrowseCompetencyCardModel> _competencies = [];
  ScrollController _scrollController;
  List<Profile> _profileDetails;
  LearnConfig _learnConfig;

  String userId;
  String userSessionId;
  String messageIdentifier;
  String departmentId;
  // Timer _timer;
  int _start = 0;
  List allEventsData = [];
  String deviceIdentifier;
  var telemetryEventData;
  Future<List<Course>> landingPageFuture;
  Future<List<Course>> getCoursesFuture;
  Future<List<Course>> getInterestedCBPSFuture;
  // Future<List<Course>> getRecommendedCoursesFuture;
  Future<List<Course>> getCourseProgramFuture;
  Future<List<Course>> getCourseRecentlyFuture;
  Future<List<Course>> getStandaloneFuture;
  Future getCourseCompetenciesFuture;
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _getLearnHomeConfig();
    // _getMandatoryCourses();
    if (_start == 0) {
      _generateTelemetryData();
    }
    getFutureData();
  }

  void getFutureData() async {
    await _getProfileData();
    getLandingPage();
    getCourses();
    getInterestedCBPS();
    // getRecommendedCourses();
    getCourseProgram();
    getCourseRecently();
    getStandaloneCourse();
    getCompetenciesCourse();
  }

  void getLandingPage() {
    landingPageFuture = landingPageService.getFeaturedCourses(
        pathUrl:
            (_learnConfig != null && _learnConfig.featuredCoursesConfig != null)
                ? _learnConfig.featuredCoursesConfig.requestBody['api']['path']
                : null);
  }

  void getCourses() {
    getCoursesFuture = Provider.of<LearnRepository>(context, listen: false)
        .getCourses(1, '', [], [], [], isModerated: true);
  }

  void getInterestedCBPS() {
    getInterestedCBPSFuture = _getInterestedCBPs();
  }

  // void getRecommendedCourses() {
  //   getRecommendedCoursesFuture = _getRecommendedCourses();
  // }

  void getCourseProgram() {
    getCourseProgramFuture =
        Provider.of<LearnRepository>(context, listen: false)
            .getCourses(1, '', ['program'], [], []);
  }

  void getCourseRecently() {
    getCourseRecentlyFuture =
        Provider.of<LearnRepository>(context, listen: false)
            .getCourses(1, '', [EnglishLang.course.toLowerCase()], [], []);
  }

  void getStandaloneCourse() {
    getStandaloneFuture = Provider.of<LearnRepository>(context, listen: false)
        .getCourses(1, '', [PrimaryCategory.standaloneAssessment], [], []);
  }

  void getCompetenciesCourse() {
    getCourseCompetenciesFuture = _getCourseCompetencies();
  }

  _getLearnHomeConfig() async {
    _learnConfig = await Provider.of<LearnRepository>(context, listen: false)
        .getLearnToolTipInfo();
  }

  // Future<dynamic> _getMandatoryCourses() async {
  //   try {
  //     List _data = await Provider.of<LearnRepository>(context, listen: false)
  //         .getMandatoryCourses();
  //     return _data;
  //   } catch (err) {
  //     return err;
  //   }
  // }

  void _generateTelemetryData() async {
    deviceIdentifier = await Telemetry.getDeviceIdentifier();
    userId = await Telemetry.getUserId();
    userSessionId = await Telemetry.generateUserSessionId();
    messageIdentifier = await Telemetry.generateUserSessionId();
    departmentId = await Telemetry.getUserDeptId();
    Map eventData2 = Telemetry.getImpressionTelemetryEvent(
        deviceIdentifier,
        userId,
        departmentId,
        TelemetryPageIdentifier.learnPageId,
        userSessionId,
        messageIdentifier,
        TelemetryType.page,
        TelemetryPageIdentifier.learnPageUri,
        env: TelemetryEnv.learn);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData2);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());
  }

  Future<List<Course>> _getInterestedCBPs() async {
    List<Course> interestedCourses;
    if (_profileDetails != null) {
      _profileDetails[0].selectedTopics.forEach((element) {
        _selectedTopics.add(element['identifier']);
      });
      _profileDetails[0].desiredTopics.forEach((element) {
        _selectedTopics.add(element);
      });
    }

    if (_selectedTopics.length > 0) {
      interestedCourses =
          await Provider.of<LearnRepository>(context, listen: false)
              .getInterestedCourses(_selectedTopics);
    }
    return interestedCourses;
  }

  Future<List<Course>> _getRecommendedCourses() async {
    if (_profileDetails != null) {
      List<dynamic> profileCompetency = _profileDetails.first.competencies;
      List<dynamic> addedCompetenciesList = [];
      profileCompetency
          .map((competency) => addedCompetenciesList.add(competency['name']))
          .toList();

      var _recommendedCourses =
          await Provider.of<LearnRepository>(context, listen: false)
              .getRecommendedCourses(addedCompetenciesList);
      return _recommendedCourses;
    }
  }

  Future<dynamic> _getData() async {
    _continueLearningcourses =
        await Provider.of<LearnRepository>(context, listen: false)
            .getContinueLearningCourses();

    _notCompletedContinueLearningcourses = _continueLearningcourses
        .where((course) => course.raw['completionPercentage'] != 100)
        .toList();

    _mandatoryCourses = _continueLearningcourses
        .where((course) =>
            (course.contentType == EnglishLang.mandatoryCourseGoal &&
                course.raw['completionPercentage'] != 100))
        .toList();

    // _mandatoryCourses =
    //     await Provider.of<LearnRepository>(context, listen: false)
    //         .getMandatoryCourses();
    // _courseTopics = await courseService.getCourseTopics();
    // print(_courseTopics.toString());
    return _continueLearningcourses;
  }

  void _scrollToTop() {
    _scrollController.animateTo(0.0,
        duration: Duration(seconds: 1), curve: Curves.ease);
  }

  Future<dynamic> _getProfileData() async {
    _profileDetails =
        await Provider.of<ProfileRepository>(context, listen: false)
            .getProfileDetailsById('');
    return _profileDetails;
  }

  Future<dynamic> _getCourseCompetencies() async {
    _competencies = await Provider.of<LearnRepository>(context, listen: false)
        .getListOfCompetencies(context);
    return true;
  }

  // /// Navigate to discussion detail
  // _navigateToDetail(tid, userName, title) {
  //   Navigator.push(
  //     context,
  //     FadeRoute(
  //         page: ChangeNotifierProvider<DiscussRepository>(
  //       create: (context) => DiscussRepository(),
  //       child: DiscussionPage(tid: tid, userName: userName, title: title),
  //     )),
  //   );
  // }

  void _generateInteractTelemetryData(
      String contentId, String primaryCategory) async {
    Map eventData = Telemetry.getInteractTelemetryEvent(
        deviceIdentifier,
        userId,
        departmentId,
        TelemetryPageIdentifier.learnPageId,
        userSessionId,
        messageIdentifier,
        contentId,
        TelemetrySubType.courseCard,
        env: TelemetryEnv.learn,
        objectType: primaryCategory != null
            ? primaryCategory
            : TelemetrySubType.courseCard);
    allEventsData.add(eventData);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData);
    await TelemetryDbHelper.insertEvent(
      telemetryEventData.toMap(),
    );
  }

  @override
  void dispose() async {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = 150.0; //MediaQuery.of(context).size.width * .6;
    return SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        child: FutureBuilder(
            future: _getData(),
            builder: (context, AsyncSnapshot<dynamic> snapshot) {
              // print(MediaQuery.of(context).size.height.toString());
              if (snapshot.hasData && snapshot.data != null) {
                // List<Course> courses = snapshot.data;
                return Container(
                  padding: const EdgeInsets.only(bottom: 0),
                  child: ListView(
                    physics: const NeverScrollableScrollPhysics(), // new
                    // controller: _scrollController,
                    shrinkWrap: true,
                    children: <Widget>[
                      SizedBox(
                        height: 16,
                      ),
                      // Container(
                      //   padding: const EdgeInsets.fromLTRB(12, 15, 12, 15),
                      //   child: Row(
                      //     children: [
                      //       Text(
                      //         EnglishLang.bites,
                      //         style: GoogleFonts.lato(
                      //           color: AppColors.greys87,
                      //           fontWeight: FontWeight.w700,
                      //           fontSize: 16,
                      //           letterSpacing: 0.12,
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      // Container(
                      //   height: 250,
                      //   width: double.infinity,
                      //   padding: const EdgeInsets.only(top: 5, bottom: 15),
                      //   child: ListView(
                      //       scrollDirection: Axis.horizontal,
                      //       children: BITES_DATA
                      //           .map((bitescardmodel) => InkWell(
                      //                 child: ClipRRect(
                      //                   borderRadius: BorderRadius.circular(4),
                      //                   child: Container(
                      //                       margin:
                      //                           const EdgeInsets.only(left: 10),
                      //                       child: BitesCard(
                      //                         imageUrl: bitescardmodel.imageUrl,
                      //                         title: bitescardmodel.title,
                      //                         iconImage:
                      //                             bitescardmodel.iconImage,
                      //                       )),
                      //                 ),
                      //               ))
                      //           .toList()),
                      // ),
                      _notCompletedContinueLearningcourses.length > 0
                          ? Container(
                              padding:
                                  const EdgeInsets.fromLTRB(12, 15, 12, 15),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: screenWidth,
                                    child: Text(
                                      AppLocalizations.of(context)
                                          .mLearnTabYourLearning,
                                      style: GoogleFonts.lato(
                                        color: AppColors.greys87,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        letterSpacing: 0.12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  ContentInfo(
                                    infoMessage: _learnConfig != null
                                        ? _learnConfig
                                            .continueLearning.description
                                        : AppLocalizations.of(context)
                                            .mLearnTabYourLearning,
                                  ),
                                  Spacer(),
                                  InkWell(
                                      onTap: () => widget.parentAction(),
                                      child: SizedBox(
                                        width: 60,
                                        child: Text(
                                          AppLocalizations.of(context)
                                              .mLearnShowAll,
                                          style: GoogleFonts.lato(
                                            color: AppColors.darkBlue,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                            letterSpacing: 0.12,
                                          ),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ))
                                ],
                              ),
                            )
                          : Center(),
                      _notCompletedContinueLearningcourses.length > 0
                          ? Container(
                              height: 296,
                              width: double.infinity,
                              margin: const EdgeInsets.only(top: 5, bottom: 15),
                              child: AnimationLimiter(
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount:
                                      _notCompletedContinueLearningcourses
                                                  .length <
                                              10
                                          ? _notCompletedContinueLearningcourses
                                              .length
                                          : 10,
                                  // itemCount: 1,
                                  itemBuilder: (context, index) {
                                    return AnimationConfiguration.staggeredList(
                                      position: index,
                                      duration:
                                          const Duration(milliseconds: 375),
                                      child: SlideAnimation(
                                        verticalOffset: 50.0,
                                        child: FadeInAnimation(
                                          child: InkWell(
                                              onTap: () async {
                                                _generateInteractTelemetryData(
                                                    _notCompletedContinueLearningcourses[
                                                            index]
                                                        .raw['courseId'],
                                                    _notCompletedContinueLearningcourses[
                                                                index]
                                                            .raw['content']
                                                        ['courseCategory']);
                                                Navigator.pushNamed(context,
                                                    AppUrl.courseTocPage,
                                                    arguments: CourseTocModel(
                                                      courseId:
                                                          _notCompletedContinueLearningcourses[
                                                                  index]
                                                              .raw['courseId'],
                                                    ));
                                              },
                                              child: CourseCard(
                                                course:
                                                    _notCompletedContinueLearningcourses[
                                                        index],
                                                progress:
                                                    (_notCompletedContinueLearningcourses[
                                                                    index]
                                                                .raw[
                                                            'completionPercentage'] /
                                                        100),
                                                displayProgress: true,
                                              )),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ))
                          : Center(),

                      /** Moderated course start**/
                      FutureBuilder(
                          future: getCoursesFuture,
                          builder: (BuildContext context,
                              AsyncSnapshot<List<Course>> courses) {
                            return (courses.hasData &&
                                    (courses.data != null &&
                                        courses.data.length > 0))
                                ? Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            16, 16, 16, 15),
                                        child: Row(
                                          children: [
                                            Text(
                                              Helper.capitalize(
                                                  AppLocalizations.of(context)
                                                      .mCommonModeratedCourses),
                                              style: GoogleFonts.lato(
                                                color: AppColors.greys87,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16,
                                                letterSpacing: 0.12,
                                              ),
                                            ),
                                            ContentInfo(
                                              infoMessage: (_learnConfig !=
                                                          null &&
                                                      _learnConfig
                                                              .moderatedCoursesConfig !=
                                                          null)
                                                  ? _learnConfig
                                                      .moderatedCoursesConfig
                                                      .description
                                                  : EnglishLang
                                                      .moderatedCoursesInfo,
                                            ),
                                            Spacer(),
                                            InkWell(
                                                onTap: () => Navigator.push(
                                                      context,
                                                      FadeRoute(
                                                        page:
                                                            TrendingCoursesPage(
                                                          selectedContentType:
                                                              EnglishLang
                                                                  .moderatedCourse,
                                                          isModerated: true,
                                                          title: AppLocalizations
                                                                  .of(context)
                                                              .mCommonModeratedCourses,
                                                        ),
                                                      ),
                                                    ),
                                                child: SizedBox(
                                                  width: 60,
                                                  child: Text(
                                                    AppLocalizations.of(context)
                                                        .mLearnShowAll,
                                                    style: GoogleFonts.lato(
                                                      color: AppColors.darkBlue,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 14,
                                                      letterSpacing: 0.12,
                                                    ),
                                                  ),
                                                ))
                                          ],
                                        ),
                                      ),
                                      courses.data.length > 0
                                          ? Container(
                                              height: 296,
                                              width: double.infinity,
                                              margin: const EdgeInsets.only(
                                                  left: 6, top: 5, bottom: 15),
                                              child: ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount:
                                                    courses.data.length < 10
                                                        ? courses.data.length
                                                        : 10,
                                                itemBuilder: (context, index) {
                                                  return InkWell(
                                                      onTap: () async {
                                                        _generateInteractTelemetryData(
                                                            courses
                                                                .data[index].id,
                                                            courses.data[index]
                                                                .contentType);
                                                        // Navigator.push(
                                                        //     context,
                                                        //     FadeRoute(
                                                        //         page: CourseDetailsPage(
                                                        //             courses
                                                        //                 .data[
                                                        //                     index]
                                                        //                 .contentType,
                                                        //             id: courses
                                                        //                 .data[
                                                        //                     index]
                                                        //                 .id,
                                                        //             isModerated:
                                                        //                 true)));
                                                        Navigator.pushNamed(
                                                            context,
                                                            AppUrl
                                                                .courseTocPage,
                                                            arguments:
                                                                CourseTocModel
                                                                    .fromJson({
                                                              'courseId':
                                                                  courses
                                                                      .data[
                                                                          index]
                                                                      .id,
                                                              'isModeratedContent':
                                                                  true
                                                            }));
                                                      },
                                                      child: CourseCard(
                                                          course: courses
                                                              .data[index]));
                                                },
                                              ))
                                          : Center(
                                              child: PageLoader(),
                                            ),
                                    ],
                                  )
                                : Center();
                          }),

                      FutureBuilder(
                          future: Provider.of<LearnRepository>(context,
                                  listen: false)
                              .getCourses(
                                  1,
                                  '',
                                  [EnglishLang.blendedProgram.toLowerCase()],
                                  [],
                                  []),
                          builder: (BuildContext context,
                              AsyncSnapshot<List<Course>> courses) {
                            List<Course> blendedCourse = [];
                            if (courses.hasData &&
                                (courses.data != null &&
                                    courses.data.length > 0)) {
                              for (int index = 0;
                                  index < courses.data.length;
                                  index++) {
                                if (!checkAllBatchEndDateOver(
                                    courses.data[index].raw)) {
                                  blendedCourse.add(courses.data[index]);
                                }
                              }
                              return (blendedCourse != null &&
                                      blendedCourse.length > 0)
                                  ? Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              16, 16, 16, 15),
                                          child: Row(
                                            children: [
                                              Text(
                                                Helper.capitalize(EnglishLang
                                                    .blendedProgram
                                                    .toLowerCase()),
                                                style: GoogleFonts.lato(
                                                  color: AppColors.greys87,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 16,
                                                  letterSpacing: 0.12,
                                                ),
                                              ),
                                              Spacer(),
                                              InkWell(
                                                  onTap: () => Navigator.push(
                                                        context,
                                                        FadeRoute(
                                                            page:
                                                                TrendingCoursesPage(
                                                          selectedContentType:
                                                              EnglishLang
                                                                  .blendedProgram,
                                                          isBlendedProgram:
                                                              true,
                                                          title: EnglishLang
                                                              .blendedProgram,
                                                        )),
                                                      ),
                                                  child: SizedBox(
                                                    width: 60,
                                                    child: Text(
                                                      AppLocalizations.of(
                                                              context)
                                                          .mLearnShowAll,
                                                      style: GoogleFonts.lato(
                                                        color:
                                                            AppColors.darkBlue,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 14,
                                                        letterSpacing: 0.12,
                                                      ),
                                                    ),
                                                  ))
                                            ],
                                          ),
                                        ),
                                        blendedCourse.length > 0
                                            ? Container(
                                                height: 296,
                                                width: double.infinity,
                                                margin: const EdgeInsets.only(
                                                    left: 6,
                                                    top: 5,
                                                    bottom: 15),
                                                child: ListView.builder(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemCount:
                                                      blendedCourse.length < 10
                                                          ? blendedCourse.length
                                                          : 10,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return InkWell(
                                                        onTap: () async {
                                                          _generateInteractTelemetryData(
                                                              blendedCourse[
                                                                      index]
                                                                  .id,
                                                              blendedCourse[
                                                                      index]
                                                                  .contentType);
                                                          Navigator.pushNamed(
                                                              context,
                                                              AppUrl
                                                                  .courseTocPage,
                                                              arguments:
                                                                  CourseTocModel
                                                                      .fromJson({
                                                                'courseId':
                                                                    blendedCourse[
                                                                            index]
                                                                        .id,
                                                                'isBlendedProgram':
                                                                    true
                                                              }));
                                                          // Navigator.push(
                                                          //     context,
                                                          //     FadeRoute(
                                                          //         page:
                                                          //             CourseDetailsPage(
                                                          //       courses
                                                          //           .data[
                                                          //               index]
                                                          //           .contentType,
                                                          //       id: courses
                                                          //           .data[
                                                          //               index]
                                                          //           .id,
                                                          //       isCuratedProgram:
                                                          //           true,
                                                          //       curatedPgmBatchId:
                                                          //           batchId,
                                                          //     )));
                                                        },
                                                        child: CourseCard(
                                                            course:
                                                                blendedCourse[
                                                                    index]));
                                                  },
                                                ))
                                            : Center(
                                                child: PageLoader(),
                                              ),
                                      ],
                                    )
                                  : Center();
                            } else
                              return Center();
                          }),

                      FutureBuilder(
                          future: landingPageFuture,
                          builder: (BuildContext context,
                              AsyncSnapshot<List<Course>> courses) {
                            return courses.hasData && courses.data != null
                                ? courses.data.length > 0
                                    ? Column(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.fromLTRB(
                                                16, 8, 16, 15),
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                  width: screenWidth,
                                                  child: Text(
                                                    (_learnConfig != null &&
                                                            _learnConfig
                                                                    .featuredCoursesConfig !=
                                                                null)
                                                        ? _learnConfig
                                                            .featuredCoursesConfig
                                                            .title
                                                        : Helper.capitalize(
                                                            AppLocalizations.of(
                                                                    context)
                                                                .mLearnFeaturedCourses
                                                                .toLowerCase()),
                                                    style: GoogleFonts.lato(
                                                      color: AppColors.greys87,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 16,
                                                      letterSpacing: 0.12,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                ContentInfo(
                                                  infoMessage: (_learnConfig !=
                                                              null &&
                                                          _learnConfig
                                                                  .featuredCoursesConfig !=
                                                              null)
                                                      ? _learnConfig
                                                          .featuredCoursesConfig
                                                          .description
                                                      : AppLocalizations.of(
                                                              context)
                                                          .mLearnFeaturedCourses,
                                                ),
                                                Spacer(),
                                              ],
                                            ),
                                          ),
                                          courses.data.length > 0
                                              ? Container(
                                                  height: 296,
                                                  width: double.infinity,
                                                  margin: const EdgeInsets.only(
                                                      top: 5,
                                                      bottom: 0,
                                                      left: 4),
                                                  child: AnimationLimiter(
                                                    child: ListView.builder(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      itemCount: courses
                                                                  .data.length <
                                                              10
                                                          ? courses.data.length
                                                          : 10,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return AnimationConfiguration
                                                            .staggeredList(
                                                          position: index,
                                                          duration:
                                                              const Duration(
                                                                  milliseconds:
                                                                      375),
                                                          child: SlideAnimation(
                                                            verticalOffset:
                                                                50.0,
                                                            child:
                                                                FadeInAnimation(
                                                              child: InkWell(
                                                                  onTap:
                                                                      () async {
                                                                    // _generateInteractTelemetryData(
                                                                    //     courses
                                                                    //         .data[
                                                                    //             index]
                                                                    //         .id,
                                                                    //     subType:
                                                                    //         TelemetrySubType.courseCard);
                                                                    Navigator.pushNamed(
                                                                        context,
                                                                        AppUrl
                                                                            .courseTocPage,
                                                                        arguments:
                                                                            CourseTocModel.fromJson({
                                                                          'courseId': courses
                                                                              .data[index]
                                                                              .id,
                                                                        }));
                                                                  },
                                                                  child: CourseCard(
                                                                      course: courses
                                                                              .data[
                                                                          index])),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ))
                                              : Center(
                                                  child: PageLoader(),
                                                ),
                                        ],
                                      )
                                    : Center()
                                : Center();
                          }),
                      enableCuratedProgram
                          ? FutureBuilder(
                              future: Provider.of<LearnRepository>(context,
                                      listen: false)
                                  .getCourses(1, '',
                                      [PrimaryCategory.curatedProgram], [], []),
                              builder: (BuildContext context,
                                  AsyncSnapshot<List<Course>> courses) {
                                return (courses.hasData &&
                                        (courses.data != null &&
                                            courses.data.length > 0))
                                    ? Column(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.fromLTRB(
                                                16, 16, 16, 15),
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                  width: screenWidth,
                                                  child: Text(
                                                    AppLocalizations.of(context)
                                                        .mLearnCuratedPrograms,
                                                    style: GoogleFonts.lato(
                                                      color: AppColors.greys87,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 16,
                                                      letterSpacing: 0.12,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                ContentInfo(
                                                  infoMessage: AppLocalizations
                                                          .of(context)
                                                      .mLearnCuratedPrograms,
                                                ),
                                                Spacer(),
                                                InkWell(
                                                    onTap: () => Navigator.push(
                                                          context,
                                                          FadeRoute(
                                                              page: TrendingCoursesPage(
                                                                  selectedContentType:
                                                                      PrimaryCategory
                                                                          .curatedProgram,
                                                                  isCuratedProgram:
                                                                      true,
                                                                  title: AppLocalizations.of(
                                                                          context)
                                                                      .mLearnCuratedPrograms)),
                                                        ),
                                                    child: SizedBox(
                                                      width: 60,
                                                      child: Text(
                                                        AppLocalizations.of(
                                                                context)
                                                            .mLearnShowAll,
                                                        style: GoogleFonts.lato(
                                                          color: AppColors
                                                              .darkBlue,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 14,
                                                          letterSpacing: 0.12,
                                                        ),
                                                        maxLines: 3,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ))
                                              ],
                                            ),
                                          ),
                                          courses.data.length > 0
                                              ? Container(
                                                  height: 296,
                                                  width: double.infinity,
                                                  margin: const EdgeInsets.only(
                                                      left: 6,
                                                      top: 5,
                                                      bottom: 24),
                                                  child: ListView.builder(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    itemCount:
                                                        courses.data.length < 10
                                                            ? courses
                                                                .data.length
                                                            : 10,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return InkWell(
                                                          onTap: () async {
                                                            _generateInteractTelemetryData(
                                                                courses
                                                                    .data[index]
                                                                    .id,
                                                                courses
                                                                    .data[index]
                                                                    .contentType);
                                                            Navigator.pushNamed(
                                                              context,
                                                              AppUrl
                                                                  .courseTocPage,
                                                              arguments:
                                                                  CourseTocModel
                                                                      .fromJson(
                                                                {
                                                                  'courseId':
                                                                      courses
                                                                          .data[
                                                                              index]
                                                                          .id
                                                                },
                                                              ),
                                                            );
                                                            // String batchId;
                                                            // courses.data[index]
                                                            //     .raw['batches']
                                                            //     .forEach((batch) =>
                                                            //         batchId = batch[
                                                            //             'batchId']);
                                                            // Navigator.push(
                                                            //     context,
                                                            //     FadeRoute(
                                                            //         page:
                                                            //             CourseDetailsPage(
                                                            //       courses
                                                            //           .data[
                                                            //               index]
                                                            //           .contentType,
                                                            //       id: courses
                                                            //           .data[
                                                            //               index]
                                                            //           .id,
                                                            //       isCuratedProgram:
                                                            //           true,
                                                            //       curatedPgmBatchId:
                                                            //           batchId,
                                                            //     )));
                                                          },
                                                          child: CourseCard(
                                                              course:
                                                                  courses.data[
                                                                      index]));
                                                    },
                                                  ))
                                              : Center(
                                                  child: PageLoader(),
                                                ),
                                        ],
                                      )
                                    : Center();
                              })
                          : Center(),
                      _mandatoryCourses.length > 0
                          ? Column(
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(12, 15, 12, 15),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: screenWidth,
                                        child: Text(
                                          AppLocalizations.of(context)
                                              .mLearnMandatoryCourses,
                                          style: GoogleFonts.lato(
                                            color: AppColors.greys87,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                            letterSpacing: 0.12,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      ContentInfo(
                                        infoMessage: _learnConfig
                                            .mandatoryCourse.description,
                                      ),
                                      Spacer(),
                                      InkWell(
                                          onTap: () => Navigator.push(
                                                context,
                                                FadeRoute(
                                                    page: MandatoryCoursesPage(
                                                        enrolmentList:
                                                            _continueLearningcourses)),
                                              ),
                                          child: SizedBox(
                                            width: 60,
                                            child: Text(
                                              AppLocalizations.of(context)
                                                  .mLearnShowAll,
                                              style: GoogleFonts.lato(
                                                color: AppColors.darkBlue,
                                                fontWeight: FontWeight.w400,
                                                fontSize: 14,
                                                letterSpacing: 0.12,
                                              ),
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ))
                                    ],
                                  ),
                                ),
                                Container(
                                    height: 296,
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(
                                        top: 5, bottom: 15),
                                    child: AnimationLimiter(
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: _mandatoryCourses.length < 10
                                            ? _mandatoryCourses.length
                                            : 10,
                                        // itemCount: 1,
                                        itemBuilder: (context, index) {
                                          return AnimationConfiguration
                                              .staggeredList(
                                            position: index,
                                            duration: const Duration(
                                                milliseconds: 375),
                                            child: SlideAnimation(
                                              verticalOffset: 50.0,
                                              child: FadeInAnimation(
                                                child: InkWell(
                                                    onTap: () async {
                                                      _generateInteractTelemetryData(
                                                          _mandatoryCourses[
                                                                  index]
                                                              .raw['courseId'],
                                                          _mandatoryCourses[
                                                                      index]
                                                                  .raw[
                                                              'primaryCategory']);
                                                      Navigator.pushNamed(
                                                          context,
                                                          AppUrl.courseTocPage,
                                                          arguments:
                                                              CourseTocModel
                                                                  .fromJson({
                                                            'courseId': _mandatoryCourses[index]
                                                                            .raw[
                                                                        'courseId'] !=
                                                                    null
                                                                ? _mandatoryCourses[
                                                                            index]
                                                                        .raw[
                                                                    'courseId']
                                                                : _mandatoryCourses[
                                                                        index]
                                                                    .id,
                                                          }));
                                                    },
                                                    child: Container(
                                                      // padding: const EdgeInsets.only(right: 16),
                                                      child: Container(
                                                        // width: MediaQuery.of(context).size.width -
                                                        //     10,
                                                        child: CourseCard(
                                                          course:
                                                              _mandatoryCourses[
                                                                  index],
                                                          progress: (_mandatoryCourses[
                                                                          index]
                                                                      .raw[
                                                                  'completionPercentage'] /
                                                              100),
                                                          displayProgress: true,
                                                          isMandatory: true,
                                                        ),
                                                      ),
                                                    )),
                                              ),
                                            ),
                                          );

                                          // CourseItem(
                                          // course: _continueLearningcourses[index]);
                                        },
                                      ),
                                    ))
                              ],
                            )
                          : Center(),
                      FutureBuilder(
                          future: getInterestedCBPSFuture,
                          builder: (BuildContext context,
                              AsyncSnapshot<List<Course>> courses) {
                            return (courses.hasData && courses.data != null)
                                ? Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            12, 15, 12, 15),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: screenWidth + 30,
                                              child: Text(
                                                AppLocalizations.of(context)
                                                    .mLearnBasedOnYourInterests,
                                                style: GoogleFonts.lato(
                                                  color: AppColors.greys87,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 16,
                                                  letterSpacing: 0.12,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            ContentInfo(
                                              infoMessage: _learnConfig
                                                  .basedOnInterest.description,
                                            ),
                                            Spacer(),
                                            courses.data.length > 0
                                                ? InkWell(
                                                    onTap: () => Navigator.push(
                                                          context,
                                                          FadeRoute(
                                                              page:
                                                                  SeeAllCoursesPage(
                                                            courses.data,
                                                            isInterested: true,
                                                          )),
                                                        ),
                                                    child: SizedBox(
                                                      width: 60,
                                                      child: Text(
                                                        AppLocalizations.of(
                                                                context)
                                                            .mLearnShowAll,
                                                        style: GoogleFonts.lato(
                                                          color: AppColors
                                                              .darkBlue,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 14,
                                                          letterSpacing: 0.12,
                                                        ),
                                                        maxLines: 3,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ))
                                                : Center()
                                          ],
                                        ),
                                      ),
                                      courses.data.length > 0
                                          ? Container(
                                              height: 296,
                                              width: double.infinity,
                                              margin: const EdgeInsets.only(
                                                  top: 5, bottom: 15),
                                              child: AnimationLimiter(
                                                child: ListView.builder(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemCount:
                                                      courses.data.length < 10
                                                          ? courses.data.length
                                                          : 10,
                                                  // itemCount: 1,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return AnimationConfiguration
                                                        .staggeredList(
                                                      position: index,
                                                      duration: const Duration(
                                                          milliseconds: 375),
                                                      child: SlideAnimation(
                                                        verticalOffset: 50.0,
                                                        child: FadeInAnimation(
                                                          child: InkWell(
                                                              onTap: () async {
                                                                _generateInteractTelemetryData(
                                                                    courses
                                                                        .data[
                                                                            index]
                                                                        .id,
                                                                    courses
                                                                        .data[
                                                                            index]
                                                                        .contentType);
                                                                Navigator
                                                                    .pushNamed(
                                                                  context,
                                                                  AppUrl
                                                                      .courseTocPage,
                                                                  arguments:
                                                                      CourseTocModel
                                                                          .fromJson(
                                                                    {
                                                                      'courseId': courses
                                                                          .data[
                                                                              index]
                                                                          .id,
                                                                      'isBlendedProgram': courses.data[index].raw['primaryCategory'] ==
                                                                              'Blended Program'
                                                                          ? true
                                                                          : false,
                                                                    },
                                                                  ),
                                                                );
                                                              },
                                                              child: Container(
                                                                // padding: const EdgeInsets.only(right: 16),
                                                                child:
                                                                    Container(
                                                                  // width: MediaQuery.of(context).size.width -
                                                                  //     10,
                                                                  child: CourseCard(
                                                                      course: courses
                                                                              .data[
                                                                          index]),
                                                                ),
                                                              )),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ))
                                          : Center(child: PageLoader())
                                    ],
                                  )
                                : Center();
                          }),
                      // FutureBuilder(
                      //     future: getRecommendedCoursesFuture,
                      //     builder: (BuildContext context,
                      //         AsyncSnapshot<List<Course>> courses) {
                      //       return (courses.hasData && courses.data != null)
                      //           ? Column(
                      //               children: [
                      //                 Container(
                      //                   padding: const EdgeInsets.fromLTRB(
                      //                       16, 15, 16, 15),
                      //                   child: Row(
                      //                     children: [
                      //                       Text(
                      //                         EnglishLang.recommendedCBPs,
                      //                         style: GoogleFonts.lato(
                      //                           color: AppColors.greys87,
                      //                           fontWeight: FontWeight.w700,
                      //                           fontSize: 16,
                      //                           letterSpacing: 0.12,
                      //                         ),
                      //                       ),
                      //                       ContentInfo(
                      //                         infoMessage: _learnConfig
                      //                             .recommendedCourse
                      //                             .description,
                      //                       ),
                      //                       Spacer(),
                      //                       InkWell(
                      //                           onTap: () => Navigator.push(
                      //                                 context,
                      //                                 FadeRoute(
                      //                                     page:
                      //                                         SeeAllCoursesPage(
                      //                                   courses.data,
                      //                                   isRecommended: true,
                      //                                 )),
                      //                               ),
                      //                           child: Text(
                      //                             AppLocalizations.of(context)
                      //                                 .showAll,
                      //                             style: GoogleFonts.lato(
                      //                               color: AppColors.darkBlue,
                      //                               fontWeight: FontWeight.w400,
                      //                               fontSize: 14,
                      //                               letterSpacing: 0.12,
                      //                             ),
                      //                           ))
                      //                     ],
                      //                   ),
                      //                 ),
                      //                 courses.data.length > 0
                      //                     ? Container(
                      //                         height: 296,
                      //                         width: double.infinity,
                      //                         margin: const EdgeInsets.only(
                      //                             left: 6, top: 5, bottom: 15),
                      //                         child: ListView.builder(
                      //                           scrollDirection:
                      //                               Axis.horizontal,
                      //                           itemCount:
                      //                               courses.data.length < 10
                      //                                   ? courses.data.length
                      //                                   : 10,
                      //                           itemBuilder: (context, index) {
                      //                             return InkWell(
                      //                                 onTap: () async {
                      //                                   var enrolledCourseInfo =
                      //                                       await TocHelper().checkIsCoursesInProgress(
                      //                                           enrolmentList:
                      //                                               _continueLearningcourses,
                      //                                           courseId: courses
                      //                                               .data[index]
                      //                                               .id,
                      //                                           context:
                      //                                               context);
                      //                                   Navigator.pushNamed(
                      //                                     context,
                      //                                     AppUrl.courseTocPage,
                      //                                     arguments:
                      //                                         CourseTocModel
                      //                                             .fromJson(
                      //                                       {
                      //                                         'courseId':
                      //                                             courses
                      //                                                 .data[
                      //                                                     index]
                      //                                                 .id,
                      //                                         'isBlendedProgram': courses.data[index].raw[
                      //                                                         'primaryCategory'] ==
                      //                                                     'Blended Program' ||
                      //                                                 courses.data[index].raw['content']
                      //                                                         [
                      //                                                         'primaryCategory'] ==
                      //                                                     'Blended Program'
                      //                                             ? true
                      //                                             : false,
                      //                                       },
                      //                                     ),
                      //                                   );
                      //                                   if (enrolledCourseInfo !=
                      //                                           null &&
                      //                                       enrolledCourseInfo
                      //                                                   .raw[
                      //                                               'lastReadContentId'] !=
                      //                                           null) {
                      //                                     Navigator.pushNamed(
                      //                                       context,
                      //                                       AppUrl.tocPlayer,
                      //                                       arguments: TocPlayerModel(
                      //                                           enrolmentList:
                      //                                               _continueLearningcourses,
                      //                                           batchId:
                      //                                               enrolledCourseInfo
                      //                                                       .raw[
                      //                                                   'batchId'],
                      //                                           lastAccessContentId:
                      //                                               enrolledCourseInfo
                      //                                                       .raw[
                      //                                                   'lastReadContentId'],
                      //                                           courseId:
                      //                                               enrolledCourseInfo
                      //                                                       .raw[
                      //                                                   'courseId']),
                      //                                     );
                      //                                   }
                      //                                 },
                      //                                 child: CourseCard(
                      //                                     course: courses
                      //                                         .data[index]));
                      //                           },
                      //                         ))
                      //                     : Center(child: PageLoader()),
                      //               ],
                      //             )
                      //           : Center();
                      //     }),
                      FutureBuilder(
                          future: getCourseProgramFuture,
                          builder: (BuildContext context,
                              AsyncSnapshot<List<Course>> programs) {
                            return (programs.hasData && programs.data != null)
                                ? Column(
                                    children: [
                                      Container(
                                        color: Colors.white,
                                        padding: const EdgeInsets.fromLTRB(
                                            16, 25, 16, 15),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: screenWidth,
                                              child: Text(
                                                AppLocalizations.of(context)
                                                    .mLearnPrograms,
                                                style: GoogleFonts.lato(
                                                  color: AppColors.greys87,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 16,
                                                  letterSpacing: 0.12,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            ContentInfo(
                                              infoMessage: _learnConfig
                                                  .newlyAddedCourse.description,
                                            ),
                                            Spacer(),
                                            InkWell(
                                                onTap: () => {
                                                      Navigator.push(
                                                        context,
                                                        FadeRoute(
                                                            page:
                                                                TrendingCoursesPage(
                                                          selectedContentType:
                                                              'program',
                                                          isProgram: true,
                                                          title: AppLocalizations
                                                                  .of(context)
                                                              .mLearnPrograms,
                                                        )),
                                                      )
                                                    },
                                                child: SizedBox(
                                                  width: 60,
                                                  child: Text(
                                                    AppLocalizations.of(context)
                                                        .mLearnShowAll,
                                                    style: GoogleFonts.lato(
                                                      color: AppColors.darkBlue,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 14,
                                                      letterSpacing: 0.12,
                                                    ),
                                                    maxLines: 3,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ))
                                          ],
                                        ),
                                      ),
                                      programs.data.length > 0
                                          ? Container(
                                              color: Colors.white,
                                              height: 326,
                                              width: double.infinity,
                                              padding: const EdgeInsets.only(
                                                  left: 6, top: 5, bottom: 25),
                                              child: ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount:
                                                    programs.data.length < 10
                                                        ? programs.data.length
                                                        : 10,
                                                itemBuilder: (context, index) {
                                                  return InkWell(
                                                      onTap: () async {
                                                        Navigator.pushNamed(
                                                            context,
                                                            AppUrl
                                                                .courseTocPage,
                                                            arguments:
                                                                CourseTocModel
                                                                    .fromJson({
                                                              'courseId':
                                                                  programs
                                                                      .data[
                                                                          index]
                                                                      .id
                                                            }));
                                                      },
                                                      child: CourseCard(
                                                          course: programs
                                                              .data[index],
                                                          isProgram: true));
                                                },
                                              ))
                                          : Center(child: PageLoader()),
                                    ],
                                  )
                                : Center();
                          }),
                      FutureBuilder(
                          future: getCourseRecentlyFuture,
                          builder: (BuildContext context,
                              AsyncSnapshot<List<Course>> courses) {
                            return (courses.hasData && courses.data != null)
                                ? Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            16, 32, 16, 15),
                                        child: Row(
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)
                                                  .mLearnRecentlyAdded,
                                              style: GoogleFonts.lato(
                                                color: AppColors.greys87,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16,
                                                letterSpacing: 0.12,
                                              ),
                                            ),
                                            ContentInfo(
                                              infoMessage: _learnConfig
                                                  .newlyAddedCourse.description,
                                            ),
                                            Spacer(),
                                            InkWell(
                                                onTap: () => Navigator.push(
                                                      context,
                                                      FadeRoute(
                                                          page: TrendingCoursesPage(
                                                              title: AppLocalizations
                                                                      .of(context)
                                                                  .mLearnRecentlyAdded)),
                                                    ),
                                                child: SizedBox(
                                                  width: 60,
                                                  child: Text(
                                                    AppLocalizations.of(context)
                                                        .mLearnShowAll,
                                                    style: GoogleFonts.lato(
                                                      color: AppColors.darkBlue,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 14,
                                                      letterSpacing: 0.12,
                                                    ),
                                                    maxLines: 3,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ))
                                          ],
                                        ),
                                      ),
                                      courses.data.length > 0
                                          ? Container(
                                              height: 296,
                                              width: double.infinity,
                                              margin: const EdgeInsets.only(
                                                  left: 6, top: 5, bottom: 15),
                                              child: ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount:
                                                    courses.data.length < 10
                                                        ? courses.data.length
                                                        : 10,
                                                itemBuilder: (context, index) {
                                                  return InkWell(
                                                      onTap: () async {
                                                        _generateInteractTelemetryData(
                                                            courses
                                                                .data[index].id,
                                                            courses.data[index]
                                                                .contentType);
                                                        Navigator.pushNamed(
                                                          context,
                                                          AppUrl.courseTocPage,
                                                          arguments:
                                                              CourseTocModel
                                                                  .fromJson(
                                                            {
                                                              'courseId':
                                                                  courses
                                                                      .data[
                                                                          index]
                                                                      .id,
                                                            },
                                                          ),
                                                        );
                                                      },
                                                      child: CourseCard(
                                                          course: courses
                                                              .data[index]));
                                                },
                                              ))
                                          : Center(
                                              child: PageLoader(),
                                            ),
                                    ],
                                  )
                                : Center();
                          }),
                      FutureBuilder(
                          future: getStandaloneFuture,
                          builder: (BuildContext context,
                              AsyncSnapshot<List<Course>> courses) {
                            return (courses.hasData &&
                                    (courses.data != null &&
                                        courses.data.length > 0))
                                ? Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            16, 16, 16, 15),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: screenWidth,
                                              child: Text(
                                                AppLocalizations.of(context)
                                                    .mStaticStandaloneAssessments,
                                                style: GoogleFonts.lato(
                                                  color: AppColors.greys87,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 16,
                                                  letterSpacing: 0.12,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            ContentInfo(
                                              infoMessage: AppLocalizations.of(
                                                      context)
                                                  .mStaticStandaloneAssessments,
                                            ),
                                            Spacer(),
                                            InkWell(
                                                onTap: () => Navigator.push(
                                                      context,
                                                      FadeRoute(
                                                          page: TrendingCoursesPage(
                                                              selectedContentType:
                                                                  PrimaryCategory
                                                                      .standaloneAssessment,
                                                              isStandaloneAssessment:
                                                                  true,
                                                              title: AppLocalizations
                                                                      .of(context)
                                                                  .mLearnStandaloneAssessment)),
                                                    ),
                                                child: SizedBox(
                                                  width: 60,
                                                  child: Text(
                                                    AppLocalizations.of(context)
                                                        .mLearnShowAll,
                                                    style: GoogleFonts.lato(
                                                      color: AppColors.darkBlue,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 14,
                                                      letterSpacing: 0.12,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 3,
                                                  ),
                                                ))
                                          ],
                                        ),
                                      ),
                                      courses.data.length > 0
                                          ? Container(
                                              height: 296,
                                              width: double.infinity,
                                              margin: const EdgeInsets.only(
                                                  left: 6, top: 5, bottom: 15),
                                              child: ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount:
                                                    courses.data.length < 10
                                                        ? courses.data.length
                                                        : 10,
                                                itemBuilder: (context, index) {
                                                  return InkWell(
                                                      onTap: () async {
                                                        _generateInteractTelemetryData(
                                                            courses
                                                                .data[index].id,
                                                            courses.data[index]
                                                                .contentType);
                                                        Navigator.pushNamed(
                                                            context,
                                                            AppUrl
                                                                .courseTocPage,
                                                            arguments:
                                                                CourseTocModel
                                                                    .fromJson({
                                                              'courseId':
                                                                  courses
                                                                      .data[
                                                                          index]
                                                                      .id
                                                            }));
                                                      },
                                                      child: CourseCard(
                                                          course: courses
                                                              .data[index]));
                                                },
                                              ))
                                          : Center(
                                              child: PageLoader(),
                                            ),
                                    ],
                                  )
                                : Center();
                          }),
                      // FutureBuilder(
                      //     future: _getCourseTopics(),
                      //     builder: (BuildContext context,
                      //         AsyncSnapshot<dynamic> snapshot) {
                      //       return (_courseTopics != null &&
                      //               _courseTopics.length > 0)
                      //           ? Column(
                      //               crossAxisAlignment:
                      //                   CrossAxisAlignment.center,
                      //               mainAxisAlignment: MainAxisAlignment.center,
                      //               children: [
                      //                 Container(
                      //                   alignment: Alignment.topLeft,
                      //                   child: Padding(
                      //                     padding: const EdgeInsets.only(
                      //                         left: 16.0, bottom: 12),
                      //                     child: Text(
                      //                       EnglishLang.popularTopics,
                      //                       style: GoogleFonts.lato(
                      //                         color: AppColors.greys87,
                      //                         fontWeight: FontWeight.w700,
                      //                         fontSize: 16,
                      //                         letterSpacing: 0.12,
                      //                       ),
                      //                     ),
                      //                   ),
                      //                 ),
                      //                 _courseTopics.length > 1
                      //                     ? Container(
                      //                         height: 100,
                      //                         child: ListView.builder(
                      //                           scrollDirection:
                      //                               Axis.horizontal,
                      //                           shrinkWrap: true,
                      //                           itemCount: 2,
                      //                           itemBuilder: (context, index) {
                      //                             return InkWell(
                      //                                 onTap: () {
                      //                                   Navigator.push(
                      //                                     context,
                      //                                     FadeRoute(
                      //                                         page: TopicCourses(
                      //                                             _courseTopics[
                      //                                                     index]
                      //                                                 .identifier,
                      //                                             _courseTopics[
                      //                                                     index]
                      //                                                 .name,
                      //                                             _courseTopics[
                      //                                                     index]
                      //                                                 .raw)),
                      //                                   );
                      //                                 },
                      //                                 child:
                      //                                     CompetenciesAndTopicsCard(
                      //                                   cardColor: Colors.black,
                      //                                   courseTopics:
                      //                                       _courseTopics[
                      //                                           index],
                      //                                   isTopic: true,
                      //                                 ));
                      //                           },
                      //                         ),
                      //                       )
                      //                     : Center(),
                      //                 _courseTopics.length > 3
                      //                     ? Container(
                      //                         height: 100,
                      //                         child: ListView.builder(
                      //                           scrollDirection:
                      //                               Axis.horizontal,
                      //                           shrinkWrap: true,
                      //                           itemCount: 2,
                      //                           itemBuilder: (context, index) {
                      //                             return InkWell(
                      //                               onTap: () {
                      //                                 Navigator.push(
                      //                                   context,
                      //                                   FadeRoute(
                      //                                       page: TopicCourses(
                      //                                           _courseTopics[
                      //                                                   index +
                      //                                                       2]
                      //                                               .identifier,
                      //                                           _courseTopics[
                      //                                                   index +
                      //                                                       2]
                      //                                               .name,
                      //                                           _courseTopics[
                      //                                                   index +
                      //                                                       2]
                      //                                               .raw)),
                      //                                 );
                      //                               },
                      //                               child:
                      //                                   CompetenciesAndTopicsCard(
                      //                                 cardColor: Colors.black,
                      //                                 courseTopics:
                      //                                     _courseTopics[
                      //                                         index + 2],
                      //                                 isTopic: true,
                      //                               ),
                      //                             );
                      //                           },
                      //                         ),
                      //                       )
                      //                     : Center(),
                      //                 // Row(
                      //                 //   children: [
                      //                 //     _competenciesAndTopicsCard(
                      //                 //       name: 'Politics',
                      //                 //       count: 321,
                      //                 //       cardColor: Colors.black,
                      //                 //     ),
                      //                 //     _competenciesAndTopicsCard(
                      //                 //       name: 'Economics',
                      //                 //       count: 182,
                      //                 //       cardColor: Colors.black,
                      //                 //     ),
                      //                 //   ],
                      //                 // ),
                      //                 InkWell(
                      //                   onTap: () {
                      //                     Navigator.pushNamed(context,
                      //                         AppUrl.browseByTopicPage);
                      //                   },
                      //                   child: Container(
                      //                     width: double.infinity,
                      //                     padding: const EdgeInsets.fromLTRB(
                      //                         16, 8, 16, 16),
                      //                     child: OutlineButtonLearn(
                      //                       name: EnglishLang.exploreByTopic
                      //                           .toUpperCase(),
                      //                       url: AppUrl.browseByTopicPage,
                      //                     ),
                      //                   ),
                      //                 ),
                      //               ],
                      //             )
                      //           : Center();
                      //     }),
                      FutureBuilder(
                          future: getCourseCompetenciesFuture,
                          builder: (BuildContext context,
                              AsyncSnapshot<dynamic> snapshot) {
                            return (_competencies != null &&
                                    _competencies.length > 0)
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        alignment: Alignment.topLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 16.0, bottom: 16, top: 16),
                                          child: Text(
                                            AppLocalizations.of(context)
                                                .mStaticTrendingCompetencies,
                                            style: GoogleFonts.lato(
                                              color: AppColors.greys87,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
                                              letterSpacing: 0.12,
                                            ),
                                          ),
                                        ),
                                      ),
                                      _competencies.length > 1
                                          ? Container(
                                              height: 100,
                                              child: ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                shrinkWrap: true,
                                                itemCount: 2,
                                                itemBuilder: (context, index) {
                                                  return InkWell(
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          FadeRoute(
                                                              page: CoursesInCompetency(
                                                                  _competencies[
                                                                      index])),
                                                        );
                                                      },
                                                      child:
                                                          CompetenciesAndTopicsCard(
                                                        cardColor: Colors.black,
                                                        name:
                                                            _competencies[index]
                                                                .name,
                                                        count:
                                                            _competencies[index]
                                                                .count,
                                                        isTopic: false,
                                                      ));
                                                },
                                              ),
                                            )
                                          : Center(),
                                      _competencies.length > 3
                                          ? Container(
                                              height: 100,
                                              child: ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                shrinkWrap: true,
                                                itemCount: 2,
                                                itemBuilder: (context, index) {
                                                  return InkWell(
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          FadeRoute(
                                                              page: CoursesInCompetency(
                                                                  _competencies[
                                                                      index])),
                                                        );
                                                      },
                                                      child:
                                                          CompetenciesAndTopicsCard(
                                                        cardColor: Colors.black,
                                                        name:
                                                            _competencies[index]
                                                                .name,
                                                        count:
                                                            _competencies[index]
                                                                .count,
                                                        isTopic: false,
                                                      ));
                                                },
                                              ),
                                            )
                                          : Center(),
                                      // Container(
                                      //   height: 100,
                                      //   child: Row(
                                      //     children: [
                                      //       _competenciesAndTopicsCard(
                                      //         name: 'Communication',
                                      //         count: 580,
                                      //         cardColor: AppColors.blueCard,
                                      //       ),
                                      //       _competenciesAndTopicsCard(
                                      //         name: 'Vigilance and Planning',
                                      //         count: 342,
                                      //         cardColor: AppColors.blueCard,
                                      //       ),
                                      //     ],
                                      //   ),
                                      // ),
                                      // Container(
                                      //   height: 100,
                                      //   child: Row(
                                      //     children: [
                                      //       _competenciesAndTopicsCard(
                                      //         name: 'Time management',
                                      //         count: 321,
                                      //         cardColor: AppColors.blueCard,
                                      //       ),
                                      //       _competenciesAndTopicsCard(
                                      //         name: 'Design thinking',
                                      //         count: 182,
                                      //         cardColor: AppColors.blueCard,
                                      //       ),
                                      //     ],
                                      //   ),
                                      // ),
                                      InkWell(
                                        onTap: () {
                                          Navigator.pushNamed(context,
                                              AppUrl.browseByCompetencyPage);
                                        },
                                        child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.fromLTRB(
                                              16, 8, 16, 0),
                                          child: OutlineButtonLearn(
                                            name: AppLocalizations.of(context)
                                                .mStaticBrowseByCompetencies
                                                .toUpperCase(),
                                            url: AppUrl.browseByCompetencyPage,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Center();
                          }),
                      // InkWell(
                      //     onTap: () {
                      //       Navigator.pushNamed(
                      //           context, AppUrl.browseByCompetencyPage);
                      //     },
                      //     child: Padding(
                      //       padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                      //       child: OutlineButtonLearn(
                      //         name: 'Browse by _competencies',
                      //       ),
                      //     )),
                      // Container(
                      //   padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
                      //   child: Row(
                      //     children: [
                      //       Text(
                      //         EnglishLang.lastViewedCBPs,
                      //         style: GoogleFonts.lato(
                      //           color: AppColors.greys87,
                      //           fontWeight: FontWeight.w700,
                      //           fontSize: 16,
                      //           letterSpacing: 0.12,
                      //         ),
                      //       ),
                      //       Spacer(),
                      //       InkWell(
                      //           onTap: () => Navigator.push(
                      //                 context,
                      //                 FadeRoute(page: TrendingCoursesPage()),
                      //               ),
                      //           child: Text(
                      //             EnglishLang.seeAll,
                      //             style: GoogleFonts.lato(
                      //               color: AppColors.primaryThree,
                      //               fontWeight: FontWeight.w700,
                      //               fontSize: 16,
                      //               letterSpacing: 0.12,
                      //             ),
                      //           ))
                      //     ],
                      //   ),
                      // ),
                      // Padding(
                      //   padding: const EdgeInsets.only(bottom: 16),
                      //   child: Container(
                      //       height: 348,
                      //       width: double.infinity,
                      //       padding: const EdgeInsets.only(
                      //           left: 6, top: 5, bottom: 15),
                      //       child: ListView.builder(
                      //         scrollDirection: Axis.horizontal,
                      //         itemCount: _trendingCourses.length,
                      //         itemBuilder: (context, index) {
                      //           return InkWell(
                      //               onTap: () {
                      //                 _generateInteractTelemetryData(
                      //                     _trendingCourses[index].id);
                      //                 Navigator.push(
                      //                   context,
                      //                   FadeRoute(
                      //                       page: CourseDetailsPage(
                      //                           id: _trendingCourses[index]
                      //                               .id)),
                      //                 );
                      //               },
                      //               child: CourseItem(
                      //                   course: _trendingCourses[index]));
                      //         },
                      //       )),
                      // ),
                      GestureDetector(
                        onTap: _scrollToTop,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 32, bottom: 32),
                          child: Column(
                            children: [
                              Container(
                                height: 48,
                                width: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(
                                      const Radius.circular(50)),
                                ),
                                child: Center(
                                    child: Icon(
                                  Icons.arrow_upward,
                                  color: AppColors.greys60,
                                  size: 24,
                                )),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 100, top: 12),
                                child: Text(
                                  AppLocalizations.of(context).mStaticBackToTop,
                                  style: GoogleFonts.lato(
                                    color: AppColors.greys60,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    letterSpacing: 0.12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 120,
                      )
                    ],
                  ),
                );
              } else {
                return PageLoader(
                  bottom: 150,
                );
              }
            }));
  }

  bool checkAllBatchEndDateOver(course) {
    bool batchstatus = true;
    if (course['batches'] != null) {
      course['batches'].forEach((batch) {
        if (batchstatus == true) {
          if (batch['endDate'] != null) {
            if (DateTime.parse(batch['endDate']).isAfter(DateTime.now()) ||
                (Helper.getDateTimeInFormat(batch['endDate']) ==
                    (Helper.getDateTimeInFormat(DateTime.now().toString())))) {
              batchstatus = false;
            }
          }
        }
      });
    }
    return batchstatus;
  }

  dynamic checkCourseEnrolled(String id) {
    if (_continueLearningcourses == null && _continueLearningcourses.isEmpty) {
      return null;
    } else {
      return _continueLearningcourses.firstWhere(
        (element) => element.raw['courseId'] == id,
        orElse: () => null,
      );
    }
  }
}
