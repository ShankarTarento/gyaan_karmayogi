import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/models/_models/assessment_info_model.dart';
import 'package:karmayogi_mobile/respositories/_respositories/learn_repository.dart';
import 'package:karmayogi_mobile/services/_services/learn_service.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/error.dart';
import 'package:karmayogi_mobile/ui/widgets/_learn/_assessment/assessment_sections.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:provider/provider.dart';
import '../../../../localization/_langs/english_lang.dart';
import './../../../../constants/_constants/app_constants.dart';
import './../../../../constants/_constants/color_constants.dart';
import './../../../../feedback/constants.dart';
import './../../../../ui/widgets/_learn/_assessment/assessment_questions.dart';
import './../../../../feedback/widgets/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CourseAssessmentPlayer extends StatefulWidget {
  final course;
  final String title;
  final String identifier;
  final String fileUrl;
  final ValueChanged<Map> parentAction;
  final String batchId;
  final duration;
  final String primaryCategory;
  final String parentCourseId;
  final ValueChanged<bool> playNextResource;
  CourseAssessmentPlayer(this.course, this.title, this.identifier, this.fileUrl,
      this.parentAction, this.batchId, this.duration,
      {this.primaryCategory,
      @required this.parentCourseId,
      this.playNextResource});
  @override
  _CourseAssessmentPlayerState createState() => _CourseAssessmentPlayerState();
}

class _CourseAssessmentPlayerState extends State<CourseAssessmentPlayer> {
  final LearnService learnService = LearnService();
  Map _microSurvey;
  double surveyCompletedPercent = 0.0;
  AssessmentInfo _assessmentInfo;
  var _retakeInfo;
  var _questionSet = [];

  @override
  void initState() {
    super.initState();
  }

  Future<dynamic> _getAssessmentData() async {
    var response;
    if (widget.fileUrl != null) {
      response = await learnService.getAssessmentData(widget.fileUrl);
    } else {
      _assessmentInfo =
          await Provider.of<LearnRepository>(context, listen: false)
              .getAssessmentInfo(widget.identifier);
      if (widget.primaryCategory == PrimaryCategory.finalAssessment) {
        _retakeInfo =
            await learnService.getRetakeAssessmentInfo(widget.identifier);
      }
      for (var i = 0; i < _assessmentInfo.questions.length; i++) {
        final response = await Provider.of<LearnRepository>(context,
                listen: false)
            .getAssessmentQuestions(
                widget.identifier, _assessmentInfo.questions[i]['childNodes']);
        _questionSet.add(response);
      }
    }
    return response;
  }

