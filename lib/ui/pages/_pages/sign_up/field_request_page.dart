import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/feedback/constants.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/services/_services/profile_service.dart';
import 'package:karmayogi_mobile/services/_services/registration_service.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/sign_up/request_successfully_regesitered_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FieldRequestPage extends StatefulWidget {
  final String fullName;
  final String mobile;
  final String email;
  final bool phoneVerified;
  final bool isEmailVerified;
  final String fieldValue;
  final parentAction;
  final String fieldName;
  FieldRequestPage(
      {Key key,
      this.fullName,
      this.mobile,
      this.email,
      this.phoneVerified = false,
      this.isEmailVerified = false,
      this.fieldValue,
      this.parentAction,
      this.fieldName})
      : super(key: key);
  @override
  State<FieldRequestPage> createState() => _FieldRequestPageState();
}

class _FieldRequestPageState extends State<FieldRequestPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _fieldController = TextEditingController();
  final TextEditingController _fieldDescriptionController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _emailOTPController = TextEditingController();

  final TextEditingController _mobileNoController = TextEditingController();
  final TextEditingController _mobileNoOTPController = TextEditingController();

  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _fieldFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _mobileNumberFocus = FocusNode();
  final FocusNode _fieldDescriptionFocus = FocusNode();
  final FocusNode _otpFocus = FocusNode();
  final FocusNode _emailOtpFocus = FocusNode();

  final RegistrationService registrationService = RegistrationService();
  final ProfileService profileService = ProfileService();

  TextEditingController _searchController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _firstName;
  // String _selectedPositionId;
  String email;

  bool _isConfirmed = false;
  // bool _isAcceptedTC = false;
  bool _hasSendOTPRequest = false;
  bool _hasSendEmailOTPRequest = false;
  bool _freezeEmailField = false;
  bool _showEmailResendOption = false;
  bool _showResendOption = false;
  bool _freezeMobileField = false;
  int _resendOTPTime = RegistrationType.resendOtpTimeLimit;
  int _resendEmailOTPTime = RegistrationType.resendEmailOtpTimeLimit;

  bool _isMobileNumberVerified = false;
  bool _isEmailVerified = false;
  String _timeFormat;
  String _timeFormatEmail;

  Timer _timer;
  Timer _timerEmail;

  RegExp regExpEmail = RegExp(
      r"[a-z0-9_-]+(?:\.[a-z0-9_-]+)*@((?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?){2,}\.){1,3}(?:\w){2,}");

  @override
  void initState() {
    super.initState();
    _firstName = widget.fullName;
    _firstNameController.text = widget.fullName;
    _emailController.text = widget.email;
    _mobileNoController.text = widget.mobile;
    _isMobileNumberVerified = widget.phoneVerified;
    _isEmailVerified = widget.isEmailVerified;
    Future.delayed(Duration(milliseconds: 10), () {
      if (widget.fieldName != AppLocalizations.of(context).mStaticDomain) {
        _fieldController.text = widget.fieldValue;
      }
    });
  }

  Future<void> _fieldRequest() async {
    Response response;
    try {
      response = await registrationService.requestForRegistrationField(
          _firstName,
          _emailController.text,
          _fieldController.text,
          _fieldDescriptionController.text,
          _mobileNoController.text,
          // isPosition: widget.fieldName == EnglishLang.position,
          isOrg: widget.fieldName ==
              AppLocalizations.of(context).mRegisterorganisation,
          isDomain:
              widget.fieldName == AppLocalizations.of(context).mStaticDomain);
      var responseBody = jsonDecode(response.body);

      if (responseBody["result"]["status"] == "OK") {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => RequestSuccessfullyRegisteredPage()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                AppLocalizations.of(context).mStaticSomethingWrongTryLater),
            backgroundColor: Theme.of(context).errorColor,
          ),
        );
      }
    } catch (err) {
      print(err);
      return err;
    }
  }

  String formatHHMMSS(int seconds) {
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

  void _startTimer() {
    _resendOTPTime = 180;
    _timeFormat = formatHHMMSS(_resendOTPTime);
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_resendOTPTime == 0) {
          setState(() {
            timer.cancel();
            _showResendOption = true;
          });
        } else {
          setState(() {
            _resendOTPTime--;
          });
        }
        _timeFormat = formatHHMMSS(_resendOTPTime);
      },
    );
  }

  _sendOTPToVerifyNumber() async {
    final response =
        await profileService.generateMobileNumberOTP(_mobileNoController.text);
    if (response['params']['errmsg'] == null ||
        response['params']['errmsg'] == '') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).mStaticOtpSentToMobile,
              style: GoogleFonts.lato(
                color: Colors.white,
              )),
          backgroundColor: AppColors.positiveLight,
        ),
      );
      setState(() {
        _hasSendOTPRequest = true;
        _freezeMobileField = true;
        _mobileNoOTPController?.clear();
        _showResendOption = false;
        _resendOTPTime = 180;
      });
      FocusScope.of(context).requestFocus(_otpFocus);
      _startTimer();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['params']['errmsg'].toString(),
              style: GoogleFonts.lato(
                color: Colors.white,
              )),
          backgroundColor: AppColors.primaryTwo,
        ),
      );
    }
  }

  _verifyOTP(otp) async {
    final response = await profileService.verifyMobileNumberOTP(
        _mobileNoController.text, otp);

    if (response['params']['errmsg'] == null ||
        response['params']['errmsg'] == '') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(AppLocalizations.of(context).mStaticMobileVerifiedMessage,
                  style: GoogleFonts.lato(
                    color: Colors.white,
                  )),
          backgroundColor: AppColors.positiveLight,
        ),
      );
      setState(() {
        _hasSendOTPRequest = false;
        _isMobileNumberVerified = true;
        _timer.cancel();
        widget.parentAction(_mobileNoController.text, _isMobileNumberVerified);
      });
      FocusScope.of(context).requestFocus(_fieldFocus);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['params']['errmsg'].toString(),
              style: GoogleFonts.lato(
                color: Colors.white,
              )),
          backgroundColor: AppColors.primaryTwo,
        ),
      );
    }
    setState(() {
      _freezeMobileField = false;
    });
  }

  Widget _buildVerifyEmailOtp() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  width: MediaQuery.of(context).size.width * 0.475,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Focus(
                    child: TextFormField(
                      obscureText: true,
                      textInputAction: TextInputAction.next,
                      focusNode: _emailOtpFocus,
                      controller: _emailOTPController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (String value) {
                        if (value.isEmpty) {
                          return AppLocalizations.of(context)
                              .mStaticPleaseEnterOtp;
                        } else
                          return null;
                      },
                      style: GoogleFonts.lato(fontSize: 14.0),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding:
                            EdgeInsets.fromLTRB(16.0, 0.0, 20.0, 0.0),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.grey16)),
                        hintText:
                            AppLocalizations.of(context).mRegisterenterOTP,
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
              Container(
                width: MediaQuery.of(context).size.width * 0.4,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryThree,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: () async {
                    await _verifyEmailOTP(_emailOTPController.text);
                  },
                  child: Text(
                    AppLocalizations.of(context).mRegisterverifyOTP,
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
          !_showEmailResendOption && !_isEmailVerified
              ? Container(
                  padding: EdgeInsets.only(top: 16),
                  alignment: Alignment.topLeft,
                  child: Text(
                    '${AppLocalizations.of(context).mRegisterresendOTPAfter} $_timeFormatEmail',
                    style: GoogleFonts.lato(),
                  ),
                )
              : Container(
                  alignment: Alignment.topLeft,
                  // padding: EdgeInsets.only(top: 8),
                  child: TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size(50, 50),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        _sendOTPToVerifyEmail();
                        setState(() {
                          _showEmailResendOption = false;
                          _resendEmailOTPTime =
                              RegistrationType.resendEmailOtpTimeLimit;
                        });
                      },
                      child: Text(
                          AppLocalizations.of(context).mRegisterresendOTP)),
                ),
        ],
      ),
    );
  }

  void _startEmailOtpTimer() {
    _timeFormatEmail = formatHHMMSS(_resendEmailOTPTime);
    const oneSec = const Duration(seconds: 1);
    _timerEmail = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_resendEmailOTPTime == 0) {
          setState(() {
            timer.cancel();
            _showEmailResendOption = true;
          });
        } else {
          if (mounted) {
            setState(() {
              _resendEmailOTPTime--;
            });
          }
        }
        _timeFormatEmail = formatHHMMSS(_resendEmailOTPTime);
      },
    );
  }

  _sendOTPToVerifyEmail() async {
    final response =
        await profileService.generateEmailOTP(_emailController.text);
    if (response['params']['errmsg'] == null ||
        response['params']['errmsg'] == '') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).mStaticOtpSentToEmail,
              style: GoogleFonts.lato(
                color: Colors.white,
              )),
          backgroundColor: AppColors.positiveLight,
        ),
      );
      setState(() {
        _hasSendEmailOTPRequest = true;
        _freezeEmailField = true;
        _emailOTPController?.clear();
        _showEmailResendOption = false;
        _resendEmailOTPTime = RegistrationType.resendEmailOtpTimeLimit;
      });
      FocusScope.of(context).requestFocus(_otpFocus);
      _startEmailOtpTimer();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['params']['errmsg'].toString(),
              style: GoogleFonts.lato(
                color: Colors.white,
              )),
          backgroundColor: AppColors.primaryTwo,
        ),
      );
    }
  }

  _verifyEmailOTP(otp) async {
    final response =
        await profileService.verifyEmailOTP(_emailController.text, otp);

    if (response['params']['errmsg'] == null ||
        response['params']['errmsg'] == '') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(AppLocalizations.of(context).mStaticEmailVerifiedMessage,
                  style: GoogleFonts.lato(
                    color: Colors.white,
                  )),
          backgroundColor: AppColors.positiveLight,
        ),
      );
      setState(() {
        _hasSendEmailOTPRequest = false;
        _isEmailVerified = true;
        _timerEmail.cancel();
      });
      FocusScope.of(context).requestFocus(_emailOtpFocus);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['params']['errmsg'].toString(),
              style: GoogleFonts.lato(
                color: Colors.white,
              )),
          backgroundColor: AppColors.primaryTwo,
        ),
      );
    }
    setState(() {
      _freezeEmailField = false;
    });
  }

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  Widget _buildFirstNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
              text: AppLocalizations.of(context).mRegisterfullName,
              style: GoogleFonts.lato(
                  color: AppColors.greys87,
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                  letterSpacing: 0.25,
                  fontSize: 14),
              children: [
                TextSpan(
                    text: ' *',
                    style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w700,
                        fontSize: 14))
              ]),
        ),
        Container(
          padding: EdgeInsets.only(top: 8),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            // color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Focus(
            child: TextFormField(
              textInputAction: TextInputAction.next,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (String value) {
                if (value.isEmpty) {
                  return AppLocalizations.of(context)
                      .mRegisterfullNameMandatory;
                } else if (!RegExp(r"^[a-zA-Z' ]+$").hasMatch(value)) {
                  return AppLocalizations.of(context).mRegisterfullNameWitoutSp;
                } else
                  return null;
              },
              focusNode: _firstNameFocus,
              controller: _firstNameController,
              onSaved: (String value) {
                _firstName = value;
              },
              onFieldSubmitted: (value) {
                if (value.isEmpty && !_formKey.currentState.validate()) {
                  return;
                }
                _fieldFocusChange(context, _firstNameFocus, _emailFocus);
              },
              style: GoogleFonts.lato(fontSize: 14.0),
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                errorMaxLines: 3,
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.fromLTRB(16.0, 14.0, 0.0, 14.0),
                border: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: AppColors.grey16, width: 1.0)),
                hintText: AppLocalizations.of(context).mProfileEnterFullName,
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
          ),
        ),
        SizedBox(
          height: 24,
        )
      ],
    );
  }

  Widget _buildRequestField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
              text: widget.fieldName,
              style: GoogleFonts.lato(
                  color: AppColors.greys87,
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                  letterSpacing: 0.25,
                  fontSize: 14),
              children: [
                TextSpan(
                    text: ' *',
                    style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w700,
                        fontSize: 14))
              ]),
        ),
        Container(
          padding: EdgeInsets.only(top: 8),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
          ),
          child: TextFormField(
            textInputAction: TextInputAction.next,
            controller: _fieldController,
            onFieldSubmitted: (value) {
              if (value.isEmpty && !_formKey.currentState.validate()) {
                return;
              }
              _fieldFocusChange(context, _fieldFocus, _fieldDescriptionFocus);
            },
            focusNode: _fieldFocus,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (String value) {
              if (widget.fieldName ==
                  AppLocalizations.of(context).mRegisterorganisation) {
                if (widget.fieldName.isEmpty) {
                  return AppLocalizations.of(context)
                      .mRegisterOrganisationMandatory;
                } else {
                  return null;
                }
                // return EnglishLang.organisationMandate;
              }
              if (widget.fieldName == EnglishLang.domain) {
                RegExp regExp = RegExp(
                    r"((?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?){2,}[^A-Za-z0-9]){1,2}(?:\w){2,}");
                if (value.isEmpty) {
                  return '${AppLocalizations.of(context).mStaticEnterYourDomain} (${AppLocalizations.of(context).mStaticDomainHintText})';
                }
                String matchedString = regExp.stringMatch(value);
                if (matchedString == null ||
                    matchedString.isEmpty ||
                    matchedString.length != value.length) {
                  return AppLocalizations.of(context).mStaticAddValidEmail;
                }
                return null;
              } else {
                if (value.isEmpty) {
                  return AppLocalizations.of(context).mStaticPositionMandate;
                } else if (!RegExp(r"^[a-zA-Z0-9' &\-()]+$").hasMatch(value)) {
                  return 'Only alphabets, numbers, space, &, -, and () are allowed.';
                } else
                  return null;
              }
            },
            style: GoogleFonts.lato(fontSize: 14.0),
            keyboardType: TextInputType.name,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.fromLTRB(16.0, 14.0, 0.0, 14.0),
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.grey16, width: 1.0)),
              hintText:
                  widget.fieldName == AppLocalizations.of(context).mStaticDomain
                      ? AppLocalizations.of(context).mStaticDomainHintText
                      : EnglishLang.enterYourPosition.replaceAll(
                          EnglishLang.position.toLowerCase(),
                          widget.fieldName.toLowerCase()),
              hintStyle: GoogleFonts.lato(
                  color: AppColors.grey40,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: AppColors.primaryThree, width: 1.0),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 16,
        )
      ],
    );
  }

  Widget _buildRequestDetailsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
              text:
                  AppLocalizations.of(context).mStaticDomain == widget.fieldName
                      ? AppLocalizations.of(context)
                          .mStaticDescribeOrganisationDetails
                          .replaceAll("organisation", "domain")
                      : AppLocalizations.of(context)
                          .mStaticDescribeOrganisationDetails,
              style: GoogleFonts.lato(
                  color: AppColors.greys87,
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                  letterSpacing: 0.25,
                  fontSize: 14),
              children: [
                // TextSpan(
                //     text: ' *',
                //     style: TextStyle(
                //         color: Colors.red,
                //         fontWeight: FontWeight.w700,
                //         fontSize: 14))
              ]),
        ),
        Container(
          padding: EdgeInsets.only(top: 8),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
          ),
          child: TextFormField(
            maxLines: 4,
            textInputAction: TextInputAction.next,
            controller: _fieldDescriptionController,
            // onFieldSubmitted: (value) {
            //   if (value.isEmpty && !_formKey.currentState.validate()) {
            //     return;
            //   }
            // },
            // autovalidateMode: AutovalidateMode.onUserInteraction,
            // validator: (String value) {
            //   if (value.isEmpty) {
            //     return EnglishLang.positionDescriptionMandate;
            //   } else
            //     return null;
            // },
            focusNode: _fieldDescriptionFocus,
            style: GoogleFonts.lato(fontSize: 14.0),
            keyboardType: TextInputType.name,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.fromLTRB(16.0, 14.0, 0.0, 14.0),
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.grey16, width: 1.0)),
              hintText: AppLocalizations.of(context).mStaticTypeHere,
              hintStyle: GoogleFonts.lato(
                  color: AppColors.grey40,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: AppColors.primaryThree, width: 1.0),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
              text: TextSpan(
                  text: AppLocalizations.of(context).mRegistermobileNumber,
                  style: GoogleFonts.lato(
                      color: AppColors.greys87,
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                      letterSpacing: 0.25,
                      fontSize: 14),
                  children: [
                    TextSpan(
                        text: ' *',
                        style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                            fontSize: 16))
                  ]),
            ),
            _freezeMobileField
                ? TextButton(
                    onPressed: () {
                      setState(() {
                        _freezeMobileField = false;
                        _otpFocus.unfocus();
                        FocusScope.of(_otpFocus.context)
                            .requestFocus(_mobileNumberFocus);
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
                          AppLocalizations.of(context).mStaticEdit,
                          style: GoogleFonts.lato(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        )
                      ],
                    ))
                : Center()
          ],
        ),
        Container(
            // height: 70,
            padding: EdgeInsets.only(top: 6),
            // width: MediaQuery.of(context).size.width * 0.725,
            decoration: BoxDecoration(
              // color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Focus(
              child: TextFormField(
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (term) {
                  // FocusScope.of(context).unfocus();
                },
                focusNode: _mobileNumberFocus,
                onChanged: (value) {
                  setState(() {
                    _hasSendOTPRequest = false;
                    _isMobileNumberVerified = false;
                  });
                },
                maxLength: 10,
                readOnly: _freezeMobileField || _isMobileNumberVerified,
                controller: _mobileNoController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (String value) {
                  if (value.trim().isEmpty) {
                    return AppLocalizations.of(context)
                        .mRegisterMobileNumberMandatory;
                  } else if (value.trim().length != 10 ||
                      !RegExp(r'^\s*(?:\+?(\d{1,3}))?[-. (]*(\d{3})[-. )]*(\d{3})[-. ]*(\d{4})(?: *x(\d+))?\s*$')
                          .hasMatch(value)) {
                    return AppLocalizations.of(context)
                        .mRegistervalidMobilenumber;
                  } else
                    return null;
                },
                style: GoogleFonts.lato(fontSize: 14.0),
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  filled: true,
                  fillColor:
                      _freezeMobileField ? AppColors.grey04 : Colors.white,
                  counterText: '',
                  suffixIcon: _isMobileNumberVerified
                      ? Icon(
                          Icons.check_circle,
                          color: AppColors.positiveLight,
                        )
                      : null,
                  contentPadding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.grey16)),
                  hintText:
                      AppLocalizations.of(context).mStaticEnterYourMobileNumber,
                  helperText: (_isMobileNumberVerified ||
                          (_mobileNoController.text.trim().length == 10 &&
                              RegExp(r'^\s*(?:\+?(\d{1,3}))?[-. (]*(\d{3})[-. )]*(\d{3})[-. ]*(\d{4})(?: *x(\d+))?\s*$')
                                  .hasMatch(_mobileNoController.text.trim())))
                      ? null
                      : AppLocalizations.of(context).mRegistervalidMobilenumber,
                  hintStyle: GoogleFonts.lato(
                      color: AppColors.grey40,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400),
                  enabled: !_freezeMobileField,
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: AppColors.primaryThree, width: 1.0),
                  ),
                ),
              ),
            )),
        _isMobileNumberVerified
            ? Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size(50, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        setState(() {
                          _isMobileNumberVerified = false;
                        });
                        FocusScope.of(context).requestFocus(_mobileNumberFocus);
                      },
                      child: Text(
                        AppLocalizations.of(context).mStaticChangeMobileNumber,
                        style: GoogleFonts.lato(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppColors.primaryThree),
                      ),
                    )),
              )
            : Center(),
        !_hasSendOTPRequest && !_isMobileNumberVerified
            ? Padding(
                padding: (_mobileNoController.text.trim().length == 10 &&
                        RegExp(r'^\s*(?:\+?(\d{1,3}))?[-. (]*(\d{3})[-. )]*(\d{3})[-. ]*(\d{4})(?: *x(\d+))?\s*$')
                            .hasMatch(_mobileNoController.text.trim()))
                    ? EdgeInsets.only(top: 16)
                    : EdgeInsets.zero,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: Text(
                          AppLocalizations.of(context).mRegisterVerifyMobile,
                          style: GoogleFonts.lato(
                              fontWeight: FontWeight.w500, height: 1.5),
                        )),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.3,
                      padding: EdgeInsets.only(top: 8),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: AppColors.primaryThree,
                          minimumSize: const Size.fromHeight(48),
                        ),
                        onPressed: _mobileNoController.text.trim().length == 10
                            ? () async {
                                await _sendOTPToVerifyNumber();
                              }
                            : null,
                        child: Text(
                          AppLocalizations.of(context).mStaticSendOtp,
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
            : !_isMobileNumberVerified
                ? Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                // height: 70,
                                width:
                                    MediaQuery.of(context).size.width * 0.475,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Focus(
                                  child: TextFormField(
                                    obscureText: true,
                                    textInputAction: TextInputAction.next,
                                    focusNode: _otpFocus,
                                    // onFieldSubmitted: (term) {
                                    //   FocusScope.of(context)
                                    //       .requestFocus(_ministryFocus);
                                    // },
                                    controller: _mobileNoOTPController,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    validator: (String value) {
                                      if (value.isEmpty) {
                                        return AppLocalizations.of(context)
                                            .mStaticPleaseEnterOtp;
                                      } else
                                        return null;
                                    },
                                    style: GoogleFonts.lato(fontSize: 14.0),
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: EdgeInsets.fromLTRB(
                                          16.0, 0.0, 20.0, 0.0),
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: AppColors.grey16)),
                                      hintText: AppLocalizations.of(context)
                                          .mStaticEnterOtp,
                                      // helperText: EnglishLang.addValidNumber,
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
                                  await _verifyOTP(_mobileNoOTPController.text);
                                },
                                child: Text(
                                  AppLocalizations.of(context).mStaticVerifyOtp,
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
                        !_showResendOption && !_isMobileNumberVerified
                            ? Container(
                                padding: EdgeInsets.only(top: 16),
                                alignment: Alignment.topLeft,
                                child: Text(
                                  '${AppLocalizations.of(context).mRegisterresendOTPAfter} $_timeFormat',
                                  style: GoogleFonts.lato(),
                                ),
                              )
                            : Container(
                                alignment: Alignment.topLeft,
                                // padding: EdgeInsets.only(top: 8),
                                child: TextButton(
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size(50, 50),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    onPressed: () {
                                      _sendOTPToVerifyNumber();
                                      setState(() {
                                        _showResendOption = false;
                                        _resendOTPTime = 180;
                                      });
                                    },
                                    child: Text(AppLocalizations.of(context)
                                        .mStaticResendOtp)),
                              ),
                      ],
                    ),
                  )
                : Center(),
        SizedBox(
          height: 16,
        )
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
              text: TextSpan(
                  text: AppLocalizations.of(context).mStaticEmail,
                  style: GoogleFonts.lato(
                      color: AppColors.greys87,
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                      letterSpacing: 0.25,
                      fontSize: 14),
                  children: [
                    TextSpan(
                        text: ' *',
                        style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w700,
                            fontSize: 14))
                  ]),
            ),
            _freezeEmailField
                ? TextButton(
                    onPressed: () {
                      setState(() {
                        _freezeEmailField = false;
                        _emailOtpFocus.unfocus();
                        FocusScope.of(_emailOtpFocus.context)
                            .requestFocus(_emailFocus);
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
                          AppLocalizations.of(context).mStaticEdit,
                          style: GoogleFonts.lato(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        )
                      ],
                    ))
                : Center(),
          ],
        ),
        Container(
          padding: EdgeInsets.only(top: 8),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            // color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Focus(
            child: TextFormField(
              textInputAction: TextInputAction.next,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              focusNode: _emailFocus,
              validator: (String value) {
                if (value.isEmpty) {
                  return AppLocalizations.of(context).mRegisterEmailMandatory;
                }
                String matchedString = regExpEmail.stringMatch(value);
                if (matchedString == null ||
                    matchedString.isEmpty ||
                    matchedString.length != value.length) {
                  return AppLocalizations.of(context).mStaticAddValidEmail;
                }
                return null;
              },
              onChanged: (value) {
                setState(() {
                  _hasSendEmailOTPRequest = false;
                  _isEmailVerified = false;
                });
              },
              onSaved: (String value) {
                email = value;
              },
              onFieldSubmitted: (value) {
                if (value.isEmpty && !_formKey.currentState.validate()) {
                  return;
                }
                _fieldFocusChange(context, _emailFocus, _emailFocus);
              },
              readOnly: _freezeEmailField || _isEmailVerified,
              controller: _emailController,
              style: GoogleFonts.lato(fontSize: 14.0),
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                errorMaxLines: 3,
                filled: true,
                fillColor: _freezeEmailField ? AppColors.grey04 : Colors.white,
                suffixIcon: _isEmailVerified
                    ? Icon(
                        Icons.check_circle,
                        color: AppColors.positiveLight,
                      )
                    : null,
                helperText: regExpEmail.hasMatch(_emailController.text.trim())
                    ? null
                    : AppLocalizations.of(context).mStaticAddValidEmail,
                contentPadding: EdgeInsets.fromLTRB(16.0, 14.0, 0.0, 14.0),
                border: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: AppColors.grey16, width: 1.0)),
                // hintText: 'Enter your email id',
                hintText:
                    AppLocalizations.of(context).mRegisterenterYourEmailAddress,
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
          ),
        ),
        Visibility(
            visible: _isEmailVerified, child: _buildChangeEmailAddress()),
        Visibility(
            visible: !_isEmailVerified && !_hasSendEmailOTPRequest,
            child: _buildSendEmailOtp()),
        Visibility(
            visible: _hasSendEmailOTPRequest, child: _buildVerifyEmailOtp())
      ],
    );
  }

  Padding _buildChangeEmailAddress() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size(50, 30),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () {
              setState(() {
                _isEmailVerified = false;
              });
              FocusScope.of(context).requestFocus(_emailFocus);
            },
            child: Text(
              AppLocalizations.of(context).mStaticChangeEmailAddress,
              style: GoogleFonts.lato(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.primaryThree),
            ),
          )),
    );
  }

  Widget _buildSendEmailOtp() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
            width: MediaQuery.of(context).size.width * 0.6,
            child: Text(
              AppLocalizations.of(context).mStaticOtpSentToEmail,
              style: GoogleFonts.lato(fontWeight: FontWeight.w500, height: 1.5),
            )),
        Container(
          width: MediaQuery.of(context).size.width * 0.3,
          padding: EdgeInsets.only(top: 8),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryThree,
              minimumSize: const Size.fromHeight(48),
            ),
            onPressed: regExpEmail.hasMatch(_emailController.text.trim())
                ? () async {
                    await _sendOTPToVerifyEmail();
                    setState(() {
                      _showEmailResendOption = false;
                      _resendEmailOTPTime =
                          RegistrationType.resendEmailOtpTimeLimit;
                    });
                  }
                : null,
            child: Text(
              AppLocalizations.of(context).mStaticSendOtp,
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
    );
  }

  @override
  void dispose() {
    super.dispose();
    _firstNameController.dispose();
    _fieldController.dispose();
    _fieldDescriptionController.dispose();
    _searchController.dispose();
    _firstNameFocus.dispose();
    _fieldFocus.dispose();
    _emailFocus.dispose();
    _mobileNumberFocus.dispose();
    _emailOTPController.dispose();
    _otpFocus.dispose();
    _emailOtpFocus.dispose();
    if (_timerEmail != null) _timerEmail.cancel();
    if (_timer != null) _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56.0),
        child: AppBar(
            foregroundColor: Colors.black,
            iconTheme: IconThemeData(color: AppColors.greys60, size: 20),
            elevation: 0,
            title: Text(
              AppLocalizations.of(context).mStaticPageTitle + widget.fieldName,
              style: GoogleFonts.montserrat(
                  fontSize: 16, fontWeight: FontWeight.w600),
            ),
            titleSpacing: 0,
            backgroundColor: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(left: 16, right: 16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.only(top: 25, bottom: 24),
              child: Text(
                AppLocalizations.of(context).mStaticBasicDetails,
                style: GoogleFonts.lato(
                    color: AppColors.greys60,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w700),
              ),
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildFirstNameField(),
                  _buildEmailField(),
                  _buildPhoneNumberField(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 16),
                        child: Text(
                          AppLocalizations.of(context).mStaticDomain ==
                                  widget.fieldName
                              ? AppLocalizations.of(context)
                                  .mStaticDomainDetails
                              : AppLocalizations.of(context)
                                  .mStaticOrgansationDetails,
                          // .replaceAll(EnglishLang.position.toUpperCase(),
                          //     widget.fieldName.toUpperCase()),
                          style: GoogleFonts.lato(
                              color: AppColors.greys60,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  _buildRequestField(),
                  _buildRequestDetailsField(),
                  SizedBox(
                    height: 24,
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          value: _isConfirmed,
                          onChanged: (value) {
                            setState(() {
                              _isConfirmed = value;
                            });

                            if (!_formKey.currentState.validate()) {
                              return;
                            }
                          },
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.75,
                          child: Text(
                              AppLocalizations.of(context)
                                  .mStaticSignUpConfirmationText,
                              overflow: TextOverflow.fade,
                              style: GoogleFonts.lato(
                                  color: AppColors.greys60,
                                  fontWeight: FontWeight.w400,
                                  height: 1.429,
                                  letterSpacing: 0.25,
                                  fontSize: 14)),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Container(
                      // height: _activeTabIndex == 0 ? 60 : 0,
                      height: 48,
                      child: Column(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: AppColors.primaryThree,
                              minimumSize: const Size.fromHeight(36), // NEW
                            ),
                            onPressed: (((_isConfirmed &&
                                        (_formKey.currentState != null &&
                                            _formKey.currentState
                                                .validate()))) &&
                                    _isMobileNumberVerified)
                                ? () {
                                    if (!_formKey.currentState.validate()) {
                                      return;
                                    }
                                    _formKey.currentState.save();
                                    _fieldRequest();
                                  }
                                : null,
                            child: Center(
                              child: Text(
                                AppLocalizations.of(context).mCommonsubmit,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.lato(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    letterSpacing: 0.5,
                                    height: 1.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
