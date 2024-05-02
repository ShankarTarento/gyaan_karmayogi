import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/util/edit_profile_mandatory_helper.dart';
import 'package:karmayogi_mobile/models/_models/profile_model.dart';
import 'package:karmayogi_mobile/respositories/_respositories/profile_repository.dart';
import 'package:karmayogi_mobile/services/_services/profile_service.dart';
import 'package:karmayogi_mobile/ui/widgets/_profile/field_name_widget.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:karmayogi_mobile/util/validations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OtpVerificationField extends StatefulWidget {
  final FocusNode fieldFocus;
  final BuildContext parentContext;
  final TextEditingController fieldController;
  final bool isToUpdateMobileNumber;
  final bool isEmailField;
  static final GlobalKey<_OtpVerificationFieldState> mobileKey = GlobalKey();
  static final GlobalKey<_OtpVerificationFieldState> emailKey = GlobalKey();
  OtpVerificationField(
      {Key key,
      this.fieldFocus,
      this.parentContext,
      this.fieldController,
      this.isToUpdateMobileNumber = false,
      this.isEmailField = false})
      : super(key: (isEmailField ? emailKey : mobileKey));

  @override
  State<OtpVerificationField> createState() => _OtpVerificationFieldState();
}

class _OtpVerificationFieldState extends State<OtpVerificationField> {
  final ProfileService profileService = ProfileService();
  List<String> _countryCodes = [];
  // final TextEditingController widget.mobileNoController = TextEditingController();
  final TextEditingController _mobileNoOTPController = TextEditingController();
  ValueNotifier<String> _countryCode = ValueNotifier('');
  bool _hasSendOTPRequest = false;
  bool _freezeMobileField = false;
  ValueNotifier<bool> _showResendOption = ValueNotifier(false);
  ValueNotifier<String> _timeFormat = ValueNotifier('');

  final FocusNode _otpFocus = FocusNode();

  bool _hasVerified = false;
  String mobile;
  Timer _timer;
  var _editProfileConfig;

  int _resendOTPTime = 180;

  RegExp regExpEmail = RegExp(
      r"[a-z0-9_-]+(?:\.[a-z0-9_-]+)*@((?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?){2,}\.){1,3}(?:\w){2,}");

