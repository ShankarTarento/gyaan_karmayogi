import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../constants/_constants/telemetry_constants.dart';
import '../../../../constants/index.dart';
import '../../../../localization/_langs/english_lang.dart';
import '../../../../models/_arguments/index.dart';
import '../../../../models/index.dart';
import '../../../../util/telemetry.dart';
import '../../../../util/telemetry_db_helper.dart';
import '../../index.dart';

class FilteredCourseViewWidget extends StatelessWidget {
  FilteredCourseViewWidget({Key key, @required this.filteredListOfCourses})
      : super(key: key);

  final List<Course> filteredListOfCourses;

  void _generateInteractTelemetryData(String contentId, String env,
      {String subType = '', String primaryCategory}) async {
    String deviceIdentifier = await Telemetry.getDeviceIdentifier();
    String userId = await Telemetry.getUserId();
    String userSessionId = await Telemetry.generateUserSessionId();
    String messageIdentifier = await Telemetry.generateUserSessionId();
    String departmentId = await Telemetry.getUserDeptId();
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
        objectType: primaryCategory != null ? primaryCategory : subType);
    // allEventsData.add(eventData);
    var telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());
  }

  @override
  Widget build(BuildContext context) {
    return filteredListOfCourses.length > 0
        ? ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: filteredListOfCourses.length,
            itemBuilder: (context, index) {
              return InkWell(
                  onTap: () async {
                    _generateInteractTelemetryData(
                        filteredListOfCourses[index].id,
                        filteredListOfCourses[index].contentType);
                    Navigator.pushNamed(context, AppUrl.courseTocPage,
                        arguments: CourseTocModel.fromJson(
                            {'courseId': filteredListOfCourses[index].id}));
                  },
                  child: CbpCourseCard(course: filteredListOfCourses[index]));
            })
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: SvgPicture.asset(
                  'assets/img/search-empty.svg',
                  height: 100,
                  width: 180,
                ),
              ),
              Text(
                '${AppLocalizations.of(context).mStaticAdjustSearch}',
                style: GoogleFonts.lato(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.greys87),
                maxLines: 2,
                textAlign: TextAlign.center,
              )
            ],
          );
  }
}
