import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Validations {
  static validateFullName({@required BuildContext context, String value}) {
    if (value.isEmpty) {
      return EnglishLang.fullNameMandatory;
    } else if (!RegExp(r"^[a-zA-Z' ]+$").hasMatch(value)) {
      return AppLocalizations.of(context).mProfileFullNameWithConditions;
    } else
      return null;
  }

  static validatePrimaryEmail({@required BuildContext context, String value}) {
    RegExp regExp = RegExp(
        r"[a-z0-9_-]+(?:\.[a-z0-9_-]+)*@((?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?){2,}\.){1,3}(?:\w){2,}");
    if (value.isEmpty) {
      return AppLocalizations.of(context).mProfilePrimaryEmailMandatory;
      // EnglishLang.firstNameMandatory
      //     .replaceAll(EnglishLang.firstName, EnglishLang.primaryEmail);
    }
    String matchedString = regExp.stringMatch(value);
    if (matchedString == null ||
        matchedString.isEmpty ||
        matchedString.length != value.length) {
      return AppLocalizations.of(context).mStaticEmailValidationText;
    }
    return null;
  }

  static bool isValidEmail({@required BuildContext context, String value}) {
    bool isValid = false;
    RegExp regExp = RegExp(
        r"[a-z0-9_-]+(?:\.[a-z0-9_-]+)*@((?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?){2,}\.){1,3}(?:\w){2,}");

    String matchedString = regExp.stringMatch(value);
    if (matchedString == null ||
        matchedString.isEmpty ||
        matchedString.length != value.length) {
      isValid = false;
    } else {
      isValid = true;
    }
    return isValid;
  }

  static validatePinCode({@required BuildContext context, String value}) {
    if (value.isEmpty) {
      return EnglishLang.firstNameMandatory
          .replaceAll(EnglishLang.firstName, EnglishLang.pinCode);
    } else if (value.length != 6 || !RegExp(r'^[0-9]+$').hasMatch(value)) {
      return AppLocalizations.of(context).mProfilePinLength;
    } else
      return null;
  }

  static validateDOB({@required BuildContext context, String value}) {
    if (value.isEmpty) {
      return AppLocalizations.of(context).mProfileDOBMandatory;
    } else
      return null;
  }

  static validateMobile({BuildContext context, String value}) {
    if (value.trim().isEmpty) {
      return AppLocalizations.of(context).mRegisterMobileNumberMandatory;
    } else if (value.trim().length != 10 ||
        !RegExp(r'^\s*(?:\+?(\d{1,3}))?[-. (]*(\d{3})[-. )]*(\d{3})[-. ]*(\d{4})(?: *x(\d+))?\s*$')
            .hasMatch(value)) {
      return AppLocalizations.of(context).mEditProfilePleaseAddValidNumber;
    } else
      return null;
  }

  static validateDesignation({@required BuildContext context, String value}) {
    if (value.trim().isEmpty) {
      return AppLocalizations.of(context).mDesignationMandatory;
    } else
      return null;
  }

  static validateGroup({@required BuildContext context, String value}) {
    if (value.trim().isEmpty) {
      return AppLocalizations.of(context).mGroupMandatory;
    } else
      return null;
  }

  static Widget validateField({String field}) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            EnglishLang.firstNameMandatory
                .replaceAll(EnglishLang.firstName, field),
            style:
                GoogleFonts.lato(fontSize: 14, color: AppColors.negativeLight),
          )),
    );
  }
}
