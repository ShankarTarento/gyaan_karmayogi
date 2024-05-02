import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/ui/widgets/_learn/_contentPlayers/course_assessment_player.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import '../../../../localization/_langs/english_lang.dart';
import './../../../../feedback/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'assessment_completed_screen_item.dart';

class AssessmentCompletedScreen extends StatefulWidget {
  final String timeSpent;
  final Map apiResponse;
  final String assessmentTitle;
  final assessmentsInfo;
  final primaryCategory;
  final course;
  final identifier;
  final updateContentProgress;
  final String batchId;
  final bool fromSectionalCutoff;

  AssessmentCompletedScreen(this.timeSpent, this.apiResponse,
      {this.assessmentTitle,
      this.assessmentsInfo,
      this.primaryCategory,
      this.course,
      this.identifier,
      this.updateContentProgress,
      this.batchId,
      this.fromSectionalCutoff});
  @override
  _AssessmentCompletedScreenState createState() =>
      _AssessmentCompletedScreenState();
}

class _AssessmentCompletedScreenState extends State<AssessmentCompletedScreen> {
  get boxDecoration => BoxDecoration(
          border: Border(
        top: BorderSide(color: AppColors.grey04),
        bottom: BorderSide(color: AppColors.grey04),
      ));

  get leftPadding => 16.0;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: AppColors.primaryBlue,
    ));
    return widget.apiResponse.runtimeType != String
        ? Scaffold(
            body: SafeArea(
              child: _buildLayout(),
            ),
            bottomSheet: _actionButton(),
          )
        : ErrorSpacer();
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
          if (widget.fromSectionalCutoff) {
            Navigator.of(context).pop(true);
          }
        },
      ),
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
                widget.primaryCategory == PrimaryCategory.practiceAssessment
                    ? AppLocalizations.of(context).mAssessmentCheckYourKnowledge
                    : AppLocalizations.of(context).mAssessmentAssessmentResults,
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
                  widget.primaryCategory == PrimaryCategory.practiceAssessment
                      ? Container(
                          height: 92,
                          width: 92,
                          margin: EdgeInsets.fromLTRB(16, 16, 16, 4),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.positiveLight.withOpacity(0.08),
                            borderRadius:
                                BorderRadius.all(Radius.circular(100)),
                          ),
                          child: Container(
                            height: 68,
                            width: 68,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.positiveLight.withOpacity(0.07),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(100)),
                            ),
                            child: Container(
                              height: 36,
                              width: 36,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.positiveLight,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(100)),
                              ),
                              child: Icon(
                                Icons.check,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          margin: EdgeInsets.fromLTRB(16, 16, 16, 4),
                          child: Stack(alignment: Alignment.center, children: [
                            SizedBox(
                              height: 92,
                              width: 92,
                              child: CircularProgressIndicator.adaptive(
                                value: (widget.apiResponse['overallResult'] !=
                                        null)
                                    ? (widget.apiResponse['overallResult']) /
                                        100
                                    : 0,
                                backgroundColor: AppColors.grey08,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    widget.apiResponse['pass'] != null
                                        ? (widget.apiResponse['pass']
                                            ? FeedbackColors.positiveLight
                                            : FeedbackColors.negativeLight)
                                        : FeedbackColors.positiveLight),
                              ),
                            ),
                            Center(
                                child: Column(
                              children: [
                                Text(
                                  (widget.apiResponse['passPercentage'] != null)
                                      ? widget.apiResponse['overallResult'] >=
                                              widget
                                                  .apiResponse['passPercentage']
                                          ? widget.apiResponse['overallResult']
                                                  .toStringAsFixed(0)
                                                  .toString() +
                                              '%'
                                          : widget.apiResponse['overallResult']
                                                  .toStringAsFixed(0)
                                                  .toString() +
                                              '%'
                                      : widget.apiResponse['pass']
                                          ? widget.apiResponse['overallResult']
                                                  .toStringAsFixed(0)
                                                  .toString() +
                                              '%'
                                          : widget.apiResponse['overallResult']
                                                  .toStringAsFixed(0)
                                                  .toString() +
                                              '%',
                                  style: GoogleFonts.lato(
                                      color: widget.apiResponse['pass'] != null
                                          ? (widget.apiResponse['pass']
                                              ? FeedbackColors.positiveLight
                                              : FeedbackColors.negativeLight)
                                          : FeedbackColors.positiveLight,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20.0,
                                      letterSpacing: 0.25),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  (widget.apiResponse['passPercentage'] != null)
                                      ? widget.apiResponse['overallResult'] >=
                                              widget
                                                  .apiResponse['passPercentage']
                                          ? AppLocalizations.of(context)
                                              .mPass
                                              .toUpperCase()
                                          : AppLocalizations.of(context)
                                              .mFail
                                              .toUpperCase()
                                      : widget.apiResponse['pass']
                                          ? AppLocalizations.of(context)
                                              .mPass
                                              .toUpperCase()
                                          : AppLocalizations.of(context)
                                              .mFail
                                              .toUpperCase(),
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
                      widget.primaryCategory ==
                              PrimaryCategory.practiceAssessment
                          ? EnglishLang.keepLearning
                          : widget.apiResponse['passPercentage'] == null
                              ? (widget.apiResponse['pass']
                                  ? AppLocalizations.of(context).mPass
                                  : EnglishLang.failed)
                              : (widget.apiResponse['overallResult'] >=
                                      widget.apiResponse['passPercentage']
                                  ? widget.apiResponse['overallResult'] == 100
                                      ? EnglishLang.acedAssessment
                                      : EnglishLang.passedSuccessfully
                                  : EnglishLang.tryAgain),
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
        widget.apiResponse['children'] == null
            ? Container()
            : Column(
                children: [
                  for (var i = 0;
                      i < widget.apiResponse['children'].length;
                      i++)
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
                                  widget.apiResponse['children'][i]['total'] ==
                                          1
                                      ? '${widget.apiResponse['children'][i]['total']} ${AppLocalizations.of(context).mCommonQuestion}'
                                      : '${widget.apiResponse['children'][i]['total']} ${AppLocalizations.of(context).mCommonQuestions}',
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
                                top: 24, left: leftPadding, bottom: 16),
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
                          _summaryItem(i),
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

  Widget _summaryItem(int i) {
    return Column(
      children: [
        widget.apiResponse['children'][i]['correct'] > 0
            ? AssessmentCompletedScreenItem(
                itemIndex: i,
                apiResponse: widget.apiResponse,
                color: AppColors.positiveLight,
                type: 'correct',
                title: widget.apiResponse['children'][i]['correct'] == 1
                    ? widget.apiResponse['children'][i]['correct'].toString() +
                        '  ' +
                        AppLocalizations.of(context).mStaticOneCorrect
                    : widget.apiResponse['children'][i]['correct'].toString() +
                        '  ' +
                        AppLocalizations.of(context).mStaticCorrect)
            : Center(),
        widget.apiResponse['children'][i]['incorrect'] > 0
            ? AssessmentCompletedScreenItem(
                itemIndex: i,
                apiResponse: widget.apiResponse,
                color: AppColors.negativeLight,
                type: 'incorrect',
                title: widget.apiResponse['children'][i]['incorrect'] == 1
                    ? widget.apiResponse['children'][i]['incorrect']
                            .toString() +
                        '  ' +
                        AppLocalizations.of(context).mStaticOneIncorrect
                    : widget.apiResponse['children'][i]['incorrect']
                            .toString() +
                        '  ' +
                        AppLocalizations.of(context).mStaticIncorrect)
            : Center(),
        widget.apiResponse['children'][i]['blank'] > 0
            ? AssessmentCompletedScreenItem(
                itemIndex: i,
                apiResponse: widget.apiResponse,
                color: AppColors.greys60,
                type: 'blank',
                title: widget.apiResponse['children'][i]['blank'].toString() +
                    '  ' +
                    AppLocalizations.of(context).mStaticNotAttempted)
            : Center(),
      ],
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
            width: MediaQuery.of(context).size.width * 0.44,
            child: TextButton(
              onPressed: () async {
                await Navigator.pushReplacement(
                    context,
                    FadeRoute(
                        page: CourseAssessmentPlayer(
                      widget.course,
                      widget.assessmentTitle,
                      widget.identifier,
                      null,
                      widget.updateContentProgress,
                      widget.batchId,
                      null,
                      primaryCategory: widget.primaryCategory,
                      parentCourseId: widget.course['identifier'],
                    )));
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                    side: BorderSide(color: AppColors.primaryBlue)),
                // onSurface: Colors.grey,
              ),
              child: Text(
                AppLocalizations.of(context).mStaticTryAgain,
                style: GoogleFonts.lato(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          Container(
            height: 58,
            width: (MediaQuery.of(context).size.width * 0.44),
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // if (widget.fromSectionalCutoff) {
                //   Navigator.of(context).pop(true);
                // }
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
