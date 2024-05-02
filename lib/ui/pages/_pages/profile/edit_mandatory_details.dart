import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/util/edit_profile_mandatory_helper.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/models/_models/profile_mandatory_details_model.dart';
import 'package:karmayogi_mobile/models/_models/profile_model.dart';
import 'package:karmayogi_mobile/respositories/_respositories/profile_repository.dart';
import 'package:karmayogi_mobile/ui/widgets/_profile/edit_profile_icon.dart';
import 'package:karmayogi_mobile/ui/widgets/_profile/field_name_widget.dart';
import 'package:karmayogi_mobile/ui/widgets/_profile/get_verified_karmayogi_info.dart';
import 'package:karmayogi_mobile/ui/widgets/_profile/select_from_bottomsheet.dart';
import 'package:karmayogi_mobile/ui/widgets/_profile/otp_verification_field.dart';
import 'package:karmayogi_mobile/ui/widgets/_profile/single_choice_inputs.dart';
import 'package:karmayogi_mobile/ui/widgets/_profile/text_input_field.dart';
import 'package:karmayogi_mobile/util/validations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditMandatoryDetails extends StatefulWidget {
  final fetchProfileDetailsAction;
  final List<dynamic> mandatoryFields;
  final bool isToUpdateMobileNumber;
  static final GlobalKey<_EditMandatoryDetailsState> mandatoryDetailsGlobalKey =
      GlobalKey();
  EditMandatoryDetails(
      {Key key,
      this.fetchProfileDetailsAction,
      this.mandatoryFields,
      this.isToUpdateMobileNumber = false})
      : super(key: mandatoryDetailsGlobalKey);

  @override
  State<EditMandatoryDetails> createState() => _EditMandatoryDetailsState();
}

class _EditMandatoryDetailsState extends State<EditMandatoryDetails> {
  final GlobalKey<FormState> mandatoryDetailsFormKey = GlobalKey<FormState>();
  // Controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _primaryEmailController = TextEditingController();
  final TextEditingController _groupController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _pinCodeController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  //FocusNodes
  final FocusNode _fullNameFocus = FocusNode();
  final FocusNode _dobFocus = FocusNode();
  final FocusNode _genderFocus = FocusNode();
  final FocusNode _categoryFocus = FocusNode();
  final FocusNode _mobileNoFocus = FocusNode();
  final FocusNode _primaryEmailFocus = FocusNode();
  final FocusNode _pinCodeFocus = FocusNode();

