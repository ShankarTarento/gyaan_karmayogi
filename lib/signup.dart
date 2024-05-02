import 'dart:async';
import 'dart:convert';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/env/env.dart';
import 'package:karmayogi_mobile/models/_models/register_organisation_model.dart';
import 'package:karmayogi_mobile/models/_models/registration_position_model.dart';
import 'package:karmayogi_mobile/respositories/_respositories/login_respository.dart';
import 'package:karmayogi_mobile/services/_services/profile_service.dart';
import 'package:karmayogi_mobile/services/_services/registration_service.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/sign_up/field_request_page.dart';
import 'package:karmayogi_mobile/ui/widgets/custom_tabs.dart';
import 'package:karmayogi_mobile/util/load_webview_page.dart';
import 'package:provider/provider.dart';

import 'constants/_constants/storage_constants.dart';
import 'localization/_langs/english_lang.dart';
import 'feedback/constants.dart';
// import 'dart:developer' as developer;

import 'models/_models/login_user_details.dart';
import 'models/_models/registration_group_model.dart';
import 'oAuth2_login.dart';

class SignUpPage extends StatefulWidget {
  final bool isParichayUser;
  final LoginUser parichayLoginInfo;
  const SignUpPage(
      {Key key, this.isParichayUser = false, this.parichayLoginInfo})
      : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _groupController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _ministryController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _organisationController = TextEditingController();
  final TextEditingController _mobileNoController = TextEditingController();
  final TextEditingController _mobileNoOTPController = TextEditingController();
  final TextEditingController _emailOTPController = TextEditingController();

  final FocusNode _fullNameFocus = FocusNode();
  final FocusNode _positionFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _mobileNumberFocus = FocusNode();
  final FocusNode _ministryFocus = FocusNode();
  final FocusNode _organisationFocus = FocusNode();
  final FocusNode _otpFocus = FocusNode();
  final FocusNode _emailOtpFocus = FocusNode();

  final RegistrationService registrationService = RegistrationService();
  final ProfileService profileService = ProfileService();

  TextEditingController _searchController = TextEditingController();

  List _categoryTypesRadio = [];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _fullName;
  // String _selectedPositionId;
  String _email;
  String _category;
  String _selectedMinistryId;
  String _selectedStateId;
  String _selectedDepartmentId;

  bool _isConfirmed = false;
  bool _isAcceptedTC = false;
  bool _hasSendOTPRequest = false;
  bool _hasSendEmailOTPRequest = false;
  bool _isEmailVerified = false;
  bool _freezeEmailField = false;

  bool _showResendOption = false;
  bool _showEmailResendOption = false;
  bool _freezeMobileField = false;
  int _resendOTPTime = RegistrationType.resendOtpTimeLimit;
  int _resendEmailOTPTime = RegistrationType.resendEmailOtpTimeLimit;
  String _timeFormat;
  String _timeFormatEmail;
  bool _isMobileNumberVerified = false;

  Timer _timer;
  Timer _timerEmail;

  List<RegistrationPosition> _positionList = [];
  List<OrganisationModel> _ministryList = [];
  List<OrganisationModel> _stateList = [];
  List<OrganisationModel> _departmentList = [];
  List<OrganisationModel> _organisationList;
  List<RegistrationGroup> _groupList = [];
  List<dynamic> _filteredItems = [];
  OrganisationModel _selectedOrg;
  RegExp regExpEmail = RegExp(
      r"[a-z0-9_-]+(?:\.[a-z0-9_-]+)*@((?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?){2,}\.){1,3}(?:\w){2,}");

  @override
  void initState() {
    super.initState();

    setState(() {
      if (widget.isParichayUser) {
        _fullNameController.text =
            widget.parichayLoginInfo.firstName.toString() +
                widget.parichayLoginInfo.lastName.toString();
        _emailController.text = widget.parichayLoginInfo.email;
      }
    });
  }

  @override
  void didChangeDependencies() {
    _categoryTypesRadio = [
      AppLocalizations.of(context).mStaticCenter,
      AppLocalizations.of(context).mStaticState
    ];
    _category = AppLocalizations.of(context).mStaticCenter;
    setState(() {});
    super.didChangeDependencies();
  }

  _getMobileNumber(String mobile, bool phoneVerified) {
    setState(() {
      _mobileNoController.text = mobile;
      _isMobileNumberVerified = phoneVerified;
    });
  }

  _getPositions() async {
    final response = await registrationService.getPositions();
    setState(() {
      _positionList = response;
    });
  }

  _getGroups() async {
    final response = await registrationService.getGroup();
    setState(() {
      List<dynamic> _listData = response;
      int index = 0;
      List<RegistrationGroup> groups = [];
      _listData.forEach((item) {
        //UAT input for removing others from list of groups
        if (!item.toString().toLowerCase().contains('others')) {
          groups.insert(index, RegistrationGroup(name: item));
          index++;
        }
      });
      _groupList = groups;
    });
  }

  _getMinistries() async {
    final response = await registrationService.getMinistries();
    setState(() {
      _ministryList = response;
      _ministryList
          .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    });
  }

  _getStates() async {
    final response = await registrationService.getStates();
    setState(() {
      _stateList = response;
      _stateList
          .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    });
  }

  _getDepartments(String id) async {
    final response = await registrationService.getMinistries(parentId: id);
    setState(() {
      _departmentList = response;
      _departmentList
          .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    });
  }

  _getOrganisations(String id) async {
    final response = await registrationService.getMinistries(parentId: id);
    setState(() {
      _organisationList = response;
      _organisationList
          .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    });
  }

  Future<void> _navigateToHomePage() async {
    final _storage = FlutterSecureStorage();
    String accessToken = await _storage.read(key: Storage.authToken);

    try {
      await Provider.of<LoginRespository>(context, listen: false)
          .getBasicUserInfo(accessToken, isParichayUser: true);

      return Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => CustomTabs(
            customIndex: 0,
            token: accessToken,
          ),
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> _registerAccount() async {
    Response response;
    String email = widget.isParichayUser ? _emailController.text : _email;
    try {
      response = await registrationService.registerAccount(
          _fullName,
          email,
          _groupController.text,
          // _positionController.text,
          _mobileNoController.text,
          _selectedOrg,
          isParichayUser: widget.isParichayUser ? true : false);
      if (widget.isParichayUser &&
          (jsonDecode(response.body)['params']['errmsg'] == null ||
              jsonDecode(response.body)['params']['errmsg'] == '')) {
        await _navigateToHomePage();
      } else if (response.statusCode == 202) {
        await _showPopupForSuccessfulRegister();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(jsonDecode(response.body)['params']['errmsg']),
            backgroundColor: AppColors.primaryTwo,
          ),
        );
      }
    } catch (err) {
      return err;
    }
    // print('Response: ' + response);
  }

