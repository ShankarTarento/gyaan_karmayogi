import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/models/_models/telemetry_event_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_network/follow_us_social_media.dart';
import 'package:karmayogi_mobile/util/telemetry.dart';
import 'package:karmayogi_mobile/util/telemetry_db_helper.dart';
import './../../../ui/screens/index.dart';
import '../../../constants/index.dart';
import '../../widgets/index.dart';
import './../../../util/faderoute.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HubPage extends StatefulWidget {
  final int tabIndex;

  const HubPage({Key key, this.tabIndex}) : super(key: key);
  @override
  State<HubPage> createState() => _HubPageState();
}

class _HubPageState extends State<HubPage> {
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
    if (widget.tabIndex == 1) {
      _generateImpressionTelemetryData();
    }
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
        TelemetryType.app,
        TelemetryPageIdentifier.homePageUri,
        env: TelemetryEnv.home);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData1);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());
  }

  void _generateInteractTelemetryData(
      {String contentId, String subType}) async {
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
    );
    // allEventsData.add(eventData);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: AppColors.whiteGradientOne,
        child: Column(
          children: <Widget>[
            Container(
              alignment: Alignment.topLeft,
              child: SectionHeading(AppLocalizations.of(context).mCommonHubs),
            ),
            Container(
              margin: EdgeInsets.only(left: 5.0, right: 5.0),
              // padding: const EdgeInsets.fromLTRB(0, 20, 0 , 10),
              child: AnimationLimiter(
                child: Column(
                  children: HUBS(context: context)
                      .map(
                        (hub) => AnimationConfiguration.staggeredList(
                          position: HUBS(context: context).indexOf(hub),
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: InkWell(
                                  onTap: () {
                                    _generateInteractTelemetryData(
                                        contentId: hub.telemetryId,
                                        subType: TelemetrySubType.hubMenu);
                                    hub.comingSoon
                                        ? Navigator.push(
                                            context,
                                            FadeRoute(page: ComingSoonScreen()),
                                          )
                                        : Navigator.pushNamed(context, hub.url);
                                  },
                                  child: HubItem(
                                      hub.id,
                                      hub.title,
                                      hub.description,
                                      hub.icon,
                                      hub.iconColor,
                                      hub.comingSoon,
                                      hub.url,
                                      hub.svgIcon,
                                      hub.svg)),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            Container(
              alignment: Alignment.topLeft,
              child: SectionHeading(AppLocalizations.of(context).mStaticDoMore),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
              child: Column(
                children: DO_MORE(context: context)
                    .map(
                      (hub) => InkWell(
                          onTap: () {
                            _generateInteractTelemetryData(
                                contentId: hub.telemetryId,
                                subType: TelemetrySubType.hubMenu);
                            hub.comingSoon
                                ? Navigator.push(
                                    context,
                                    FadeRoute(page: ComingSoonScreen()),
                                  )
                                : Navigator.pushNamed(context, hub.url);
                          },
                          child: HubItem(
                            hub.id,
                            hub.title,
                            hub.description,
                            hub.icon,
                            hub.iconColor,
                            hub.comingSoon,
                            hub.url,
                            hub.svgIcon,
                            hub.svg,
                            isDoMore: true,
                          )),
                    )
                    .toList(),
              ),
            ),
            Container(
              alignment: Alignment.topLeft,
              child: SectionHeading(
                  AppLocalizations.of(context).mStaticComingSoon),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
              child: Column(
                children: COMING_SOON(context: context)
                    .map(
                      (hub) => InkWell(
                          onTap: () => hub.comingSoon
                              ? null
                              : Navigator.pushNamed(context, hub.url),
                          child: HubItem(
                              hub.id,
                              hub.title,
                              hub.description,
                              hub.icon,
                              hub.iconColor,
                              hub.comingSoon,
                              hub.url,
                              hub.svgIcon,
                              hub.svg)),
                    )
                    .toList(),
              ),
            ),
            FollowUsOnSocialMedia(),
            // Container(
            //   alignment: Alignment.topLeft,
            //   child: SectionHeading(EnglishLang.externalLinks),
            // ),
            // Container(
            //   padding: const EdgeInsets.fromLTRB(5, 5, 5, 20),
            //   child: Column(
            //     children: EXTERNAL_LINKS
            //         .map(
            //           (hub) => InkWell(
            //               onTap: () {
            //                 if (hub.url != '') {
            //                   _launchURL(hub.url);
            //                 }
            //               },
            //               child: OtherItem(hub.id, hub.title, hub.description,
            //                   hub.icon, hub.iconColor, hub.url)),
            //         )
            //         .toList(),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
