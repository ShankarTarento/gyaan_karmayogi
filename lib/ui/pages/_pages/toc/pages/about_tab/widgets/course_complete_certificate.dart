import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:device_info/device_info.dart';
import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/models/index.dart';
import 'package:karmayogi_mobile/services/index.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/about_tab/widgets/certificate_competency_subtheme.dart';
import 'package:karmayogi_mobile/ui/skeleton/pages/card_skeleton.dart';
import 'package:karmayogi_mobile/ui/widgets/index.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:karmayogi_mobile/util/telemetry.dart';
import 'package:karmayogi_mobile/util/telemetry_db_helper.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CourseCompleteCertificate extends StatefulWidget {
  final Course courseInfo;
  final List<CompetencyPassbook> competencies;
  final String certificate;
  final bool isCertificateProvided;
  const CourseCompleteCertificate(
      {Key key,
      @required this.courseInfo,
      this.certificate,
      this.competencies,
      this.isCertificateProvided = false})
      : super(key: key);

  @override
  State<CourseCompleteCertificate> createState() =>
      _CourseCompleteCertificateState();
}

class _CourseCompleteCertificateState extends State<CourseCompleteCertificate> {
  final double leftPadding = 20.0;
  bool isDownloadingToSave = false;
  WebViewController _webViewController;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: EdgeInsets.only(top: 20, bottom: 16),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/img/certificate_background.png'),
              fit: BoxFit.fill, // or BoxFit.fill, BoxFit.contain, etc.
            ),
          ),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 66.0, bottom: 36),
                  child: Text(
                    AppLocalizations.of(context).mStaticCertificateEarned,
                    style: GoogleFonts.lato(
                        color: AppColors.darkBlue,
                        fontWeight: FontWeight.w600,
                        fontSize: 20),
                  ),
                ),
                ClipPath(
                  clipper: TocBottomCornerClipper(),
                  child: Container(
                    margin: const EdgeInsets.only(left: 35.0, right: 35),
                    padding:
                        EdgeInsets.only(top: 1, left: 1, right: 1, bottom: 0),
                    decoration: BoxDecoration(
                      color: AppColors.grey16,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(9),
                        topRight: Radius.circular(9),
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                    child: ClipPath(
                      clipper: TocBottomCornerClipper(),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(9),
                              topRight: Radius.circular(9),
                            ),
                            color: AppColors.appBarBackground),
                        child: ClipPath(
                          clipper: TocBottomCornerClipper(),
                          child: Container(
                            margin: EdgeInsets.only(left: 6, right: 6),
                            padding: EdgeInsets.all(16),
                            decoration: DottedDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(9),
                                topRight: Radius.circular(9),
                              ),
                              strokeWidth: 2,
                              shape: Shape.line,
                              linePosition: LinePosition.bottom,
                              color: AppColors.grey16,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width /
                                          2.1,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.courseInfo.raw["courseName"],
                                            maxLines: 2,
                                            style: GoogleFonts.lato(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 12),
                                          ),
                                          widget.courseInfo.completedOn != null
                                              ? SizedBox(height: 4)
                                              : SizedBox.shrink(),
                                          widget.courseInfo.completedOn != null
                                              ? Text(
                                                  '${AppLocalizations.of(context).mStaticYouCompletedThisCourseOn} ${Helper.getDateTimeInFormat("${DateTime.fromMillisecondsSinceEpoch(widget.courseInfo.completedOn)}", desiredDateFormat: IntentType.dateFormat2)}',
                                                  style: GoogleFonts.lato(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.w400,
                                                    color: AppColors.greys60,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                )
                                              : SizedBox.shrink()
                                        ],
                                      ),
                                    ),
                                    widget.courseInfo.completedOn == null
                                        ? SizedBox.shrink()
                                        : isDownloadingToSave
                                            ? SizedBox(
                                                height: 20,
                                                width: 20,
                                                child: PageLoader())
                                            : IconButton(
                                                padding:
                                                    EdgeInsets.only(right: 0),
                                                alignment:
                                                    Alignment.centerRight,
                                                onPressed: () async {
                                                  _generateInteractTelemetryData(
                                                      widget.courseInfo.raw[
                                                              "issuedCertificates"]
                                                          [0]["identifier"],
                                                      edataId: TelemetryIdentifier
                                                          .downloadCertificate,
                                                      subType: TelemetrySubType
                                                          .certificate);
                                                  _saveAsPdf(widget.courseInfo
                                                      .raw["courseName"]);
                                                },
                                                icon: Icon(
                                                  Icons.arrow_downward,
                                                  color: AppColors.darkBlue,
                                                  size: 24,
                                                ),
                                              )
                                  ],
                                ),
                                SizedBox(height: 10),
                                Container(
                                  width: 212,
                                  height: 100,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8)),
                                  child: widget.certificate != null
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: WebView(
                                            onWebViewCreated: (controller) {
                                              _webViewController = controller;
                                            },
                                            onPageFinished: (url) {
                                              double imageWidth =
                                                  MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      2;

                                              _webViewController
                                                  .evaluateJavascript(
                                                'document.querySelector("svg").setAttribute("width", "$imageWidth");'
                                                'document.querySelector("svg").setAttribute("height", "500px");',
                                              );
                                            },
                                            zoomEnabled: false,
                                            initialUrl:
                                                Uri.parse(widget.certificate)
                                                    .toString(),
                                            javascriptMode:
                                                JavascriptMode.unrestricted,
                                          ),
                                        )
                                      : widget.isCertificateProvided
                                          ? CardSkeletonPage(
                                              height: 100,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.8)
                                          : Stack(
                                              children: [
                                                Image.asset(
                                                  'assets/img/default_certificate.png',
                                                  alignment: Alignment.center,
                                                  height: 100,
                                                  width: 214,
                                                  fit: BoxFit.cover,
                                                ),
                                                Container(
                                                  height: 100,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      1.5,
                                                  padding: EdgeInsets.all(16),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.greys60
                                                        .withOpacity(0.8),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      AppLocalizations.of(
                                                              context)
                                                          .mStaticWaitingForCertificateGeneration,
                                                      style: GoogleFonts.lato(
                                                          color: AppColors
                                                              .appBarBackground,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 12,
                                                          letterSpacing: 0.25,
                                                          height: 1.5),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                ClipPath(
                  clipper: TocTopCornerClipper(),
                  child: Container(
                    margin: const EdgeInsets.only(left: 35.0, right: 35),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(9),
                        bottomRight: Radius.circular(9),
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                      color: AppColors.grey16,
                    ),
                    padding:
                        EdgeInsets.only(top: 0, left: 1, right: 1, bottom: 1),
                    child: ClipPath(
                      clipper: TocTopCornerClipper(),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(9),
                            bottomRight: Radius.circular(9),
                            topLeft: Radius.circular(5),
                            topRight: Radius.circular(5),
                          ),
                        ),
                        child: CertificateCompetencySubtheme(
                            competencySubthemes: widget.competencies),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveAsPdf(String courseName) async {
    String fileName =
        '$courseName-' + DateTime.now().millisecondsSinceEpoch.toString();

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
        setState(() {
          isDownloadingToSave = true;
        });

        final certificate = await LearnService().downloadCompletionCertificate(
            widget.certificate,
            outputType: CertificateType.pdf);

        await File('$path/$fileName.pdf').writeAsBytes(certificate);

        setState(() {
          isDownloadingToSave = false;
        });
        displayDialog(true, '$path/$fileName.pdf', 'Success');
      } else {
        return false;
      }
    } catch (e) {
      setState(() {
        isDownloadingToSave = false;
      });
    } finally {
      setState(() {
        isDownloadingToSave = false;
      });
    }
  }

  Future<bool> displayDialog(
      bool isSuccess, String filePath, String message) async {
    return showModalBottomSheet(
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8), topRight: Radius.circular(8)),
          side: BorderSide(
            color: AppColors.grey08,
          ),
        ),
        context: context,
        builder: (context) => SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        margin: EdgeInsets.only(bottom: 20),
                        height: 6,
                        width: MediaQuery.of(context).size.width * 0.25,
                        decoration: BoxDecoration(
                          color: AppColors.grey16,
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(top: 5, bottom: 15),
                        child: Text(
                          isSuccess
                              ? AppLocalizations.of(context)
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
                            padding: const EdgeInsets.only(top: 5, bottom: 10),
                            child: GestureDetector(
                              onTap: () => openFile(filePath),
                              child: roundedButton(
                                AppLocalizations.of(context).mStaticOpen,
                                AppColors.darkBlue,
                                Colors.white,
                              ),
                            ),
                          )
                        : Center(),
                    Padding(
                      padding: const EdgeInsets.only(top: 5, bottom: 15),
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(false),
                        child: roundedButton(
                            AppLocalizations.of(context).mStaticClose,
                            Colors.white,
                            AppColors.darkBlue),
                      ),
                    ),
                  ],
                ),
              ),
            ));
  }

  Future<dynamic> openFile(filePath) async {
    await OpenFile.open(filePath);
  }

  Widget roundedButton(String buttonLabel, Color bgColor, Color textColor) {
    var loginBtn = Container(
      width: MediaQuery.of(context).size.width - 50,
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

  void _generateInteractTelemetryData(String contentId,
      {String subType = '', edataId}) async {
    String deviceIdentifier = await Telemetry.getDeviceIdentifier();
    String userId = await Telemetry.getUserId();
    String userSessionId = await Telemetry.generateUserSessionId();
    String messageIdentifier = await Telemetry.generateUserSessionId();
    String departmentId = await Telemetry.getUserDeptId();
    var telemetryEventData;
    Map eventData = Telemetry.getInteractTelemetryEvent(
        deviceIdentifier,
        userId,
        departmentId,
        (TelemetryPageIdentifier.courseDetailsPageId +
            '_' +
            widget.courseInfo.raw["courseId"]),
        userSessionId,
        messageIdentifier,
        contentId,
        subType,
        env: TelemetryEnv.learn,
        objectType: subType,
        clickId: edataId);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());
  }
}
