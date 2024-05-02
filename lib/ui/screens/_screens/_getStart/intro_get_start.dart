import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/storage_constants.dart';
import 'package:karmayogi_mobile/services/_services/profile_service.dart';
import 'package:karmayogi_mobile/ui/widgets/_tour/tour_video_progress_slider.dart';
import 'package:provider/provider.dart';
import 'package:smooth_video_progress/smooth_video_progress.dart';
import 'package:video_player/video_player.dart';
import '../../../../constants/_constants/telemetry_constants.dart';
import '../../../../constants/index.dart';
import '../../../../localization/_langs/english_lang.dart';
import '../../../../models/_models/profile_model.dart';
import '../../../../models/_models/telemetry_event_model.dart';
import '../../../../respositories/_respositories/profile_repository.dart';
import '../../../../services/_services/vega_service.dart';
import '../../../../util/telemetry.dart';
import '../../../../util/telemetry_db_helper.dart';
import 'intro_tour_screen.dart';

class IntroGetStart extends StatefulWidget {
  final Function returnCallback;
  IntroGetStart({this.returnCallback});
  @override
  _IntroGetStartState createState() => _IntroGetStartState();
}

class _IntroGetStartState extends State<IntroGetStart> {
  final ProfileService profileService = ProfileService();

  bool showGetStart = true;
  var actionList = [
    {
      'icon': 'assets/img/video_play.png',
      'description': 'What is iGOT Karmayogi?'
    },
    {'icon': 'assets/img/tour.png', 'description': 'Take a tour'}
  ];
  String userId;
  String userSessionId;
  String messageIdentifier;
  String departmentId;
  Timer _timer;
  int _start = 0;
  List allEventsData = [];
  String deviceIdentifier;
  var telemetryEventData;
  String identifier;
  String primaryCategory;
  bool isFeaturedCourse = false;
  bool isvideoplaying = false;
  bool isTourView = false;
  VideoPlayerController _videoController;
  ChewieController _chewieController;
  final bool isPublic = true;

  bool _visible = true;
  List<Profile> _profileDetails;
  final VegaService vegaService = VegaService();

  @override
  void initState() {
    super.initState();
    initializeChewiePlayer();
    // _startTimer();
    _generateImpressionTelemetryData();
  }

