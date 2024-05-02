import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/models/_models/profile_other_details.dart';
import 'package:karmayogi_mobile/models/index.dart';
import 'package:karmayogi_mobile/respositories/_respositories/profile_repository.dart';
import 'package:karmayogi_mobile/ui/widgets/_profile/approval_indicators.dart';
import 'package:karmayogi_mobile/ui/widgets/_profile/custom_auto_complete_textfield.dart';
import 'package:karmayogi_mobile/ui/widgets/_profile/edit_profile_tags.dart';
import 'package:karmayogi_mobile/ui/widgets/_profile/field_name_widget.dart';
import 'package:karmayogi_mobile/ui/widgets/_profile/form_field_section_heading.dart';
import 'package:karmayogi_mobile/ui/widgets/_profile/input_chip_common.dart';
import 'package:karmayogi_mobile/ui/widgets/_profile/org_type_selection.dart';
import 'package:karmayogi_mobile/ui/widgets/_profile/read_only_field.dart';
import 'package:karmayogi_mobile/ui/widgets/_profile/select_from_bottomsheet.dart';
import 'package:karmayogi_mobile/ui/widgets/_profile/single_choice_inputs.dart';
import 'package:karmayogi_mobile/ui/widgets/_profile/text_input_field.dart';
import 'package:karmayogi_mobile/util/edit_other_profile_details_helper.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditOtherDetailsPage extends StatefulWidget {
  static final GlobalKey<_EditOtherDetailsPageState> otherDetailsGlobalKey =
      GlobalKey();
  EditOtherDetailsPage({Key key}) : super(key: otherDetailsGlobalKey);

  @override
  State<EditOtherDetailsPage> createState() => _EditOtherDetailsPageState();
}

class _EditOtherDetailsPageState extends State<EditOtherDetailsPage> {
  Map _organisationTypes = <String, bool>{
    EnglishLang.government: false,
    EnglishLang.nonGovernment: false,
  };
  final TextEditingController _otherLangsController = TextEditingController();
  final TextEditingController _telephoneNoController = TextEditingController();
  final TextEditingController _secondaryEmailController =
      TextEditingController();
  final TextEditingController _postalAddressController =
      TextEditingController();
  final TextEditingController _nationalityController = TextEditingController();
  final TextEditingController _motherTongueController = TextEditingController();
  final TextEditingController _orgNameController = TextEditingController();
  final TextEditingController _industryController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dojController = TextEditingController();
  final TextEditingController _orgDescriptionController =
      TextEditingController();
  final TextEditingController _payBandController = TextEditingController();
  final TextEditingController _serviceController = TextEditingController();
  final TextEditingController _cadreController = TextEditingController();
  final TextEditingController _allotmentYrServiceController =
      TextEditingController();
  final TextEditingController _dateOfJoiningExpController =
      TextEditingController();
  final TextEditingController _civilListNoController = TextEditingController();
  final TextEditingController _employeeCodeController = TextEditingController();
  final TextEditingController _officePostalAddressController =
      TextEditingController();
  final TextEditingController _officePinCodeController =
      TextEditingController();
  final TextEditingController _schoolName10thController =
      TextEditingController();
  final TextEditingController _yearOfPassing10thController =
      TextEditingController();
  final TextEditingController _schoolName12thController =
      TextEditingController();
  final TextEditingController _yearOfPassing12thController =
      TextEditingController();
  final TextEditingController _graduationController = TextEditingController();
  final TextEditingController _postGranduationController =
      TextEditingController();

  final FocusNode _motherTongueFocus = FocusNode();

  ValueNotifier<List<dynamic>> _otherLanguages = ValueNotifier([]);
  ValueNotifier<String> _selectedMaritalStatus = ValueNotifier('');
  ValueNotifier<String> _selectedOrg = ValueNotifier('');

  DateTime _dojDate;

  ValueNotifier<Map<dynamic, dynamic>> _graduationDegrees = ValueNotifier({
    0: {
      'display': true,
      'nameOfQualification': '',
      'type': DegreeType.graduate,
      'nameOfInstitute': '',
      'yearOfPassing': ''
    }
  });
  ValueNotifier<Map<dynamic, dynamic>> _postGraduationDegrees = ValueNotifier({
    0: {
      'display': true,
      'nameOfQualification': '',
      'type': DegreeType.postGraduate,
      'nameOfInstitute': '',
      'yearOfPassing': ''
    }
  });

