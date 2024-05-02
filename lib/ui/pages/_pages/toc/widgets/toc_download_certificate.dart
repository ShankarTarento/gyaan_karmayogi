import 'dart:convert';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../../constants/_constants/storage_constants.dart';
import '../../../../../constants/index.dart';
import '../../../../../models/index.dart';
import '../../../../../services/index.dart';
import '../../../../../util/helper.dart';
import '../../../../widgets/index.dart';
import '../../../index.dart';

class TocDownloadCertificateWidget extends StatefulWidget {
  TocDownloadCertificateWidget(
      {Key key,
      @required this.courseId,
      this.isPlayer = false,
      this.isExpanded = false})
      : super(key: key);
  final String courseId;
  final bool isPlayer, isExpanded;

  @override
  State<TocDownloadCertificateWidget> createState() =>
      _TocDownloadCertificateWidgetState();
}

class _TocDownloadCertificateWidgetState
    extends State<TocDownloadCertificateWidget> {
  bool isDownloadingToSave = false;
  Course enrolledCourse;
  var base64CertificateImage;
  final _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getEnrolledCourse(widget.courseId),
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data != null &&
                base64CertificateImage != null &&
                base64CertificateImage != '') {
              return TextButton(
                onPressed: () async {
                  saveAsPdf();
                },
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      color: widget.isExpanded 
                          ? AppColors.appBarBackground
                          : AppColors.darkBlue),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: isDownloadingToSave
                      ? SizedBox(height: 20, width: 60, child: PageLoader())
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              AppLocalizations.of(context).mStaticCertificates,
                              style: GoogleFonts.lato(
                                  height: 1.333,
                                  decoration: TextDecoration.none,
                                  color: widget.isExpanded
                                      ? AppColors.darkBlue
                                      : AppColors.appBarBackground,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.25),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.arrow_downward,
                              size: 16,
                              color: widget.isExpanded
                                  ? AppColors.darkBlue
                                  : AppColors.appBarBackground,
                            )
                          ],
                        ),
                ),
              );
            } else {
              return LinearProgressIndicatorWidget(
                  value: 1, isExpnaded: widget.isExpanded, isCourse: true);
            }
          } else {
            return Center();
          }
        });
  }

  Future<bool> displayDialog(
      bool isSuccess, String filePath, String message) async {
    return showModalBottomSheet(
        isScrollControlled: true,
        // useSafeArea: true,
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
                    // Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(top: 5, bottom: 15),
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(false),
                        child: roundedButton(
                            AppLocalizations.of(context).mCommonClose,
                            Colors.white,
                            AppColors.darkBlue),
                      ),
                    ),
                  ],
                ),
              ),
            ));
  }

  Future<void> saveAsPdf() async {
    String cname =
        enrolledCourse.raw['courseName'].replaceAll(RegExp(r'[^\w\s]'), '');
    String fileName =
        '$cname-' + DateTime.now().millisecondsSinceEpoch.toString();

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
            .downloadCompletionCertificate(base64CertificateImage);

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

  Future<dynamic> getCompletionCertificate() async {
    if (enrolledCourse != null) {
      List issuedCertificate = enrolledCourse.raw['issuedCertificates'];
      if (mounted) {
        if (enrolledCourse.raw['batchId'] != null) {
          final certificateId = issuedCertificate.length > 0
              ? (issuedCertificate.length > 1
                  ? issuedCertificate[1]['identifier']
                  : issuedCertificate[0]['identifier'])
              : null;
          if (certificateId != null) {
            final certificate = await LearnService()
                .getCourseCompletionCertificate(certificateId);

            setState(() {
              base64CertificateImage = certificate;
            });
          } else {
            base64CertificateImage = '';
          }
        }
      }
    }
    return base64CertificateImage;
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

  // get enrolment info from local storage
  Future<dynamic> getEnrolledCourse(courseId) async {
    List enrolList = [];
    String responseData = await _storage.read(key: Storage.enrolmentList);
    enrolList = jsonDecode(responseData);
    List<Course> enrolmentList = enrolList
        .map(
          (dynamic item) => Course.fromJson(item),
        )
        .toList();
    enrolledCourse = enrolmentList.firstWhere(
      (element) => element.raw['courseId'] == courseId,
      orElse: () => null,
    );
    if (enrolledCourse != null) {
      await getCompletionCertificate();
    }
    return enrolledCourse;
  }
}
