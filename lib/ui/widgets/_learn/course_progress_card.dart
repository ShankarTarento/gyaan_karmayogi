import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:karmayogi_mobile/ui/widgets/index.dart';
import 'package:karmayogi_mobile/util/share_certificate_helper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../constants/_constants/telemetry_constants.dart';
import '../../../constants/index.dart';
import '../../../models/_arguments/index.dart';
import '../../../models/index.dart';
import '../../../respositories/_respositories/learn_repository.dart';
import '../../../services/index.dart';
import '../../../util/helper.dart';
import '../../../util/telemetry.dart';
import '../../../util/telemetry_db_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../_buttons/animated_container.dart';

class CourseProgressCard extends StatefulWidget {
  final Course course;
  final List<Course> continueLearningCourse;
  final bool isMandatory;
  final bool isFeatured;
  final bool completed;
  final bool isFeaturedCourse;

  CourseProgressCard(this.course,
      {this.continueLearningCourse,
      this.isMandatory = false,
      this.isFeatured = false,
      this.completed,
      this.isFeaturedCourse = false});
  CourseProgressCardState createState() => CourseProgressCardState();
}

class CourseProgressCardState extends State<CourseProgressCard> {
  LearnService learnService = LearnService();
  LearnRepository learnRepository = LearnRepository();
  final TelemetryService telemetryService = TelemetryService();
  final service = HttpClient();
  int pageNo = 1;
  int pageCount;
  int currentPage;
  int _courseProgress;

  String userId;
  String userSessionId;
  String messageIdentifier;
  String departmentId;
  String deviceIdentifier, lastAccessContentId;
  var telemetryEventData;

  Future<List<Course>> futureCourse;

  List leafNodes = [];
  ValueNotifier<List> navigationItems = ValueNotifier([]);
  List<Batch> courseBatches = [];
  List _issuedCertificate;

  double progress = 0.0;
  double totalCourseProgress = 0;

  String _batchId;

  var courseInfo;
  var _base64CertificateImage;
  var certificateId;

