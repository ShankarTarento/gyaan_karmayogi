import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import '../../../../localization/_langs/english_lang.dart';
import './../../../../feedback/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AssessmentCompleted extends StatefulWidget {
  final String timeSpent;
  final Map apiResponse;
  final Function parentAction;
  AssessmentCompleted(this.timeSpent, this.apiResponse, this.parentAction);
  @override
  _AssessmentCompletedState createState() => _AssessmentCompletedState();
}

class _AssessmentCompletedState extends State<AssessmentCompleted> {

  get boxDecoration => BoxDecoration(
      border: Border(
        top: BorderSide(color: AppColors.grey04),
        bottom: BorderSide(color: AppColors.grey04),
      ));

  @override
  Widget build(BuildContext context) {
   return Scaffold(
     body: SafeArea(
       child: _buildLayout(),
     ),
     bottomSheet: _actionButton(),
   );
  }

  Widget _buildLayout() {
    return Container(
      color: AppColors.primaryBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _getAppbar(),
          Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              child: Text(
                AppLocalizations.of(context).mAssessmentAssessmentResults,
                style: GoogleFonts.montserrat(
                  color: AppColors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.w600,
                ),
              )),
          _containerBody(),
        ],
      ),
    );
  }

  Widget _getAppbar() {
    return AppBar(
      backgroundColor: AppColors.primaryBlue,
      titleSpacing: 0,
      elevation: 0,
      leading: IconButton(
        icon:
        Icon(Icons.arrow_back_ios_sharp, size: 20, color: AppColors.white),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Widget _containerBody() {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0), topRight: Radius.circular(16.0)),
        child: Container(
          padding: EdgeInsets.only(
            top: 8,
          ),
          color: Colors.white,
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(16, 16, 16, 4),
                    child: Stack(alignment: Alignment.center, children: [
                      SizedBox(
                        height: 92,
                        width: 92,
                        child: CircularProgressIndicator.adaptive(
                          value: (widget.apiResponse['result'] != null)
                              ? (widget.apiResponse['result']) /
                              100 : 0,
                          backgroundColor: AppColors.grey08,
                          valueColor: AlwaysStoppedAnimation<Color>(
                                  widget.apiResponse['result'] >= widget.apiResponse['passPercent']
                                  ? FeedbackColors.positiveLight
                                  : FeedbackColors.negativeLight),
                        ),
                      ),
                      Center(
                          child: Column(
                            children: [
                              Text(
                                widget.apiResponse['result'] >=
                                    widget.apiResponse['passPercent']
                                    ? widget.apiResponse['result']
                                        .toStringAsFixed(0)
                                        .toString() +
                                    ' %'
                                    : widget.apiResponse['result']
                                        .toStringAsFixed(0)
                                        .toString() +
                                    ' %',
                                style: GoogleFonts.lato(
                                    color: (widget.apiResponse['result'] >= widget.apiResponse['passPercent'])
                                        ? FeedbackColors.positiveLight : FeedbackColors.negativeLight,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20.0,
                                    letterSpacing: 0.25),
                              ),
                              SizedBox(height: 4),
                              Text(
                                widget.apiResponse['result'] >= widget.apiResponse['passPercent']
                                    ? AppLocalizations.of(context).mPass.toUpperCase()
                                    : AppLocalizations.of(context).mFail.toUpperCase(),
                                style: GoogleFonts.lato(
                                    color: AppColors.greys60,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12.0,
                                    letterSpacing: 0.25),
                              ),
                            ],
                          )),
                    ]),
                  ),
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.fromLTRB(86, 4, 86, 16),
                    child: Text(
                      widget.apiResponse['result'] >=
                          widget.apiResponse['passPercent']
                          ? widget.apiResponse['result'] == 100
                          ? AppLocalizations.of(context).mStaticAcedAssessment
                          : AppLocalizations.of(context).mStaticPassedSuccessfully
                          : AppLocalizations.of(context).mStaticTryAgainMsg,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.0,
                          letterSpacing: 0.25),
                    ),
                  ),
                  _overallSummary()
                ]),
          ),
        ),
      ),
    );
  }

  Widget _overallSummary() {
    return Column(
      children: [
        Column(
          children: [
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(top: 8.0, bottom: 8),
              padding: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 16),
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/img/assessment_icon.svg',
                              color: AppColors.primaryBlue,
                            ),
                            SizedBox(width: 8.0),
                            Text(
                              AppLocalizations.of(context)
                                  .mTotalQuestion,
                              style: GoogleFonts.lato(
                                  decoration: TextDecoration.none,
                                  color: Colors.black87,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.25),
                            )
                          ],
                        ),
                        Spacer(), // Add space between text and icon
                        Text(
                          widget.apiResponse['total'] == 1
                              ? '${widget.apiResponse['total']} ${AppLocalizations.of(context).mCommonQuestion}'
                              : '${widget.apiResponse['total']} ${AppLocalizations.of(context).mCommonQuestions}',
                          style: GoogleFonts.lato(
                              decoration: TextDecoration.none,
                              color: Colors.black87,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.25),
                        )
                      ],
                    ),
                    decoration: boxDecoration,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: 24, left: 16, bottom: 16),
                    child: Text(
                      AppLocalizations.of(context)
                          .mYourPerformanceSummary,
                      style: GoogleFonts.lato(
                          color: FeedbackColors.black87,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.25),
                    ),
                  ),
                  _summaryItems(),
                ],
              ),
            ),
          ],
        ),
        SizedBox(
          height: 100,
        )
      ],
    );
  }

  Widget _summaryItems() {
    return Column(
      children: [
        widget.apiResponse['correct'] > 0
            ? _summaryItem(
            'correct',
            widget.apiResponse['correct'] == 1
                ? widget.apiResponse['correct'].toString() +
                '  ' +
                AppLocalizations.of(context).mStaticOneCorrect
                : widget.apiResponse['correct'].toString() +
                '  ' +
                AppLocalizations.of(context).mStaticCorrect)
            : Center(),
        widget.apiResponse['inCorrect'] > 0
            ? _summaryItem(
            'inCorrect',
            widget.apiResponse['inCorrect'] == 1
                ? widget.apiResponse['inCorrect']
                .toString() +
                '  ' +
                AppLocalizations.of(context).mStaticOneIncorrect
                : widget.apiResponse['inCorrect']
                .toString() +
                '  ' +
                AppLocalizations.of(context).mStaticIncorrect)
            : Center(),
        widget.apiResponse['blank'] > 0
            ? _summaryItem(
            'blank',
            widget.apiResponse['blank'].toString() +
                '  ' +
                AppLocalizations.of(context).mStaticNotAttempted)
            : Center(),
      ],
    );
  }

  Widget _summaryItem(String type, String title) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.white,
          border: Border(
            top: BorderSide(color: AppColors.grey04),
            bottom: BorderSide(color: AppColors.grey04),
            left: BorderSide(color: AppColors.white, width: 0),
          )),
      child: Row(
        children: [
          if (type.toString() == 'correct')
            Icon(Icons.done,
                size: 24,
                color: AppColors.primaryBlue),
          if (type.toString() == 'inCorrect')
            SvgPicture.asset(
              'assets/img/close_black.svg',
              color: AppColors.primaryBlue,
            ),
          if (type.toString() == 'blank')
            SvgPicture.asset(
              'assets/img/unanswered.svg',
              color: AppColors.primaryBlue,
            ),
          Padding(
            padding:
            const EdgeInsets.only(left: 8),
            child: Text(
              title,
              style: GoogleFonts.lato(
                color:
                FeedbackColors.black87,
                fontSize: 14.0,
                fontWeight:
                FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton() {
    return Container(
      height: 90,
      padding: EdgeInsets.fromLTRB(16, 16, 16, 32),
      decoration: BoxDecoration(color: Colors.white),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            height: 58,
            width: (MediaQuery.of(context).size.width - 32),
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (widget.parentAction != null) {
                  widget.parentAction();
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                    side: BorderSide(color: AppColors.primaryBlue)),
              ),
              child: Text(
                AppLocalizations.of(context).mFinish,
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
