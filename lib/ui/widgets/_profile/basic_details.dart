import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants/_constants/storage_constants.dart';
import '../index.dart';
import './../../../util/helper.dart';
import './../../../constants/index.dart';
import './../../../models/index.dart';
// import 'dart:developer' as developer;

class BasicDetails extends StatelessWidget {
  final Profile profileDetails;
  final bool isLoggedUser;
  final _storage = FlutterSecureStorage();

  BasicDetails(this.profileDetails, {this.isLoggedUser = false});

  @override
  Widget build(BuildContext context) {
    String profileImageUrl;
    Future<void> getProfileImageUrl() async {
      if (isLoggedUser) {
        profileImageUrl = await _storage.read(key: Storage.profileImageUrl);
      }
    }

    return FutureBuilder(
        future: getProfileImageUrl(),
        builder: (BuildContext context, snapshot) {
          return Column(
            children: <Widget>[
              Container(
                  height: 100,
                  width: double.infinity,
                  padding: EdgeInsets.all(10.0),
                  color: AppColors.seaShell,
                  child: Center(
                    child: profileImageUrl != null && profileImageUrl != ''
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(63),
                            child: Image(
                              // height: 100,
                              // width: double.infinity,
                              fit: BoxFit.fitWidth,
                              image: NetworkImage(profileImageUrl != null
                                  ? profileImageUrl
                                  : profileDetails.profileImageUrl),
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
                                Helper.getInitialsNew(
                                    (profileDetails.firstName != null
                                            ? profileDetails.firstName
                                            : '') +
                                        ' ' +
                                        (profileDetails.surname != null
                                            ? profileDetails.surname
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
                // margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  // border: Border.all(color: AppColors.grey08),
                  // borderRadius: BorderRadius.all(
                  //   Radius.circular(4),
                  // ),
                ),
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.topLeft,
                      padding: EdgeInsets.only(bottom: 5),
                      child: Row(
                        children: [
                          Text(
                            profileDetails.firstName != null
                                ? (profileDetails.firstName.split(' ').length ==
                                        2
                                    ? Helper.capitalize(
                                        profileDetails.firstName)
                                    : Helper.capitalize(
                                        profileDetails.firstName))
                                : '' +
                                    ' ' +
                                    (profileDetails.surname != null
                                        ? Helper.capitalize(
                                            profileDetails.surname)
                                        : ''),
                            style: GoogleFonts.lato(
                              color: AppColors.greys87,
                              fontWeight: FontWeight.w700,
                              fontSize: 16.0,
                              letterSpacing: 0.12,
                            ),
                          ),
                          profileDetails.rawDetails['profileDetails']
                                          ['verifiedKarmayogi'] !=
                                      null &&
                                  profileDetails.rawDetails['profileDetails']
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
                    profileDetails.rawDetails['rootOrg'] != null
                        ? Container(
                            alignment: Alignment.topLeft,
                            padding: EdgeInsets.only(bottom: 5),
                            child: Text(
                              profileDetails.rawDetails['rootOrg']['orgName'] !=
                                      null
                                  ? profileDetails.rawDetails['rootOrg']
                                      ['orgName']
                                  : '',
                              style: GoogleFonts.lato(
                                color: AppColors.greys87.withOpacity(0.5),
                                fontWeight: FontWeight.w400,
                                fontSize: 14.0,
                                letterSpacing: 0.12,
                              ),
                            ))
                        : Center(),
                    profileDetails.professionalDetails.length > 0
                        ? profileDetails.designation != null
                            ? Container(
                                alignment: Alignment.topLeft,
                                padding: EdgeInsets.only(bottom: 5),
                                child: Text(
                                  // profileDetails.firstName + ' ' + profileDetails.surname,
                                  (profileDetails.designation) +
                                      (profileDetails.professionalDetails[0]
                                                  ['name'] !=
                                              null
                                          ? ' at ' +
                                              (profileDetails
                                                      .professionalDetails[0]
                                                  ['name'])
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
                    profileDetails.experience.length > 0
                        ? (profileDetails.experience[0]['location']) != null
                            ? Container(
                                alignment: Alignment.topLeft,
                                padding: EdgeInsets.only(bottom: 5),
                                child: Text(
                                  // profileDetails.firstName + ' ' + profileDetails.surname,
                                  (profileDetails.experience[0]['location']),
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
                    // Container(
                    //   alignment: Alignment.topLeft,
                    //   child: Text(
                    //     (profileDetails.designation != null
                    //             ? profileDetails.designation
                    //             : '') +
                    //         (profileDetails.department != '' ? ' at ' : '') +
                    //         profileDetails.department +
                    //         '\n' +
                    //         profileDetails.location,
                    //     style: GoogleFonts.lato(
                    //       color: AppColors.greys87,
                    //       fontSize: 14,
                    //       height: 1.5,
                    //       fontWeight: FontWeight.w400,
                    //       letterSpacing: 0.25,
                    //     ),
                    //   ),
                    // ),
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
