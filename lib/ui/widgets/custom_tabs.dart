import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:animations/animations.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gyaan_karmayogi_resource_list/utils/app_colors.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/storage_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/models/_models/deeplink_model.dart';
import 'package:karmayogi_mobile/models/_models/profile_model.dart';
import 'package:karmayogi_mobile/models/_models/telemetry_event_model.dart';
import 'package:karmayogi_mobile/respositories/_respositories/chatbot_repository.dart';
import 'package:karmayogi_mobile/respositories/_respositories/in_app_review_repository.dart';
import 'package:karmayogi_mobile/respositories/_respositories/landing_page_repository.dart';
import 'package:karmayogi_mobile/respositories/_respositories/learn_repository.dart';
import 'package:karmayogi_mobile/respositories/_respositories/notification_repository.dart';
import 'package:karmayogi_mobile/respositories/_respositories/profile_repository.dart';
import 'package:karmayogi_mobile/services/_services/vega_service.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/ai_assistant_page.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/my_learnings/my_learning_page.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/text_search_results/text_search_page.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/_getStart/intro_get_start.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/home_screen.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/hub_screen.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/notifications_screen.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile_screen.dart';
import 'package:karmayogi_mobile/ui/widgets/chatbotbtn.dart';
import 'package:karmayogi_mobile/ui/widgets/custom_bottom_navigation.dart';
import 'package:karmayogi_mobile/ui/widgets/custom_drawer.dart';
import 'package:karmayogi_mobile/ui/widgets/title_regular_grey60.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:karmayogi_mobile/util/survey.dart';
import 'package:karmayogi_mobile/util/telemetry.dart';
import 'package:karmayogi_mobile/util/telemetry_db_helper.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:upgrader/upgrader.dart';

class CustomTabs extends StatefulWidget {
  final int customIndex;
  final String token;
  final bool isFromSignIn;
  final int tabIndex;

  CustomTabs(
      {Key key,
      this.customIndex = 0,
      this.token,
      this.isFromSignIn = false,
      this.tabIndex = 0})
      : super(key: key);

  @override
  _CustomTabsState createState() => _CustomTabsState();

  static void setTabItem(BuildContext context, int index) {
    _CustomTabsState state =
        context.findAncestorStateOfType<_CustomTabsState>();
    state?.setTabItems(index);
  }
}

GlobalKey<ScaffoldState> drawerKey = GlobalKey();

class _CustomTabsState extends State<CustomTabs> with TickerProviderStateMixin {
  StreamSubscription _connectivitySubscription;
  final VegaService vegaService = VegaService();
  final _storage = FlutterSecureStorage();
  Future<void> _getProfileDetailsFuture;
  bool _isDeviceConnected = false;
  bool _isSetAlert = false;
  int _currentIndex;
  int _unSeenNotificationsCount = 0;
  TabController _controller;
  bool _pageInitialized = false;
  bool get notProdRelease => !Helper.itsProdRelease;
  List<Profile> _profileDetails;
  bool _showGetStarted = false;
  // SpeechRecognizer _speechRecognizer;
  String userId;
  String userSessionId;
  String messageIdentifier;
  String departmentId;
  String deviceIdentifier;
  var telemetryEventData;

  @override
  void initState() {
    super.initState();
    // Provider.of<LoginRespository>(context, listen: false).clearData();
    // _doActionOnNotification();
    //to trigger platform rating on 4th click setting platform rating to default(zero)
    _performDeeplinking();
    setDefaultStorageValues();
    getEnrolledCourse();
    _getConnectivity();
    _getUnSeenNotificationsCount();
    _getFaqData();
    _getGetStartedStatus();
    _setAppOpenStatus();
    _getProfileDetailsFuture = _getProfileDetails();
  }