  bool isBlendedProgram = false;
  bool isLoading = false;
  bool isLiveBlendedProgram = false;
  String courseName = '';
  ValueNotifier<bool> _isShareLoading = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    getTelemetryInfo();
    if (!widget.completed) {
      checkIsLiveBlendedProgram();
    }
    courseName = widget.course.raw['courseName'];
    if (widget.completed) {
      _issuedCertificate = widget.course.raw['issuedCertificates'];
      _courseProgress = widget.course.raw['completionPercentage'];
      _batchId = widget.course.raw['batchId'];
      certificateId = _issuedCertificate.length > 0
          ? (_issuedCertificate.length > 1
              ? _issuedCertificate[1]['identifier']
              : _issuedCertificate[0]['identifier'])
          : null;
    }
  }

  void getTelemetryInfo() async {
    deviceIdentifier = await Telemetry.getDeviceIdentifier();
    userId = await Telemetry.getUserId();
    userSessionId = await Telemetry.generateUserSessionId();
    messageIdentifier = await Telemetry.generateUserSessionId();
    departmentId = await Telemetry.getUserDeptId();
  }

  void _generateInteractTelemetryData(String contentId,
      {String subType = '', String primaryCategory, edataId}) async {
    Map eventData = Telemetry.getInteractTelemetryEvent(
        deviceIdentifier,
        userId,
        departmentId,
        TelemetryPageIdentifier.homePageId,
        userSessionId,
        messageIdentifier,
        contentId,
        subType,
        env: TelemetryEnv.home,
        objectType: primaryCategory != null ? primaryCategory : subType,
        clickId: edataId);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());
  }

  void checkIsLiveBlendedProgram() {
    if (widget.course.contentType == PrimaryCategory.blendedProgram) {
      bool isLive = checkCourseConsumptionAllowed(widget.course);
      if (isLive) {
        isLiveBlendedProgram = true;
      }
    }
  }

  bool checkCourseConsumptionAllowed(Course courseDetails) {
    if ((DateTime.parse(courseDetails.raw['batch']['startDate'])
                .isAfter(DateTime.now()) &&
            Helper.getDateTimeInFormat(
                    courseDetails.raw['batch']['startDate']) !=
                Helper.getDateTimeInFormat(DateTime.now().toString())) ||
        (DateTime.parse(courseDetails.raw['batch']['endDate'])
                .isBefore(DateTime.now()) &&
            Helper.getDateTimeInFormat(courseDetails.raw['batch']['endDate']) !=
                Helper.getDateTimeInFormat(DateTime.now().toString()))) {
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    var imageExtension;
    if (widget.course.appIcon != null) {
      imageExtension =
          widget.course.appIcon.substring(widget.course.appIcon.length - 3);
    }
    var imgExtension;
    if (widget.course.raw['content'] != null &&
        widget.course.raw['content']['posterImage'] != null) {
      imgExtension = widget.course.raw['content']['posterImage']
          .substring(widget.course.raw['content']['posterImage'].length - 3);
    }
    return InkWell(
      onTap: () async {
        _generateInteractTelemetryData(widget.course.raw['courseId'],
            primaryCategory: widget.course.contentType,
            subType: TelemetrySubType.myLearning,
            edataId: TelemetryIdentifier.cardContent);
        Navigator.pushNamed(context, AppUrl.courseTocPage,
            arguments: CourseTocModel.fromJson(
                {'courseId': widget.course.raw['courseId']}));
      },
      child: Wrap(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    PrimaryCategoryWidget(
                        contentType: widget.course.contentType,
                        addedMargin: true),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        ClipRRect(
                            child: widget.course.appIcon != null
                                ? ClipRRect(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                    child: imageExtension != 'svg'
                                        ? Image.network(
                                            widget.course.appIcon,
                                            // fit: BoxFit.cover,
                                            fit: BoxFit.fill,
                                            width: 107,
                                            height: 72,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Image.asset(
                                              'assets/img/image_placeholder.jpg',
                                              width: 107,
                                              height: 72,
                                              fit: BoxFit.fitWidth,
                                            ),
                                          )
                                        : Image.asset(
                                            'assets/img/image_placeholder.jpg',
                                            width: 107,
                                            height: 72,
                                            fit: BoxFit.fitWidth,
                                          ))
                                : widget.course.raw['content'] != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12)),
                                        child: widget.course.raw['content']
                                                    ['posterImage'] !=
                                                null
                                            ? imgExtension != 'svg'
                                                ? Image.network(
                                                    Helper.convertImageUrl(
                                                        widget.course
                                                                .raw['content']
                                                            ['posterImage']),
                                                    fit: BoxFit.fill,
                                                    width: 107,
                                                    height: 72,
                                                    errorBuilder: (context,
                                                            error,
                                                            stackTrace) =>
                                                        Image.asset(
                                                      'assets/img/image_placeholder.jpg',
                                                      width: 107,
                                                      height: 72,
                                                      fit: BoxFit.fitWidth,
                                                    ),
                                                  )
                                                : Image.asset(
                                                    'assets/img/image_placeholder.jpg',
                                                    width: 107,
                                                    height: 72,
                                                    fit: BoxFit.fitWidth,
                                                  )
                                            : Image.asset(
                                                'assets/img/image_placeholder.jpg',
                                                width: 107,
                                                height: 72,
                                                fit: BoxFit.fitWidth,
                                              ),
                                      )
                                    : Image.asset(
                                        'assets/img/image_placeholder.jpg',
                                        width: 107,
                                        height: 72,
                                        fit: BoxFit.fitWidth,
                                      )),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 16),
                                child: Container(
                                  height: 40,
                                  child: Text(
                                    widget.course.raw['courseName'],
                                    style: GoogleFonts.lato(
                                        color: AppColors.greys87,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        letterSpacing: 0.25,
                                        height: 1.429),
                                    softWrap: false,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ),
                              ),
                              //Source
                              Row(
                                children: [
                                  (widget.course.creatorIcon != null &&
                                          !widget.isFeatured)
                                      ? Container(
                                          margin: EdgeInsets.only(top: 8),
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(
                                                  color: AppColors.grey16,
                                                  width: 1),
                                              borderRadius: BorderRadius.all(
                                                  const Radius.circular(4.0))),
                                          child: Container(
                                            height: 16,
                                            width: 17,
                                            margin: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                  image: NetworkImage(widget
                                                      .course.creatorIcon),
                                                  fit: BoxFit.fitWidth),
                                            ),
                                          ),
                                        )
                                      : !widget.isFeatured
                                          ? Container(
                                              margin: EdgeInsets.only(
                                                  top: 6, left: 16),
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(
                                                      color: AppColors.grey16,
                                                      width: 1),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          const Radius.circular(
                                                              4.0))),
                                              child: Container(
                                                height: 16,
                                                width: 17,
                                                margin: EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                    image: widget.course
                                                                .creatorLogo !=
                                                            ''
                                                        ? NetworkImage(widget
                                                            .course.creatorLogo)
                                                        : AssetImage(
                                                            'assets/img/igot_creator_icon.png'),
                                                  ),
                                                ),
                                              ),
                                            )
                                          : SizedBox.shrink(),
                                  Expanded(
                                    child: Container(
                                      alignment: Alignment.topLeft,
                                      padding:
                                          EdgeInsets.only(left: 16, right: 16),
                                      child: Text(
                                        widget.course.source != null
                                            ? widget.course.source != ''
                                                ? '${AppLocalizations.of(context).mCommonBy} ' +
                                                    widget.course.source
                                                : ''
                                            : '',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.lato(
                                          color: AppColors.greys60,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12.0,
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                            ],
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 4),
                    Visibility(
                      visible: widget.completed,
                      child: Row(
                        children: [
                          Icon(
                            Icons.check,
                            size: 20,
                            color: AppColors.positiveLight,
                          ),
                          Text(
                            AppLocalizations.of(context).mStaticCompleted,
                            style: GoogleFonts.lato(
                              color: AppColors.positiveLight,
                              fontWeight: FontWeight.w700,
                              fontSize: 14.0,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(top: widget.completed ? 0 : 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Visibility(
                        visible: !widget.completed,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.35,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 32,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 32,
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Row(
                                          children: [
                                            SvgPicture.asset(
                                              'assets/img/time_active.svg',
                                              width: 20.0,
                                              height: 20.0,
                                            ),
                                            widget.course.duration != null
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 4),
                                                    child: widget.course
                                                                .duration !=
                                                            null
                                                        ? Text(
                                                            getRemainingTime(
                                                                widget.course
                                                                    .duration,
                                                                widget.course
                                                                        .raw[
                                                                    'completionPercentage']),
                                                            style: GoogleFonts
                                                                .lato(
                                                              color: AppColors
                                                                  .greys87,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontSize: 12.0,
                                                            ),
                                                          )
                                                        : Text(''),
                                                  )
                                                : Center(),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.4,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: LinearProgressIndicator(
                                    minHeight: 4,
                                    backgroundColor: AppColors.grey16,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.verifiedBadgeIconColor,
                                    ),
                                    value: widget.course
                                            .raw['completionPercentage'] /
                                        100,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Visibility(
                                  visible: widget.completed,
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.395,
                                    child: ValueListenableBuilder(
                                        valueListenable: _isShareLoading,
                                        builder: (BuildContext context,
                                            bool isShareLoading, Widget child) {
                                          return ButtonClickEffect(
                                            onTap: () => isShareLoading
                                                ? null
                                                : _shareCertificate(),
                                            child: isShareLoading
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: PageLoader(),
                                                  )
                                                : Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                              AppLocalizations
                                                                      .of(
                                                                          context)
                                                                  .mHomeProfileCardCertificate,
                                                              style: GoogleFonts.lato(
                                                                  color: AppColors
                                                                      .avatarText,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  fontSize: 14,
                                                                  letterSpacing:
                                                                      0.5)),
                                                          Text(
                                                              AppLocalizations
                                                                      .of(
                                                                          context)
                                                                  .mStaticShare,
                                                              style: GoogleFonts.lato(
                                                                  color: AppColors
                                                                      .avatarText,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  fontSize: 10,
                                                                  letterSpacing:
                                                                      0.5)),
                                                        ],
                                                      ),
                                                      SizedBox(width: 10),
                                                      Icon(
                                                        Icons.share,
                                                        color: AppColors
                                                            .avatarText,
                                                        size: 24,
                                                      )
                                                    ],
                                                  ),
                                          );
                                        }),
                                  )),
                              Visibility(
                                  visible: widget.completed,
                                  child: SizedBox(width: 8)),
                              SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.395,
                                child: ButtonClickEffect(
                                  onTap: (widget.course.contentType ==
                                              PrimaryCategory.blendedProgram &&
                                          !isLiveBlendedProgram &&
                                          !widget.completed)
                                      ? null
                                      : () async {
                                          if (isLoading) return;
                                          setState(() {
                                            isLoading = true;
                                          });
                                          if (widget.completed) {
                                            _generateInteractTelemetryData(
                                                certificateId,
                                                edataId: TelemetryIdentifier
                                                    .downloadCertificate,
                                                subType: TelemetrySubType
                                                    .certificate);
                                            if (_batchId != null &&
                                                _courseProgress == 100) {
                                              if (certificateId != null) {
                                                await _getCompletionCertificate();
                                                await _saveAsPdf(context);
                                              }
                                            }
                                          } else {
                                            _generateInteractTelemetryData(
                                                widget.course.raw['contentId'],
                                                subType:
                                                    TelemetrySubType.myLearning,
                                                primaryCategory: widget.course
                                                    .raw['primaryCategory']);
                                            Navigator.pushNamed(
                                                context, AppUrl.courseTocPage,
                                                arguments:
                                                    CourseTocModel.fromJson({
                                                  'courseId': widget
                                                      .course.raw['courseId']
                                                }));
                                          }
                                          setState(() {
                                            isLoading = false;
                                          });
                                        },
                                  opacity: (widget.course.contentType ==
                                                  PrimaryCategory
                                                      .blendedProgram &&
                                              isLiveBlendedProgram &&
                                              !widget.completed) ||
                                          widget.course.contentType !=
                                              PrimaryCategory.blendedProgram ||
                                          widget.completed
                                      ? 1.0
                                      : 0.7,
                                  child: isLoading
                                      ? Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: PageLoader(),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            widget.completed
                                                ? Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                          AppLocalizations.of(
                                                                  context)
                                                              .mStaticCertificates,
                                                          style: GoogleFonts.lato(
                                                              color: AppColors
                                                                  .avatarText,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              fontSize: 14,
                                                              letterSpacing:
                                                                  0.5)),
                                                      Text(
                                                          AppLocalizations.of(
                                                                  context)
                                                              .mDownload,
                                                          style: GoogleFonts.lato(
                                                              color: AppColors
                                                                  .avatarText,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              fontSize: 11,
                                                              letterSpacing:
                                                                  0.5)),
                                                    ],
                                                  )
                                                : Text(
                                                    widget.course.raw[
                                                                'completionPercentage'] ==
                                                            0
                                                        ? Helper()
                                                            .capitalizeFirstCharacter(
                                                                AppLocalizations.of(
                                                                        context)
                                                                    .mLearnStart)
                                                        : Helper().capitalizeFirstCharacter(
                                                            AppLocalizations
                                                                    .of(context)
                                                                .mStaticResume),
                                                    style: GoogleFonts.lato(
                                                        color: AppColors
                                                            .avatarText,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: 14,
                                                        letterSpacing: 0.5)),
                                            SizedBox(width: 10),
                                            widget.completed
                                                ? Icon(
                                                    Icons.arrow_downward_sharp,
                                                    color: AppColors.avatarText,
                                                    size: 24,
                                                  )
                                                : Icon(
                                                    Icons.play_circle_fill,
                                                    color: AppColors.avatarText,
                                                    size: 24,
                                                  )
                                          ],
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  String getRemainingTime(duration, completionPercentage) {
    if (completionPercentage != 0) {
      int totalDuration = int.parse(widget.course.duration);
      return getTimeFormat(
              ((totalDuration - ((completionPercentage * totalDuration) / 100))
                      .toInt())
                  .toString()) +
          ' to go';
    } else {
      return getTimeFormat(duration) + ' to go';
    }
  }

  static getTimeFormat(duration) {
    int hours = Duration(seconds: int.parse(duration)).inHours;
    int minutes = Duration(seconds: int.parse(duration)).inMinutes;
    String time;
    if (hours > 0) {
      time =
          hours.toString() + 'hrs ' + (minutes - hours * 60).toString() + 'm';
    } else {
      time = minutes.toString() + ' min';
    }
    return time;
  }

  Future<void> _saveAsPdf(BuildContext parentContext) async {
    String nameOfCourse = courseName;
    nameOfCourse = nameOfCourse.replaceAll(RegExp(r'[^\w\s]'), '');
    if (nameOfCourse.length > 20) {
      nameOfCourse = nameOfCourse..substring(0, 20);
    }
    String fileName =
        '$nameOfCourse-' + DateTime.now().millisecondsSinceEpoch.toString();

    String path = await Helper.getDownloadPath();
    await Directory('$path').create(recursive: true);

    try {
      Permission _permision = Permission.storage;
      if (Platform.isAndroid) {
        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        if (androidInfo.version.sdkInt >= 33) {
          _permision = Permission.photos;
        }
      }

      if (await Helper.requestPermission(_permision)) {
        final certificate = await learnService
            .downloadCompletionCertificate(_base64CertificateImage);

        await File('$path/$fileName.pdf').writeAsBytes(certificate);

        _displayDialog(parentContext, true, '$path/$fileName.pdf', 'Success');
      } else {
        return false;
      }
    } catch (e) {
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<dynamic> _getCompletionCertificate() async {
    final certificate =
        await learnService.getCourseCompletionCertificate(certificateId);

    setState(() {
      _base64CertificateImage = certificate;
    });
    return _base64CertificateImage;
  }

  bool isValidBatch(var enrollmentEndDate) {
    var dateDiff = enrollmentEndDate.difference(DateTime.now()).inDays;
    return dateDiff >= 0;
  }

  Future<bool> _displayDialog(BuildContext parentContext, bool isSuccess,
      String filePath, String message) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (cntxt) => Stack(
              children: [
                Positioned(
                    child: Align(
                        // alignment: FractionalOffset.center,
                        alignment: FractionalOffset.bottomCenter,
                        child: Container(
                          padding: EdgeInsets.all(20),
                          // margin: EdgeInsets.only(left: 20, right: 20),
                          width: double.infinity,
                          height: filePath != '' ? 190.0 : 140,
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                  padding:
                                      const EdgeInsets.only(top: 5, bottom: 15),
                                  child: Text(
                                    isSuccess
                                        ? AppLocalizations.of(parentContext)
                                            .mStaticFileDownloadingCompleted
                                        : message,
                                    style: GoogleFonts.montserrat(
                                        decoration: TextDecoration.none,
                                        color: Colors.black87,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400),
                                  )),
                              filePath != ''
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          top: 5, bottom: 10),
                                      child: GestureDetector(
                                        onTap: () => _openFile(filePath),
                                        child: roundedButton(
                                          AppLocalizations.of(parentContext)
                                              .mStaticOpen,
                                          AppColors.primaryThree,
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : Center(),
                              // Spacer(),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 5, bottom: 15),
                                child: GestureDetector(
                                  onTap: () => Navigator.of(cntxt).pop(false),
                                  child: roundedButton(
                                      AppLocalizations.of(parentContext)
                                          .mCommonClose,
                                      Colors.white,
                                      AppColors.primaryThree),
                                ),
                              ),
                            ],
                          ),
                        )))
              ],
            ));
  }

  Widget roundedButton(String buttonLabel, Color bgColor, Color textColor) {
    var loginBtn = Container(
      // width: MediaQuery.of(context).size.width - 50,
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
            fontWeight: FontWeight.w500),
      ),
    );
    return loginBtn;
  }

  Future<dynamic> _openFile(filePath) async {
    await OpenFile.open(filePath);
  }

  Future<void> _shareCertificate() async {
    _generateInteractTelemetryData(certificateId,
        subType: TelemetrySubType.certificate,
        edataId: TelemetryIdentifier.shareCertificate);
    if (Platform.isIOS) {
      ShareCertificateHelper.showPopupToSelectSharePlatforms(
        context: context,
        onLinkedinTap: () {
          Helper.doLaunchUrl(
              url: Helper.getLinkedlnUrlToShareCertificate(certificateId),
              mode: LaunchMode.externalApplication);
        },
        onOtherAppsTap: () async {
          await _sharePdfCertificate();
        },
      );
    } else {
      try {
        _isShareLoading.value = true;
        await _sharePdfCertificate();
      } catch (e) {
        _isShareLoading.value = false;
      } finally {
        _isShareLoading.value = false;
      }
    }
  }

  Future<void> _sharePdfCertificate() async {
    String nameOfCourse = courseName;
    nameOfCourse = nameOfCourse.replaceAll(RegExp(r'[^\w\s]'), '');
    if (nameOfCourse.length > 20) {
      nameOfCourse = nameOfCourse..substring(0, 20);
    }
    String fileName =
        '$nameOfCourse-' + DateTime.now().millisecondsSinceEpoch.toString();
    String path = await Helper.getDownloadPath();
    String outputFormat = CertificateType.png;
    await Directory('$path').create(recursive: true);

    Permission _permision = Permission.storage;
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        _permision = Permission.photos;
      }
    }

    if (await Helper.requestPermission(_permision)) {
      if (certificateId != null) {
        await _getCompletionCertificate();
        final certificate = await learnService.downloadCompletionCertificate(
            _base64CertificateImage,
            outputType: outputFormat);

        await File('$path/$fileName.' + outputFormat).writeAsBytes(certificate);

        await Share.shareXFiles([
          XFile('$path/$fileName.' + outputFormat, mimeType: EMimeTypes.png)
        ], text: "Certificate of completion");
      }
    } else {
      return false;
    }
  }
}
