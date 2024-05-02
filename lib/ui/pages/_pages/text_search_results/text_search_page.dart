// import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:karmayogi_mobile/localization/index.dart';
import 'package:karmayogi_mobile/models/index.dart';
import 'package:karmayogi_mobile/services/index.dart';
import '../../../../constants/_constants/telemetry_constants.dart';
import '../../../widgets/index.dart';
import './../../../../constants/index.dart';
import './../../../../ui/pages/_pages/ai_assistant_page.dart';
import './../../../../ui/screens/index.dart';
// import './../../../../localization/index.dart';
import './../../../../util/telemetry.dart';
import './../../../../util/telemetry_db_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

//ignore: must_be_immutable
class TextSearchPage extends StatefulWidget {
  final int index;
  final Profile profileInfo;
  final profileParentAction;
  TextSearchPage(
      {Key key, this.index, this.profileInfo, this.profileParentAction})
      : super(key: key);
  @override
  TextSearchPageState createState() => TextSearchPageState();
}

class TextSearchPageState extends State<TextSearchPage> {
  var searchActionIcon = Icons.mic_rounded;
  // var searchActionIcon =
  //     VegaConfiguration.isEnabled ? Icons.mic_rounded : Icons.arrow_forward;
  final _textController = TextEditingController();
  String _searchText;

  String userId;
  String userSessionId;
  String messageIdentifier;
  String departmentId;
  List allEventsData = [];
  String deviceIdentifier;
  var telemetryEventData;
  String profileImageUrl;
  final _storage = FlutterSecureStorage();

  final TelemetryService telemetryService = TelemetryService();

  @override
  void initState() {
    super.initState();
    if (widget.index == 2) {
      _textController.addListener(_manageSearchActionIcon);
      _generateTelemetryData();
    }
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
        TelemetryPageIdentifier.globalSearchPageId,
        userSessionId,
        messageIdentifier,
        TelemetryType.app,
        TelemetryPageIdentifier.globalSearchPageUri,
        env: TelemetryEnv.home);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData1);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());
    allEventsData.add(eventData1);
    // await telemetryService.triggerEvent(allEventsData);
  }

  void _manageSearchActionIcon() {
    var icon;
    if (VegaConfiguration.isEnabled) {
      if (_textController.text != '') {
        icon = Icons.arrow_forward;
      } else {
        icon = Icons.mic_rounded;
      }
    } else {
      icon = Icons.arrow_forward;
    }

    setState(() {
      searchActionIcon = icon;
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.index == 2
        ? Scaffold(
            body: SafeArea(
                child: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  HomeAppBarNew(
                      profileInfo: widget.profileInfo,
                      index: widget.index,
                      profileParentAction: widget.profileParentAction,
                      isSearch: true),
                ];
              },
              body: Column(
                children: [
                  Container(
                      // color: Colors.white,
                      // height: double.infinity,
                      ),
                ],
              ),
            )),
            bottomNavigationBar: Transform.translate(
              offset:
                  Offset(0.0, -1 * MediaQuery.of(context).viewInsets.bottom),
              child: BottomAppBar(
                child: Container(
                    height: 56,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                            padding: const EdgeInsets.only(left: 15, right: 10),
                            child: Icon(
                              Icons.search,
                              color: AppColors.greys60,
                            )),
                        SizedBox(
                            height: 38,
                            width: MediaQuery.of(context).size.width - 150,
                            child: TextField(
                              autofocus: true,
                              controller: _textController,
                              onChanged: (value) {
                                setState(() {
                                  _searchText = value;
                                });
                                // print(textController.text);
                              },
                              decoration: InputDecoration(
                                suffixIconConstraints:
                                    BoxConstraints(maxWidth: 25),
                                suffixIcon: (_searchText != null &&
                                        _searchText.isNotEmpty)
                                    ? IconButton(
                                        splashRadius: 2,
                                        onPressed: () {
                                          setState(() {
                                            _textController.clear();
                                            _searchText = null;
                                          });
                                        },
                                        icon: Icon(
                                          Icons.clear,
                                        ))
                                    : Center(),
                                border: InputBorder.none,
                                hintText: _textController.text != ''
                                    ? _textController.text
                                    : AppLocalizations.of(context)
                                        .mCommonSearch,
                              ),
                            )),
                        Container(
                            padding: const EdgeInsets.only(left: 15),
                            child: CircleAvatar(
                              backgroundColor: AppColors.darkBlue,
                              child: IconButton(
                                icon: Icon(searchActionIcon),
                                color: Colors.white,
                                onPressed: () {
                                  if (searchActionIcon == Icons.mic_rounded) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                AiAssistantPage(
                                                  searchKeyword: '...',
                                                  index: 2,
                                                  isFromTextSearchPage: true,
                                                )));
                                  } else {
                                    _navigateToSubPage(context);
                                  }
                                },
                              ),
                              radius: 20,
                            )),
                      ],
                    )),
                color: Colors.white,
              ),
            ),
          )
        : Center();
  }

  void _navigateToSubPage(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                TextSearchResultScreen(searchKeyword: _textController.text)));
  }
}
