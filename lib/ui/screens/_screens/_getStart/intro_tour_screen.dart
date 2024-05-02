import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/storage_constants.dart';
import 'package:karmayogi_mobile/services/_services/profile_service.dart';
import 'package:karmayogi_mobile/ui/widgets/_tour/tour_finish_widget.dart';
import 'package:karmayogi_mobile/ui/widgets/_tour/tour_widget.dart';
import '../../../../constants/_constants/telemetry_constants.dart';
import '../../../../models/index.dart';
import '../../../../util/telemetry.dart';
import '../../../../util/telemetry_db_helper.dart';
import '../../../widgets/_tour/tour_bottom_widget.dart';

class IntroTourScreen extends StatefulWidget {
  final int initialScreen;
  final Profile profileInfo;
  final Function previousPageCallback;
  final Function returnCallback;

  IntroTourScreen(this.initialScreen,
      {this.profileInfo, this.previousPageCallback, this.returnCallback});

  @override
  _IntroTourScreenState createState() => _IntroTourScreenState();
}

class _IntroTourScreenState extends State<IntroTourScreen> {
  final ProfileService profileService = ProfileService();
  bool showGetStart = true;
  bool isNextDiscussTapped = true;
  bool isNextLearnTapped = true;
  bool isNext2Tapped = true;

  bool isPreviousTapped = true;
  bool isBottomTapped = false;
  bool visible = true;
  bool isNextSearchTapped = false;
  String userId;
  String userSessionId;
  String messageIdentifier;
  String departmentId;
  List allEventsData = [];
  String deviceIdentifier;
  var telemetryEventData;
  String identifier;
  String primaryCategory;
  bool isFeaturedCourse = false;

  @override
  void initState() {
    super.initState();
  }