  Future<void> _showPopupForSuccessfulRegister() async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context).mStaticThanksForRegistering,
            style: GoogleFonts.lato(
                color: AppColors.greys87,
                fontWeight: FontWeight.w700,
                fontSize: 16,
                letterSpacing: 0.12,
                height: 1.5)),
        content: Text(
          AppLocalizations.of(context).mStaticPostRegisterInfo,
          style: GoogleFonts.lato(
              color: AppColors.greys87,
              fontWeight: FontWeight.w400,
              fontSize: 14,
              letterSpacing: 0.25,
              height: 1.5),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        actions: <Widget>[
          Container(
            width: 87,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: AppColors.primaryThree,
                minimumSize: const Size.fromHeight(40),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => OAuth2Login(),
                ));
              },
              child: Text(
                AppLocalizations.of(context).mStaticOk.toUpperCase(),
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _filterItems(List items, String value) {
    setState(() {
      _filteredItems = items
          .where((item) => item.name.toLowerCase().contains(value))
          .toList();
    });
  }

  void _setListItem(String listType, dynamic item) {
    setState(() {
      switch (listType) {
        case EnglishLang.position:
          _positionController.text = item.name;
          break;
        case EnglishLang.group:
          _groupController.text = item.name;
          break;
        case EnglishLang.ministry:
          _ministryController.text = item.name;
          _departmentController.clear();
          _organisationController.clear();
          setState(() {
            _selectedMinistryId = item.id;
            _selectedOrg = item;
          });
          break;
        case EnglishLang.state:
          _stateController.text = item.name;
          _departmentController.clear();
          _organisationController.clear();
          setState(() {
            _selectedStateId = item.id;
            _selectedOrg = item;
          });
          break;
        case EnglishLang.department:
          _departmentController.text = item.name;
          _organisationController.clear();
          setState(() {
            _selectedDepartmentId = item.id;
            _selectedOrg = item;
          });
          break;
        case EnglishLang.organisation:
          _organisationController.text = item.name;
          setState(() {
            _selectedOrg = item;
          });
          break;
      }
    });
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
    _resendOTPTime = RegistrationType.resendOtpTimeLimit;
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
          if (mounted) {
            setState(() {
              _resendOTPTime--;
            });
          }
        }
        _timeFormat = formatHHMMSS(_resendOTPTime);
      },
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
        _resendOTPTime = RegistrationType.resendOtpTimeLimit;
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
      });
      FocusScope.of(context).requestFocus(_organisationFocus);
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
      FocusScope.of(context).requestFocus(_organisationFocus);
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

  Widget _options(String listType, dynamic item) {
    Color _color;
    switch (listType) {
      case EnglishLang.position:
        _color = _positionController.text == item.name
            ? AppColors.lightSelected
            : Colors.white;
        break;
      case EnglishLang.group:
        _color = _groupController.text == item.name
            ? AppColors.lightSelected
            : Colors.white;
        break;
      case EnglishLang.ministry:
        _color = _ministryController.text == item.name
            ? AppColors.lightSelected
            : Colors.white;
        break;
      case EnglishLang.state:
        _color = _stateController.text == item.name
            ? AppColors.lightSelected
            : Colors.white;
        break;
      case EnglishLang.department:
        _color = _departmentController.text == item.name
            ? AppColors.lightSelected
            : Colors.white;
        break;
      case EnglishLang.organisation:
        _color = _organisationController.text == item.name
            ? AppColors.lightSelected
            : Colors.white;
        break;
    }
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Container(
          decoration: BoxDecoration(
            color: _color,
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
          // height: 52,
          child: Padding(
            padding:
                const EdgeInsets.only(top: 7, bottom: 7, left: 12, right: 4),
            child: Text(
              item.name,
              style: GoogleFonts.lato(
                  color: AppColors.greys87,
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  letterSpacing: 0.25,
                  height: 1.5),
            ),
          )),
    );
  }

  Future<bool> _showListOfOptions(contextMain, String listType) async {
    List<dynamic> items = [];
    switch (listType) {
      case EnglishLang.position:
        await _getPositions();
        items = _positionList;
        break;
      case EnglishLang.ministry:
        await _getMinistries();
        items = _ministryList;
        break;
      case EnglishLang.state:
        await _getStates();
        items = _stateList;
        break;
      case EnglishLang.department:
        await _getDepartments(_category == EnglishLang.center
            ? _selectedMinistryId
            : _selectedStateId);
        items = _departmentList;
        break;
      case EnglishLang.organisation:
        await _getOrganisations(_selectedDepartmentId);
        items = _organisationList;
        break;
      case EnglishLang.group:
        await _getGroups();
        items = _groupList;
    }
    _filterItems(items, '');
    return showModalBottomSheet(
        isScrollControlled: true,
        // useSafeArea: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8), topRight: Radius.circular(8)),
          side: BorderSide(
            color: AppColors.grey08,
          ),
        ),
        context: context,
        builder: (context) => StatefulBuilder(builder: (context, setState) {
              return SingleChildScrollView(
                child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    width: double.infinity,
                    child: Container(
                      margin: EdgeInsets.only(top: 10),
                      color: Colors.white,
                      child: Material(
                          color: Colors.white,
                          child: Column(children: [
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                margin: EdgeInsets.only(bottom: 16),
                                height: 6,
                                width: MediaQuery.of(context).size.width * 0.25,
                                decoration: BoxDecoration(
                                  color: AppColors.grey16,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(16)),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(left: 20),
                              color: Colors.white,
                              child: Row(
                                children: [
                                  Container(
                                    color: Colors.white,
                                    width: MediaQuery.of(context).size.width *
                                        0.75,
                                    height: 48,
                                    child: TextFormField(
                                        onChanged: (value) {
                                          setState(() {
                                            _filteredItems = items
                                                .where((item) => item.name
                                                    .toLowerCase()
                                                    .contains(value))
                                                .toList();
                                          });
                                          _filterItems(items, value);
                                        },
                                        controller: _searchController,
                                        keyboardType: TextInputType.text,
                                        textInputAction: TextInputAction.done,
                                        style: GoogleFonts.lato(fontSize: 14.0),
                                        decoration: InputDecoration(
                                          prefixIcon: Icon(Icons.search),
                                          contentPadding: EdgeInsets.fromLTRB(
                                              16.0, 14.0, 0.0, 10.0),
                                          hintText: AppLocalizations.of(context)
                                              .mStaticSearch,
                                          hintStyle: GoogleFonts.lato(
                                              color: AppColors.greys60,
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w400),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.transparent),
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: AppColors.primaryThree,
                                                width: 1.0),
                                          ),
                                          counterStyle: TextStyle(
                                            height: double.minPositive,
                                          ),
                                          counterText: '',
                                        )),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16),
                                    child: Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          // borderRadius:
                                          //     BorderRadius.all(
                                          //         const Radius.circular(
                                          //             4.0)),
                                          // border: Border.all(
                                          //     color: AppColors.grey16),
                                        ),
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.of(context).pop(false);
                                            _searchController.text = '';
                                            SystemChannels.textInput
                                                .invokeMethod('TextInput.hide');
                                          },
                                          child: Icon(
                                            Icons.clear,
                                            color: AppColors.greys60,
                                            size: 24,
                                          ),
                                        )),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              color: Colors.white,
                              height: 8,
                            ),
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: AppColors.grey08,
                            ),
                            Container(
                                color: Colors.white,
                                padding: const EdgeInsets.only(top: 10),
                                height: MediaQuery.of(context).size.height *
                                    (_filteredItems.length > 0 ? 0.685 : 0.6),
                                child: _filteredItems.length > 0
                                    ? ListView.builder(
                                        // controller: _controller,
                                        shrinkWrap: true,
                                        itemCount: _filteredItems.length,
                                        itemBuilder: (BuildContext context,
                                                index) =>
                                            InkWell(
                                                onTap: () {
                                                  _setListItem(listType,
                                                      _filteredItems[index]);
                                                  setState(() {
                                                    switch (listType) {
                                                      case EnglishLang.position:
                                                        _positionController
                                                                .text =
                                                            _filteredItems[
                                                                    index]
                                                                .name;
                                                        break;
                                                      case EnglishLang.group:
                                                        _groupController.text =
                                                            _filteredItems[
                                                                    index]
                                                                .name;
                                                        break;
                                                      case EnglishLang.ministry:
                                                        _ministryController
                                                                .text =
                                                            _filteredItems[
                                                                    index]
                                                                .name;
                                                        break;
                                                      case EnglishLang.state:
                                                        _stateController.text =
                                                            _filteredItems[
                                                                    index]
                                                                .name;
                                                        break;
                                                      case EnglishLang
                                                          .department:
                                                        _departmentController
                                                                .text =
                                                            _filteredItems[
                                                                    index]
                                                                .name;
                                                        break;
                                                      case EnglishLang
                                                          .organisation:
                                                        _organisationController
                                                                .text =
                                                            _filteredItems[
                                                                    index]
                                                                .name;
                                                        break;
                                                    }
                                                  });
                                                  Navigator.of(context)
                                                      .pop(false);
                                                },
                                                child: _options(listType,
                                                    _filteredItems[index])))
                                    : Padding(
                                        padding: const EdgeInsets.all(32.0),
                                        child: Column(
                                          children: [
                                            Text(
                                                AppLocalizations.of(context)
                                                    .mMsgNoSearchResultFound,
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.lato(
                                                    color: AppColors.greys60,
                                                    fontWeight: FontWeight.w600,
                                                    height: 1.5,
                                                    letterSpacing: 0.25,
                                                    fontSize: 16)),
                                            Visibility(
                                              visible:
                                                  listType != EnglishLang.group,
                                              child: TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                    Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                FieldRequestPage(
                                                                  fullName:
                                                                      _fullNameController
                                                                          .text,
                                                                  mobile:
                                                                      _mobileNoController
                                                                          .text,
                                                                  email:
                                                                      _emailController
                                                                          .text,
                                                                  phoneVerified:
                                                                      _isMobileNumberVerified,
                                                                  isEmailVerified:
                                                                      _isEmailVerified,
                                                                  fieldValue:
                                                                      _searchController
                                                                          .text,
                                                                  parentAction:
                                                                      _getMobileNumber,
                                                                  fieldName:
                                                                      EnglishLang
                                                                          .position,
                                                                )));
                                                  },
                                                  child: Text(EnglishLang
                                                      .requestForHelp)),
                                            )
                                          ],
                                        ),
                                      )),
                          ])),
                    )),
              );
            }));
  }

  Future<bool> _showListOfOrganisation(contextMain, String listType) async {
    _getOrganisationItems() async {
      final response = await registrationService.getOrganisation(
          searchText: _searchController.text, category: _category);

      return response;
    }

    return showModalBottomSheet(
        isScrollControlled: true,
        // useSafeArea: true,
        useRootNavigator: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8), topRight: Radius.circular(8)),
          side: BorderSide(
            color: AppColors.grey08,
          ),
        ),
        context: context,
        builder: (context) => StatefulBuilder(builder: (ctx, setState) {
              return SingleChildScrollView(
                child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    width: double.infinity,
                    child: Stack(
                      alignment: AlignmentDirectional.bottomEnd,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 10),
                          color: Colors.white,
                          child: Material(
                              color: Colors.white,
                              child: Column(children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                    margin: EdgeInsets.only(bottom: 4),
                                    height: 6,
                                    width: MediaQuery.of(context).size.width *
                                        0.25,
                                    decoration: BoxDecoration(
                                      color: AppColors.grey16,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(16)),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(left: 12),
                                  // color: Colors.white,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(),
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.of(context).pop(false);
                                              _searchController.text = '';
                                              SystemChannels.textInput
                                                  .invokeMethod(
                                                      'TextInput.hide');
                                            },
                                            child: Icon(
                                              Icons.clear,
                                              color: AppColors.greys60,
                                              size: 22,
                                            ),
                                          )),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.7,
                                        height: 48,
                                        margin: EdgeInsets.only(left: 2),
                                        child: TextFormField(
                                            onChanged: (value) {
                                              setState(() {});
                                            },
                                            controller: _searchController,
                                            keyboardType: TextInputType.text,
                                            textInputAction:
                                                TextInputAction.done,
                                            style: GoogleFonts.lato(
                                                fontSize: 14.0),
                                            decoration: InputDecoration(
                                              // suffixIcon: Icon(Icons.search),
                                              contentPadding:
                                                  EdgeInsets.fromLTRB(
                                                      4.0, 10.0, 0.0, 10.0),
                                              hintText:
                                                  AppLocalizations.of(context)
                                                      .mStaticTypeHere,
                                              hintStyle: GoogleFonts.lato(
                                                  color: AppColors.greys60,
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w400),
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.transparent),
                                              ),
                                              focusedBorder:
                                                  UnderlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color:
                                                        AppColors.primaryThree,
                                                    width: 1.0),
                                              ),
                                              counterStyle: TextStyle(
                                                height: double.minPositive,
                                              ),
                                              counterText: '',
                                            )),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8),
                                        child: TextButton(
                                          onPressed: _searchController
                                                  .text.isNotEmpty
                                              ? () async {
                                                  final response =
                                                      await _getOrganisationItems();
                                                  if (response == null ||
                                                      response.runtimeType ==
                                                          String) {
                                                    Navigator.of(ctx).pop();
                                                    ScaffoldMessenger.of(
                                                            contextMain)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                            response != null
                                                                ? response
                                                                    .toString()
                                                                : AppLocalizations.of(
                                                                        context)
                                                                    .mStaticSomethingWrongTryLater,
                                                            style: GoogleFonts
                                                                .lato(
                                                              color:
                                                                  Colors.white,
                                                            )),
                                                        backgroundColor:
                                                            AppColors
                                                                .primaryTwo,
                                                      ),
                                                    );
                                                    // Navigator.of(ctx).pop();
                                                  } else {
                                                    setState(() {
                                                      _organisationList =
                                                          response;
                                                    });
                                                  }
                                                }
                                              : null,
                                          child: Text(
                                            AppLocalizations.of(context)
                                                .mStaticSearch,
                                            style: GoogleFonts.lato(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  color: Colors.white,
                                  height: 8,
                                ),
                                Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: AppColors.grey08,
                                ),
                                (_organisationList != null &&
                                        _organisationList.length > 0)
                                    ? Container(
                                        color: Colors.white,
                                        padding: const EdgeInsets.only(top: 10),
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.685,
                                        child: ListView.builder(
                                            // controller: _controller,
                                            shrinkWrap: true,
                                            itemCount: _organisationList.length,
                                            itemBuilder: (BuildContext context,
                                                    index) =>
                                                InkWell(
                                                    onTap: () {
                                                      _setListItem(
                                                          listType,
                                                          _organisationList[
                                                              index]);
                                                      setState(() {
                                                        _organisationController
                                                                .text =
                                                            _organisationList[
                                                                    index]
                                                                .name;
                                                        _selectedOrg =
                                                            _organisationList[
                                                                index];
                                                      });
                                                    },
                                                    child: Column(
                                                      children: [
                                                        _orgItems(
                                                            listType,
                                                            _organisationList[
                                                                index]),
                                                        Divider(
                                                          height: 8,
                                                          thickness: 1,
                                                          indent: 16,
                                                          endIndent: 16,
                                                          color:
                                                              AppColors.grey08,
                                                        ),
                                                      ],
                                                    ))))
                                    : Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.5,
                                        margin: EdgeInsets.only(top: 16),
                                        child: Padding(
                                          padding: const EdgeInsets.all(32.0),
                                          child: Column(
                                            children: [
                                              Text(
                                                  (_organisationList != null &&
                                                          _organisationList
                                                                  .length ==
                                                              0)
                                                      ? AppLocalizations.of(
                                                              context)
                                                          .mMsgNoSearchResultFound
                                                      : AppLocalizations.of(
                                                              context)
                                                          .mStaticOrgSearchHelperText,
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.lato(
                                                      color: AppColors.greys60,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      height: 1.5,
                                                      letterSpacing: 0.25,
                                                      fontSize: 16)),
                                              (_organisationList != null &&
                                                      _organisationList
                                                              .length ==
                                                          0)
                                                  ? TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                        Navigator.of(context).push(
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        FieldRequestPage(
                                                                          fullName:
                                                                              _fullNameController.text,
                                                                          mobile:
                                                                              _mobileNoController.text,
                                                                          email:
                                                                              _emailController.text,
                                                                          phoneVerified:
                                                                              _isMobileNumberVerified,
                                                                          isEmailVerified:
                                                                              _isEmailVerified,
                                                                          fieldValue:
                                                                              _searchController.text,
                                                                          parentAction:
                                                                              _getMobileNumber,
                                                                          fieldName:
                                                                              AppLocalizations.of(context).mRegisterorganisation,
                                                                        )));
                                                      },
                                                      child: Text(AppLocalizations
                                                              .of(context)
                                                          .mStaticRequestForHelp))
                                                  : Center()
                                            ],
                                          ),
                                        )),
                                SizedBox(
                                  height: 80,
                                )
                              ])),
                        ),
                        (_organisationList != null &&
                                _organisationList.length > 0)
                            ? Container(
                                padding: EdgeInsets.all(16),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: AppColors.primaryThree,
                                    minimumSize:
                                        const Size.fromHeight(40), // NEW
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                  child: Text(
                                    AppLocalizations.of(context).mStaticDone,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              )
                            : Center()
                      ],
                    )),
              );
            }));
  }

  Widget _orgItems(String listType, dynamic item) {
    Color _color;
    _color = _organisationController.text == item.name
        ? AppColors.lightSelected
        : Colors.white;

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Container(
          decoration: BoxDecoration(
            color: _color,
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
          child: Padding(
            padding:
                const EdgeInsets.only(left: 4, top: 10, bottom: 10, right: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: GoogleFonts.lato(
                      color: AppColors.greys87,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      letterSpacing: 0.25,
                      height: 1.5),
                ),
                SizedBox(
                  height: 8,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    item.l1OrgName != null
                        ? Row(
                            children: [
                              Text(
                                  '${AppLocalizations.of(context).mRegisterunder}  '),
                              Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.3,
                                  child: Text(
                                    item.l1OrgName != null
                                        ? item.l1OrgName
                                        : '',
                                    // maxLines: 1,
                                  )),
                            ],
                          )
                        : Center(),
                    item.l2OrgName != null
                        ? Padding(
                            padding: const EdgeInsets.only(left: 8, right: 8),
                            child: Icon(Icons.arrow_forward),
                          )
                        : Center(),
                    item.l2OrgName != null
                        ? Container(
                            width: MediaQuery.of(context).size.width * 0.38,
                            child: Text(
                                item.l2OrgName != null ? item.l2OrgName : ''),
                          )
                        : Center(),
                  ],
                )
              ],
            ),
          )),
    );
  }

  Widget _buildFullNameField() {
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
              focusNode: _fullNameFocus,
              controller: _fullNameController,
              onSaved: (String value) {
                _fullName = value;
              },
              onFieldSubmitted: (value) {
                if (value.isEmpty && !_formKey.currentState.validate()) {
                  return;
                }
                _fieldFocusChange(context, _fullNameFocus, _positionFocus);
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
                hintText:
                    AppLocalizations.of(context).mRegisterenterYourFullName,
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

  // Widget _buildPositionField() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       RichText(
  //         text: TextSpan(
  //             text: EnglishLang.position,
  //             style: GoogleFonts.lato(
  //                 color: AppColors.greys87,
  //                 fontWeight: FontWeight.w700,
  //                 height: 1.5,
  //                 letterSpacing: 0.25,
  //                 fontSize: 14),
  //             children: [
  //               TextSpan(
  //                   text: ' *',
  //                   style: TextStyle(
  //                       color: Colors.red,
  //                       fontWeight: FontWeight.w700,
  //                       fontSize: 14))
  //             ]),
  //       ),
  //       Container(
  //         padding: EdgeInsets.only(top: 8),
  //         alignment: Alignment.centerLeft,
  //         decoration: BoxDecoration(
  //           borderRadius: BorderRadius.circular(4),
  //         ),
  //         child: TextFormField(
  //           readOnly: true,
  //           onTap: () async {
  //             setState(() {
  //               _searchController?.clear();
  //             });
  //             await _showListOfOptions(context, EnglishLang.position);
  //           },
  //           textInputAction: TextInputAction.next,
  //           controller: _positionController,
  //           onFieldSubmitted: (value) {
  //             if (value.isEmpty && !_formKey.currentState.validate()) {
  //               return;
  //             }
  //           },
  //           autovalidateMode: AutovalidateMode.onUserInteraction,
  //           validator: (String value) {
  //             if (value.isEmpty) {
  //               return EnglishLang.positionValidationText;
  //             } else
  //               return null;
  //           },
  //           style: GoogleFonts.lato(fontSize: 14.0),
  //           keyboardType: TextInputType.name,
  //           decoration: InputDecoration(
  //             filled: true,
  //             fillColor: Colors.white,
  //             contentPadding: EdgeInsets.fromLTRB(16.0, 14.0, 0.0, 14.0),
  //             border: OutlineInputBorder(
  //                 borderSide: BorderSide(color: AppColors.grey16, width: 1.0)),
  //             hintText: EnglishLang.selectHere,
  //             hintStyle: GoogleFonts.lato(
  //                 color: AppColors.grey40,
  //                 fontSize: 14.0,
  //                 fontWeight: FontWeight.w400),
  //             focusedBorder: OutlineInputBorder(
  //               borderSide:
  //                   const BorderSide(color: AppColors.primaryThree, width: 1.0),
  //             ),
  //           ),
  //         ),
  //       ),
  //       SizedBox(
  //         height: 16,
  //       )
  //     ],
  //   );
  // }

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
                        .mStaticEmptyMobileNumber;
                  } else if (value.trim().length != 10 ||
                      !RegExp(r'^\s*(?:\+?(\d{1,3}))?[-. (]*(\d{3})[-. )]*(\d{3})[-. ]*(\d{4})(?: *x(\d+))?\s*$')
                          .hasMatch(value)) {
                    return AppLocalizations.of(context)
                        .mStaticPleaseAddValidNumber;
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
                  hintText: AppLocalizations.of(context).mStaticMobileNumber,
                  helperText: (_isMobileNumberVerified ||
                          (_mobileNoController.text.trim().length == 10 &&
                              RegExp(r'^\s*(?:\+?(\d{1,3}))?[-. (]*(\d{3})[-. )]*(\d{3})[-. ]*(\d{4})(?: *x(\d+))?\s*$')
                                  .hasMatch(_mobileNoController.text.trim())))
                      ? null
                      : AppLocalizations.of(context)
                          .mStaticPleaseAddValidNumber,
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
                                            .mStaticEnterOtp;
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
                                  AppLocalizations.of(context)
                                      .mRegisterresendOTP,
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
                                        _resendOTPTime =
                                            RegistrationType.resendOtpTimeLimit;
                                      });
                                    },
                                    child: Text(AppLocalizations.of(context)
                                        .mRegisterresendOTP)),
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

  Widget _buildSendEmailOtp() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
            width: MediaQuery.of(context).size.width * 0.6,
            child: Text(
              AppLocalizations.of(context).mStaticOtpSentToEmailDesc,
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
              AppLocalizations.of(context).mRegistersendOTP,
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
                          return AppLocalizations.of(context).mRegisterenterOTP;
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

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
              text: TextSpan(
                  text: AppLocalizations.of(context).mRegisteremail,
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
                  return AppLocalizations.of(context).mRegistervalidEmail;
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
                _email = value;
              },
              onFieldSubmitted: (value) {
                if (value.isEmpty && !_formKey.currentState.validate()) {
                  return;
                }
                _fieldFocusChange(context, _emailFocus, _emailFocus);
              },
              readOnly: (_freezeEmailField ? true : widget.isParichayUser) ||
                  _isEmailVerified,
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
                    : AppLocalizations.of(context).mRegistervalidEmail,
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

  Widget _buildCategoryChoose() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
              text: AppLocalizations.of(context)
                  .mStaticSelectYourOrganisationType,
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          // spacing: 16,
          children: [
            for (var index = 0; index < _categoryTypesRadio.length; index++)
              (Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.44,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(const Radius.circular(4.0)),
                    border: Border.all(
                        color: (_category == _categoryTypesRadio[index])
                            ? AppColors.primaryThree
                            : AppColors.grey16,
                        width: 1.5),
                  ),
                  child: RadioListTile(
                    dense: true,
                    groupValue: _category,
                    title: Text(
                      _categoryTypesRadio[index],
                      style: GoogleFonts.lato(
                          color: AppColors.greys87,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400),
                    ),
                    value: _categoryTypesRadio[index],
                    onChanged: (value) {
                      setState(() {
                        _category = value;
                      });
                      // if (!_formKey.currentState.validate()) {
                      //   return;
                      // }
                      _ministryController.clear();
                      _stateController.clear();
                      _departmentController.clear();
                      _organisationController.clear();
                    },
                    selected: (_category == _categoryTypesRadio[index]),
                    selectedTileColor: AppColors.selectionBackgroundBlue,
                  ),
                ),
              ))
          ],
        )
      ],
    );
  }

  // Widget _buildMinistryField() {
  //   return Container(
  //     padding: EdgeInsets.only(top: 16),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         RichText(
  //           text: TextSpan(
  //               text: EnglishLang.ministry,
  //               style: GoogleFonts.lato(
  //                   color: AppColors.greys87,
  //                   fontWeight: FontWeight.w600,
  //                   height: 1.5,
  //                   letterSpacing: 0.12,
  //                   fontSize: 16),
  //               children: [
  //                 TextSpan(
  //                     text: ' *',
  //                     style: TextStyle(
  //                         color: Colors.red,
  //                         fontWeight: FontWeight.w600,
  //                         fontSize: 16))
  //               ]),
  //         ),
  //         Container(
  //           padding: EdgeInsets.only(top: 6),
  //           alignment: Alignment.centerLeft,
  //           decoration: BoxDecoration(
  //             // color: Colors.white,
  //             borderRadius: BorderRadius.circular(4),
  //           ),
  //           child: Focus(
  //             child: TextFormField(
  //               readOnly: true,
  //               onTap: () async {
  //                 await _showListOfOptions(context, EnglishLang.ministry);
  //               },
  //               focusNode: _ministryFocus,
  //               textInputAction: TextInputAction.next,
  //               controller: _ministryController,
  //               onFieldSubmitted: (value) {
  //                 if (value.isEmpty && !_formKey.currentState.validate()) {
  //                   return;
  //                 }
  //               },
  //               autovalidateMode: AutovalidateMode.onUserInteraction,
  //               validator: (value) {
  //                 if (value.isEmpty) {
  //                   return '${_category == EnglishLang.center ? EnglishLang.ministry : EnglishLang.state} is mandatory';
  //                 } else {
  //                   return null;
  //                 }
  //               },
  //               style: GoogleFonts.lato(fontSize: 14.0),
  //               keyboardType: TextInputType.name,
  //               decoration: InputDecoration(
  //                 contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 10.0),
  //                 border: OutlineInputBorder(
  //                     borderSide: BorderSide(color: AppColors.grey16)),
  //                 // hintText: 'Select your ministry',
  //                 hintText: EnglishLang.selectYourPosition.replaceAll(
  //                     EnglishLang.position.toLowerCase(),
  //                     EnglishLang.ministry.toLowerCase()),
  //                 hintStyle: GoogleFonts.lato(
  //                     color: AppColors.grey40,
  //                     fontSize: 14.0,
  //                     fontWeight: FontWeight.w400),
  //                 focusedBorder: OutlineInputBorder(
  //                   borderSide: const BorderSide(
  //                       color: AppColors.primaryThree, width: 1.0),
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //         SizedBox(
  //           height: 16,
  //         )
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildStateField() {
  //   return Container(
  //     padding: EdgeInsets.only(top: 16),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         RichText(
  //           text: TextSpan(
  //               text: EnglishLang.state,
  //               style: GoogleFonts.lato(
  //                   color: AppColors.greys87,
  //                   fontWeight: FontWeight.w600,
  //                   height: 1.5,
  //                   letterSpacing: 0.12,
  //                   fontSize: 16),
  //               children: [
  //                 TextSpan(
  //                     text: ' *',
  //                     style: TextStyle(
  //                         color: Colors.red,
  //                         fontWeight: FontWeight.w600,
  //                         fontSize: 16))
  //               ]),
  //         ),
  //         Container(
  //           padding: EdgeInsets.only(top: 6),
  //           alignment: Alignment.centerLeft,
  //           decoration: BoxDecoration(
  //             // color: Colors.white,
  //             borderRadius: BorderRadius.circular(4),
  //           ),
  //           child: TextFormField(
  //             readOnly: true,
  //             onTap: () async {
  //               await _showListOfOptions(context, EnglishLang.state);
  //             },
  //             textInputAction: TextInputAction.next,
  //             onFieldSubmitted: (value) {
  //               if (value.isEmpty && !_formKey.currentState.validate()) {
  //                 return;
  //               }
  //             },
  //             autovalidateMode: AutovalidateMode.onUserInteraction,
  //             validator: (value) {
  //               if (value.isEmpty) {
  //                 // return '$_category is mandatory';
  //                 return EnglishLang.firstNameMandatory
  //                     .replaceAll(EnglishLang.firstName, '$_category');
  //               } else {
  //                 return null;
  //               }
  //             },
  //             controller: _stateController,
  //             style: GoogleFonts.lato(fontSize: 14.0),
  //             keyboardType: TextInputType.name,
  //             decoration: InputDecoration(
  //               contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 10.0),
  //               border: OutlineInputBorder(
  //                   borderSide: BorderSide(color: AppColors.grey16)),
  //               // hintText: 'Select your state',
  //               hintText: EnglishLang.selectYourPosition.replaceAll(
  //                   EnglishLang.position.toLowerCase(),
  //                   EnglishLang.state.toLowerCase()),
  //               hintStyle: GoogleFonts.lato(
  //                   color: AppColors.grey40,
  //                   fontSize: 14.0,
  //                   fontWeight: FontWeight.w400),
  //               focusedBorder: OutlineInputBorder(
  //                 borderSide: const BorderSide(
  //                     color: AppColors.primaryThree, width: 1.0),
  //               ),
  //             ),
  //           ),
  //         ),
  //         SizedBox(
  //           height: 16,
  //         )
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildDepartmentField() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           Text(EnglishLang.department,
  //               style: GoogleFonts.lato(
  //                   color: AppColors.greys87,
  //                   fontWeight: FontWeight.w600,
  //                   height: 1.5,
  //                   letterSpacing: 0.12,
  //                   fontSize: 16)),
  //           InkWell(
  //             child: Padding(
  //               padding: const EdgeInsets.only(top: 2),
  //               child: Icon(
  //                 Icons.info_outline,
  //                 color: AppColors.grey40,
  //               ),
  //             ),
  //             onTap: () {
  //               showDialog(context: context, builder: (ctx) => FieldInfo());
  //             },
  //           ),
  //         ],
  //       ),
  //       Container(
  //         padding: EdgeInsets.only(top: 6),
  //         alignment: Alignment.centerLeft,
  //         decoration: BoxDecoration(
  //           // color: Colors.white,
  //           borderRadius: BorderRadius.circular(4),
  //         ),
  //         child: TextFormField(
  //           readOnly: true,
  //           onTap: () async {
  //             if ((_selectedMinistryId != null && _selectedMinistryId != '') ||
  //                 (_selectedStateId != null && _selectedStateId != '')) {
  //               await _showListOfOptions(context, EnglishLang.department);
  //             }
  //           },
  //           textInputAction: TextInputAction.next,
  //           autovalidateMode: AutovalidateMode.onUserInteraction,
  //           controller: _departmentController,
  //           style: GoogleFonts.lato(fontSize: 14.0),
  //           keyboardType: TextInputType.name,
  //           decoration: InputDecoration(
  //             contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 10.0),
  //             border: OutlineInputBorder(
  //                 borderSide: BorderSide(color: AppColors.grey16)),
  //             // hintText: 'Select your department',
  //             hintText: EnglishLang.selectYourPosition.replaceAll(
  //                 EnglishLang.position.toLowerCase(),
  //                 EnglishLang.department.toLowerCase()),
  //             hintStyle: GoogleFonts.lato(
  //                 color: AppColors.grey40,
  //                 fontSize: 14.0,
  //                 fontWeight: FontWeight.w400),
  //             focusedBorder: OutlineInputBorder(
  //               borderSide:
  //                   const BorderSide(color: AppColors.primaryThree, width: 1.0),
  //             ),
  //           ),
  //         ),
  //       ),
  //       SizedBox(
  //         height: 16,
  //       )
  //     ],
  //   );
  // }

  Widget _buildOrganisationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
              text: TextSpan(
                  text: AppLocalizations.of(context)
                      .mStaticSelectYourOrganisation,
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
            // InkWell(
            //   child: Padding(
            //     padding: const EdgeInsets.only(top: 2),
            //     child: Icon(
            //       Icons.info_outline,
            //       color: AppColors.grey40,
            //     ),
            //   ),
            //   onTap: () {
            //     showDialog(context: context, builder: (ctx) => FieldInfo());
            //   },
            // ),
          ],
        ),
        _selectedOrg == null
            ? Container(
                padding: EdgeInsets.only(top: 8),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  // color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: TextFormField(
                  focusNode: _organisationFocus,
                  readOnly: true,
                  onTap: () async {
                    // if (_selectedDepartmentId != null &&
                    //     _selectedDepartmentId != '') {
                    //   await _showListOfOptions(context, EnglishLang.organisation);
                    // }
                    setState(() {
                      _organisationList = null;
                      _searchController?.clear();
                    });
                    await _showListOfOrganisation(
                        context, EnglishLang.organisation);
                  },
                  textInputAction: TextInputAction.next,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value.isEmpty) {
                      return AppLocalizations.of(context)
                          .mRegisterOrganisationMandatory;
                    } else {
                      return null;
                    }
                  },
                  controller: _organisationController,
                  style: GoogleFonts.lato(fontSize: 14.0),
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 10.0),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.grey16)),
                    hintText: AppLocalizations.of(context).mRegisterTapToSearch,
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
              )
            : Container(
                margin: EdgeInsets.only(top: 8),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedOrg.name,
                      style: GoogleFonts.lato(
                          color: AppColors.greys87,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          letterSpacing: 0.25,
                          height: 1.5),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _selectedOrg.l1OrgName != null
                            ? Row(
                                children: [
                                  Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.35,
                                      child: Text(
                                        _selectedOrg.l1OrgName != null
                                            ? _selectedOrg.l1OrgName
                                            : '',
                                        // maxLines: 1,
                                      )),
                                ],
                              )
                            : Center(),
                        _selectedOrg.l2OrgName != null
                            ? Padding(
                                padding:
                                    const EdgeInsets.only(left: 8, right: 8),
                                child: Icon(Icons.arrow_forward),
                              )
                            : Center(),
                        _selectedOrg.l2OrgName != null
                            ? Container(
                                width: MediaQuery.of(context).size.width * 0.4,
                                child: Text(_selectedOrg.l2OrgName != null
                                    ? _selectedOrg.l2OrgName
                                    : ''),
                              )
                            : Center(),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedOrg = null;
                                _organisationController.clear();
                              });
                            },
                            child: Icon(
                              Icons.delete,
                            )),
                      ),
                    )
                  ],
                ),
              ),
        SizedBox(
          height: 16,
        )
      ],
    );
  }

  Widget _buildGroupField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
              text: AppLocalizations.of(context).mRegistergroup,
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
            readOnly: true,
            onTap: () async {
              setState(() {
                _searchController?.clear();
              });
              await _showListOfOptions(context, EnglishLang.group);
            },
            textInputAction: TextInputAction.next,
            controller: _groupController,
            onFieldSubmitted: (value) {
              if (value.isEmpty && !_formKey.currentState.validate()) {
                return;
              }
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (String value) {
              if (value.isEmpty) {
                return AppLocalizations.of(context).mRegistergroupMandatory;
              } else
                return null;
            },
            style: GoogleFonts.lato(fontSize: 14.0),
            keyboardType: TextInputType.name,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.fromLTRB(16.0, 14.0, 0.0, 14.0),
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.grey16, width: 1.0)),
              hintText: AppLocalizations.of(context).mStaticSelectHere,
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

  @override
  void dispose() {
    super.dispose();
    _fullNameController.dispose();
    _groupController.dispose();
    _positionController.dispose();
    _departmentController.dispose();
    _ministryController.dispose();
    _organisationController.dispose();
    _stateController.dispose();
    _searchController.dispose();
    _fullNameFocus.dispose();
    _positionFocus.dispose();
    _emailFocus.dispose();
    _mobileNumberFocus.dispose();
    _emailOTPController.dispose();
    _ministryFocus.dispose();
    _otpFocus.dispose();
    _emailOtpFocus.dispose();
    _organisationFocus.dispose();
    _timer?.cancel();
    _timerEmail?.cancel();
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
              widget.isParichayUser
                  ? AppLocalizations.of(context).mStaticWelcomeToiGOT
                  : AppLocalizations.of(context).mStaticRegister,
              style: GoogleFonts.montserrat(
                  fontSize: 16, fontWeight: FontWeight.w600),
            ),
            titleSpacing: 0,
            centerTitle: widget.isParichayUser ? true : false,
            backgroundColor: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(left: 16, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      _buildFullNameField(),
                      // _buildPositionField(),
                      _buildGroupField(),
                      Container(
                        child: Column(
                          children: [
                            // Row(
                            //   children: [
                            //     Expanded(
                            //         child: Text(
                            //       EnglishLang.postionNotFound,
                            //       textAlign: TextAlign.start,
                            //       style: GoogleFonts.lato(
                            //           color: AppColors.greys87,
                            //           fontWeight: FontWeight.w700,
                            //           fontSize: 14,
                            //           letterSpacing: 0.5,
                            //           height: 1.5),
                            //     )),
                            //     InkWell(
                            //       child: Text(
                            //         EnglishLang.requestForHelp,
                            //         textAlign: TextAlign.end,
                            //         style: GoogleFonts.lato(
                            //             color: AppColors.primaryThree,
                            //             fontWeight: FontWeight.w700,
                            //             fontSize: 14,
                            //             letterSpacing: 0.5,
                            //             height: 1.5),
                            //       ),
                            //       onTap: () {
                            //         Navigator.of(context).push(
                            //             MaterialPageRoute(
                            //                 builder: (context) =>
                            //                     FieldRequestPage(
                            //                       fullName:
                            //                           _fullNameController.text,
                            //                       mobile:
                            //                           _mobileNoController.text,
                            //                       email: _emailController.text,
                            //                       phoneVerified:
                            //                           _isMobileNumberVerified,
                            //                       fieldValue:
                            //                           _searchController.text,
                            //                       parentAction:
                            //                           _getMobileNumber,
                            //                       fieldName:
                            //                           EnglishLang.position,
                            //                     )));
                            //       },
                            //     )
                            //   ],
                            // ),
                            SizedBox(
                              height: 24,
                            )
                          ],
                        ),
                      ),
                      _buildEmailField(),
                      Container(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    AppLocalizations.of(context)
                                        .mRegisterdonotHaveGovernmentEmail,
                                    textAlign: TextAlign.start,
                                    style: GoogleFonts.lato(
                                        color: AppColors.greys87,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        letterSpacing: 0.5,
                                        height: 1.5),
                                  ),
                                ),
                                InkWell(
                                  child: Text(
                                    AppLocalizations.of(context)
                                        .mRegisterrequestForHelp,
                                    textAlign: TextAlign.end,
                                    style: GoogleFonts.lato(
                                        color: AppColors.primaryThree,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        letterSpacing: 0.5,
                                        height: 1.5),
                                  ),
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                FieldRequestPage(
                                                  fullName:
                                                      _fullNameController.text,
                                                  mobile:
                                                      _mobileNoController.text,
                                                  email: _emailController.text,
                                                  phoneVerified:
                                                      _isMobileNumberVerified,
                                                  isEmailVerified:
                                                      _isEmailVerified,
                                                  parentAction:
                                                      _getMobileNumber,
                                                  fieldName:
                                                      AppLocalizations.of(
                                                              context)
                                                          .mStaticDomain,
                                                )));
                                  },
                                )
                              ],
                            ),
                            SizedBox(
                              height: 24,
                            )
                          ],
                        ),
                      ),
                      _buildPhoneNumberField(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 16, bottom: 16),
                            child: Text(
                              AppLocalizations.of(context)
                                  .mStaticOrgansationDetails,
                              style: GoogleFonts.lato(
                                  color: AppColors.greys60,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      _buildCategoryChoose(),
                      // _category == EnglishLang.center
                      //     ? _buildMinistryField()
                      //     : _buildStateField(),
                      // _buildDepartmentField(),
                      SizedBox(
                        height: 24,
                      ),
                      _buildOrganisationField(),
                      Container(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                    child: Text(
                                  AppLocalizations.of(context)
                                      .mStaticNoOrganisationFound,
                                  textAlign: TextAlign.start,
                                  style: GoogleFonts.lato(
                                      color: AppColors.greys87,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      letterSpacing: 0.5,
                                      height: 1.5),
                                )),
                                InkWell(
                                  child: Text(
                                    AppLocalizations.of(context)
                                        .mRegisterrequestForHelp,
                                    textAlign: TextAlign.end,
                                    style: GoogleFonts.lato(
                                        color: AppColors.primaryThree,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        letterSpacing: 0.5,
                                        height: 1.5),
                                  ),
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                FieldRequestPage(
                                                  fullName:
                                                      _fullNameController.text,
                                                  mobile:
                                                      _mobileNoController.text,
                                                  email: _emailController.text,
                                                  phoneVerified:
                                                      _isMobileNumberVerified,
                                                  isEmailVerified:
                                                      _isEmailVerified,
                                                  fieldValue:
                                                      _searchController.text,
                                                  parentAction:
                                                      _getMobileNumber,
                                                  fieldName: AppLocalizations
                                                          .of(context)
                                                      .mRegisterorganisation,
                                                )));
                                    // RequestSuccessfullyRegisteredPage()));
                                  },
                                )
                              ],
                            ),
                            SizedBox(
                              height: 24,
                            )
                          ],
                        ),
                      ),
                      // Container(
                      //     child: Column(children: [
                      //   Row(
                      //     children: [
                      //       Text(
                      //         EnglishLang.whatIsAnOrganisation,
                      //         textAlign: TextAlign.center,
                      //         style: GoogleFonts.lato(
                      //             color: AppColors.greys87,
                      //             fontWeight: FontWeight.w700,
                      //             fontSize: 14,
                      //             letterSpacing: 0.5,
                      //             height: 1.5),
                      //       )
                      //     ],
                      //   ),
                      //   SizedBox(
                      //     height: 8,
                      //   ),
                      // ])),
                      // SizedBox(
                      //   height: 48,
                      //   child: ElevatedButton(
                      //       style: ElevatedButton.styleFrom(
                      //         side: const BorderSide(
                      //           width: 1.0,
                      //           color: AppColors.grey16,
                      //         ),
                      //         elevation: 0,
                      //         backgroundColor:
                      //             AppColors.scaffoldBackground,
                      //         minimumSize:
                      //             const Size.fromHeight(36), // NEW
                      //       ),
                      //       onPressed: () {
                      //         showDialog(
                      //             context: context,
                      //             builder: (ctx) => FieldInfo());
                      //       },
                      //       child: Row(
                      //         mainAxisAlignment: MainAxisAlignment.center,
                      //         children: [
                      //           Icon(
                      //             Icons.info_outline,
                      //             color: AppColors.greys60,
                      //             size: 20,
                      //           ),
                      //           Padding(
                      //             padding:
                      //                 const EdgeInsets.only(left: 10),
                      //             child: Text(
                      //               EnglishLang.knowMore,
                      //               textAlign: TextAlign.center,
                      //               style: GoogleFonts.lato(
                      //                   color: AppColors.greys60,
                      //                   fontWeight: FontWeight.w700,
                      //                   fontSize: 14,
                      //                   letterSpacing: 0.5,
                      //                   height: 1.5),
                      //             ),
                      //           )
                      //         ],
                      //       )),
                      // ),
                      //       SizedBox(
                      //         height: 24,
                      //       ),
                      //       Container(
                      //         // margin: EdgeInsets.only(left: 16, right: 16),
                      //         child: Divider(
                      //           color: AppColors.grey16,
                      //           height: 10,
                      //           // indent: 16,
                      //           // endIndent: 16,
                      //           thickness: 1,
                      //         ),
                      //       )
                      //     ],
                      //   ),
                      // ),
                      // SizedBox(
                      //   height: 24,
                      // ),
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
                                      .mRegisterconfirmInfo,
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
                        height: 8,
                      ),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          // crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              value: _isAcceptedTC,
                              onChanged: (value) {
                                setState(() {
                                  _isAcceptedTC = value;
                                });

                                if (!_formKey.currentState.validate()) {
                                  return;
                                }
                              },
                            ),
                            Container(
                                width: MediaQuery.of(context).size.width * 0.8,
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        style: GoogleFonts.lato(
                                            color: AppColors.greys60,
                                            fontWeight: FontWeight.w400,
                                            height: 1.429,
                                            letterSpacing: 0.25,
                                            fontSize: 14),
                                        text: AppLocalizations.of(context)
                                            .mRegisteragree,
                                      ),
                                      TextSpan(
                                        style: GoogleFonts.lato(
                                            color: AppColors.primaryThree,
                                            fontWeight: FontWeight.w600,
                                            height: 1.429,
                                            letterSpacing: 0.25,
                                            fontSize: 14),
                                        text: AppLocalizations.of(context)
                                            .mRegisterterms,
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () => {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        LoadWebViewPage(
                                                      title: ' Terms of Service',
                                                      url:
                                                          Env.termsOfServiceUrl,
                                                    ),
                                                  ),
                                                ),
                                              }),
                                    TextSpan(
                                        style: GoogleFonts.lato(
                                            color: AppColors.greys60,
                                            fontWeight: FontWeight.w400,
                                            height: 1.429,
                                            letterSpacing: 0.25,
                                            fontSize: 14),
                                        text: ' and '),
                                    TextSpan(
                                      style: GoogleFonts.lato(
                                          color: AppColors.primaryThree,
                                          fontWeight: FontWeight.w600,
                                          height: 1.429,
                                          letterSpacing: 0.25,
                                          fontSize: 14),
                                      text: ' ' +AppLocalizations.of(context)
                                            .mStaticPrivacyPolicy+ ' ',
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () => {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      LoadWebViewPage(
                                                    title: AppLocalizations.of(context)
                                            .mStaticPrivacyPolicy,
                                                    url: ApiUrl.baseUrl +
                                                        ApiUrl.privacyPolicy,
                                                  ),
                                                ),
                                              ),
                                            },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  )),
              SizedBox(
                height: 24,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: Container(
                  // height: _activeTabIndex == 0 ? 60 : 0,
                  // height: 48,
                  child: Column(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryThree,
                          minimumSize: const Size.fromHeight(36), // NEW
                        ),
                        onPressed: (((_isConfirmed &&
                                        (_formKey.currentState != null &&
                                            _formKey.currentState
                                                .validate())) &&
                                    _isAcceptedTC) &&
                                _isMobileNumberVerified)
                            ? () {
                                if (!_formKey.currentState.validate()) {
                                  return;
                                }
                                _formKey.currentState.save();
                                _registerAccount();
                              }
                            : null,
                        child: Center(
                          child: Text(
                              widget.isParichayUser
                                  ? AppLocalizations.of(context)
                                      .mStaticSaveAndNext
                                  : AppLocalizations.of(context)
                                      .mRegistersignup,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lato(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  letterSpacing: 0.5,
                                  height: 1.5)),
                        ),
                      ),
                      // SizedBox(
                      //   height: 24,
                      // ),
                      Container(
                        padding: EdgeInsets.fromLTRB(0, 5, 5, 5),
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: RichText(
                            text: TextSpan(children: [
                          TextSpan(
                            style: GoogleFonts.lato(
                                color: AppColors.greys60,
                                fontWeight: FontWeight.w400,
                                height: 1.429,
                                letterSpacing: 0.25,
                                fontSize: 14),
                            text: "Already have an account? ",
                          ),
                          TextSpan(
                            style: GoogleFonts.lato(
                                color: AppColors.primaryThree,
                                fontWeight: FontWeight.w600,
                                height: 1.429,
                                letterSpacing: 0.25,
                                fontSize: 14),
                            text: " Sign in here",
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => OAuth2Login(),
                                      ),
                                    ),
                                  },
                          ),
                        ])),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
