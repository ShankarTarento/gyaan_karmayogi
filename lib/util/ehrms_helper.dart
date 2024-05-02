import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/models/user/ehrms_details_model.dart';

class KeyValue {
  final String key;
  final String value;

  const KeyValue({@required this.key, @required this.value});
}

class EhrmsHelper {
  static dynamic getPersonalDetails(
          {@required BuildContext context,
          @required EhrmsDetails ehrmsDetails}) =>
      [
        KeyValue(
            key: AppLocalizations.of(context).mehrmsSalutation,
            value: ehrmsDetails.salutation),
        KeyValue(
            key: AppLocalizations.of(context).mehrmsFirstname,
            value: ehrmsDetails.empFirstName),
        KeyValue(
            key: AppLocalizations.of(context).mehrmsMiddlename,
            value: ehrmsDetails.empMiddleName),
        KeyValue(
            key: AppLocalizations.of(context).mehrmsLastname,
            value: ehrmsDetails.empLastName),
        KeyValue(
            key: AppLocalizations.of(context).mehrmsDob,
            value: ehrmsDetails.empDob),
        KeyValue(
            key: AppLocalizations.of(context).mehrmsGender,
            value: ehrmsDetails.gender),
        KeyValue(
            key: AppLocalizations.of(context).mehrmsCategory,
            value: ehrmsDetails.category),
        KeyValue(
            key: AppLocalizations.of(context).mehrmsDifferentlyAbled,
            value: ehrmsDetails.differentlyAbled),
        KeyValue(
            key: AppLocalizations.of(context).mehrmsMaritalStatus,
            value: ehrmsDetails.maritalStatus)
      ];

  static dynamic getEmployeeDetails(
          {@required BuildContext context,
          @required EhrmsDetails ehrmsDetails}) =>
      [
        KeyValue(
            key: AppLocalizations.of(context).mehrmsEmployeeCode,
            value: ehrmsDetails.employeeCode),
        KeyValue(
            key: AppLocalizations.of(context).mehrmsService,
            value: ehrmsDetails.serviceType),
        KeyValue(
            key: AppLocalizations.of(context).mehrmsDesignation,
            value: ehrmsDetails.designation),
        KeyValue(
            key: AppLocalizations.of(context).mehrmsMinistryDepartmentOffice,
            value: ehrmsDetails.mdo),
        KeyValue(
            key: AppLocalizations.of(context).mehrmsCurrentPlaceOfPosting,
            value: ehrmsDetails.placeOfPosting),
        KeyValue(
            key: AppLocalizations.of(context).mehrmsEmailId,
            value: ehrmsDetails.empEmail),
        KeyValue(
            key: AppLocalizations.of(context).mehrmsMobileNo,
            value: ehrmsDetails.empMobile),
      ];

  static dynamic getPresentAddress(
          {@required BuildContext context,
          @required EhrmsDetails ehrmsDetails}) =>
      [
        KeyValue(
            key: AppLocalizations.of(context).mehrmsAddress1,
            value: ehrmsDetails.presentAddress1),
        KeyValue(
            key: AppLocalizations.of(context).mehrmsAddress2,
            value: ehrmsDetails.presentAddress2),
        KeyValue(
            key: AppLocalizations.of(context).mehrmsState,
            value: ehrmsDetails.presentState),
        KeyValue(
            key: AppLocalizations.of(context).mehrmsDistrict,
            value: ehrmsDetails.presentCity),
        KeyValue(
            key: AppLocalizations.of(context).mehrmsPincode,
            value: ehrmsDetails.presentPincode),
      ];

  static dynamic getPermanentAddress(
          {@required BuildContext context,
          @required EhrmsDetails ehrmsDetails}) =>
      [
        KeyValue(
            key: AppLocalizations.of(context).mehrmsAddress1,
            value: ehrmsDetails.prmntAddress1),
        KeyValue(
            key: AppLocalizations.of(context).mehrmsAddress2,
            value: ehrmsDetails.prmntAddress2),
        KeyValue(
            key: AppLocalizations.of(context).mehrmsState,
            value: ehrmsDetails.prmntState),
        KeyValue(
            key: AppLocalizations.of(context).mehrmsDistrict,
            value: ehrmsDetails.prmntCity),
        KeyValue(
            key: AppLocalizations.of(context).mehrmsPincode,
            value: ehrmsDetails.prmntPincode),
      ];
}
