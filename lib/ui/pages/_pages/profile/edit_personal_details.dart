import 'dart:async';
import 'dart:io';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:karmayogi_mobile/feedback/widgets/_microSurvey/page_loader.dart';
import 'package:karmayogi_mobile/models/_models/localization_text.dart';
import 'package:karmayogi_mobile/respositories/_respositories/profile_repository.dart';
import 'package:provider/provider.dart';
import '../../../../constants/_constants/storage_constants.dart';
import './../../../../models/index.dart';
import './../../../../util/helper.dart';
import './../../../../services/index.dart';
import './../../../../constants/index.dart';

class EditPersonalDetailsPage extends StatefulWidget {
  final profileDetails;
  final scaffoldKey;
  static final GlobalKey<_EditPersonalDetailsPageState>
      personalDetailsGlobalKey = GlobalKey();
  final parentAction;
  final bool isToUpdateMobileNumber;
  final bool isToUpdateProfile;
  final String focus;
  final mandatoryFields;
  EditPersonalDetailsPage(
      {Key key,
      this.profileDetails,
      this.scaffoldKey,
      this.parentAction,
      this.isToUpdateMobileNumber = false,
      this.focus,
      this.mandatoryFields,
      this.isToUpdateProfile = false})
      : super(key: personalDetailsGlobalKey);
  @override
  _EditPersonalDetailsPageState createState() =>
      _EditPersonalDetailsPageState();
}

class _EditPersonalDetailsPageState extends State<EditPersonalDetailsPage> {
  // final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<AutoCompleteTextFieldState<String>> key1 = GlobalKey();
  final GlobalKey<AutoCompleteTextFieldState<String>> key2 = GlobalKey();
  final GlobalKey<AutoCompleteTextFieldState<String>> key3 = GlobalKey();
  final GlobalKey<FormState> personalDetailsFormKey = GlobalKey<FormState>();

  final ProfileService profileService = ProfileService();
  final _storage = FlutterSecureStorage();

  // final GlobalKey<TagsState> _tagStateKey = GlobalKey<TagsState>();

  File _selectedFile;
  final _picker = ImagePicker();
  bool _inProcess = false;

  List<LocalizationText> _genderRadio = [];

  List<LocalizationText> _maritalStatusRadio = [];

  List<LocalizationText> _categoryRadio = [];

