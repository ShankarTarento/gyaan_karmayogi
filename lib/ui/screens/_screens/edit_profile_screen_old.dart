import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/storage_constants.dart';
import 'package:karmayogi_mobile/respositories/_respositories/profile_repository.dart';
import 'package:karmayogi_mobile/services/_services/profile_service.dart';
import 'package:karmayogi_mobile/util/telemetry.dart';
import 'package:karmayogi_mobile/util/telemetry_db_helper.dart';
import 'package:provider/provider.dart';
import '../../../constants/_constants/telemetry_constants.dart';
import './../../../ui/pages/index.dart';
import './../../../constants/index.dart';
import './../../widgets/index.dart';
import './../../../models/index.dart';
import './../../../localization/index.dart';

class EditProfileScreen extends StatefulWidget {
  static const route = AppUrl.editProfilePage;
  final bool isToUpdateMobileNumber;
  final focus;
  final bool isToUpdateProfile;
  final int tabIndex;
  final profileParentAction;

  EditProfileScreen(
      {this.isToUpdateMobileNumber = false,
      this.focus,
      this.isToUpdateProfile = false,
      this.tabIndex = 0,
      this.profileParentAction});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with SingleTickerProviderStateMixin {
  TabController _controller;
  int _activeTabIndex = 0;
  bool popularPosts = false;
  List<Profile> _profileDetails;
  final service = HttpClient();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final ProfileService profileService = ProfileService();

  var _mandatoryFields = [];
  var _personalToFill = [];
  var _professionalToFill = [];
  var _academicToFill = [];

  String userId;
  String userSessionId;
  String messageIdentifier;
  String departmentId;
  String deviceIdentifier;
  var telemetryEventData;

  @override
  void initState() {
    super.initState();
    _controller = TabController(
        length: EditProfileTab.getItems(context).length,
        vsync: this,
        initialIndex: widget.tabIndex);
    _controller.addListener(_setActiveTabIndex);
    _generateTelemetryData();
    _getMandatoryFields();
  }

  void _generateTelemetryData() async {
    deviceIdentifier = await Telemetry.getDeviceIdentifier();
    userId = await Telemetry.getUserId();
    userSessionId = await Telemetry.generateUserSessionId();
    messageIdentifier = await Telemetry.generateUserSessionId();
    departmentId = await Telemetry.getUserDeptId();
    Map eventData1 = Telemetry.getImpressionTelemetryEvent(
        deviceIdentifier,
        userId,
        departmentId,
        TelemetryPageIdentifier.userProfileDetailsPageId,
        userSessionId,
        messageIdentifier,
        TelemetryType.page,
        TelemetryPageIdentifier.userProfileDetailsPageUri,
        env: TelemetryEnv.profile);
    // print('event data: ' + eventData1.toString());
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData1);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());
  }

  Future<List<Profile>> _getProfileDetails() async {
    _profileDetails =
        await Provider.of<ProfileRepository>(context, listen: false)
            .getProfileDetailsById('');
    final _storage = FlutterSecureStorage();
    await _storage.write(
        key: Storage.profileCompletionPercentage,
        value: _profileDetails.first.profileCompletionPercentage.toString());
    // print(_profileDetails.toString());
    return _profileDetails;
  }

  _updateMobileVerifiedStatus() async {
    await _getProfileDetails();
    widget.profileParentAction();
    setState(() {});
  }

  _getMandatoryFields() async {
    _mandatoryFields = await profileService.getProfileMandatoryFields();
    for (var i = 0; i < _mandatoryFields.length; i++) {
      if (_mandatoryFields[i].contains('profileDetails.personalDetails')) {
        _personalToFill.add(_mandatoryFields[i].toString().split('.').last);
      } else if (_mandatoryFields[i]
          .contains('profileDetails.professionalDetails')) {
        _professionalToFill.add(_mandatoryFields[i].toString().split('.').last);
      } else if (_mandatoryFields[i].contains('profileDetails.academics')) {
        _academicToFill.add(_mandatoryFields[i].toString().split('.').last);
      }
    }
  }

  void _setActiveTabIndex() {
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _activeTabIndex = _controller.index;
      });
      // print(_activeTabIndex);
    });
  }

  void _generateInteractTelemetryData(String contentId) async {
    Map eventData = Telemetry.getInteractTelemetryEvent(
        deviceIdentifier,
        userId,
        departmentId,
        TelemetryPageIdentifier.userProfileDetailsPageId + '_' + contentId,
        userSessionId,
        messageIdentifier,
        contentId,
        TelemetrySubType.profileEditTab,
        env: TelemetryEnv.profile,
        objectType: TelemetrySubType.profileEditTab);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());
  }

  void _triggerInteractTelemetryData(int index) {
    if (index == 0) {
      _generateInteractTelemetryData(TelemetrySubType.personalDetailsTab);
    } else if (index == 1) {
      _generateInteractTelemetryData(TelemetrySubType.academicsTab);
    } else if (index == 2) {
      _generateInteractTelemetryData(TelemetrySubType.professionalDetailsTab);
    } else {
      _generateInteractTelemetryData(TelemetrySubType.certificationSkillsTab);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   leading: BackButton(color: AppColors.greys60),
        // ),
        key: _scaffoldKey,
        bottomSheet: Container(
          height: 60,
          // padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
          decoration: BoxDecoration(color: Colors.white, boxShadow: [
            BoxShadow(
              color: AppColors.grey08,
              blurRadius: 9.0,
              spreadRadius: 0,
              offset: Offset(
                0,
                -2,
              ),
            ),
          ]),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 8, left: 16),
                child: Container(
                  height: 48,
                  width: MediaQuery.of(context).size.width / 2 - 20,
                  child: TextButton(
                    onPressed: () {
                      switch (_activeTabIndex) {
                        case 0:
                          EditPersonalDetailsPage
                              .personalDetailsGlobalKey.currentState
                              .saveProfile();
                          break;
                        case 1:
                          EditAcademicDetailsPage
                              .academicDetailsGlobalKey.currentState
                              .saveProfile();
                          break;
                        case 2:
                          EditProfessionalDetailsPage
                              .professionalDetailsGlobalKey.currentState
                              .saveProfile();
                          break;
                        case 3:
                          EditCertificationAndSkillsPage
                              .certificationSkillsDetailsGlobalKey.currentState
                              .saveProfile();
                          break;
                      }
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                          side: BorderSide(
                              color: AppColors.customBlue, width: 1.5)),
                    ),
                    child: Text(
                      EnglishLang.save,
                      style: GoogleFonts.lato(
                        color: AppColors.customBlue,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Container(
                  height: 48,
                  width: MediaQuery.of(context).size.width / 2 - 20,
                  child: TextButton(
                    onPressed: () {
                      switch (_activeTabIndex) {
                        case 0:
                          EditPersonalDetailsPage
                              .personalDetailsGlobalKey.currentState
                              .saveProfile();
                          if (EditPersonalDetailsPage
                              .personalDetailsGlobalKey.currentState
                              .checkMandatoryFieldsStatus()) {
                            Navigator.pop(context);
                          }
                          break;
                        case 1:
                          EditAcademicDetailsPage
                              .academicDetailsGlobalKey.currentState
                              .saveProfile();
                          Navigator.pop(context);
                          break;
                        case 2:
                          EditProfessionalDetailsPage
                              .professionalDetailsGlobalKey.currentState
                              .saveProfile();
                          Navigator.pop(context);
                          break;
                        case 3:
                          EditCertificationAndSkillsPage
                              .certificationSkillsDetailsGlobalKey.currentState
                              .saveProfile();
                          Navigator.pop(context);
                          break;
                      }
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.customBlue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                          side: BorderSide(
                              color: AppColors.customBlue, width: 1.5)),
                    ),
                    child: Text(
                      EnglishLang.submitChanges,
                      style: GoogleFonts.lato(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: FutureBuilder(
            future: _getProfileDetails(),
            builder:
                (BuildContext context, AsyncSnapshot<List<Profile>> snapshot) {
              if (snapshot.hasData) {
                return DefaultTabController(
                  length: EditProfileTab.getItems(context).length,
                  child: SafeArea(
                    child: NestedScrollView(
                      headerSliverBuilder:
                          (BuildContext context, bool innerBoxIsScrolled) {
                        return <Widget>[
                          SliverAppBar(
                            pinned: false,
                            leading: BackButton(color: AppColors.greys60),
                            flexibleSpace: FlexibleSpaceBar(
                              centerTitle: false,
                              titlePadding:
                                  EdgeInsets.fromLTRB(40.0, 0.0, 10.0, 18.0),
                              title: Padding(
                                padding: EdgeInsets.only(left: 13.0, top: 3.0),
                                child: Text(
                                  'Edit profile',
                                  style: GoogleFonts.montserrat(
                                    color: AppColors.greys87,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SliverPersistentHeader(
                            delegate: SilverAppBarDelegate(
                              TabBar(
                                isScrollable: true,
                                indicator: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: AppColors.darkBlue,
                                      width: 2.0,
                                    ),
                                  ),
                                ),
                                indicatorColor: Colors.white,
                                labelPadding: EdgeInsets.only(top: 0.0),
                                unselectedLabelColor: AppColors.greys60,
                                labelColor: AppColors.darkBlue,
                                labelStyle: GoogleFonts.lato(
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.w600,
                                ),
                                unselectedLabelStyle: GoogleFonts.lato(
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.normal,
                                ),
                                tabs: [
                                  for (var tabItem
                                      in EditProfileTab.getItems(context))
                                    Container(
                                      // width: 125.0,
                                      padding: const EdgeInsets.only(
                                          left: 16, right: 16),
                                      child: Tab(
                                        child: Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Text(
                                            tabItem.title.toUpperCase(),
                                            style: GoogleFonts.lato(
                                              color: AppColors.greys87,
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                ],
                                controller: _controller,
                                onTap: (value) => _triggerInteractTelemetryData(
                                    _controller.index),
                              ),
                            ),
                            pinned: true,
                            floating: false,
                          ),
                        ];
                      },

                      // TabBar view
                      body: Container(
                        // color: AppColors.lightBackground,
                        child: FutureBuilder(
                            future: Future.delayed(Duration(milliseconds: 500)),
                            builder:
                                (BuildContext context, AsyncSnapshot snapshot) {
                              return TabBarView(
                                controller: _controller,
                                children: [
                                  EditPersonalDetailsPage(
                                    profileDetails: _profileDetails,
                                    scaffoldKey: _scaffoldKey,
                                    parentAction: _updateMobileVerifiedStatus,
                                    isToUpdateMobileNumber:
                                        widget.isToUpdateMobileNumber,
                                    focus: widget.focus,
                                    mandatoryFields: _personalToFill,
                                    isToUpdateProfile: widget.isToUpdateProfile,
                                  ),
                                  EditAcademicDetailsPage(
                                    profileDetails: _profileDetails,
                                    scaffoldKey: _scaffoldKey,
                                    mandatoryFields: _academicToFill,
                                  ),
                                  EditProfessionalDetailsPage(
                                      profileDetails: _profileDetails,
                                      scaffoldKey: _scaffoldKey,
                                      mandatoryFields: _professionalToFill),
                                  // EditCertificationAndSkillsPage(
                                  //   profileDetails: _profileDetails,
                                  //   scaffoldKey: _scaffoldKey,
                                  // )
                                ],
                              );
                            }),
                      ),
                    ),
                  ),
                );
              } else {
                return PageLoader();
              }
            }));
  }
}