  Future<void> initializeChewiePlayer() async {
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(ApiUrl.baseUrl + '/content-store/Website_Video.mp4'),
      videoPlayerOptions: VideoPlayerOptions(
        mixWithOthers: false,
      ),
    )..initialize().then((_) {
        setState(() {}); // Ensure the first frame is shown
      });
  }

  void _generateImpressionTelemetryData() async {
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
        TelemetryType.viewer,
        TelemetryPageIdentifier.homePageUri,
        env: TelemetryEnv.getStarted);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData1);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());
  }

  void _generateInteractTelemetryData(
      {String contentId, String subtype}) async {
    Map eventData = Telemetry.getInteractTelemetryEvent(
        deviceIdentifier,
        userId,
        departmentId,
        TelemetryPageIdentifier.homePageId,
        userSessionId,
        messageIdentifier,
        contentId,
        subtype,
        env: TelemetryEnv.getStarted);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());
  }

  void _triggerPlayerStartTelemetryEvent() async {
    _startTimer();
    Map eventData = Telemetry.getStartTelemetryEvent(
        deviceIdentifier,
        userId,
        departmentId,
        TelemetryPageIdentifier.homePageId,
        userSessionId,
        messageIdentifier,
        TelemetryType.player,
        TelemetryPageIdentifier.homePageUri,
        env: TelemetryEnv.getStarted);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());

    allEventsData.add(eventData);
  }

  _triggerPlayerEndTelemetryEvent() async {
    Map eventData = Telemetry.getEndTelemetryEvent(
        deviceIdentifier,
        userId,
        departmentId,
        TelemetryPageIdentifier.homePageId,
        userSessionId,
        messageIdentifier,
        _start,
        TelemetryType.player,
        TelemetryPageIdentifier.homePageUri,
        {},
        env: TelemetryEnv.getStarted);
    allEventsData.add(eventData);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());
  }

  Future<dynamic> _getProfileDetails() async {
    _profileDetails =
        await Provider.of<ProfileRepository>(context, listen: false)
            .getProfileDetailsById('');
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
      await vegaService.getVegaSuggestions(
          isRegistered: 1,
          isMDO: isMDOAdmin ? 1 : 0,
          isSPV: isSPVAdmin ? 1 : 0);
    }
  }

  @override
  void dispose() {
    if (_videoController != null) _videoController.dispose();
    if (_chewieController != null) _chewieController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _start = 0;
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        _start++;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return showGetStart
        ? Stack(
            children: [
              Material(
                  type: MaterialType.transparency,
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    color: Colors.black.withOpacity(0.7),
                    child: SafeArea(
                      child:
                          ((isvideoplaying ?? false) && (!isTourView ?? false))
                              ? _videoPlayerView()
                              : (!isTourView ?? false)
                                  ? _getStartedView()
                                  : SizedBox(),
                    ),
                  )),
              if (isTourView == true)
                Positioned.fill(
                  child: _profileDetails != null
                      ? IntroTourScreen(0,
                          profileInfo: _profileDetails[0],
                          previousPageCallback: _tourReturnCallback,
                          returnCallback: _skipCallback)
                      : IntroTourScreen(
                          0,
                          previousPageCallback: _tourReturnCallback,
                          returnCallback: _skipCallback,
                        ),
                )
            ],
          )
        : Center();
  }

  Future<void> _tourReturnCallback() async {
    setState(() {
      isvideoplaying = true;
      isTourView = false;
    });
  }

  Future<void> _skipCallback({bool isVideoSkip = false}) async {
    if (isTourView ?? false) {
      if (widget.returnCallback != null) {
        widget.returnCallback();
      }
    } else {
      final _storage = FlutterSecureStorage();
      try {
        var response = await profileService.updateGetStarted(isSkipped: true);
        if (response['params']['status'].toString().toLowerCase() ==
            'success') {
          _storage.write(key: Storage.getStarted, value: GetStarted.finished);
        }
      } catch (e) {}
      setState(() {
        showGetStart = false;
      });
      if (isVideoSkip) {
        if (_videoController.value.isPlaying) {
          _triggerPlayerEndTelemetryEvent();
        }
        _generateInteractTelemetryData(
            contentId: TelemetryIdentifier.videoSkip,
            subtype: TelemetrySubType.video);
      } else {
        _generateInteractTelemetryData(
            contentId: TelemetryIdentifier.welcomeSkip,
            subtype: TelemetrySubType.welcome);
      }
      if (widget.returnCallback != null) {
        widget.returnCallback();
      }
    }
  }

  Widget _videoPlayerView() {
    return Container(
        height: MediaQuery.of(context).size.height,
        // color: Colors.black.withOpacity(0.7),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  width: 87,
                  height: 40,
                  decoration: BoxDecoration(
                      color: AppColors.grey16,
                      borderRadius: BorderRadius.circular(4)),
                  child: ElevatedButton(
                      onPressed: () => _skipCallback(isVideoSkip: true),
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStatePropertyAll(AppColors.grey16)),
                      child: Text(EnglishLang.skip,
                          style: GoogleFonts.lato(
                              decoration: TextDecoration.none,
                              color: AppColors.appBarBackground,
                              fontSize: 14,
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.w700,
                              height: 1.5))),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(0),
                child: Column(
                  children: [
                    Text(EnglishLang.getstartvideo,
                        style: GoogleFonts.lato(
                            decoration: TextDecoration.none,
                            color: AppColors.appBarBackground,
                            fontSize: 16,
                            letterSpacing: 0.5,
                            fontWeight: FontWeight.w700,
                            height: 1.5)),
                    SizedBox(height: 25),
                    GestureDetector(
                      onPanStart: (details) => resetVisibility(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Center(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 500,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    border: Border.all(
                                        color: Colors.white, width: 1),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: AspectRatio(
                                      aspectRatio:
                                          _videoController.value.aspectRatio,
                                      child: VideoPlayer(_videoController),
                                    ),
                                  ),
                                ),
                                ValueListenableBuilder(
                                  valueListenable: _videoController,
                                  builder: (context, value, child) {
                                    return GestureDetector(
                                      onTap: () {
                                        if (_videoController.value.isPlaying) {
                                          _videoController.pause();
                                          _triggerPlayerEndTelemetryEvent();
                                        } else {
                                          _videoController.play();
                                          _triggerPlayerStartTelemetryEvent();
                                        }
                                        //update the variable again to hide action button
                                        hideVisibilityAfterSomeTime();
                                      },
                                      child: Visibility(
                                        visible: _visible ||
                                            !_videoController.value.isPlaying,
                                        maintainAnimation: true,
                                        maintainState: true,
                                        child: Icon(
                                          _videoController.value.isPlaying
                                              ? Icons.pause_circle
                                              : Icons.play_circle,
                                          color: Colors.grey,
                                          size: 50.0,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                Positioned(
                                  top: 180,
                                  bottom: 0,
                                  child: Container(
                                    width: 380,
                                    child: SmoothVideoProgress(
                                      controller: _videoController,
                                      builder:
                                          (context, position, duration, _) =>
                                              VideoProgressSlider(
                                        position: position,
                                        duration: duration,
                                        controller: _videoController,
                                        swatch: AppColors.primaryThree,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    width: 500,
                    height: 48,
                    decoration: BoxDecoration(
                        color: Color.fromRGBO(243, 150, 47, 1),
                        borderRadius: BorderRadius.circular(4)),
                    child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            if (_videoController.value.isPlaying) {
                              _videoController.pause();
                              _triggerPlayerEndTelemetryEvent();
                            } else {
                              _videoController.play();
                              _triggerPlayerStartTelemetryEvent();
                            }
                          });
                          //update the variable again to hide action button
                          hideVisibilityAfterSomeTime();
                        },
                        style: ButtonStyle(
                            backgroundColor: MaterialStatePropertyAll(
                                Color.fromRGBO(243, 150, 47, 1))),
                        child: ValueListenableBuilder(
                            valueListenable: _videoController,
                            builder: (context, value, child) {
                              return Text(
                                  _videoController.value.isPlaying
                                      ? EnglishLang.pause
                                      : EnglishLang.watch,
                                  style: GoogleFonts.lato(
                                      decoration: TextDecoration.none,
                                      color: AppColors.primaryTwo,
                                      fontSize: 14,
                                      letterSpacing: 0.5,
                                      fontWeight: FontWeight.w700,
                                      height: 1.5));
                            })),
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: 500,
                    height: 48,
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(color: Colors.white, width: 1),
                        borderRadius: BorderRadius.circular(4)),
                    child: ElevatedButton(
                        onPressed: () {
                          _videoController.pause();
                          if (_videoController.value.isPlaying) {
                            _triggerPlayerEndTelemetryEvent();
                          }
                          _generateInteractTelemetryData(
                              contentId: TelemetryIdentifier.tourStart,
                              subtype: TelemetrySubType.tour);
                          _getProfileDetails();
                          setState(() {
                            isTourView = true;
                          });
                        },
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll(AppColors.black16)),
                        child: Text(EnglishLang.next,
                            style: GoogleFonts.lato(
                                decoration: TextDecoration.none,
                                color: Colors.white,
                                fontSize: 14,
                                letterSpacing: 0.5,
                                fontWeight: FontWeight.w700,
                                height: 1.5))),
                  )
                ],
              )
            ],
          ),
        ));
  }

  Widget _getStartedView() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 87,
              height: 40,
              decoration: BoxDecoration(
                  color: AppColors.grey16,
                  borderRadius: BorderRadius.circular(4)),
              child: ElevatedButton(
                  onPressed: _skipCallback,
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStatePropertyAll(AppColors.grey16)),
                  child: Text(EnglishLang.skip,
                      style: GoogleFonts.lato(
                          decoration: TextDecoration.none,
                          color: AppColors.appBarBackground,
                          fontSize: 14,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w700,
                          height: 1.5))),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Center(
                  child: Column(children: [
                    Image(
                      image: AssetImage('assets/img/karmasahayogi.png'),
                      height: 160,
                    ),
                    Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4)),
                            color: Color(0XFF1B4CA1),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(47, 24, 47, 20),
                            child: Column(
                              children: [
                                Text(EnglishLang.getStarted,
                                    style: GoogleFonts.lato(
                                        decoration: TextDecoration.none,
                                        color:
                                            Color.fromRGBO(255, 255, 255, 0.95),
                                        fontSize: 16,
                                        letterSpacing: 0.12,
                                        fontWeight: FontWeight.w700,
                                        height: 1.5)),
                                SizedBox(height: 4),
                                Text(EnglishLang.welcome,
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.lato(
                                        decoration: TextDecoration.none,
                                        color:
                                            Color.fromRGBO(255, 255, 255, 0.95),
                                        fontSize: 14,
                                        letterSpacing: 0.25,
                                        fontWeight: FontWeight.w400,
                                        height: 1.5))
                              ],
                            ),
                          ),
                        ),
                        Container(
                          height: 160,
                          width: 500,
                          decoration: BoxDecoration(
                              color: AppColors.lightGrey,
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(4),
                                  bottomRight: Radius.circular(4))),
                          child: ListView.separated(
                            padding: EdgeInsets.all(0),
                            itemCount: actionList.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                height: 70,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      isvideoplaying = true;
                                    });
                                    if (index != 0) {
                                      setState(() {
                                        isTourView = true;
                                      });
                                      _generateInteractTelemetryData(
                                          contentId:
                                              TelemetryIdentifier.tourStart,
                                          subtype: TelemetrySubType.tour);
                                      _getProfileDetails();
                                    }
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 16, right: 16),
                                            child: Icon(Icons.check_circle,
                                                size: 24,
                                                color: AppColors.grey16),
                                          ),
                                          Image(
                                            image: AssetImage(
                                                actionList[index]['icon']),
                                            height: 40,
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(actionList[index]['description'],
                                              style: GoogleFonts.lato(
                                                  color: Color.fromRGBO(
                                                      0, 0, 0, 0.87),
                                                  fontSize: 14.0,
                                                  letterSpacing: 0.5,
                                                  height: 1.5,
                                                  fontWeight: FontWeight.w700)),
                                        ],
                                      ),
                                      IconButton(
                                          onPressed: () {
                                            if (index == 0) {
                                              setState(() {
                                                isvideoplaying = true;
                                              });
                                            } else {
                                              if (index == 0) {
                                                setState(() {
                                                  isTourView = true;
                                                });
                                              }
                                              _getProfileDetails();
                                            }

                                            setState(() {});
                                          },
                                          icon: Icon(
                                            Icons.arrow_forward_ios_sharp,
                                            size: 13,
                                            color:
                                                Color.fromRGBO(27, 76, 161, 1),
                                          ))
                                    ],
                                  ),
                                ),
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) => Divider(
                              thickness: 2,
                              color: AppColors.grey16,
                            ),
                          ),
                        )
                      ],
                    )
                  ]),
                ),
              ],
            ),
          ),
          Container(
            width: 500,
            height: 48,
            decoration: BoxDecoration(
                color: Color.fromRGBO(243, 150, 47, 1),
                borderRadius: BorderRadius.circular(4)),
            child: ElevatedButton(
                onPressed: () {
                  _generateInteractTelemetryData(
                      contentId: TelemetryIdentifier.welcomeStart,
                      subtype: TelemetrySubType.welcome);
                  setState(() {
                    isvideoplaying = true;
                  });
                },
                style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(
                        Color.fromRGBO(243, 150, 47, 1))),
                child: Text(EnglishLang.getStarted,
                    style: GoogleFonts.lato(
                        decoration: TextDecoration.none,
                        color: AppColors.primaryTwo,
                        fontSize: 14,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w700,
                        height: 1.5))),
          )
        ],
      ),
    );
  }

  hideVisibilityAfterSomeTime() {
    Future.delayed(const Duration(seconds: 3), () {
      if (this.mounted) {
        setState(() {
          _visible = false; //update the variable to hide action button
        });
      }
    });
  }

  resetVisibility() {
    Future.delayed(const Duration(seconds: 1), () {
      if (this.mounted) {
        setState(() {
          _visible = true; //update the variable to show action button
        });
      }
    });

    //update the variable again to hide action button
    hideVisibilityAfterSomeTime();
  }
}
