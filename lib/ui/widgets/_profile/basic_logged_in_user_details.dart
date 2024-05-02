import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/respositories/_respositories/profile_repository.dart';
import 'package:provider/provider.dart';
import '../index.dart';
import './../../../util/helper.dart';
import './../../../constants/index.dart';

class BasicLoggedInUserDetails extends StatelessWidget {
  BasicLoggedInUserDetails();

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileRepository>(
        builder: (context, profileRepository, _) {
      return Column(
        children: <Widget>[
          Container(
              height: 100,
              width: double.infinity,
              padding: EdgeInsets.all(10.0),
              color: AppColors.seaShell,
              child: Center(
                child: profileRepository.profileDetails.profileImageUrl !=
                            null &&
                        profileRepository.profileDetails.profileImageUrl != ''
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(63),
                        child: Image(
                          fit: BoxFit.fitWidth,
                          image: NetworkImage(
                              profileRepository.profileDetails.profileImageUrl),
                          errorBuilder: (context, error, stackTrace) =>
                              SizedBox.shrink(),
                        ),
                      )
                    : Container(
                        height: 90,
                        width: 90,
                        decoration: BoxDecoration(
                          color: AppColors.profilebgGrey,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            Helper.getInitialsNew((profileRepository
                                            .profileDetails.firstName !=
                                        null
                                    ? profileRepository.profileDetails.firstName
                                    : '') +
                                ' ' +
                                (profileRepository.profileDetails.surname !=
                                        null
                                    ? profileRepository.profileDetails.surname
                                    : '')),
                            style: GoogleFonts.lato(
                                color: AppColors.avatarText,
                                fontWeight: FontWeight.w600,
                                fontSize: 24.0),
                          ),
                        ),
                      ),
              )),
          Container(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.topLeft,
                  padding: EdgeInsets.only(bottom: 5),
                  child: Row(
                    children: [
                      Text(
                        profileRepository.profileDetails.firstName != null
                            ? (profileRepository.profileDetails.firstName
                                        .split(' ')
                                        .length ==
                                    2
                                ? Helper.capitalize(
                                    profileRepository.profileDetails.firstName)
                                : Helper.capitalize(
                                    profileRepository.profileDetails.firstName))
                            : '' +
                                ' ' +
                                (profileRepository.profileDetails.surname !=
                                        null
                                    ? Helper.capitalize(profileRepository
                                        .profileDetails.surname)
                                    : ''),
                        style: GoogleFonts.lato(
                          color: AppColors.greys87,
                          fontWeight: FontWeight.w700,
                          fontSize: 16.0,
                          letterSpacing: 0.12,
                        ),
                      ),
                      profileRepository.profileDetails
                                          .rawDetails['profileDetails']
                                      ['verifiedKarmayogi'] !=
                                  null &&
                              profileRepository.profileDetails
                                          .rawDetails['profileDetails']
                                      ['verifiedKarmayogi'] ==
                                  true
                          ? Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Icon(
                                Icons.check_circle,
                                size: 20,
                                color: AppColors.positiveLight,
                              ),
                            )
                          : Center()
                    ],
                  ),
                ),
                profileRepository.profileDetails.rawDetails['rootOrg'] != null
                    ? Container(
                        alignment: Alignment.topLeft,
                        padding: EdgeInsets.only(bottom: 5),
                        child: Text(
                          profileRepository.profileDetails.rawDetails['rootOrg']
                                      ['orgName'] !=
                                  null
                              ? profileRepository.profileDetails
                                  .rawDetails['rootOrg']['orgName']
                              : '',
                          style: GoogleFonts.lato(
                            color: AppColors.greys87.withOpacity(0.5),
                            fontWeight: FontWeight.w400,
                            fontSize: 14.0,
                            letterSpacing: 0.12,
                          ),
                        ))
                    : Center(),
                profileRepository.profileDetails.professionalDetails.length > 0
                    ? profileRepository.profileDetails.designation != null
                        ? Container(
                            alignment: Alignment.topLeft,
                            padding: EdgeInsets.only(bottom: 5),
                            child: Text(
                              (profileRepository.profileDetails.designation) +
                                  (profileRepository.profileDetails
                                              .professionalDetails[0]['name'] !=
                                          null
                                      ? ' at ' +
                                          (profileRepository.profileDetails
                                              .professionalDetails[0]['name'])
                                      : ''),
                              style: GoogleFonts.lato(
                                color: AppColors.greys87,
                                fontWeight: FontWeight.w700,
                                fontSize: 16.0,
                                letterSpacing: 0.12,
                              ),
                            ),
                          )
                        : Center()
                    : Center(),
                profileRepository.profileDetails.experience.length > 0
                    ? (profileRepository.profileDetails.experience[0]
                                ['location']) !=
                            null
                        ? Container(
                            alignment: Alignment.topLeft,
                            padding: EdgeInsets.only(bottom: 5),
                            child: Text(
                              // profileDetails.firstName + ' ' + profileDetails.surname,
                              (profileRepository.profileDetails.experience[0]
                                  ['location']),
                              style: GoogleFonts.lato(
                                color: AppColors.greys87,
                                fontWeight: FontWeight.w700,
                                fontSize: 16.0,
                                letterSpacing: 0.12,
                              ),
                            ),
                          )
                        : Center()
                    : Center(),
                navigateToCompetency(context),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget navigateToCompetency(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, AppUrl.competencyPassbookPage);
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.grey04, width: 1),
            color: AppColors.darkBlueGradient8),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TitleBoldWidget(
              AppLocalizations.of(context).mStaticlearningHistory,
              fontSize: 14,
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.darkBlue,
              size: 16,
            )
          ],
        ),
      ),
    );
  }
}
