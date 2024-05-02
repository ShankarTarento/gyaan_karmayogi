import 'dart:convert';
// import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/storage_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/landing_page.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/models/_models/telemetry_event_model.dart';
import 'package:karmayogi_mobile/respositories/_respositories/chatbot_repository.dart';
import 'package:karmayogi_mobile/ui/pages/index.dart';
import 'package:karmayogi_mobile/util/telemetry.dart';
import 'package:karmayogi_mobile/util/telemetry_db_helper.dart';
import 'package:provider/provider.dart';

class LanguagePickerWidget extends StatefulWidget {
  final parentAction;
  final String loggedInStatus;
  ValueChanged onChanged;

  LanguagePickerWidget(
      {Key key, this.parentAction, this.loggedInStatus, this.onChanged})
      : super(key: key);
  @override
  LanguagePickerWidgetState createState() => LanguagePickerWidgetState();
}

class LanguagePickerWidgetState extends State<LanguagePickerWidget>
    with WidgetsBindingObserver {
  List<dynamic> dropdownItems = [];
  dynamic _dropdownValue;

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

  @override
  void initState() {
    super.initState();
    _getLanguages();
  }

  _getLanguages() async {
    final _storage = FlutterSecureStorage();
    final res = await Provider.of<ChatbotRepository>(context, listen: false)
        .getFaqAvailableLanguages();
    final String deviceLocale = Platform.localeName.split('_').first.toString();
    String selectedLanguage =
        await _storage.read(key: Storage.faqSelectedLanguage);
    dynamic selected;

    if (selectedLanguage == null) {
      if (deviceLocale == ChatBotLocale.hindi) {
        selected = {"value": "hi", "viewValue": "हिंदी"};
      } else {
        selected = {"value": "en", "viewValue": "English"};
      }
    } else {
      selected = jsonDecode(selectedLanguage);
    }
    setState(() {
      dropdownItems = res;
      if (dropdownItems == null) return dropdownItems;
      dropdownItems.forEach((element) {
        if (element.toString() == selected.toString()) {
          _dropdownValue = element;
        } else {
          _dropdownValue = dropdownItems[0];
        }
      });
    });
    return dropdownItems;
  }

  Future<void> _generateInteractTelemetryData(
      String contentId, String subtype) async {
    deviceIdentifier = await Telemetry.getDeviceIdentifier();
    userId = await Telemetry.getUserId(
        isPublic: widget.loggedInStatus == EnglishLang.NotLoggedIn);
    userSessionId = await Telemetry.generateUserSessionId();
    messageIdentifier = await Telemetry.generateUserSessionId();
    departmentId = await Telemetry.getUserDeptId(
        isPublic: widget.loggedInStatus == EnglishLang.NotLoggedIn);
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

  _setLanguage(dynamic newValue) async {
    await Provider.of<ChatbotRepository>(context, listen: false)
        .setLanguageDropDownValue(newValue);
    await Provider.of<ChatbotRepository>(context, listen: false).getFaqData(
        isLoggedIn: widget.loggedInStatus != EnglishLang.NotLoggedIn);
    // await LandingPage().setLocale(
    //     context,
    //     Locale(
    //       newValue['value'],
    //     ));
    //  await LandingPage().setChatBotLocale(context);

    await _generateInteractTelemetryData(
        newValue['value'], TelemetrySubType.languageDropdown);

    setState(() {
      _dropdownValue = newValue;
    });

    widget.parentAction();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: EdgeInsets.only(right: 4, top: 10, bottom: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.grey16),
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      child: dropdownItems != null && dropdownItems.isNotEmpty
          ? DropdownButton<dynamic>(
              value: _dropdownValue != null ? _dropdownValue : null,
              icon: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Icon(Icons.arrow_drop_down_outlined),
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
                return dropdownItems.map<Widget>((dynamic item) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      item['viewValue'],
                      style: GoogleFonts.lato(
                        color: AppColors.greys87,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.25,
                      ),
                    ),
                  );
                }).toList();
              },
              onChanged: (dynamic newValue) {
                _setLanguage(newValue);
                widget.onChanged(newValue);
              },
              items:
                  dropdownItems.map<DropdownMenuItem<dynamic>>((dynamic value) {
                return DropdownMenuItem<dynamic>(
                  value: value,
                  child: Text(value['viewValue']),
                );
              }).toList(),
            )
          : Text('Select'),
    );
  }
}
