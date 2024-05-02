import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/storage_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/models/_models/telemetry_event_model.dart';
import 'package:karmayogi_mobile/respositories/_respositories/chatbot_repository.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/chat_assistant_page.dart';
import 'package:karmayogi_mobile/ui/widgets/language_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/util/telemetry.dart';
import 'package:karmayogi_mobile/util/telemetry_db_helper.dart';
import 'package:provider/provider.dart';

class ChatBot extends StatefulWidget {
  final String loggedInStatus;

  const ChatBot({Key key, this.loggedInStatus}) : super(key: key);
  @override
  _ChatBotState createState() => _ChatBotState();
}

class _ChatBotState extends State<ChatBot> with SingleTickerProviderStateMixin {
  String _userName = '';
  TabController _tabController;
  bool _isLanguageChanged = true;

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

  int _start = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
    _getProfileDetails();
    _triggerStartTelemetryEvent();
  }

  void _triggerStartTelemetryEvent() async {
    startTimer();
    deviceIdentifier = await Telemetry.getDeviceIdentifier();
    userId = await Telemetry.getUserId(
        isPublic: widget.loggedInStatus == EnglishLang.NotLoggedIn);
    userSessionId = await Telemetry.generateUserSessionId();
    messageIdentifier = await Telemetry.generateUserSessionId();
    departmentId = await Telemetry.getUserDeptId(
        isPublic: widget.loggedInStatus == EnglishLang.NotLoggedIn);

    Map eventData = Telemetry.getStartTelemetryEvent(
        deviceIdentifier,
        userId,
        departmentId,
        pageIdentifier,
        userSessionId,
        messageIdentifier,
        telemetryType,
        pageUri,
        env: TelemetryEnv.home);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());

    allEventsData.add(eventData);
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  void _generateInteractTelemetryData(String contentId, String subtype) async {
    Map eventData = Telemetry.getInteractTelemetryEvent(
        deviceIdentifier,
        userId,
        departmentId,
        pageIdentifier,
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

  Future<void> _triggerEndTelemetryEvent() async {
    Map eventData = Telemetry.getEndTelemetryEvent(
        deviceIdentifier,
        userId,
        departmentId,
        pageIdentifier,
        userSessionId,
        messageIdentifier,
        _start * 1000,
        telemetryType,
        pageUri,
        {},
        env: TelemetryEnv.learn);
    allEventsData.add(eventData);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());
  }

  _updateWidget() {
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  _getProfileDetails() async {
    try {
      final _storage = FlutterSecureStorage();
      String firstName = await _storage.read(key: Storage.firstName);
      setState(() {
        _userName = firstName;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  pinned: true,
                  backgroundColor: Color(0XFF1B4CA1),
                  elevation: 10,
                  centerTitle: false,
                  automaticallyImplyLeading: false,
                  title: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5.0),
                        child: Text(
                            _userName != null && _userName != ''
                                ? AppLocalizations.of(context).mStaticHi +
                                    ' ${_userName[0].toUpperCase()}${_userName.substring(1)}!'
                                : '${AppLocalizations.of(context).mStaticHi}!',
                            style: GoogleFonts.lato(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            )),
                      )),
                  actions: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        LanguagePickerWidget(
                          parentAction: _updateWidget,
                          loggedInStatus: widget.loggedInStatus,
                          onChanged: (value) {
                            _isLanguageChanged = true;
                            setState(() {});
                          },
                        ),
                        InkWell(
                          onTap: () async {
                            await _triggerEndTelemetryEvent();
                            await Provider.of<ChatbotRepository>(context,
                                    listen: false)
                                .updateChatHistory(isClear: true);
                            Navigator.of(context).pop();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: <Widget>[
                Center(
                  child: ChatAssistantPage(
                    widget.loggedInStatus,
                    isLanguageChanged: _isLanguageChanged,
                  ),
                ),
                Center(
                  child: ChatAssistantPage(
                    widget.loggedInStatus,
                    isIssues: true,
                    isLanguageChanged: _isLanguageChanged,
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: FutureBuilder(
            future: Future.delayed(Duration(milliseconds: 500)),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              return BottomAppBar(
                child: Container(
                  color: AppColors.appBarBackground,
                  child: TabBar(
                    indicator: BoxDecoration(
                        border: Border(
                            top: BorderSide(
                          color: AppColors.verifiedBadgeIconColor,
                          width: 3.0,
                        )),
                        color: Color.fromARGB(255, 243, 232, 209)),
                    labelColor: AppColors.verifiedBadgeIconColor,
                    unselectedLabelColor: AppColors.greys60,
                    tabs: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(5, 10, 5, 5),
                        child: Tab(
                            child: Column(
                          children: [
                            Icon(Icons.info_rounded, size: 24),
                            Text(
                                AppLocalizations.of(context) != null
                                    ? AppLocalizations.of(context)
                                        .mStaticInformation
                                    : EnglishLang.information,
                                style: GoogleFonts.lato(
                                    color: AppColors.greys60,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0.5))
                          ],
                        )),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(5, 10, 5, 5),
                        child: Tab(
                            child: Column(
                          children: [
                            Icon(Icons.warning_rounded, size: 24),
                            Text(
                                AppLocalizations.of(context) != null
                                    ? AppLocalizations.of(context).mStaticIssues
                                    : EnglishLang.issues,
                                style: GoogleFonts.lato(
                                    color: AppColors.greys60,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0.5))
                          ],
                        )),
                      )
                    ],
                    controller: _tabController,
                    onTap: (value) {
                      if (_tabController.index == 0) {
                        _generateInteractTelemetryData(EnglishLang.information,
                            TelemetrySubType.informationTab);
                      } else {
                        _generateInteractTelemetryData(
                            EnglishLang.issues, TelemetrySubType.issuesTab);
                      }
                    },
                  ),
                ),
              );
            }),
      ),
    );
  }
}
