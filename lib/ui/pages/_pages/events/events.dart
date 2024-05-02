import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/api_endpoints.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/feedback/widgets/_microSurvey/page_loader.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/models/_models/event_model.dart';
import 'package:karmayogi_mobile/models/_models/localization_text.dart';
import 'package:karmayogi_mobile/respositories/_respositories/event_repository.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/event_details_page.dart';
import 'package:karmayogi_mobile/ui/widgets/_events/events_item.dart';
import 'package:karmayogi_mobile/ui/widgets/_events/todays_events.dart';
import 'package:karmayogi_mobile/ui/widgets/_network/follow_us_social_media.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:provider/provider.dart';

import '../../../../constants/_constants/telemetry_constants.dart';
import '../../../../models/_models/telemetry_event_model.dart';
import '../../../../util/telemetry.dart';
import '../../../../util/telemetry_db_helper.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({Key key}) : super(key: key);

  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  String _dropdownValue = EnglishLang.all;
  List<LocalizationText> dropdownItems = [];
  List<Event> _eventsList = [];
  List<Event> _filteredEvents = [];
  bool _pageInitilized = false;
  List<Event> _todaysEvents = [];
  List<Event> _curatedEvents = [];
  // int pageNo = 1;
  // int pageCount;
  String userId;
  String userSessionId;
  String messageIdentifier;
  String departmentId;
  // List allEventsData;
  String deviceIdentifier;
  var telemetryEventData;

  @override
  void initState() {
    super.initState();
    _generateTelemetryData();
    _getTodaysEvents();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    dropdownItems =
        LocalizationText.getEventsHubFilterDropdown(context: context);
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
        TelemetryPageIdentifier.eventHomePageId,
        userSessionId,
        messageIdentifier,
        TelemetryType.page,
        TelemetryPageIdentifier.eventHomePageUri,
        env: TelemetryEnv.events);
    // print('event data: ' + eventData1.toString());
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData1);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());
  }

  void _generateInteractTelemetryData(String contentId) async {
    deviceIdentifier = await Telemetry.getDeviceIdentifier();
    userId = await Telemetry.getUserId();
    userSessionId = await Telemetry.generateUserSessionId();
    messageIdentifier = await Telemetry.generateUserSessionId();
    departmentId = await Telemetry.getUserDeptId();
    Map eventData = Telemetry.getInteractTelemetryEvent(
        deviceIdentifier,
        userId,
        departmentId,
        TelemetryPageIdentifier.eventHomePageId + '_' + contentId,
        userSessionId,
        messageIdentifier,
        contentId,
        TelemetrySubType.eventsTab,
        env: TelemetryEnv.events,
        objectType: TelemetrySubType.eventsTab);
    // print(eventData);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());
  }

  void _initializeInteractTelemetryData(newValue) async {
    if (newValue == EnglishLang.all) {
      _generateInteractTelemetryData(TelemetrySubType.allTab);
    } else {
      _generateInteractTelemetryData(TelemetrySubType.hostedByMyMDOTab);
    }
  }

  Future<List<Event>> _getTodaysEvents() async {
    final events = await Provider.of<EventRepository>(context, listen: false)
        .getAllEvents();
    _todaysEvents = events
        .where((event) =>
            event.startDate ==
            DateTime.now().toLocal().toString().split(' ').first)
        .toList();

    _curatedEvents = events
        .where((event) => event.createdFor.contains(SPV_ADMIN_ROOT_ORG_ID))
        .toList();
    return _todaysEvents;
  }

  Future<List<Event>> _getEvents() async {
    if (!_pageInitilized) {
      if (_dropdownValue == EnglishLang.hostedByMyMDO) {
        _eventsList = await Provider.of<EventRepository>(context, listen: false)
            .getEventsForMDO();
      } else if (_dropdownValue == EnglishLang.all) {
        _eventsList = await Provider.of<EventRepository>(context, listen: false)
            .getAllEvents();
      } else if (_dropdownValue == EnglishLang.curatedEvents) {
        _eventsList = _curatedEvents;
      }

      setState(() {
        _filteredEvents = _eventsList;
        _pageInitilized = true;
      });
    }

    return _eventsList;
  }

  void filterEvents(value) {
    setState(() {
      _filteredEvents = _eventsList
          .where(
              (event) => event.name.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  /// Load cards on scroll
  _loadMore() {
    // setState(() {
    //   if (pageNo < pageCount) {
    //     pageNo = pageNo + 1;
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
        // ignore: missing_return
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            _loadMore();
          }
        },
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: SingleChildScrollView(
            child: Container(
              color: AppColors.grey04,
              child: FutureBuilder(
                future: _getEvents(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return PageLoader(
                      bottom: 175,
                    );
                  }
                  var events = _filteredEvents;
                  // print('data: ' + snapshot.data.first.creatorDetails.toString());

                  return Column(
                    children: [
                      Wrap(
                        alignment: WrapAlignment.start,
                        children: [
                          Image(
                            height: 100,
                            width: double.infinity,
                            fit: BoxFit.fitWidth,
                            image: NetworkImage(
                              ApiUrl.baseUrl +
                                  '/assets/instances/eagle/banners/hubs/events/xxl.jpg',
                            ),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: PageLoader()),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                SizedBox.shrink(),
                          ),
                          FutureBuilder(
                            future: _getTodaysEvents(),
                            initialData: [],
                            builder:
                                (BuildContext context, AsyncSnapshot snapshot) {
                              return TodaysEvents(
                                events: _todaysEvents,
                              );
                            },
                          ),

                          Padding(
                            padding: const EdgeInsets.only(top: 16.0, left: 16),
                            child: Text(
                              AppLocalizations.of(context)
                                  .mEventsLabelAllEvents,
                              style: GoogleFonts.lato(
                                color: AppColors.greys87,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Container(
                              width: double.infinity,
                              // width: 316,
                              height: 48,
                              child: TextFormField(
                                  onChanged: (value) {
                                    filterEvents(value);
                                  },
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.done,
                                  style: GoogleFonts.lato(fontSize: 14.0),
                                  decoration: InputDecoration(
                                    fillColor: Colors.white,
                                    filled: true,
                                    prefixIcon: Icon(Icons.search),
                                    contentPadding: EdgeInsets.fromLTRB(
                                        16.0, 10.0, 0.0, 10.0),
                                    // border: OutlineInputBorder(
                                    //     borderSide: BorderSide(
                                    //         color: AppColors
                                    //             .primaryThree, width: 10),),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4.0),
                                      borderSide: BorderSide(
                                        color: AppColors.grey16,
                                        width: 1.0,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4.0),
                                      borderSide: BorderSide(
                                        color: AppColors.primaryThree,
                                      ),
                                    ),
                                    hintText: AppLocalizations.of(context)
                                        .mStaticSearch,
                                    hintStyle: GoogleFonts.lato(
                                        color: AppColors.greys60,
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w400),
                                    // focusedBorder: OutlineInputBorder(
                                    //   borderSide: const BorderSide(
                                    //       color: AppColors.primaryThree, width: 1.0),
                                    // ),
                                    counterStyle: TextStyle(
                                      height: double.minPositive,
                                    ),
                                    counterText: '',
                                  )),
                            ),
                          ),
                          Container(
                            // width: double.infinity,
                            // margin: EdgeInsets.only(right: 16, top: 2),
                            child: DropdownButton<String>(
                              value: _dropdownValue != null
                                  ? _dropdownValue
                                  : null,
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
                                return dropdownItems
                                    .map<Widget>((LocalizationText item) {
                                  return Row(
                                    children: [
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              15.0, 15.0, 0, 15.0),
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
                                _initializeInteractTelemetryData(newValue);
                                setState(() {
                                  _dropdownValue = newValue;
                                  _pageInitilized = false;
                                });
                              },
                              items: dropdownItems
                                  .map<DropdownMenuItem<String>>(
                                      (LocalizationText value) {
                                return DropdownMenuItem<String>(
                                  value: value.value,
                                  child: Text(value.displayText),
                                );
                              }).toList(),
                            ),
                          ),
                          _filteredEvents.length > 0
                              ? AnimationLimiter(
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: events.length,
                                    itemBuilder: (context, index) {
                                      return AnimationConfiguration
                                          .staggeredList(
                                              position: index,
                                              duration: const Duration(
                                                  milliseconds: 375),
                                              child: SlideAnimation(
                                                  verticalOffset: 50.0,
                                                  child: FadeInAnimation(
                                                    child: InkWell(
                                                        onTap: () {
                                                          // _generateInteractTelemetryData(
                                                          //     _trendingCourses[index].id);
                                                          Navigator.push(
                                                              context,
                                                              FadeRoute(
                                                                  page:
                                                                      EventDetailsPage(
                                                                eventId: events[
                                                                        index]
                                                                    .identifier,
                                                                objectType: events[
                                                                        index]
                                                                    .objectType,
                                                              )));
                                                          // Navigator.push(
                                                          //     context,
                                                          //     FadeRoute(
                                                          //         page: CourseDetailsPage(
                                                          //             id: _trendingCourses[index]
                                                          //                 .id)));
                                                        },
                                                        child: EventsItem(
                                                          event: events[index],
                                                        )),
                                                  )));
                                      // child: CourseItem(
                                      //     course: _trendingCourses[index]));
                                    },
                                  ),
                                )
                              : Stack(
                                  children: <Widget>[
                                    Column(
                                      children: [
                                        Container(
                                          child: Center(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 50),
                                              child: SvgPicture.asset(
                                                'assets/img/empty_search.svg',
                                                alignment: Alignment.center,
                                                // color: AppColors.grey16,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.2,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.2,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 16),
                                          child: Text(
                                            "No events",
                                            style: GoogleFonts.lato(
                                              color: AppColors.greys60,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
                                              height: 1.5,
                                              letterSpacing: 0.25,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                          // Wrap(
                          //   children: [
                          //     for (int i = 0; i < _filteredCareerOpenings.length; i++)
                          //       InkWell(
                          //           onTap: () {
                          //             _navigateToDetail(
                          //                 _filteredCareerOpenings[i].title,
                          //                 _filteredCareerOpenings[i].description,
                          //                 _filteredCareerOpenings[i].viewCount,
                          //                 _filteredCareerOpenings[i].timeStamp,
                          //                 _filteredCareerOpenings[i].tags);
                          //             // Navigator.push(
                          //             //   context,
                          //             //   MaterialPageRoute(
                          //             //       builder: (context) => CareerDetailedView(
                          //             //             careerOpening: _careerOpenings[i],
                          //             //           )),
                          //             // );
                          //             // _navigateToDetail(
                          //             //     _data[i].tid,
                          //             //     _data[i].user['fullname'],
                          //             //     _data[i].title,
                          //             //     _data[i].user['uid']);
                          //           },
                          //           child: Padding(
                          //             padding: const EdgeInsets.only(top: 8),
                          //             child: CareerCardView(
                          //               careerOpening: _filteredCareerOpenings[i],
                          //             ),
                          //           )),
                          //   ],
                          // ),
                        ],
                      ),
                      FollowUsOnSocialMedia(),
                      SizedBox(
                        height: 50,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ));
  }
}
