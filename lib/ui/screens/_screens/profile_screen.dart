import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/respositories/_respositories/profile_repository.dart';
import 'package:karmayogi_mobile/ui/widgets/_profile/basic_logged_in_user_details.dart';
import 'package:provider/provider.dart';
import '../../../constants/_constants/telemetry_constants.dart';
import '../../../localization/_langs/english_lang.dart';
import '../../../respositories/_respositories/learn_repository.dart';
import '../../../util/telemetry.dart';
import '../../../util/telemetry_db_helper.dart';
import './../../pages/index.dart';
import './../../screens/index.dart';
import './../../widgets/index.dart';
import './../../../constants/index.dart';
import './../../../models/index.dart';
// import 'dart:developer' as developer;

class ProfileScreen extends StatefulWidget {
  static const route = AppUrl.profilePage;
  final int index;
  final bool showMyActivity;
  final profileParentAction;
  final double scrollOffset;

  ProfileScreen(
      {Key key,
      this.index,
      this.showMyActivity = false,
      this.profileParentAction,
      this.scrollOffset = 0.0})
      : super(key: key);

  @override
  ProfileScreenState createState() {
    return ProfileScreenState();
  }
}

class ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  TabController _controller;
  ScrollController _myActivityScrollController = ScrollController();

  List<Profile> _profileDetails;
  List<Course> _completedLearningcourses;
  double appBarHeight = 220;

  String userId;
  String userSessionId;
  String messageIdentifier;
  String departmentId;
  String deviceIdentifier;
  var telemetryEventData;

  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _setupMyActivityScroll();
    // setAppBarHeight();
    _generateTelemetryData();
    bool validIndex = widget.index == (VegaConfiguration.isEnabled ? 4 : 3);
    // if (validIndex) {
    _getCompletedLearningCourses();
    // }
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    bool validIndex = widget.index == (VegaConfiguration.isEnabled ? 4 : 3);

    if (validIndex) {
      _controller = TabController(
          length: ProfileTab.items(context: context).length,
          vsync: this,
          initialIndex: 0);
    } else if (widget.showMyActivity) {
      _controller = TabController(
          length: ProfileTab.items(context: context).length,
          vsync: this,
          initialIndex: 1);
    }
    _getEhrmsData();
  }

  void _setupMyActivityScroll() {
    _scrollOffset = widget.scrollOffset ?? 0.0;
    if (((_scrollOffset > 0.0) && widget.showMyActivity)) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Future.delayed(Duration(seconds: 1), () async {
          _myActivityScrollController.animateTo(widget.scrollOffset,
              duration: Duration(seconds: 1), curve: Curves.easeInOut);
        });
      });
    }
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
        TelemetryPageIdentifier.myProfilePageId,
        userSessionId,
        messageIdentifier,
        TelemetryType.page,
        TelemetryPageIdentifier.myProfilePageUri,
        env: TelemetryEnv.profile);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData1);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());
  }

  void _generateInteractTelemetryData(String contentId,
      {String subType = '', String primaryCategory}) async {
    Map eventData = Telemetry.getInteractTelemetryEvent(
        deviceIdentifier,
        userId,
        departmentId,
        TelemetryPageIdentifier.myProfilePageUri,
        userSessionId,
        messageIdentifier,
        contentId,
        subType,
        env: TelemetryEnv.profile,
        objectType: primaryCategory != null ? primaryCategory : subType);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());
  }

  void _triggerInteractTelemetryData(int index) {
    if (index == 0) {
      _generateInteractTelemetryData(TelemetrySubType.profile);
    } else if (index == 1) {
      _generateInteractTelemetryData(TelemetrySubType.myActivities);
    } else if (index == 2) {
      _generateInteractTelemetryData(TelemetrySubType.yourDiscussions);
    } else if (index == 3) {
      _generateInteractTelemetryData(TelemetrySubType.savedPosts);
    }
  }

  _getEhrmsData() async {
    final profileDetails =
        await Provider.of<ProfileRepository>(context, listen: false)
            .profileDetails;
    if (profileDetails.ehrmsId != null) {
      Provider.of<ProfileRepository>(context, listen: false).getEhrmsDetails();
    }
  }

  Future<List<Course>> _getCompletedLearningCourses() async {
    final continueLearningCourses =
        await Provider.of<LearnRepository>(context, listen: false)
            .getContinueLearningCourses();
    // _AnimatedMovies = AllMovies.where((i) => i.isAnimated).toList();
    if (continueLearningCourses == null) {
      _completedLearningcourses = [];
      return _completedLearningcourses;
    }
    _completedLearningcourses = continueLearningCourses
        .where((course) => course.raw['completionPercentage'] == 100)
        .toList();
    setState(() {});
    return _completedLearningcourses;
  }

  Future<List<Profile>> _getProfileDetails() async {
    _profileDetails =
        await Provider.of<ProfileRepository>(context, listen: false)
            .getProfileDetailsById('');
    // setAppBarHeight();
    // print(_profileDetails[0].toString());
    return _profileDetails;
  }

  void setAppBarHeight() {
    if (_profileDetails[0].professionalDetails.length > 0) {
      if (_profileDetails[0].professionalDetails[0]['designation'] != null &&
          _profileDetails[0].professionalDetails[0]['name'] != null &&
          _profileDetails[0].experience[0]['location'] != null) {
        setState(() {
          appBarHeight = 250;
        });
      } else if (_profileDetails[0].professionalDetails[0]['designation'] !=
              null ||
          _profileDetails[0].professionalDetails[0]['name'] != null ||
          _profileDetails[0].experience[0]['location'] != null) {
        setState(() {
          appBarHeight = 220;
        });
      } else if (_profileDetails[0].professionalDetails[0]['designation'] ==
              null ||
          _profileDetails[0].professionalDetails[0]['name'] != null &&
              _profileDetails[0].experience[0]['location'] != null) {
        setState(() {
          appBarHeight = 200;
        });
      }
    }
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller.dispose();
    }
    if (_myActivityScrollController != null) {
      _myActivityScrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // Tab controller
        body: DefaultTabController(
            length: ProfileTab.items(context: context).length,
            child: SafeArea(
              child: FutureBuilder(
                  future: _getProfileDetails(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Profile>> snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      // List<Profile> profileDetails = snapshot.data;

                      return NestedScrollView(
                          headerSliverBuilder:
                              (BuildContext context, bool innerBoxIsScrolled) {
                            return <Widget>[
                              SliverAppBar(
                                  pinned: true,
                                  expandedHeight: (_profileDetails[0]
                                                  .professionalDetails
                                                  .length >
                                              0 &&
                                          _profileDetails[0].designation !=
                                              null)
                                      ? 260
                                      : 220,
                                  flexibleSpace: ListView(
                                    shrinkWrap: true,
                                    children: <Widget>[
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Spacer(),
                                          IconButton(
                                              icon: Icon(
                                                Icons.settings,
                                                color: AppColors.greys60,
                                              ),
                                              onPressed: () {
                                                Navigator.pushNamed(context,
                                                    AppUrl.settingsPage);
                                              }),
                                        ],
                                      ),
                                      BasicLoggedInUserDetails(),
                                      // BasicDetails(
                                      //   _profileDetails[0],
                                      //   isLoggedUser: true,
                                      // ),
                                      Container(
                                        margin: const EdgeInsets.all(10),
                                        child: IconButton(
                                            icon: Icon(
                                              Icons.filter_list,
                                              color: Colors.white,
                                            ),
                                            onPressed: () {}),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: AppColors.primaryThree,
                                        ),
                                        height: 40,
                                      ),
                                    ],
                                  )),
                              SliverPersistentHeader(
                                delegate: SilverAppBarDelegate(
                                  TabBar(
                                      isScrollable: true,
                                      indicator: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: AppColors.darkBlue,
                                            width: 2.0,
                                          ),
                                        ),
                                      ),
                                      indicatorColor: Colors.white,
                                      labelPadding: EdgeInsets.only(top: 0.0),
                                      unselectedLabelColor: AppColors.greys60,
                                      labelColor: AppColors.darkBlue,
                                      labelStyle: GoogleFonts.lato(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.greys87,
                                      ),
                                      unselectedLabelStyle: GoogleFonts.lato(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.greys60,
                                      ),
                                      tabs: [
                                        for (var tabItem in ProfileTab.items(
                                            context: context))
                                          Container(
                                            // width: 110,
                                            padding: const EdgeInsets.only(
                                                left: 16, right: 16),
                                            child: Tab(
                                              child: Padding(
                                                padding: EdgeInsets.all(5.0),
                                                child: Text(
                                                  tabItem.title,
                                                ),
                                              ),
                                            ),
                                          )
                                      ],
                                      controller: _controller,
                                      onTap: (value) {
                                        setState(() {
                                          _scrollOffset = 0.0;
                                        });
                                        _triggerInteractTelemetryData(value);
                                      }),
                                ),
                                pinned: true,
                                floating: false,
                              ),
                            ];
                          },

                          // TabBar view
                          body: Container(
                            color: AppColors.lightBackground,
                            child: TabBarView(
                              controller: _controller,
                              children: [
                                Consumer<LearnRepository>(builder:
                                    (BuildContext context,
                                        LearnRepository learnRepository,
                                        Widget child) {
                                  return ProfilePage(_profileDetails[0],
                                      completedCourse:
                                          _completedLearningcourses);
                                }),
                                SingleChildScrollView(
                                  controller: ((_scrollOffset > 0.0) &&
                                          widget.showMyActivity)
                                      ? _myActivityScrollController
                                      : null,
                                  child: Column(
                                    children: [YourActivities()],
                                  ),
                                ),
                                // YourActivities(scrollOffset: widget.scrollOffset),
                                MyDiscussionsPage(
                                  isProfilePage: true,
                                ),
                                SavedPostsPage(),
                              ],
                            ),
                          ));
                    } else {
                      // return Center(child: CircularProgressIndicator());
                      return PageLoader();
                    }
                  }),
            )),
        floatingActionButton: OpenContainer(
          openColor: Colors.white,
          transitionDuration: Duration(milliseconds: 750),
          openBuilder: (context, _) =>
              EditProfileScreen(profileParentAction: updateProfile),
          closedShape: CircleBorder(),
          closedColor: Colors.white,
          transitionType: ContainerTransitionType.fadeThrough,
          closedBuilder: (context, openContainer) => FloatingActionButton(
            onPressed: openContainer,
            child: Icon(Icons.edit),
            backgroundColor: AppColors.darkBlue,
          ),
        ));
  }

  updateProfile() async {
    await _getProfileDetails();
    widget.profileParentAction();
    setState(() {});
  }
}
