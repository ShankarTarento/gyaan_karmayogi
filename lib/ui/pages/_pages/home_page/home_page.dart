import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:karmayogi_mobile/models/_models/batch_attributes_model.dart';
import 'package:karmayogi_mobile/models/_models/landing_page_info_model.dart';
import 'package:karmayogi_mobile/models/_models/learn_config_model.dart';
import 'package:karmayogi_mobile/models/_models/overlay_theme_model.dart';
import 'package:karmayogi_mobile/models/_models/user_feed_model.dart';
import 'package:karmayogi_mobile/respositories/_respositories/in_app_review_repository.dart';
import 'package:karmayogi_mobile/respositories/_respositories/landing_page_repository.dart';
import 'package:karmayogi_mobile/respositories/_respositories/learn_repository.dart';
import 'package:karmayogi_mobile/respositories/_respositories/nps_repository.dart';
import 'package:karmayogi_mobile/services/_services/landing_page_service.dart';
import 'package:karmayogi_mobile/services/_services/report_service.dart';
import 'package:karmayogi_mobile/ui/widgets/_home/display_widget_for_duration.dart';
import 'package:karmayogi_mobile/ui/widgets/_home/user_nudge_card.dart';
import 'package:karmayogi_mobile/ui/widgets/_network/follow_us_social_media.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../../../constants/_constants/storage_constants.dart';
import '../../../../constants/_constants/telemetry_constants.dart';
import '../../../../models/_models/leaderboard_model.dart';
import '../../../../models/_arguments/index.dart';
import '../../../../respositories/_respositories/profile_repository.dart';
import '../../../../respositories/index.dart';
import '../../../../util/faderoute.dart';
import '../../../../util/helper.dart';
import '../../../screens/index.dart';
import '../../../../constants/index.dart';
import '../../../skeleton/index.dart';
import '../../../widgets/_home/leaderboard_nudge_card.dart';
import '../../../widgets/index.dart';
import '../../index.dart';
import '../../../../services/index.dart';
import '../../../../models/index.dart';
import '../../../../localization/index.dart';
import '../../../../util/telemetry.dart';
import '../../../../util/telemetry_db_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  static const route = AppUrl.homePage;
  final int index;

  HomePage({
    Key key,
    this.index,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final CareerOpeningService careerOpeningService = CareerOpeningService();
  final SuggestionService suggestionService = SuggestionService();
  final TelemetryService telemetryService = TelemetryService();
  final landingPageService = LandingPageService();
  final ReportService reportService = ReportService();
  ScrollController _controller = ScrollController();
  ProfileService profileService = ProfileService();
  final LearnService learnService = LearnService();

  List _data, trendingDiscussionList = [];
  int pageNo = 1;
  int totalCount = 1;
  int connectionRequests = 0;

  String userId;
  String userSessionId;
  String messageIdentifier;
  String departmentId;
  int _start = 0;
  List allEventsData;
  bool dataSent;
  String deviceIdentifier;
  var telemetryEventData;
  List<Profile> _profileDetails;
  List<Suggestion> _suggestions;
  List<dynamic> _requestedConnections = [];
  LearnConfig _homeCoursesConfig;
  bool _pageInitialized = false;
  List _flaggedDiscussions = [];
  final _storage = FlutterSecureStorage();
  Timer _timer;
  ValueNotifier<bool> _isDisplayUserNudge = ValueNotifier(false);
  ValueNotifier<bool> _isDisplayLeaderboardNudge = ValueNotifier(false);
  ValueNotifier<bool> _showOverlayThemeUpdates = ValueNotifier(false);
  OverlayThemeModel overlayThemeUpdatesData;
  final List<Color> gradientColors = <Color>[];

  var _mandatoryFields = [];
  var _personalToFill = [];
  var _professionalToFill = [];
  var _academicToFill = [];

  List<Map<String, BatchAttributes>> batchAttributes = [];
  String courseId = '';
  String batchId = '';
  String sessionId = '';

  String feedId, enableRating = '0';
  Map<String, dynamic> formFields;
  int _npsFormId;
  var trendingFuture;
  List<Map<String, dynamic>> orderedSessions = [];
  Future getTrendingDisscussionFuture;
  Future<List<Course>> curratedCollectionsFuture;
  Future<List<Course>> landingPageFuture;
  // Future<List<Course>> getCoursesFuture;
  Future<Map<dynamic, dynamic>> getEnrolledCoursesFuture;
  Future<List<Course>> getStandaloneFuture;
  Future<List<CareerOpening>> careerOpeningFuture;
  Future<List<Profile>> getProfileFuture;
  Future<dynamic> getLatestDiscussionFuture;
  Future<dynamic> getUserInsightFuture;
  Future<List<Course>> getCourseRecentlyFuture;
  Future<List<Course>> getProgramsRecentlyFuture;
  LandingPageInfo getLandingPageInfoData;

  AnimationController _animationController;
  Animation<double> _opacityAnimation;
  Animation<double> _fadeOutAnimation;
  int get nudgeFadeInOutDuration => 500;
  int get leaderboardCelebrationPlayDuration => 1100;

  /// leaderboard
  LeaderboardModel _leaderboardData;

  Map<dynamic, dynamic> enrolmentList;
  bool enableEnrolPopupOnLaunch = false;
  List<Course> enrolmentCourseList = [];

  @override
  void initState() {
    super.initState();
    allEventsData = [];
    dataSent = false;
    if (widget.index == 0) {
      _getUserNudgeAndThemeInfo();
      _getCourses();
      _getFlaggedContent();
      _getConnectionRequest();
      _getAllSuggestions();
      _getRequestedConnections();
      _getUpcomingSchedules();
      if (_start == 0) {
        _generateTelemetryData();
      }
      _start++;
      // Create the animation controller
      _animationController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: nudgeFadeInOutDuration),
      );
      _opacityAnimation =
          Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
      _fadeOutAnimation =
          Tween<double>(begin: 1.0, end: 0.0).animate(_animationController);
      // WidgetsBinding.instance.addPostFrameCallback((_) async {
      //   _animationController = AnimationController(
      //     vsync: this,
      //     duration: Duration(milliseconds: nudgeFadeInOutDuration),
      //   );
      //   _opacityAnimation =
      //       Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
      //   _fadeOutAnimation =
      //       Tween<double>(begin: 1.0, end: 0.0).animate(_animationController);
      // });
    }
    _getFormFeed();
    _getFutureData();
    getCoursesAndPrograms();
    _getLeaderboardData();
  }

  _getUserNudgeAndThemeInfo() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<LandingPageRepository>(context, listen: false)
          .getUserNudgeAndThemeInfo();
      _startTimer();
    });
  }

  void _getFutureData() {
    getTrendingDiscussion();
    getCurratedCourses();
    getLandingPageServiceCourse();

    // getCourse();
    getCourseRecently();
    getProgramsRecently();
    getEnrolledCoursesFuture = getEnrolmentInfo();
    getStandaloneCourses();
    getCareerOpenings();
    getUserInsights();
    getLatestDiscussion();
    getProfile();
  }

  void _startTimer() {
    int start = 0;
    int nudgeStartSecond =
        Provider.of<LandingPageRepository>(context, listen: false).profileDelay;
    int nudgeEndSecond = nudgeStartSecond +
        Provider.of<LandingPageRepository>(context, listen: false).nudgeDelay;
    _isDisplayUserNudge.value =
        Provider.of<LandingPageRepository>(context, listen: false)
                .displayUserNudge &&
            Provider.of<LandingPageRepository>(context, listen: false)
                .isProfileCardExpanded;

    _isDisplayLeaderboardNudge.value =
        Provider.of<LandingPageRepository>(context, listen: false)
                .displayUserNudge &&
            Provider.of<LandingPageRepository>(context, listen: false)
                .isProfileCardExpanded;

    _showOverlayThemeUpdates.value =
        Provider.of<LandingPageRepository>(context, listen: false)
            .displayOverlayTheme;
    if (_showOverlayThemeUpdates.value) {
      overlayThemeUpdatesData =
          Provider.of<LandingPageRepository>(context, listen: false)
              .overleyThemeData;

      Provider.of<LandingPageRepository>(context, listen: false)
          .overleyThemeData
          .backgroundColors
          .forEach((element) {
        gradientColors.add(Color(int.parse(element)));
      });
    }

    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      start++;
      if ((start > nudgeStartSecond && start < nudgeEndSecond) &&
          (Provider.of<LandingPageRepository>(context, listen: false)
                  .displayUserNudge &&
              Provider.of<LandingPageRepository>(context, listen: false)
                  .isProfileCardExpanded)) {
        _isDisplayUserNudge.value = true;
        _animationController.forward();
      } else if (start == nudgeEndSecond) {
        _isDisplayUserNudge.value = false;
        _animationController.reverse();
        _timer.cancel();
      } else {
        _isDisplayUserNudge.value = false;
      }
    });
  }

  void getTrendingDiscussion() {
    getTrendingDisscussionFuture = _trendingDiscussion();
  }

  void getCurratedCourses() {
    curratedCollectionsFuture =
        Provider.of<LearnRepository>(context, listen: false).getCourses(
            1, '', ['CuratedCollections'], [], [],
            hasRequestBody: _homeCoursesConfig != null ? true : false,
            requestBody: _homeCoursesConfig != null
                ? _homeCoursesConfig.curatedCollectionConfig.requestBody
                : null);
  }

  void getLandingPageServiceCourse() {
    landingPageFuture = landingPageService.getFeaturedCourses(
        pathUrl: (_homeCoursesConfig != null &&
                _homeCoursesConfig.featuredCoursesConfig != null)
            ? _homeCoursesConfig.featuredCoursesConfig.requestBody['api']
                ['path']
            : null);
  }

  void getCourseRecently() {
    getCourseRecentlyFuture =
        Provider.of<LearnRepository>(context, listen: false)
            .getCourses(1, '', [PrimaryCategory.course], [], []);
  }

  void getProgramsRecently() {
    getProgramsRecentlyFuture =
        Provider.of<LearnRepository>(context, listen: false).getCourses(1, '', [
      PrimaryCategory.curatedProgram,
    ], [], []);
  }

  // void getCourse() {
  //   getCoursesFuture = Provider.of<LearnRepository>(context, listen: false)
  //       .getCourses(1, '', ['course'], [], [],
  //           hasRequestBody: _homeCoursesConfig != null ? true : false,
  //           requestBody: _homeCoursesConfig != null
  //               ? _homeCoursesConfig.newlyAddedCourse.requestBody
  //               : null);
  // }
  Future<Map<String, dynamic>> getEnrolmentInfo() async {
    String responseData =
        await _storage.read(key: Storage.userCourseEnrolmentInfo);
    String time = await _storage.read(key: Storage.enrolmentExpiryTime);
    DateTime expiryTime = time != null ? DateTime.parse(time) : null;
    if (responseData != null &&
        (expiryTime != null &&
            expiryTime.difference(DateTime.now()).inSeconds >= 0)) {
      var enrolmentInfo = jsonDecode(responseData);
      var enrolmentListResponse =
          await _storage.read(key: Storage.enrolmentList);
      List<dynamic> list = jsonDecode(enrolmentListResponse);
      enrolmentCourseList = list
          .map(
            (dynamic item) => Course.fromJson(item),
          )
          .toList();
      return enrolmentInfo;
    } else {
      return await fetchEnrolInfo();
    }
  }

  Future<dynamic> fetchEnrolInfo() async {
    Map<String, dynamic> response =
        await Provider.of<LearnRepository>(context, listen: false)
            .getEnrollmentList();
    if (response != null) {
      _storage.write(
          key: Storage.userCourseEnrolmentInfo,
          value: jsonEncode(response['userCourseEnrolmentInfo']));
      _storage.write(
          key: Storage.enrolmentList, value: jsonEncode(response['courses']));
      _storage.write(
          key: Storage.enrolmentExpiryTime,
          value: DateTime.now()
              .add(Duration(seconds: CACHE_EXPIRY_DURATION))
              .toString());
      List<dynamic> list = response['courses'];
      enrolmentCourseList = list
          .map(
            (dynamic item) => Course.fromJson(item),
          )
          .toList();
    }
    return response['userCourseEnrolmentInfo'];
  }

  void getUserInsights() async {
    getUserInsightFuture =
        Provider.of<ProfileRepository>(context, listen: false)
            .getInsights(context);
  }

  void getStandaloneCourses() {
    getStandaloneFuture = Provider.of<LearnRepository>(context, listen: false)
        .getCourses(1, '', [PrimaryCategory.standaloneAssessment], [], []);
  }

  void getCareerOpenings() {
    careerOpeningFuture = careerOpeningService.getCareerOpenings();
  }

  void getProfile() {
    getProfileFuture = _getProfileDetails();
  }

  void getLatestDiscussion() {
    getLatestDiscussionFuture = _getLatestDiscussion();
  }

  void _modalBottomSheetMenu(show) async {
    await Provider.of<InAppReviewRespository>(context, listen: false)
        .setOtherPopupVisibleStatus(true);
    showModalBottomSheet<Widget>(
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return show == 'true'
            ? SingleChildScrollView(
                child: NPSFeedback(formFields, _npsFormId, feedId))
            : Center();
      },
    ).whenComplete(() async {
      await Provider.of<InAppReviewRespository>(context, listen: false)
          .setOtherPopupVisibleStatus(false);
    });
  }

  void _generateTelemetryData() async {
    deviceIdentifier = await Telemetry.getDeviceIdentifier();
    userId = await Telemetry.getUserId();
    userSessionId = await Telemetry.generateUserSessionId();
    messageIdentifier = await Telemetry.generateUserSessionId();
    departmentId = await Telemetry.getUserDeptId();
    Map eventData1 = Telemetry.getImpressionTelemetryEvent(
        deviceIdentifier,
        userId,
        departmentId,
        TelemetryPageIdentifier.homePageId,
        userSessionId,
        messageIdentifier,
        TelemetryType.app,
        TelemetryPageIdentifier.homePageUri,
        env: TelemetryEnv.home);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData1);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());
  }

  _getFormFeed() async {
    String userId = await _storage.read(key: Storage.userId);
    List<UserFeed> userFeed =
        await Provider.of<NpsRepository>(context, listen: false)
            .getFormFeed(userId);
    userFeed.forEach((element) async {
      if (element.category == FeedCategory.nps &&
          element.data['actionData'] != null &&
          element.data['actionData']['formId'] != null) {
        _npsFormId = element.data['actionData']['formId'];
        feedId = element.feedId;
        await _storage.write(key: Storage.showRatingPlatform, value: 'true');
        if (_npsFormId != null) _getFormById(_npsFormId);
      }
      if (element.category == FeedCategory.inAppReview) {
        bool isExpired = DateTime.fromMillisecondsSinceEpoch(
                int.parse(element.expireOn.toString()))
            .isBefore(DateTime.now());
        if (!isExpired) {
          await Provider.of<InAppReviewRespository>(context, listen: false)
              .rateAppOnWeeklyClap(context: context, feedId: element.feedId);
        }
      }
    });
  }

  _getFormById(formId) async {
    formFields = await Provider.of<NpsRepository>(context, listen: false)
        .getFormById(formId);
    String show = await _storage.read(key: Storage.showRatingPlatform);
    enableRating = await _storage.read(key: Storage.enableRating);
    if (show == 'true' && int.parse(enableRating) >= 4) {
      Future.delayed(Duration.zero, () {
        _modalBottomSheetMenu(show);
      });
    }
    if (mounted) {
      setState(() {});
    }
  }

  _getCourses() async {
    _homeCoursesConfig =
        await Provider.of<LearnRepository>(context, listen: false)
            .getHomeCoursesConfig();
  }

  void _generateInteractTelemetryData(String contentId,
      {String subType = '',
      String primaryCategory,
      bool isObjectNull = false,
      String clickId}) async {
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
    // allEventsData.add(eventData);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());
  }

  Future<List<Profile>> _getProfileDetails() async {
    // _getConnectivity();
    if (!_pageInitialized && mounted) {
      _profileDetails =
          await Provider.of<ProfileRepository>(context, listen: false)
              .getProfileDetailsById('');
      if (mounted) {
        setState(() {
          _pageInitialized = true;
          _showPopupToUpdateProfile();
        });
      }
    }
    return _profileDetails;
  }

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

  bool _isProfessionalMandatoryFilled() {
    bool completed = true;
    Map professionalDetails = _profileDetails.first.professionalDetails.first;
    for (var field in _professionalToFill) {
      switch (field) {
        case 'organisationType':
          if (professionalDetails['organisationType'] == null ||
              professionalDetails['organisationType'].isEmpty) {
            completed = false;
          }
          break;
        case 'departmentName':
          if (professionalDetails['departmentName'] == null ||
              professionalDetails['departmentName'].isEmpty) {
            completed = false;
          }
          break;
        case 'industry':
          if (professionalDetails['industry'] == null ||
              professionalDetails['industry'].isEmpty) {
            completed = false;
          }
          break;
        case 'designation':
          if (professionalDetails['designation'] == null ||
              professionalDetails['designation'].isEmpty) {
            completed = false;
          }
          break;
        case 'location':
          if (professionalDetails['location'] == null ||
              professionalDetails['location'].isEmpty) {
            completed = false;
          }
          break;
        case 'doj':
          if (professionalDetails['doj'] == null ||
              professionalDetails['doj'].isEmpty) {
            completed = false;
          }
          break;
        case 'description':
          if (professionalDetails['description'] == null ||
              professionalDetails['description'].isEmpty) {
            completed = false;
          }
          break;
        default:
      }
    }
    return completed;
  }

  bool _isPersonalMandatoryFilled() {
    bool personal = true;
    Map personalDetails = _profileDetails.first.personalDetails;
    for (var field in _personalToFill) {
      switch (field) {
        case 'firstname':
          if (personalDetails['firstname'] == null ||
              personalDetails['firstname'].isEmpty) {
            personal = false;
          }
          break;
        case 'dob':
          if (personalDetails['dob'] == null ||
              personalDetails['dob'].isEmpty) {
            personal = false;
          }
          break;
        case 'nationality':
          if (personalDetails['nationality'] == null ||
              personalDetails['nationality'].isEmpty) {
            personal = false;
          }
          break;
        case 'gender':
          if (personalDetails['gender'] == null ||
              personalDetails['gender'].isEmpty) {
            personal = false;
          }
          break;
        case 'maritalStatus':
          if (personalDetails['maritalStatus'] == null ||
              personalDetails['maritalStatus'].isEmpty) {
            personal = false;
          }
          break;
        case 'category':
          if (personalDetails['category'] == null ||
              personalDetails['category'].isEmpty) {
            personal = false;
          }
          break;
        case 'domicileMedium':
          if (personalDetails['domicileMedium'] == null ||
              personalDetails['domicileMedium'].isEmpty) {
            personal = false;
          }
          break;
        case 'primaryEmail':
          if (personalDetails['primaryEmail'] == null ||
              personalDetails['primaryEmail'].isEmpty) {
            personal = false;
          }
          break;
        case 'postalAddress':
          if (personalDetails['postalAddress'] == null ||
              personalDetails['postalAddress'].isEmpty) {
            personal = false;
          }
          break;
        case 'pincode':
          if (personalDetails['pincode'] == null ||
              personalDetails['pincode'].isEmpty) {
            personal = false;
          }
          break;
        default:
      }
    }
    return personal;
  }

  Future<int> _getTabIndexToEditProfile() async {
    _mandatoryFields = await profileService.getProfileMandatoryFields();
    for (var i = 0; i < _mandatoryFields.length; i++) {
      if (_mandatoryFields[i].contains('profileDetails.personalDetails')) {
        _personalToFill.add(_mandatoryFields[i].toString().split('.').last);
      } else if (_mandatoryFields[i]
          .contains('profileDetails.professionalDetails')) {
        _professionalToFill.add(_mandatoryFields[i].toString().split('.').last);
      } else if (_mandatoryFields[i].contains('profileDetails.academics')) {
        _academicToFill.add(_mandatoryFields[i].toString().split('.').last);
      }
    }
    int tabIndex = 0;
    if (_personalToFill.length > 0 && !_isPersonalMandatoryFilled()) {
      tabIndex = 0;
    } else if (_professionalToFill.length > 0 &&
        !_isProfessionalMandatoryFilled()) {
      tabIndex = 2;
    }
    return tabIndex;
  }

  _showPopupToUpdateProfile() async {
    bool showGetStarted =
        await _storage.read(key: Storage.getStarted).then((value) {
      return value != GetStarted.finished || value == 'null';
    });
    if (showGetStarted) return;

    String showNPS = await _storage.read(key: Storage.showRatingPlatform);
    if (showNPS == 'true') return;

    String showReminder = await _storage.read(key: Storage.showReminder);
    if (showReminder != EnglishLang.no) {
      int _profileCompleted = await _getProfileCompleted();

      Map personalDetails = _profileDetails.first.personalDetails;
      // Nudge for mobile number update
      if ((personalDetails['mobile'] == null ||
              personalDetails['mobile'] == '') ||
          (personalDetails['phoneVerified'] == null ||
              personalDetails['phoneVerified'] == false)) {
        Future.delayed(Duration.zero, () {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await Provider.of<InAppReviewRespository>(context, listen: false)
                .setOtherPopupVisibleStatus(true);
            await _showDialogToUpdateNumber();
          });
        });
      }
      // Nudge for profile details update
      else if (_profileCompleted != 100) {
        Future.delayed(Duration(milliseconds: 500), () {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await Provider.of<InAppReviewRespository>(context, listen: false)
                .setOtherPopupVisibleStatus(true);
            await _showDialogToUpdateNumber(
              isUpdateProfile: true,
            );
          });
        });
      }
    }
  }

  _showDialogToUpdateNumber(
      {bool isUpdateProfile = false, String focus}) async {
    int tabIndex = await _getTabIndexToEditProfile();
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 70),
              child: AlertDialog(
                contentPadding: EdgeInsets.zero,
                insetPadding: EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0),
                ),
                content: Container(
                  padding: EdgeInsets.fromLTRB(17, 0, 17, 0),
                  height: 64,
                  decoration: BoxDecoration(
                      color: AppColors.orangeLightShade,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.orangeTourText)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            _storage.write(
                                key: Storage.showReminder,
                                value: EnglishLang.no);
                            Navigator.of(ctx).pop();
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.close,
                                color: AppColors.grey40,
                                size: 20,
                              ),
                              SvgPicture.asset(
                                'assets/img/phone_update.svg',
                                height: 58,
                                width: 54,
                              ),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    left: !isUpdateProfile ? 8 : 4,
                                    right: 4,
                                    // top: !isUpdateProfile ? 16 : 0,
                                    // bottom: isUpdateProfile ? 16 : 0
                                  ),
                                  child: TitleRegularGrey60(
                                    !isUpdateProfile
                                        ? AppLocalizations.of(context)
                                            .mStaticUpdatePhoneNumber
                                        : AppLocalizations.of(context)
                                            .mStaticUpdateProfile,
                                    color: AppColors.greys87,
                                    maxLines: 2,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: 87,
                        height: 32,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(63)),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.darkBlue,
                            minimumSize: const Size.fromHeight(40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(63),
                            ),
                          ),
                          onPressed: () async {
                            Navigator.of(ctx).pop();
                            await Provider.of<InAppReviewRespository>(context,
                                    listen: false)
                                .setOtherPopupVisibleStatus(false);
                            if (isUpdateProfile) {
                              Navigator.push(
                                context,
                                FadeRoute(
                                    page: EditProfileScreen(
                                  focus: focus,
                                  tabIndex: tabIndex,
                                  isToUpdateProfile: true,
                                )),
                              );
                            } else {
                              Navigator.push(
                                context,
                                FadeRoute(
                                    page: EditProfileScreen(
                                  isToUpdateMobileNumber: true,
                                )),
                              );
                            }
                          },
                          child: Text(
                            AppLocalizations.of(context).mCommonUpdate,
                            style: TextStyle(
                                fontSize: 14,
                                color: AppColors.avatarText,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ).whenComplete(() async {
      await Provider.of<InAppReviewRespository>(context, listen: false)
          .setOtherPopupVisibleStatus(false);
    });
  }

  /// Get connection request response
  Future<void> _getConnectionRequest() async {
    try {
      var response =
          await Provider.of<NetworkRespository>(context, listen: false)
              .getCrList();
      setState(() {
        connectionRequests = response.data.length;
      });
    } catch (err) {
      return err;
    }
  }

  Future<List<dynamic>> _getAllSuggestions() async {
    try {
      final response = await suggestionService.getSuggestions();
      setState(() {
        if (response.runtimeType == String) {
          return [];
        }
        _suggestions = response;
      });
      return _suggestions;
    } catch (err) {
      return [];
    }
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

  // Get trending discussions
  Future<dynamic> _trendingDiscussion() async {
    try {
      if (pageNo == 1) {
        _data = await Provider.of<DiscussRepository>(context, listen: false)
            .getPopularDiscussions(pageNo);
      } else {
        _data.addAll(
            await Provider.of<DiscussRepository>(context, listen: false)
                .getPopularDiscussions(pageNo));
      }
      _data = _data.toSet().toList();
      _data.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));

      _flaggedDiscussions.forEach((flagged) {
        _data.removeWhere((data) =>
            data.tid == int.parse(flagged['contextTypeId']) ||
            data.user['uid'] == int.parse(flagged['contextTypeId']));
      });
    } catch (err) {
      return err;
    }
    if (_data != null && _data.length > 0 && trendingDiscussionList.isEmpty) {
      if (_data.length > DISCUSS_CARD_DISPLAY_LIMIT) {
        trendingDiscussionList
            .addAll(_data.sublist(0, DISCUSS_CARD_DISPLAY_LIMIT));
      } else {
        trendingDiscussionList = _data;
      }
    }
    return _data;
  }

  // Navigate to discussion detail
  _navigateToDiscussionDetail(tid, userName, title, uid) {
    _generateInteractTelemetryData(tid.toString(),
        primaryCategory: TelemetrySubType.discussion,
        subType: TelemetrySubType.trendingDiscussions,
        clickId: TelemetryIdentifier.cardContent);
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

  _loadMore() {
    if (pageNo <= totalCount && mounted) {
      setState(() {
        pageNo = pageNo + 1;
        if (_data[0].topicCount != null) {
          totalCount = (_data[0].topicCount / _data[0].nextStart).ceil();
        }
        // totalCount = 5;
        _trendingDiscussion();
      });
    }
  }

  Future<void> _createConnectionRequest(id) async {
    var _response;
    try {
      List<Profile> profileDetailsFrom;
      profileDetailsFrom =
          await Provider.of<ProfileRepository>(context, listen: false)
              .getProfileDetailsById('');
      List<Profile> profileDetailsTo;
      profileDetailsTo =
          await Provider.of<ProfileRepository>(context, listen: false)
              .getProfileDetailsById(id);
      _response = await NetworkService.postConnectionRequest(
          id, profileDetailsFrom, profileDetailsTo);

      if (_response['result']['status'] == 'CREATED') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context).mStaticConnectionRequestSent),
            backgroundColor: AppColors.positiveLight,
          ),
        );
        await _getRequestedConnections();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).mStaticErrorMessage),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      setState(() {});
    } catch (err) {
      print(err);
    }
  }

  _getRequestedConnections() async {
    final response =
        await Provider.of<NetworkRespository>(context, listen: false)
            .getRequestedConnections();
    if (mounted) {
      setState(() {
        _requestedConnections = response;
      });
    }
  }

  Future<void> getCoursesAndPrograms() async {
    await Provider.of<LearnRepository>(context, listen: false)
        .getCourses(1, '', [], [], []);
  }

  void _getLeaderboardData() async {
    List<LeaderboardModel> _leaderboardDataList = [];
    try {
      dynamic result =
          await Provider.of<ProfileRepository>(context, listen: false)
              .getLeaderboardData();
      if (result != null) {
        _leaderboardDataList = List<LeaderboardModel>.from(
            result.map((data) => LeaderboardModel.fromJson(data)).toList());
        if (_leaderboardDataList.isNotEmpty) {
          String userId = await _storage.read(key: Storage.wid);
          _leaderboardDataList.forEach((element) {
            if (userId == element.userId ?? "") {
              _leaderboardData = element;
            }
          });
        }
      }
    } catch (error) {
      print('$error');
    }
  }

  @override
  void dispose() async {
    _controller.dispose();
    _animationController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return newHome();
  }

  Widget newHome() {
    return NotificationListener<ScrollNotification>(
        // ignore: missing_return
        onNotification: (ScrollNotification scrollInfo) {
          // _loadMore();
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            _loadMore();
          }
        },
        child: widget.index == 0
            ? FutureBuilder(
                future: getTrendingDisscussionFuture,
                builder: (context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return Container(
                        decoration: _showOverlayThemeUpdates.value
                            ? BoxDecoration(
                                color: AppColors.whiteGradientOne,
                                gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: gradientColors))
                            : BoxDecoration(color: AppColors.whiteGradientOne),
                        // height: MediaQuery.of(context).size.height,
                        child: MediaQuery.removePadding(
                          removeTop: true,
                          context: context,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Container(
                                  color: AppColors.appBarBackground,
                                  child: Container(
                                    alignment: Alignment.center,
                                    margin: const EdgeInsets.only(
                                        top: 16, left: 8, bottom: 8),
                                    height: 90,
                                    child: ListView(
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      children: HUBS(context: context)
                                          .map(
                                            (hub) => InkWell(
                                              onTap: () async {
                                                if (hub.telemetryId != null &&
                                                    hub.telemetryId
                                                        .isNotEmpty) {
                                                  _generateInteractTelemetryData(
                                                      hub.telemetryId,
                                                      subType: TelemetrySubType
                                                          .hubMenu,
                                                      isObjectNull: true);
                                                }
                                                if (hub.comingSoon) {
                                                  Navigator.push(
                                                    context,
                                                    FadeRoute(
                                                        page:
                                                            ComingSoonScreen()),
                                                  );
                                                } else {
                                                  enableRating =
                                                      await _storage.read(
                                                          key: Storage
                                                              .enableRating);
                                                  if (int.parse(enableRating) >=
                                                      3) {
                                                    if (_npsFormId != null) {
                                                      await _getFormById(
                                                          _npsFormId);
                                                    }
                                                  }
                                                  Navigator.pushNamed(
                                                      context, hub.url);
                                                }
                                              },
                                              child: Container(
                                                  margin: const EdgeInsets.only(
                                                      left: 20, right: 20),
                                                  // width: 95.0,
                                                  child: HomeHubItemNew(
                                                      hub.id,
                                                      hub.title,
                                                      hub.icon,
                                                      hub.iconColor,
                                                      hub.url,
                                                      (hub.id == 4 &&
                                                              connectionRequests >
                                                                  0)
                                                          ? true
                                                          : false,
                                                      hub.svgIcon)),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ),
                                ),
                                enrolmentList != null
                                    ? !courseEnrolmentStatus(enrolmentList) &&
                                            enableEnrolPopupOnLaunch
                                        ? courseFirstEnrolPopup()
                                        : SizedBox.shrink()
                                    : SizedBox.shrink(),
                                overlayThemeUpdatesData != null
                                    ? Visibility(
                                        visible:
                                            _showOverlayThemeUpdates.value &&
                                                overlayThemeUpdatesData != null,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12.0),
                                              child: Lottie.network(
                                                ApiUrl.baseUrl +
                                                        overlayThemeUpdatesData
                                                            .logoUrl ??
                                                    '',
                                                width: 80,
                                                height: 80,
                                              ),
                                            ),
                                            Flexible(
                                              child: Container(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 8.0),
                                                  child: Text(
                                                    overlayThemeUpdatesData
                                                        .logoText,
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      color: AppColors.darkBlue,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 16,
                                                      letterSpacing: 0.12,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : SizedBox.shrink(),
                                // My Activities
                                FutureBuilder(
                                    future: getProfileFuture,
                                    builder: (BuildContext context,
                                        AsyncSnapshot<List<Profile>> snapshot) {
                                      var profileData =
                                          snapshot.hasData ? snapshot.data : [];
                                      return (profileData.isNotEmpty)
                                          ? Column(children: [
                                              Stack(
                                                children: [
                                                  FutureBuilder(
                                                      future:
                                                          getEnrolledCoursesFuture,
                                                      builder: (context,
                                                          AsyncSnapshot<dynamic>
                                                              snapshot) {
                                                        if (snapshot.hasData) {
                                                          var enrollmentInfo =
                                                              snapshot.data;
                                                          return FutureBuilder(
                                                              future:
                                                                  getUserInsightFuture,
                                                              builder: (context,
                                                                  AsyncSnapshot<
                                                                          dynamic>
                                                                      snapshot) {
                                                                if (snapshot
                                                                    .hasData) {
                                                                  if (snapshot.data
                                                                              .runtimeType ==
                                                                          String ||
                                                                      snapshot.data
                                                                              .runtimeType ==
                                                                          HandshakeException) {
                                                                    return Container(
                                                                      width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width,
                                                                      child: MyactivityCard(
                                                                          profileDetails: profileData[
                                                                              0],
                                                                          userCourseEnrolmentInfo:
                                                                              enrollmentInfo,
                                                                          weeklyClaps: {}),
                                                                    );
                                                                  }
                                                                  return Container(
                                                                    width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width,
                                                                    child:
                                                                        MyactivityCard(
                                                                      profileDetails:
                                                                          profileData[
                                                                              0],
                                                                      userCourseEnrolmentInfo:
                                                                          enrollmentInfo,
                                                                      weeklyClaps: snapshot.data !=
                                                                              null
                                                                          ? snapshot
                                                                              .data['weekly-claps']
                                                                          : {},
                                                                      leaderboardRank: (_leaderboardData !=
                                                                              null)
                                                                          ? '${_leaderboardData.rank ?? ''}'
                                                                          : '',
                                                                    ),
                                                                  );
                                                                } else {
                                                                  return Center();
                                                                }
                                                              });
                                                        } else {
                                                          return Center();
                                                        }
                                                      }),
                                                  // User nudge card on timely basis
                                                  ValueListenableBuilder(
                                                      valueListenable:
                                                          _isDisplayUserNudge,
                                                      builder: (BuildContext
                                                              context,
                                                          bool
                                                              isDisplayUserNudge,
                                                          Widget child) {
                                                        return Consumer<
                                                                LandingPageRepository>(
                                                            builder: (BuildContext
                                                                    context,
                                                                LandingPageRepository
                                                                    landingPageRepository,
                                                                Widget child) {
                                                          return landingPageRepository
                                                                      .userNudgeInfo !=
                                                                  null
                                                              ? AnimatedBuilder(
                                                                  animation:
                                                                      _animationController,
                                                                  builder:
                                                                      (context,
                                                                          child) {
                                                                    return Container(
                                                                        width: MediaQuery.of(context)
                                                                            .size
                                                                            .width,
                                                                        // color: Colors.transparent,
                                                                        child:
                                                                            AnimatedOpacity(
                                                                          duration:
                                                                              Duration(milliseconds: nudgeFadeInOutDuration),
                                                                          opacity: isDisplayUserNudge
                                                                              ? _opacityAnimation.value
                                                                              : _fadeOutAnimation.value,
                                                                          child:
                                                                              Visibility(
                                                                            visible:
                                                                                _opacityAnimation.value > 0,
                                                                            child:
                                                                                UserNudgeCard(
                                                                              profileDetails: profileData[0],
                                                                              isDisplayUserNudge: isDisplayUserNudge,
                                                                              landingPageRepository: landingPageRepository,
                                                                              opacityAnimation: _opacityAnimation,
                                                                              nudgeFadeInOutDuration: nudgeFadeInOutDuration,
                                                                            ),
                                                                          ),
                                                                        ));
                                                                  })
                                                              : Center();
                                                        });
                                                      }),

                                                  /// leader board celebration card
                                                  if ((_leaderboardData !=
                                                          null) &&
                                                      (!_isSameMonth(
                                                          Helper.formatDate(
                                                              DateTime.now()),
                                                          profileData[0]
                                                                  .lastMotivationalMessageTime ??
                                                              '')))
                                                    if (_leaderboardData
                                                            .previousRank >
                                                        _leaderboardData.rank)
                                                      ValueListenableBuilder(
                                                          valueListenable:
                                                              _isDisplayLeaderboardNudge,
                                                          builder: (BuildContext
                                                                  context,
                                                              bool
                                                                  isDisplayUserNudge,
                                                              Widget child) {
                                                            _leaderboardNudgeDisplayed();
                                                            return Container(
                                                                width: 1.sw,
                                                                child:
                                                                    DisplayWidgetWithDuration(
                                                                  duration:
                                                                      Duration(
                                                                          seconds:
                                                                              5),
                                                                  child:
                                                                      LeaderboardNudgeCard(
                                                                    leaderboardData:
                                                                        _leaderboardData,
                                                                  ),
                                                                ));
                                                          }),
                                                ],
                                              ),
                                              //CBP plan
                                              Consumer<LearnRepository>(
                                                builder: (context,
                                                    learnRepository, _) {
                                                  final cbpData =
                                                      learnRepository
                                                          .cbplanData;
                                                  final enrolledCourseList =
                                                      learnRepository
                                                          .enrolledCourseList;
                                                  if (cbpData != null) {
                                                    if (cbpData.runtimeType ==
                                                        String) {
                                                      return Center();
                                                    } else if (cbpData[
                                                                'content'] !=
                                                            null &&
                                                        cbpData['content']
                                                                .length >
                                                            0) {
                                                      CbPlanModel
                                                          cbpCourseData =
                                                          CbPlanModel.fromJson(
                                                              cbpData);
                                                      return CbpCoursePage(
                                                          cbpCourseData:
                                                              cbpCourseData,
                                                          enrolledCourseList:
                                                              enrolledCourseList
                                                                          .runtimeType ==
                                                                      String
                                                                  ? []
                                                                  : enrolledCourseList);
                                                    } else {
                                                      return Center();
                                                    }
                                                  } else {
                                                    return Container(
                                                      height: 300,
                                                      child: ListView.separated(
                                                        itemBuilder: (context,
                                                                index) =>
                                                            const CourseProgressSkeletonPage(),
                                                        separatorBuilder:
                                                            (context, index) =>
                                                                SizedBox(
                                                                    width: 8),
                                                        itemCount: 3,
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        shrinkWrap: true,
                                                      ),
                                                    );
                                                  }
                                                },
                                              ),
                                              // Mark Attendance
                                              UpcomingCourseSchedule(
                                                  batchAttributes:
                                                      batchAttributes,
                                                  orderedSessions:
                                                      orderedSessions,
                                                  callBack: () {
                                                    if (mounted) {
                                                      setState(() {});
                                                    }
                                                  }),

                                              // My Learning
                                              _profileDetails.isNotEmpty
                                                  ? Consumer<LearnRepository>(
                                                      builder: (context,
                                                          learnRepository, _) {
                                                      final enrolledCourseList =
                                                          learnRepository
                                                              .enrolledCourseList;
                                                      if (enrolledCourseList !=
                                                          null) {
                                                        return enrolledCourseList
                                                                    .runtimeType ==
                                                                String
                                                            ? Center()
                                                            : enrolledCourseList
                                                                        .length >
                                                                    0
                                                                ? HomeMylearningPage(
                                                                    courses:
                                                                        enrolledCourseList)
                                                                : Center();
                                                      } else {
                                                        return Container(
                                                          height: 300,
                                                          child: ListView
                                                              .separated(
                                                            itemBuilder: (context,
                                                                    index) =>
                                                                const CourseProgressSkeletonPage(),
                                                            separatorBuilder:
                                                                (context,
                                                                        index) =>
                                                                    SizedBox(
                                                                        width:
                                                                            8),
                                                            itemCount: 3,
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            shrinkWrap: true,
                                                          ),
                                                        );
                                                      }
                                                    })
                                                  : Center(),
                                            ])
                                          : Center();
                                    }),

                                // Learn Hub
                                Container(
                                  color: AppColors.appBarBackground,
                                  child: Container(
                                      margin: EdgeInsets.all(16),
                                      child: Column(
                                        children: [
                                          Container(
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                              AppLocalizations.of(context)
                                                  .mStaticLearnHub,
                                              style: GoogleFonts.montserrat(
                                                color: AppColors.greys87,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 20,
                                                letterSpacing: 0.12,
                                              ),
                                            ),
                                          ),

                                          // Recently added programs
                                          FutureBuilder(
                                              future: getProgramsRecentlyFuture,
                                              builder: (BuildContext context,
                                                  AsyncSnapshot<List<Course>>
                                                      courses) {
                                                return (courses.hasData &&
                                                        courses.data != null)
                                                    ? Column(
                                                        children: [
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                        .fromLTRB(
                                                                    0,
                                                                    32,
                                                                    0,
                                                                    15),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                  AppLocalizations.of(
                                                                          context)
                                                                      .mStaticRecentlyAddedPrograms,
                                                                  style:
                                                                      GoogleFonts
                                                                          .lato(
                                                                    color: AppColors
                                                                        .greys87,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    fontSize:
                                                                        16,
                                                                    letterSpacing:
                                                                        0.12,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 60,
                                                                  child: InkWell(
                                                                      onTap: () {
                                                                        _generateInteractTelemetryData(
                                                                            TelemetryIdentifier
                                                                                .showAll,
                                                                            subType:
                                                                                TelemetrySubType.recentlyAddedPrograms,
                                                                            isObjectNull: true);
                                                                        Navigator
                                                                            .push(
                                                                          context,
                                                                          FadeRoute(
                                                                              page: TrendingCoursesPage(title: AppLocalizations.of(context).mLearnRecentlyAdded)),
                                                                        );
                                                                      },
                                                                      child: Text(
                                                                        AppLocalizations.of(context)
                                                                            .mStaticShowAll,
                                                                        style: GoogleFonts
                                                                            .lato(
                                                                          color:
                                                                              AppColors.darkBlue,
                                                                          fontWeight:
                                                                              FontWeight.w400,
                                                                          fontSize:
                                                                              14,
                                                                          letterSpacing:
                                                                              0.12,
                                                                        ),
                                                                      )),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          courses.data.length >
                                                                  0
                                                              ? Container(
                                                                  height: 296,
                                                                  width: double
                                                                      .infinity,
                                                                  margin: const EdgeInsets
                                                                          .only(
                                                                      left: 6,
                                                                      top: 5,
                                                                      bottom:
                                                                          15),
                                                                  child: ListView
                                                                      .builder(
                                                                    scrollDirection:
                                                                        Axis.horizontal,
                                                                    itemCount: courses.data.length <
                                                                            10
                                                                        ? courses
                                                                            .data
                                                                            .length
                                                                        : 10,
                                                                    itemBuilder:
                                                                        (context,
                                                                            index) {
                                                                      return InkWell(
                                                                          onTap:
                                                                              () async {
                                                                            _generateInteractTelemetryData(courses.data[index].id,
                                                                                primaryCategory: courses.data[index].contentType,
                                                                                subType: TelemetrySubType.recentlyAddedPrograms,
                                                                                clickId: TelemetryIdentifier.cardContent);
                                                                            Navigator.pushNamed(context,
                                                                                AppUrl.courseTocPage,
                                                                                arguments: CourseTocModel.fromJson({
                                                                                  'courseId': courses.data[index].id
                                                                                }));
                                                                          },
                                                                          child:
                                                                              CourseCard(course: courses.data[index]));
                                                                    },
                                                                  ))
                                                              : Center(
                                                                  child:
                                                                      PageLoader(),
                                                                ),
                                                        ],
                                                      )
                                                    : Center();
                                              }),
                                          // Recently added courses
                                          FutureBuilder(
                                              future: getCourseRecentlyFuture,
                                              builder: (BuildContext context,
                                                  AsyncSnapshot<List<Course>>
                                                      courses) {
                                                return (courses.hasData &&
                                                        courses.data != null)
                                                    ? Column(
                                                        children: [
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                        .fromLTRB(
                                                                    0,
                                                                    32,
                                                                    0,
                                                                    15),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                  AppLocalizations.of(
                                                                          context)
                                                                      .mStaticRecentlyAddedCourses,
                                                                  style:
                                                                      GoogleFonts
                                                                          .lato(
                                                                    color: AppColors
                                                                        .greys87,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    fontSize:
                                                                        16,
                                                                    letterSpacing:
                                                                        0.12,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 60,
                                                                  child: InkWell(
                                                                      onTap: () {
                                                                        _generateInteractTelemetryData(
                                                                            TelemetryIdentifier
                                                                                .showAll,
                                                                            subType:
                                                                                TelemetrySubType.recentlyAddedCourses,
                                                                            isObjectNull: true);
                                                                        Navigator
                                                                            .push(
                                                                          context,
                                                                          FadeRoute(
                                                                              page: TrendingCoursesPage(title: AppLocalizations.of(context).mLearnRecentlyAdded)),
                                                                        );
                                                                      },
                                                                      child: Text(
                                                                        AppLocalizations.of(context)
                                                                            .mStaticShowAll,
                                                                        style: GoogleFonts
                                                                            .lato(
                                                                          color:
                                                                              AppColors.darkBlue,
                                                                          fontWeight:
                                                                              FontWeight.w400,
                                                                          fontSize:
                                                                              14,
                                                                          letterSpacing:
                                                                              0.12,
                                                                        ),
                                                                      )),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          courses.data.length >
                                                                  0
                                                              ? Container(
                                                                  height: 296,
                                                                  width: double
                                                                      .infinity,
                                                                  margin: const EdgeInsets
                                                                          .only(
                                                                      left: 6,
                                                                      top: 5,
                                                                      bottom:
                                                                          15),
                                                                  child: ListView
                                                                      .builder(
                                                                    scrollDirection:
                                                                        Axis.horizontal,
                                                                    itemCount: courses.data.length <
                                                                            10
                                                                        ? courses
                                                                            .data
                                                                            .length
                                                                        : 10,
                                                                    itemBuilder:
                                                                        (context,
                                                                            index) {
                                                                      return InkWell(
                                                                          onTap:
                                                                              () async {
                                                                            _generateInteractTelemetryData(courses.data[index].id,
                                                                                primaryCategory: courses.data[index].contentType,
                                                                                subType: TelemetrySubType.recentlyAddedCourses,
                                                                                clickId: TelemetryIdentifier.cardContent);
                                                                            Navigator.pushNamed(context,
                                                                                AppUrl.courseTocPage,
                                                                                arguments: CourseTocModel.fromJson({
                                                                                  'courseId': courses.data[index].id
                                                                                }));
                                                                          },
                                                                          child:
                                                                              CourseCard(course: courses.data[index]));
                                                                    },
                                                                  ))
                                                              : Center(
                                                                  child:
                                                                      PageLoader(),
                                                                ),
                                                        ],
                                                      )
                                                    : Center();
                                              }),

                                          //Trending Course in your department
                                          Consumer<LearnRepository>(
                                            builder:
                                                (context, learnRepository, _) {
                                              final trendingCourseDeptList =
                                                  learnRepository
                                                      .trendingCourseDeptList;

                                              return courseWidget(
                                                  courseList:
                                                      trendingCourseDeptList,
                                                  title: AppLocalizations.of(
                                                          context)
                                                      .mStaticTrendingCoursesInYourDepartment,
                                                  telemetrySubType: TelemetrySubType
                                                      .trendingCoursesInYourDepartment);
                                            },
                                          ),

                                          //Trending Programs in your department
                                          Consumer<LearnRepository>(
                                            builder:
                                                (context, learnRepository, _) {
                                              final trendingProgramDeptList =
                                                  learnRepository
                                                      .trendingProgramDeptList;

                                              return courseWidget(
                                                  courseList:
                                                      trendingProgramDeptList,
                                                  title: AppLocalizations.of(
                                                          context)
                                                      .mStaticTrendingProgramsInYourDepartment,
                                                  telemetrySubType: TelemetrySubType
                                                      .trendingProgramsInYourDepartment);
                                            },
                                          ),

                                          //Trending Courses across department
                                          Consumer<LearnRepository>(
                                            builder:
                                                (context, learnRepository, _) {
                                              final trendingCourseList =
                                                  learnRepository
                                                      .trendingCourseList;

                                              return courseWidget(
                                                  courseList:
                                                      trendingCourseList,
                                                  title: AppLocalizations.of(
                                                          context)
                                                      .mStaticTrendingAcrossDepartment,
                                                  telemetrySubType: TelemetrySubType
                                                      .trendingCoursesAcrossDepartments);
                                            },
                                          ),

                                          //Trending Programs across department
                                          Consumer<LearnRepository>(
                                            builder:
                                                (context, learnRepository, _) {
                                              final trendingProgramList =
                                                  learnRepository
                                                      .trendingProgramList;

                                              return courseWidget(
                                                  courseList:
                                                      trendingProgramList,
                                                  title: AppLocalizations.of(
                                                          context)
                                                      .mStaticTrendingProgramsAcrossDepartment,
                                                  telemetrySubType: TelemetrySubType
                                                      .trendingProgramsAcrossDepartments);
                                            },
                                          ),

                                          // Learning under 30 minutes
                                          Consumer<LearnRepository>(
                                            builder:
                                                (context, learnRepository, _) {
                                              final shortDurationCourseList =
                                                  learnRepository
                                                      .shortDurationCourseList;

                                              return courseWidget(
                                                  courseList:
                                                      shortDurationCourseList,
                                                  title: AppLocalizations.of(
                                                          context)
                                                      .mStaticLearningUnder30Minutes,
                                                  telemetrySubType:
                                                      TelemetrySubType
                                                          .learningUnder30Minutes);
                                            },
                                          ),
                                          // Blended program
                                          FutureBuilder(
                                              future:
                                                  Provider.of<LearnRepository>(
                                                          context,
                                                          listen: false)
                                                      .getCourses(1, '', [
                                                EnglishLang.blendedProgram
                                                    .toLowerCase()
                                              ], [], []),
                                              builder: (BuildContext context,
                                                  AsyncSnapshot<List<Course>>
                                                      courses) {
                                                List<Course> blendedCourse = [];
                                                if (courses.hasData &&
                                                    (courses.data != null &&
                                                        courses.data.length >
                                                            0)) {
                                                  for (int index = 0;
                                                      index <
                                                          courses.data.length;
                                                      index++) {
                                                    if (!checkAllBatchEndDateOver(
                                                        courses
                                                            .data[index].raw)) {
                                                      blendedCourse.add(
                                                          courses.data[index]);
                                                    }
                                                  }
                                                  return (blendedCourse !=
                                                              null &&
                                                          blendedCourse.length >
                                                              0)
                                                      ? Column(
                                                          children: [
                                                            Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .fromLTRB(
                                                                      0,
                                                                      16,
                                                                      0,
                                                                      15),
                                                              child: Row(
                                                                children: [
                                                                  TitleSemiboldSize16(
                                                                    Helper.capitalize(AppLocalizations.of(
                                                                            context)
                                                                        .mCommonBlendedProgram
                                                                        .toLowerCase()),
                                                                  ),
                                                                  Spacer(),
                                                                  blendedCourse
                                                                              .length >
                                                                          SHOW_ALL_DISPLAY_COUNT
                                                                      ? SizedBox(
                                                                          width:
                                                                              60,
                                                                          child: InkWell(
                                                                              onTap: () {
                                                                                _generateInteractTelemetryData(TelemetryIdentifier.showAll, subType: TelemetrySubType.blendedProgram, isObjectNull: true);
                                                                                Navigator.push(
                                                                                  context,
                                                                                  FadeRoute(
                                                                                      page: TrendingCoursesPage(
                                                                                    selectedContentType: EnglishLang.blendedProgram,
                                                                                    isBlendedProgram: true,
                                                                                    title: AppLocalizations.of(context).mCommonBlendedProgram,
                                                                                  )),
                                                                                );
                                                                              },
                                                                              child: Text(
                                                                                AppLocalizations.of(context).mStaticShowAll,
                                                                                style: GoogleFonts.lato(
                                                                                  color: AppColors.darkBlue,
                                                                                  fontWeight: FontWeight.w400,
                                                                                  fontSize: 14,
                                                                                  letterSpacing: 0.12,
                                                                                ),
                                                                              )),
                                                                        )
                                                                      : Center()
                                                                ],
                                                              ),
                                                            ),
                                                            blendedCourse
                                                                        .length >
                                                                    0
                                                                ? Container(
                                                                    height: 296,
                                                                    width: double
                                                                        .infinity,
                                                                    margin: const EdgeInsets
                                                                            .only(
                                                                        left: 0,
                                                                        top: 5,
                                                                        bottom:
                                                                            15),
                                                                    child: ListView
                                                                        .builder(
                                                                      scrollDirection:
                                                                          Axis.horizontal,
                                                                      itemCount: blendedCourse.length <
                                                                              SHOW_ALL_CHECK_COUNT
                                                                          ? blendedCourse
                                                                              .length
                                                                          : SHOW_ALL_CHECK_COUNT,
                                                                      itemBuilder:
                                                                          (context,
                                                                              index) {
                                                                        if (blendedCourse.length >
                                                                                SHOW_ALL_CHECK_COUNT &&
                                                                            index ==
                                                                                SHOW_ALL_CHECK_COUNT - 1) {
                                                                          return Row(
                                                                            children: [
                                                                              InkWell(
                                                                                  onTap: () async {
                                                                                    _generateInteractTelemetryData(blendedCourse[index].id, subType: TelemetrySubType.blendedProgram, primaryCategory: PrimaryCategory.blendedProgram, clickId: TelemetryIdentifier.cardContent);
                                                                                    Navigator.pushNamed(context, AppUrl.courseTocPage,
                                                                                        arguments: CourseTocModel.fromJson({
                                                                                          'courseId': blendedCourse[index].id,
                                                                                          'isBlendedProgram': true,
                                                                                        }));
                                                                                  },
                                                                                  child: CourseCard(course: blendedCourse[index])),
                                                                              InkWell(
                                                                                  onTap: () {
                                                                                    Navigator.push(
                                                                                      context,
                                                                                      FadeRoute(page: TrendingCoursesPage(selectedContentType: EnglishLang.blendedProgram, isBlendedProgram: true, title: EnglishLang.blendedProgram)),
                                                                                    );
                                                                                  },
                                                                                  child: Container(
                                                                                    height: COURSE_CARD_HEIGHT,
                                                                                    width: COURSE_CARD_WIDTH,
                                                                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.darkBlue)),
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
                                                                                _generateInteractTelemetryData(blendedCourse[index].id, subType: TelemetrySubType.blendedProgram, primaryCategory: PrimaryCategory.blendedProgram, clickId: TelemetryIdentifier.cardContent);
                                                                                Navigator.pushNamed(context, AppUrl.courseTocPage,
                                                                                    arguments: CourseTocModel.fromJson({
                                                                                      'courseId': blendedCourse[index].id,
                                                                                      'isBlendedProgram': true,
                                                                                    }));
                                                                              },
                                                                              child: CourseCard(course: blendedCourse[index]));
                                                                        }
                                                                      },
                                                                    ))
                                                                : Center(),
                                                          ],
                                                        )
                                                      : Center();
                                                } else if (courses.hasData &&
                                                    (courses.data != null &&
                                                        courses.data.length <=
                                                            0)) {
                                                  return Center();
                                                } else {
                                                  return CourseCardSkeletonPage();
                                                }
                                              }),

                                          // Certificate of the week
                                          Consumer<LearnRepository>(builder:
                                              (context, learnRepository, _) {
                                            final certificateOfWeekList =
                                                learnRepository
                                                    .certificateOfWeekList;
                                            return CertificateOfWeek(
                                                certificateOfWeekList:
                                                    certificateOfWeekList,
                                                enrolmentList:
                                                    enrolmentCourseList);
                                          })
                                        ],
                                      )),
                                ),

                                // Banner Carousel
                                BannerViewWidget(),

                                // Discuss Hub
                                Container(
                                  color: AppColors.whiteGradientOne,
                                  child: Container(
                                      margin: EdgeInsets.all(16),
                                      child: Column(children: [
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  AppLocalizations.of(context)
                                                      .mStaticDiscussHub,
                                                  style: GoogleFonts.montserrat(
                                                    color: AppColors.greys87,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 20,
                                                    letterSpacing: 0.12,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.46,
                                                child: ElevatedButton(
                                                  onPressed: () =>
                                                      Navigator.push(
                                                    context,
                                                    FadeRoute(
                                                        page:
                                                            NewDiscussionPage()),
                                                  ),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                          backgroundColor: AppColors
                                                              .appBarBackground,
                                                          elevation: 0,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        16.0),
                                                            side: BorderSide(
                                                                color: AppColors
                                                                    .darkBlue),
                                                          )),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          AppLocalizations.of(
                                                                  context)
                                                              .mStaticPostDiscussion,
                                                          maxLines: 2,
                                                          style: GoogleFonts.lato(
                                                              color: AppColors
                                                                  .darkBlue,
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700),
                                                        ),
                                                      ),
                                                      SizedBox(width: 6),
                                                      SizedBox(
                                                        width: 16,
                                                        child: Icon(
                                                          Icons.add,
                                                          color: AppColors
                                                              .darkBlue,
                                                          size: 16,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ]),
                                        FutureBuilder(
                                            future: getLatestDiscussionFuture,
                                            builder: (context,
                                                AsyncSnapshot<dynamic>
                                                    snapshot) {
                                              if (snapshot.hasData) {
                                                if (snapshot.data != null) {
                                                  if (snapshot
                                                          .data.runtimeType ==
                                                      String) {
                                                    return Center();
                                                  }
                                                  Discuss latestDiscussion =
                                                      snapshot.data;
                                                  return Column(
                                                    children: [
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                    .fromLTRB(
                                                                0, 24, 0, 15),
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              AppLocalizations.of(
                                                                      context)
                                                                  .mHomeDiscussUpdateOnPost,
                                                              style: GoogleFonts
                                                                  .montserrat(
                                                                color: AppColors
                                                                    .greys87,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 16,
                                                                letterSpacing:
                                                                    0.12,
                                                              ),
                                                            ),
                                                            Spacer(),
                                                            SizedBox(
                                                              width: 60,
                                                              child: InkWell(
                                                                  onTap: () {
                                                                    _generateInteractTelemetryData(
                                                                        TelemetryIdentifier
                                                                            .showAll,
                                                                        subType:
                                                                            TelemetrySubType
                                                                                .myDiscussions,
                                                                        isObjectNull:
                                                                            true);
                                                                    Navigator
                                                                        .push(
                                                                      context,
                                                                      FadeRoute(
                                                                          page:
                                                                              DiscussionHub(
                                                                        title: AppLocalizations.of(context)
                                                                            .mStaticYourDiscussions,
                                                                      )),
                                                                    );
                                                                  },
                                                                  child: Text(
                                                                    AppLocalizations.of(
                                                                            context)
                                                                        .mStaticShowAll,
                                                                    style:
                                                                        GoogleFonts
                                                                            .lato(
                                                                      color: AppColors
                                                                          .darkBlue,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      fontSize:
                                                                          14,
                                                                      letterSpacing:
                                                                          0.12,
                                                                    ),
                                                                  )),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      UpdatesOnDiscussionCard(
                                                          latestDiscussion:
                                                              latestDiscussion),
                                                    ],
                                                  );
                                                } else
                                                  return Center();
                                              } else {
                                                return const DiscussSkeleton();
                                              }
                                            }),
                                        trendingDiscussionList.length > 0
                                            ? Column(children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          0, 24, 0, 15),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        AppLocalizations.of(
                                                                context)
                                                            .mStaticTrendingDiscussion,
                                                        style: GoogleFonts
                                                            .montserrat(
                                                          color:
                                                              AppColors.greys87,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 16,
                                                          letterSpacing: 0.12,
                                                        ),
                                                      ),
                                                      Spacer(),
                                                      SizedBox(
                                                        width: 60,
                                                        child: InkWell(
                                                            onTap: () {
                                                              _generateInteractTelemetryData(
                                                                  TelemetryIdentifier
                                                                      .showAll,
                                                                  subType:
                                                                      TelemetrySubType
                                                                          .trendingDiscussions,
                                                                  isObjectNull:
                                                                      true);
                                                              Navigator.pushNamed(
                                                                  context,
                                                                  AppUrl
                                                                      .discussionHub);
                                                            },
                                                            child: Text(
                                                              AppLocalizations.of(
                                                                      context)
                                                                  .mStaticShowAll,
                                                              style: GoogleFonts
                                                                  .lato(
                                                                color: AppColors
                                                                    .darkBlue,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize: 14,
                                                                letterSpacing:
                                                                    0.12,
                                                              ),
                                                            )),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          0, 16, 0, 16),
                                                  child: SizedBox(
                                                    height: DISCUSS_CARD_HEIGHT,
                                                    width: double.infinity,
                                                    child: ListView.builder(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      cacheExtent: MediaQuery
                                                                  .of(context)
                                                              .size
                                                              .width *
                                                          0.9 *
                                                          DISCUSS_CARD_DISPLAY_LIMIT, // Not to dispose children when there is no visibility on listview
                                                      itemCount:
                                                          trendingDiscussionList
                                                              .length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return InkWell(
                                                            onTap: () => _navigateToDiscussionDetail(
                                                                trendingDiscussionList[
                                                                        index]
                                                                    .tid,
                                                                trendingDiscussionList[
                                                                            index]
                                                                        .user[
                                                                    'fullname'],
                                                                trendingDiscussionList[
                                                                        index]
                                                                    .title,
                                                                trendingDiscussionList[
                                                                            index]
                                                                        .user[
                                                                    'uid']),
                                                            child: TrendingDiscussCard(
                                                                data:
                                                                    trendingDiscussionList[
                                                                        index],
                                                                isProfile:
                                                                    false));
                                                      },
                                                    ),
                                                  ),
                                                )
                                              ])
                                            : Center(),
                                      ])),
                                ),
                                // Network Hub
                                _suggestions != null && _suggestions.length > 0
                                    ? Column(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.fromLTRB(
                                                16, 48, 16, 15),
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                              AppLocalizations.of(context)
                                                  .mNetworkHub,
                                              style: GoogleFonts.montserrat(
                                                color: AppColors.greys87,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 20,
                                                letterSpacing: 0.12,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.fromLTRB(
                                                16, 24, 16, 15),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                SizedBox(
                                                  width: 160,
                                                  child: Text(
                                                    AppLocalizations.of(context)
                                                        .mHomeSuggestedForYou,
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      color: AppColors.greys87,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 16,
                                                      letterSpacing: 0.12,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 60,
                                                  child: InkWell(
                                                      onTap: () {
                                                        _generateInteractTelemetryData(
                                                            TelemetryIdentifier
                                                                .showAll,
                                                            subType:
                                                                TelemetrySubType
                                                                    .suggestedConnections,
                                                            isObjectNull: true);
                                                        Navigator.push(
                                                          context,
                                                          FadeRoute(
                                                              page: NetworkHub(
                                                            title: AppLocalizations
                                                                    .of(context)
                                                                .mStaticRecommended,
                                                          )),
                                                        );
                                                      },
                                                      child: Text(
                                                        AppLocalizations.of(
                                                                context)
                                                            .mStaticShowAll,
                                                        style: GoogleFonts.lato(
                                                          color: AppColors
                                                              .darkBlue,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 14,
                                                          letterSpacing: 0.12,
                                                        ),
                                                      )),
                                                )
                                              ],
                                            ),
                                          ),
                                          Container(
                                              height: 258,
                                              width: double.infinity,
                                              padding: const EdgeInsets.only(
                                                top: 5,
                                                bottom: 10,
                                                left: 9,
                                                right: 9,
                                              ),
                                              child: ListView.builder(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemCount:
                                                      _suggestions.length > 5
                                                          ? 5
                                                          : _suggestions.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return PeopleNetworkItem(
                                                        suggestion:
                                                            _suggestions[index],
                                                        parentAction1:
                                                            _createConnectionRequest,
                                                        parentAction2:
                                                            _generateInteractTelemetryData,
                                                        requestedConnections:
                                                            _requestedConnections);
                                                  })),
                                          connectionRequests > 0
                                              ? GestureDetector(
                                                  onTap: () => Navigator.push(
                                                    context,
                                                    FadeRoute(
                                                        page: NetworkHub(
                                                      title:
                                                          AppLocalizations.of(
                                                                  context)
                                                              .mStaticRequests,
                                                    )),
                                                  ),
                                                  child: Container(
                                                    margin: EdgeInsets.only(
                                                        left: 16,
                                                        right: 16,
                                                        bottom: 50),
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            31, 16, 17, 16),
                                                    height: 80,
                                                    width: double.infinity,
                                                    decoration: BoxDecoration(
                                                        border: Border(
                                                          left: BorderSide(
                                                            color: AppColors
                                                                .orangeBackground,
                                                            width: 4.0,
                                                          ),
                                                        ),
                                                        color: AppColors
                                                            .orangeShadow),
                                                    child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              SvgPicture.asset(
                                                                'assets/img/network_people_icon.svg',
                                                                width: 48.0,
                                                                height: 48.0,
                                                              ),
                                                              SizedBox(
                                                                  width: 16),
                                                              Container(
                                                                height: 48,
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.5,
                                                                child: Text(
                                                                    connectionRequests
                                                                            .toString() +
                                                                        ' ' +
                                                                        AppLocalizations.of(context)
                                                                            .mStaticConnectionsRequestsWaiting,
                                                                    maxLines: 2,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style: GoogleFonts.lato(
                                                                        color: AppColors
                                                                            .greys87,
                                                                        fontSize:
                                                                            16.0,
                                                                        letterSpacing:
                                                                            0.12,
                                                                        fontWeight:
                                                                            FontWeight.w700)),
                                                              )
                                                            ],
                                                          ),
                                                          SvgPicture.asset(
                                                            'assets/img/swipe_right.svg',
                                                            width: 24.0,
                                                            height: 24.0,
                                                          ),
                                                        ]),
                                                  ),
                                                )
                                              : Center(),
                                        ],
                                      )
                                    : Center(),

                                // Top providers
                                Consumer<LearnRepository>(
                                    builder: (context, learnRepository, _) {
                                  final topProviderList =
                                      learnRepository.topProvidersConfig;
                                  return topProviderList == null
                                      ? const CourseCardSkeletonPage()
                                      : topProviderList.runtimeType == String
                                          ? Center()
                                          : topProviderList.isEmpty
                                              ? Center()
                                              : TopProviders(
                                                  topProviderList:
                                                      getTopProviderModel(
                                                          topProviderList));
                                }),
                                // Follow Us
                                FollowUsOnSocialMedia(),
                                SizedBox(
                                  height: 120,
                                )
                              ],
                            ),
                          ),
                        ));
                  } else {
                    return const HomeSkeletonPage();
                  }
                })
            : Center());
  }

  Future<void> _readContentProgress(batchId, courseId) async {
    var response = await learnService.readContentProgress(courseId, batchId);
    if (response['result']['contentList'] != null) {
      var contentProgressList = response['result']['contentList'];
      if (contentProgressList != null) {
        for (int i = 0; i < contentProgressList.length; i++) {
          if (contentProgressList[i]['progress'] == 100 &&
              contentProgressList[i]['status'] == 2) {
            batchAttributes
                .forEach((batch) => batch.forEach((id, batchAttr) async {
                      batchAttr.sessionDetailsV2.forEach((sessionMap) async {
                        if (sessionMap.sessionId ==
                            contentProgressList[i]['contentId']) {
                          setState(() {
                            sessionMap.sessionAttendanceStatus = true;
                          });
                        }
                      });
                    }));
          }
        }
      }
    }
  }

  Future<void> _getUpcomingSchedules() async {
    final dynamic data =
        await Provider.of<LearnRepository>(context, listen: false)
            .getUpcomingSchedules();
    try {
      List courses = data['result']['courses'];
      orderedSessions = [];
      courses.forEach((course) {
        if (course['batch']['batchAttributes'] != null) {
          if (course['batch']['batchAttributes']["sessionDetails_v2"] != null) {
            Map<String, BatchAttributes> batchAttr = {
              course['batch']['identifier'].toString():
                  BatchAttributes.fromJson(course['batch']['batchAttributes'])
            };
            courseId = course['courseId'];
            List sessionList =
                course['batch']['batchAttributes']["sessionDetails_v2"];
            List tempSessionList = sessionList;
            tempSessionList.forEach((tempSession) {
              bool isUpcoming = _isSessionLive(tempSession);
              if (!isUpcoming) {
                batchAttr.values.forEach((batch) {
                  batch.sessionDetailsV2.removeWhere((session) =>
                      session.sessionId == tempSession['sessionId']);
                });
              }
            });

            batchAttr.forEach((id, batchAttribute) {
              if (batchAttribute.sessionDetailsV2.isNotEmpty) {
                // Adding sorted sessions to orderedSessions to display in ascending order
                batchAttribute.sessionDetailsV2.forEach((session) {
                  DateTime sessionDate = DateTime.parse(session.startDate);
                  TimeOfDay startTime =
                      _getTimeIn24HourFormat(session.startTime);
                  DateTime sessionStartDateTime = DateTime(
                      sessionDate.year,
                      sessionDate.month,
                      sessionDate.day,
                      startTime.hour,
                      startTime.minute);
                  orderedSessions.add({
                    'sessionId': session.sessionId,
                    'startDateTime': sessionStartDateTime
                  });
                });
                batchAttributes.add(batchAttr);
              }
            });

            batchAttributes
                .forEach((batch) => batch.forEach((id, batchAttr) async {
                      batchId = id;
                      if (course['batchId'] == id) {
                        batchAttr.courseId = course['courseId'];
                      }
                      batchAttr.sessionDetailsV2.forEach((sessionMap) async {
                        await _readContentProgress(id, courseId);
                      });
                    }));
          }
        }
      });
      if (orderedSessions.isNotEmpty) {
        orderedSessions
            .sort((a, b) => a['startDateTime'].compareTo(b['startDateTime']));
      }
      setState(() {});
    } catch (e) {
      debugPrint(e);
    }
  }

  // int boolToInt(bool a) => a ? 1 : 0;

  TimeOfDay _getTimeIn24HourFormat(String timeIn12HourFormat) {
    List timeSplits = timeIn12HourFormat.split(':'); // eg. 12:30 PM
    String hourString = timeSplits.first;
    String minString = timeSplits.last.split(' ').first;
    int min = int.parse(minString);
    int hour = int.parse(hourString);
    hour =
        (hour != 12 && timeSplits.last.toString().toLowerCase().contains('pm'))
            ? hour + 12
            : hour;

    return TimeOfDay(hour: hour, minute: min);
  }

  bool _isSessionLive(session) {
    try {
      DateTime sessionDate = DateTime.parse(session['startDate']);
      TimeOfDay startTime = _getTimeIn24HourFormat(session['startTime']);
      DateTime sessionStartEndTime = DateTime(
          sessionDate.year,
          sessionDate.month,
          sessionDate.day,
          startTime.hour +
              (int.parse((session['sessionDuration']).split('hr')[0])) +
              AttendenceMarking.bufferHour,
          startTime.minute);
      final bool isUpcoming = (DateTime.now().isBefore(sessionStartEndTime));
      return isUpcoming;
    } catch (e) {
      return false;
    }
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

  Widget courseWidget(
      {dynamic courseList,
      String title,
      bool showShowAll,
      String telemetrySubType}) {
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
                    enrolmentList: enrolmentCourseList != null &&
                            enrolmentCourseList.isNotEmpty
                        ? enrolmentCourseList
                        : [],
                    telemetrySubType: telemetrySubType,
                  );
  }

  List<TopProviderModel> getTopProviderModel(List<dynamic> topProviderList) {
    return topProviderList
        .map((item) => TopProviderModel.fromJson(item))
        .toList();
  }

  Future<int> _getProfileCompleted() async {
    return await FlutterSecureStorage()
        .read(key: Storage.profileCompletionPercentage)
        .then((value) => int.parse(value));
  }

  Future<void> _leaderboardNudgeDisplayed() async {
    try {
      await profileService
          .updateLeaderboardNudgeData(Helper.formatDate(DateTime.now()));
    } catch (e) {}
  }

  bool _isSameMonth(String currentUpdate, String lastUpdate) {
    if (lastUpdate == '') return false;

    String _lastFormattedDate =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(lastUpdate));
    DateFormat format = DateFormat('yyyy-MM-dd HH:mm:ss');
    DateTime _currentDate = format.parse(currentUpdate);
    DateTime _lastDate = format.parse(_lastFormattedDate);

    if (_currentDate.year != _lastDate.year) {
      return false;
    }
    if (_currentDate.month != _lastDate.month) {
      return false;
    }
    return true;
  }

  TextSpan textWidget(String message, FontWeight font) {
    return TextSpan(
      text: message,
      style: TextStyle(
          color: AppColors.greys87,
          fontSize: 12,
          fontWeight: font,
          letterSpacing: 0.25),
    );
  }

  Widget courseFirstEnrolPopup() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 8, 0, 8),
      width: MediaQuery.of(context).size.width,
      color: AppColors.grey16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.75,
            child: RichText(
              text: TextSpan(
                children: [
                  textWidget(AppLocalizations.of(context).mStaticEarn + ' ',
                      FontWeight.w400),
                  textWidget(
                      '$FIRST_ENROLMENT_POINT ' +
                          AppLocalizations.of(context).mStaticKarmaPoints +
                          ' ',
                      FontWeight.w900),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: SvgPicture.asset(
                      'assets/img/kp_icon.svg',
                      width: 24,
                      height: 24,
                    ),
                  ),
                  textWidget(
                      ' ' +
                          AppLocalizations.of(context)
                              .mStaticFirstCourseEnrolment,
                      FontWeight.w400)
                ],
              ),
            ),
          ),
          IconButton(
              onPressed: () {
                setState(() {
                  _storage.write(
                      key: Storage.showKarmaPointFirstCourseEnrolPopup,
                      value: 'false');
                  enableEnrolPopupOnLaunch = false;
                });
              },
              icon: Icon(
                Icons.close,
                size: 24,
                color: AppColors.greys60,
              ))
        ],
      ),
    );
  }

  Future<void> userEnrolledToAnyCourse() async {
    String status =
        await _storage.read(key: Storage.showKarmaPointFirstCourseEnrolPopup);
    if (status.toLowerCase() == 'false') {
      enableEnrolPopupOnLaunch = false;
    } else {
      enableEnrolPopupOnLaunch = true;
    }
  }

  bool courseEnrolmentStatus(Map<dynamic, dynamic> enrolList) {
    if (enrolList['courses'] == null) {
      return false;
    } else if (enrolList['courses'].isEmpty) {
      return false;
    } else {
      bool isEnrolled = false;
      enrolList['courses'].forEach((course) {
        if (course['content']['primaryCategory'].toString().toLowerCase() ==
            'course') {
          isEnrolled = true;
        }
      });
      return isEnrolled;
    }
  }

  dynamic checkCourseEnrolled(String id) {
    if (enrolmentCourseList == null && enrolmentCourseList.isEmpty) {
      return null;
    } else {
      return enrolmentCourseList.firstWhere(
        (element) => element.raw['courseId'] == id,
        orElse: () => null,
      );
    }
  }
}
