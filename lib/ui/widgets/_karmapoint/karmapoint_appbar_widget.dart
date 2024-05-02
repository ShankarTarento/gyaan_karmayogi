import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../constants/_constants/storage_constants.dart';
import '../../../constants/_constants/telemetry_constants.dart';
import '../../../constants/index.dart';
import '../../../localization/index.dart';
import '../../../models/index.dart';
import '../../../util/faderoute.dart';
import '../../../util/telemetry.dart';
import '../../../util/telemetry_db_helper.dart';
import '../index.dart';

class KarmaPointAppbarWidget extends StatelessWidget {
  final profileParentAction;

  KarmaPointAppbarWidget({this.profileParentAction});

  Future<dynamic> getEnrolmentInfo() async {
    String enrolmentList =
        await FlutterSecureStorage().read(key: Storage.userCourseEnrolmentInfo);
    return jsonDecode(enrolmentList);
  }

  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getEnrolmentInfo(),
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.only(top: 6, right: 8),
              child: GestureDetector(
                onTap: () async {
                  await _generateInteractTelemetryData(EnglishLang.karmaPoints);
                  Navigator.push(
                    context,
                    FadeRoute(
                      page: KarmaPointOverview(),
                    ),
                  );
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 6,
                      ),
                      child: SvgPicture.asset(
                        'assets/img/kp_icon.svg',
                        width: 32,
                        height: 32,
                      ),
                    ),
                    SizedBox(width: 4),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 65,
                              child: TitleBoldWidget(
                                AppLocalizations.of(context).mStaticKarmaPoints,
                                fontSize: 10,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 4, top: 4),
                              child: TooltipWidget(
                                  message: AppLocalizations.of(context)
                                      .mStaticKarmapointAppbarInfo),
                            )
                          ],
                        ),
                        TitleBoldWidget(
                          snapshot.data != null
                              ? snapshot.data['karmaPoints'].toString()
                              : '',
                          fontSize: 14,
                          letterSpacing: 0.25,
                          color: AppColors.darkBlue,
                        )
                      ],
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Center();
          }
        });
  }

  Future<void> _generateInteractTelemetryData(String contentId) async {
    String deviceIdentifier = await Telemetry.getDeviceIdentifier();
    String userId = await Telemetry.getUserId();
    String userSessionId = await Telemetry.generateUserSessionId();
    String messageIdentifier = await Telemetry.generateUserSessionId();
    String departmentId = await Telemetry.getUserDeptId();
    Map eventData = Telemetry.getInteractTelemetryEvent(
        deviceIdentifier,
        userId,
        departmentId,
        TelemetryPageIdentifier.karmaPointPageId,
        userSessionId,
        messageIdentifier,
        contentId,
        TelemetrySubType.karmaPoints,
        env: TelemetryEnv.home,
        objectType: TelemetrySubType.karmaPoints);
    var telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());
  }
}
