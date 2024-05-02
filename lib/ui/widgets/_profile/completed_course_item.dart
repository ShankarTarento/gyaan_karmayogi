import 'dart:io';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/models/_models/telemetry_event_model.dart';
import 'package:karmayogi_mobile/ui/widgets/index.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:karmayogi_mobile/util/share_certificate_helper.dart';
import 'package:karmayogi_mobile/util/telemetry.dart';
import 'package:karmayogi_mobile/util/telemetry_db_helper.dart';
import 'package:open_file_plus/open_file_plus.dart';
// import 'package:open_file_safe/open_file_safe.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../constants/index.dart';
import '../../../localization/_langs/english_lang.dart';
import '../../../services/_services/learn_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CompletedCourseItemCard extends StatefulWidget {
  final String name;
  final String description;
  final String image;
  final String issuedDate;
  final completionCertificate;

  CompletedCourseItemCard({
    this.name,
    this.description,
    this.image = '',
    this.issuedDate,
    this.completionCertificate,
  });

  @override
  State<CompletedCourseItemCard> createState() =>
      _CompletedCourseItemCardState();
}

class _CompletedCourseItemCardState extends State<CompletedCourseItemCard> {
  final LearnService learnService = LearnService();
  String _certificateUrl;
  // bool _isProgressStop;
  bool _isDownloadingToSave = false;
  String _certificateId;
  ValueNotifier<bool> _isShareLoading = ValueNotifier(false);

  String userId;
  String userSessionId;
  String messageIdentifier;
  String departmentId;
  String deviceIdentifier, lastAccessContentId;
  var telemetryEventData;

  // Future<void> _saveImageAsPdf(String courseName) async {
  //   String fileName =
  //       '$courseName-' + DateTime.now().millisecondsSinceEpoch.toString();
  //   final pdf = pw.Document();
  //   // final directoryName = "Karmayogi";
  //   // Directory directory = await getExternalStorageDirectory();
  //   // var dir = await DownloadsPathProvider.downloadsDirectory;
  //   // String path = dir.path;
  //   String path = await Helper.getDownloadPath();
  //   // String path = APP_DOWNLOAD_FOLDER;
  //   await Directory('$path').create(recursive: true);

  //   try {
  //     if (await Helper.requestPermission(Permission.storage)) {
  //       setState(() {
  //         _isProgressStop = false;
  //       });

  //       final image = pw.SvgImage(svg: Helper.svgDecoder(_certificateUrl));

  //       //creating PDF for the image
  //       pdf.addPage(pw.Page(
  //           pageFormat: PdfPageFormat.undefined,
  //           build: (pw.Context context) {
  //             return image; // Center
  //           }));

  //       //saving the PDF in external storage
  //       await File('$path/$fileName.pdf').writeAsBytes(await pdf.save());
  //       setState(() {
  //         _isProgressStop = true;
  //       });
  //       _displayDialog(true, '$path/$fileName.pdf', 'Success');
  //     } else {
  //       return false;
  //     }
  //   } catch (e) {
  //     setState(() {
  //       _isProgressStop = true;
  //     });
  //     _displayDialog(false, '', e.toString().split(':').last);
  //   }
  // }