  @override
  void initState() {
    super.initState();
    _populateMobileNumber();
    _getCountryCodes();
    _getResendTimeOTP();
    if (widget.isToUpdateMobileNumber) {
      Future.delayed(Duration(milliseconds: 1000), () {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          FocusScope.of(context).requestFocus(widget.fieldFocus);
        });
        setState(() {});
      });
    }
  }

  _populateMobileNumber() {
    Profile profileDetails =
        Provider.of<ProfileRepository>(context, listen: false).profileDetails;
    dynamic personalDetails = profileDetails.personalDetails;
    if (widget.isEmailField) {
      widget.fieldController.text = profileDetails.primaryEmail;
    } else {
      widget.fieldController.text = personalDetails['mobile'] != null
          ? personalDetails['mobile'].toString()
          : '';
    }
  }

  Future<void> _getResendTimeOTP() async {
    _editProfileConfig = await profileService.getProfileEditConfig();
    if (_editProfileConfig['resendOTPTime'] != null && mounted) {
      _resendOTPTime = _editProfileConfig['resendOTPTime'];
    }
  }

  _getCountryCodes() async {
    _countryCodes = await EditProfileMandatoryHelper.getNationalities(context);
  }

  void _startTimer() {
    _timeFormat.value = EditProfileMandatoryHelper.formatHHMMSS(_resendOTPTime);
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_resendOTPTime == 0) {
          timer.cancel();
          _showResendOption.value = true;
        } else {
          if (mounted) {
            _resendOTPTime--;
          }
        }
        _timeFormat.value =
            EditProfileMandatoryHelper.formatHHMMSS(_resendOTPTime);
      },
    );
  }

  _sendOTPToVerifyNumber() async {
    final response = widget.isEmailField
        ? await profileService
            .generatePrimaryEmailOTP(widget.fieldController.text.trim())
        : await profileService
            .generateMobileNumberOTP(widget.fieldController.text.trim());
    if (response['params']['errmsg'] == null ||
        response['params']['errmsg'] == '') {
      Helper.showSnackBarMessage(
          context: context,
          text: widget.isEmailField
              ? AppLocalizations.of(context).mEditProfileOtpSentToEmail
              : AppLocalizations.of(context).mEditProfileOtpSentToMobile,
          bgColor: AppColors.positiveLight);
      setState(() {
        _hasSendOTPRequest = true;
        _freezeMobileField = true;
        _mobileNoOTPController.clear();
        _hasVerified = false;
        EditProfileMandatoryHelper.fieldFocusChange(
            widget.parentContext, widget.fieldFocus, _otpFocus);
        _resendOTPTime = _editProfileConfig['resendOTPTime'];
        _startTimer();
      });
    } else {
      Helper.showSnackBarMessage(
          context: context,
          text: response['params']['errmsg'].toString(),
          bgColor: AppColors.negativeLight);
    }
  }

  _verifyOTP(otp) async {
    final response = widget.isEmailField
        ? await profileService.verifyPrimaryEmailOTP(
            widget.fieldController.text.trim(), otp)
        : await profileService.verifyMobileNumberOTP(
            widget.fieldController.text.trim(), otp);

    if (response['params']['errmsg'] == null ||
        response['params']['errmsg'] == '') {
      var profileUpdateResponse;
      //call extPatch
      if (widget.isEmailField) {
        profileUpdateResponse = await profileService.updateUserPrimaryEmail(
            email: widget.fieldController.text.trim(),
            contextToken: response['result']['contextToken']);
      } else {
        Map profileData = {
          "personalDetails": {
            "mobile": int.parse(widget.fieldController.text.trim()),
            "phoneVerified": true
          },
        };
        profileUpdateResponse =
            await profileService.updateProfileDetails(profileData);
      }
      if (profileUpdateResponse['params']['status'] == 'success' ||
          profileUpdateResponse['params']['status'] == 'SUCCESS') {
        Helper.showSnackBarMessage(
            context: context,
            text: widget.isEmailField
                ? AppLocalizations.of(context).mEditProfileEmailVerifiedMessage
                : AppLocalizations.of(context)
                    .mEditProfileMobileVerifiedMessage,
            bgColor: AppColors.positiveLight);
        await Provider.of<ProfileRepository>(context, listen: false)
            .getProfileDetailsById('');
        setState(() {
          _hasSendOTPRequest = false;
          _freezeMobileField = false;
          _hasVerified = true;
        });
      } else {
        Helper.showSnackBarMessage(
            context: context,
            text: profileUpdateResponse['params']['errmsg'].toString(),
            bgColor: AppColors.negativeLight);
      }
    } else {
      Helper.showSnackBarMessage(
          context: context,
          text: response['params']['errmsg'].toString(),
          bgColor: AppColors.negativeLight);
    }
  }

  @override
  void dispose() {
    super.dispose();
    widget.fieldController.dispose();
    _mobileNoOTPController.dispose();
    _otpFocus.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileRepository>(
        builder: (context, profileRepository, _) {
      if (widget.isEmailField) {
        _hasVerified = profileRepository.profileDetails.primaryEmail ==
            widget.fieldController.text.trim();
      } else {
        _hasVerified = profileRepository.profileDetails
                    .rawDetails['profileDetails']['personalDetails'] !=
                null
            ? profileRepository.profileDetails.rawDetails['profileDetails']
                ['personalDetails']['phoneVerified']
            : false;
      }
      mobile = profileRepository.profileDetails.rawDetails['profileDetails']
                  ['personalDetails'] !=
              null
          ? profileRepository.profileDetails
              .rawDetails['profileDetails']['personalDetails']['mobile']
              .toString()
          : '';
      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FieldNameWidget(
                  fieldName: widget.isEmailField
                      ? AppLocalizations.of(context).mEditProfilePrimaryEmail
                      : AppLocalizations.of(context).mEditProfileMobileNumber,
                  isMandatory: true),
              _freezeMobileField
                  ? Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: TextButton(
                          onPressed: () {
                            setState(() {
                              _freezeMobileField = false;
                              EditProfileMandatoryHelper.fieldFocusChange(
                                  widget.parentContext,
                                  _otpFocus,
                                  widget.fieldFocus);
                            });
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size(50, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Icon(
                                  Icons.edit,
                                  size: 18,
                                ),
                              ),
                              Text(
                                AppLocalizations.of(context).mEditProfileEdit,
                                style: GoogleFonts.lato(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              )
                            ],
                          )),
                    )
                  : SizedBox()
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
                alignment: Alignment.centerLeft,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Visibility(
                      visible: !widget.isEmailField,
                      child: Container(
                          decoration: BoxDecoration(
                              color: _freezeMobileField
                                  ? AppColors.grey04
                                  : Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4)),
                              border: Border.all(color: AppColors.grey16)),
                          height: 48.0,
                          width: MediaQuery.of(context).size.width * 0.165,
                          child: ValueListenableBuilder(
                              valueListenable: _countryCode,
                              builder: (BuildContext context,
                                  String countryCode, Widget child) {
                                return DropdownButton<String>(
                                  value: countryCode.isNotEmpty
                                      ? countryCode
                                      : null,
                                  icon: Visibility(
                                      visible: false,
                                      child: Icon(Icons.arrow_downward)),
                                  hint: Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Container(
                                        alignment: Alignment.center,
                                        child: Text('+91')),
                                  ),
                                  iconSize: 26,
                                  elevation: 16,
                                  style: TextStyle(color: AppColors.greys87),
                                  underline: Container(
                                    // height: 2,
                                    color: AppColors.lightGrey,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                  selectedItemBuilder: (BuildContext context) {
                                    return _countryCodes
                                        .map<Widget>((String item) {
                                      return Row(
                                        children: [
                                          Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  15.0, 15.0, 0, 15.0),
                                              child: Text(
                                                item,
                                                style: GoogleFonts.lato(
                                                  color: AppColors.greys87,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ))
                                        ],
                                      );
                                    }).toList();
                                  },
                                  onChanged: !_freezeMobileField
                                      ? (String newValue) {
                                          _countryCode.value = newValue;
                                        }
                                      : null,
                                  items: _countryCodes
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value.toString()),
                                    );
                                  }).toList(),
                                );
                              })),
                    ),
                    Container(
                        height: 70,
                        width: widget.isEmailField
                            ? MediaQuery.of(context).size.width - 32
                            : MediaQuery.of(context).size.width * 0.725,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Focus(
                          child: TextFormField(
                            textInputAction: TextInputAction.next,
                            focusNode: widget.fieldFocus,
                            enabled: !_freezeMobileField,
                            onFieldSubmitted: (term) {},
                            onChanged: (value) {
                              setState(() {
                                _hasSendOTPRequest = false;
                                _hasVerified = false;
                                if (value.trim().length > 9 &&
                                    (mobile == value.trim())) {
                                  // widget.parentAction();
                                }
                              });
                            },
                            readOnly: _freezeMobileField,
                            controller: widget.fieldController,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            maxLength: widget.isEmailField ? null : 10,
                            validator: (String value) => widget.isEmailField
                                ? Validations.validatePrimaryEmail(
                                    value: value, context: context)
                                : Validations.validateMobile(
                                    context: context, value: value),
                            style: GoogleFonts.lato(fontSize: 14.0),
                            keyboardType: widget.isEmailField
                                ? TextInputType.emailAddress
                                : TextInputType.phone,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: _freezeMobileField
                                  ? AppColors.grey04
                                  : Colors.white,
                              counterText: '',
                              suffixIcon: (!widget.isEmailField &&
                                          _hasVerified == true &&
                                          widget.fieldController.text
                                                  .toString()
                                                  .trim() ==
                                              mobile.toString().trim()) ||
                                      (widget.isEmailField &&
                                          profileRepository.profileDetails
                                                  .primaryEmail ==
                                              widget.fieldController.text
                                                  .trim())
                                  ? Icon(
                                      Icons.check_circle,
                                      color: AppColors.positiveLight,
                                    )
                                  : null,
                              contentPadding:
                                  EdgeInsets.fromLTRB(16.0, 0.0, 20.0, 0.0),
                              border: const OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: AppColors.grey16)),
                              hintText: AppLocalizations.of(context)
                                  .mEditProfileTypeHere,
                              helperText: widget.isEmailField
                                  ? (regExpEmail.hasMatch(
                                          widget.fieldController.text.trim())
                                      ? null
                                      : AppLocalizations.of(context)
                                          .mEditProfileAddValidEmail)
                                  : (((!widget.isEmailField &&
                                              widget.fieldController.text
                                                      .trim()
                                                      .length ==
                                                  10) &&
                                          RegExp(r'^\s*(?:\+?(\d{1,3}))?[-. (]*(\d{3})[-. )]*(\d{3})[-. ]*(\d{4})(?: *x(\d+))?\s*$')
                                              .hasMatch(widget
                                                  .fieldController.text
                                                  .trim()))
                                      ? null
                                      : AppLocalizations.of(context)
                                          .mEditProfilePleaseAddValidNumber),
                              hintStyle: GoogleFonts.lato(
                                  color: AppColors.grey40,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w400),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: AppColors.primaryThree, width: 1.0),
                              ),
                            ),
                          ),
                        )),
                  ],
                )),
          ),
          ((widget.isEmailField
                          ? profileRepository.profileDetails.primaryEmail
                          : mobile.toString()) !=
                      widget.fieldController.text.trim() ||
                  (_hasVerified == false))
              ? !_hasSendOTPRequest
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.6,
                              child: Text(
                                widget.isEmailField
                                    ? AppLocalizations.of(context)
                                        .mEditProfilePleaseVerifyYourEmail
                                    : AppLocalizations.of(context)
                                        .mEditProfilePleaseVerifyYourNumber,
                                style: GoogleFonts.lato(
                                    fontWeight: FontWeight.w500, height: 1.5),
                              )),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: AppColors.primaryThree,
                                minimumSize: const Size.fromHeight(48),
                              ),
                              onPressed: (!widget.isEmailField &&
                                          widget.fieldController.text
                                                  .trim()
                                                  .length ==
                                              10) ||
                                      Validations.isValidEmail(
                                          context: context,
                                          value: widget.fieldController.text
                                              .trim())
                                  ? () async {
                                      await _sendOTPToVerifyNumber();
                                    }
                                  : null,
                              child: Text(
                                AppLocalizations.of(context)
                                    .mEditProfileSendOtp,
                                style: GoogleFonts.lato(
                                    height: 1.429,
                                    letterSpacing: 0.5,
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                // height: 70,
                                width: MediaQuery.of(context).size.width * 0.45,
                                decoration: BoxDecoration(
                                  // color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Focus(
                                  autofocus: true,
                                  child: TextFormField(
                                    autofocus: true,
                                    textInputAction: TextInputAction.next,
                                    controller: _mobileNoOTPController,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    focusNode: _otpFocus,
                                    obscureText: true,
                                    validator: (String value) {
                                      if (value.isEmpty) {
                                        return AppLocalizations.of(context)
                                            .mStaticPleaseEnterOtp;
                                      } else
                                        return null;
                                    },
                                    style: GoogleFonts.lato(fontSize: 14.0),
                                    keyboardType: TextInputType.phone,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: EdgeInsets.fromLTRB(
                                          16.0, 0.0, 20.0, 0.0),
                                      border: const OutlineInputBorder(),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: AppColors.grey16)),
                                      hintText: AppLocalizations.of(context)
                                          .mEditProfileEnterOtp,
                                      hintStyle: GoogleFonts.lato(
                                          color: AppColors.grey40,
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w400),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: AppColors.primaryThree,
                                            width: 1.0),
                                      ),
                                    ),
                                  ),
                                )),
                            Container(
                              // height: 45,
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: AppColors.primaryThree,
                                  minimumSize: const Size.fromHeight(48),
                                ),
                                onPressed: () async {
                                  await _verifyOTP(
                                      _mobileNoOTPController.text.trim());
                                },
                                child: Text(
                                  AppLocalizations.of(context)
                                      .mEditProfileVerifyOtp,
                                  style: GoogleFonts.lato(
                                      height: 1.429,
                                      letterSpacing: 0.5,
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ],
                        ),
                        ValueListenableBuilder(
                            valueListenable: _showResendOption,
                            builder: (BuildContext context,
                                bool showResendOption, Widget child) {
                              return SizedBox(
                                child: !showResendOption
                                    ? ValueListenableBuilder(
                                        valueListenable: _timeFormat,
                                        builder: (BuildContext context,
                                            String timeFormat, Widget child) {
                                          return Container(
                                            padding: EdgeInsets.only(top: 16),
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                                '${AppLocalizations.of(context).mProfileResendOTPAfter}' +
                                                    '$timeFormat'),
                                          );
                                        })
                                    : Container(
                                        alignment: Alignment.topLeft,
                                        padding: EdgeInsets.only(top: 4),
                                        child: TextButton(
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.zero,
                                              minimumSize: Size(50, 50),
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                            onPressed: () {
                                              _sendOTPToVerifyNumber();
                                              _showResendOption.value = false;
                                              _resendOTPTime = 180;
                                            },
                                            child: Text(
                                                AppLocalizations.of(context)
                                                    .mEditProfileResendOtp)),
                                      ),
                              );
                            })
                      ],
                    )
              : Center(),
        ],
      );
    });
  }
}
