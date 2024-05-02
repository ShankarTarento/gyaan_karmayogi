import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/models/_models/profile_mandatory_details_model.dart';
import 'package:karmayogi_mobile/models/_models/registration_group_model.dart';
import 'package:karmayogi_mobile/models/index.dart';
import 'package:karmayogi_mobile/respositories/_respositories/profile_repository.dart';
import 'package:karmayogi_mobile/services/_services/profile_service.dart';
import 'package:karmayogi_mobile/services/_services/registration_service.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/profile/edit_mandatory_details.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:provider/provider.dart';

class EditProfileMandatoryHelper {
  final RegistrationService registrationService = RegistrationService();
  static List genderRadio = [
    EnglishLang.male,
    EnglishLang.female,
    EnglishLang.others
  ];

  static List categoryRadio = [
    EnglishLang.general,
    EnglishLang.obc,
    EnglishLang.sc,
    EnglishLang.st
  ];

  static Future<List<String>> getNationalities(context) async {
    List<Nationality> nationalities =
        await Provider.of<ProfileRepository>(context, listen: false)
            .getNationalities();
    List countryCodes;
    nationalities.map((item) => item.country.toString()).toList();
    countryCodes = nationalities
        .map((item) => item.countryCode.toString())
        .toSet()
        .toList();
    countryCodes.sort();
    return countryCodes;
  }

  static String formatHHMMSS(int seconds) {
    int hours = (seconds / 3600).truncate();
    seconds = (seconds % 3600).truncate();
    int minutes = (seconds / 60).truncate();

    String hoursStr = (hours).toString().padLeft(2, '0');
    String minutesStr = (minutes).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');

    if (hours == 0) {
      return '$minutesStr:$secondsStr';
    }

    return '$hoursStr:$minutesStr:$secondsStr';
  }

  Future<List<RegistrationGroup>> getGroups(context) async {
    List<dynamic> listData =
        await Provider.of<ProfileRepository>(context, listen: false)
            .getGroups();

    int index = 0;
    List<RegistrationGroup> groups = [];
    listData.forEach((item) {
      //UAT input for removing others from list of groups
      if (!item.toString().toLowerCase().contains('others')) {
        groups.insert(index, RegistrationGroup(name: item));
        index++;
      }
    });
    return groups;
  }

  Future<List<dynamic>> getDesignations(context) async {
    List<dynamic> designations =
        await Provider.of<ProfileRepository>(context, listen: false)
            .getDesignations();

    List<dynamic> designationList =
        designations.map((item) => item.toString()).toList();
    return designationList;
  }

  static void fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  static Future<void> saveProfile(
      {@required BuildContext context,
      ProfileMandatoryDetails profileMandatoryDetails}) async {
    Profile profileDetails =
        Provider.of<ProfileRepository>(context, listen: false).profileDetails;
    Map payload;
    var editedPersonalDetails = getEdittedMandatoryPersonalDetails(
        profileDetails: profileDetails,
        profileMandatoryDetails: profileMandatoryDetails);
    var editedProfessionalDetails = getEdittedMandatoryProfessionalDetails(
        profileDetails: profileDetails,
        profileMandatoryDetails: profileMandatoryDetails);
    bool isFilledAllMandatoryFields =
        checkMandatoryFieldsStatus(context, profileDetails);
    if (isFilledAllMandatoryFields) {
      if (isFilledAllMandatoryFields == profileDetails.verifiedKarmayogi) {
        payload = {
          'personalDetails': editedPersonalDetails,
          'academics': profileDetails.education,
          'competencies': profileDetails.competencies,
        };
      } else if (isFilledAllMandatoryFields !=
          profileDetails.verifiedKarmayogi) {
        payload = {
          'personalDetails': editedPersonalDetails,
          'academics': profileDetails.education,
          'competencies': profileDetails.competencies,
          'verifiedKarmayogi': isFilledAllMandatoryFields
        };
      } else {
        payload = {
          'personalDetails': editedPersonalDetails,
          'academics': profileDetails.education,
          'competencies': profileDetails.competencies
        };
      }
      if (editedProfessionalDetails.isNotEmpty) {
        payload['professionalDetails'] = [editedProfessionalDetails];
      }

      var response;
      try {
        response = await ProfileService().updateProfileDetails(payload);
        FocusManager.instance.primaryFocus.unfocus();
        if ((response['params']['errmsg'] == null ||
                response['params']['errmsg'] == '') &&
            (response['params']['err'] == null ||
                response['params']['err'] == '')) {
          Helper.showSnackBarMessage(
              context: context,
              text: 'Profile details updated.',
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
                  : "Error in saving profile details.",
              bgColor: Theme.of(context).colorScheme.error);
        }
      } catch (err) {
        return err;
      }
    }
  }

