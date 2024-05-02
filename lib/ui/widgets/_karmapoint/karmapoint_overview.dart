import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../constants/_constants/telemetry_constants.dart';
import '../../../constants/index.dart';
import '../../../localization/index.dart';
import '../../../models/index.dart';
import '../../../respositories/_respositories/profile_repository.dart';
import '../../../util/telemetry.dart';
import '../../../util/telemetry_db_helper.dart';
import '../index.dart';

class KarmaPointOverview extends StatefulWidget {
  final Map<dynamic, dynamic> karmaPointList;

  const KarmaPointOverview({Key key, this.karmaPointList}) : super(key: key);
  KarmaPointOverviewState createState() => KarmaPointOverviewState();
}

class KarmaPointOverviewState extends State<KarmaPointOverview> {
  List karmaPointList = [];
  int count = 0;
  Future<Map<dynamic, dynamic>> karmaPointsFuture;
  ScrollController _scrollController = ScrollController();
  String userId;
  String userSessionId;
  String messageIdentifier;
  String departmentId;
  String pageIdentifier;
  String telemetryType;
  String pageUri;
  List allEventsData = [];
  String deviceIdentifier;
  var telemetryEventData;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    if (widget.karmaPointList == null) {
      getKarmaPointsHistory(
          limit: KARMAPOINT_READ_LIMIT,
          offset: DateTime.now().millisecondsSinceEpoch);
    } else {
      karmaPointList = widget.karmaPointList['kpList'];
      count = widget.karmaPointList['count'];
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      getKarmaPointsHistory(
          limit: count > KARMAPOINT_READ_LIMIT ? KARMAPOINT_READ_LIMIT : count,
          offset: DateTime.now().millisecondsSinceEpoch);
    }
  }

  Future<void> getKarmaPointsHistory({limit, offset}) async {
    _generateTelemetryData();
    var response = await Provider.of<ProfileRepository>(context, listen: false)
        .getKarmaPointHistory(limit: limit, offset: offset);
    setState(() {
      count = response['count'];
      response['kpList'].forEach((newitem) {
        bool isPontInList = false;
        karmaPointList.forEach((kpItem) {
          if ((newitem['operation_type'] == kpItem['operation_type'] &&
                  newitem['context_id'] == kpItem['context_id']) ||
              (newitem['operation_type'] == kpItem['operation_type'] &&
                  kpItem['operation_type'] == OperationTypes.firstLogin)) {
            isPontInList = true;
          }
        });
        if (!isPontInList) {
          karmaPointList.add(newitem);
        }
      });
    });
    print(karmaPointList);
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
        TelemetryPageIdentifier.karmaPointOverviewPageId,
        userSessionId,
        messageIdentifier,
        TelemetryType.page,
        TelemetryPageIdentifier.karmaPointOverviewPageUri,
        env: TelemetryEnv.profile,
        subType: TelemetrySubType.scroll);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData1);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll
                .disallowIndicator(); //previous code overscroll.disallowGlow();
            return true;
          },
          child: NotificationListener<ScrollNotification>(
              // ignore: missing_return
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo.metrics.pixels ==
                    scrollInfo.metrics.maxScrollExtent) {
                  if (count > karmaPointList.length) {
                    int listLengthDiff = count - karmaPointList.length;
                    getKarmaPointsHistory(
                        limit: listLengthDiff > KARMAPOINT_READ_LIMIT
                            ? KARMAPOINT_READ_LIMIT
                            : listLengthDiff,
                        offset: karmaPointList[karmaPointList.length - 1]
                            ['credit_date']);
                  }
                }
              },
              child: SingleChildScrollView(
                child: Container(
                  color: AppColors.scaffoldBackground,
                  child: Column(
                    children: [
                      Container(
                          alignment: Alignment.topLeft,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 25, left: 16, bottom: 10),
                                child: Text(
                                  AppLocalizations.of(context)
                                      .mStaticKarmaPoints,
                                  style: GoogleFonts.lato(
                                    color: AppColors.greys87,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    letterSpacing: 0.12,
                                  ),
                                ),
                              ),
                              Padding(
                                  padding:
                                      const EdgeInsets.only(right: 10, top: 15),
                                  child: TooltipWidget(
                                      message: AppLocalizations.of(context)
                                          .mStaticKarmaPointInfo,
                                      iconSize: 20,
                                      triggerMode: TooltipTriggerMode.tap))
                            ],
                          )),
                      ListView.builder(
                        controller: _scrollController,
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: karmaPointList.length,
                        itemBuilder: (BuildContext context, int index) {
                          Map kpItem = karmaPointList[index];
                          return count > karmaPointList.length &&
                                  index == karmaPointList.length
                              ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    KarmapointCard(kpItem: kpItem),
                                    SizedBox(
                                        height: 50,
                                        width: 50,
                                        child: PageLoader())
                                  ],
                                )
                              : KarmapointCard(kpItem: kpItem);
                        },
                      ),
                      SizedBox(
                        height: 48,
                      )
                    ],
                  ),
                ),
              ))),
    );
  }
}