  @override
  void initState() {
    super.initState();
    _populateFields();
  }

  _populateFields() {
    Profile profile =
        Provider.of<ProfileRepository>(context, listen: false).profileDetails;
    dynamic personalDetails = profile.personalDetails;
    dynamic employmentDetails = profile.employmentDetails;
    _otherLanguages.value = personalDetails['knownLanguages'] != null
        ? personalDetails['knownLanguages']
        : [];
    _telephoneNoController.text = personalDetails['telephone'];
    _secondaryEmailController.text = personalDetails['secondaryEmail'];
    _postalAddressController.text = personalDetails['postalAddress'];
    _nationalityController.text = personalDetails['nationality'];
    _motherTongueController.text = personalDetails['domicileMedium'];
    _selectedMaritalStatus.value = personalDetails['maritalStatus'];
    if (profile.experience.length > 0) {
      if (profile.experience[0]['organisationType'] != null &&
          profile.experience[0]['organisationType'] != '') {
        _organisationTypes[profile.experience[0]['organisationType']] = true;
        _selectedOrg.value = profile.experience[0]['organisationType'];
      }
      _industryController.text = profile.experience[0]['industry'];
      _locationController.text = profile.experience[0]['location'];
      _dojController.text = profile.experience[0]['doj'];
      _orgDescriptionController.text = profile.experience[0]['description'];
    }
    _orgNameController.text = employmentDetails['departmentName'];
    _payBandController.text = employmentDetails['payType'];
    _cadreController.text = employmentDetails['cadre'];
    _serviceController.text = employmentDetails['service'];
    _allotmentYrServiceController.text =
        employmentDetails['allotmentYearOfService'];
    _dateOfJoiningExpController.text = employmentDetails['dojOfService'];
    _civilListNoController.text = employmentDetails['civilListNo'];
    _employeeCodeController.text = employmentDetails['employeeCode'];
    _officePostalAddressController.text =
        employmentDetails['officialPostalAddress'];
    _officePinCodeController.text = employmentDetails['pinCode'];
    _populateAcademicFields(profile);
  }

  _populateAcademicFields(Profile profile) {
    int graduationIndex = 0;
    int postGraduationIndex = 0;
    Map<dynamic, dynamic> graduationDegrees = {};
    Map<dynamic, dynamic> postGraduationDegrees = {};
    for (int i = 0; i < profile.education.length; i++) {
      switch (profile.education[i]['type']) {
        case DegreeType.xStandard:
          _schoolName10thController.text =
              profile.education[i]['nameOfInstitute'];
          _yearOfPassing10thController.text =
              profile.education[i]['yearOfPassing'];
          break;
        case DegreeType.xiiStandard:
          _schoolName12thController.text =
              profile.education[i]['nameOfInstitute'];
          _yearOfPassing12thController.text =
              profile.education[i]['yearOfPassing'];
          break;
        case DegreeType.graduate:
          graduationDegrees.addAll({
            graduationIndex++: {
              'display': true,
              'nameOfQualification': profile.education[i]
                  ['nameOfQualification'],
              'type': DegreeType.graduate,
              'nameOfInstitute': profile.education[i]['nameOfInstitute'],
              'yearOfPassing': profile.education[i]['yearOfPassing']
            }
          });
          break;
        case DegreeType.postGraduate:
          postGraduationDegrees.addAll({
            postGraduationIndex++: {
              'display': true,
              'nameOfQualification': profile.education[i]
                  ['nameOfQualification'],
              'type': DegreeType.postGraduate,
              'nameOfInstitute': profile.education[i]['nameOfInstitute'],
              'yearOfPassing': profile.education[i]['yearOfPassing']
            }
          });
          break;
      }
    }
    if (graduationDegrees.length > 0) {
      _graduationDegrees.value = graduationDegrees;
    }
    if (postGraduationDegrees.length > 0) {
      _postGraduationDegrees.value = postGraduationDegrees;
    }
  }

  _addIntoLangList() {
    if (_otherLangsController.text.trim().isNotEmpty) {
      _otherLanguages.value.add(_otherLangsController.text.trim());
      _otherLanguages.value = _otherLanguages.value.toSet().toList();
      _otherLangsController.clear();
    }
  }