  void _generateInteractTelemetryData(
      {String contentId, String subType, String edataId}) async {
    deviceIdentifier = await Telemetry.getDeviceIdentifier();
    userId = await Telemetry.getUserId();
    userSessionId = await Telemetry.generateUserSessionId();
    messageIdentifier = await Telemetry.generateUserSessionId();
    departmentId = await Telemetry.getUserDeptId();
    Map eventData = Telemetry.getInteractTelemetryEvent(
        deviceIdentifier,
        userId,
        departmentId,
        TelemetryPageIdentifier.myProfilePageId,
        userSessionId,
        messageIdentifier,
        contentId,
        subType,
        env: TelemetryEnv.profile,
        objectType: subType,
        clickId: edataId);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());
  }

  Future<void> _saveAsPdf(BuildContext parentContext, String courseName) async {
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

        final certificate =
            await learnService.downloadCompletionCertificate(_certificateUrl);

        await File('$path/$fileName.pdf').writeAsBytes(certificate);

        setState(() {
          _isDownloadingToSave = false;
        });
        _displayDialog(parentContext, true, '$path/$fileName.pdf', 'Success');
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

  Future<void> _shareCertificate() async {
    _generateInteractTelemetryData(
        contentId: _certificateId,
        subType: TelemetrySubType.certificate,
        edataId: TelemetryIdentifier.shareCertificate);
    if (Platform.isIOS) {
      ShareCertificateHelper.showPopupToSelectSharePlatforms(
        context: context,
        onLinkedinTap: () {
          Helper.doLaunchUrl(
              url: Helper.getLinkedlnUrlToShareCertificate(_certificateId),
              mode: LaunchMode.externalApplication);
        },
        onOtherAppsTap: () async {
          await _sharePdfCertificate(widget.name);
        },
      );
    } else {
      try {
        _isShareLoading.value = true;
        await _sharePdfCertificate(widget.name);
      } catch (e) {
        _isShareLoading.value = false;
      } finally {
        _isShareLoading.value = false;
      }
    }
  }

  Future<void> _sharePdfCertificate(String nameOfCourse) async {
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
      final certificate = await learnService.downloadCompletionCertificate(
          _certificateUrl,
          outputType: outputFormat);

      await File('$path/$fileName.' + outputFormat).writeAsBytes(certificate);

      await Share.shareXFiles(
          [XFile('$path/$fileName.' + outputFormat, mimeType: EMimeTypes.png)],
          text: "Certificate of completion");
    } else {
      return false;
    }
  }

  Future<dynamic> _openFile(filePath) async {
    await OpenFile.open(filePath);
  }

  // Future<dynamic> _openSvgFile(filePath) async {
  //   await launchUrl(Uri.parse(filePath),
  //       mode: LaunchMode.externalNonBrowserApplication);
  // }

  Future<bool> _displayDialog(BuildContext parentContext, bool isSuccess,
      String filePath, String message) async {
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
        context: parentContext,
        builder: (cntext) => SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 20),
                // margin: EdgeInsets.only(left: 20, right: 20),
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
                            padding: const EdgeInsets.only(top: 5, bottom: 10),
                            child: GestureDetector(
                              onTap: () => _openFile(filePath),
                              child: roundedButton(
                                AppLocalizations.of(parentContext).mStaticOpen,
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
                        onTap: () => Navigator.of(cntext).pop(false),
                        child: roundedButton(
                            AppLocalizations.of(parentContext).mCommonClose,
                            Colors.white,
                            AppColors.primaryThree),
                      ),
                    ),
                  ],
                ),
              ),
            ));
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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.white,
      margin: EdgeInsets.only(bottom: 5.0),
      padding: EdgeInsets.only(top: 8, bottom: 8),
      child: ExpansionTile(
        // collapsedTextColor: AppColors.primaryThree,
        onExpansionChanged: (value) async {
          // print(widget.completionCertificate);
          if (value) {
            if (widget.completionCertificate.raw['issuedCertificates'].length >
                    0 &&
                ((widget.completionCertificate.raw['issuedCertificates']
                                .length >
                            1
                        ? widget.completionCertificate.raw['issuedCertificates']
                            [1]['identifier']
                        : widget.completionCertificate.raw['issuedCertificates']
                            [0]['identifier']) !=
                    null)) {
              _certificateId = widget.completionCertificate
                          .raw['issuedCertificates'].length >
                      1
                  ? widget.completionCertificate.raw['issuedCertificates'][1]
                      ['identifier']
                  : widget.completionCertificate.raw['issuedCertificates'][0]
                      ['identifier'];
              final certificate = await learnService
                  .getCourseCompletionCertificate(_certificateId);
              setState(() {
                _certificateUrl = certificate;
              });
            }
          }
        },
        tilePadding: EdgeInsets.only(right: 16),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 16, right: 16, top: 5),
              child: Container(
                height: 48,
                width: 48,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: (widget.image == '' || widget.image == null)
                      ? Image.asset(
                          'assets/img/image_placeholder.jpg',
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          Helper.convertPortalImageUrl(widget.image),
                          // width: 48,
                          // height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset(
                            'assets/img/image_placeholder.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.name,
                    style: GoogleFonts.lato(
                        color: AppColors.greys87,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w700),
                  ),
                  (widget.description != null && widget.description != '')
                      ? Padding(
                          padding: EdgeInsets.only(top: 6.0),
                          child: Text(
                            widget.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.lato(
                                color: AppColors.greys60,
                                fontSize: 12.0,
                                fontWeight: FontWeight.w400),
                          ),
                        )
                      : Center(),
                ],
              ),
            ),
          ],
        ),

        subtitle: Padding(
          padding: const EdgeInsets.only(left: 80),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.issuedDate,
                style: GoogleFonts.lato(
                    // color: AppColors.greys60,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w400),
              ),
              widget.issuedDate == EnglishLang.certificateIsBeingGenerated
                  ? Tooltip(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.info_outline,
                          color: AppColors.greys60,
                          size: 20,
                        ),
                      ),
                      margin: EdgeInsets.only(left: 100, right: 20),
                      padding: EdgeInsets.all(16),
                      message: AppLocalizations.of(context)
                          .mStaticCertificateIsBeingGeneratedMessage,
                      showDuration: Duration(seconds: 3),
                      triggerMode: TooltipTriggerMode.tap,
                      verticalOffset: 20,
                    )
                  : Center()
            ],
          ),
        ),
        children: [
          widget.issuedDate != EnglishLang.certificateIsBeingGenerated
              ? Container(
                  margin:
                      EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 16),
                  // height: 193,
                  // width: double.infinity,
                  child: _certificateUrl != null
                      ? Column(
                          children: [
                            Container(
                              height: 210,
                              width: double.infinity,
                              child: ClipRRect(
                                  child: WebView(
                                initialUrl:
                                    Uri.parse(_certificateUrl).toString(),
                                javascriptMode: JavascriptMode.unrestricted,
                              )),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.30,
                                    child: ValueListenableBuilder(
                                        valueListenable: _isShareLoading,
                                        builder: (BuildContext context,
                                            bool isShareLoading, Widget child) {
                                          return ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              onPrimary: AppColors.primaryThree,
                                              primary: Colors.white,
                                              minimumSize:
                                                  const Size.fromHeight(
                                                      40), // NEW
                                              side: BorderSide(
                                                  width: 1,
                                                  color:
                                                      AppColors.primaryThree),
                                            ),
                                            onPressed: () => isShareLoading
                                                ? null
                                                : _shareCertificate(),
                                            child: isShareLoading
                                                ? SizedBox(
                                                    height: 20,
                                                    width: 20,
                                                    child: PageLoader())
                                                : Text(
                                                    AppLocalizations.of(context)
                                                        .mStaticShare,
                                                    style: GoogleFonts.lato(
                                                        height: 1.429,
                                                        letterSpacing: 0.5,
                                                        fontSize: 14,
                                                        color: AppColors
                                                            .primaryThree,
                                                        fontWeight:
                                                            FontWeight.w700),
                                                  ),
                                          );
                                        }),
                                  ),
                                  Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.58,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          primary: AppColors.primaryThree,
                                          minimumSize:
                                              const Size.fromHeight(40), // NEW
                                          side: BorderSide(
                                              width: 1,
                                              color: AppColors.primaryThree),
                                        ),
                                        onPressed: () async {
                                          _generateInteractTelemetryData(
                                              contentId: _certificateId,
                                              subType:
                                                  TelemetrySubType.certificate,
                                              edataId: TelemetryIdentifier
                                                  .downloadCertificate);
                                          _isDownloadingToSave
                                              ? null
                                              : _saveAsPdf(
                                                  context, widget.name);
                                        },
                                        child: !_isDownloadingToSave
                                            ? Text(
                                                AppLocalizations.of(context)
                                                    .mCommonDownloadCertificate,
                                                style: GoogleFonts.lato(
                                                    height: 1.429,
                                                    letterSpacing: 0.5,
                                                    fontSize: 14,
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.w700),
                                              )
                                            : SizedBox(
                                                height: 20,
                                                width: 20,
                                                child: PageLoader()),
                                      )),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Container(height: 200, child: PageLoader()))
              : Center()
        ],
      ),
    );
  }
}
