import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/models/_models/telemetry_event_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_common/rounded_button.dart';
import 'package:karmayogi_mobile/ui/widgets/_signup/contact_us.dart';
import 'package:karmayogi_mobile/util/logout.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:karmayogi_mobile/util/telemetry.dart';
import 'package:karmayogi_mobile/util/telemetry_db_helper.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../constants/_constants/storage_constants.dart';
import '../../../respositories/_respositories/landing_page_repository.dart';
import './../../../util/faderoute.dart';
import './../../../ui/screens/index.dart';
import './../../../constants/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  static const route = AppUrl.settingsPage;

  @override
  _SettingsScreenState createState() {
    return new _SettingsScreenState();
  }
}

String get getEnvironmentInfo => APP_ENVIRONMENT == Environment.prod
    ? ''
    : APP_ENVIRONMENT.split('.').last.toUpperCase();

String get getYear => Helper.getDateTimeInFormat(DateTime.now().toString(),
    desiredDateFormat: IntentType.dateFormatYearOnly);

String get getNextYear => (int.parse(getYear) + 1).toString();

class _SettingsScreenState extends State<SettingsScreen> {
  String userId;
  String userSessionId;
  String messageIdentifier;
  String departmentId;
  String pageIdentifier;
  String telemetryType;
  String pageUri;
  List allEventsData = [];
  String deviceIdentifier;
  var telemetryEventData;

