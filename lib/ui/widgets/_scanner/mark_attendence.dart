import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/models/_models/qr_scanner_model.dart';
import 'package:karmayogi_mobile/services/_services/learn_service.dart';
import 'package:karmayogi_mobile/ui/widgets/_scanner/qr_scanner.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'widget/attendence_marked_widget.dart';
import 'widget/flash_light_widget.dart';

class MarkAttendence extends StatefulWidget {
  final String id;
  final String courseId;
  final List<Map<String, dynamic>> sessionIds;
  final String batchId;
  final Function() onAttendanceMarked;

  const MarkAttendence({
    Key key,
    this.id,
    this.courseId,
    this.sessionIds,
    this.batchId,
    @required this.onAttendanceMarked,
  }) : super(key: key);

  @override
  State<MarkAttendence> createState() => _MarkAttendenceState();
}

class _MarkAttendenceState extends State<MarkAttendence> {
  bool isAttendenceMarked = false;
  bool errorDialogShown = false;
  ScannerModel model;
  bool attendanceStatus = false;

  MobileScannerController cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool isValidQR(String sessionId, String batchId) {
    return (widget.sessionIds
            .any((session) => session.values.contains(sessionId)) &&
        batchId == widget.batchId);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Future<void> dispose() async {
    await cameraController.stop();
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            }),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            AppLocalizations.of(context).mStaticScanAndMarkAttendence,
            style: GoogleFonts.lato(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.12,
                height: 1.5,
                color: AppColors.greys87),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: MobileScanner(
              overlay: Stack(
                children: [
                  Container(
                    decoration: ShapeDecoration(
                      shape: QrScannerOverlayShape(
                        borderColor: AppColors.primaryThree,
                        borderRadius: 33,
                        borderLength: 120,
                        borderWidth: 8,
                        cutOutSize: 220,
                      ),
                    ),
                  )
                ],
              ),
              controller: cameraController,
              onDetect: (capture) async {
                try {
                  final List<Barcode> barcodes = capture.barcodes;
                  for (final barcode in barcodes) {
                    model = scannerModelFromJson(barcode.rawValue);
                    if (isValidQR(model.sessionId, model.batchId)) {
                      attendanceStatus = false;
                      widget.sessionIds.forEach((session) {
                        if (session['sessionId'] == model.sessionId &&
                            session['status']) {
                          attendanceStatus = true;
                        }
                      });
                      if (!attendanceStatus) {
                        isAttendenceMarked = await _updateContentProgress();
                      } else {
                        isAttendenceMarked = true;
                      }
                      setState(() {});
                    } else {
                      showErrorDialog();
                      setError();
                    }
                  }
                } catch (e) {
                  showErrorDialog();
                  setError();
                }
              },
            ),
          ),
          showBottomSheet(context, ""),
        ],
      ),
    );
  }

  Widget showBottomSheet(BuildContext context, String submittedDateTime) {
    if (errorDialogShown) return const SizedBox.shrink();
    return Positioned(
        bottom: 0,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.appBarBackground,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          ),
          height: isAttendenceMarked ? 200 : 80,
          width: MediaQuery.of(context).size.width,
          child: isAttendenceMarked
              ? attendanceStatus
                  ? ShowMarkedAttendenceWidget(
                      message: AppLocalizations.of(context)
                          .mStaticAttendanceAlreadyMarked,
                      dateAndTime: submittedDateTime,
                    )
                  : ShowMarkedAttendenceWidget(
                      message:
                          AppLocalizations.of(context).mStaticScannerSuccesfuly,
                      dateAndTime: submittedDateTime,
                    )
              : ValueListenableBuilder(
                  valueListenable: cameraController.torchState,
                  builder: (context, state, child) {
                    return ShowFlashLightWidget(state == TorchState.on,
                        () async {
                      await cameraController.toggleTorch();
                    });
                  },
                ),
        ));
  }

  void showErrorDialog() {
    errorDialogShown
        ? const SizedBox.shrink()
        : showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) => AlertDialog(
                  content: Container(
                      decoration: BoxDecoration(
                        color: AppColors.appBarBackground,
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/img/icon_error.svg',
                            height: 24,
                            width: 24,
                            fit: BoxFit.fill,
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Text(
                            AppLocalizations.of(context).mStaticInvalidQR,
                            style: GoogleFonts.montserrat(
                                color: Colors.black,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Text(
                            AppLocalizations.of(context).mStaticInvalidQRDesc,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                                color: AppColors.greys60,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w400),
                          ),
                          SizedBox(
                            height: 24,
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                              resetError();
                            },
                            child: Text(
                              AppLocalizations.of(context).mStaticScanAgain,
                              style: GoogleFonts.lato(
                                  color: AppColors.primaryThree,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      )),
                ));
  }

  void setError() {
    errorDialogShown = true;
    isAttendenceMarked = false;
    cameraController.stop();
  }

  void resetError() {
    errorDialogShown = false;
    isAttendenceMarked = false;
    cameraController.start();
  }

  Future<bool> _updateContentProgress() async {
    final LearnService learnService = LearnService();
    String courseId = widget.courseId;
    String batchId = model.batchId;
    String contentId = model.sessionId;
    int status = 2;
    double completionPercentage = 100.0;
    var response = await learnService.markAttendance(
        courseId, batchId, contentId, status, completionPercentage);
    if (response['responseCode'] == 'OK') {
      widget.onAttendanceMarked();
    }
    return response['responseCode'] == 'OK';
  }
}
