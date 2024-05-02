import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/models/_models/telemetry_event_model.dart';
import 'package:karmayogi_mobile/services/_services/location_service.dart';
import 'package:karmayogi_mobile/ui/widgets/_scanner/mark_attendence.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:karmayogi_mobile/util/telemetry.dart';
import 'package:karmayogi_mobile/util/telemetry_db_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// import '../../../../models/_models/batch_attributes_model.dart';
import '../../../../models/_models/batch_model.dart';
import '../../../../services/index.dart';

class CourseSessionPage extends StatefulWidget {
  final course;
  final bool isContinueLearning;
  final String batchId;
  final contentProgress;
  final ValueChanged<String> parentAction;
  final bool isFeatured;
  final bool isBlendedProgram;
  final bool scannerVisibility;

  CourseSessionPage(
      {this.course,
      this.isContinueLearning = false,
      this.batchId,
      this.contentProgress,
      this.parentAction,
      this.isFeatured = false,
      this.isBlendedProgram = false,
      this.scannerVisibility = false});

  @override
  State<CourseSessionPage> createState() => _CourseSessionPageState();
}

class _CourseSessionPageState extends State<CourseSessionPage> {
  final LearnService learnService = LearnService();
  String userId;
  String userSessionId;
  String departmentId;
  String messageIdentifier;
  String deviceIdentifier;
  var telemetryEventData;
  var contentProgressList = [];
  DateTime attendanceMarkTime;
  List batches = [];
  List<Map<String, dynamic>> sessionIdList = [];

  List<SessionDetailV2> sessionList = [];
  var selectedBatch;

  void initState() {
    super.initState();
    // _generateNavigation();
    if (widget.batchId != null && !widget.isFeatured) {
      // _readCourseContentProgress(true);
    }
    _generateTelemetryData();
    getSessionDetails();
  }