  _performDeeplinking() async {
    // storage_const.Storage.deepLinkPayload
    final String deepLinkData =
        await _storage.read(key: Storage.deepLinkPayload);
    if (deepLinkData != null) {
      DeepLink deepLink = DeepLink.fromJson(jsonDecode(deepLinkData));
      if (deepLink.url != null && deepLink.url.isNotEmpty) {
        Future.delayed(Duration.zero, () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (ctx) => Survey(
              surveyUrl: deepLink.url.toString(),
              parentContext: context,
            ),
          ));
        });
      }
    }
  }

  void setDefaultStorageValues() {
    _storage.write(key: Storage.enableRating, value: '0');
    _storage.write(
        key: Storage.showKarmaPointFirstCourseEnrolPopup, value: 'true');
  }

  setTabItems(int index) {
    _controller = TabController(
        length: VegaConfiguration.isEnabled
            ? CustomBottomNavigation.items.length
            : CustomBottomNavigation.itemsWithVegaDisabled(context: context)
                .length,
        vsync: this,
        initialIndex: index > 0 ? index : 0);
    if (index > 0) {
      setState(() {
        _currentIndex = index;
      });
    } else {
      setState(() {
        _currentIndex = 0;
      });
    }
    _controller.addListener(() {
      _getUnSeenNotificationsCount();
    });
  }

  void _generateInteractTelemetryData(
      {String contentId, String subType}) async {
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
        env: TelemetryEnv.home);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());
  }

  @override
  void didChangeDependencies() {
    _getProfileDetailsFuture.then((data) => setTabItems(widget.customIndex));
    super.didChangeDependencies();
  }

  void _getFaqData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      String isLoggedIn = await _storage.read(key: Storage.hasFetchedFaqData);
      if (isLoggedIn == null) {
        await Provider.of<ChatbotRepository>(context, listen: false)
            .getAlData();
      }
      await Provider.of<ChatbotRepository>(context, listen: false)
          .getFaqData(isLoggedIn: true);
    });
  }

  void _setAppOpenStatus() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final isAppOpened = await _storage.read(
        key: Storage.isAppOpened,
      );
      // checking if the app launch time has stored or not. If it's not stored, need to call setAppOpenedStatus() to store current time
      final lastTriggeredTime = await _storage.read(
        key: Storage.lastTriggeredTime,
      );
      if (isAppOpened != EnglishLang.yes || lastTriggeredTime == null) {
        await Provider.of<InAppReviewRespository>(context, listen: false)
            .setAppOpenedStatus();
      }
    });
  }

  Future<dynamic> _getProfileDetails() async {
    if (!_pageInitialized) {
      //Should be uncomment when vega go to the prod 100-102
      _profileDetails =
          await Provider.of<ProfileRepository>(context, listen: false)
              .getProfileDetailsById('');
      // Store profile image to local Storage
      _storage.write(
          key: Storage.profileImageUrl,
          value: _profileDetails[0].profileImageUrl);
      await _storage.write(
          key: Storage.profileCompletionPercentage,
          value: _profileDetails.first.profileCompletionPercentage.toString());
      //Should be uncomment when vega go to the prod 105-121
      if (VegaConfiguration.isEnabled) {
        if (_profileDetails.first.roles.contains(Roles.spv) ||
            _profileDetails.first.roles.contains(Roles.mdo)) {
          if (_profileDetails.first.roles.contains(Roles.mdo)) {
            mdoID = _profileDetails.first.rawDetails['rootOrgId'];
            mdo = _profileDetails.first.department;
            isMDOAdmin = true;
            isSPVAdmin = false;
          } else {
            mdoID = '';
            mdo = '';
            isSPVAdmin = true;
            isMDOAdmin = false;
          }
        } else {
          mdoID = '';
          mdo = '';
        }
        // print('isMDO: $isMDOAdmin, isSPV: $isSPVAdmin');
        await vegaService.getVegaSuggestions(
            isRegistered: 1,
            isMDO: isMDOAdmin ? 1 : 0,
            isSPV: isSPVAdmin ? 1 : 0);
        _pageInitialized = true;
      }
    }
  }

  _getConnectivity() async {
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      _isDeviceConnected = await InternetConnectionChecker().hasConnection;
      if (!_isDeviceConnected && !_isSetAlert) {
        _showDialogBox();
        setState(() {
          _isSetAlert = true;
        });
      }
    });
  }

  _showDialogBox() => {
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext contxt) => Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    AlertDialog(
                        insetPadding: EdgeInsets.symmetric(horizontal: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        actionsPadding: EdgeInsets.zero,
                        actions: [
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: AppColors.negativeLight),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: Container(
                                    child: TitleRegularGrey60(
                                      AppLocalizations.of(context)
                                          .mStaticUnableToConnectInternet,
                                      fontSize: 14,
                                      color: AppColors.appBarBackground,
                                      maxLines: 3,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () async {
                                    Navigator.pop(contxt, EnglishLang.cancel);
                                    setState(() {
                                      _isSetAlert = false;
                                    });
                                    _isDeviceConnected =
                                        await InternetConnectionChecker()
                                            .hasConnection;
                                    if (!_isDeviceConnected) {
                                      _showDialogBox();
                                      setState(() {
                                        _isSetAlert = true;
                                      });
                                    }
                                  },
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(16, 4, 4, 0),
                                    child: Icon(
                                      Icons.replay_outlined,
                                      color: AppColors.appBarBackground,
                                      size: 24,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ]),
                  ],
                ))
      };

  @override
  void dispose() {
    _controller?.dispose();
    _connectivitySubscription.cancel();
    super.dispose();
    // _getUserSessionId();
  }

  // Future<void> _getUserSessionId() async {
  //   var ssid = await Telemetry.getUserSessionId();
  //   print('ssid: $ssid');
  // }

  Future<void> _getUnSeenNotificationsCount() async {
    try {
      var unSeenNotificationsCount =
          await Provider.of<NotificationRespository>(context, listen: false)
              .getUnSeenNotificationsCount();
      setState(() {
        _unSeenNotificationsCount = int.parse(unSeenNotificationsCount);
      });
    } catch (err) {
      return err;
    }
  }

  // void searchResults(String searchKey) async {
  //   // print('$searchKey');
  //   Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //           builder: (context) => AiAssistantPage(searchKeyword: searchKey)));
  // }

  void _updateUnSeenNotificationsCount(bool status) {
    _getUnSeenNotificationsCount();
  }

  Future<void> getEnrolledCourse() async {
    String responseData =
        await _storage.read(key: Storage.userCourseEnrolmentInfo);
    String time = await _storage.read(key: Storage.enrolmentExpiryTime);
    DateTime expiryTime = time != null ? DateTime.parse(time) : null;
    if (responseData == null || expiryTime == null) {
      await fetchEnrolmentInfo();
    } else if (jsonDecode(responseData).runtimeType == String ||
        expiryTime.difference(DateTime.now()).inSeconds < 0) {
      await fetchEnrolmentInfo();
    }
  }

  Future<void> fetchEnrolmentInfo() async {
    Map<dynamic, dynamic> getEnrolmentList =
        await Provider.of<LearnRepository>(context, listen: false)
            .getEnrollmentList();
    if (getEnrolmentList != null) {
      _storage.write(
          key: Storage.userCourseEnrolmentInfo,
          value: jsonEncode(getEnrolmentList['userCourseEnrolmentInfo']));
      _storage.write(
          key: Storage.enrolmentList,
          value: jsonEncode(getEnrolmentList['courses']));
      _storage.write(
          key: Storage.enrolmentExpiryTime,
          value: DateTime.now()
              .add(Duration(seconds: CACHE_EXPIRY_DURATION))
              .toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FutureBuilder(
            future: _getProfileDetailsFuture,
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              return Scaffold(
                  // Page content
                  body: UpgradeAlert(
                    upgrader: Upgrader(
                        showIgnore: notProdRelease,
                        showLater: notProdRelease,
                        shouldPopScope: () => notProdRelease,
                        canDismissDialog: false,
                        durationUntilAlertAgain: const Duration(minutes: 5),
                        dialogStyle: Platform.isIOS
                            ? UpgradeDialogStyle.cupertino
                            : UpgradeDialogStyle.material),
                    child: PageTransitionSwitcher(
                        transitionBuilder: (
                          Widget child,
                          Animation<double> animation,
                          Animation<double> secondaryAnimation,
                        ) {
                          return FadeThroughTransition(
                            animation: animation,
                            secondaryAnimation: secondaryAnimation,
                            child: child,
                          );
                        },
                        duration: Duration(milliseconds: 500),
                        child: FutureBuilder(
                            future: fetchData(),
                            builder: (context, snapshot) {
                              return VegaConfiguration.isEnabled
                                  ? IndexedStack(
                                      index: _currentIndex,
                                      key: ValueKey<int>(_currentIndex),
                                      children: [
                                        for (final tabItem
                                            in CustomBottomNavigation.items)
                                          tabItem.index == 0
                                              ? HomeScreen(
                                                  index: _currentIndex,
                                                  profileInfo:
                                                      _profileDetails[0])
                                              : tabItem.index == 1
                                                  ? HubScreen(
                                                      index: _currentIndex,
                                                      profileInfo:
                                                          _profileDetails[0])
                                                  : _currentIndex == 2
                                                      // ? AssistantScreen(index: _currentIndex)
                                                      ? AiAssistantPage(
                                                          searchKeyword: '...',
                                                          index: tabItem.index,
                                                        )
                                                      : tabItem.index == 3
                                                          ? NotificationScreen(
                                                              updateNotificationsCount:
                                                                  _updateUnSeenNotificationsCount,
                                                              index:
                                                                  _currentIndex)
                                                          : tabItem.index == 5
                                                              ? ProfileScreen(
                                                                  index:
                                                                      _currentIndex)
                                                              : tabItem.page,
                                      ],
                                    )
                                  : IndexedStack(
                                      index: _currentIndex,
                                      key: ValueKey<int>(_currentIndex),
                                      children: [
                                        for (final tabItem in CustomBottomNavigation
                                            .itemsWithVegaDisabled(
                                                context: context))
                                          tabItem.index == 0
                                              ? _profileDetails != null
                                                  ? HomeScreen(
                                                      index: _currentIndex,
                                                      profileInfo:
                                                          _profileDetails[0],
                                                      profileParentAction:
                                                          updateProfile)
                                                  : HomeScreen(
                                                      index: _currentIndex)
                                              : tabItem.index == 1
                                                  ? _profileDetails != null
                                                      ? HubScreen(
                                                          index: _currentIndex,
                                                          profileInfo:
                                                              _profileDetails[
                                                                  0],
                                                          profileParentAction:
                                                              updateProfile)
                                                      : HubScreen(
                                                          index: _currentIndex)
                                                  : tabItem.index == 2
                                                      ? _profileDetails != null
                                                          ? TextSearchPage(
                                                              index:
                                                                  _currentIndex,
                                                              profileInfo:
                                                                  _profileDetails[
                                                                      0],
                                                              profileParentAction:
                                                                  updateProfile)
                                                          : TextSearchPage(
                                                              index:
                                                                  _currentIndex)
                                                      : tabItem.index == 3
                                                          ? _profileDetails !=
                                                                  null
                                                              ? MyLearningPage(
                                                                  index:
                                                                      _currentIndex,
                                                                  profileInfo:
                                                                      _profileDetails[
                                                                          0],
                                                                  profileParentAction:
                                                                      updateProfile,
                                                                  tabIndex: widget
                                                                      .tabIndex)
                                                              : MyLearningPage(
                                                                  index:
                                                                      _currentIndex,
                                                                  tabIndex: widget
                                                                      .tabIndex)
                                                          : tabItem.page,
                                      ],
                                    );
                            })),
                  ),

                  // Bottom navigation bar
                  bottomNavigationBar: DefaultTabController(
                    length: VegaConfiguration.isEnabled
                        ? CustomBottomNavigation.items.length
                        : CustomBottomNavigation.itemsWithVegaDisabled(
                                context: context)
                            .length,
                    child: Container(
                        child: TabBar(
                          indicator: BoxDecoration(
                            color: Color.fromRGBO(0, 0, 0, 0.04),
                            border: Border(
                              top: BorderSide(
                                color: AppColors.darkBlue,
                                width: 2.0,
                              ),
                            ),
                          ),
                          indicatorColor: Colors.transparent,
                          labelPadding: EdgeInsets.only(top: 0.0),
                          unselectedLabelColor: AppColors.greys60,
                          labelColor: AppColors.darkBlue,
                          labelStyle: GoogleFonts.lato(
                            fontSize: 10.0,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.5,
                          ),
                          unselectedLabelStyle: GoogleFonts.lato(
                            fontSize: 10.0,
                            fontWeight: FontWeight.normal,
                          ),
                          onTap: (int index) => setState(() {
                            _currentIndex = index;
                            _generateInteractTelemetryData(
                                contentId: CustomBottomNavigation
                                        .itemsWithVegaDisabled(
                                            context: context)[index]
                                    .telemetryId,
                                subType: TelemetrySubType.hubMenu);
                            // if (index == 2) {
                            //   Future.delayed(Duration.zero, () async {
                            //     _speechRecognizer =
                            //         Provider.of<SpeechRecognizer>(context, listen: false);
                            //     _speechRecognizer.initialize(searchResults);
                            //     _speechRecognizer.listen();
                            //   });
                            // }
                            // if (index == 0) {
                            //   // Navigator.of(context).push(
                            //   //     MaterialPageRoute(builder: (context) => HomePage()));
                            //   // setState(() {});
                            //   Navigator.pushReplacement(
                            //       context,
                            //       MaterialPageRoute(
                            //           builder: (BuildContext context) => super.widget));
                            // }
                          }),
                          tabs: [
                            for (final tabItem in (VegaConfiguration.isEnabled
                                ? CustomBottomNavigation.items
                                : CustomBottomNavigation.itemsWithVegaDisabled(
                                    context: context)))
                              tabItem.index == _currentIndex
                                  ? Stack(children: <Widget>[
                                      SizedBox(
                                        height: Platform.isIOS ? 70 : 60.0,
                                        child: Container(
                                            margin: EdgeInsets.fromLTRB(
                                                0.0, 0.0, 0.0, 3.0),
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 8,
                                                          bottom: 4,
                                                          left: 8,
                                                          right: 8),
                                                  child: SvgPicture.asset(
                                                    tabItem.svgIcon,
                                                    width: 24.0,
                                                    height: 24.0,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 60,
                                                  child: Text(
                                                    tabItem.title,
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.lato(
                                                        color:
                                                            AppColors.darkBlue,
                                                        fontSize: 10.0,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                )
                                              ],
                                            )),
                                      ),
                                      (tabItem.index == 3 &&
                                              _unSeenNotificationsCount > 0)
                                          ? Positioned(
                                              // draw a red marble
                                              top: 5,
                                              right: 0,
                                              child: Container(
                                                height: 20,
                                                child: CircleAvatar(
                                                    backgroundColor:
                                                        AppColors.negativeLight,
                                                    child: Center(
                                                      child: Text(
                                                        _unSeenNotificationsCount
                                                            .toString(),
                                                        style: GoogleFonts.lato(
                                                            fontSize: 10.0,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400),
                                                      ),
                                                    )),
                                              ),
                                            )
                                          : Positioned(
                                              child: Text(''),
                                            ),
                                    ])
                                  : Stack(children: <Widget>[
                                      SizedBox(
                                        height: Platform.isIOS ? 70 : 60.0,
                                        child: Container(
                                            margin: EdgeInsets.fromLTRB(
                                                0.0, 0.0, 0.0, 3.0),
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 8,
                                                          bottom: 4,
                                                          left: 8,
                                                          right: 8),
                                                  child: SvgPicture.asset(
                                                    tabItem.unselectedSvgIcon,
                                                    width: 24.0,
                                                    height: 24.0,
                                                    color: AppColors.greys60,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 60,
                                                  child: Text(
                                                    tabItem.title,
                                                    style: GoogleFonts.lato(
                                                        color:
                                                            AppColors.greys60,
                                                        fontSize: 10.0,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                    textAlign: TextAlign.center,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                )
                                              ],
                                            )),
                                      ),
                                      (tabItem.index == 3 &&
                                              _unSeenNotificationsCount > 0)
                                          ? Positioned(
                                              // draw a red marble
                                              top: 5,
                                              right: 0,
                                              child: Container(
                                                height: 20,
                                                child: CircleAvatar(
                                                    backgroundColor:
                                                        AppColors.negativeLight,
                                                    child: Center(
                                                      child: Text(
                                                        _unSeenNotificationsCount
                                                            .toString(),
                                                        style: GoogleFonts.lato(
                                                            fontSize: 10.0,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400),
                                                      ),
                                                    )),
                                              ),
                                            )
                                          : Positioned(
                                              child: Text(''),
                                            ),
                                    ])
                          ],
                          controller: _controller,
                        ),
                        decoration:
                            BoxDecoration(color: Colors.white, boxShadow: [
                          BoxShadow(
                            color: AppColors.grey08,
                            blurRadius: 6.0,
                            spreadRadius: 0,
                            offset: Offset(
                              0,
                              -3,
                            ),
                          ),
                        ])),
                  ),

                  // Drawer
                  key: drawerKey,
                  drawer: CustomDrawer(
                    profileDetails:
                        _profileDetails != null ? _profileDetails.first : null,
                  ),
                  floatingActionButtonLocation:
                      FloatingActionButtonLocation.centerFloat,
                  floatingActionButton: Chatbotbtn(
                    loggedInStatus: EnglishLang.loggedIn,
                  ));
            }),
        Consumer<LandingPageRepository>(builder: (BuildContextcontext,
            LandingPageRepository landingPageRepository, Widget child) {
          if (landingPageRepository.showGetStarted) {
            if (_currentIndex > 0) {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                setState(() {
                  _currentIndex = 0;
                  _controller.animateTo(0);
                });
              });
            }
          }
          return Visibility(
            visible: (landingPageRepository.showGetStarted),
            child: Positioned.fill(
              child: IntroGetStart(
                returnCallback: _getStartReturnCallback,
              ),
            ),
          );
        }),
      ],
    );
  }

  Future<void> _getStartReturnCallback() async {
    Provider.of<LandingPageRepository>(context, listen: false)
        .updateShowGetStarted(false);
  }

  Future<void> _getGetStartedStatus() async {
    _showGetStarted =
        await _storage.read(key: Storage.getStarted).then((value) {
      return value != GetStarted.finished;
    });
    Provider.of<LandingPageRepository>(context, listen: false)
        .updateShowGetStarted(_showGetStarted);
  }

  updateProfile() async {
    await _getProfileDetails();
    setState(() {});
  }

  fetchData() async {
    await getCbplan();
    await _getContinueLearningCourses();
    await getTrendingCourse(
        category: CourseCategory.courses.name, enableAcrossDept: false);
    await getTrendingCourse(
        category: CourseCategory.programs.name, enableAcrossDept: false);
    await getTrendingCourse(
        category: CourseCategory.courses.name, enableAcrossDept: true);
    await getTrendingCourse(
        category: CourseCategory.certifications.name, enableAcrossDept: true);
    await getTrendingCourse(
        category: CourseCategory.under_30_mins.name, enableAcrossDept: true);
    await getTrendingCourse(
        category: CourseCategory.programs.name, enableAcrossDept: true);
    await _getCourses();
  }

  Future<void> getTrendingCourse(
      {String category, bool enableAcrossDept = true}) async {
    await Provider.of<LearnRepository>(context, listen: false)
        .getTrendingSearch(
            category: category, enableAcrossDept: enableAcrossDept);
  }

  Future<void> getCbplan() async {
    var cbpPlanData =
        await Provider.of<LearnRepository>(context, listen: false).getCbplan();
    _storage.write(key: Storage.cbpdataInfo, value: jsonEncode(cbpPlanData));
  }

  _getCourses() async {
    await Provider.of<LearnRepository>(context, listen: false)
        .getHomeCoursesConfig();
  }

  Future<dynamic> _getContinueLearningCourses() async {
    try {
      await Provider.of<LearnRepository>(context, listen: false)
          .getContinueLearningCourses(checkforCBPEnddate: true);
    } catch (err) {
      return err;
    }
  }
}
