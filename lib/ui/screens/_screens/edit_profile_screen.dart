import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/storage_constants.dart';
import 'package:karmayogi_mobile/respositories/_respositories/profile_repository.dart';
import 'package:karmayogi_mobile/services/_services/profile_service.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/profile/edit_mandatory_details.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/profile/edit_other_details.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/profile/ehrms_details.dart';
import 'package:karmayogi_mobile/ui/skeleton/pages/edit_profile_skeleton_page.dart';
import 'package:karmayogi_mobile/util/telemetry.dart';
import 'package:karmayogi_mobile/util/telemetry_db_helper.dart';
import 'package:provider/provider.dart';
import '../../../constants/_constants/telemetry_constants.dart';
import './../../../constants/index.dart';
import './../../widgets/index.dart';
import './../../../models/index.dart';
import './../../../localization/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  _EditProfileScreenNewState createState() => _EditProfileScreenNewState();
}

class _EditProfileScreenNewState extends State<EditProfileScreen>
    with SingleTickerProviderStateMixin {
  TabController _controller;
  int _activeTabIndex = 0;
  bool popularPosts = false;
  List<Profile> _profileDetails;
  final service = HttpClient();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final ProfileService profileService = ProfileService();

  Future<List<Profile>> getProfileFuture;

  String userId;
  String userSessionId;
  String messageIdentifier;
  String departmentId;
  String deviceIdentifier;
  var telemetryEventData;

  @override
  void initState() {
    super.initState();

    //  _getMandatoryFields();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final profileDetails =
          Provider.of<ProfileRepository>(context, listen: false).profileDetails;
      _controller = TabController(
          length: (profileDetails.ehrmsId != null
                  ? EditProfileTab.getItems(context)
                  : EditProfileTab.getItemsWithoutEhrms(context))
              .length,
          vsync: this,
          initialIndex: widget.tabIndex);
      _controller.addListener(_setActiveTabIndex);
    });

    _generateTelemetryData();
    // _getMandatoryFields();
    getProfileFuture = _getProfileDetails();
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
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData1);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());
  }

  _fetchData() async {
    await Provider.of<ProfileRepository>(context, listen: false)
        .getInReviewFields();
    Provider.of<ProfileRepository>(context, listen: false).getLanguages();
  }

  Future<List<Profile>> _getProfileDetails() async {
    // Getting in review fields
    await _fetchData();
    // Getting profile data
    _profileDetails =
        await Provider.of<ProfileRepository>(context, listen: false)
            .getProfileDetailsById('');
    final _storage = FlutterSecureStorage();
    await _storage.write(
        key: Storage.profileCompletionPercentage,
        value: _profileDetails.first.profileCompletionPercentage.toString());
    return _profileDetails;
  }

  void _setActiveTabIndex() {
    // print(_activeTabIndex);
    Future.delayed(const Duration(milliseconds: 100), () {
      _activeTabIndex = _controller.index;
      setState(() {});
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
      _generateInteractTelemetryData(TelemetrySubType.mandatoryDetailsTab);
    } else if (index == 1) {
      _generateInteractTelemetryData(TelemetrySubType.otherDetailsTab);
    } else {
      _generateInteractTelemetryData(TelemetrySubType.eHRMSDetailsTab);
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
      key: _scaffoldKey,
      body: FutureBuilder(
          future: getProfileFuture,
          builder:
              (BuildContext context, AsyncSnapshot<List<Profile>> snapshot) {
            if (snapshot.hasData) {
              return Consumer<ProfileRepository>(builder: (BuildContext context,
                  ProfileRepository profileRepository, Widget child) {
                return DefaultTabController(
                  length: (profileRepository.profileDetails.ehrmsId != null
                          ? EditProfileTab.getItems(context)
                          : EditProfileTab.getItemsWithoutEhrms(context))
                      .length,
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
                                  "${AppLocalizations.of(context).mStaticEdit} ${AppLocalizations.of(context).mStaticProfile}",
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
                                  for (var tabItem in profileRepository
                                              .profileDetails.ehrmsId !=
                                          null
                                      ? EditProfileTab.getItems(context)
                                      : EditProfileTab.getItemsWithoutEhrms(
                                          context))
                                    Container(
                                      padding: const EdgeInsets.only(
                                          left: 16, right: 16),
                                      child: Tab(
                                        child: Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Text(
                                            tabItem.title,
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
                      body: profileRepository.profileDetails.ehrmsId != null
                          ? TabBarView(
                              controller: _controller,
                              children: [
                                EditMandatoryDetails(
                                  fetchProfileDetailsAction: _getProfileDetails,
                                  mandatoryFields: [],
                                  isToUpdateMobileNumber:
                                      widget.isToUpdateMobileNumber,
                                ),
                                EditOtherDetailsPage(),
                                EHrmsDetails()
                              ],
                            )
                          : TabBarView(
                              controller: _controller,
                              children: [
                                EditMandatoryDetails(
                                  fetchProfileDetailsAction: _getProfileDetails,
                                  mandatoryFields: [],
                                  isToUpdateMobileNumber:
                                      widget.isToUpdateMobileNumber,
                                ),
                                EditOtherDetailsPage(),
                              ],
                            ),
                    ),
                  ),
                );
              });
            } else {
              // return PageLoader();
              return EditProfileSkeletonPage();
            }
          }),
      bottomSheet: _activeTabIndex != 2
          ? Container(
              height: 60,
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
                              EditMandatoryDetails
                                  .mandatoryDetailsGlobalKey.currentState
                                  .saveProfile();
                              break;
                            case 1:
                              EditOtherDetailsPage
                                  .otherDetailsGlobalKey.currentState
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
                          AppLocalizations.of(context).mEditProfileSave,
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
                              EditMandatoryDetails
                                  .mandatoryDetailsGlobalKey.currentState
                                  .saveProfile();
                              Navigator.pop(context);
                              break;
                            case 1:
                              EditOtherDetailsPage
                                  .otherDetailsGlobalKey.currentState
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
                          AppLocalizations.of(context)
                              .mEditProfileSubmitChanges,
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
            )
          : SizedBox(),
    );
  }
}