  void _generateTelemetryData() async {
    deviceIdentifier = await Telemetry.getDeviceIdentifier();
    userId = await Telemetry.getUserId(isPublic: widget.isFeatured);
    userSessionId = await Telemetry.generateUserSessionId();
    messageIdentifier = await Telemetry.generateUserSessionId();
    departmentId = await Telemetry.getUserDeptId(isPublic: widget.isFeatured);
    String pageUri = (!widget.isFeatured
            ? TelemetryPageIdentifier.courseDetailsPageUri
            : TelemetryPageIdentifier.publicCourseDetailsPageUri)
        .replaceAll(':do_ID', widget.course['identifier']);
    if (widget.batchId != null) {
      pageUri = pageUri + "?batchId=${widget.batchId}";
    }
    Map eventData1 = Telemetry.getImpressionTelemetryEvent(
        deviceIdentifier,
        userId,
        departmentId,
        (!widget.isFeatured
            ? TelemetryPageIdentifier.courseDetailsPageId
            : TelemetryPageIdentifier.publicCourseDetailsPageId),
        userSessionId,
        messageIdentifier,
        !widget.isFeatured ? TelemetryType.public : TelemetryType.page,
        pageUri,
        env: TelemetryEnv.learn,
        objectId: widget.course['identifier'],
        objectType: widget.course['primaryCategory'],
        isPublic: widget.isFeatured);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData1);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());
  }

  Future<dynamic> _readContentProgress() async {
    var response = await learnService.readContentProgress(
        widget.course['identifier'], widget.batchId);
    if (response['result']['contentList'] != null) {
      setState(() {
        contentProgressList = response['result']['contentList'];
      });
    }
  }

  bool checkCompletionStatus(session) {
    if (contentProgressList != null) {
      for (int i = 0; i < contentProgressList.length; i++) {
        if (contentProgressList[i]['contentId'] == session.sessionId &&
            contentProgressList[i]['progress'] == 100 &&
            contentProgressList[i]['status'] == 2) {
          session.sessionAttendanceStatus = true;
          return true;
        }
      }
    }
    return false;
  }

  getSessionDetails() async {
    sessionList = [];
    await _readContentProgress();
    batches = widget.course['batches'];
    if (batches.isNotEmpty) {
      batches.forEach((batch) {
        if (batch.batchId == widget.batchId &&
            batch.batchAttributes.sessionDetailsV2 != null) {
          (batch.batchAttributes.sessionDetailsV2).forEach((session) {
            selectedBatch = batch;
            sessionList.add(session);
          });
        }
      });
    }
    if (sessionList.isNotEmpty) {
      getLiveSessionIds();
    }
  }

  getLiveSessionIds() {
    sessionIdList = [];
    sessionList.forEach((session) {
      bool sessionStatus = Helper.isSessionLive(session);
      if (sessionStatus) {
        bool status = checkCompletionStatus(session);
        sessionIdList.add({'sessionId': session.sessionId, 'status': status});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sessionList.length,
                  itemBuilder: (context, index) {
                    bool showCompleted =
                        checkCompletionStatus(sessionList[index]);
                    return SessionItem(
                        session: sessionList[index],
                        showCompleted: showCompleted);
                  }),
              SizedBox(height: 80),
            ],
          ),
        ),
        floatingActionButton: Visibility(
          visible: (sessionList.isNotEmpty && widget.scannerVisibility),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 70.0),
            child: FloatingActionButton.extended(
              label: Row(
                children: [
                  SvgPicture.asset(
                    'assets/img/ic_mark_attendance.svg',
                    alignment: Alignment.center,
                    width: 24,
                    height: 24,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(width: 8),
                  Text(AppLocalizations.of(context).mStaticScanToMarkAttendence,
                      style: GoogleFonts.lato(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        fontSize: 14,
                      ))
                ],
              ),
              backgroundColor: Colors.black.withOpacity(0.7),
              onPressed: () async {
                final LocationService locationService = LocationService();
                LocationPermission permissionStatus =
                    await locationService.handleLocationPermission();
                if (permissionStatus == LocationPermission.denied) {
                  showToastMessage(context,
                      message: AppLocalizations.of(context)
                          .mStaticDisabledLocationToastMsg);
                  return;
                }
                if (permissionStatus == LocationPermission.deniedForever) {
                  showToastMessage(context,
                      message: AppLocalizations.of(context)
                          .mStaticDisabledLocationToastToOpenSettings);
                  return;
                }
                if (permissionStatus == LocationPermission.always ||
                    permissionStatus == LocationPermission.whileInUse) {
                  try {
                    Position position =
                        await locationService.getCurrentPosition();

                    var currentBatch = batches.isNotEmpty
                        ? batches.firstWhere(
                            (batch) => batch.batchId == widget.batchId)
                        : [];

                    bool isLocationValid = locationService.isValidLocationRange(
                        startLatitude: position.latitude,
                        startLongitude: position.longitude,
                        endLatitude: double.parse(currentBatch
                            .batchAttributes.latlong
                            .split(',')
                            .first),
                        endLongitude: double.parse(currentBatch
                            .batchAttributes.latlong
                            .split(',')
                            .last));

                    if (isLocationValid) {
                      var isAttendanceMarked = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => MarkAttendence(
                            courseId: widget.course['identifier'],
                            sessionIds: sessionIdList,
                            batchId: widget.batchId,
                            onAttendanceMarked: () {},
                          ),
                        ),
                      );
                      if (isAttendanceMarked != null) {
                        if (isAttendanceMarked) {
                          await getSessionDetails();
                        }
                      }
                    } else {
                      showToastMessage(context,
                          title: AppLocalizations.of(context)
                              .mStaticInvalidBatchLocation,
                          message: AppLocalizations.of(context)
                              .mStaticInvalidBatchLocationDesc);
                    }
                  } catch (e) {
                    showToastMessage(context,
                        title:
                            AppLocalizations.of(context).mStaticInvalidLocation,
                        message: AppLocalizations.of(context)
                            .mStaticInvalidBatchLocationDesc);
                  }
                }
              },
            ),
          ),
        ));
  }
}

