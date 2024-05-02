import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/storage_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/models/_models/profile_model.dart';
import 'package:karmayogi_mobile/models/_models/telemetry_event_model.dart';
import 'package:karmayogi_mobile/respositories/_respositories/login_respository.dart';
import 'package:karmayogi_mobile/services/_services/logout_service.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile_screen.dart';
import 'package:karmayogi_mobile/ui/widgets/_profile/profile_picture.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:karmayogi_mobile/util/telemetry.dart';
import 'package:karmayogi_mobile/util/telemetry_db_helper.dart';
import 'package:karmayogi_mobile/util/load_webview_page.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../respositories/_respositories/landing_page_repository.dart';

class CustomDrawer extends StatefulWidget {
  final String title;
  final Profile profileDetails;
  final String userName;

  CustomDrawer({Key key, this.title, this.profileDetails, this.userName})
      : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String userId;
  String userSessionId;
  String messageIdentifier;
  String departmentId;
  String deviceIdentifier;
  var telemetryEventData;

  @override
  void initState() {
    super.initState();
    _generateImpressionTelemetryData();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          SizedBox(
            height: 40,
          ),
          InkWell(
            onTap: () {
              _generateInteractTelemetryData(TelemetryConstants.viewProfile);
              Navigator.of(context).pop();
              Navigator.push(
                context,
                FadeRoute(
                  page: ProfileScreen(),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  ProfilePicture(
                    widget.profileDetails,
                    isFromDrawer: true,
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widget.profileDetails != null
                          ? Container(
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: Text(
                                  Helper.capitalize(
                                      (widget.profileDetails.firstName != null
                                              ? widget.profileDetails.firstName
                                              : '') +
                                          ' ' +
                                          (widget.profileDetails.surname != null
                                              ? widget.profileDetails.surname
                                              : '')),
                                  style: GoogleFonts.lato(
                                      color: AppColors.greys87,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16.0)),
                            )
                          : SizedBox(),
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                          AppLocalizations.of(context).mCustomDrawerViewprofile,
                          style: GoogleFonts.lato(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w700,
                              fontSize: 10.0))
                    ],
                  )
                ],
              ),
            ),
          ),
          Divider(
            height: 0,
            color: AppColors.grey16,
          ),
          InkWell(
            onTap: () async {
              _generateInteractTelemetryData(
                  TelemetryConstants.shareApplication);
              await Share.share(
                  Platform.isAndroid ? ApiUrl.androidUrl : ApiUrl.iOSUrl);
            },
            child: _getMenu(
                text: AppLocalizations.of(context).mSettingShareApplication,
                icon: Icons.share),
          ),
          Divider(
            height: 0,
            color: AppColors.grey16,
            indent: 28,
          ),
          InkWell(
            onTap: () async {
              _generateInteractTelemetryData(
                TelemetryIdentifier.getStarted,
              );
              Navigator.of(context).pop();
              Provider.of<LandingPageRepository>(context, listen: false)
                  .updateShowGetStarted(true);
            },
            child: _getMenu(
                text: AppLocalizations.of(context).mStaticKarmayogiTour,
                icon: Icons.play_circle),
          ),
          Divider(
            height: 0,
            color: AppColors.grey16,
            indent: 28,
          ),
          InkWell(
            onTap: () {
              _generateInteractTelemetryData(TelemetryConstants.rateNow);
              final InAppReview inAppReview = InAppReview.instance;
              inAppReview.openStoreListing(appStoreId: APP_STORE_ID);
              Navigator.of(context).pop();
            },
            child: _getMenu(
                text: AppLocalizations.of(context).mCustomDrawerRateUs,
                icon: Icons.star),
          ),

