import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/respositories/_respositories/profile_repository.dart';
import 'package:provider/provider.dart';
import './../../../../constants/index.dart';
import './../../../../models/index.dart';
import './../../../../services/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import './../../../../localization/index.dart';

class EditProfessionalDetailsPage extends StatefulWidget {
  final profileDetails;
  final scaffoldKey;
  static final GlobalKey<_EditProfessionalDetailsPageState>
      professionalDetailsGlobalKey = GlobalKey();
  final List mandatoryFields;
  EditProfessionalDetailsPage({
    Key key,
    this.profileDetails,
    this.scaffoldKey,
    this.mandatoryFields,
  }) : super(key: professionalDetailsGlobalKey);

  @override
  _EditProfessionalDetailsPageState createState() =>
      _EditProfessionalDetailsPageState();
}

class _EditProfessionalDetailsPageState
    extends State<EditProfessionalDetailsPage> {
  final ProfileService profileService = ProfileService();

  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _allotmentYearOfServiceController =
      TextEditingController();
  final TextEditingController _dateOfJoiningController =
      TextEditingController();
  final TextEditingController _dateOfJoiningExpController =
      TextEditingController();
  final TextEditingController _civilListNumberController =
      TextEditingController();
  final TextEditingController _employeeCodeController = TextEditingController();
  final TextEditingController _officialPostalAddressController =
      TextEditingController();
  final TextEditingController _pinCodeController = TextEditingController();

  final FocusNode _descriptionFocus = FocusNode();
  final FocusNode _allotmentYearOfServiceFocus = FocusNode();
  final FocusNode _dateOfJoiningFocus = FocusNode();
  final FocusNode _dateOfJoiningExpFocus = FocusNode();
  final FocusNode _civilListNumberFocus = FocusNode();
  final FocusNode _employeeCodeFocus = FocusNode();
  final FocusNode _officialPostalAddressFocus = FocusNode();
  final FocusNode _pinCodeFocus = FocusNode();

  Map _organisationTypes = <String, bool>{
    EnglishLang.government: false,
    EnglishLang.nonGovernment: false,
  };

  List _organizationTypesRadio = [
    EnglishLang.government,
    EnglishLang.nonGovernment
  ];

  // String _orgType;
  List<String> _organisationList = [];
  List<String> _industriesList = [];
  List<String> _locationList = [];
  List<String> _designationList = [];
  List<String> _gradePayList = [];
  List<String> _serviceList = [];
  List<String> _cadreList = [];
  List<String> _tagsList = [];
  String _selectedOrganisation;
  String _selectedIndustry;
  String _selectedLocation;
  String _selectedDesignation;
  String _selectedGradePay;
  String _selectedService;
  String _selectedCadre;
  Map _profileData;
  String _selectedOrg = '';
  TextEditingController _searchController = TextEditingController();
  List<String> _filteredItems = [];
  DateTime _selectedDate;
  List<dynamic> _inReview = [];

  @override
  void initState() {
    super.initState();
    _populateFields();
    _getOrganisations();
    _getLocations();
    _getIndustries();
    _getDesignations();
    _getGradePay();
    _getServices();
    _getCadre();
    _getInReviewFields();
  }

  _getInReviewFields() async {
    final response = await profileService.getInReviewFields();
    if (mounted) {
      setState(() {
        _inReview = response['result']['data'];
      });
    }
  }

  _isMandatoryFilled() {
    bool completed = true;
    for (var field in widget.mandatoryFields) {
      switch (field) {
        case 'organisationType':
          if (_selectedOrg == null || _selectedOrg.isEmpty) {
            completed = false;
          }
          break;
        case 'departmentName':
          if (_selectedOrganisation == null || _selectedOrganisation.isEmpty) {
            completed = false;
          }
          break;
        case 'industry':
          if (_selectedIndustry == null || _selectedIndustry.isEmpty) {
            completed = false;
          }
          break;
        case 'designation':
          if (_selectedDesignation == null || _selectedDesignation.isEmpty) {
            completed = false;
          }
          break;
        case 'location':
          if (_selectedLocation == null || _selectedLocation.isEmpty) {
            completed = false;
          }
          break;
        case 'doj':
          if (_dateOfJoiningController.text == null ||
              _dateOfJoiningController.text.isEmpty) {
            completed = false;
          }
          break;
        case 'description':
          if (_descriptionController.text == null ||
              _descriptionController.text.isEmpty) {
            completed = false;
          }
          break;
        default:
      }
      if (!completed) {
        break;
      }
    }
    return completed;
  }

  Future<void> _populateFields() async {
    if (widget.profileDetails[0].employmentDetails.length > 0) {
      _selectedGradePay = widget.profileDetails[0].employmentDetails['payType'];
      _selectedService = widget.profileDetails[0].employmentDetails['service'];

      _selectedCadre = widget.profileDetails[0].employmentDetails['cadre'];
      _allotmentYearOfServiceController.text =
          widget.profileDetails[0].employmentDetails['allotmentYearOfService'];
      _dateOfJoiningExpController.text =
          widget.profileDetails[0].employmentDetails['dojOfService'];
      _civilListNumberController.text =
          widget.profileDetails[0].employmentDetails['civilListNo'];

      _employeeCodeController.text =
          widget.profileDetails[0].employmentDetails['employeeCode'];
      _officialPostalAddressController.text =
          widget.profileDetails[0].employmentDetails['officialPostalAddress'];
      _pinCodeController.text =
          widget.profileDetails[0].employmentDetails['pinCode'];
    }

    if (widget.profileDetails[0].experience.length > 0) {
      setState(() {
        if (widget.profileDetails[0].experience[0]['organisationType'] !=
                null &&
            widget.profileDetails[0].experience[0]['organisationType'] != '') {
          _organisationTypes[widget.profileDetails[0].experience[0]
              ['organisationType']] = true;
          _selectedOrg =
              widget.profileDetails[0].experience[0]['organisationType'];
          // _orgType = widget.profileDetails[0].experience[0]['organisationType'];
        }
        _selectedOrganisation =
            widget.profileDetails[0].rawDetails['rootOrg']['orgName'];
        _selectedIndustry = widget.profileDetails[0].experience[0]['industry'];
        _selectedDesignation =
            widget.profileDetails[0].experience[0]['designation'];
        _selectedLocation = widget.profileDetails[0].experience[0]['location'];
        _dateOfJoiningController.text =
            widget.profileDetails[0].experience[0]['doj'];
        _descriptionController.text =
            widget.profileDetails[0].experience[0]['description'];
        _tagsList = List.from(widget.profileDetails[0].tags);
      });
    } else {
      setState(() {
        _selectedOrganisation =
            widget.profileDetails[0].rawDetails['rootOrg']['orgName'];
      });
    }
  }

  Future<void> _getOrganisations() async {
    List<dynamic> _organisations =
        await Provider.of<ProfileRepository>(context, listen: false)
            .getOrganisations();
    if (mounted) {
      setState(() {
        _organisationList =
            _organisations.map((item) => item.toString()).toList();
        _organisationList
            .sort((a, b) => a.toUpperCase().compareTo(b.toUpperCase()));
      });
    }
  }

  Future<void> _getIndustries() async {
    List<dynamic> _industries =
        await Provider.of<ProfileRepository>(context, listen: false)
            .getIndustries();
    if (mounted) {
      setState(() {
        _industriesList = _industries.map((item) => item.toString()).toList();
      });
    }
  }

  Future<void> _getDesignations() async {
    List<dynamic> _designations =
        await Provider.of<ProfileRepository>(context, listen: false)
            .getDesignations();
    if (mounted) {
      setState(() {
        _designationList =
            _designations.map((item) => item.toString()).toList();
      });
    }
  }

  //getGradePay

  Future<void> _getGradePay() async {
    List<dynamic> _gradepay =
        await Provider.of<ProfileRepository>(context, listen: false)
            .getGradePay();
    if (mounted) {
      setState(() {
        _gradepay.sort(((a, b) => int.parse(a).compareTo(int.parse(b))));
        _gradePayList = _gradepay;
      });
    }
  }

  Future<void> _getServices() async {
    List<dynamic> _services =
        await Provider.of<ProfileRepository>(context, listen: false)
            .getServices();
    setState(() {
      _serviceList = _services.map((item) => item.toString()).toList();
      // _serviceList.insert(0, EnglishLang.selectFromDropdown);
    });
  }

  Future<void> _getCadre() async {
    List<dynamic> _cadre =
        await Provider.of<ProfileRepository>(context, listen: false).getCadre();
    if (mounted) {
      setState(() {
        _cadreList = _cadre.map((item) => item.toString()).toList();
        // _cadreList.insert(0, EnglishLang.selectFromDropdown);
      });
    }
  }

  Future<void> _getLocations() async {
    List<Nationality> nationalities =
        await Provider.of<ProfileRepository>(context, listen: false)
            .getNationalities();
    if (mounted) {
      setState(() {
        _locationList =
            nationalities.map((item) => item.country.toString()).toList();
        // _locationList.insert(0, EnglishLang.selectFromDropdown);
      });
    }
  }

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  // void _updateOrganisation(key, value) {
  //   setState(() {
  //     _organisationTypes = {
  //       EnglishLang.government: false,
  //       EnglishLang.nonGovernment: false,
  //     };
  //     _organisationTypes[key] = value;
  //     _orgType = key;
  //   });
  // }
  _getEditedEmploymentDetails() async {
    var employmentDetails = [
      {
        'allotmentYearOfService':
            _allotmentYearOfServiceController.text.toString(),
        'isChanged': _allotmentYearOfServiceController.text.toString() !=
                (widget.profileDetails[0]
                            .employmentDetails['allotmentYearOfService'] !=
                        null
                    ? widget.profileDetails[0]
                        .employmentDetails['allotmentYearOfService']
                        .toString()
                    : '')
            ? true
            : false
      },
      {
        'cadre': _selectedCadre,
        'isChanged': _selectedCadre !=
                widget.profileDetails[0].employmentDetails['cadre']
            ? true
            : false
      },
      {
        'civilListNo': _civilListNumberController.text.toString(),
        'isChanged': _civilListNumberController.text.toString() !=
                (widget.profileDetails[0].employmentDetails['civilListNo'] !=
                        null
                    ? widget.profileDetails[0].employmentDetails['civilListNo']
                        .toString()
                    : '')
            ? true
            : false
      },
      {
        'dojOfService': _dateOfJoiningExpController.text.toString(),
        'isChanged': _dateOfJoiningExpController.text.toString() !=
                (widget.profileDetails[0].employmentDetails['dojOfService'] !=
                        null
                    ? widget.profileDetails[0].employmentDetails['dojOfService']
                        .toString()
                    : '')
            ? true
            : false
      },
      {
        'employeeCode': _employeeCodeController.text.toString(),
        'isChanged': _employeeCodeController.text.toString() !=
                (widget.profileDetails[0].employmentDetails['employeeCode'] !=
                        null
                    ? widget.profileDetails[0].employmentDetails['employeeCode']
                    : '')
            ? true
            : false
      },
      {
        'officialPostalAddress': _officialPostalAddressController.text,
        'isChanged': _officialPostalAddressController.text !=
                (widget.profileDetails[0]
                            .employmentDetails['officialPostalAddress'] !=
                        null
                    ? widget.profileDetails[0]
                        .employmentDetails['officialPostalAddress']
                    : '')
            ? true
            : false
      },
      {
        'payType': _selectedGradePay,
        'isChanged': _selectedGradePay !=
                widget.profileDetails[0].employmentDetails['payType']
            ? true
            : false
      },
      {
        'pinCode': _pinCodeController.text.toString(),
        'isChanged': _pinCodeController.text.toString() !=
                (widget.profileDetails[0].employmentDetails['pinCode'] != null
                    ? widget.profileDetails[0].employmentDetails['pinCode']
                        .toString()
                    : '')
            ? true
            : false
      },
      {
        'service': _selectedService != EnglishLang.selectFromDropdown
            ? _selectedService
            : '',
        'isChanged': _selectedService !=
                widget.profileDetails[0].employmentDetails['service']
            ? true
            : false
      }
    ];
    var edited = {};
    var editedEmploymentDetails =
        employmentDetails.where((data) => data['isChanged'] == true);

    editedEmploymentDetails.forEach((element) {
      edited[element.entries.first.key] = element.entries.first.value;
    });
    // developer.log(edited.isEmpty.toString());
    return edited;
  }

  _getEditedProfessionalDetails() async {
    var professionalDetails = [
      {
        'organisationType': _selectedOrg,
        "isChanged": _organizationTypesRadio.contains(_selectedOrg) &&
                (_selectedOrg !=
                    ((widget.profileDetails[0].experience.length > 0)
                        ? widget.profileDetails[0].experience[0]
                            ['organisationType']
                        : null))
            ? true
            : false
      },
      {
        'name': _selectedOrganisation,
        'isChanged': _selectedOrganisation != null &&
                (_selectedOrganisation !=
                    widget.profileDetails[0].rawDetails['rootOrg']['orgName'])
            ? true
            : false
      },
      {
        'designation': _selectedDesignation,
        'isChanged': _selectedDesignation != null &&
                (_selectedDesignation !=
                        (widget.profileDetails[0].experience.toString() ==
                                [].toString()
                            ? ''
                            : widget.profileDetails[0].experience[0]
                                ['designation']) &&
                    !_inReview.contains('designation'))
            ? true
            : false
      },
      {
        'industry': _selectedIndustry,
        'isChanged': _selectedIndustry != null &&
                (_selectedIndustry !=
                    (widget.profileDetails[0].experience.toString() ==
                            [].toString()
                        ? ''
                        : widget.profileDetails[0].experience[0]['industry']))
            ? true
            : false
      },
      {
        'location': _selectedLocation,
        'isChanged': _selectedLocation != null &&
                (_selectedLocation !=
                    (widget.profileDetails[0].experience.toString() ==
                            [].toString()
                        ? ''
                        : widget.profileDetails[0].experience[0]['location']))
            ? true
            : false
      },
      {
        'doj': _dateOfJoiningController.text.toString(),
        'isChanged': (_dateOfJoiningController.text.toString() !=
                    (widget.profileDetails[0].experience.toString() ==
                            [].toString()
                        ? ''
                        : widget.profileDetails[0].experience[0]['doj']
                            .toString()) &&
                !_inReview.contains('doj'))
            ? true
            : false
      },
      {
        'description': _descriptionController.text,
        'isChanged': (_descriptionController.text !=
                (widget.profileDetails[0].experience.toString() == [].toString()
                    ? ''
                    : (widget.profileDetails[0].experience[0]['description'] !=
                            null
                        ? widget.profileDetails[0].experience[0]['description']
                        : '')))
            ? true
            : false
      }
    ];
    var edited = {};
    var editedProfessionalDetails =
        professionalDetails.where((data) => data['isChanged'] == true);

    editedProfessionalDetails.forEach((element) {
      edited[element.entries.first.key] = element.entries.first.value;
    });
    // developer.log(edited.toString());
    return edited;
  }

  Future<void> saveProfile() async {
    var editedEmploymentDetails = await _getEditedEmploymentDetails();
    var editedProfessionalDetails = await _getEditedProfessionalDetails();

    if (_isMandatoryFilled()) {
      if (editedEmploymentDetails.isEmpty) {
        _profileData = {
          'academics': widget.profileDetails[0].education,
          'professionalDetails': [editedProfessionalDetails],
          "competencies": widget.profileDetails[0].competencies,
        };
      } else if (editedProfessionalDetails.isEmpty) {
        _profileData = {
          'academics': widget.profileDetails[0].education,
          'employmentDetails': editedEmploymentDetails,
          "competencies": widget.profileDetails[0].competencies,
        };
      } else {
        _profileData = {
          'academics': widget.profileDetails[0].education,
          'employmentDetails': editedEmploymentDetails,
          'professionalDetails': [editedProfessionalDetails],
          "competencies": widget.profileDetails[0].competencies,
        };
      }
      var response;
      try {
        var snackBar;
        response = await profileService.updateProfileDetails(_profileData);
        FocusManager.instance.primaryFocus.unfocus();

        if ((response['params']['errmsg'] == null ||
                response['params']['errmsg'] == '') &&
            (response['params']['err'] == null ||
                response['params']['err'] == '')) {
          snackBar = SnackBar(
            content: Container(
                child: Text(
              AppLocalizations.of(context)
                  .mStaticProfessionalDetailsUpdatedText,
            )),
            backgroundColor: AppColors.positiveLight,
          );
          _getInReviewFields();
        } else {
          snackBar = SnackBar(
            content: Container(
                child: Text(
              response['params']['errmsg'] != null
                  ? response['params']['errmsg']
                  : AppLocalizations.of(context).mErrorSavingProfile,
            )),
            backgroundColor: Theme.of(context).colorScheme.error,
          );
        }

        ScaffoldMessenger.of(widget.scaffoldKey.currentContext)
            .showSnackBar(snackBar);
      } catch (err) {
        return err;
      }
    } else {
      ScaffoldMessenger.of(widget.scaffoldKey.currentContext)
          .showSnackBar(SnackBar(
        content: Container(
            child: Text(
          AppLocalizations.of(context).mStaticPleaseFillAllMandatory,
        )),
        backgroundColor: AppColors.negativeLight,
      ));
    }
  }

  Widget _titleFieldWidget(String title,
      {bool topPadding = true, bool isMandatory = false}) {
    return Padding(
      padding: EdgeInsets.only(top: topPadding ? 32 : 24, bottom: 8, left: 16),
      child: Container(
        alignment: Alignment.topLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            !isMandatory
                ? Text(
                    title,
                    style: GoogleFonts.lato(
                      color: AppColors.greys87,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  )
                : RichText(
                    text: TextSpan(
                        text: title,
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
      ),
    );
  }

  Widget _inReviewWidget(String field) {
    return _inReview.contains(field)
        ? Padding(
            padding: const EdgeInsets.only(left: 16, top: 8),
            child: Text(
              AppLocalizations.of(context).mEditProfessionalDetailsInReview,
              style: GoogleFonts.lato(
                color: AppColors.negativeLight,
              ),
            ),
          )
        : Center();
  }

  Widget _reviewStatusIconWidget(
      {bool topPadding = true,
      bool isApproved = false,
      bool isRequired = false}) {
    return Padding(
      padding: EdgeInsets.only(right: 16, top: 20),
      child: SvgPicture.asset(
        isApproved
            ? 'assets/img/approved.svg'
            : isRequired
                ? 'assets/img/needs_approval.svg'
                : 'assets/img/sent_for_approval.svg',
        width: 22,
        height: 22,
      ),
    );
  }

  Widget _fieldNameWidget(String fieldName) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 24, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            fieldName,
            style: GoogleFonts.lato(
              color: AppColors.greys87,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          // Icon(Icons.check_circle_outline)
        ],
      ),
    );
  }

  void _setListItem(String listType, String itemName) {
    setState(() {
      switch (listType) {
        case EnglishLang.organisationName:
          _selectedOrganisation = itemName;
          break;
        case EnglishLang.industry:
          _selectedIndustry = itemName;
          break;
        case EnglishLang.designation:
          _selectedDesignation = itemName;
          break;
        case EnglishLang.location:
          _selectedLocation = itemName;
          break;
        case EnglishLang.payBand:
          _selectedGradePay = itemName;
          break;
        case EnglishLang.service:
          _selectedService = itemName;
          break;
        default:
          _selectedCadre = itemName;
      }
    });
  }

  void _filterItems(List items, String value) {
    setState(() {
      _filteredItems =
          items.where((item) => item.toLowerCase().contains(value)).toList();
    });
  }

  Future<bool> _showListOfOptions(contextMain, String listType) {
    List<String> items = [];
    switch (listType) {
      case EnglishLang.organisationName:
        items = _organisationList;
        break;
      case EnglishLang.industry:
        items = _industriesList;
        break;
      case EnglishLang.designation:
        items = _designationList;
        break;
      case EnglishLang.location:
        items = _locationList;
        break;
      case EnglishLang.payBand:
        items = _gradePayList;
        break;
      case EnglishLang.service:
        items = _serviceList;
        break;
      default:
        items = _cadreList;
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
                      // height: (_graduationDegreesList.length * 52.0),
                      child: Material(
                          child: Column(
                              // mainAxisAlignment:
                              //     MainAxisAlignment.end,
                              children: [
                            Container(
                              padding: const EdgeInsets.only(left: 16),
                              color: Colors.white,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    color: Colors.white,
                                    width: MediaQuery.of(context).size.width *
                                        0.725,
                                    // width: 316,
                                    height: 48,
                                    child: TextFormField(
                                        onChanged: (value) {
                                          setState(() {
                                            _filteredItems = items
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
                                    padding: const EdgeInsets.only(
                                        left: 8, right: 12),
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
                                height:
                                    MediaQuery.of(context).size.height * 0.685,
                                child: ListView.builder(
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
                                                  case EnglishLang
                                                      .organisationName:
                                                    _selectedOrganisation =
                                                        _filteredItems[index];
                                                    break;
                                                  case EnglishLang.industry:
                                                    _selectedIndustry =
                                                        _filteredItems[index];
                                                    break;
                                                  case EnglishLang.designation:
                                                    _selectedDesignation =
                                                        _filteredItems[index];
                                                    break;
                                                  case EnglishLang.location:
                                                    _selectedLocation =
                                                        _filteredItems[index];
                                                    break;
                                                  case EnglishLang.payBand:
                                                    _selectedGradePay =
                                                        _filteredItems[index];
                                                    break;
                                                  case EnglishLang.service:
                                                    _selectedService =
                                                        _filteredItems[index];
                                                    break;
                                                  default:
                                                    _selectedCadre =
                                                        _filteredItems[index];
                                                }
                                              });
                                              _getInReviewFields();
                                              Navigator.of(context).pop(false);
                                            },
                                            child: _options(listType,
                                                _filteredItems[index])))),
                          ])),
                    )),
              );
            }));
  }

  Widget _options(String listType, String itemName) {
    Color _color;
    switch (listType) {
      case EnglishLang.organisationName:
        _color = _selectedOrganisation == itemName
            ? AppColors.lightSelected
            : Colors.white;
        break;
      case EnglishLang.industry:
        _color = _selectedIndustry == itemName
            ? AppColors.lightSelected
            : Colors.white;
        break;
      case EnglishLang.designation:
        _color = _selectedDesignation == itemName
            ? AppColors.lightSelected
            : Colors.white;
        break;
      case EnglishLang.location:
        _color = _selectedLocation == itemName
            ? AppColors.lightSelected
            : Colors.white;
        break;
      case EnglishLang.payBand:
        _color = _selectedGradePay == itemName
            ? AppColors.lightSelected
            : Colors.white;
        break;
      case EnglishLang.service:
        _color = _selectedService == itemName
            ? AppColors.lightSelected
            : Colors.white;
        break;
      default:
        _color =
            _selectedCadre == itemName ? AppColors.lightSelected : Colors.white;
        break;
    }
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Container(
          decoration: BoxDecoration(
            color: _color,

            // ? AppColors.lightSelected
            // : Colors.white,
            // color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
          // height: 52,
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

  _iconIndicatorWidget(String iconPath, String text) {
    return Container(
      margin: const EdgeInsets.only(
        top: 20,
      ),
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Container(
          height: 40,
          padding: EdgeInsets.only(left: 8, right: 8),
          // width: 165,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon(Icons.check_circle_outline),
              SvgPicture.asset(
                // 'assets/img/needs_approval.svg',
                iconPath,
                width: 22,
                height: 22,
                // alignment: Alignment.center,
                // height: double.infinity,
                // fit: BoxFit.cover,
              ),
              SizedBox(
                width: 8,
              ),
              Text(
                text,
                style: GoogleFonts.lato(
                  color: AppColors.greys87,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400,
                ),
              )
            ],
          ),
          decoration: BoxDecoration(
            color: AppColors.grey04,
            borderRadius: BorderRadius.all(const Radius.circular(24.0)),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _allotmentYearOfServiceController.dispose();
    _dateOfJoiningController.dispose();
    _dateOfJoiningExpController.dispose();
    _civilListNumberController.dispose();
    _employeeCodeController.dispose();
    _officialPostalAddressController.dispose();
    _pinCodeController.dispose();

    _descriptionFocus.dispose();
    _allotmentYearOfServiceFocus.dispose();
    _dateOfJoiningFocus.dispose();
    _dateOfJoiningExpFocus.dispose();
    _civilListNumberFocus.dispose();
    _employeeCodeFocus.dispose();
    _officialPostalAddressFocus.dispose();
    _pinCodeFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: FutureBuilder(
            future: Future.delayed(Duration(milliseconds: 1500)),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (true) {
                return SingleChildScrollView(
                    child: Column(children: [
                  Container(
                    margin: EdgeInsets.only(left: 2),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _iconIndicatorWidget(
                              'assets/img/needs_approval.svg',
                              AppLocalizations.of(context)
                                  .mStaticRequiresApproval),
                          _iconIndicatorWidget(
                              'assets/img/sent_for_approval.svg',
                              AppLocalizations.of(context)
                                  .mStaticSentForApproval),
                          _iconIndicatorWidget('assets/img/approved.svg',
                              AppLocalizations.of(context).mStaticApproved),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _titleFieldWidget(
                            AppLocalizations.of(context)
                                .mStaticTypeOfOrganisation,
                            topPadding: false,
                            isMandatory: widget.mandatoryFields
                                .contains('organisationType')),
                        _inReview.contains('organisationType')
                            ? _reviewStatusIconWidget(topPadding: false)
                            : ((_selectedOrg != null && _selectedOrg != '') &&
                                    _selectedOrg ==
                                        (widget.profileDetails[0].experience
                                                    .length >
                                                0
                                            ? widget.profileDetails[0]
                                                    .experience[0]
                                                ['organisationType']
                                            : null))
                                ? _reviewStatusIconWidget(
                                    isApproved: true, topPadding: false)
                                : _reviewStatusIconWidget(
                                    isRequired: true, topPadding: false)
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    // margin: EdgeInsets.only(top: 5.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: GridView.count(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                crossAxisCount: 2,
                                childAspectRatio: 4,
                                children: List.generate(
                                    _organizationTypesRadio.length, (index) {
                                  // itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      if (!_inReview
                                          .contains('organisationType')) {
                                        setState(() {
                                          _selectedOrg =
                                              _organizationTypesRadio[index];
                                        });
                                      }
                                    },
                                    child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            16, 8, 16, 0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                const Radius.circular(4.0)),
                                            color: (_selectedOrg ==
                                                        _organizationTypesRadio[
                                                            index]) ||
                                                    ((_selectedOrg == '') &&
                                                        _organizationTypesRadio[
                                                                index] ==
                                                            EnglishLang
                                                                .government)
                                                ? AppColors.primaryThree
                                                : Colors.white,
                                            border: Border.all(
                                              color: (_selectedOrg ==
                                                          _organizationTypesRadio[
                                                              index]) ||
                                                      ((_selectedOrg == '') &&
                                                          _organizationTypesRadio[
                                                                  index] ==
                                                              EnglishLang
                                                                  .government)
                                                  ? AppColors.primaryThree
                                                  : AppColors.greys60,
                                            ),
                                          ),
                                          child: Center(
                                              child: Text(
                                            _organizationTypesRadio[index] ==
                                                    EnglishLang.government
                                                ? AppLocalizations.of(context)
                                                    .mStaticGovernment
                                                : AppLocalizations.of(context)
                                                    .mStaticNonGovernment,
                                            style: GoogleFonts.lato(
                                                fontSize: 14,
                                                color: (_selectedOrg ==
                                                            _organizationTypesRadio[
                                                                index]) ||
                                                        ((_selectedOrg == '') &&
                                                            _organizationTypesRadio[
                                                                    index] ==
                                                                EnglishLang
                                                                    .government)
                                                    ? Colors.white
                                                    : AppColors.greys60),
                                          )),
                                        )),
                                  );
                                }))),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _titleFieldWidget(
                                AppLocalizations.of(context)
                                    .mStaticOrganisationName,
                                isMandatory: widget.mandatoryFields
                                    .contains('departmentName')),
                            _inReview.contains('name')
                                ? _reviewStatusIconWidget()
                                : ((_selectedOrganisation != null &&
                                            _selectedOrganisation != '') &&
                                        (_selectedOrganisation ==
                                            widget.profileDetails[0]
                                                    .rawDetails['rootOrg']
                                                ['orgName']))
                                    ? _reviewStatusIconWidget(isApproved: true)
                                    : _reviewStatusIconWidget(isRequired: true),
                          ],
                        ),
                        InkWell(
                          onTap: () => _inReview.contains('name')
                              ? null
                              : _showListOfOptions(
                                  context, EnglishLang.organisationName),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(
                                      const Radius.circular(4.0)),
                                  border: Border.all(color: AppColors.grey40),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16, top: 10, bottom: 10),
                                  child: Text(
                                    _selectedOrganisation != null &&
                                            _selectedOrganisation != ''
                                        ? _selectedOrganisation
                                        : AppLocalizations.of(context)
                                            .mStaticSelectHere,
                                    style: GoogleFonts.lato(
                                      color: AppColors.greys60,
                                      fontSize: 14,
                                      // fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                )),
                          ),
                        ),
                        // _inReviewWidget('name'),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.start,
                        //   children: [
                        //     _fieldNameWidget(EnglishLang.industry),

                        //     // Icon(Icons.check_circle_outline)
                        //   ],
                        // ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _titleFieldWidget(
                                AppLocalizations.of(context).mProfileIndustry,
                                isMandatory: widget.mandatoryFields
                                    .contains('industry')),
                            _inReview.contains('industry')
                                ? _reviewStatusIconWidget()
                                : ((_selectedIndustry != null &&
                                            _selectedIndustry != '') &&
                                        (_selectedIndustry ==
                                            (widget.profileDetails[0].experience
                                                        .length >
                                                    0
                                                ? widget.profileDetails[0]
                                                    .experience[0]['industry']
                                                : null)))
                                    ? _reviewStatusIconWidget(isApproved: true)
                                    : _reviewStatusIconWidget(isRequired: true),
                          ],
                        ),
                        InkWell(
                          onTap: () => _inReview.contains('industry')
                              ? null
                              : _showListOfOptions(
                                  context, EnglishLang.industry),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(
                                      const Radius.circular(4.0)),
                                  border: Border.all(color: AppColors.grey40),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16, top: 10, bottom: 10),
                                  child: Text(
                                    _selectedIndustry != null &&
                                            _selectedIndustry != ''
                                        ? _selectedIndustry
                                        : AppLocalizations.of(context)
                                            .mStaticSelectHere,
                                    style: GoogleFonts.lato(
                                      color: AppColors.greys60,
                                      fontSize: 14,
                                      // fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                )),
                          ),
                        ),
                        // _inReviewWidget('industry'),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.start,
                        //   children: [
                        //     _fieldNameWidget(EnglishLang.designation),

                        //     // Icon(Icons.check_circle_outline)
                        //   ],
                        // ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _titleFieldWidget(
                                AppLocalizations.of(context)
                                    .mProfileDesignation,
                                isMandatory: widget.mandatoryFields
                                    .contains('designation')),
                            _inReview.contains('designation')
                                ? _reviewStatusIconWidget()
                                : ((_selectedDesignation != null &&
                                            _selectedDesignation != '') &&
                                        (_selectedDesignation ==
                                            (widget.profileDetails[0].experience
                                                        .length >
                                                    0
                                                ? widget.profileDetails[0]
                                                        .experience[0]
                                                    ['designation']
                                                : null)))
                                    ? _reviewStatusIconWidget(isApproved: true)
                                    : _reviewStatusIconWidget(isRequired: true),
                          ],
                        ),
                        InkWell(
                          onTap: () => _inReview.contains('designation')
                              ? null
                              : _showListOfOptions(
                                  context, EnglishLang.designation),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(
                                      const Radius.circular(4.0)),
                                  border: Border.all(color: AppColors.grey40),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16, top: 10, bottom: 10),
                                  child: Text(
                                    _selectedDesignation != null &&
                                            _selectedDesignation != ''
                                        ? _selectedDesignation
                                        : AppLocalizations.of(context)
                                            .mStaticSelectHere,
                                    style: GoogleFonts.lato(
                                      color: AppColors.greys60,
                                      fontSize: 14,
                                      // fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                )),
                          ),
                        ),
                        // _inReviewWidget('designation'),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.start,
                        //   children: [
                        //     _fieldNameWidget(EnglishLang.location),
                        //     // Icon(Icons.check_circle_outline)
                        //   ],
                        // ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _titleFieldWidget(
                                AppLocalizations.of(context).mProfileCountry,
                                isMandatory: widget.mandatoryFields
                                    .contains('location')),
                            _inReview.contains('location')
                                ? _reviewStatusIconWidget()
                                : ((_selectedLocation != null &&
                                            _selectedLocation != '') &&
                                        (_selectedLocation ==
                                            (widget.profileDetails[0].experience
                                                        .length >
                                                    0
                                                ? widget.profileDetails[0]
                                                    .experience[0]['location']
                                                : null)))
                                    ? _reviewStatusIconWidget(isApproved: true)
                                    : _reviewStatusIconWidget(isRequired: true),
                          ],
                        ),
                        InkWell(
                          onTap: () => _inReview.contains('location')
                              ? null
                              : _showListOfOptions(
                                  context, EnglishLang.location),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(
                                      const Radius.circular(4.0)),
                                  border: Border.all(color: AppColors.grey40),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16, top: 10, bottom: 10),
                                  child: Text(
                                    _selectedLocation != null &&
                                            _selectedLocation != ''
                                        ? _selectedLocation
                                        : AppLocalizations.of(context)
                                            .mCommonTypeHere,
                                    style: GoogleFonts.lato(
                                      color: AppColors.greys60,
                                      fontSize: 14,
                                      // fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                )),
                          ),
                        ),
                        // _inReviewWidget('location'),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.start,
                        //   children: [
                        //     _fieldNameWidget(EnglishLang.doj),

                        //     // Icon(Icons.check_circle_outline)
                        //   ],
                        // ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _titleFieldWidget(
                                AppLocalizations.of(context)
                                    .mProfileDateOfJoining,
                                isMandatory:
                                    widget.mandatoryFields.contains('doj')),
                            _inReview.contains('doj')
                                ? _reviewStatusIconWidget()
                                : ((_dateOfJoiningController.text != null &&
                                            _dateOfJoiningController.text !=
                                                '') &&
                                        (_dateOfJoiningController.text ==
                                            (widget.profileDetails[0].experience
                                                        .length >
                                                    0
                                                ? widget.profileDetails[0]
                                                    .experience[0]['doj']
                                                : null)))
                                    ? _reviewStatusIconWidget(isApproved: true)
                                    : _reviewStatusIconWidget(isRequired: true),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                          child: Container(
                            height: 40,
                            // padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                            child: TextFormField(
                                enabled:
                                    _inReview.contains('doj') ? false : true,
                                keyboardType: TextInputType.datetime,
                                textInputAction: TextInputAction.next,
                                focusNode: _dateOfJoiningFocus,
                                readOnly: true,
                                onTap: () async {
                                  DateTime newDate = await showDatePicker(
                                      context: context,
                                      initialDate: _selectedDate == null
                                          ? ((_dateOfJoiningController.text !=
                                                      null &&
                                                  _dateOfJoiningController
                                                          .text !=
                                                      '')
                                              ? DateTime.parse(
                                                  _dateOfJoiningController.text
                                                      .toString()
                                                      .split('-')
                                                      .reversed
                                                      .join('-'))
                                              : DateTime.now())
                                          : _selectedDate,
                                      firstDate: DateTime(1900),
                                      lastDate: DateTime(2100));
                                  if (newDate == null) {
                                    return null;
                                  }
                                  setState(() {
                                    _selectedDate = newDate;
                                    _dateOfJoiningController.text = newDate
                                        .toString()
                                        .split(' ')
                                        .first
                                        .split('-')
                                        .reversed
                                        .join('-');
                                  });
                                },
                                onFieldSubmitted: (term) {
                                  _fieldFocusChange(context,
                                      _dateOfJoiningFocus, _descriptionFocus);
                                },
                                controller: _dateOfJoiningController,
                                style: GoogleFonts.lato(fontSize: 14.0),
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.fromLTRB(
                                      20.0, 10.0, 0.0, 10.0),
                                  border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: AppColors.grey16)),
                                  hintText: _dateOfJoiningController.text != ''
                                      ? _dateOfJoiningController.text
                                      : AppLocalizations.of(context)
                                          .mStaticChooseDate,
                                  hintStyle: GoogleFonts.lato(
                                      color: AppColors.grey40,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w400),
                                  focusedBorder: OutlineInputBorder(
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
                        ),
                        // _inReviewWidget('doj'),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.start,
                        //   children: [
                        //     _fieldNameWidget(EnglishLang.description),

                        //     // Icon(Icons.check_circle_outline)
                        //   ],
                        // ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _titleFieldWidget(
                                AppLocalizations.of(context)
                                    .mProfileDescription,
                                isMandatory: widget.mandatoryFields
                                    .contains('description')),
                            _inReview.contains('description')
                                ? _reviewStatusIconWidget()
                                : ((_descriptionController.text != null &&
                                            _descriptionController.text !=
                                                '') &&
                                        (_descriptionController.text ==
                                            (widget.profileDetails[0].experience
                                                        .length >
                                                    0
                                                ? widget.profileDetails[0]
                                                        .experience[0]
                                                    ['description']
                                                : null)))
                                    ? _reviewStatusIconWidget(isApproved: true)
                                    : _reviewStatusIconWidget(isRequired: true),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                          child: TextFormField(
                              readOnly: _inReview.contains('description'),
                              style: GoogleFonts.lato(fontSize: 14.0),
                              textInputAction: TextInputAction.done,
                              textCapitalization: TextCapitalization.sentences,
                              // focusNode: _yearOfPassing10thFocus,
                              // onFieldSubmitted: (term) {
                              //   _fieldFocusChange(
                              //       context,
                              //       _yearOfPassing10thFocus,
                              //       _schoolName12thFocus);
                              // },
                              controller: _descriptionController,
                              minLines: 6,
                              maxLines: 10,
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.fromLTRB(20.0, 10.0, 0.0, 10.0),
                                border: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: AppColors.grey16)),
                                hintText: AppLocalizations.of(context)
                                    .mCommonTypeHere,
                                hintStyle: GoogleFonts.lato(
                                    color: AppColors.grey40,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: AppColors.primaryThree,
                                      width: 1.0),
                                ),
                              )),
                        ),
                        Padding(
                            padding: const EdgeInsets.only(
                                top: 8, right: 16, bottom: 24),
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                _descriptionController.text.length.toString() +
                                    '/500 ' +
                                    AppLocalizations.of(context)
                                        .mProfileCharacters,
                                style: GoogleFonts.lato(
                                  color: AppColors.greys60,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            )),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _inReviewWidget('responsibilities'),
                        )
                      ],
                    ),
                  ),
                  _titleFieldWidget(AppLocalizations.of(context)
                      .mStaticOtherDetailsOfGovtEmployees),
                  // Container(
                  //   margin: const EdgeInsets.only(top: 24, bottom: 5),
                  //   alignment: Alignment.topLeft,
                  //   child: Padding(
                  //     padding: const EdgeInsets.only(left: 16),
                  //     child: Text(
                  //       EnglishLang.otherDetailsOfGovtEmployees,
                  //       style: GoogleFonts.lato(
                  //         color: AppColors.greys87,
                  //         fontWeight: FontWeight.w700,
                  //         fontSize: 16,
                  //         letterSpacing: 0.12,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  Container(
                      width: double.infinity,
                      color: Colors.white,
                      // margin: EdgeInsets.only(top: 5.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              _fieldNameWidget(
                                  AppLocalizations.of(context).mProfilePayBand),

                              // Icon(Icons.check_circle_outline)
                            ],
                          ),
                          InkWell(
                            onTap: () {
                              _showListOfOptions(context, EnglishLang.payBand);
                            },
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                              child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(
                                        const Radius.circular(4.0)),
                                    border: Border.all(color: AppColors.grey40),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16, top: 10, bottom: 10),
                                    child: Text(
                                      _selectedGradePay != null &&
                                              _selectedGradePay != ''
                                          ? _selectedGradePay
                                          : AppLocalizations.of(context)
                                              .mStaticSelectHere,
                                      style: GoogleFonts.lato(
                                        color: AppColors.greys60,
                                        fontSize: 14,
                                        // fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  )),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              _fieldNameWidget(
                                  AppLocalizations.of(context).mProfileService),

                              // Icon(Icons.check_circle_outline)
                            ],
                          ),
                          InkWell(
                            onTap: () => _showListOfOptions(
                                context, EnglishLang.service),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                              child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(
                                        const Radius.circular(4.0)),
                                    border: Border.all(color: AppColors.grey40),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16, top: 10, bottom: 10),
                                    child: Text(
                                      _selectedService != null &&
                                              _selectedService != ''
                                          ? _selectedService
                                          : AppLocalizations.of(context)
                                              .mStaticSelectHere,
                                      style: GoogleFonts.lato(
                                        color: AppColors.greys60,
                                        fontSize: 14,
                                        // fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  )),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              _fieldNameWidget(
                                  AppLocalizations.of(context).mProfileCadre),

                              // Icon(Icons.check_circle_outline)
                            ],
                          ),
                          InkWell(
                            onTap: () =>
                                _showListOfOptions(context, EnglishLang.cadre),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                              child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(
                                        const Radius.circular(4.0)),
                                    border: Border.all(color: AppColors.grey40),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16, top: 10, bottom: 10),
                                    child: Text(
                                      _selectedCadre != null &&
                                              _selectedCadre != ''
                                          ? _selectedCadre
                                          : AppLocalizations.of(context)
                                              .mStaticSelectHere,
                                      style: GoogleFonts.lato(
                                        color: AppColors.greys60,
                                        fontSize: 14,
                                        // fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  )),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              _fieldNameWidget(AppLocalizations.of(context)
                                  .mProfileAllotmentYearOfService),

                              // Icon(Icons.check_circle_outline)
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: Container(
                              height: 40,
                              child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  maxLength: 4,
                                  textInputAction: TextInputAction.next,
                                  focusNode: _allotmentYearOfServiceFocus,
                                  onFieldSubmitted: (term) {
                                    _fieldFocusChange(
                                        context,
                                        _allotmentYearOfServiceFocus,
                                        _dateOfJoiningExpFocus);
                                  },
                                  controller: _allotmentYearOfServiceController,
                                  style: GoogleFonts.lato(fontSize: 14.0),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.fromLTRB(
                                        20.0, 10.0, 0.0, 10.0),
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AppColors.grey16)),
                                    hintText: AppLocalizations.of(context)
                                        .mCommonTypeHere,
                                    hintStyle: GoogleFonts.lato(
                                        color: AppColors.grey40,
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w400),
                                    focusedBorder: OutlineInputBorder(
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
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              _fieldNameWidget(AppLocalizations.of(context)
                                  .mProfileDateOfJoining),

                              // Icon(Icons.check_circle_outline)
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: Container(
                              height: 40,
                              child: TextFormField(
                                  keyboardType: TextInputType.datetime,
                                  textInputAction: TextInputAction.next,
                                  focusNode: _dateOfJoiningExpFocus,
                                  readOnly: true,
                                  onTap: () async {
                                    DateTime newDate = await showDatePicker(
                                        context: context,
                                        initialDate: _selectedDate == null
                                            ? ((_dateOfJoiningExpController
                                                            .text !=
                                                        null &&
                                                    _dateOfJoiningExpController
                                                            .text !=
                                                        '')
                                                ? DateTime.parse(
                                                    _dateOfJoiningExpController
                                                        .text
                                                        .toString()
                                                        .split('-')
                                                        .reversed
                                                        .join('-'))
                                                : DateTime.now())
                                            : _selectedDate,
                                        firstDate: DateTime(1900),
                                        lastDate: DateTime(2100));
                                    if (newDate == null) {
                                      return null;
                                    }
                                    setState(() {
                                      _selectedDate = newDate;
                                      _dateOfJoiningExpController.text = newDate
                                          .toString()
                                          .split(' ')
                                          .first
                                          .split('-')
                                          .reversed
                                          .join('-');
                                    });
                                  },
                                  onFieldSubmitted: (term) {
                                    _fieldFocusChange(
                                        context,
                                        _dateOfJoiningExpFocus,
                                        _civilListNumberFocus);
                                  },
                                  controller: _dateOfJoiningExpController,
                                  style: GoogleFonts.lato(fontSize: 14.0),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.fromLTRB(
                                        20.0, 10.0, 0.0, 10.0),
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AppColors.grey16)),
                                    hintText:
                                        _dateOfJoiningExpController.text != ''
                                            ? _dateOfJoiningExpController.text
                                            : AppLocalizations.of(context)
                                                .mStaticChooseDate,
                                    hintStyle: GoogleFonts.lato(
                                        color: AppColors.grey40,
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w400),
                                    focusedBorder: OutlineInputBorder(
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
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _fieldNameWidget(AppLocalizations.of(context)
                                  .mProfileCivilListNumber),

                              // Icon(Icons.check_circle_outline)
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: Container(
                              height: 40,
                              child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.next,
                                  focusNode: _civilListNumberFocus,
                                  onFieldSubmitted: (term) {
                                    _fieldFocusChange(
                                        context,
                                        _civilListNumberFocus,
                                        _employeeCodeFocus);
                                  },
                                  controller: _civilListNumberController,
                                  style: GoogleFonts.lato(fontSize: 14.0),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.fromLTRB(
                                        20.0, 10.0, 0.0, 10.0),
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AppColors.grey16)),
                                    hintText: AppLocalizations.of(context)
                                        .mCommonTypeHere,
                                    hintStyle: GoogleFonts.lato(
                                        color: AppColors.grey40,
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w400),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: AppColors.primaryThree,
                                          width: 1.0),
                                    ),
                                  )),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              _fieldNameWidget(AppLocalizations.of(context)
                                  .mProfileEmployeeCode),

                              // Icon(Icons.check_circle_outline)
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: Container(
                              height: 40,
                              child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.next,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  focusNode: _employeeCodeFocus,
                                  onFieldSubmitted: (term) {
                                    _fieldFocusChange(
                                        context,
                                        _employeeCodeFocus,
                                        _officialPostalAddressFocus);
                                  },
                                  controller: _employeeCodeController,
                                  style: GoogleFonts.lato(fontSize: 14.0),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.fromLTRB(
                                        20.0, 10.0, 0.0, 10.0),
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AppColors.grey16)),
                                    hintText: AppLocalizations.of(context)
                                        .mCommonTypeHere,
                                    hintStyle: GoogleFonts.lato(
                                        color: AppColors.grey40,
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w400),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: AppColors.primaryThree,
                                          width: 1.0),
                                    ),
                                  )),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              _fieldNameWidget(AppLocalizations.of(context)
                                  .mStaticOfficialPostalAddress),

                              // Icon(Icons.check_circle_outline)
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                            child: TextFormField(
                                textInputAction: TextInputAction.next,
                                focusNode: _officialPostalAddressFocus,
                                onFieldSubmitted: (term) {
                                  _fieldFocusChange(
                                      context,
                                      _officialPostalAddressFocus,
                                      _pinCodeFocus);
                                },
                                controller: _officialPostalAddressController,
                                style: GoogleFonts.lato(fontSize: 14.0),
                                minLines: 6,
                                maxLines: 10,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.fromLTRB(
                                      20.0, 10.0, 0.0, 10.0),
                                  border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: AppColors.grey16)),
                                  hintText: AppLocalizations.of(context)
                                      .mCommonTypeHere,
                                  hintStyle: GoogleFonts.lato(
                                      color: AppColors.grey40,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w400),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: AppColors.primaryThree,
                                        width: 1.0),
                                  ),
                                )),
                          ),
                          Padding(
                              padding: const EdgeInsets.only(
                                  top: 8, right: 16, bottom: 0),
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                  _officialPostalAddressController.text.length
                                          .toString() +
                                      '/500 ' +
                                      AppLocalizations.of(context)
                                          .mProfileCharacters,
                                  style: GoogleFonts.lato(
                                    color: AppColors.greys60,
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              )),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              _fieldNameWidget(
                                  AppLocalizations.of(context).mProfilePinCode),

                              // Icon(Icons.check_circle_outline)
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: Container(
                              height: 40,
                              child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  maxLength: 6,
                                  textInputAction: TextInputAction.next,
                                  focusNode: _pinCodeFocus,
                                  controller: _pinCodeController,
                                  style: GoogleFonts.lato(fontSize: 14.0),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.fromLTRB(
                                        20.0, 10.0, 0.0, 10.0),
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AppColors.grey16)),
                                    hintText: AppLocalizations.of(context)
                                        .mCommonTypeHere,
                                    hintStyle: GoogleFonts.lato(
                                        color: AppColors.grey40,
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w400),
                                    focusedBorder: OutlineInputBorder(
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
                          ),
                          _fieldNameWidget(
                              AppLocalizations.of(context).mStaticTagsText),
                          _tagsList.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: Text(
                                    AppLocalizations.of(context).mProfileNoTags,
                                    style: TextStyle(color: AppColors.grey40),
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.only(left: 12.0),
                                  child: Row(
                                    children: _tagsList
                                        .map((tag) => Container(
                                            padding: EdgeInsets.all(10),
                                            margin: EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                                color: AppColors.grey04,
                                                border: Border.all(
                                                    color: AppColors.grey40),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(12))),
                                            child: Text(tag)))
                                        .toList(),
                                  ),
                                ),
                          SizedBox(height: 30),
                        ],
                      )),
                  Container(
                    height: 100,
                  )
                ]));
              }
              // else {
              //   return PageLoader(
              //     bottom: 200,
              //   );
              // }
            }));
  }
}