  _deleteFromLangList(item) {
    _otherLanguages.value.remove(item);
    _otherLanguages.value = _otherLanguages.value.toSet().toList();
  }

  Future<void> saveProfile() async {
    await EditOtherProfileDetailshelper.saveProfile(
        context: context,
        profileOtherDetails: ProfileOtherDetails(
            otherLanguages: _otherLanguages.value,
            telephoneNo: _telephoneNoController.text,
            secondaryEmail: _secondaryEmailController.text,
            postalAddress: _postalAddressController.text,
            nationality: _nationalityController.text,
            motherTongue: _motherTongueController.text,
            maritalStatus: _selectedMaritalStatus.value,
            orgName: _orgNameController.text,
            orgType: _selectedOrg.value,
            industry: _industryController.text,
            location: _locationController.text,
            doj: _dojController.text,
            orgDescription: _orgDescriptionController.text,
            allotmentYrOfService: _allotmentYrServiceController.text,
            payBand: _payBandController.text,
            cadre: _cadreController.text,
            service: _serviceController.text,
            dateOfJoiningExp: _dateOfJoiningExpController.text,
            civilListNo: _civilListNoController.text,
            employeeCode: _employeeCodeController.text,
            officePostalAddress: _officePostalAddressController.text,
            officePinCode: _officePinCodeController.text,
            schoolName10th: _schoolName10thController.text,
            yearOfPassing10th: _yearOfPassing10thController.text,
            schoolName12th: _schoolName12thController.text,
            yearOfPassing12th: _yearOfPassing12thController.text,
            graduationDegrees: _graduationDegrees.value,
            postGraduationDegrees: _postGraduationDegrees.value));
  }