  void _generateTelemetryTourInteractData(
      {String contentId, String subType}) async {
    deviceIdentifier = await Telemetry.getDeviceIdentifier();
    userId = await Telemetry.getUserId();
    userSessionId = await Telemetry.generateUserSessionId();
    messageIdentifier = await Telemetry.generateUserSessionId();
    departmentId = await Telemetry.getUserDeptId();
    Map eventData1 = Telemetry.getInteractTelemetryEvent(
        deviceIdentifier,
        userId,
        departmentId,
        TelemetryPageIdentifier.homePageId,
        userSessionId,
        messageIdentifier,
        contentId,
        subType,
        env: TelemetryEnv.getStarted);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData1);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());
  }

  @override
  Widget build(BuildContext context) {
    return showGetStart
        ? isNext2Tapped == true
            ? Material(
                type: MaterialType.transparency,
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  color: Colors.black.withOpacity(0.7),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        isNextDiscussTapped == false
                            ? TourWidget(
                                title:
                                    AppLocalizations.of(context).mStaticDiscuss,
                                description: AppLocalizations.of(context)
                                    .mDiscussDescMandatory,
                                insidetitle:
                                    AppLocalizations.of(context).mStaticDiscuss,
                                icon: Icons.school_outlined,
                                isTapped: isNextDiscussTapped,
                                isProfileTapped: false,
                                isDiscussTapped: true,
                                image: 'assets/img/Discuss.svg',
                                onPerviousTap: () {
                                  setState(() {
                                    isNextDiscussTapped = true;
                                    isNextLearnTapped = true;
                                  });
                                  _generateTelemetryTourInteractData(
                                      contentId:
                                          TelemetryIdentifier.discussPrevious,
                                      subType: TelemetrySubType.discuss);
                                },
                                onCloseTap: () async {
                                  _closeTabCallback();
                                },
                                onTap: () {
                                  setState(() {
                                    isNextLearnTapped = false;
                                    isNextDiscussTapped = true;
                                    isNext2Tapped = false;
                                    isBottomTapped = true;
                                  });
                                  _generateTelemetryTourInteractData(
                                      contentId: TelemetryIdentifier.dicussNext,
                                      subType: TelemetrySubType.discuss);
                                },
                              )
                            : isNextLearnTapped == true
                                ? TourWidget(
                                    title: AppLocalizations.of(context)
                                        .mTourStepLearn,
                                    description: AppLocalizations.of(context)
                                        .mStaticLearnDesc,
                                    insidetitle: AppLocalizations.of(context)
                                        .mLearningHub,
                                    image: 'assets/img/Learn.svg',
                                    isTapped: true,
                                    isProfileTapped: false,
                                    isDiscussTapped: false,
                                    onPerviousTap: () {
                                      _generateTelemetryTourInteractData(
                                          contentId:
                                              TelemetryIdentifier.learnPrevious,
                                          subType: TelemetrySubType.learn);
                                      if (widget.previousPageCallback != null) {
                                        widget.previousPageCallback();
                                      }
                                    },
                                    onCloseTap: () async {
                                      _closeTabCallback();
                                    },
                                    onTap: () {
                                      setState(() {
                                        isNextDiscussTapped = false;
                                        isNextLearnTapped = true;
                                      });
                                      _generateTelemetryTourInteractData(
                                          contentId:
                                              TelemetryIdentifier.learnNext,
                                          subType: TelemetrySubType.learn);
                                    },
                                  )
                                : TourWidget(
                                    title: AppLocalizations.of(context)
                                        .mStaticProfile,
                                    description: AppLocalizations.of(context)
                                        .mStaticProfileDesc,
                                    insidetitle: '',
                                    icon: Icons.person,
                                    profileInfo: widget.profileInfo,
                                    isTapped: isNextLearnTapped,
                                    isProfileTapped: true,
                                    isDiscussTapped: false,
                                    onCloseTap: () async {
                                      _closeTabCallback();
                                    },
                                    onPerviousTap: () {
                                      setState(() {
                                        isNext2Tapped = false;
                                        isNextSearchTapped = false;
                                        isBottomTapped = true;
                                      });
                                      _generateTelemetryTourInteractData(
                                          contentId: TelemetryIdentifier
                                              .profilePrevious,
                                          subType: TelemetrySubType.profile);
                                    },
                                    onTap: () {
                                      setState(() {
                                        isNext2Tapped = false;
                                        isBottomTapped = false;
                                        isNextSearchTapped = true;
                                      });
                                      _generateTelemetryTourInteractData(
                                          contentId:
                                              TelemetryIdentifier.tourFinish,
                                          subType: TelemetrySubType.finish);
                                    },
                                  )
                      ],
                    ),
                  ),
                )
                // : TakeTour(),
                )
            : isNextSearchTapped == false
                ? Material(
                    type: MaterialType.transparency,
                    child: Container(
                      height: double
                          .infinity, // Take up all available vertical space
                      width: double.infinity,
                      color: Colors.black.withOpacity(0.7),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        // mainAxisSize: MainAxisSize.max,
                        children: [
                          TourBottomWidget(
                            title: AppLocalizations.of(context).mStaticSearch,
                            description:
                                AppLocalizations.of(context).mStaticSearchDesc,
                            insidetitle:
                                AppLocalizations.of(context).mCommonSearch,
                            icon: Icons.search,
                            isTapped: true,
                            isProfileTapped: false,
                            isDiscussTapped: false,
                            onPerviousTap: () {
                              setState(() {
                                isNext2Tapped = true;
                                isNextDiscussTapped = false;
                              });
                              _generateTelemetryTourInteractData(
                                  contentId: TelemetryIdentifier.searchPrevious,
                                  subType: TelemetrySubType.search);
                            },
                            onCloseTap: () async {
                              _closeTabCallback();
                            },
                            onTap: () {
                              setState(() {
                                isNextSearchTapped = true;
                                isNext2Tapped = true;
                                isBottomTapped = false;
                                _generateTelemetryTourInteractData(
                                    contentId: TelemetryIdentifier.searchNext,
                                    subType: TelemetrySubType.search);
                              });
                            },
                          )
                        ],
                      ),
                    ),
                  )
                : TourFinishWidget(
                    returnCallback: widget.returnCallback,
                  )
        : Center();
  }

  Future<void> _closeTabCallback() async {
    final _storage = FlutterSecureStorage();
    try {
      var response = await profileService.updateGetStarted(isSkipped: true);
      if (response['params']['status'].toString().toLowerCase() == 'success') {
        _storage.write(key: Storage.getStarted, value: GetStarted.finished);
      }
    } catch (e) {}
    setState(() {
      showGetStart = false;
    });
    _generateTelemetryTourInteractData(
        contentId: TelemetryIdentifier.tourSkip,
        subType: TelemetrySubType.tour);
    if (widget.returnCallback != null) {
      widget.returnCallback();
    }
  }
}
