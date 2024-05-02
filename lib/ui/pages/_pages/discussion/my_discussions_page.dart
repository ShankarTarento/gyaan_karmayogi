import 'dart:async';
import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/models/_models/localization_text.dart';
import 'package:karmayogi_mobile/models/index.dart';
import 'package:karmayogi_mobile/respositories/_respositories/profile_repository.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../constants/_constants/telemetry_constants.dart';
import './../../../../respositories/index.dart';
import './../../../../services/index.dart';
import './../../../../ui/pages/index.dart';
import './../../../../ui/widgets/index.dart';
import './../../../../util/faderoute.dart';
import './../../../../constants/index.dart';
import './../../../../localization/index.dart';
import './../../../../util/telemetry.dart';
import './../../../../util/telemetry_db_helper.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// ignore: must_be_immutable
class MyDiscussionsPage extends StatefulWidget {
  final String wid;
  final int tabIndex;
  final bool isProfilePage;
  final bool isDiscussionPage;

  MyDiscussionsPage(
      {Key key,
      this.tabIndex,
      this.wid = '',
      this.isProfilePage = false,
      this.isDiscussionPage = false})
      : super(key: key);

  @override
  _MyDiscussionsPageState createState() => _MyDiscussionsPageState();
}

class _MyDiscussionsPageState extends State<MyDiscussionsPage> {
  final TelemetryService telemetryService = TelemetryService();
  final ProfileService profileService = ProfileService();
  List _data = [];
  List<LocalizationText> dropdownItems = [];

  String _dropdownValue = EnglishLang.recentPosts;

  String userId;
  String userSessionId;
  String messageIdentifier;
  String departmentId;
  int _start = 0;
  List allEventsData;
  String deviceIdentifier;
  var telemetryEventData;

  @override
  void initState() {
    super.initState();

    if (_start == 0) {
      allEventsData = [];
      _generateTelemetryData();
    }
  }