  @override
  void dispose() {
    super.dispose();
    _otherLangsController.dispose();
    _telephoneNoController.dispose();
    _secondaryEmailController.dispose();
    _postalAddressController.dispose();
    _nationalityController.dispose();
    _motherTongueController.dispose();
    _orgNameController.dispose();
    _industryController.dispose();
    _locationController.dispose();
    _dojController.dispose();
    _orgDescriptionController.dispose();
    _payBandController.dispose();
    _cadreController.dispose();
    _serviceController.dispose();
    _dateOfJoiningExpController.dispose();
    _civilListNoController.dispose();
    _employeeCodeController.dispose();
    _officePostalAddressController.dispose();
    _officePinCodeController.dispose();
    _schoolName10thController.dispose();
    _yearOfPassing10thController.dispose();
    _schoolName12thController.dispose();
    _yearOfPassing12thController.dispose();
    _graduationController.dispose();
    _postGraduationDegrees.dispose();
    _allotmentYrServiceController.dispose();
    _motherTongueFocus.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Personal details
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Other languages known
                FieldNameWidget(
                    fieldName:
                        AppLocalizations.of(context).mEditProfileOtherLangs),
                TextInputField(
                  keyboardType: TextInputType.text,
                  hintText: AppLocalizations.of(context).mEditProfileTypeHere,
                  controller: _otherLangsController,
                  suffix: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: GestureDetector(
                      onTap: () => _addIntoLangList(),
                      child: Text(
                        AppLocalizations.of(context).mEditProfileAdd,
                        style: GoogleFonts.lato(
                          color: AppColors.primaryThree,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
                ValueListenableBuilder(
                    valueListenable: _otherLanguages,
                    builder: (BuildContext context,
                        List<dynamic> otherLanguages, Widget child) {
                      return Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Wrap(
                          children: [
                            for (dynamic i in _otherLanguages.value)
                              InputChipWidget(
                                onDeleted: () => _deleteFromLangList(i),
                                text: i,
                              ),
                          ],
                        ),
                      );
                    }),
                // Telephone number
                FieldNameWidget(
                    fieldName: AppLocalizations.of(context)
                        .mEditProfileTelephoneNumber),
                TextInputField(
                  keyboardType: TextInputType.number,
                  hintText: AppLocalizations.of(context)
                      .mEditProfileTelephoneNumberExample,
                  controller: _telephoneNoController,
                ),
                // Secondary email
                FieldNameWidget(
                  fieldName:
                      AppLocalizations.of(context).mEditProfileSecondaryEmail,
                ),
                TextInputField(
                  keyboardType: TextInputType.emailAddress,
                  hintText: AppLocalizations.of(context).mEditProfileTypeHere,
                  controller: _secondaryEmailController,
                ),
                // Postal address
                FieldNameWidget(
                  fieldName:
                      AppLocalizations.of(context).mEditProfilePostalAddress,
                ),
                TextInputField(
                  keyboardType: TextInputType.multiline,
                  hintText: AppLocalizations.of(context)
                      .mEditProfileEnterResidenceAddress,
                  controller: _postalAddressController,
                  maxLength: 200,
                  minLines: 1,
                ),
                // Nationality
                FieldNameWidget(
                  fieldName:
                      AppLocalizations.of(context).mEditProfileNationality,
                ),
                SelectFromBottomSheet(
                  fieldName: EnglishLang.nationality,
                  controller: _nationalityController,
                ),
                // Mother tongue
                FieldNameWidget(
                  fieldName:
                      AppLocalizations.of(context).mEditProfileDomicileMeduium,
                ),
                Consumer<ProfileRepository>(builder: (BuildContext context,
                    ProfileRepository profileRepository, Widget child) {
                  return CustomAutoCompleteTextField(
                    controller: _motherTongueController,
                    suggestions: profileRepository.languages
                        .map((item) => item.language)
                        .toList(),
                    focusNode: _motherTongueFocus,
                    textSubmitted: (p0) => _motherTongueFocus.unfocus(),
                  );
                }),
                // Marital status
                FieldNameWidget(
                    fieldName:
                        AppLocalizations.of(context).mEditProfileMaritalStatus),
                ValueListenableBuilder(
                    valueListenable: _selectedMaritalStatus,
                    builder: (BuildContext context,
                        String selectedMaritalStatus, Widget child) {
                      return SingleChoiceInputs(
                        itemCount: EditOtherProfileDetailshelper
                            .maritalStatusRadio.length,
                        choices:
                            EditOtherProfileDetailshelper.maritalStatusRadio,
                        selected: selectedMaritalStatus,
                        onChanged: (value) {
                          _selectedMaritalStatus.value = value;
                        },
                      );
                    }),
              ],
            ),
          ),
          Container(
            height: 24,
            color: Colors.white,
          ),
          // Organisation details
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: FormFieldSectionHeading(
                text: AppLocalizations.of(context)
                    .mEditProfileOrganisationDetails),
          ),
          ApprovalIndicators(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Consumer<ProfileRepository>(builder: (BuildContext context,
                ProfileRepository profileRepository, Widget child) {
              dynamic employmentDetails =
                  profileRepository.profileDetails.employmentDetails;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Organisation type
                  ValueListenableBuilder(
                      valueListenable: _selectedOrg,
                      builder: (BuildContext context, String selectedOrg,
                          Widget child) {
                        return Column(
                          children: [
                            FieldNameWidget(
                              fieldName: AppLocalizations.of(context)
                                  .mEditProfileTypeOfOrganisation,
                              isApprovalField: true,
                              isInReview: profileRepository.inReview != null &&
                                  profileRepository.inReview
                                      .containsKey('organisationType'),
                            ),
                            OrgTypeSelection(
                                selected: selectedOrg,
                                options: EditOtherProfileDetailshelper
                                    .organizationTypesRadio,
                                onTapFn: (dynamic value) {
                                  _selectedOrg.value = value;
                                }),
                          ],
                        );
                      }),
                  // Organisation name
                  FieldNameWidget(
                    fieldName: AppLocalizations.of(context)
                        .mEditProfileOrganisationName,
                    isApprovalField: true,
                    isApproved: _orgNameController.text ==
                        employmentDetails['departmentName'],
                    isInReview: profileRepository.inReview != null &&
                        profileRepository.inReview.containsKey('name'),
                  ),
                  SelectFromBottomSheet(
                    fieldName: EnglishLang.organisationName,
                    controller: _orgNameController,
                    isInReview: profileRepository.inReview != null &&
                        profileRepository.inReview.containsKey('name'),
                    callBack: () {
                      setState(() {});
                    },
                  ),
                  // Industry
                  FieldNameWidget(
                    fieldName:
                        AppLocalizations.of(context).mEditProfileIndustry,
                    isApprovalField: true,
                    isApproved: _industryController.text ==
                        (profileRepository.profileDetails.experience.length > 0
                            ? profileRepository.profileDetails.experience[0]
                                ['industry']
                            : null),
                    isInReview: profileRepository.inReview != null &&
                        profileRepository.inReview.containsKey('industry'),
                  ),
                  SelectFromBottomSheet(
                    fieldName: EnglishLang.industry,
                    controller: _industryController,
                    isInReview: profileRepository.inReview != null &&
                        profileRepository.inReview.containsKey('industry'),
                    callBack: () {
                      setState(() {});
                    },
                  ),
                  // Country of organisation
                  FieldNameWidget(
                    fieldName:
                        AppLocalizations.of(context).mEditProfileLocation,
                    isApprovalField: true,
                    isApproved: _locationController.text ==
                        (profileRepository.profileDetails.experience.length > 0
                            ? profileRepository.profileDetails.experience[0]
                                ['location']
                            : null),
                    isInReview: profileRepository.inReview != null &&
                        profileRepository.inReview.containsKey('location'),
                  ),
                  SelectFromBottomSheet(
                    fieldName: EnglishLang.location,
                    controller: _locationController,
                    isInReview: profileRepository.inReview != null &&
                        profileRepository.inReview.containsKey('location'),
                    callBack: () {
                      setState(() {});
                    },
                  ),
                  // Date of joining in the organisation
                  FieldNameWidget(
                    fieldName: AppLocalizations.of(context).mEditProfileDoj,
                    isApprovalField: true,
                    isApproved: _dojController.text ==
                        (profileRepository.profileDetails.experience.length > 0
                            ? profileRepository.profileDetails.experience[0]
                                ['doj']
                            : null),
                    isInReview: profileRepository.inReview != null &&
                        profileRepository.inReview.containsKey('doj'),
                  ),
                  TextInputField(
                    keyboardType: TextInputType.datetime,
                    readOnly: true,
                    isDate: true,
                    controller: _dojController,
                    hintText: _dojController.text != null &&
                            _dojController.text != ''
                        ? _dojController.text
                        : AppLocalizations.of(context).mEditProfileChooseDate,
                    onTap: profileRepository.inReview != null &&
                            profileRepository.inReview.containsKey('doj')
                        ? null
                        : () async {
                            DateTime newDate = await showDatePicker(
                                context: context,
                                initialDate: _dojDate == null
                                    ? ((_dojController.text != null &&
                                                _dojController.text != '') &&
                                            !RegExp(r'[a-zA-Z]')
                                                .hasMatch(_dojController.text)
                                        ? Helper.convertDDMMYYYYtoDateTime(
                                            _dojController.text)
                                        : DateTime.now())
                                    : _dojDate,
                                firstDate: DateTime(1900),
                                lastDate: DateTime(2100));
                            if (newDate == null) {
                              return null;
                            }
                            _dojDate = newDate;
                            _dojController.text =
                                Helper.convertDatetimetoDDMMYYYY(newDate);
                          },
                  ),
                  // Description about the organisation
                  FieldNameWidget(
                    fieldName:
                        AppLocalizations.of(context).mEditProfileDescription,
                    isApprovalField: true,
                    isApproved: _orgDescriptionController.text ==
                        (profileRepository.profileDetails.experience.length > 0
                            ? profileRepository.profileDetails.experience[0]
                                ['description']
                            : null),
                    isInReview: profileRepository.inReview != null &&
                        profileRepository.inReview.containsKey('description'),
                  ),
                  TextInputField(
                    keyboardType: TextInputType.multiline,
                    hintText: AppLocalizations.of(context)
                        .mEditProfileEnterOrgDescription,
                    controller: _orgDescriptionController,
                    maxLength: 500,
                    minLines: 1,
                    readOnly: profileRepository.inReview != null &&
                        profileRepository.inReview.containsKey('description'),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 12),
                    child: Divider(
                      color: AppColors.grey16,
                    ),
                  ),
                  // Other details for government employees(If applicable)
                  FormFieldSectionHeading(
                    text: AppLocalizations.of(context)
                        .mEditProfileOtherDetailsOfGovtEmployees,
                    isSubHeadingText: true,
                  ),
                  FieldNameWidget(
                    fieldName: AppLocalizations.of(context).mEditProfilePayBand,
                  ),
                  SelectFromBottomSheet(
                    fieldName: EnglishLang.payBand,
                    controller: _payBandController,
                  ),
                  FieldNameWidget(
                    fieldName: AppLocalizations.of(context).mEditProfileService,
                  ),
                  SelectFromBottomSheet(
                    fieldName: EnglishLang.service,
                    controller: _serviceController,
                  ),
                  FieldNameWidget(
                      fieldName:
                          AppLocalizations.of(context).mEditProfileCadre),
                  SelectFromBottomSheet(
                    fieldName: EnglishLang.cadre,
                    controller: _cadreController,
                  ),
                  FieldNameWidget(
                      fieldName: AppLocalizations.of(context)
                          .mEditProfileAllotmentYearOfService),
                  TextInputField(
                    keyboardType: TextInputType.number,
                    hintText: AppLocalizations.of(context).mEditProfileTypeHere,
                    controller: _allotmentYrServiceController,
                  ),
                  FieldNameWidget(
                      fieldName: AppLocalizations.of(context).mEditProfileDoj),
                  TextInputField(
                    keyboardType: TextInputType.datetime,
                    readOnly: true,
                    isDate: true,
                    controller: _dateOfJoiningExpController,
                    hintText: _dateOfJoiningExpController.text != null &&
                            _dateOfJoiningExpController.text != ''
                        ? _dateOfJoiningExpController.text
                        : AppLocalizations.of(context).mEditProfileChooseDate,
                    onTap: () async {
                      DateTime newDate = await showDatePicker(
                          context: context,
                          initialDate: _dojDate == null
                              ? ((_dateOfJoiningExpController.text != null &&
                                          _dateOfJoiningExpController.text !=
                                              '') &&
                                      !RegExp(r'[a-zA-Z]').hasMatch(
                                          _dateOfJoiningExpController.text)
                                  ? Helper.convertDDMMYYYYtoDateTime(
                                      _dateOfJoiningExpController.text)
                                  : DateTime.now())
                              : _dojDate,
                          firstDate: DateTime(1900),
                          lastDate: DateTime(2100));
                      if (newDate == null) {
                        return null;
                      }
                      _dojDate = newDate;
                      _dateOfJoiningExpController.text =
                          Helper.convertDatetimetoDDMMYYYY(newDate);
                    },
                  ),
                  FieldNameWidget(
                      fieldName: AppLocalizations.of(context)
                          .mEditProfileCivilListNumber),
                  TextInputField(
                    keyboardType: TextInputType.number,
                    hintText: AppLocalizations.of(context).mEditProfileTypeHere,
                    controller: _civilListNoController,
                  ),
                  FieldNameWidget(
                      fieldName: AppLocalizations.of(context)
                          .mEditProfileEmployeeCode),
                  TextInputField(
                    keyboardType: TextInputType.number,
                    hintText: AppLocalizations.of(context).mEditProfileTypeHere,
                    controller: _employeeCodeController,
                  ),
                  FieldNameWidget(
                      fieldName: AppLocalizations.of(context)
                          .mEditProfileOfficePostalAddress),
                  TextInputField(
                    keyboardType: TextInputType.multiline,
                    hintText: AppLocalizations.of(context).mEditProfileTypeHere,
                    controller: _officePostalAddressController,
                    maxLength: 200,
                    minLines: 1,
                  ),
                  FieldNameWidget(
                      fieldName: AppLocalizations.of(context)
                          .mEditProfileOfficePinCode),
                  TextInputField(
                    maxLength: 6,
                    minLines: 1,
                    keyboardType: TextInputType.number,
                    hintText: AppLocalizations.of(context).mEditProfileTypeHere,
                    controller: _officePinCodeController,
                    counterText: '',
                  ),
                  profileRepository.profileDetails.ehrmsId != null
                      ? Column(
                          children: [
                            FieldNameWidget(
                              fieldName: AppLocalizations.of(context).mehrmsId,
                            ),
                            ReadOnlyField(
                              text: profileRepository.profileDetails.ehrmsId,
                            ),
                            FieldNameWidget(
                              fieldName:
                                  AppLocalizations.of(context).mehrmsSystem,
                            ),
                            ReadOnlyField(
                              text:
                                  profileRepository.profileDetails.ehrmsSystem,
                            ),
                          ],
                        )
                      : SizedBox(),
                  FieldNameWidget(
                      fieldName:
                          AppLocalizations.of(context).mEditProfileTagsText),
                  EditProfileTags(),
                ],
              );
            }),
          ),
          Container(
            height: 24,
            color: Colors.white,
          ),
          // Academics details
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: FormFieldSectionHeading(
                      text: AppLocalizations.of(context)
                          .mEditProfileAcademicDetails),
                ),
                // 10th Standard
                FormFieldSectionHeading(
                  text: AppLocalizations.of(context).mEditProfileStandardTenth,
                  isSubHeadingText: true,
                ),
                FieldNameWidget(
                    fieldName:
                        AppLocalizations.of(context).mEditProfileSchoolName),
                TextInputField(
                  keyboardType: TextInputType.name,
                  hintText: AppLocalizations.of(context).mEditProfileTypeHere,
                  controller: _schoolName10thController,
                ),
                FieldNameWidget(
                    fieldName:
                        AppLocalizations.of(context).mEditProfileYearOfPassing),
                TextInputField(
                  keyboardType: TextInputType.number,
                  hintText: AppLocalizations.of(context).mEditProfileTypeHere,
                  controller: _yearOfPassing10thController,
                ),
                // 12th Standard
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: FormFieldSectionHeading(
                    text:
                        AppLocalizations.of(context).mEditProfileStandardTwelth,
                    isSubHeadingText: true,
                  ),
                ),
                FieldNameWidget(
                    fieldName:
                        AppLocalizations.of(context).mEditProfileSchoolName),
                TextInputField(
                    keyboardType: TextInputType.name,
                    hintText: AppLocalizations.of(context).mEditProfileTypeHere,
                    controller: _schoolName12thController),
                FieldNameWidget(
                    fieldName:
                        AppLocalizations.of(context).mEditProfileYearOfPassing),
                TextInputField(
                  keyboardType: TextInputType.number,
                  hintText: AppLocalizations.of(context).mEditProfileTypeHere,
                  controller: _yearOfPassing12thController,
                ),
                // Graduation details
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: FormFieldSectionHeading(
                    text: AppLocalizations.of(context).mEditProfileGradDetails,
                    isSubHeadingText: true,
                  ),
                ),
                ValueListenableBuilder(
                    valueListenable: _graduationDegrees,
                    builder: (BuildContext context,
                        Map<dynamic, dynamic> graduationDegrees, Widget child) {
                      return Column(
                        children: [
                          ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: graduationDegrees.length,
                              itemBuilder: (context, index) {
                                return graduationDegrees[index]['display']
                                    ? _getDegreeFields(
                                        AcademicDegree.graduation, index)
                                    : Center();
                              }),
                          Padding(
                            padding: EdgeInsets.only(bottom: 16, top: 16),
                            child: SizedBox(
                              width: double.infinity,
                              child: TextButton(
                                onPressed: () {
                                  _graduationDegrees.value[
                                      _graduationDegrees.value.length] = {
                                    'display': true,
                                    'nameOfQualification': '',
                                    'type': DegreeType.graduate,
                                    'nameOfInstitute': '',
                                    'yearOfPassing': ''
                                  };
                                  _graduationDegrees.notifyListeners();
                                },
                                style: TextButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                      side: BorderSide(
                                          color: AppColors.primaryThree)),
                                ),
                                child: Text(
                                  AppLocalizations.of(context)
                                      .mEditProfileAddAnotherQualification,
                                  style: GoogleFonts.lato(
                                    color: AppColors.primaryThree,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                // Post graduation details
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: FormFieldSectionHeading(
                    text: AppLocalizations.of(context)
                        .mEditProfilePostGradDetails,
                    isSubHeadingText: true,
                  ),
                ),
                ValueListenableBuilder(
                    valueListenable: _postGraduationDegrees,
                    builder: (BuildContext context,
                        Map<dynamic, dynamic> postGraduationDegrees,
                        Widget child) {
                      return Column(
                        children: [
                          ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: postGraduationDegrees.length,
                              itemBuilder: (context, index) {
                                return postGraduationDegrees[index]['display']
                                    ? _getDegreeFields(
                                        AcademicDegree.postGraduation, index)
                                    : Center();
                              }),
                          Padding(
                            padding: EdgeInsets.only(bottom: 16, top: 16),
                            child: SizedBox(
                              width: double.infinity,
                              child: TextButton(
                                onPressed: () {
                                  _postGraduationDegrees.value[
                                      _postGraduationDegrees.value.length] = {
                                    'display': true,
                                    'nameOfQualification': '',
                                    'type': DegreeType.postGraduate,
                                    'nameOfInstitute': '',
                                    'yearOfPassing': ''
                                  };
                                  _postGraduationDegrees.notifyListeners();
                                },
                                style: TextButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                      side: BorderSide(
                                          color: AppColors.primaryThree)),
                                ),
                                child: Text(
                                  AppLocalizations.of(context)
                                      .mEditProfileAddAnotherQualification,
                                  style: GoogleFonts.lato(
                                    color: AppColors.primaryThree,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
              ],
            ),
          ),
          SizedBox(
            height: 100,
          )
        ],
      ),
    );
  }

  _getDegreeFields(String degree, int index) {
    return ValueListenableBuilder(
        valueListenable: degree == AcademicDegree.graduation
            ? _graduationDegrees
            : _postGraduationDegrees,
        builder: (BuildContext context, Map<dynamic, dynamic> degrees,
            Widget child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FieldNameWidget(
                  fieldName: AppLocalizations.of(context).mEditProfileDegres),
              SelectFromBottomSheet(
                fieldName: AppLocalizations.of(context).mProfileDegree,
                degreeType: degree,
                controller: degree == AcademicDegree.graduation
                    ? _graduationController
                    : _postGranduationController,
                selected: degree == AcademicDegree.graduation
                    ? _graduationDegrees.value[index]['nameOfQualification'] !=
                                null &&
                            _graduationDegrees.value[index]
                                    ['nameOfQualification'] !=
                                ''
                        ? _graduationDegrees.value[index]['nameOfQualification']
                        : "Select"
                    : _postGraduationDegrees.value[index]
                                    ['nameOfQualification'] !=
                                null &&
                            _postGraduationDegrees.value[index]
                                    ['nameOfQualification'] !=
                                ''
                        ? _postGraduationDegrees.value[index]
                            ['nameOfQualification']
                        : "Select",
                onSelected: (value) {
                  if (degree == AcademicDegree.graduation) {
                    _graduationDegrees.value[index]['nameOfQualification'] =
                        value;
                    _graduationDegrees.notifyListeners();
                  } else {
                    _postGraduationDegrees.value[index]['nameOfQualification'] =
                        value;
                    _postGraduationDegrees.notifyListeners();
                  }
                },
              ),
              FieldNameWidget(
                  fieldName:
                      AppLocalizations.of(context).mEditProfileYearOfPassing),
              TextInputField(
                keyboardType: TextInputType.number,
                hintText: AppLocalizations.of(context).mEditProfileTypeHere,
                initialValue: degree == AcademicDegree.graduation
                    ? _graduationDegrees.value[index]['yearOfPassing']
                    : _postGraduationDegrees.value[index]['yearOfPassing'],
                onChanged: (value) {
                  degree == AcademicDegree.graduation
                      ? _graduationDegrees.value[index]['yearOfPassing'] = value
                      : _postGraduationDegrees.value[index]['yearOfPassing'] =
                          value;
                },
              ),
              FieldNameWidget(
                  fieldName:
                      AppLocalizations.of(context).mEditProfileInstituteName),
              TextInputField(
                keyboardType: TextInputType.name,
                hintText: AppLocalizations.of(context).mEditProfileTypeHere,
                initialValue: degrees[index]['nameOfInstitute'],
                onChanged: (value) {
                  degree == AcademicDegree.graduation
                      ? _graduationDegrees.value[index]['nameOfInstitute'] =
                          value
                      : _postGraduationDegrees.value[index]['nameOfInstitute'] =
                          value;
                },
              ),
              index > 0
                  ? InkWell(
                      onTap: () => EditOtherProfileDetailshelper.onRemoveDegree(
                          context: context,
                          degree: degree,
                          index: index,
                          onTapFn: () {
                            degree == AcademicDegree.graduation
                                ? _graduationDegrees.value[index]['display'] =
                                    false
                                : _postGraduationDegrees.value[index]
                                    ['display'] = false;
                            _graduationDegrees.notifyListeners();
                          }),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.delete,
                              size: 24,
                              color: AppColors.greys60,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(
                                AppLocalizations.of(context)
                                    .mEditProfileDeleteDegree,
                                style: GoogleFonts.lato(
                                  color: AppColors.greys60,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  height: 1.5,
                                  letterSpacing: 0.25,
                                ),
                              ),
                            )
                          ],
                        ),
                      ))
                  : Center()
            ],
          );
        });
  }
}
