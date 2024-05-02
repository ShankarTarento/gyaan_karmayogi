import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../constants/_constants/color_constants.dart';
import '../../../../feedback/constants.dart';
import '../../../../services/_services/learn_service.dart';
import '../../_common/error_page.dart';
import 'assessment_completed_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AssessmentVerificationScreen extends StatefulWidget {
  final String timeSpent;
  final Map requestBody;
  final String assessmentTitle;
  final assessmentsInfo;
  final primaryCategory;
  final course;
  final identifier;
  final updateContentProgress;
  final String batchId;
  final bool fromSectionalCutoff;

  AssessmentVerificationScreen(this.timeSpent, this.requestBody,
      {this.assessmentTitle,
      this.assessmentsInfo,
      this.primaryCategory,
      this.course,
      this.identifier,
      this.updateContentProgress,
      this.batchId,
      this.fromSectionalCutoff});
  @override
  _AssessmentVerificationScreenState createState() =>
      _AssessmentVerificationScreenState();
}

class _AssessmentVerificationScreenState
    extends State<AssessmentVerificationScreen> {
  LearnService learnService;
  int _start;
  static const int counterLimit = 4;
  static const int apiCounterLimit = 3;

  @override
  void initState() {
    super.initState();
    learnService = LearnService();
    _start = counterLimit;
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return _start == 0
        ? SafeArea(
            child: Scaffold(
                appBar: AppBar(
                  titleSpacing: 0,
                  elevation: 0,
                  leading: IconButton(
                    icon: Icon(Icons.clear, color: FeedbackColors.black60),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                  ),
                ),
                body: Container(
                  margin: EdgeInsets.only(top: 4),
                  color: AppColors.white,
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context).mClickToSeeTheResults,
                        overflow: TextOverflow.fade,
                        style: GoogleFonts.montserrat(
                            color: FeedbackColors.black87,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.25),
                      ),
                      TextButton(
                        child: Text(AppLocalizations.of(context).mStaticTryAgain),
                        onPressed: () async {
                          await _submitSurvey();
                        },
                      ),
                    ],
                  ),
                )))
        : _showLoadingView();
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    new Timer.periodic(
      oneSec,
      (Timer timer) async {
        if (!mounted) return;
        if (_start < apiCounterLimit) {
          timer.cancel();
          await _submitSurvey();
          if (mounted) {
            setState(() {});
          }
        } else {
          _start--;
          setState(() {});
        }
      },
    );
  }

  Future<bool> _submitSurvey() async {
    var response =
        await learnService.getAssessmentCompletionStatus(widget.requestBody);
    Navigator.of(context).pop(true);
    if (response is String) {
      return await Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => Scaffold(body: ErrorPage())));
    }
    if (response is Map) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
        return await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => AssessmentCompletedScreen(
              widget.timeSpent,
              response,
              assessmentTitle: widget.assessmentTitle,
              assessmentsInfo: widget.assessmentsInfo,
              primaryCategory: widget.primaryCategory,
              course: widget.course,
              identifier: widget.identifier,
              updateContentProgress: widget.updateContentProgress,
              batchId: widget.batchId,
              fromSectionalCutoff: widget.fromSectionalCutoff,
            )));
      });
    }
    return false;
  }

  Widget _showLoadingView() {
    return WillPopScope(
      onWillPop: () async => false,
      child: Container(
        height: double.maxFinite,
        width: double.maxFinite,
        color: Colors.black.withOpacity(0.6),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Stack(alignment: Alignment.center, children: [
                SizedBox(
                  height: 150,
                  width: 150,
                  child: CircularProgressIndicator(
                    strokeWidth: 8,
                    backgroundColor: Colors.black.withOpacity(0),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFFEF951E)),
                  ),
                ),
                Center(
                    child: Column(
                  children: [
                    Text(
                      '${AppLocalizations.of(context).mStaticCalculating}..',
                      style: GoogleFonts.lato(
                          color: AppColors.white,
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.w700,
                          fontSize: 14.0,
                          letterSpacing: 0.25),
                    ),
                  ],
                )),
              ]),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                AppLocalizations.of(context).mAssessmentResultWaitingMessage,
                style: GoogleFonts.lato(
                    color: AppColors.white,
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.w400,
                    fontSize: 12.0,
                    letterSpacing: 0.25),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
