import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/feedback/widgets/_microSurvey/page_loader.dart';
import 'package:karmayogi_mobile/localization/index.dart';
import 'package:karmayogi_mobile/models/_models/event_detail_model.dart';
import 'package:karmayogi_mobile/respositories/_respositories/event_repository.dart';
import 'package:karmayogi_mobile/ui/widgets/_events/event_overview.dart';
import 'package:karmayogi_mobile/ui/widgets/_signup/contact_us.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:provider/provider.dart';

import '../../../../constants/_constants/telemetry_constants.dart';
import '../../../../models/_models/telemetry_event_model.dart';
import '../../../../util/telemetry.dart';
import '../../../../util/telemetry_db_helper.dart';

class EventDetailsPage extends StatefulWidget {
  final eventId;
  final objectType;
  EventDetailsPage({Key key, this.eventId, this.objectType}) : super(key: key);

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  EventDetail _event;

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
        TelemetryPageIdentifier.eventDetailsPageId,
        userSessionId,
        messageIdentifier,
        TelemetryType.page,
        TelemetryPageIdentifier.eventDetailsPageUri
            .replaceAll(':eventId', widget.eventId),
        env: TelemetryEnv.events,
        objectId: widget.eventId,
        objectType: widget.objectType);
    // print('event data: ' + eventData1.toString());
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData1);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());
  }

  Future<EventDetail> _getEventDetails(context) async {
    _event = await Provider.of<EventRepository>(context, listen: false)
        .getEventDetails(widget.eventId);
    return _event;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
            future: _getEventDetails(context),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.hasData) {
                // var course = snapshot.data;
                return NestedScrollView(
                  headerSliverBuilder:
                      (BuildContext context, bool innerBoxIsScrolled) {
                    return <Widget>[
                      SliverAppBar(
                          pinned: false,
                          expandedHeight: 280,
                          leading: BackButton(color: AppColors.greys60),
                          actions: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  FadeRoute(page: ContactUs()),
                                );
                              },
                              child: SvgPicture.asset(
                                'assets/img/help_icon.svg',
                                width: 56.0,
                                height: 56.0,
                              ),
                            )
                          ],
                          flexibleSpace: ListView(
                            shrinkWrap: true,
                            children: <Widget>[
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          8, 26, 0, 32),
                                      child: Center(),
                                    )
                                  ]),
                              Container(
                                  width: double.infinity,
                                  child: (_event.eventIcon != null &&
                                          _event.eventIcon != '')
                                      ? Image.network(
                                          Helper.convertImageUrl(
                                              _event.eventIcon),
                                          // fit: BoxFit.cover,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return SizedBox(
                                              width: 50,
                                              height: 50,
                                              child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: PageLoader()),
                                            );
                                          },
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Center(),
                                        )
                                      : Image.asset(
                                          'assets/img/image_placeholder.jpg',
                                          // width: 320,
                                          // height: 182,
                                          fit: BoxFit.cover,
                                        )),

                              // Padding(
                              //   padding: const EdgeInsets.only(
                              //       left: 16, right: 330, top: 8, bottom: 10),
                              //   child: Container(
                              //     height: 48,
                              //     width: 48,
                              //     decoration: BoxDecoration(
                              //       image: DecorationImage(
                              //           image: AssetImage(
                              //               'assets/img/igot_icon.png'),
                              //           fit: BoxFit.scaleDown),
                              //       color: Colors.white,
                              //       borderRadius: BorderRadius.all(
                              //           const Radius.circular(4.0)),
                              //       // shape: BoxShape.circle,
                              //       boxShadow: [
                              //         BoxShadow(
                              //           color: AppColors.grey08,
                              //           blurRadius: 3,
                              //           spreadRadius: 0,
                              //           offset: Offset(
                              //             3,
                              //             3,
                              //           ),
                              //         ),
                              //       ],
                              //     ),
                              //   ),
                              // ),
                            ],
                          )),
                    ];
                  },

                  // TabBar view
                  body: Container(
                    color: AppColors.lightBackground,
                    child: EventOverview(
                      eventDetail: _event,
                    ),
                  ),
                );
              } else {
                // return Center(child: CircularProgressIndicator());
                return PageLoader();
              }
            }),
      ),
    );
  }
}
