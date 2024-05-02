import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/storage_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/respositories/_respositories/landing_page_repository.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:karmayogi_mobile/util/telemetry.dart';
import 'package:karmayogi_mobile/util/telemetry_db_helper.dart';
import 'package:provider/provider.dart';
import '../../../constants/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../models/index.dart';
import '../../../util/faderoute.dart';
import '../../screens/index.dart';
import '../_activities/_leaderboard/leaderboard_title_widget.dart';
import '../index.dart';

class MyactivityCard extends StatelessWidget {
  final Profile profileDetails;
  final userCourseEnrolmentInfo;
  final weeklyClaps;
  final String leaderboardRank;

  const MyactivityCard(
      {Key key,
      this.profileDetails,
      this.userCourseEnrolmentInfo,
      this.weeklyClaps,
      this.leaderboardRank})
      : super(key: key);

  Future<String> _fetchProfileCompletionPercentage() async {
    var profilePercentage = await FlutterSecureStorage()
        .read(key: Storage.profileCompletionPercentage); // return your response
    return profilePercentage;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: _fetchProfileCompletionPercentage(), // async work
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          var profilePercentage = 0;
          if (snapshot.hasData) profilePercentage = int.parse(snapshot.data);

          return Container(
            margin: EdgeInsets.fromLTRB(17, 16, 17, 16).w,
            decoration: BoxDecoration(
              color: AppColors.grey08,
              borderRadius: BorderRadius.circular(12.0).w,
            ),
            child: Column(
              children: [
                Container(
                  width: 1.sw,
                  decoration: BoxDecoration(
                    color: AppColors.appBarBackground,
                    borderRadius: BorderRadius.circular(12.0).w,
                  ),
                  child: Consumer<LandingPageRepository>(
                      builder: (context, landingPageRepository, _) {
                    return ExpansionTile(
                      onExpansionChanged: (value) async {
                        Provider.of<LandingPageRepository>(context,
                                listen: false)
                            .changeExpansionProfileCard(value);
                      },
                      title: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                            profileDetails.firstName != null
                                ? '${AppLocalizations.of(context).mCommonHey} ' +
                                    Helper().capitalizeFirstCharacter(
                                        profileDetails.firstName) +
                                    '!'
                                : '${AppLocalizations.of(context).mCommonHey}, ',
                            style: GoogleFonts.lato(
                              color: AppColors.greys87,
                              fontWeight: FontWeight.w700,
                              fontSize: 16.sp,
                              letterSpacing: 0.12.sp,
                            )),
                      ),
                      iconColor: AppColors.darkBlue,
                      collapsedIconColor: AppColors.darkBlue,
                      initiallyExpanded:
                          landingPageRepository.isProfileCardExpanded,
                      childrenPadding: EdgeInsets.fromLTRB(15.5, 0, 15.5, 0).w,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 69.w,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5).w,
                                child: LinearProgressIndicator(
                                  minHeight: 4.w,
                                  backgroundColor: AppColors.grey16,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.lightGreen,
                                  ),
                                  value: profilePercentage / 100,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            InkWell(
                              onTap: () {
                                _generateInteractTelemetryData(null,
                                    edataId: TelemetryIdentifier
                                        .profileUpdateProgress);
                                Navigator.push(
                                  context,
                                  FadeRoute(page: EditProfileScreen()),
                                );
                              },
                              child: TitleRegularGrey60(
                                AppLocalizations.of(context)
                                    .mCommonProfileIsComplete(
                                        profilePercentage),
                                maxLines: 2,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Icon(
                              Icons.keyboard_arrow_right,
                              size: 12.w,
                              color: AppColors.profilebgGrey,
                            )
                          ],
                        ),
                        Divider(
                          color: AppColors.grey08,
                          thickness: 1,
                        ),
                        SizedBox(height: 15.5.w),
                        YourStats(
                            userCourseEnrolmentInfo != null
                                ? userCourseEnrolmentInfo['coursesInProgress']
                                : 0,
                            userCourseEnrolmentInfo != null
                                ? userCourseEnrolmentInfo['certificatesIssued']
                                : 0,
                            Helper.getTimeFormat(userCourseEnrolmentInfo != null
                                ? userCourseEnrolmentInfo[
                                        'timeSpentOnCompletedCourses']
                                    .toString()
                                : '0'),
                            userCourseEnrolmentInfo != null
                                ? userCourseEnrolmentInfo['karmaPoints']
                                : 0),
                        SizedBox(height: 15.5.w),
                        Divider(
                          color: AppColors.grey08,
                          thickness: 1,
                        ),
                        /** Leaderboard changes start**/
                        IntrinsicHeight(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (leaderboardRank != '')
                                Expanded(
                                  child: LeaderboardTitleWidget(
                                      rank: leaderboardRank),
                                ),
                              if (leaderboardRank != '')
                                VerticalDivider(
                                  color: AppColors.grey08,
                                  thickness: 1,
                                ),
                              Expanded(
                                child: WeeklyclapTitleWidget(
                                    weeklyClaps: weeklyClaps.isNotEmpty
                                        ? weeklyClaps
                                        : {},
                                    showInRow:
                                        (leaderboardRank != '') ? false : true,
                                    enableNavigationForWeeklyClaps: true),
                              ),
                            ],
                          ),
                        ),
                        /** Leaderboard changes end**/
                        SizedBox(height: 8.w),
                      ],
                    );
                  }),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 8).w,
                  decoration: BoxDecoration(
                      // color: AppColors.grey08,
                      borderRadius:
                          BorderRadius.vertical(bottom: Radius.circular(12))),
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      FadeRoute(
                        page: ProfileScreen(showMyActivity: true),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/img/activity_icon.svg',
                              width: 24.w,
                              height: 24.w,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                                AppLocalizations.of(context)
                                    .mStaticShowMyActivities,
                                style: GoogleFonts.lato(
                                  color: AppColors.darkBlue,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14.sp,
                                  letterSpacing: 0.12.sp,
                                )),
                          ],
                        ),
                        SvgPicture.asset(
                          'assets/img/arrow_forward_blue.svg',
                          width: 24.w,
                          height: 24.w,
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
        });
  }

  void _generateInteractTelemetryData(String contentId,
      {String subType = '', String edataId}) async {
    String deviceIdentifier = await Telemetry.getDeviceIdentifier();
    String userId = await Telemetry.getUserId();
    String userSessionId = await Telemetry.generateUserSessionId();
    String messageIdentifier = await Telemetry.generateUserSessionId();
    String departmentId = await Telemetry.getUserDeptId();
    var telemetryEventData;
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
        clickId: edataId);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());
  }
}