  int _postalAddressLength = 0;
  bool _officialEmail = false;
  var _imageBase64 = '';
  Map _profileData;
  List<String> _nationalities = [];
  List<String> _filterednationalities = [];
  List<String> _languages = [];
  List<String> _countryCodes = [];
  List<String> _otherLanguages = [];
  String _selectedGender = '';
  String _selectedMaritalStatusRadio = '';
  String _selectedCategoryRadio = '';
  DateTime _dobDate;
  Timer _timer;
  int _resendOTPTime = 180;
  String _timeFormat;
  bool _hasSendOTPRequest = false;
  bool _showResendOption = false;
  bool _freezeMobileField = false;
  bool karmayogiBadgeValue = false;
  var _editProfileConfig;
  List<dynamic> _inReview = [];

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _surNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _nationalityController = TextEditingController();
  final TextEditingController _domicileMediumController =
      TextEditingController();
  final TextEditingController _otherLangsController = TextEditingController();
  final TextEditingController _mobileNoController = TextEditingController();
  final TextEditingController _mobileNoOTPController = TextEditingController();
  final TextEditingController _countryCodeController = TextEditingController();
  final TextEditingController _telephoneNoController = TextEditingController();
  final TextEditingController _primaryEmailController = TextEditingController();
  final TextEditingController _secondaryEmailController =
      TextEditingController();
  final TextEditingController _postalAddressController =
      TextEditingController();
  final TextEditingController _pinCodeController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  final FocusNode _fullNameFocus = FocusNode();
  final FocusNode _dobFocus = FocusNode();
  final FocusNode _nationalityFocus = FocusNode();
  final FocusNode _domicileMediumFocus = FocusNode();
  final FocusNode _otherLangsFocus = FocusNode();
  final FocusNode _mobileNoFocus = FocusNode();
  final FocusNode _countryCodeFocus = FocusNode();
  final FocusNode _telephoneNoFocus = FocusNode();
  final FocusNode _primaryEmailFocus = FocusNode();
  final FocusNode _secondaryEmailFocus = FocusNode();
  final FocusNode _postalAddressFocus = FocusNode();
  final FocusNode _pinCodeFocus = FocusNode();
  final FocusNode _otpFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    karmayogiBadgeValue = widget.profileDetails[0].verifiedKarmayogi;
    _populateFields(widget.profileDetails);
    _getNationalities();
    _getLanguages();
    _getInReviewFields();
    _getResendTimeOTP();
    if (widget.isToUpdateMobileNumber) {
      Future.delayed(Duration(milliseconds: 1000), () {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          FocusScope.of(context).requestFocus(_mobileNoFocus);
        });
        setState(() {});
      });
    }
    if (widget.isToUpdateProfile) {
      Future.delayed(Duration(milliseconds: 1000), () {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          checkMandatoryFieldsStatus();
        });
        setState(() {});
      });
    }
  }

  _getInReviewFields() async {
    final response = await profileService.getInReviewFields();
    if (mounted) {
      setState(() {
        _inReview = response['result']['data'];
      });
    }
  }

  void _startTimer() {
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

  Future<void> _populateFields(profileDetails) async {
    String temp;
    if (profileDetails[0].personalDetails['knownLanguages'] != null &&
        profileDetails[0].personalDetails['knownLanguages'] != '') {
      temp = profileDetails[0].personalDetails['knownLanguages'].join(',');
    }
    setState(() {
      _imageBase64 = profileDetails[0].profileImageUrl;
      _fullNameController.text = profileDetails[0].firstName;
      _surNameController.text = profileDetails[0].surname;
      _dobController.text = profileDetails[0].personalDetails['dob'];
      _nationalityController.text =
          profileDetails[0].personalDetails['nationality'];
      _domicileMediumController.text =
          profileDetails[0].personalDetails['domicileMedium'];
      _otherLanguages = (temp != null && temp != '') ? temp.split(',') : [];
      _mobileNoController.text =
          profileDetails[0].personalDetails['mobile'] != null
              ? profileDetails[0].personalDetails['mobile'].toString()
              : '';
      _countryCodeController.text =
          profileDetails[0].personalDetails['countryCode'];
      _telephoneNoController.text =
          profileDetails[0].personalDetails['telephone'];
      _primaryEmailController.text =
          profileDetails[0].personalDetails['primaryEmail'];
      _officialEmail = profileDetails[0].personalDetails['officialEmail'] ==
              profileDetails[0].personalDetails['primaryEmail']
          ? true
          : false;
      _secondaryEmailController.text =
          profileDetails[0].personalDetails['personalEmail'];
      _postalAddressController.text =
          profileDetails[0].personalDetails['postalAddress'];
      _postalAddressLength =
          profileDetails[0].personalDetails['postalAddress'] != null
              ? profileDetails[0].personalDetails['postalAddress'].length
              : 0;
      _pinCodeController.text = profileDetails[0].personalDetails['pincode'];

      _selectedGender = profileDetails[0].personalDetails['gender'];
      _selectedMaritalStatusRadio =
          profileDetails[0].personalDetails['maritalStatus'];

      _selectedCategoryRadio = profileDetails[0].personalDetails['category'];
    });
  }

  Future<void> _getNationalities() async {
    List<Nationality> nationalities =
        await Provider.of<ProfileRepository>(context, listen: false)
            .getNationalities();
    if (mounted) {
      setState(() {
        _nationalities =
            nationalities.map((item) => item.country.toString()).toList();
        _countryCodes = nationalities
            .map((item) => item.countryCode.toString())
            .toSet()
            .toList();
        _countryCodes.sort();
      });
    }
  }

  Future<void> _getResendTimeOTP() async {
    _editProfileConfig = await profileService.getProfileEditConfig();
    if (_editProfileConfig['resendOTPTime'] != null && mounted) {
      setState(() {
        _resendOTPTime = _editProfileConfig['resendOTPTime'];
      });
    }
  }

  Future<dynamic> _getLanguages() async {
    List<Language> languages =
        await Provider.of<ProfileRepository>(context, listen: false)
            .getLanguages();
    _languages = languages.map((item) => item.language).toList();
    // for (int i = 0; i < _languages.length; i++) {
    //   _languages[i] = _languages[i].replaceAll('ʽ', '');
    //   _languages[i] = _languages[i].replaceAll('-', '');
    //   _languages[i] = _languages[i].replaceAll('(', '');
    //   _languages[i] = _languages[i].replaceAll(')', '');
    // }
    // developer.log(JsonEncoder() .toString());
    return _languages;
  }

  _getEditedFields() async {
    var personalDetails = [
      {
        "personalEmail": _secondaryEmailController.text,
        "isChanged": _secondaryEmailController.text !=
                widget.profileDetails[0].personalDetails['personalEmail']
            ? true
            : false
      },
      {
        "firstname": _fullNameController.text,
        "isChanged":
            _fullNameController.text != widget.profileDetails[0].firstName
                ? true
                : false
      },
      {
        'dob': _dobController.text,
        "isChanged": _dobController.text !=
                widget.profileDetails[0].personalDetails['dob']
            ? true
            : false
      },
      {
        'nationality': _nationalityController.text.toString(),
        "isChanged": _nationalityController.text !=
                widget.profileDetails[0].personalDetails['nationality']
            ? true
            : false
      },
      {
        'domicileMedium': _domicileMediumController.text.toString(),
        "isChanged": _domicileMediumController.text !=
                widget.profileDetails[0].personalDetails['domicileMedium']
            ? true
            : false
      },
      {
        'gender': _selectedGender.toString(),
        "isChanged": _selectedGender.toString() !=
                widget.profileDetails[0].personalDetails['gender']
            ? true
            : false
      },
      {
        'maritalStatus': _selectedMaritalStatusRadio.toString(),
        "isChanged": _selectedMaritalStatusRadio.toString() !=
                widget.profileDetails[0].personalDetails['maritalStatus']
            ? true
            : false
      },
      {
        'category': _selectedCategoryRadio,
        "isChanged": _selectedCategoryRadio !=
                widget.profileDetails[0].personalDetails['category']
            ? true
            : false
      },
      {
        'knownLanguages': _otherLanguages,
        "isChanged": (_otherLanguages.toString() !=
                    widget.profileDetails[0].personalDetails['knownLanguages']
                        .toString() &&
                _otherLanguages.length > 0)
            ? true
            : false
      },
      {
        'countryCode': _countryCodeController.text.toString(),
        "isChanged": _countryCodeController.text.toString() !=
                widget.profileDetails[0].personalDetails['countryCode']
                    .toString()
            ? true
            : false
      },
      {
        'mobile': _mobileNoController.text != ''
            ? int.parse(_mobileNoController.text)
            : '',
        "isChanged": (_mobileNoController.text.toString() !=
                    widget.profileDetails[0].personalDetails['mobile']
                        .toString()) ||
                widget.profileDetails[0].personalDetails['mobile']
                        .runtimeType ==
                    String
            ? true
            : false,
        "phoneVerified":
            (widget.profileDetails[0].personalDetails['phoneVerified'] != null
                    ? widget.profileDetails[0].personalDetails['phoneVerified']
                    : false) &&
                (_mobileNoController.text.toString() ==
                    widget.profileDetails[0].personalDetails['mobile']
                        .toString())
      },
      {
        "phoneVerified":
            (widget.profileDetails[0].personalDetails['phoneVerified'] != null
                    ? widget.profileDetails[0].personalDetails['phoneVerified']
                    : false) &&
                (_mobileNoController.text.toString() ==
                    widget.profileDetails[0].personalDetails['mobile']
                        .toString()),
        "isChanged": _mobileNoController.text.toString() !=
                widget.profileDetails[0].personalDetails['mobile'].toString()
            ? true
            : false,
      },
      {
        'telephone': _telephoneNoController.text.toString(),
        "isChanged": _telephoneNoController.text.toString() !=
                widget.profileDetails[0].personalDetails['telephone'].toString()
            ? true
            : false
      },
      {
        'primaryEmail': _primaryEmailController.text,
        "isChanged": _primaryEmailController.text !=
                widget.profileDetails[0].personalDetails['primaryEmail']
            ? true
            : false
      },
      {
        'officialEmail': _officialEmail ? _primaryEmailController.text : '',
        "isChanged": true
      },
      {
        'secondaryEmail': _secondaryEmailController.text,
        "isChanged": _secondaryEmailController.text !=
                widget.profileDetails[0].personalDetails['personalEmail']
            ? true
            : false
      },
      {
        'postalAddress': _postalAddressController.text,
        "isChanged": _postalAddressController.text !=
                widget.profileDetails[0].personalDetails['postalAddress']
            ? true
            : false
      },
      {
        'pincode': _pinCodeController.text.toString(),
        "isChanged": _pinCodeController.text.toString() !=
            widget.profileDetails[0].personalDetails['pincode']
      }
    ];
    var edited = {};
    var editedPersonalDetails =
        personalDetails.where((data) => data['isChanged'] == true);

    editedPersonalDetails.forEach((element) {
      edited[element.entries.first.key] = element.entries.first.value;
    });
    // developer.log(edited.toString());
    return edited;
  }

  _focusField(FocusNode focus) async {
    Future.delayed(Duration.zero, () {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        FocusScope.of(context).requestFocus(focus);
      });
      setState(() {});
    });
  }

  bool checkMandatoryFieldsStatus() {
    bool completed = true;
    for (var field in widget.mandatoryFields) {
      switch (field) {
        case 'firstname':
          if (_fullNameController.text == null ||
              _fullNameController.text.isEmpty) {
            completed = false;
            _focusField(_fullNameFocus);
          }
          break;
        case 'dob':
          if (_dobController.text == null || _dobController.text.isEmpty) {
            completed = false;
            _focusField(_dobFocus);
          }
          break;
        case 'nationality':
          if (_nationalityController.text == null ||
              _nationalityController.text.isEmpty) {
            completed = false;
            _focusField(_nationalityFocus);
          }
          break;
        case 'gender':
          if (_selectedGender == null || _selectedGender.isEmpty) {
            completed = false;
          }
          break;
        case 'maritalStatus':
          if (_selectedMaritalStatusRadio == null ||
              _selectedMaritalStatusRadio.isEmpty) {
            completed = false;
          }
          break;
        case 'category':
          if (_selectedCategoryRadio == null ||
              _selectedCategoryRadio.isEmpty) {
            completed = false;
          }
          break;
        case 'domicileMedium':
          if (_domicileMediumController.text == null ||
              _domicileMediumController.text.isEmpty) {
            completed = false;
            _focusField(_domicileMediumFocus);
          }
          break;
        case 'primaryEmail':
          if (_primaryEmailController.text == null ||
              _primaryEmailController.text.isEmpty) {
            completed = false;
            _focusField(_primaryEmailFocus);
          }
          break;
        case 'postalAddress':
          if (_postalAddressController.text == null ||
              _postalAddressController.text.isEmpty) {
            completed = false;
            _focusField(_postalAddressFocus);
          }
          break;
        case 'pincode':
          if (_pinCodeController.text == null ||
              _pinCodeController.text.isEmpty) {
            completed = false;
            _focusField(_pinCodeFocus);
          }
          break;
        default:
      }
      if (!completed) {
        break;
      }
    }
    return (personalDetailsFormKey.currentState != null &&
            personalDetailsFormKey.currentState.validate()) &&
        completed;
  }

  void _filterItems(List items, String value) {
    setState(() {
      _filterednationalities =
          items.where((item) => item.toLowerCase().contains(value)).toList();
    });
  }

  void _setListItem(String itemName) {
    setState(() {
      _nationalityController.text = itemName;
    });
  }

  Future<bool> showNationalities(BuildContext context) {
    List<String> items = _nationalities;
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
                          child: Column(children: [
                        Container(
                          padding: const EdgeInsets.only(left: 16),
                          color: Colors.white,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                color: Colors.white,
                                width:
                                    MediaQuery.of(context).size.width * 0.725,
                                height: 48,
                                child: TextFormField(
                                    onChanged: (value) {
                                      setState(() {
                                        _filterednationalities = items
                                            .where((item) => item
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
                                          .mCommonSearch,
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
                                padding:
                                    const EdgeInsets.only(left: 8, right: 12),
                                child: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
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
                            height: MediaQuery.of(context).size.height * 0.685,
                            child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: _filterednationalities.length,
                                itemBuilder: (BuildContext context, index) =>
                                    InkWell(
                                        onTap: () {
                                          _setListItem(
                                              _filterednationalities[index]);
                                          Navigator.of(context).pop(false);
                                        },
                                        child: _options(
                                            _filterednationalities[index])))),
                      ])),
                    )),
              );
            }));
  }

  Future<void> saveProfile() async {
    if (_imageBase64 != widget.profileDetails[0].profileImageUrl) {
      _profileData = {"profileImageUrl": _imageBase64};
      var response = await profileService.updateProfileDetails(_profileData);
      if (response['result']['response'] == 'success') {
        print(response);
      }
    } else {
      var editedPersonalDetails = await _getEditedFields();
      if (karmayogiBadgeValue == widget.profileDetails[0].verifiedKarmayogi) {
        _profileData = {
          "personalDetails": editedPersonalDetails,
          'academics': widget.profileDetails[0].education,
          "competencies": widget.profileDetails[0].competencies,
        };
      } else if (karmayogiBadgeValue !=
          widget.profileDetails[0].verifiedKarmayogi) {
        _profileData = {
          "personalDetails": editedPersonalDetails,
          'academics': widget.profileDetails[0].education,
          "competencies": widget.profileDetails[0].competencies,
          "verifiedKarmayogi": karmayogiBadgeValue
        };
      } else {
        _profileData = {
          "personalDetails": editedPersonalDetails,
          'academics': widget.profileDetails[0].education,
          "competencies": widget.profileDetails[0].competencies
        };
      }

      var response;
      if (checkMandatoryFieldsStatus()) {
        try {
          response = await profileService.updateProfileDetails(_profileData);
          FocusManager.instance.primaryFocus.unfocus();
          var snackBar;
          if ((response['params']['errmsg'] == null ||
                  response['params']['errmsg'] == '') &&
              (response['params']['err'] == null ||
                  response['params']['err'] == '')) {
            snackBar = SnackBar(
              content: Container(
                  child: Text(
                'Personal details updated.',
              )),
              backgroundColor: AppColors.positiveLight,
            );
          } else {
            snackBar = SnackBar(
              content: Container(
                  child: Text(
                response['params']['errmsg'] != null
                    ? response['params']['errmsg']
                    : "Error in saving profile details.",
              )),
              backgroundColor: Theme.of(context).colorScheme.error,
            );
          }
          ScaffoldMessenger.of(widget.scaffoldKey.currentContext)
              .showSnackBar(snackBar);
        } catch (err) {
          return err;
        }
      } else
        ScaffoldMessenger.of(widget.scaffoldKey.currentContext)
            .showSnackBar(SnackBar(
          content: Container(
              child: Text(
            AppLocalizations.of(context).mStaticPleaseFillAllMandatory,
          )),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
    }
  }

  Widget _options(String itemName) {
    Color _color;
    _color = _nationalityController.text == itemName
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
                const EdgeInsets.only(top: 7, bottom: 7, left: 12, right: 4),
            child: Text(
              itemName,
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

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
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
        _mobileNoOTPController.clear();
        widget.profileDetails[0].personalDetails['phoneVerified'] = false;
        FocusScope.of(context).requestFocus(_otpFocus);
        _resendOTPTime = _editProfileConfig['resendOTPTime'];
        _startTimer();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['params']['errmsg'].toString(),
              style: GoogleFonts.lato(
                color: Colors.white,
              )),
          backgroundColor: AppColors.negativeLight,
        ),
      );
    }
  }

  _verifyOTP(otp) async {
    final response = await profileService.verifyMobileNumberOTP(
        _mobileNoController.text, otp);

    if (response['params']['errmsg'] == null ||
        response['params']['errmsg'] == '') {
      //call extPatch
      _profileData = {
        "personalDetails": {
          "mobile": int.parse(_mobileNoController.text),
          "phoneVerified": true
        },
      };
      final response = await profileService.updateProfileDetails(_profileData);
      if (response['params']['status'] == 'success' ||
          response['params']['status'] == 'SUCCESS') {
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
          widget.parentAction();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['params']['errmsg'].toString(),
                style: GoogleFonts.lato(
                  color: Colors.white,
                )),
            backgroundColor: AppColors.negativeLight,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['params']['errmsg'].toString(),
              style: GoogleFonts.lato(
                color: Colors.white,
              )),
          backgroundColor: AppColors.negativeLight,
        ),
      );
    }
    setState(() {
      _freezeMobileField = false;
    });
  }

  // void _updateGender(key, value) {
  //   setState(() {
  //     _gender = {
  //       EnglishLang.male: false,
  //       EnglishLang.female: false,
  //       EnglishLang.others: false,
  //     };
  //     _gender[key] = value;
  //     _genderValue = key;
  //   });
  // }

  // void _updateMaritalStatus(key, value) {
  //   setState(() {
  //     _maritalStatus = {
  //       EnglishLang.single: false,
  //       EnglishLang.married: false,
  //     };
  //     _maritalStatus[key] = value;
  //     _maritalStatusValue = key;
  //   });
  // }

  // void _updateCategory(key, value) {
  //   setState(() {
  //     _category = {
  //       EnglishLang.general: false,
  //       EnglishLang.obc: false,
  //       EnglishLang.sc: false,
  //       EnglishLang.st: false,
  //     };
  //     _category[key] = value;
  //     _categoryValue = key;
  //   });
  // }

  Widget _getImageWidget() {
    if (_selectedFile != null) {
      // List<int> imageBytes = _selectedFile.readAsBytesSync();
      // _imageBase64 = 'data:image/jpeg;base64,' + base64Encode(imageBytes);
      return Stack(children: [
        Container(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(200),
            child: Image.file(
              _selectedFile,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          right: 0,
          child: InkWell(
            onTap: () {
              photoOptions(context);
            },
            child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.grey08,
                      blurRadius: 3,
                      spreadRadius: 0,
                      offset: Offset(
                        3,
                        3,
                      ),
                    ),
                  ],
                ),
                height: 48,
                width: 48,
                child: Icon(
                  Icons.edit,
                  color: AppColors.greys60,
                )),
          ),
        )
      ]);
    } else {
      return widget.profileDetails[0].profileImageUrl != null &&
              widget.profileDetails[0].profileImageUrl != ''
          ? Stack(children: [
              Container(
                  child: ClipRRect(
                borderRadius: BorderRadius.circular(200),
                child: Image(
                  height: MediaQuery.of(context).size.width * 0.4,
                  width: MediaQuery.of(context).size.width * 0.4,
                  fit: BoxFit.fitWidth,
                  image: NetworkImage(_imageBase64 != null
                      ? _imageBase64
                      : widget.profileDetails[0].profileImageUrl),
                  errorBuilder: (context, error, stackTrace) =>
                      SizedBox.shrink(),
                ),
              )),
              Positioned(
                bottom: 10,
                right: 0,
                child: InkWell(
                  onTap: () {
                    photoOptions(context);
                  },
                  child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.grey08,
                            blurRadius: 3,
                            spreadRadius: 0,
                            offset: Offset(
                              3,
                              3,
                            ),
                          ),
                        ],
                      ),
                      height: 48,
                      width: 48,
                      child: Icon(
                        Icons.edit,
                        color: AppColors.greys60,
                      )),
                ),
              )
            ])
          : Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.grey16,
                  width: 1,
                ),
              ),
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // _getImageWidget(),

                  Padding(
                    padding: const EdgeInsets.only(top: 40.0),
                    child: SvgPicture.asset('assets/img/connections_empty.svg',
                        width: 48, height: 48, fit: BoxFit.cover),
                  ),
                  InkWell(
                    onTap: () {
                      photoOptions(context);
                    },
                    child: Container(
                        padding: const EdgeInsets.only(top: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo,
                              color: AppColors.primaryThree,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: 80,
                                child: Text(
                                  AppLocalizations.of(context).mStaticAddAPhoto,
                                  style: GoogleFonts.lato(
                                    color: AppColors.primaryThree,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                          ],
                        )),
                  ),
                ],
              ),
            );
    }
  }

  Future<bool> photoOptions(contextMain) {
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
                          height: 120.0,
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop(true);
                                    _getImage(ImageSource.camera);
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.photo_camera,
                                        color: AppColors.primaryThree,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          AppLocalizations.of(contextMain)
                                              .mStaticTakeAPicture,
                                          style: GoogleFonts.montserrat(
                                              decoration: TextDecoration.none,
                                              color: Colors.black87,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop(true);
                                    _getImage(ImageSource.gallery);
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(Icons.photo),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          AppLocalizations.of(contextMain)
                                              .mStaticGoToFiles,
                                          style: GoogleFonts.montserrat(
                                              decoration: TextDecoration.none,
                                              color: Colors.black87,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )))
              ],
            ));
  }

  Future<dynamic> _getImage(ImageSource source) async {
    _inProcess = true;
    PickedFile image = await _picker.getImage(source: source);
    if (image != null) {
      File cropped = await ImageCropper().cropImage(
          sourcePath: image.path,
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
          compressQuality: 100,
          maxWidth: 700,
          maxHeight: 700,
          compressFormat: ImageCompressFormat.jpg,
          androidUiSettings: AndroidUiSettings(
            toolbarColor: AppColors.primaryThree,
            toolbarTitle: AppLocalizations.of(context).mStaticCropImage,
            toolbarWidgetColor: Colors.white,
            statusBarColor: Colors.grey.shade900,
            backgroundColor: Colors.white,
          ));
      await uploadImage(cropped);
      setState(() {
        _selectedFile = cropped;
        _inProcess = false;
      });
    } else {
      setState(() {
        _inProcess = false;
      });
    }
  }

  Widget _addOtherLang() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _otherLanguages.add(_otherLangsController.text);
          _otherLanguages.toSet().toList();
        });
        _otherLangsController.clear();
      },
      child: Text(
        AppLocalizations.of(context).mStaticAdd,
        style: GoogleFonts.lato(
          color: AppColors.primaryThree,
          fontWeight: FontWeight.w700,
          fontSize: 14,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _fieldNameWidget(String fieldName, {bool isMandatory = false}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 8, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          !isMandatory
              ? Text(
                  fieldName,
                  style: GoogleFonts.lato(
                    color: AppColors.greys87,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                )
              : RichText(
                  text: TextSpan(
                      text: fieldName,
                      style: GoogleFonts.lato(
                        color: AppColors.greys87,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(
                            text: ' *',
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                                fontSize: 16))
                      ]),
                ),
          // Icon(Icons.check_circle_outline)
        ],
      ),
    );
  }

  @override
  void dispose() {
    _otherLangsController.dispose();
    _mobileNoController.dispose();
    _countryCodeController.dispose();
    _telephoneNoController.dispose();
    _primaryEmailController.dispose();
    _secondaryEmailController.dispose();
    _postalAddressController.dispose();
    _pinCodeController.dispose();

    _fullNameFocus.dispose();
    // _middleNameFocus.dispose();
    _dobFocus.dispose();
    _nationalityFocus.dispose();
    _domicileMediumFocus.dispose();
    _otherLangsFocus.dispose();
    _mobileNoFocus.dispose();
    _countryCodeFocus.dispose();
    _telephoneNoFocus.dispose();
    _primaryEmailFocus.dispose();
    _secondaryEmailFocus.dispose();
    _postalAddressFocus.dispose();
    _pinCodeFocus.dispose();
    _otpFocus.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    _genderRadio = LocalizationText.getGenders(context: context);
    _maritalStatusRadio = LocalizationText.getMaritalStatus(context: context);
    _categoryRadio = LocalizationText.getCategoryStatus(context: context);
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getLanguages(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.data != null) {
          return SingleChildScrollView(
              child: Form(
            key: personalDetailsFormKey,
            child: Container(
                padding: const EdgeInsets.only(
                    bottom: 100, left: 0, right: 0, top: 16),
                color: Colors.white,
                child: Column(children: [
                  Container(
                      width: 250,
                      height: 250,
                      // height: MediaQuery.of(context).size.height,
                      // padding: const EdgeInsets.all(20),
                      child: Stack(
                        children: [
                          Container(
                              alignment: Alignment.center,
                              // padding: const EdgeInsets.all(20),
                              child: _getImageWidget()),
                          _inProcess
                              ? Container(
                                  height: MediaQuery.of(context).size.height,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : Center(),
                        ],
                      )),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        widget.mandatoryFields.contains('firstname')
                            ? RichText(
                                text: TextSpan(
                                    text: AppLocalizations.of(context)
                                        .mProfileFullName,
                                    style: GoogleFonts.lato(
                                      color: AppColors.greys87,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                    children: [
                                      TextSpan(
                                          text: ' *',
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16))
                                    ]),
                              )
                            : Text(
                                AppLocalizations.of(context).mProfileFullName,
                                style: GoogleFonts.lato(
                                  color: AppColors.greys87,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                        // Icon(Icons.check_circle_outline)
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Container(
                      // height: 40,
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        // color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Focus(
                        child: TextFormField(
                          textInputAction: TextInputAction.next,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator:
                              widget.mandatoryFields.contains('firstname')
                                  ? (String value) {
                                      if (value.isEmpty) {
                                        return AppLocalizations.of(context)
                                            .mProfileFullNameMandatory;
                                      } else if (!RegExp(r"^[a-zA-Z' ]+$")
                                          .hasMatch(value)) {
                                        return AppLocalizations.of(context)
                                            .mProfileFullNameWithConditions;
                                      } else
                                        return null;
                                    }
                                  : null,
                          focusNode: _fullNameFocus,
                          onFieldSubmitted: (term) {
                            _fieldFocusChange(
                                context, _fullNameFocus, _dobFocus);
                          },
                          // onChanged: (value) =>
                          //     _updateProfileDetails(),
                          controller: _fullNameController,
                          style: GoogleFonts.lato(fontSize: 14.0),
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            contentPadding:
                                EdgeInsets.fromLTRB(16.0, 10.0, 0.0, 10.0),
                            border: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: AppColors.grey16)),
                            hintText: AppLocalizations.of(context)
                                .mProfileEnterFullName,
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
                  ),
                  _fieldNameWidget(AppLocalizations.of(context).mProfileDOB,
                      isMandatory: widget.mandatoryFields.contains('dob')),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Container(
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        // color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      // height: 40.0,
                      child: Focus(
                        child: TextFormField(
                          textCapitalization: TextCapitalization.none,
                          textInputAction: TextInputAction.next,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: widget.mandatoryFields.contains('dob')
                              ? (String value) {
                                  if (value.isEmpty) {
                                    return AppLocalizations.of(context)
                                        .mProfileDOBMandatory;
                                  } else
                                    return null;
                                }
                              : null,
                          focusNode: _dobFocus,
                          readOnly: true,
                          onTap: () async {
                            DateTime newDate = await showDatePicker(
                                context: context,
                                initialDate: _dobDate == null
                                    ? ((_dobController.text != null &&
                                                _dobController.text != '') &&
                                            !RegExp(r'[a-zA-Z]')
                                                .hasMatch(_dobController.text)
                                        ? DateTime.parse(_dobController.text
                                            .toString()
                                            .split('-')
                                            .reversed
                                            .join('-'))
                                        : DateTime.now())
                                    : _dobDate,
                                firstDate: DateTime(1900),
                                lastDate: DateTime(2100));
                            if (newDate == null) {
                              return null;
                            }
                            setState(() {
                              _dobDate = newDate;
                              _dobController.text = newDate
                                  .toString()
                                  .split(' ')
                                  .first
                                  .split('-')
                                  .reversed
                                  .join('-');
                            });
                            _fieldFocusChange(
                                context, _dobFocus, _nationalityFocus);
                          },
                          onFieldSubmitted: (term) {
                            _fieldFocusChange(
                                context, _dobFocus, _nationalityFocus);
                          },
                          controller: _dobController,
                          style: GoogleFonts.lato(fontSize: 14.0),
                          keyboardType: TextInputType.datetime,
                          decoration: InputDecoration(
                            contentPadding:
                                EdgeInsets.fromLTRB(16.0, 0.0, 20.0, 0.0),
                            border: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: AppColors.grey16)),
                            hintText: _dobController.text != ''
                                ? _dobController.text
                                : AppLocalizations.of(context)
                                    .mStaticChooseDate,
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
                  ),
                  _fieldNameWidget(
                      AppLocalizations.of(context).mProfileNationality,
                      isMandatory:
                          widget.mandatoryFields.contains('nationality')),
                  InkWell(
                      onTap: () => _nationalities == null
                          ? null
                          : showNationalities(context),
                      child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(4.0)),
                                border: Border.all(color: Colors.grey),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 16, top: 10, bottom: 10),
                                child: Text(
                                  _nationalityController.text == null ||
                                          _nationalityController.text == ''
                                      ? AppLocalizations.of(context)
                                          .mStaticSelectHere
                                      : _nationalityController.text,
                                  style: GoogleFonts.lato(
                                    fontSize: 14.0,
                                    color: _nationalityController.text ==
                                                null ||
                                            _nationalityController.text == ''
                                        ? AppColors.greys60
                                        : AppColors.greys87,
                                  ),
                                ),
                              )))),

                  ((key1.currentState != null && key1.currentState != null) &&
                              key1.currentState.currentText.isEmpty) &&
                          widget.mandatoryFields.contains('nationality')
                      ? Container(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 32),
                            child: Text(
                              AppLocalizations.of(context)
                                  .mProfileNationalityMandatory,
                              style: GoogleFonts.lato(
                                  color: AppColors.negativeLight),
                            ),
                          ),
                        )
                      : Center(),
                  _fieldNameWidget(AppLocalizations.of(context).mProfileGender,
                      isMandatory: widget.mandatoryFields.contains('gender')),
                  // for (var entry in _gender.entries)
                  //   Padding(
                  //     padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  //     child: Container(
                  //       margin: const EdgeInsets.only(top: 10),
                  //       alignment: Alignment.centerLeft,
                  //       decoration: BoxDecoration(
                  //         color: entry.value
                  //             ? Color.fromRGBO(0, 116, 182, 0.05)
                  //             : Colors.white,
                  //         border: Border.all(
                  //           color: entry.value
                  //               ? AppColors.primaryThree
                  //               : AppColors.grey16,
                  //           width: 1,
                  //         ),
                  //         borderRadius: BorderRadius.circular(4),
                  //       ),
                  //       height: 48.0,
                  //       child: Row(
                  //         children: [
                  //           Checkbox(
                  //             value: entry.value,
                  //             onChanged: (value) {
                  //               _updateGender(entry.key, value);
                  //             },
                  //             // activeTrackColor: Color.fromRGBO(0, 116, 182, 0.3),
                  //             activeColor: AppColors.primaryThree,
                  //           ),
                  //           Text(
                  //             entry.key != null ? entry.key : '',
                  //             textAlign: TextAlign.center,
                  //             style: GoogleFonts.lato(
                  //                 color: AppColors.greys87,
                  //                 fontSize: 14.0,
                  //                 fontWeight: FontWeight.w400),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _genderRadio.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(const Radius.circular(4.0)),
                              border: Border.all(
                                  color: (_selectedGender ==
                                          _genderRadio[index].value)
                                      ? AppColors.primaryThree
                                      : AppColors.grey16,
                                  width: 1.5),
                            ),
                            child: RadioListTile(
                              dense: true,
                              // contentPadding: EdgeInsets.only(bottom:20),
                              groupValue: _selectedGender,
                              title: Text(
                                _genderRadio[index].displayText,
                                style: GoogleFonts.lato(
                                    color: AppColors.greys87,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400),
                              ),
                              value: _genderRadio[index].value,
                              onChanged: (value) {
                                setState(() {
                                  _selectedGender = value;
                                });
                              },
                              selected: (_selectedGender ==
                                  _genderRadio[index].value),
                              selectedTileColor:
                                  AppColors.selectionBackgroundBlue,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  (_selectedGender == null || _selectedGender == '') &&
                          widget.mandatoryFields.contains('gender')
                      ? Container(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 32, top: 8),
                            child: Text(
                              AppLocalizations.of(context)
                                  .mProfileGenderMandatory,
                              style: GoogleFonts.lato(
                                  color: AppColors.negativeLight),
                            ),
                          ),
                        )
                      : Center(),
                  _fieldNameWidget(
                      AppLocalizations.of(context).mProfileMartalStatus,
                      isMandatory:
                          widget.mandatoryFields.contains('maritalStatus')),
                  // for (var entry in _maritalStatus.entries)
                  //   Padding(
                  //     padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  //     child: Container(
                  //       margin: const EdgeInsets.only(top: 10),
                  //       alignment: Alignment.centerLeft,
                  //       decoration: BoxDecoration(
                  //         color: entry.value
                  //             ? Color.fromRGBO(0, 116, 182, 0.05)
                  //             : Colors.white,
                  //         border: Border.all(
                  //           color: entry.value
                  //               ? AppColors.primaryThree
                  //               : AppColors.grey16,
                  //           width: 1,
                  //         ),
                  //         borderRadius: BorderRadius.circular(4),
                  //       ),
                  //       height: 48.0,
                  //       child: Row(
                  //         children: [
                  //           Checkbox(
                  //             value: entry.value,
                  //             onChanged: (value) {
                  //               _updateMaritalStatus(entry.key, value);
                  //             },
                  //             // activeTrackColor: Color.fromRGBO(0, 116, 182, 0.3),
                  //             activeColor: AppColors.primaryThree,
                  //           ),
                  //           Text(
                  //             entry.key != null ? entry.key : '',
                  //             textAlign: TextAlign.center,
                  //             style: GoogleFonts.lato(
                  //                 color: AppColors.greys87,
                  //                 fontSize: 14.0,
                  //                 fontWeight: FontWeight.w400),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _maritalStatusRadio.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(const Radius.circular(4.0)),
                              border: Border.all(
                                  color: (_selectedMaritalStatusRadio ==
                                          _maritalStatusRadio[index].value)
                                      ? AppColors.primaryThree
                                      : AppColors.grey16,
                                  width: 1.5),
                            ),
                            child: RadioListTile(
                              dense: true,
                              // contentPadding: EdgeInsets.only(bottom:20),
                              groupValue: _selectedMaritalStatusRadio,
                              title: Text(
                                _maritalStatusRadio[index].displayText,
                                style: GoogleFonts.lato(
                                    color: AppColors.greys87,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400),
                              ),
                              value: _maritalStatusRadio[index].value,
                              onChanged: (value) {
                                setState(() {
                                  _selectedMaritalStatusRadio = value;
                                });
                              },
                              selected: (_selectedMaritalStatusRadio ==
                                  _maritalStatusRadio[index].value),
                              selectedTileColor:
                                  AppColors.selectionBackgroundBlue,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  (_selectedMaritalStatusRadio == null ||
                              _selectedMaritalStatusRadio == '') &&
                          widget.mandatoryFields.contains('maritalStatus')
                      ? Container(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 32, top: 8),
                            child: Text(
                              AppLocalizations.of(context)
                                  .mProfileMaritalMandatory,
                              style: GoogleFonts.lato(
                                  color: AppColors.negativeLight),
                            ),
                          ),
                        )
                      : Center(),
                  _fieldNameWidget(
                      AppLocalizations.of(context).mProfileCategory,
                      isMandatory: widget.mandatoryFields.contains('category')),
                  // for (var entry in _category.entries)
                  //   Padding(
                  //     padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  //     child: Container(
                  //       margin: const EdgeInsets.only(top: 10),
                  //       alignment: Alignment.centerLeft,
                  //       decoration: BoxDecoration(
                  //         color: entry.value
                  //             ? Color.fromRGBO(0, 116, 182, 0.05)
                  //             : Colors.white,
                  //         border: Border.all(
                  //           color: entry.value
                  //               ? AppColors.primaryThree
                  //               : AppColors.grey16,
                  //           width: 1,
                  //         ),
                  //         borderRadius: BorderRadius.circular(4),
                  //       ),
                  //       height: 48.0,
                  //       child: Row(
                  //         children: [
                  //           Checkbox(
                  //             value: entry.value,
                  //             onChanged: (value) {
                  //               _updateCategory(entry.key, value);
                  //             },
                  //             // activeTrackColor: Color.fromRGBO(0, 116, 182, 0.3),
                  //             activeColor: AppColors.primaryThree,
                  //           ),
                  //           Text(
                  //             entry.key != null ? entry.key : '',
                  //             textAlign: TextAlign.center,
                  //             style: GoogleFonts.lato(
                  //                 color: AppColors.greys87,
                  //                 fontSize: 14.0,
                  //                 fontWeight: FontWeight.w400),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _categoryRadio.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(const Radius.circular(4.0)),
                              border: Border.all(
                                  color: (_selectedCategoryRadio ==
                                          _categoryRadio[index].value)
                                      ? AppColors.primaryThree
                                      : AppColors.grey16,
                                  width: 1.5),
                            ),
                            child: RadioListTile(
                              dense: true,
                              // contentPadding: EdgeInsets.only(bottom:20),
                              groupValue: _selectedCategoryRadio,
                              title: Text(
                                _categoryRadio[index].displayText,
                                style: GoogleFonts.lato(
                                    color: AppColors.greys87,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400),
                              ),
                              value: _categoryRadio[index].value,
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategoryRadio = value;
                                });
                              },
                              selected: (_selectedCategoryRadio ==
                                  _categoryRadio[index].value),
                              selectedTileColor:
                                  AppColors.selectionBackgroundBlue,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  (_selectedCategoryRadio == null ||
                              _selectedCategoryRadio == '') &&
                          widget.mandatoryFields.contains('category')
                      ? Container(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 32, top: 8),
                            child: Text(
                              AppLocalizations.of(context)
                                  .mProfileCategoryMandatory,
                              style: GoogleFonts.lato(
                                  color: AppColors.negativeLight),
                            ),
                          ),
                        )
                      : Center(),
                  _fieldNameWidget(
                      AppLocalizations.of(context).mProfileDomicileMedium,
                      isMandatory:
                          widget.mandatoryFields.contains('domicileMedium')),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Container(
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      height: 40.0,
                      child: SimpleAutoCompleteTextField(
                        key: key2,
                        suggestions: _languages,
                        controller: _domicileMediumController,
                        focusNode: _domicileMediumFocus,
                        textSubmitted: (term) {
                          _fieldFocusChange(
                              context, _domicileMediumFocus, _otherLangsFocus);
                        },
                        clearOnSubmit: false,
                        decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.fromLTRB(16.0, 0.0, 20.0, 0.0),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: AppColors.grey16)),
                          hintText:
                              AppLocalizations.of(context).mCommonTypeHere,
                          hintStyle: GoogleFonts.lato(
                              color: AppColors.grey40,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w400),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color:
                                    _domicileMediumController.text.isNotEmpty ||
                                            !widget.mandatoryFields
                                                .contains('domicileMedium')
                                        ? AppColors.primaryThree
                                        : AppColors.negativeLight,
                                width: 1.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                  ((key2.currentState != null) &&
                              key2.currentState.currentText.isEmpty) &&
                          widget.mandatoryFields.contains('domicileMedium')
                      ? Container(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 32),
                            child: Text(
                              AppLocalizations.of(context)
                                  .mProfileDomicileMandatory,
                              style: GoogleFonts.lato(
                                  color: AppColors.negativeLight),
                            ),
                          ),
                        )
                      : Center(),
                  _fieldNameWidget(
                      AppLocalizations.of(context).mProfileOtherLanguages),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Container(
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      height: 40.0,
                      child: Focus(
                        child: TextFormField(
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.sentences,
                          focusNode: _otherLangsFocus,
                          onFieldSubmitted: (term) {
                            _fieldFocusChange(
                                context, _otherLangsFocus, _mobileNoFocus);
                          },
                          controller: _otherLangsController,
                          style: GoogleFonts.lato(fontSize: 14.0),
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            contentPadding:
                                EdgeInsets.fromLTRB(16.0, 0.0, 20.0, 0.0),
                            border: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: AppColors.grey16)),
                            hintText:
                                AppLocalizations.of(context).mCommonTypeHere,
                            suffix: _addOtherLang(),
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
                  ),
                  Container(
                    margin: const EdgeInsets.all(5.0),
                    alignment: Alignment.topLeft,
                    child: Wrap(
                      children: [
                        for (var i in _otherLanguages)
                          Container(
                            margin: const EdgeInsets.only(left: 12.0),
                            child: InputChip(
                              padding: EdgeInsets.all(10.0),
                              backgroundColor: AppColors.lightOrange,
                              label: Text(
                                i,
                                style: GoogleFonts.lato(
                                  color: AppColors.greys87,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.25,
                                ),
                              ),
                              deleteIcon: Stack(
                                clipBehavior: Clip.none,
                                alignment: Alignment.topLeft,
                                children: [
                                  Positioned(
                                    top: -3.5,
                                    left: -4.5,
                                    right: 0,
                                    child: Icon(Icons.cancel,
                                        size: 25.0, color: AppColors.grey40),
                                  ),
                                ],
                              ),
                              onDeleted: () {
                                setState(() {
                                  _otherLanguages
                                      .removeAt(_otherLanguages.indexOf(i));
                                });
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        widget.mandatoryFields.contains('mobile')
                            ? RichText(
                                text: TextSpan(
                                    text: AppLocalizations.of(context)
                                        .mProfileMobileNumber,
                                    style: GoogleFonts.lato(
                                        color: AppColors.greys87,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14),
                                    children: [
                                      TextSpan(
                                          text: ' *',
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16))
                                    ]),
                              )
                            : Text(
                                AppLocalizations.of(context)
                                    .mProfileMobileNumber,
                                style: GoogleFonts.lato(
                                  color: AppColors.greys87,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                        _freezeMobileField
                            ? TextButton(
                                onPressed: () {
                                  setState(() {
                                    _freezeMobileField = false;
                                  });
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size(50, 30),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
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
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    )
                                  ],
                                ))
                            : Center()
                      ],
                    ),
                  ),
                  // _fieldNameWidget(EnglishLang.mobileNumber, isMandatory: true),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Container(
                        alignment: Alignment.centerLeft,
                        // height: 70.0,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4)),
                                    border:
                                        Border.all(color: AppColors.grey40)),
                                height: 48.0,
                                width:
                                    MediaQuery.of(context).size.width * 0.165,
                                child: DropdownButton<String>(
                                  value: _countryCodeController.text.isNotEmpty
                                      ? _countryCodeController.text
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
                                  onChanged: (String newValue) {
                                    setState(() {
                                      _countryCodeController.text = newValue;
                                    });
                                    // sortCompetencies(dropdownValue);
                                  },
                                  items: _countryCodes
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value.toString()),
                                    );
                                  }).toList(),
                                )

                                // SimpleAutoCompleteTextField(
                                //   key: key3,
                                //   suggestions: _countryCodes,
                                //   controller: _countryCodeController,
                                //   focusNode: _countryCodeFocus,
                                //   keyboardType: TextInputType.phone,
                                //   clearOnSubmit: false,
                                //   decoration: InputDecoration(
                                //     contentPadding:
                                //         EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                                //     border: OutlineInputBorder(
                                //         borderSide:
                                //             BorderSide(color: AppColors.grey16)),
                                //     hintText: '+91',
                                //     hintStyle: GoogleFonts.lato(
                                //         color: AppColors.grey40,
                                //         fontSize: 14.0,
                                //         fontWeight: FontWeight.w400),
                                //     focusedBorder: OutlineInputBorder(
                                //       borderSide: const BorderSide(
                                //           color: AppColors.primaryThree,
                                //           width: 1.0),
                                //     ),
                                //   ),
                                // ),
                                ),
                            Container(
                                height: 70,
                                width:
                                    MediaQuery.of(context).size.width * 0.725,
                                decoration: BoxDecoration(
                                  // color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Focus(
                                  child: TextFormField(
                                    textInputAction: TextInputAction.next,
                                    focusNode: _mobileNoFocus,
                                    onFieldSubmitted: (term) {
                                      // _fieldFocusChange(context, _mobileNoFocus,
                                      //     _telephoneNoFocus);

                                      FocusScope.of(context).unfocus();
                                    },
                                    onChanged: (value) {
                                      setState(() {
                                        _hasSendOTPRequest = false;
                                        widget.profileDetails[0]
                                                .personalDetails[
                                            'phoneVerified'] = false;
                                        if (value.trim().length > 9 &&
                                            (widget.profileDetails[0]
                                                        .personalDetails[
                                                    'mobile'] ==
                                                value.trim())) {
                                          widget.parentAction();
                                        }
                                      });
                                    },
                                    readOnly: _freezeMobileField,
                                    controller: _mobileNoController,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    maxLength: 10,
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
                                      counterText: '',
                                      suffixIcon: (widget.profileDetails[0]
                                                          .personalDetails[
                                                      'phoneVerified'] ==
                                                  true &&
                                              _mobileNoController.text
                                                      .toString()
                                                      .trim() ==
                                                  widget.profileDetails[0]
                                                      .personalDetails['mobile']
                                                      .toString()
                                                      .trim())
                                          ? Icon(
                                              Icons.check_circle,
                                              color: AppColors.positiveLight,
                                            )
                                          : null,
                                      contentPadding: EdgeInsets.fromLTRB(
                                          16.0, 0.0, 20.0, 0.0),
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: AppColors.grey16)),
                                      hintText: AppLocalizations.of(context)
                                          .mCommonTypeHere,
                                      helperText: (_mobileNoController.text
                                                      .trim()
                                                      .length ==
                                                  10 &&
                                              RegExp(r'^\s*(?:\+?(\d{1,3}))?[-. (]*(\d{3})[-. )]*(\d{3})[-. ]*(\d{4})(?: *x(\d+))?\s*$')
                                                  .hasMatch(_mobileNoController
                                                      .text
                                                      .trim()))
                                          ? null
                                          : AppLocalizations.of(context)
                                              .mStaticAddValidNumber,
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
                          ],
                        )),
                  ),
                  (widget.profileDetails[0].personalDetails['mobile']
                                  .toString() !=
                              _mobileNoController.text.trim() ||
                          (widget.profileDetails[0]
                                  .personalDetails['phoneVerified'] ==
                              false))
                      ? !_hasSendOTPRequest
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                    padding: EdgeInsets.only(left: 16),
                                    width:
                                        MediaQuery.of(context).size.width * 0.6,
                                    child: Text(
                                      AppLocalizations.of(context)
                                          .mRegisterVerifyMobile,
                                      style: GoogleFonts.lato(
                                          fontWeight: FontWeight.w500,
                                          height: 1.5),
                                    )),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.35,
                                  padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      primary: AppColors.primaryThree,
                                      minimumSize: const Size.fromHeight(48),
                                    ),
                                    onPressed: _mobileNoController.text
                                                .trim()
                                                .length ==
                                            10
                                        ? () async {
                                            await _sendOTPToVerifyNumber();
                                          }
                                        : null,
                                    child: Text(
                                      AppLocalizations.of(context)
                                          .mStaticSendOtp,
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
                            )
                          : Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                          // height: 70,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.45,
                                          decoration: BoxDecoration(
                                            // color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Focus(
                                            child: TextFormField(
                                              textInputAction:
                                                  TextInputAction.next,
                                              controller:
                                                  _mobileNoOTPController,
                                              autovalidateMode: AutovalidateMode
                                                  .onUserInteraction,
                                              obscureText: true,
                                              validator: (String value) {
                                                if (value.isEmpty) {
                                                  return AppLocalizations.of(
                                                          context)
                                                      .mStaticEnterOtp;
                                                } else
                                                  return null;
                                              },
                                              style: GoogleFonts.lato(
                                                  fontSize: 14.0),
                                              keyboardType: TextInputType.phone,
                                              decoration: InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.fromLTRB(
                                                        16.0, 0.0, 20.0, 0.0),
                                                border: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color:
                                                            AppColors.grey16)),
                                                hintText:
                                                    AppLocalizations.of(context)
                                                        .mStaticEnterOtp,
                                                // helperText: EnglishLang.addValidNumber,
                                                hintStyle: GoogleFonts.lato(
                                                    color: AppColors.grey40,
                                                    fontSize: 14.0,
                                                    fontWeight:
                                                        FontWeight.w400),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      color: AppColors
                                                          .primaryThree,
                                                      width: 1.0),
                                                ),
                                              ),
                                            ),
                                          )),
                                      Container(
                                        // height: 45,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.4,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            primary: AppColors.primaryThree,
                                            minimumSize:
                                                const Size.fromHeight(48),
                                          ),
                                          onPressed: () async {
                                            await _verifyOTP(
                                                _mobileNoOTPController.text);
                                          },
                                          child: Text(
                                            AppLocalizations.of(context)
                                                .mProfileVerifyOTP,
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
                                  !_showResendOption
                                      ? Container(
                                          padding: EdgeInsets.only(top: 16),
                                          alignment: Alignment.topLeft,
                                          child: Text(
                                              '${AppLocalizations.of(context).mProfileResendOTPAfter} $_timeFormat'),
                                        )
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
                                                setState(() {
                                                  _showResendOption = false;
                                                  _resendOTPTime = 180;
                                                });
                                              },
                                              child: Text(
                                                  AppLocalizations.of(context)
                                                      .mProfileResendOTP)),
                                        )
                                ],
                              ),
                            )
                      : Center(),

                  _fieldNameWidget(
                      AppLocalizations.of(context).mProfileTelephoneNumber),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Container(
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      // height: 40.0,
                      child: Focus(
                        child: TextFormField(
                          textInputAction: TextInputAction.next,
                          focusNode: _telephoneNoFocus,
                          onFieldSubmitted: (term) {
                            _fieldFocusChange(context, _telephoneNoFocus,
                                _secondaryEmailFocus);
                          },
                          controller: _telephoneNoController,
                          style: GoogleFonts.lato(fontSize: 14.0),
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            contentPadding:
                                EdgeInsets.fromLTRB(16.0, 0.0, 20.0, 0.0),
                            border: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: AppColors.grey16)),
                            hintText: AppLocalizations.of(context)
                                .mStaticTelephoneNumberExample,
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
                  ),
                  _fieldNameWidget(
                      AppLocalizations.of(context).mProfilePrimaryEmail,
                      isMandatory:
                          widget.mandatoryFields.contains('primaryEmail')),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Container(
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      // height: 40.0,
                      child: Focus(
                        child: TextFormField(
                          textInputAction: TextInputAction.next,
                          focusNode: _primaryEmailFocus,
                          onFieldSubmitted: (term) {
                            _fieldFocusChange(context, _primaryEmailFocus,
                                _secondaryEmailFocus);
                          },
                          readOnly: _primaryEmailController.text.isNotEmpty,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (_primaryEmailController.text.isEmpty &&
                                  widget.mandatoryFields
                                      .contains('primaryEmail'))
                              ? (String value) {
                                  RegExp regExp = RegExp(
                                      r"[a-z0-9_-]+(?:\.[a-z0-9_-]+)*@((?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?){2,}\.){1,3}(?:\w){2,}");
                                  if (value.isEmpty) {
                                    return AppLocalizations.of(context)
                                        .mProfilePrimaryEmailMandatory;
                                  }
                                  String matchedString =
                                      regExp.stringMatch(value);
                                  if (matchedString == null ||
                                      matchedString.isEmpty ||
                                      matchedString.length != value.length) {
                                    return AppLocalizations.of(context)
                                        .mStaticAddValidEmail;
                                  }
                                  return null;
                                }
                              : null,
                          controller: _primaryEmailController,
                          style: GoogleFonts.lato(fontSize: 14.0),
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            filled: _primaryEmailController.text.isNotEmpty,
                            fillColor: AppColors.grey04,
                            contentPadding:
                                EdgeInsets.fromLTRB(16.0, 0.0, 20.0, 0.0),
                            border: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: AppColors.grey16)),
                            hintText:
                                AppLocalizations.of(context).mStaticTypeHere,
                            hintStyle: GoogleFonts.lato(
                                color: AppColors.grey40,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w400),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: AppColors.grey40, width: 1.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Row(
                      children: [
                        Checkbox(
                          value: _officialEmail,
                          onChanged: (value) {
                            setState(() {
                              _officialEmail = !_officialEmail;
                            });
                          },
                        ),
                        Text(
                          AppLocalizations.of(context).mProfileOfficialEmail,
                          textAlign: TextAlign.left,
                          style: GoogleFonts.lato(
                              color: AppColors.greys87,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                  _fieldNameWidget(
                      AppLocalizations.of(context).mProfileSecondaryEmail,
                      isMandatory:
                          widget.mandatoryFields.contains('secondaryEmail')),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Container(
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Focus(
                        child: TextFormField(
                          // autovalidateMode: AutovalidateMode.onUserInteraction,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.sentences,
                          focusNode: _secondaryEmailFocus,
                          onFieldSubmitted: (term) {
                            _fieldFocusChange(context, _secondaryEmailFocus,
                                _postalAddressFocus);
                          },
                          controller: _secondaryEmailController,
                          style: GoogleFonts.lato(fontSize: 14.0),
                          keyboardType: TextInputType.emailAddress,
                          // validator: (String value) {
                          //   RegExp regExp = RegExp(
                          //       r"[a-z0-9_-]+(?:\.[a-z0-9_-]+)*@((?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?){2,}\.){1,3}(?:\w){2,}");
                          //   String matchedString = regExp.stringMatch(value);
                          //   if (matchedString == null ||
                          //       matchedString.length != value.length) {
                          //     return EnglishLang.emailValidationText;
                          //   }
                          //   return null;
                          // },
                          decoration: InputDecoration(
                            contentPadding:
                                EdgeInsets.fromLTRB(16.0, 0.0, 20.0, 0.0),
                            border: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: AppColors.grey16)),
                            hintText:
                                AppLocalizations.of(context).mCommonTypeHere,
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
                  ),
                  _fieldNameWidget(
                      AppLocalizations.of(context).mProfilePostalAddress,
                      isMandatory:
                          widget.mandatoryFields.contains('postalAddress')),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Container(
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      // height: 50.0,
                      child: Focus(
                        child: TextFormField(
                          textInputAction: TextInputAction.next,
                          focusNode: _postalAddressFocus,
                          onFieldSubmitted: (term) {
                            _fieldFocusChange(
                                context, _postalAddressFocus, _pinCodeFocus);
                          },
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator:
                              widget.mandatoryFields.contains('postalAddress')
                                  ? (String value) {
                                      if (value.isEmpty) {
                                        return AppLocalizations.of(context)
                                            .mProfilePostalAddressMandatory;
                                      } else
                                        return null;
                                    }
                                  : null,
                          onChanged: (text) {
                            setState(() {
                              _postalAddressLength = text.length;
                            });
                          },
                          controller: _postalAddressController,
                          maxLength: 200,
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          style: GoogleFonts.lato(fontSize: 14.0),
                          keyboardType: TextInputType.multiline,
                          minLines: 5,
                          maxLines: 5,
                          decoration: InputDecoration(
                              contentPadding:
                                  EdgeInsets.fromLTRB(16.0, 20.0, 20.0, 0.0),
                              border: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: AppColors.grey16)),
                              hintText:
                                  AppLocalizations.of(context).mCommonTypeHere,
                              hintStyle: GoogleFonts.lato(
                                  color: AppColors.grey40,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w400),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: AppColors.primaryThree, width: 1.0),
                              ),
                              counterStyle: TextStyle(
                                height: double.minPositive,
                              ),
                              counterText: ''),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(top: 5, right: 16),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          _postalAddressLength.toString() +
                              '/200 ' +
                              AppLocalizations.of(context).mProfileCharacters,
                          style: GoogleFonts.lato(
                            color: AppColors.greys60,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      )),
                  _fieldNameWidget(AppLocalizations.of(context).mProfilePinCode,
                      isMandatory: widget.mandatoryFields.contains('pincode')),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Container(
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      // height: 40.0,
                      child: Focus(
                        child: TextFormField(
                          maxLength: 6,
                          maxLengthEnforcement: MaxLengthEnforcement.none,
                          // textInputAction: TextInputAction.next,
                          focusNode: _pinCodeFocus,
                          // obscureText: true,
                          // onFieldSubmitted: (term) {
                          //   _fieldFocusChange(
                          //       context,
                          //       _secondaryEmailFocus,
                          //       _postalAddressFocus);
                          // },
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (String value) {
                            if (value.isEmpty) {
                              return AppLocalizations.of(context)
                                  .mProfilePinMandatory;
                            } else if (value.length != 6 ||
                                !RegExp(r'^[0-9]+$').hasMatch(value)) {
                              return AppLocalizations.of(context)
                                  .mProfilePinLength;
                            } else
                              return null;
                          },
                          controller: _pinCodeController,
                          style: GoogleFonts.lato(fontSize: 14.0),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            counterText: '',
                            contentPadding:
                                EdgeInsets.fromLTRB(16.0, 0.0, 20.0, 0.0),
                            border: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: AppColors.grey16)),
                            hintText:
                                AppLocalizations.of(context).mCommonTypeHere,
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
                  ),
                  CheckboxListTile(
                    title: Text(AppLocalizations.of(context)
                        .mProfileEarnKarmayogiBadge),
                    value: karmayogiBadgeValue,
                    onChanged: widget.profileDetails[0].verifiedKarmayogi ||
                            _inReview.contains('verifiedKarmayogi')
                        ? (newValue) {}
                        : (newValue) {
                            setState(() {
                              karmayogiBadgeValue = newValue;
                            });
                          },
                    controlAffinity: ListTileControlAffinity
                        .leading, //  <-- leading Checkbox
                    secondary: _inReview.contains('verifiedKarmayogi')
                        ? _reviewStatusIconWidget()
                        : widget.profileDetails[0].verifiedKarmayogi
                            ? _reviewStatusIconWidget(isApproved: true)
                            : _reviewStatusIconWidget(isRequired: true),
                  )
                ])),
          ));
        } else {
          return PageLoader(
            bottom: 125,
          );
        }
      },
    );
  }

  Widget _reviewStatusIconWidget(
      {bool isApproved = false, bool isRequired = false}) {
    return SvgPicture.asset(
      isApproved
          ? 'assets/img/approved.svg'
          : isRequired
              ? 'assets/img/needs_approval.svg'
              : 'assets/img/sent_for_approval.svg',
      width: 22,
      height: 22,
    );
  }

  Future<void> uploadImage(File _selectedFile) async {
    var response = await Provider.of<ProfileRepository>(context, listen: false)
        .profilePhotoUpdate(_selectedFile);
    if (response.runtimeType == int) {
      print('Image upload failed!');
    } else {
      setState(() {
        _imageBase64 = Helper.convertPortalImageUrl(response);
        _storage.write(key: Storage.profileImageUrl, value: _imageBase64);
        widget.parentAction();
      });
      await saveProfile();
    }
  }
}
