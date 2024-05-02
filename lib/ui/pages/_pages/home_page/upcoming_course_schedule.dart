import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/models/_models/batch_attributes_model.dart';
import 'package:karmayogi_mobile/services/_services/location_service.dart';
import 'package:karmayogi_mobile/ui/widgets/_scanner/mark_attendence.dart';
import 'package:karmayogi_mobile/ui/widgets/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../constants/_constants/color_constants.dart';
import '../../../../localization/_langs/english_lang.dart';

class UpcomingCourseSchedule extends StatefulWidget {
  final List<Map<String, BatchAttributes>> batchAttributes;
  final List<Map<String, dynamic>> orderedSessions;
  final VoidCallback callBack;
  UpcomingCourseSchedule(
      {Key key,
      @required this.batchAttributes,
      this.callBack,
      this.orderedSessions})
      : super(key: key);
  @override
  UpcomingCourseScheduleState createState() => UpcomingCourseScheduleState();
}

class UpcomingCourseScheduleState extends State<UpcomingCourseSchedule> {
  final _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.batchAttributes.isNotEmpty,
      child: Container(
        color: AppColors.whiteGradientOne,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(left: 16),
              child: TitleSemiboldSize16(
                  AppLocalizations.of(context).mStaticMarkYourAttendance),
            ),
            Container(
                padding: EdgeInsets.only(left: 10, bottom: 16),
                height: 136,
                child: Column(
                  children: [
                    Expanded(
                      child: PageView.builder(
                          controller: _controller,
                          itemCount: widget.orderedSessions.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            var batchData;
                            widget.batchAttributes.forEach((batch) =>
                                batch.forEach((id, batchAttr) {
                                  batchAttr.sessionDetailsV2.forEach((session) {
                                    if (session.sessionId ==
                                        widget.orderedSessions[index]
                                            ['sessionId']) {
                                      batchData = batch;
                                    }
                                  });
                                }));
                            return batchData == null
                                ? Center()
                                : SessionScheduleWidget(
                                    batch: batchData,
                                    sessionId: widget.orderedSessions[index]
                                        ['sessionId'],
                                    callBack: widget.callBack);
                          }),
                    ),
                    SmoothPageIndicator(
                      controller: _controller,
                      count: widget.orderedSessions.length,
                      effect: ExpandingDotsEffect(
                          activeDotColor: AppColors.orangeTourText,
                          dotColor: AppColors.profilebgGrey20,
                          dotHeight: 4,
                          dotWidth: 4,
                          spacing: 4),
                    )
                  ],
                )),
          ],
        ),
      ),
    );
  }
}

class SessionScheduleWidget extends StatelessWidget {
  final Map<String, BatchAttributes> batch;
  final VoidCallback callBack;
  final String sessionId;

  bool isPast = false;
  SessionScheduleWidget({Key key, this.batch, this.sessionId, this.callBack})
      : super(key: key);

