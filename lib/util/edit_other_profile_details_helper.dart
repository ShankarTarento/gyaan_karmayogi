import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/models/_models/profile_model.dart';
import 'package:karmayogi_mobile/models/_models/profile_other_details.dart';
import 'package:karmayogi_mobile/respositories/_respositories/profile_repository.dart';
import 'package:karmayogi_mobile/services/_services/profile_service.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditOtherProfileDetailshelper {
  static List maritalStatusRadio = [EnglishLang.single, EnglishLang.married];
  static List organizationTypesRadio = [
    EnglishLang.government,
    EnglishLang.nonGovernment
  ];

  static Future<void> saveProfile(
      {@required BuildContext context,
      @required ProfileOtherDetails profileOtherDetails}) async {
    Profile profileDetails =
        Provider.of<ProfileRepository>(context, listen: false).profileDetails;
    var editedEmploymentDetails = getEdittedEmploymentDetails(
        profileDetails: profileDetails,
        profileOtherDetails: profileOtherDetails);
    var editedProfessionalDetails = getEdittedProfessionalDetails(
        profileDetails: profileDetails,
        profileOtherDetails: profileOtherDetails);
    var editedPersonalDetails = getEdittedPersonalDetails(
        profileDetails: profileDetails,
        profileOtherDetails: profileOtherDetails);
    List<Map<dynamic, dynamic>> academics = getAcademicDetails(
        context: context, profileOtherDetails: profileOtherDetails);

    Map payLoad;
    payLoad = {
      'academics': academics,
      'competencies': profileDetails.competencies,
    };
    if (editedProfessionalDetails.isNotEmpty) {
      payLoad['professionalDetails'] = [editedProfessionalDetails];
    }
    if (editedEmploymentDetails.isNotEmpty) {
      payLoad['employmentDetails'] = editedEmploymentDetails;
    }
    if (editedPersonalDetails.isNotEmpty) {
      payLoad['personalDetails'] = editedPersonalDetails;
    }

    var response;
    try {
      response = await ProfileService().updateProfileDetails(payLoad);
      FocusManager.instance.primaryFocus.unfocus();
      if ((response['params']['errmsg'] == null ||
              response['params']['errmsg'] == '') &&
          (response['params']['err'] == null ||
              response['params']['err'] == '')) {
        Helper.showSnackBarMessage(
            context: context,
            text: AppLocalizations.of(context).mEditProfileDetailsUpdated,
            bgColor: AppColors.positiveLight);
        Provider.of<ProfileRepository>(context, listen: false)
            .getInReviewFields();
        Provider.of<ProfileRepository>(context, listen: false)
            .getProfileDetailsById('');
      } else {
        Helper.showSnackBarMessage(
            context: context,
            text: response['params']['errmsg'] != null
                ? response['params']['errmsg']
                : AppLocalizations.of(context).mErrorSavingProfile,
            bgColor: Theme.of(context).colorScheme.error);
      }
    } catch (err) {
      return err;
    }
  }

  static List<Map<dynamic, dynamic>> getAcademicDetails(
      {@required BuildContext context,
      @required ProfileOtherDetails profileOtherDetails}) {
    // List<dynamic> graduationDegreesList =
    //     Provider.of<ProfileRepository>(context, listen: false).graduations;
    // List<dynamic> postGraduationDegreesList =
    //     Provider.of<ProfileRepository>(context, listen: false).postGraduations;
    List<Map<dynamic, dynamic>> academics = [
      {
        'nameOfQualification': '',
        'type': DegreeType.xStandard,
        'nameOfInstitute': profileOtherDetails.schoolName10th,
        'yearOfPassing': profileOtherDetails.yearOfPassing10th
      },
      {
        'nameOfQualification': '',
        'type': DegreeType.xiiStandard,
        'nameOfInstitute': profileOtherDetails.schoolName12th,
        'yearOfPassing': profileOtherDetails.yearOfPassing12th
      }
    ];
    for (int i = 0; i < profileOtherDetails.graduationDegrees.length; i++) {
      // if (profileOtherDetails.graduationDegrees[i]['nameOfQualification'] ==
      //     '') {
      //   profileOtherDetails.graduationDegrees[i]['nameOfQualification'] =
      //       graduationDegreesList[0];
      // }
      if (profileOtherDetails.graduationDegrees[i]['display']) {
        academics.add(profileOtherDetails.graduationDegrees[i]);
      }
    }
    for (int i = 0; i < profileOtherDetails.postGraduationDegrees.length; i++) {
      // if (profileOtherDetails.postGraduationDegrees[i]['nameOfQualification'] ==
      //     '') {
      //   profileOtherDetails.postGraduationDegrees[i]['nameOfQualification'] =
      //       postGraduationDegreesList[0];
      // }
      if (profileOtherDetails.postGraduationDegrees[i]['display']) {
        academics.add(profileOtherDetails.postGraduationDegrees[i]);
      }
    }
    return academics;
  }

  static getEdittedPersonalDetails(
      {Profile profileDetails, ProfileOtherDetails profileOtherDetails}) {
    dynamic fetchedPersonalDetails = profileDetails.personalDetails;
    var personalDetails = [
      {
        'knownLanguages': profileOtherDetails.otherLanguages,
        'isChanged': profileOtherDetails.otherLanguages.toString() !=
            fetchedPersonalDetails['knownLanguages'].toString()
      },
      {
        'telephone': profileOtherDetails.telephoneNo,
        'isChanged': profileOtherDetails.telephoneNo !=
            fetchedPersonalDetails['telephone'].toString()
      },
      {
        'secondaryEmail': profileOtherDetails.secondaryEmail,
        'isChanged': profileOtherDetails.secondaryEmail !=
            fetchedPersonalDetails['secondaryEmail']
      },
      {
        'postalAddress': profileOtherDetails.postalAddress,
        'isChanged': profileOtherDetails.postalAddress !=
            fetchedPersonalDetails['postalAddress']
      },
      {
        'nationality': profileOtherDetails.nationality,
        'isChanged': profileOtherDetails.nationality !=
            fetchedPersonalDetails['nationality']
      },
      {
        'domicileMedium': profileOtherDetails.motherTongue,
        'isChanged': profileOtherDetails.motherTongue !=
            fetchedPersonalDetails['domicileMedium']
      },
      {
        'maritalStatus': profileOtherDetails.maritalStatus,
        'isChanged': profileOtherDetails.motherTongue !=
            fetchedPersonalDetails['maritalStatus']
      }
    ];
    var edited = {};
    var editedPersonalDetails =
        personalDetails.where((data) => data['isChanged'] == true);

    editedPersonalDetails.forEach((element) {
      edited[element.entries.first.key] = element.entries.first.value;
    });
    return edited;
  }

  static getEdittedProfessionalDetails(
      {Profile profileDetails, ProfileOtherDetails profileOtherDetails}) {
    dynamic employmentDetails = profileDetails.employmentDetails;
    var professionalDetails = [
      {
        'organisationType': profileOtherDetails.orgType,
        'isChanged': profileOtherDetails.orgType.toString() !=
            ((profileDetails.experience.length > 0)
                ? profileDetails.experience[0]['organisationType']
                : null)
      },
      {
        'name': profileOtherDetails.orgName,
        'isChanged': profileOtherDetails.orgName !=
            (employmentDetails['departmentName'] != null
                ? employmentDetails['departmentName']
                : '')
      },
      {
        'industry': profileOtherDetails.industry,
        'isChanged': profileOtherDetails.industry !=
            (profileDetails.experience.toString() == [].toString()
                ? ''
                : (profileDetails.experience[0]['industry'] != null
                    ? profileDetails.experience[0]['industry']
                    : ''))
      },
      {
        'location': profileOtherDetails.location,
        'isChanged': profileOtherDetails.location !=
            (profileDetails.experience.toString() == [].toString()
                ? ''
                : (profileDetails.experience[0]['location'] != null
                    ? profileDetails.experience[0]['location']
                    : ''))
      },
      {
        'doj': profileOtherDetails.doj,
        'isChanged': profileOtherDetails.doj.toString() !=
            (profileDetails.experience.toString() == [].toString()
                ? ''
                : (profileDetails.experience[0]['doj'] != null
                    ? profileDetails.experience[0]['doj'].toString()
                    : ''))
      },
      {
        'description': profileOtherDetails.orgDescription,
        'isChanged': profileOtherDetails.orgDescription !=
            (profileDetails.experience.toString() == [].toString()
                ? ''
                : (profileDetails.experience[0]['description'] != null
                    ? profileDetails.experience[0]['description']
                    : ''))
      }
    ];
    var edited = {};
    var editedProfessionalDetails =
        professionalDetails.where((data) => data['isChanged'] == true);

    editedProfessionalDetails.forEach((element) {
      edited[element.entries.first.key] = element.entries.first.value;
    });
    return edited;
  }

  static getEdittedEmploymentDetails(
      {Profile profileDetails, ProfileOtherDetails profileOtherDetails}) {
    dynamic fetchedEmploymentDetails = profileDetails.employmentDetails;
    var employmentDetails = [
      {
        'allotmentYearOfService': profileOtherDetails.allotmentYrOfService,
        'isChanged': profileOtherDetails.allotmentYrOfService.toString() !=
            (fetchedEmploymentDetails['allotmentYearOfService'] != null
                ? fetchedEmploymentDetails['allotmentYearOfService'].toString()
                : '')
      },
      {
        'cadre': profileOtherDetails.cadre,
        'isChanged':
            profileOtherDetails.cadre != fetchedEmploymentDetails['cadre']
      },
      {
        'civilListNo': profileOtherDetails.civilListNo,
        'isChanged': profileOtherDetails.civilListNo.toString() !=
            (fetchedEmploymentDetails['civilListNo'] != null
                ? fetchedEmploymentDetails['civilListNo'].toString()
                : '')
      },
      {
        'dojOfService': profileOtherDetails.dateOfJoiningExp,
        'isChanged': profileOtherDetails.dateOfJoiningExp !=
            (fetchedEmploymentDetails['dojOfService'] != null
                ? fetchedEmploymentDetails['dojOfService'].toString()
                : '')
      },
      {
        'employeeCode': profileOtherDetails.employeeCode,
        'isChanged': profileOtherDetails.employeeCode !=
            (fetchedEmploymentDetails['employeeCode'] != null
                ? fetchedEmploymentDetails['employeeCode'].toString()
                : '')
      },
      {
        'officialPostalAddress': profileOtherDetails.officePostalAddress,
        'isChanged': profileOtherDetails.officePostalAddress !=
            (fetchedEmploymentDetails['officialPostalAddress'] != null
                ? fetchedEmploymentDetails['officialPostalAddress']
                : '')
      },
      {
        'payType': profileOtherDetails.payBand,
        'isChanged': profileOtherDetails.payBand !=
            (fetchedEmploymentDetails['payType'] != null
                ? fetchedEmploymentDetails['payType']
                : '')
      },
      {
        'pinCode': profileOtherDetails.officePinCode,
        'isChanged': profileOtherDetails.officePinCode !=
            (fetchedEmploymentDetails['pinCode'] != null
                ? fetchedEmploymentDetails['pinCode'].toString()
                : '')
      },
    ];
    var edited = {};
    var editedEmploymentDetails =
        employmentDetails.where((data) => data['isChanged'] == true);

    editedEmploymentDetails.forEach((element) {
      edited[element.entries.first.key] = element.entries.first.value;
    });
    return edited;
  }

  static Future<bool> onRemoveDegree(
      {@required BuildContext context,
      @required String degree,
      @required int index,
      @required Function() onTapFn}) {
    return showDialog(
        context: context,
        builder: (ctx) => Stack(
              children: [
                Positioned(
                    child: Align(
                        alignment: FractionalOffset.bottomCenter,
                        child: Container(
                          padding: EdgeInsets.all(20),
                          width: double.infinity,
                          height: 125.0,
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                  padding:
                                      const EdgeInsets.only(top: 5, bottom: 15),
                                  child: Text(
                                    AppLocalizations.of(context)
                                        .mStaticConfirmRemoveText,
                                    style: GoogleFonts.montserrat(
                                        decoration: TextDecoration.none,
                                        color: Colors.black87,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  )),
                              Row(children: [
                                GestureDetector(
                                  onTap: () {
                                    onTapFn();
                                    Navigator.of(ctx).pop(false);
                                  },
                                  child: roundedButton(
                                      context: context,
                                      buttonLabel: AppLocalizations.of(context)
                                          .mStaticYesRemove,
                                      bgColor: Colors.white,
                                      textColor: AppColors.primaryThree),
                                ),
                                Spacer(),
                                GestureDetector(
                                  onTap: () => Navigator.of(ctx).pop(false),
                                  child: roundedButton(
                                      context: context,
                                      buttonLabel: AppLocalizations.of(context)
                                          .mStaticNoBackText,
                                      bgColor: AppColors.primaryThree,
                                      textColor: Colors.white),
                                ),
                              ])
                            ],
                          ),
                        )))
              ],
            ));
  }

  static Widget roundedButton(
      {@required BuildContext context,
      @required String buttonLabel,
      @required Color bgColor,
      @required Color textColor}) {
    var loginBtn = Container(
      width: MediaQuery.of(context).size.width / 2 - 28,
      padding: EdgeInsets.all(10),
      alignment: FractionalOffset.center,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.all(const Radius.circular(4.0)),
        border: bgColor == Colors.white
            ? Border.all(color: AppColors.grey40)
            : Border.all(color: bgColor),
      ),
      child: Text(
        buttonLabel,
        style: GoogleFonts.montserrat(
            decoration: TextDecoration.none,
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w500),
      ),
    );
    return loginBtn;
  }
}