//Privacy Policy
          Divider(
            height: 0,
            color: AppColors.grey16,
            indent: 28,
          ),
          InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => LoadWebViewPage(
                  title: AppLocalizations.of(context)
                                            .mStaticPrivacyPolicy,
                  url: ApiUrl.baseUrl + ApiUrl.privacyPolicy,
                ),
              ),
            ),
            child: _getMenu(
                text: AppLocalizations.of(context)
                                            .mStaticPrivacyPolicy, icon: Icons.privacy_tip_outlined),
          ),

          Divider(
            height: 0,
            color: AppColors.grey16,
            indent: 28,
          ),
          InkWell(
            onTap: () {
              _generateInteractTelemetryData(TelemetryConstants.signout);
              _onSignOutPressed(context);
            },
            child: _getMenu(
                text: AppLocalizations.of(context).mSettingSignOut,
                svgPath: 'assets/img/logout.svg'),
          ),
          Divider(
            height: 0,
            color: AppColors.grey16,
            indent: 28,
          ),
        ],
      ),
    );
  }

  void _generateImpressionTelemetryData() async {
    deviceIdentifier = await Telemetry.getDeviceIdentifier();
    userId = await Telemetry.getUserId();
    userSessionId = await Telemetry.generateUserSessionId();
    messageIdentifier = await Telemetry.generateUserSessionId();
    departmentId = await Telemetry.getUserDeptId();
    Map eventData = Telemetry.getImpressionTelemetryEvent(
        deviceIdentifier,
        userId,
        departmentId,
        TelemetryPageIdentifier.homePageId,
        userSessionId,
        messageIdentifier,
        TelemetryType.viewer,
        TelemetryPageIdentifier.homePageUri,
        env: TelemetryEnv.home);
    // print(jsonEncode(eventData));
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());
  }

  void _generateInteractTelemetryData(String contentId) async {
    Map eventData = Telemetry.getInteractTelemetryEvent(
        deviceIdentifier,
        userId,
        departmentId,
        TelemetryPageIdentifier.homePageId,
        userSessionId,
        messageIdentifier,
        contentId,
        TelemetrySubType.profile.toLowerCase(),
        env: TelemetryEnv.home);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());
  }

  Future<void> doLogout(context) async {
    final _storage = FlutterSecureStorage();
    String parichayToken = await _storage.read(key: Storage.parichayAuthToken);

    String userId = await Telemetry.getUserId();
    await TelemetryDbHelper.triggerEvents(userId, forceTrigger: true);

    try {
      final keyCloakLogoutResponse = await LogoutService.doKeyCloakLogout();
      if (keyCloakLogoutResponse == 204) {
        if (parichayToken != null) {
          final parichayLogoutResponse = await LogoutService.doParichayLogout();
          if (parichayLogoutResponse == 200) {
            Navigator.pushNamedAndRemoveUntil(
                context, AppUrl.onboardingScreen, (r) => false);
          }
        } else {
          Navigator.pushNamedAndRemoveUntil(
              context, AppUrl.onboardingScreen, (r) => false);
        }
      }
    } catch (e) {
      throw e;
    } finally {
      await Provider.of<LoginRespository>(context, listen: false).clearData();
    }
  }

  Widget roundedButton(String buttonLabel, Color bgColor, Color textColor) {
    var loginBtn = Container(
      width: MediaQuery.of(context).size.width - 40,
      padding: EdgeInsets.all(10),
      alignment: FractionalOffset.center,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.all(const Radius.circular(4.0)),
        border: bgColor == Colors.white
            ? Border.all(color: AppColors.grey40)
            : Border.all(color: bgColor),
      ),
      child: Text(
        buttonLabel,
        style: GoogleFonts.montserrat(
            decoration: TextDecoration.none,
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w700),
      ),
    );
    return loginBtn;
  }

  Future<bool> _onSignOutPressed(contextMain) {
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
        builder: (context) => SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 20),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        margin: EdgeInsets.only(bottom: 20),
                        height: 6,
                        width: MediaQuery.of(context).size.width * 0.25,
                        decoration: BoxDecoration(
                          color: AppColors.grey16,
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(top: 5, bottom: 15),
                        child: Text(
                          'Do you want to logout?',
                          style: GoogleFonts.montserrat(
                              decoration: TextDecoration.none,
                              color: Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        )),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop(true);
                        doLogout(contextMain);
                      },
                      child: roundedButton(
                          'Yes, logout', Colors.white, AppColors.primaryThree),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(true),
                        child: roundedButton('No, take me back',
                            AppColors.primaryThree, Colors.white),
                      ),
                    )
                  ],
                ),
              ),
            ));
  }

  _getMenu({String text, IconData icon, String svgPath}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 1.0, 22.0, 1.0),
      child: ListTile(
        leading: SizedBox(
          height: 25,
          width: 45,
          child: svgPath != null
              ? SvgPicture.asset(
                  svgPath,
                  width: 25.0,
                  height: 25.0,
                  color: AppColors.primaryBlue,
                )
              : Icon(
                  icon,
                  color: AppColors.primaryBlue,
                ),
        ),
        title: Text(
          text,
          style: GoogleFonts.lato(
              color: Colors.black87,
              fontWeight: FontWeight.w700,
              fontSize: 16.0),
        ),
      ),
    );
  }
}
