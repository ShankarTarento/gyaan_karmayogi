import 'package:karmayogi_mobile/util/telemetry.dart';

import '../../../../../constants/_constants/telemetry_constants.dart';
import '../../../../../models/_models/telemetry_event_model.dart';
import '../../../../../util/telemetry_db_helper.dart';

class GyaanKarmayogiTelemetry {
  void generateImpressionTelemetryData(
      {String pageIdentifier, String pageUri}) async {
    String deviceIdentifier = await Telemetry.getDeviceIdentifier();
    String userId = await Telemetry.getUserId(isPublic: false);
    String userSessionId = await Telemetry.generateUserSessionId();
    String messageIdentifier = await Telemetry.generateUserSessionId();
    String departmentId = await Telemetry.getUserDeptId(isPublic: false);
    var telemetryEventData;
    Map eventData1 = Telemetry.getImpressionTelemetryEvent(
        deviceIdentifier,
        userId,
        departmentId,
        pageIdentifier,
        userSessionId,
        messageIdentifier,
        TelemetryType.viewer,
        pageUri,
        env: "Gyaan Karmayogi",
        isPublic: false);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData1);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap(),
        isPublic: false);
  }

  void generateInteractTelemetryData(
      {String contentId, String subType = '', String pageIdentifier}) async {
    List allEventsData = [];
    var telemetryEventData;

    String deviceIdentifier = await Telemetry.getDeviceIdentifier();
    String userId = await Telemetry.getUserId(isPublic: false);
    String userSessionId = await Telemetry.generateUserSessionId();
    String messageIdentifier = await Telemetry.generateUserSessionId();
    String departmentId = await Telemetry.getUserDeptId(isPublic: false);
    Map eventData = Telemetry.getInteractTelemetryEvent(
        deviceIdentifier,
        userId,
        departmentId,
        pageIdentifier,
        userSessionId,
        messageIdentifier,
        contentId,
        subType,
        env: "Gyaan Karmayogi",
        objectType: subType);
    allEventsData.add(eventData);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());
  }

  void triggerStartTelemetryEvent(
      {String pageIdentifier, String pageUri}) async {
    var telemetryEventData;

    List allEventsData = [];

    String deviceIdentifier = await Telemetry.getDeviceIdentifier();
    String userId = await Telemetry.getUserId(isPublic: false);
    String userSessionId = await Telemetry.generateUserSessionId();
    String messageIdentifier = await Telemetry.generateUserSessionId();
    String departmentId = await Telemetry.getUserDeptId(isPublic: false);

    Map eventData = Telemetry.getStartTelemetryEvent(
        deviceIdentifier,
        userId,
        departmentId,
        pageIdentifier,
        userSessionId,
        messageIdentifier,
        TelemetryType.page,
        pageUri,
        env: "Gyaan Karmayogi");
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());

    allEventsData.add(eventData);
  }

  Future<void> triggerEndTelemetryEvent(
      {time, String pageUrl, String pageIdentifier}) async {
    List allEventsData = [];
    var telemetryEventData;

    String deviceIdentifier = await Telemetry.getDeviceIdentifier();
    String userId = await Telemetry.getUserId(isPublic: false);
    String userSessionId = await Telemetry.generateUserSessionId();
    String messageIdentifier = await Telemetry.generateUserSessionId();
    String departmentId = await Telemetry.getUserDeptId(isPublic: false);
    Map eventData = Telemetry.getEndTelemetryEvent(
        deviceIdentifier,
        userId,
        departmentId,
        pageIdentifier,
        userSessionId,
        messageIdentifier,
        time * 1000,
        TelemetryType.page,
        pageUrl,
        {},
        env: "Gyaan Karmayogi");
    allEventsData.add(eventData);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());
  }
}