  @override
  void didChangeDependencies() {
    dropdownItems = LocalizationText.getDiscussHubYourDiscussionFilterDropdown(
        context: context);
    super.didChangeDependencies();
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
        TelemetryPageIdentifier.myDiscussionsPageId,
        userSessionId,
        messageIdentifier,
        TelemetryType.page,
        TelemetryPageIdentifier.myDiscussionsPageUri,
        env: TelemetryEnv.discuss);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData1);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());
  }

  /// Get recent discussions
  Future<dynamic> _myDiscussion() async {
    List<dynamic> response = [];
    List<dynamic> data = [];
    try {
      switch (_dropdownValue) {
        case EnglishLang.recentPosts:
          var res = await Provider.of<DiscussRepository>(context, listen: false)
              .getMyDiscussions();
          if (res['posts'] != null && res['posts'].isNotEmpty) {
            response = [
              for (final item in res['posts']) Discuss.fromJson(item)
            ];
          }
          break;
        case EnglishLang.bestPosts:
          response =
              await Provider.of<DiscussRepository>(context, listen: false)
                  .getMyBestDiscussions();
          break;
        case EnglishLang.upvoted:
          response =
              await Provider.of<DiscussRepository>(context, listen: false)
                  .getUpvotedDiscussions();
          break;
        default:
          response =
              await Provider.of<DiscussRepository>(context, listen: false)
                  .getDownvotedDiscussions();
          break;
      }
      List<int> tids = [];
      for (int i = 0; i < response.length; i++) {
        if (!tids.contains(response[i].tid)) {
          data.add(response[i]);
        }
        tids.add(response[i].tid);
      }
    } catch (err) {
      return err;
    }
    return data;
  }

  Future<dynamic> _userDiscussions(wid) async {
    // print('In user discussion: ' + wid.toString());
    List<dynamic> response = [];
    List<dynamic> data = [];
    // print('In discussion');
    try {
      String userName =
          await Provider.of<ProfileRepository>(context, listen: false)
              .getUserName(wid);
      // print('user name' + userName);
      response = await Provider.of<DiscussRepository>(context, listen: false)
          .getUserDiscussions(userName);
      // print('discussion data: ' + response.toString());
      List<int> tids = [];
      for (int i = 0; i < response.length; i++) {
        if (!tids.contains(response[i].tid)) {
          data.add(response[i]);
        }
        tids.add(response[i].tid);
      }
    } catch (err) {
      return err;
    }
    return data;
  }

  void _generateInteractTelemetryData(String contentId) async {
    Map eventData = Telemetry.getInteractTelemetryEvent(
        deviceIdentifier,
        userId,
        departmentId,
        TelemetryPageIdentifier.myDiscussionsPageId,
        userSessionId,
        messageIdentifier,
        contentId,
        TelemetrySubType.discussionCard,
        env: TelemetryEnv.discuss,
        objectType: TelemetrySubType.discussionCard);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());
    // allEventsData.add(eventData);
  }

  /// Navigate to discussion detail
  _navigateToDetail(tid, userName, title, uid) {
    _generateInteractTelemetryData(tid.toString());
    Navigator.push(
      context,
      FadeRoute(
        page: ChangeNotifierProvider<DiscussRepository>(
          create: (context) => DiscussRepository(),
          child: DiscussionPage(
              tid: tid, userName: userName, title: title, uid: uid),
        ),
      ),
    );
  }

  @override
  void dispose() async {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.isDiscussionPage);
    print(widget.isProfilePage);
    return SingleChildScrollView(
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.isDiscussionPage
              ? Container(
                  // width: double.infinity,
                  margin: EdgeInsets.only(left: 8, top: 8),
                  child: DropdownButton<String>(
                    // isExpanded: true,
                    value: _dropdownValue != null ? _dropdownValue : null,
                    icon: Icon(Icons.arrow_drop_down_outlined),
                    iconSize: 26,
                    elevation: 16,
                    style: TextStyle(color: AppColors.greys87),
                    underline: Container(
                      // height: 2,
                      color: AppColors.lightGrey,
                    ),
                    borderRadius: BorderRadius.circular(4),
                    selectedItemBuilder: (BuildContext context) {
                      return dropdownItems.map<Widget>((LocalizationText item) {
                        return Row(
                          children: [
                            Padding(
                                padding:
                                    EdgeInsets.fromLTRB(15.0, 15.0, 8.0, 15.0),
                                child: Text(
                                  item.displayText,
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
                      // _initializeInteractTelemetryData(newValue);
                      setState(() {
                        _dropdownValue = newValue;
                        // _pageInitilized = false;
                      });
                    },
                    items: dropdownItems.map<DropdownMenuItem<String>>(
                        (LocalizationText value) {
                      return DropdownMenuItem<String>(
                        value: value.value,
                        child: Text(value.displayText),
                      );
                    }).toList(),
                  ),
                )
              : Center(),
          _dropdownValue == EnglishLang.savedPosts
              ? SavedPostsPage()
              : FutureBuilder(
                  future: widget.wid == ''
                      ? _myDiscussion()
                      : _userDiscussions(widget.wid),
                  builder: (context, AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      _data = snapshot.data;
                      return Wrap(
                        alignment: WrapAlignment.start,
                        children: [
                          AnimationLimiter(
                            child: Wrap(
                              children: [
                                Container(
                                  padding: EdgeInsets.only(bottom: 200.0),
                                  child: Wrap(
                                    children: [
                                      for (int i = 0; i < _data.length; i++)
                                        AnimationConfiguration.staggeredList(
                                          position: i,
                                          duration:
                                              const Duration(milliseconds: 375),
                                          child: SlideAnimation(
                                            verticalOffset: 50.0,
                                            child: FadeInAnimation(
                                              child: InkWell(
                                                onTap: () {
                                                  _navigateToDetail(
                                                      _data[i].tid,
                                                      _data[i].user['fullname'],
                                                      _data[i].title,
                                                      _data[i].user['uid']);
                                                },
                                                child: _data != null
                                                    ? Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                top: 8,
                                                                left: 16,
                                                                right: 12),
                                                        child:
                                                            TrendingDiscussCard(
                                                          data: _data[i],
                                                          isDiscussion: true,
                                                        ),
                                                      )
                                                    : Center(
                                                        child: Text(''),
                                                      ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      _data.length == 0
                                          ? Container(
                                              padding: const EdgeInsets.only(
                                                  top: 100),
                                              child: Center(
                                                  child: Column(children: [
                                                SvgPicture.asset(
                                                  'assets/img/discussion-empty.svg',
                                                  fit: BoxFit.cover,
                                                ),
                                                Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 20),
                                                    child: Text(
                                                      AppLocalizations.of(
                                                              context)
                                                          .mStaticNoDiscussions,
                                                      style: GoogleFonts.lato(
                                                        color:
                                                            AppColors.greys60,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: 16,
                                                      ),
                                                    )),
                                                (!widget.isProfilePage &&
                                                        _dropdownValue ==
                                                            EnglishLang
                                                                .recentPosts)
                                                    ? Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                top: 20,
                                                                left: 50,
                                                                right: 50),
                                                        child: Text(
                                                          AppLocalizations.of(
                                                                  context)
                                                              .mStaticStartNewDiscussionText,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style:
                                                              GoogleFonts.lato(
                                                            color: AppColors
                                                                .greys60,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 16,
                                                          ),
                                                        ))
                                                    : Center()
                                              ])))
                                          : Center()
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    } else {
                      return PageLoader(
                        bottom: 175,
                      );
                    }
                  }),
        ],
      ),
    );
  }
}