  void markSurveyCompleted(double status) {
    surveyCompletedPercent = status;
    Map data = {
      'identifier': widget.identifier,
      'completionPercentage': surveyCompletedPercent / 100,
      'current': '',
      'mimeType': EMimeTypes.assessment,
    };
    widget.parentAction(data);
    widget.playNextResource(true);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: AppColors.primaryBlue,
    ));
    return FutureBuilder(
        future: _getAssessmentData(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          _microSurvey = snapshot.data;
          if (snapshot.hasData || _assessmentInfo != null) {
            return Scaffold(
              body: SafeArea(
                child: _buildLayout(),
              ),
              bottomSheet: _actionButton(),
            );
          } else {
            return Scaffold(
                appBar: AppBar(
                    elevation: 0,
                    // automaticallyImplyLeading: false,
                    leading: IconButton(
                        icon: Icon(
                          Icons.close,
                          color: AppColors.greys87,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                    title: Padding(
                        padding: const EdgeInsets.only(left: 0),
                        child: Text(
                          '',
                          style: GoogleFonts.lato(
                            color: AppColors.greys87,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ))),
                body: PageLoader());
          }
        });
  }

  Widget _getAppbar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppBar(
          backgroundColor: AppColors.primaryBlue,
          titleSpacing: 0,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close, size: 20, color: AppColors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Text(
              widget.title,
              style: GoogleFonts.montserrat(
                color: AppColors.white,
                fontSize: 24.0,
                fontWeight: FontWeight.w600,
              ),
            )),
      ],
    );
  }

  Widget _buildLayout() {
    return Container(
      color: AppColors.primaryBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_getAppbar(), _containerBody()],
      ),
    );
  }

  Widget _containerBody() {
    return Expanded(
        child: ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(16.0),
        topRight: Radius.circular(16.0),
      ),
      child: Container(
          padding:
              const EdgeInsets.only(left: 24, top: 24, right: 24, bottom: 90),
          color: Colors.white,
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _cardHeadingItems(),
                Divider(
                  thickness: 1,
                  color: AppColors.grey16,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 16),
                  child: Text(
                    EnglishLang.summary,
                    style: GoogleFonts.lato(
                      color: AppColors.greys60,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                _informationCard(),
              ],
            ),
          )),
    ));
  }

  Widget _cardHeadingItems() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: (widget.primaryCategory == PrimaryCategory.practiceAssessment
              ? PRACTICE_SCENARIO_4_SUMMARY
              : SCENARIO_4_SUMMARY)
          .map(
            (informationCard) => _headingItem(
                informationCard.icon,
                informationCard.scenarioNumber == 1
                    ? '${_microSurvey != null ? _microSurvey['questions'].length : _assessmentInfo.maxQuestions} questions'
                    : informationCard.scenarioNumber == 2
                        ? (_retakeInfo != null
                            ? '${AppLocalizations.of(context).mStaticMaximum} ${_retakeInfo['attemptsAllowed']} ${AppLocalizations.of(context).mStaticRetakeAssesmentMessage} ${_retakeInfo['attemptsMade']} ${AppLocalizations.of(context).mStaticTime}'
                            : AppLocalizations.of(context)
                                .mStaticUnlimitedRetakes)
                        : (_assessmentInfo != null
                            ? Helper.getFullTimeFormat(
                                _assessmentInfo.expectedDuration.toString(),
                                timelyDurationFlag: true)
                            : widget.duration.toString().split('-').last),
                informationCard.iconColor),
          )
          .toList(),
    );
  }

  Widget _headingItem(IconData icon, String information, Color iconColor) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: iconColor),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.7,
                child: Text(
                  information,
                  style: GoogleFonts.lato(
                      color: AppColors.greys87,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _informationCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(bottom: 24),
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children:
                (widget.primaryCategory == PrimaryCategory.practiceAssessment
                        ? PRACTICE_SCENARIO_4_INFO
                        : SCENARIO_4_INFO)
                    .map(
                      (informationCard) =>
                          _informationItem(informationCard.information),
                    )
                    .toList(),
          )
        ],
      ),
    );
  }

  Widget _informationItem(String information) {
    return Container(
      margin: EdgeInsets.only(top: 8, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 6, color: AppColors.primaryOne),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Text(
                information,
                style: GoogleFonts.lato(
                  color: AppColors.greys87,
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
            width: (MediaQuery.of(context).size.width - 35),
            child: TextButton(
              onPressed: !(_retakeInfo != null &&
                      _retakeInfo['attemptsAllowed'] ==
                          _retakeInfo['attemptsMade'])
                  ? () {
                      Navigator.pop(context);
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => widget.fileUrl != null
                              ? AssessmentQuestions(
                                  widget.course,
                                  widget.title,
                                  widget.identifier,
                                  _microSurvey != null
                                      ? _microSurvey
                                      : _questionSet.first,
                                  markSurveyCompleted,
                                  widget.batchId,
                                  widget.duration,
                                  isNewAssessment:
                                      widget.fileUrl != null ? false : true,
                                  primaryCategory: widget.primaryCategory,
                                  parentCourseId: widget.parentCourseId
                                )
                              : (_questionSet.length > 0
                                  ? AssessmentSection(
                                      widget.course,
                                      widget.title,
                                      widget.identifier,
                                      _microSurvey != null
                                          ? _microSurvey
                                          : _questionSet,
                                      markSurveyCompleted,
                                      widget.batchId,
                                      _assessmentInfo.expectedDuration,
                                      isNewAssessment:
                                          widget.fileUrl != null ? false : true,
                                      primaryCategory:
                                          _assessmentInfo.primaryCategory,
                                      objectType: _assessmentInfo.objectType,
                                      assessmentsInfo:
                                          _assessmentInfo.questions,
                                      updateContentProgress:
                                          widget.parentAction,
                                      parentCourseId: widget.parentCourseId)
                                  : ErrorScreen())));
                    }
                  : null,
              style: TextButton.styleFrom(
                backgroundColor: !(_retakeInfo != null &&
                        _retakeInfo['attemptsAllowed'] ==
                            _retakeInfo['attemptsMade'])
                    ? AppColors.primaryBlue
                    : AppColors.grey40,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                    side: BorderSide(color: AppColors.primaryBlue)),
              ),
              child: Text(
                !(_retakeInfo != null &&
                        _retakeInfo['attemptsAllowed'] ==
                            _retakeInfo['attemptsMade'])
                    ? AppLocalizations.of(context).mStartAssessment
                    : AppLocalizations.of(context)
                        .mAssessmentAttemptsExceededMessage,
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