  static getEdittedMandatoryPersonalDetails(
      {Profile profileDetails,
      ProfileMandatoryDetails profileMandatoryDetails}) {
    dynamic fetchedPersonalDetails = profileDetails.personalDetails;
    var personalDetails = [
      {
        'firstname': profileMandatoryDetails.fullName,
        'isChanged':
            profileMandatoryDetails.fullName != profileDetails.firstName
      },
      {
        'dob': profileMandatoryDetails.dob,
        'isChanged':
            profileMandatoryDetails.dob != fetchedPersonalDetails['dob']
      },
      {
        'gender': profileMandatoryDetails.gender,
        'isChanged':
            profileMandatoryDetails.gender != fetchedPersonalDetails['gender']
      },
      {
        'category': profileMandatoryDetails.category,
        'isChanged': profileMandatoryDetails.category !=
            fetchedPersonalDetails['category']
      },
      {
        'mobile': profileMandatoryDetails.mobile != ''
            ? int.parse(profileMandatoryDetails.mobile)
            : '',
        'isChanged': (profileMandatoryDetails.mobile.toString() !=
                fetchedPersonalDetails['mobile'].toString()) ||
            fetchedPersonalDetails['mobile'].runtimeType == String,
        'phoneVerified': (fetchedPersonalDetails['phoneVerified'] != null
                ? fetchedPersonalDetails['phoneVerified']
                : false) &&
            (profileMandatoryDetails.mobile.toString() ==
                fetchedPersonalDetails['mobile'].toString())
      },
      {
        'phoneVerified': (fetchedPersonalDetails['phoneVerified'] != null
                ? fetchedPersonalDetails['phoneVerified']
                : false) &&
            (profileMandatoryDetails.mobile.toString() ==
                fetchedPersonalDetails['mobile'].toString()),
        'isChanged': profileMandatoryDetails.mobile.toString() !=
            fetchedPersonalDetails['mobile'].toString(),
      },
      {
        'pincode': profileMandatoryDetails.pinCode.toString(),
        'isChanged': profileMandatoryDetails.pinCode.toString() !=
            fetchedPersonalDetails['pincode']
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

  static getEdittedMandatoryProfessionalDetails(
      {Profile profileDetails,
      ProfileMandatoryDetails profileMandatoryDetails}) {
    var personalDetails = [
      {
        'designation': profileMandatoryDetails.position,
        'isChanged':
            profileMandatoryDetails.position != profileDetails.designation
      },
      {
        'group': profileMandatoryDetails.group,
        'isChanged': profileMandatoryDetails.group != profileDetails.group
      },
    ];
    var edited = {};
    var editedProfessionalDetails =
        personalDetails.where((data) => data['isChanged'] == true);

    editedProfessionalDetails.forEach((element) {
      edited[element.entries.first.key] = element.entries.first.value;
    });
    return edited;
  }

  static checkMandatoryFieldsStatus(
    BuildContext context,
    Profile profileDetails,
  ) {
    dynamic fetchedPersonalDetails = profileDetails.personalDetails;
    bool valid = EditMandatoryDetails.mandatoryDetailsGlobalKey.currentState
        .mandatoryDetailsFormKey.currentState
        .validate();
    if (!valid) {
      Helper.showSnackBarMessage(
          context: context,
          text: EnglishLang.pleaseFillAllMandatory,
          bgColor: Theme.of(context).colorScheme.error);
    } else if (valid && !fetchedPersonalDetails['phoneVerified']) {
      Helper.showSnackBarMessage(
          context: context,
          text: EnglishLang.pleaseVerifyYourNumber,
          bgColor: Theme.of(context).colorScheme.error);
    }
    return valid && fetchedPersonalDetails['phoneVerified'];
  }
}