  void _generateInteractTelemetryData(String contentId, String subtype) async {
    deviceIdentifier = await Telemetry.getDeviceIdentifier();
    userId = await Telemetry.getUserId();
    userSessionId = await Telemetry.generateUserSessionId();
    messageIdentifier = await Telemetry.generateUserSessionId();
    departmentId = await Telemetry.getUserDeptId();
    Map eventData = Telemetry.getInteractTelemetryEvent(
        deviceIdentifier,
        userId,
        departmentId,
        TelemetryPageIdentifier.homePageId,
        userSessionId,
        messageIdentifier,
        contentId,
        subtype,
        env: TelemetryEnv.home,
        objectType: subtype);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());
  }

  ValueNotifier<bool> _displayFcmToken = ValueNotifier(false);
  String _fcmToken;
  final _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _getFcmToken();
  }

  _getFcmToken() async {
    _fcmToken = await _storage.read(key: Storage.fcmToken);
  }

  Future<bool> _onBackPressed(contextMain) {
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
        builder: (context) => Logout(
              contextMain: contextMain,
            ));
  }

  Future<bool> _onLangClick() {
    return showDialog(
        context: context,
        builder: (context) => Stack(
              children: [
                Positioned(
                    child: Align(
                        // alignment: FractionalOffset.center,
                        alignment: FractionalOffset.bottomCenter,
                        child: Container(
                          padding: EdgeInsets.all(20),
                          // margin: EdgeInsets.only(left: 20, right: 20),
                          width: double.infinity,
                          height: 170.0,
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                  padding:
                                      const EdgeInsets.only(top: 5, bottom: 5),
                                  child: Text(
                                    'Oho!',
                                    style: GoogleFonts.montserrat(
                                        decoration: TextDecoration.none,
                                        color: Colors.black87,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700),
                                  )),
                              Padding(
                                  padding:
                                      const EdgeInsets.only(top: 5, bottom: 15),
                                  child: Text(
                                    'Current version only supports English, other Indian languages will be available soon.',
                                    style: GoogleFonts.montserrat(
                                        decoration: TextDecoration.none,
                                        color: Colors.black87,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400),
                                  )),
                              Row(children: [
                                // GestureDetector(
                                //   onTap: () => Navigator.of(context).pop(true),
                                //   child: roundedButton('Yes, exit',
                                //       Colors.white, AppColors.primaryThree),
                                // ),
                                Spacer(),
                                GestureDetector(
                                  onTap: () => Navigator.of(context).pop(false),
                                  child: RoundedButton(
                                    buttonLabel: 'Okay',
                                    bgColor: AppColors.primaryThree,
                                    textColor: Colors.white,
                                  ),
                                ),
                              ])
                            ],
                          ),
                        )))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(241, 244, 244, 1),
      appBar: AppBar(
        titleSpacing: 0,
        leading: BackButton(color: AppColors.greys60),
        // leading: IconButton(
        //   icon: Icon(Icons.settings, color: AppColors.greys60),
        //   onPressed: () => Navigator.of(context).pop(),
        // ),
        title: Row(children: [
          Icon(Icons.settings, color: AppColors.greys60),
          Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                AppLocalizations.of(context).mStaticSettings,
                style: GoogleFonts.montserrat(
                  color: AppColors.greys87,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ))
        ]),
        // centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          // color: Color.fromRGBO(241, 244, 244, 1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: SvgPicture.asset(
                  'assets/img/settings_w.svg',
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.fitWidth,
                ),
              ),
              Container(
                padding: const EdgeInsets.only(left: 16, top: 32, bottom: 16),
                child: Text(
                  AppLocalizations.of(context).mSettingGeneralSettings,
                  style: GoogleFonts.lato(
                      color: AppColors.greys87,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                      letterSpacing: 0.25),
                ),
              ),
              // Container(
              //     decoration: BoxDecoration(
              //       color: Colors.white,
              //     ),
              //     padding: const EdgeInsets.all(15),
              //     margin: const EdgeInsets.only(bottom: 5),
              //     child: Row(
              //       children: <Widget>[
              //         Container(
              //           padding: const EdgeInsets.only(right: 20),
              //           child: SvgPicture.asset(
              //             'assets/img/language.svg',
              //             width: 25.0,
              //             height: 25.0,
              //           ),
              //         ),
              //         InkWell(
              //             onTap: () => _onLangClick(),
              //             child: Container(
              //                 width: 278,
              //                 child: Column(
              //                   crossAxisAlignment: CrossAxisAlignment.start,
              //                   mainAxisSize: MainAxisSize.min,
              //                   children: <Widget>[
              //                     Text(
              //                       AppLocalizations.of(context)
              //                           .mSettingLanguage,
              //                       style: GoogleFonts.lato(
              //                         color: AppColors.greys87,
              //                         fontSize: 14,
              //                         fontWeight: FontWeight.w700,
              //                         height: 1.5,
              //                       ),
              //                     )
              //                   ],
              //                 ))),
              //       ],
              //     )),
              InkWell(
                  onTap: () => Navigator.push(
                        context,
                        // FadeRoute(page: NotificationSettings()),
                        FadeRoute(
                            page: ComingSoonScreen(
                          removeGoToWeb: true,
                        )),
                      ),
                  child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.all(15),
                      margin: const EdgeInsets.only(bottom: 5),
                      child: Row(
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.only(right: 20),
                            child: SvgPicture.asset(
                              'assets/img/notifications.svg',
                              width: 25.0,
                              height: 25.0,
                              color: AppColors.greys87,
                            ),
                          ),
                          Container(
                              width: 278,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    AppLocalizations.of(context)
                                        .mStaticNotificationSettings,
                                    style: GoogleFonts.lato(
                                      color: AppColors.greys87,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      height: 1.5,
                                    ),
                                  )
                                ],
                              )),
                        ],
                      ))),
              InkWell(
                onTap: () => (() {}),
                child: Container(
                  padding: const EdgeInsets.only(left: 16, top: 32, bottom: 16),
                  child: Text(
                    AppLocalizations.of(context).mStaticOthers,
                    style: GoogleFonts.lato(
                        color: AppColors.greys87,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w700,
                        height: 1.5,
                        letterSpacing: 0.25),
                  ),
                ),
              ),
              InkWell(
                  onTap: () async => {
                        await Share.share(Platform.isAndroid
                            ? ApiUrl.androidUrl
                            : ApiUrl.iOSUrl)
                      },
                  child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.all(15),
                      margin: const EdgeInsets.only(bottom: 5),
                      child: Row(
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.only(right: 20),
                            child: SvgPicture.asset(
                              'assets/img/share.svg',
                              width: 25.0,
                              height: 25.0,
                              color: AppColors.greys60,
                            ),
                          ),
                          Container(
                              width: 278,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    AppLocalizations.of(context)
                                        .mSettingShareApplication,
                                    style: GoogleFonts.lato(
                                      color: AppColors.greys87,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      height: 1.5,
                                    ),
                                  )
                                ],
                              )),
                        ],
                      ))),
              InkWell(
                  onTap: () => Navigator.push(
                        context,
                        // FadeRoute(page: FeedbackPage()),
                        FadeRoute(
                            page: ComingSoonScreen(
                          removeGoToWeb: true,
                        )),
                      ),
                  // onTap: () => Navigator.push(
                  //       context,
                  //       FadeRoute(page: ComingSoonScreen()),
                  //     ),
                  child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.all(15),
                      margin: const EdgeInsets.only(bottom: 5),
                      child: Row(
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.only(right: 20),
                            child: SvgPicture.asset(
                              'assets/img/feedback.svg',
                              width: 25.0,
                              height: 25.0,
                              color: AppColors.greys60,
                            ),
                          ),
                          Container(
                              width: 278,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    AppLocalizations.of(context)
                                        .mSettingGiveFeedback,
                                    style: GoogleFonts.lato(
                                      color: AppColors.greys87,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      height: 1.5,
                                    ),
                                  )
                                ],
                              )),
                        ],
                      ))),
              InkWell(
                  onTap: () => Navigator.push(
                        context,
                        FadeRoute(page: ContactUs()),
                      ),
                  child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.all(15),
                      margin: const EdgeInsets.only(bottom: 5),
                      child: Row(
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.only(right: 20),
                            child: SvgPicture.asset(
                              'assets/img/help.svg',
                              width: 25.0,
                              height: 25.0,
                              color: AppColors.greys60,
                            ),
                          ),
                          Container(
                              width: 278,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    AppLocalizations.of(context).mSettingHelp,
                                    style: GoogleFonts.lato(
                                      color: AppColors.greys87,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      height: 1.5,
                                    ),
                                  )
                                ],
                              )),
                        ],
                      ))),
              InkWell(
                  onTap: () async {
                    final _storage = FlutterSecureStorage();
                    await _storage.write(
                        key: Storage.getStarted, value: GetStarted.reset);
                    _generateInteractTelemetryData(
                        TelemetryIdentifier.getStartedTab,
                        TelemetryIdentifier.getStartedTab);
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    Provider.of<LandingPageRepository>(context, listen: false)
                        .updateShowGetStarted(true);
                  },
                  child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.all(15),
                      margin: const EdgeInsets.only(bottom: 5),
                      child: Row(
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.only(right: 20),
                            child: SvgPicture.asset(
                              'assets/img/videoplay.svg',
                              width: 25.0,
                              height: 25.0,
                              color: AppColors.greys60,
                            ),
                          ),
                          Container(
                              width: 278,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    AppLocalizations.of(context)
                                        .mStaticKarmayogiTour,
                                    style: GoogleFonts.lato(
                                      color: AppColors.greys87,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      height: 1.5,
                                    ),
                                  )
                                ],
                              )),
                        ],
                      ))),
              Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  padding: const EdgeInsets.all(15),
                  margin: const EdgeInsets.only(bottom: 5),
                  child: Row(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.only(right: 20),
                        child: SvgPicture.asset(
                          'assets/img/logout.svg',
                          width: 25.0,
                          height: 25.0,
                          color: AppColors.greys87,
                        ),
                      ),
                      InkWell(
                        onTap: () => _onBackPressed(context),
                        child: Container(
                            width: 278,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  AppLocalizations.of(context).mSettingSignOut,
                                  style: GoogleFonts.lato(
                                    color: AppColors.greys87,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    height: 1.5,
                                  ),
                                )
                              ],
                            )),
                      )
                    ],
                  )),
              InkWell(
                onTap: () {
                  _displayFcmToken.value = !_displayFcmToken.value;
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    getEnvironmentInfo + ' Release ' + APP_VERSION,
                    style: GoogleFonts.montserrat(
                        color: AppColors.greys60,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              ValueListenableBuilder(
                  valueListenable: _displayFcmToken,
                  builder:
                      (BuildContext context, bool displayToken, Widget child) {
                    return Visibility(
                      visible: displayToken,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: Wrap(
                          runSpacing: 8,
                          children: [
                            Text(
                              'Firebase device token:  ',
                              style: GoogleFonts.montserrat(
                                color: AppColors.greys87,
                                fontSize: 16.0,
                              ),
                            ),
                            SelectableText(
                              '$_fcmToken',
                              showCursor: true,
                              // ignore: deprecated_member_use
                              toolbarOptions: ToolbarOptions(
                                  copy: true,
                                  selectAll: true,
                                  cut: false,
                                  paste: false),
                              style: GoogleFonts.montserrat(
                                color: AppColors.greys60,
                                fontSize: 14.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                alignment: Alignment.center,
                child: Text(
                  AppLocalizations.of(context).mStaticCopyRightText,
                ),
              ),
            ],
          ),
        ),
      ),

      // bottomNavigationBar: Transform.translate(
      //   offset: Offset(0.0, -1 * MediaQuery.of(context).viewInsets.bottom),
      //   child: BottomAppBar(
      //     child: Container(
      //         height: 56,
      //         child: Row(
      //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //           children: [
      //               Padding(
      //                 padding: const EdgeInsets.all(16.0),
      //                 child: Container(
      //                   height: 48,
      //                   // width: double.infinity,
      //                   child: Text(
      //                     'Karmayogi Bharat',
      //                     style: GoogleFonts.lato(
      //                         color: AppColors.greys87,
      //                         fontSize: 14.0,
      //                         fontWeight: FontWeight.w700),
      //                   ),
      //                 ),
      //               ),
      //           ])),
      //     color: Colors.white,
      //   ),
      // ),
    );
  }
}
