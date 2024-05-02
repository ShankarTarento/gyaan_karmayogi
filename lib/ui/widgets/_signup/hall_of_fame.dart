import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/models/_models/hall_of_fame_mdo_model.dart';
import 'package:karmayogi_mobile/services/_services/landing_page_service.dart';
import 'package:karmayogi_mobile/ui/widgets/_signup/hall_of_fame_body_content.dart';
import 'package:karmayogi_mobile/ui/widgets/_signup/hall_of_fame_header_content.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/models/_models/telemetry_event_model.dart';
import 'package:karmayogi_mobile/ui/widgets/index.dart';
import 'package:karmayogi_mobile/util/telemetry.dart';
import 'package:karmayogi_mobile/util/telemetry_db_helper.dart';

class HallOfFameWidget extends StatefulWidget {
  const HallOfFameWidget({Key key}) : super(key: key);

  @override
  State<HallOfFameWidget> createState() => _HallOfFameWidgetState();
}

class _HallOfFameWidgetState extends State<HallOfFameWidget> {
  String userId;
  String userSessionId;
  String messageIdentifier;
  String departmentId;
  String deviceIdentifier;
  var telemetryEventData;

  Future<dynamic> getListOfMdoFuture;

  @override
  void initState() {
    super.initState();
    _generateTelemetryData();
    _getFutureData();
  }

  Future<HallOfFameMdoListModel> _getFutureData() async {
    getListOfMdoFuture = LandingPageService().getListOfMdo();
    return getListOfMdoFuture;
  }

  void _generateTelemetryData() async {
    deviceIdentifier = await Telemetry.getDeviceIdentifier();
    userId = await Telemetry.getUserId();
    userSessionId = await Telemetry.generateUserSessionId();
    messageIdentifier = await Telemetry.generateUserSessionId();
    departmentId = await Telemetry.getUserDeptId();
    Map eventData1 = Telemetry.getImpressionTelemetryEvent(
        deviceIdentifier,
        null,
        null,
        TelemetryPageIdentifier.hallOfFamePageId,
        userSessionId,
        messageIdentifier,
        TelemetryType.viewer,
        TelemetryPageIdentifier.hallOfFamePageUri,
        isPublic: true,
        env: TelemetryEnv.home);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData1);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getListOfMdoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return Column(
            children: [
              HallOfFameHeaderContentWidget(listOfMdo: snapshot.data),
              HallOfFameBodyContentWidget(listOfMdo: snapshot.data)
            ],
          );
        } else {
          return PageLoader();
        }
      },
    );
  }
}
