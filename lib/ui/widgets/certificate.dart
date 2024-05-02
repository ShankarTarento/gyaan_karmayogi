import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/services/index.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../constants/_constants/color_constants.dart';
import '../../feedback/widgets/_microSurvey/page_loader.dart';
import '../../localization/index.dart';
import '../../respositories/_respositories/learn_repository.dart';
import '../../util/helper.dart';

class CertificateWidget extends StatefulWidget {
  final String courseId;
  CertificateWidget({this.courseId});

  @override
  _CertificateWidgetState createState() => _CertificateWidgetState();
}

class _CertificateWidgetState extends State<CertificateWidget> {
  LearnService learnService = LearnService();
  bool showCertificate = false;
  var _base64CertificateImage;
  var courseDetails;
  bool _isDownloadingToSave = false;
  bool _isDownloadingCertToShare = false;

  @override
  void initState() {
    super.initState();
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

  Widget showCertificateWidget() {
    return _base64CertificateImage != null
        ? _base64CertificateImage != ''
            ? Container(
                margin: EdgeInsets.only(top: 8),
                // height: 193,
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 210,
                      child: ClipRRect(
                          child: WebView(
                        initialUrl:
                            Uri.parse(_base64CertificateImage).toString(),
                        javascriptMode: JavascriptMode.unrestricted,
                      )),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.20,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: AppColors.primaryThree, backgroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(40), // NEW
                              side: BorderSide(
                                  width: 1, color: AppColors.primaryThree),
                            ),
                            onPressed: () async {
                              _isDownloadingCertToShare
                                  ? null
                                  : await _sharePdfCertificate(
                                      courseDetails.raw['description'] ?? '');
                            },
                            child: _isDownloadingCertToShare
                                ? SizedBox(
                                    height: 20, width: 20, child: PageLoader())
                                : Text(
                                    AppLocalizations.of(context).mStaticShare,
                                    style: GoogleFonts.lato(
                                        height: 1.429,
                                        letterSpacing: 0.5,
                                        fontSize: 14,
                                        color: AppColors.primaryThree,
                                        fontWeight: FontWeight.w700),
                                  ),
                          ),
                        ),
                        SizedBox(width: 5),
                        Expanded(
                          child: Container(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: AppColors.primaryThree,
                                minimumSize: const Size.fromHeight(40), // NEW
                                side: BorderSide(
                                    width: 1, color: AppColors.primaryThree),
                              ),
                              onPressed: () async {
                                _saveAsPdf(courseDetails.raw['courseName']);
                              },
                              child: _isDownloadingToSave
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: PageLoader())
                                  : Text(
                                      AppLocalizations.of(context)
                                          .mCommonDownloadCertificate,
                                      style: GoogleFonts.lato(
                                          height: 1.429,
                                          letterSpacing: 0.5,
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            : (_base64CertificateImage == null || _base64CertificateImage == '')
                ? Container(
                    padding: EdgeInsets.all(16),
                    color: Colors.white,
                    child: Text(
                        AppLocalizations.of(context).mCertificateNotIssuedBy,
                        style: GoogleFonts.lato(
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.12,
                            height: 1.5,
                            color: AppColors.greys87)),
                  )
                : SizedBox.shrink()
        : SizedBox.shrink();
  }

  Future<bool> _displayDialog(
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
                              onTap: () => _openFile(filePath),
                              child: roundedButton(
                                AppLocalizations.of(context).mStaticOpen,
                                AppColors.primaryThree,
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
                            AppLocalizations.of(context).mStaticClose,
                            Colors.white,
                            AppColors.primaryThree),
                      ),
                    ),
                  ],
                ),
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getEnrollmentList(widget.courseId),
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            return showCertificateWidget();
          } else {
            return SizedBox.shrink();
          }
        });
  }

  Future<dynamic> _getCompletionCertificate() async {
    if (courseDetails != null) {
      List issuedCertificate = courseDetails.raw['issuedCertificates'];
      if (mounted) {
        if (courseDetails.raw['batchId'] != null) {
          final certificateId = issuedCertificate.length > 0
              ? (issuedCertificate.length > 1
                  ? issuedCertificate[1]['identifier']
                  : issuedCertificate[0]['identifier'])
              : null;
          if (certificateId != null) {
            final certificate = await learnService
                .getCourseCompletionCertificate(certificateId);

            setState(() {
              _base64CertificateImage = certificate;
            });
          } else {
            _base64CertificateImage = '';
          }
        }
      }
    }
    return _base64CertificateImage;
  }

  Future<dynamic> _getEnrollmentList(courseId) async {
    if (mounted) {
      //Call api to get enrolled courses
      var _continueLearningcourses =
          await Provider.of<LearnRepository>(context, listen: false)
              .getContinueLearningCourses();
      final course = _continueLearningcourses
          .where((element) => element.raw['courseId'] == courseId);

      courseDetails = course.length > 0 ? course.first : null;
      if (courseDetails != null) {
        await _getCompletionCertificate();
      }
    }
    return courseDetails;
  }

  Future<void> _saveAsPdf(String courseName) async {
    courseName = courseName.replaceAll(RegExp(r'[^\w\s]'), '');
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
          _isDownloadingToSave = true;
        });

        final certificate = await learnService
            .downloadCompletionCertificate(_base64CertificateImage);

        await File('$path/$fileName.pdf').writeAsBytes(certificate);

        setState(() {
          _isDownloadingToSave = false;
        });
        _displayDialog(true, '$path/$fileName.pdf', 'Success');
      } else {
        return false;
      }
    } catch (e) {
      setState(() {
        _isDownloadingToSave = false;
      });
    } finally {
      setState(() {
        _isDownloadingToSave = false;
      });
    }
  }

  Future<void> _sharePdfCertificate(String courseName) async {
    String fileName =
        '$courseName-' + DateTime.now().millisecondsSinceEpoch.toString();
    String path = await Helper.getDownloadPath();
    String outputFormat = CertificateType.png;
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
          _isDownloadingCertToShare = true;
        });

        final certificate = await learnService
            .downloadCompletionCertificate(_base64CertificateImage);

        await File('$path/$fileName.' + outputFormat).writeAsBytes(certificate);

        setState(() {
          _isDownloadingCertToShare = false;
        });
        await Share.shareXFiles([
          XFile('$path/$fileName.' + outputFormat, mimeType: EMimeTypes.png)
        ], text: "Certificate of completion");
      } else {
        return false;
      }
    } catch (e) {
      setState(() {
        _isDownloadingCertToShare = false;
      });
    } finally {
      setState(() {
        _isDownloadingCertToShare = false;
      });
    }
  }

  Future<dynamic> _openFile(filePath) async {
    await OpenFile.open(filePath);
  }
}