  ValueNotifier<String> _selectedGender = ValueNotifier('');
  ValueNotifier<String> _selectedCategory = ValueNotifier('');
  ValueNotifier<bool> _categoryValidateTextVisible = ValueNotifier(false);
  ValueNotifier<bool> _genderValidateTextVisible = ValueNotifier(false);
  DateTime _dobDate;
  ValueNotifier<Map> _inReview = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _populateFields();
    });
  }

  _getInReviewFields() async {
    _inReview.value =
        Provider.of<ProfileRepository>(context, listen: false).inReview;
  }

  _populateFields() async {
    // Getting in review fields if there are any
    await _getInReviewFields();
    // Fetching profile data and populating the fields
    Profile profileDetails =
        Provider.of<ProfileRepository>(context, listen: false).profileDetails;
    dynamic personalDetails = profileDetails.personalDetails;
    _fullNameController.text = profileDetails.firstName;
    _primaryEmailController.text = personalDetails['primaryEmail'];
    _positionController.text = profileDetails.designation != null
        ? profileDetails.designation
        : _inReview.value['designation'];
    _groupController.text = profileDetails.group != null
        ? profileDetails.group
        : _inReview.value['group'];
    _dobController.text = personalDetails['dob'];
    _pinCodeController.text = personalDetails['pincode'];
    _selectedGender.value = personalDetails['gender'];
    _selectedCategory.value = personalDetails['category'];
  }

  Future<void> saveProfile() async {
    if (_selectedCategory.value == null || _selectedCategory.value.isEmpty) {
      _categoryValidateTextVisible.value = true;
    }
    if (_selectedCategory.value == null || _selectedGender.value.isEmpty) {
      _genderValidateTextVisible.value = true;
    }
    await EditProfileMandatoryHelper.saveProfile(
        context: context,
        profileMandatoryDetails: ProfileMandatoryDetails(
            fullName: _fullNameController.text,
            primaryEmail: _primaryEmailController.text,
            pinCode: _pinCodeController.text,
            dob: _dobController.text,
            gender: _selectedGender.value,
            category: _selectedCategory.value,
            mobile: _mobileNumberController.text,
            group: _groupController.text,
            position: _positionController.text));
  }

  @override
  void dispose() {
    super.dispose();
    _fullNameController.dispose();
    _groupController.dispose();
    _positionController.dispose();
    _pinCodeController.dispose();

    _fullNameFocus.dispose();
    _dobFocus.dispose();
    _genderFocus.dispose();
    _categoryFocus.dispose();
    _mobileNoFocus.dispose();
    _primaryEmailFocus.dispose();
    _pinCodeFocus.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: mandatoryDetailsFormKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Profile photo section
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 16),
                child: EditProfileIcon(
                  fetchProfileDetailsAction: widget.fetchProfileDetailsAction,
                ),
              ),
              // Full name field
              FieldNameWidget(
                  fieldName: AppLocalizations.of(context).mEditProfileFullName,
                  isMandatory: true),
              TextInputField(
                focusNode: _fullNameFocus,
                keyboardType: TextInputType.name,
                controller: _fullNameController,
                hintText:
                    AppLocalizations.of(context).mEditProfileEnterYourFullname,
                validatorFuntion: (String value) =>
                    Validations.validateFullName(
                        value: value, context: context),
                onFieldSubmitted: (String value) {
                  EditProfileMandatoryHelper.fieldFocusChange(
                      context, _fullNameFocus, _dobFocus);
                },
              ),
              // DOB field
              FieldNameWidget(
                  fieldName: AppLocalizations.of(context).mEditProfileDob,
                  isMandatory: true),
              TextInputField(
                focusNode: _dobFocus,
                keyboardType: TextInputType.datetime,
                readOnly: true,
                isDate: true,
                controller: _dobController,
                hintText:
                    _dobController.text != null && _dobController.text != ''
                        ? _dobController.text
                        : AppLocalizations.of(context).mEditProfileChooseDate,
                onTap: () async {
                  DateTime newDate = await showDatePicker(
                      context: context,
                      initialDate: _dobDate == null
                          ? ((_dobController.text != null &&
                                      _dobController.text != '') &&
                                  !RegExp(r'[a-zA-Z]')
                                      .hasMatch(_dobController.text)
                              ? Helper.convertDDMMYYYYtoDateTime(
                                  _dobController.text)
                              : DateTime.now())
                          : _dobDate,
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100));
                  if (newDate == null) {
                    return null;
                  }
                  _dobDate = newDate;
                  _dobController.text =
                      Helper.convertDatetimetoDDMMYYYY(newDate);
                  EditProfileMandatoryHelper.fieldFocusChange(
                      context, _dobFocus, _genderFocus);
                },
                validatorFuntion: (String value) =>
                    Validations.validateDOB(value: value, context: context),
              ),
              // Gender
              FieldNameWidget(
                  fieldName: AppLocalizations.of(context).mEditProfileGender,
                  isMandatory: true),
              Focus(
                focusNode: _genderFocus,
                child: ValueListenableBuilder(
                    valueListenable: _selectedGender,
                    builder: (BuildContext context, String selectedGender,
                        Widget child) {
                      return SingleChoiceInputs(
                        itemCount:
                            EditProfileMandatoryHelper.genderRadio.length,
                        choices: EditProfileMandatoryHelper.genderRadio,
                        selected: selectedGender,
                        onChanged: (value) {
                          _selectedGender.value = value;
                          _genderValidateTextVisible.value = false;
                        },
                      );
                    }),
              ),
              ValueListenableBuilder(
                  valueListenable: _genderValidateTextVisible,
                  builder: (BuildContext context,
                      bool genderValidateTextVisible, Widget child) {
                    return Visibility(
                      visible: genderValidateTextVisible,
                      child:
                          Validations.validateField(field: EnglishLang.gender),
                    );
                  }),
              // Category
              FieldNameWidget(
                  fieldName: AppLocalizations.of(context).mEditProfileCategory,
                  isMandatory: true),
              Focus(
                focusNode: _categoryFocus,
                child: ValueListenableBuilder(
                    valueListenable: _selectedCategory,
                    builder: (BuildContext context, String selectedCategory,
                        Widget child) {
                      return SingleChoiceInputs(
                        itemCount:
                            EditProfileMandatoryHelper.categoryRadio.length,
                        choices: EditProfileMandatoryHelper.categoryRadio,
                        selected: selectedCategory,
                        onChanged: (value) {
                          _selectedCategory.value = value;
                          _categoryValidateTextVisible.value = false;
                        },
                      );
                    }),
              ),
              ValueListenableBuilder(
                  valueListenable: _categoryValidateTextVisible,
                  builder: (BuildContext context,
                      bool categoryValidateTextVisible, Widget child) {
                    return Visibility(
                      visible: categoryValidateTextVisible,
                      child: Validations.validateField(
                          field: EnglishLang.category),
                    );
                  }),
              // Mobile number
              OtpVerificationField(
                fieldFocus: _mobileNoFocus,
                parentContext: context,
                fieldController: _mobileNumberController,
                isToUpdateMobileNumber: widget.isToUpdateMobileNumber,
              ),
              // Primary email
              OtpVerificationField(
                fieldFocus: _primaryEmailFocus,
                parentContext: context,
                fieldController: _primaryEmailController,
                isEmailField: true,
              ),
              // Professional details
              Consumer<ProfileRepository>(builder: (BuildContext context,
                  ProfileRepository profileRepository, Widget child) {
                return Column(
                  children: [
                    // Group field
                    FieldNameWidget(
                      fieldName: AppLocalizations.of(context).mEditProfileGroup,
                      isMandatory: true,
                      isApprovalField: true,
                      isApproved: profileRepository.profileDetails.group !=
                              '' &&
                          (profileRepository.profileDetails.group.toString() ==
                              _groupController.text),
                      isInReview: profileRepository.inReview != null &&
                          profileRepository.inReview.containsKey('group'),
                    ),
                    SelectFromBottomSheet(
                      fieldName: AppLocalizations.of(context).mStaticGroup,
                      controller: _groupController,
                      callBack: () {
                        setState(() {});
                      },
                      isInReview: profileRepository.inReview != null &&
                          profileRepository.inReview.containsKey('group'),
                      validator: (value) => Validations.validateGroup(
                          value: value, context: context),
                    ),
                    // Designation field
                    FieldNameWidget(
                      fieldName:
                          AppLocalizations.of(context).mEditProfileDesignation,
                      isMandatory: true,
                      isApprovalField: true,
                      isApproved:
                          profileRepository.profileDetails.designation != '' &&
                              (profileRepository.profileDetails.designation
                                      .toString() ==
                                  _positionController.text),
                      isInReview: profileRepository.inReview != null &&
                          profileRepository.inReview.containsKey('designation'),
                    ),
                    SelectFromBottomSheet(
                      fieldName: EnglishLang.designation,
                      controller: _positionController,
                      isInReview: profileRepository.inReview != null &&
                          profileRepository.inReview.containsKey('designation'),
                      validator: (value) => Validations.validateGroup(
                          value: value, context: context),
                      callBack: () {
                        setState(() {});
                      },
                    ),
                  ],
                );
              }),
              // Pincode field
              FieldNameWidget(
                  fieldName: AppLocalizations.of(context).mEditProfilePinCode,
                  isMandatory: true),
              TextInputField(
                maxLength: 6,
                minLines: 1,
                focusNode: _pinCodeFocus,
                keyboardType: TextInputType.number,
                controller: _pinCodeController,
                hintText: AppLocalizations.of(context).mEditProfileTypeHere,
                validatorFuntion: (String value) =>
                    Validations.validatePinCode(context: context, value: value),
                onFieldSubmitted: (String value) {
                  _pinCodeFocus.unfocus();
                  EditProfileMandatoryHelper.fieldFocusChange(
                      context, _fullNameFocus, _dobFocus);
                },
              ),
              // Info text to get verified karmayogi badge
              Consumer<ProfileRepository>(builder: (BuildContext context,
                  ProfileRepository profileRepository, Widget child) {
                return profileRepository.profileDetails.verifiedKarmayogi
                    ? SizedBox()
                    : GetVerifiedKarmayogiInfo();
              }),
              SizedBox(
                height: 100,
              )
            ],
          ),
        ),
      ),
    );
  }
}
