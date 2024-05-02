import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/respositories/_respositories/profile_repository.dart';
import 'package:karmayogi_mobile/ui/widgets/custom_tabs.dart';
import 'package:karmayogi_mobile/util/telemetry.dart';
import 'package:karmayogi_mobile/util/telemetry_db_helper.dart';
import 'package:provider/provider.dart';

import '../../../constants/index.dart';
import '../../../models/index.dart';
import '../../../util/faderoute.dart';
import '../../../util/helper.dart';
import '../../screens/index.dart';

class ProfilePicture extends StatefulWidget {
  final Profile profileDetails;
  final profileParentAction;
  final bool isFromDrawer;

  ProfilePicture(this.profileDetails,
      {this.profileParentAction, this.isFromDrawer = false});

  @override
  State<ProfilePicture> createState() => _ProfilePictureState();
}

class _ProfilePictureState extends State<ProfilePicture> {
  String userId;
  String userSessionId;
  String messageIdentifier;
  String departmentId;
  String deviceIdentifier;
  var telemetryEventData;

  void _generateInteractTelemetryData(String contentId) async {
    deviceIdentifier = await Telemetry.getDeviceIdentifier();
    userId = await Telemetry.getUserId();
    userSessionId = await Telemetry.generateUserSessionId();
    messageIdentifier = await Telemetry.generateUserSessionId();
    departmentId = await Telemetry.getUserDeptId();
    Map eventData = Telemetry.getInteractTelemetryEvent(
        deviceIdentifier,
        userId,
        departmentId,
        TelemetryPageIdentifier.homePageId,
        userSessionId,
        messageIdentifier,
        contentId,
        TelemetrySubType.profile.toLowerCase(),
        env: TelemetryEnv.home);
    // print(jsonEncode(eventData));
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileRepository>(
        builder: (context, profileRepository, _) {
      return InkWell(
        onTap: () {
          if (widget.isFromDrawer) {
            Navigator.push(
              context,
              FadeRoute(
                page: ProfileScreen(
                    profileParentAction: widget.profileParentAction),
              ),
            );
          } else {
            _generateInteractTelemetryData(TelemetryIdentifier.profileIcon);
            drawerKey.currentState.openDrawer();
          }
        },
        child: profileRepository.profileDetails != null
            ? Stack(
                alignment: Alignment.center,
                children: [
                  profileRepository.profileDetails.profileImageUrl != ''
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(63),
                          child: Container(
                            height: widget.isFromDrawer ? 52 : 32,
                            width: widget.isFromDrawer ? 52 : 32,
                            color: AppColors.grey04,
                            child: Image(
                              height: widget.isFromDrawer ? 52 : 32,
                              width: widget.isFromDrawer ? 52 : 32,
                              fit: BoxFit.fitWidth,
                              image: NetworkImage(profileRepository
                                  .profileDetails.profileImageUrl),
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                height: widget.isFromDrawer ? 52 : 32,
                                width: widget.isFromDrawer ? 52 : 32,
                                color: AppColors.grey04,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          height: widget.isFromDrawer ? 52 : 32,
                          width: widget.isFromDrawer ? 52 : 32,
                          decoration: BoxDecoration(
                            color: AppColors.profilebgGrey,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              Helper.getInitialsNew((profileRepository
                                              .profileDetails.firstName !=
                                          null
                                      ? profileRepository
                                          .profileDetails.firstName
                                      : '') +
                                  ' ' +
                                  (profileRepository.profileDetails.surname !=
                                          null
                                      ? profileRepository.profileDetails.surname
                                      : '')),
                              style: GoogleFonts.lato(
                                  color: AppColors.avatarText,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.0),
                            ),
                          ),
                        ),
                  profileRepository.profileDetails.verifiedKarmayogi
                      ? Positioned(
                          bottom: 0,
                          right: 0,
                          child: Center(
                            child: CircleAvatar(
                              backgroundColor: AppColors.positiveLight,
                              radius: 5.0,
                              child: SvgPicture.asset(
                                'assets/img/approved.svg',
                                width: 10.0,
                                height: 10.0,
                              ),
                            ),
                          ),
                        )
                      : Center()
                ],
              )
            : SizedBox.shrink(),
      );
    });
  }
}