class SessionItem extends StatelessWidget {
  final SessionDetailV2 session;
  final bool showCompleted;
  const SessionItem({Key key, @required this.session, this.showCompleted})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    TimeOfDay startTime, endTime;
    try {
      startTime = Helper.getTimeIn24HourFormat(session.startTime);
    } on FormatException catch (e) {
      startTime = TimeOfDay(hour: 0, minute: 0);
    }

    String startHour = startTime.hour.toString().length < 2
        ? '0' + startTime.hour.toString()
        : startTime.hour.toString();
    String startMin = startTime.minute.toString().length < 2
        ? '0' + startTime.minute.toString()
        : startTime.minute.toString();
    String startTimeIn24HourFormat = startHour + ':' + startMin;
    try {
      endTime = Helper.getTimeIn24HourFormat(session.endTime);
    } on FormatException catch (e) {
      endTime = TimeOfDay(hour: 0, minute: 0);
    }
    String endHour = endTime.hour.toString().length < 2
        ? '0' + endTime.hour.toString()
        : endTime.hour.toString();
    String endMin = endTime.minute.toString().length < 2
        ? '0' + endTime.minute.toString()
        : endTime.minute.toString();
    String endTimeIn24HourFormat = endHour + ':' + endMin;

    return Container(
      margin: EdgeInsets.only(top: 8.0, bottom: 8),
      padding: EdgeInsets.only(top: 16.0, bottom: 16),
      color: AppColors.appBarBackground,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                  backgroundColor: AppColors.grey16,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.positiveLight,
                  ),
                  strokeWidth: 3,
                  value: showCompleted ? 100.0 : 0.0),
            ),
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.title,
                  style: GoogleFonts.lato(
                      height: 1.5,
                      decoration: TextDecoration.none,
                      color: AppColors.greys87,
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 4),
                Text(session.sessionType,
                    style: GoogleFonts.lato(
                        height: 1.5,
                        decoration: TextDecoration.none,
                        color: AppColors.greys87,
                        fontSize: 14,
                        fontWeight: FontWeight.w400)),
                SizedBox(height: 10),
                Row(
                  children: [
                    textWidget(Helper.getDateTimeInFormat(session.startDate)),
                    SizedBox(width: 5),
                    textWidget(session.sessionDuration),
                    SizedBox(width: 5),
                    textWidget(
                        '$startTimeIn24HourFormat - $endTimeIn24HourFormat'),
                  ],
                ),
                SizedBox(height: 8),
                Text(AppLocalizations.of(context).mStaticAttendenceStatus,
                    style: GoogleFonts.lato(
                        height: 1.5,
                        decoration: TextDecoration.none,
                        color: AppColors.greys87,
                        fontSize: 14,
                        fontWeight: FontWeight.w400)),
                SizedBox(height: 8),
                Container(
                  width: MediaQuery.of(context).size.width - 80,
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.shadeOne),
                    color: AppColors.shadeOne,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                            AppLocalizations.of(context)
                                .mStaticSessionStartAttendence,
                            style: GoogleFonts.lato(
                                height: 1.5,
                                decoration: TextDecoration.none,
                                color: AppColors.greys87,
                                fontSize: 10,
                                fontWeight: FontWeight.w400)),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: SvgPicture.asset(
                                showCompleted
                                    ? 'assets/img/approved.svg'
                                    : 'assets/img/attendance_mark.svg',
                                width: 20,
                                height: 20,
                              ),
                            ),
                            Text(
                                showCompleted
                                    ? AppLocalizations.of(context)
                                        .mStaticMarkedAttendence
                                    // ? '${EnglishLang.markedAttendence} @${session.markedAttendenceDate} ${session.markedAttendenceTime}'
                                    : AppLocalizations.of(context)
                                        .mStaticUnMarkedAttendence,
                                style: GoogleFonts.lato(
                                    height: 1.5,
                                    decoration: TextDecoration.none,
                                    color: AppColors.greys87,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400)),
                          ],
                        ),
                      ]),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget textWidget(String txt) {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey16),
        color: AppColors.appBarBackground,
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      child: Text(txt,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.lato(
              decoration: TextDecoration.none,
              color: AppColors.greys87,
              fontSize: 12,
              fontWeight: FontWeight.w400)),
    );
  }
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
