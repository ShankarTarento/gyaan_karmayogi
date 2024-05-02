import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/services/index.dart';
import 'package:karmayogi_mobile/ui/widgets/index.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../models/_arguments/index.dart';
import '../../../models/_models/competency_data_model.dart';
import '../../../util/helper.dart';
import '../../skeleton/index.dart';

class CompetencyPassbookCertificateCard extends StatefulWidget {
  final CourseData courseInfo;
  final String certificate;
  final bool isCertificateProvided;
  const CompetencyPassbookCertificateCard(
      {Key key,
      @required this.courseInfo,
      this.certificate,
      this.isCertificateProvided = false})
      : super(key: key);

  @override
  State<CompetencyPassbookCertificateCard> createState() =>
      _CompetencyPassbookCertificateCardState();
}

class _CompetencyPassbookCertificateCardState
    extends State<CompetencyPassbookCertificateCard> {
  final double leftPadding = 20.0;
  bool isDownloadingToSave = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, AppUrl.courseTocPage,
              arguments: CourseTocModel.fromJson(
                  {'courseId': widget.courseInfo.courseId}));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipPath(
              clipper: BottomCornerClipper(),
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: AppColors.appBarBackground,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12)),
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(16),
                  decoration: DottedDecoration(
                    strokeWidth: 2,
                    shape: Shape.line,
                    linePosition: LinePosition.bottom,
                    color: AppColors.grey16,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.65,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TitleBoldWidget(
                                  widget.courseInfo.courseName,
                                  maxLines: 2,
                                ),
                                widget.courseInfo.completedOn != null
                                    ? SizedBox(height: 4)
                                    : SizedBox.shrink(),
                                widget.courseInfo.completedOn != null
                                    ? TitleRegularGrey60(
                                        '${AppLocalizations.of(context).mProfileIssuedOn} ${Helper.getDateTimeInFormat(widget.courseInfo.completedOn, desiredDateFormat: 'MMM yyyy')}')
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
                                      padding: EdgeInsets.only(right: 0),
                                      alignment: Alignment.centerRight,
                                      onPressed: () async {
                                        _saveAsPdf(
                                            widget.courseInfo.courseName);
                                      },
                                      icon: Icon(
                                        Icons.arrow_downward,
                                        color: AppColors.darkBlue,
                                        size: 24,
                                      ))
                        ],
                      ),
                      SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        height: 210,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8)),
                        child: widget.certificate != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: WebView(
                                  initialUrl:
                                      Uri.parse(widget.certificate).toString(),
                                  javascriptMode: JavascriptMode.unrestricted,
                                ))
                            : widget.isCertificateProvided
                                ? CardSkeletonPage(
                                    height: 120,
                                    width:
                                        MediaQuery.of(context).size.width * 0.8)
                                : Stack(
                                    children: [
                                      Image.asset(
                                        'assets/img/default_certificate.png',
                                        alignment: Alignment.center,
                                        height: 170,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        fit: BoxFit.cover,
                                      ),
                                      Container(
                                        height: 170,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        padding: EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: AppColors.greys60
                                              .withOpacity(0.8),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Center(
                                          child: Text(
                                            AppLocalizations.of(context)
                                                .mCompetencyCertificateGeneration,
                                            style: GoogleFonts.lato(
                                                color:
                                                    AppColors.appBarBackground,
                                                fontWeight: FontWeight.w600,
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
            ClipPath(
              clipper: TopCornerClipper(),
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: AppColors.appBarBackground,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12))),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 16),
                    child: CompetencyPassbookSubtheme(
                        competencySubthemes: widget.courseInfo.courseSubthemes),
                  )),
            ),
          ],
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

        final certificate = await LearnService()
            .downloadCompletionCertificate(widget.certificate);

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
                        child: roundedButton(AppLocalizations.of(context).mStaticClose,
                            Colors.white, AppColors.darkBlue),
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
}