  final subTitleStyle = TextStyle(
      color: AppColors.avatarText.withOpacity(0.7),
      fontWeight: FontWeight.w400,
      fontSize: 14);

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];
    batch.forEach((id, batchAttr) {
      String selectedBatchId = id;
      batchAttr.sessionDetailsV2.forEach((session) {
        final bool isLive = _isSessionLive(session);
        var widget = session.sessionId == sessionId
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                        color: AppColors.orange32,
                        border: Border.all(
                            color: AppColors.verifiedBadgeIconColor, width: 1),
                        borderRadius: BorderRadius.all(Radius.circular(12))),
                    margin: EdgeInsets.fromLTRB(5, 10, 10, 0),
                    padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Visibility(
                            visible: isLive,
                            child: Text(
                              AppLocalizations.of(context).mStaticLive,
                              style: TextStyle(
                                  color: AppColors.lightGreen,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12),
                            )),
                        Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.60,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TitleBoldWidget(
                                    '${session.title} - ${session.sessionType}',
                                    maxLines: 2,
                                  ),
                                  Visibility(
                                      visible: !isLive,
                                      child: SizedBox(
                                        height: 5,
                                      )),
                                  Visibility(
                                    visible: !isLive,
                                    child: TitleRegularGrey60(
                                      convertTo12HourFormat(session.startTime) +
                                          ' to ' +
                                          convertTo12HourFormat(
                                              session.endTime) +
                                          ', ' +
                                          DateFormat('dd/MM/yy').format(
                                              DateTime.parse(
                                                  session.startDate)),
                                      color: AppColors.greys87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            session.sessionAttendanceStatus
                                ? Container(
                                    padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                                    decoration: BoxDecoration(
                                        color: AppColors.ghostWhite
                                            .withOpacity(.5),
                                        borderRadius: BorderRadius.circular(5)),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: SvgPicture.asset(
                                            'assets/img/approved.svg',
                                            width: 20,
                                            height: 20,
                                          ),
                                        ),
                                        Text(
                                            AppLocalizations.of(context)
                                                .mStaticMarkedAttendence,
                                            style: GoogleFonts.lato(
                                                height: 1.5,
                                                decoration: TextDecoration.none,
                                                color: AppColors.greys87,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400)),
                                      ],
                                    ),
                                  )
                                : Align(
                                    alignment: Alignment.center,
                                    child: ElevatedButton(
                                      child: Center(
                                        child: SvgPicture.asset(
                                            'assets/img/qr_scanner.svg',
                                            width: 56.0,
                                            height: 56.0),
                                      ),
                                      style: TextButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          elevation: 0),
                                      onPressed: isLive &&
                                              session.sessionType ==
                                                  'Offline' &&
                                              batchAttr.enableQR
                                          ? () async {
                                              final LocationService
                                                  locationService =
                                                  LocationService();
                                              LocationPermission
                                                  permissionStatus =
                                                  await locationService
                                                      .handleLocationPermission();
                                              if (permissionStatus ==
                                                  LocationPermission.denied) {
                                                showToastMessage(context,
                                                    message: AppLocalizations
                                                            .of(context)
                                                        .mStaticDisabledLocationToastMsg);
                                                return;
                                              }
                                              if (permissionStatus ==
                                                  LocationPermission
                                                      .deniedForever) {
                                                showToastMessage(context,
                                                    message: AppLocalizations
                                                            .of(context)
                                                        .mStaticDisabledLocationToastToOpenSettings);
                                                return;
                                              }
                                              if (permissionStatus ==
                                                      LocationPermission
                                                          .always ||
                                                  permissionStatus ==
                                                      LocationPermission
                                                          .whileInUse) {
                                                try {
                                                  Position position =
                                                      await locationService
                                                          .getCurrentPosition();
                                                  bool isLocationValid = locationService
                                                      .isValidLocationRange(
                                                          startLatitude:
                                                              position.latitude,
                                                          startLongitude:
                                                              position
                                                                  .longitude,
                                                          endLatitude: double
                                                              .parse(batchAttr
                                                                  .latlong
                                                                  .split(',')
                                                                  .first),
                                                          endLongitude: double
                                                              .parse(batchAttr
                                                                  .latlong
                                                                  .split(',')
                                                                  .last));

                                                  if (isLocationValid) {
                                                    var isAttendanceMarked =
                                                        await Navigator.of(
                                                                context)
                                                            .push(
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            MarkAttendence(
                                                          id: id,
                                                          onAttendanceMarked:
                                                              () {},
                                                          courseId: batchAttr
                                                              .courseId,
                                                          sessionIds: [
                                                            {
                                                              'sessionId':
                                                                  session
                                                                      .sessionId,
                                                              'status': false
                                                            }
                                                          ],
                                                          batchId:
                                                              selectedBatchId,
                                                        ),
                                                      ),
                                                    );
                                                    if (isAttendanceMarked !=
                                                        null) {
                                                      if (isAttendanceMarked) {
                                                        session.sessionAttendanceStatus =
                                                            isAttendanceMarked;
                                                        callBack();
                                                      }
                                                    }
                                                  } else {
                                                    showToastMessage(context,
                                                        title: AppLocalizations
                                                                .of(context)
                                                            .mStaticInvalidLocation,
                                                        message: AppLocalizations
                                                                .of(context)
                                                            .mStaticInvalidLocationDesc);
                                                  }
                                                } catch (e) {
                                                  showToastMessage(context,
                                                      title: AppLocalizations
                                                              .of(context)
                                                          .mStaticInvalidLocation,
                                                      message: AppLocalizations
                                                              .of(context)
                                                          .mStaticInvalidLocationDesc);
                                                }
                                              }
                                            }
                                          : isPast ||
                                                  session.sessionType !=
                                                          'Offline' &&
                                                      !batchAttr.enableQR
                                              ? () {
                                                  showToastMessage(context,
                                                      message: AppLocalizations
                                                              .of(context)
                                                          .mStaticContactProgramCordinator);
                                                }
                                              : () => showToastMessage(context,
                                                  message: AppLocalizations.of(
                                                          context)
                                                      .mStaticWaitTillSessionStart),
                                    ),
                                  ),
                          ],
                        ),
                      ],
                    )),
              )
            : Center();
        widgets.add(widget);
      });
    });
    return Row(children: widgets);
  }

  void showToastMessage(BuildContext context, {String title, String message}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Column(
      children: [
        Text(title ?? ''),
        Text(
          message ?? '',
          textAlign: TextAlign.center,
        ),
      ],
    )));
  }

  bool _isSessionLive(SessionDetailsV2 session) {
    try {
      DateTime sessionDate = DateTime.parse(session.startDate);
      TimeOfDay startTime = _getTimeIn24HourFormat(session.startTime);
      // TimeOfDay endTime = _getTimeIn24HourFormat(session.endTime);
      DateTime sessionStartDateTime = DateTime(sessionDate.year,
          sessionDate.month, sessionDate.day, startTime.hour, startTime.minute);
      DateTime sessionStartEndTime = DateTime(
          sessionDate.year,
          sessionDate.month,
          sessionDate.day,
          startTime.hour +
              (int.parse((session.sessionDuration).split('hr')[0])) +
              AttendenceMarking.bufferHour,
          startTime.minute);
      final bool isLive = (DateTime.now().isAfter(sessionStartDateTime) &&
          DateTime.now().isBefore(sessionStartEndTime));
      isPast = (DateTime.now().isAfter(sessionStartEndTime));
      return isLive;
    } catch (e) {
      return false;
    }
  }

  TimeOfDay _getTimeIn24HourFormat(String timeIn12HourFormat) {
    List timeSplits = timeIn12HourFormat.split(':'); // eg. 12:30 PM
    String hourString = timeSplits.first;
    String minString = timeSplits.last.split(' ').first;
    int min = int.parse(minString);
    int hour = int.parse(hourString);

    //add 12 hour value if time recieved in pm
    hour =
        (hour != 12 && timeSplits.last.toString().toLowerCase().contains('pm'))
            ? hour + 12
            : hour;

    return TimeOfDay(hour: hour, minute: min);
  }

  String convertTo12HourFormat(String time24hr) {
    final time = DateFormat.Hm().parse(time24hr); // Parse time
    final formattedTime =
        DateFormat.jm().format(time); // Format to 12-hour format with AM/PM
    return formattedTime;
  }
}
