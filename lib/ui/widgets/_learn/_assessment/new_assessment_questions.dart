import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/error.dart';
import 'package:karmayogi_mobile/ui/widgets/index.dart';
import '../../../../constants/_constants/telemetry_constants.dart';
import './../../../../feedback/constants.dart';
import './../../../../constants/index.dart';
import './../../../../services/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NewAssessmentQuestions extends StatefulWidget {
  final course;
  final String title;
  final String identifier;
  final microSurvey;
  final ValueChanged<double> parentAction;
  final String batchId;
  final duration;
  final bool isNewAssessment;
  final String primaryCategory;
  final String objectType;
  final assessmentInfo;
  final int sectionIndex;
  final getAnsweredQuestions;
  final answeredQuestions;
  final bool isLastSection;
  final navigateToNextSection;
  final currentRunningTime;
  final isFullAnswered;
  final submitSurvey;
  final int assessmentSectionLength;
  final int selectedSection;
  final generateInteractTelemetryData;
  NewAssessmentQuestions(this.course, this.title, this.identifier,
      this.microSurvey, this.parentAction, this.batchId, this.duration,
      {this.isNewAssessment = false,
      this.primaryCategory,
      this.objectType,
      this.assessmentInfo,
      this.sectionIndex,
      this.getAnsweredQuestions,
      this.answeredQuestions,
      this.isLastSection = false,
      this.navigateToNextSection,
      this.currentRunningTime,
      this.isFullAnswered,
      this.submitSurvey,
      this.assessmentSectionLength,
      this.selectedSection,
      this.generateInteractTelemetryData});

  @override
  _NewAssessmentQuestionsState createState() => _NewAssessmentQuestionsState();
}

class _NewAssessmentQuestionsState extends State<NewAssessmentQuestions> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final LearnService learnService = LearnService();
  final TelemetryService telemetryService = TelemetryService();

  List _microSurvey = [];
  List _questionAnswers = [];
  int _questionIndex = 0;
  bool _nextQuestion = false;
  bool _showAnswer = false;
  // List _options = [];
  // int _questionShuffled;

  Timer _timer;
  int _start;
  String _timeFormat;
  int timeLimit;
  int _sectionIndex;
  bool _showQuestionIndex = true;
  List _flaggedQuestions = [];
  int _answeredQuestion = 0;

  @override
  void initState() {
    super.initState();
    timeLimit = widget.currentRunningTime != null
        ? widget.currentRunningTime
        : (widget.duration);
    _sectionIndex = widget.sectionIndex;

    if (widget.microSurvey.runtimeType != String) {
      _loadInitialData();
    }
  }

  _loadInitialData() {
    if (widget.answeredQuestions != null &&
        widget.answeredQuestions.length > 0) {
      _questionAnswers = widget.answeredQuestions;
    }
    _nextQuestion = widget.primaryCategory == PrimaryCategory.finalAssessment;

    _start = timeLimit;
    _microSurvey = widget.microSurvey;

    if (widget.primaryCategory == PrimaryCategory.finalAssessment) {
      startTimer();
    }
  }

  @override
  void dispose() async {
    if (_questionAnswers.length > 0 && widget.getAnsweredQuestions != null) {
      widget.getAnsweredQuestions(widget.sectionIndex, _questionAnswers);
    }
    super.dispose();
    _timer?.cancel();
  }

  String formatHHMMSS(int seconds) {
    int hours = (seconds / 3600).truncate();
    seconds = (seconds % 3600).truncate();
    int minutes = (seconds / 60).truncate();

    String hoursStr = (hours).toString().padLeft(2, '0');
    String minutesStr = (minutes).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');

    if (hours == 0) {
      return '$minutesStr:$secondsStr';
    }

    return '$hoursStr:$minutesStr:$secondsStr';
  }

  void startTimer() {
    _timeFormat = formatHHMMSS(_start);
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer?.cancel();
            _questionIndex = _microSurvey.length;
            if (widget.assessmentSectionLength > 1) {
              for (var i = 0;
                  i <
                      (widget.assessmentSectionLength -
                          (widget.selectedSection + 1));
                  i++) {
                Navigator.of(context).pop();
              }
            } else {
              widget.submitSurvey();
            }
          });
        } else {
          if (mounted) {
            setState(() {
              _start--;
            });
          }
        }
        _timeFormat = formatHHMMSS(_start);
      },
    );
  }

  void updateQuestionIndex(int value) {
    setState(() {
      _questionIndex = value;
    });
  }

  void setUserAnswer(Map answer) {
    bool matchDetected = false;
    for (int i = 0; i < _questionAnswers.length; i++) {
      if (_questionAnswers[i]['index'] == answer['index']) {
        setState(() {
          _questionAnswers[i]['value'] = answer['value'];
          _questionAnswers[i]['isCorrect'] = answer['isCorrect'];
          matchDetected = true;
        });
      }
    }
    if (!matchDetected) {
      setState(() {
        _questionAnswers.add(answer);
      });
    }
    if (_questionAnswers.length > 0 && widget.getAnsweredQuestions != null) {
      widget.getAnsweredQuestions(widget.sectionIndex, _questionAnswers);
    }
    _answeredQuestion = _questionAnswers.length;
  }

  bool _answerGiven(_questionIndex) {
    bool answerGiven = false;
    for (int i = 0; i < _questionAnswers.length; i++) {
      if (_questionAnswers[i]['index'] == _questionIndex) {
        if (_questionAnswers[i]['value'] != null) {
          if (_questionAnswers[i]['value'].length > 0) {
            answerGiven = true;
          }
        } else {
          answerGiven = false;
        }
      }
    }
    return answerGiven;
  }

  int _getRadioQuestionCorrectAnswer(List options) {
    int answerIndex;
    if (options != null) {
      for (int i = 0; i < options.length; i++) {
        if (options[i]['answer'] is String) {
          if (options[i]['answer'] != null &&
              options[i]['answer'].toString().trim().toLowerCase() == 'true') {
            answerIndex = i;
          }
        } else if (options[i]['answer'] != null && options[i]['answer']) {
          answerIndex = i;
        }
      }
    }
    return answerIndex;
  }

  // List _shuffleOptions(List options) {
  //   if (_questionShuffled != _questionIndex) {
  //     _options = [];
  //     for (int i = 0; i < options.length; i++) {
  //       _options.add(options[i]);
  //     }
  //     _options = _options..shuffle();
  //     _questionShuffled = _questionIndex;
  //   }
  //   // print(_options);
  //   return _options;
  // }

  _getQuestionAnswer(_index) {
    var givenAnswer;
    for (int i = 0; i < _questionAnswers.length; i++) {
      if (_questionAnswers[i]['index'] == _index) {
        givenAnswer = _questionAnswers[i]['value'];
      }
    }
    if (_microSurvey[_questionIndex]['qType'] ==
            AssessmentQuestionType.radioType.toUpperCase() ||
        (_microSurvey[_questionIndex]['qType'] ==
                AssessmentQuestionType.fitb.toUpperCase() ||
            _microSurvey[_questionIndex]['qType'] ==
                AssessmentQuestionType.fitb)) {
      return givenAnswer != null ? givenAnswer : '';
    } else {
      return givenAnswer != null ? givenAnswer : [];
    }
  }

  Future<bool> _onSubmitPressed(contextMain) {
    widget.generateInteractTelemetryData(
        widget.identifier, TelemetrySubType.submit);
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
                          AppLocalizations.of(context)
                              .mStaticQuestionsNotAttempted,
                          style: GoogleFonts.montserrat(
                              decoration: TextDecoration.none,
                              color: Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        )),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _questionIndex++;
                        });
                        _timer?.cancel();
                        widget.submitSurvey();
                        Navigator.of(context).pop(true);
                      },
                      child: roundedButton(
                          AppLocalizations.of(context).mAssessmentSubmit,
                          Colors.white,
                          AppColors.primaryBlue),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop(true);
                          Navigator.of(context).pop(true);
                        },
                        child: roundedButton(
                            AppLocalizations.of(context).mStaticYesTakeMeBack,
                            AppColors.primaryBlue,
                            Colors.white),
                      ),
                    )
                  ],
                ),
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.sectionIndex != null && widget.sectionIndex != _sectionIndex) {
      _loadInitialData();
    }
    return widget.microSurvey.runtimeType == String
        ? ErrorScreen()
        : WillPopScope(
            onWillPop: () async => false,
            child: Stack(
              children: [
                Scaffold(
                    key: _scaffoldKey,
                    appBar: _getAppbar(context),
                    body: (widget.primaryCategory ==
                                PrimaryCategory.finalAssessment &&
                            _start == 0)
                        ? Center(
                            child: Text(AppLocalizations.of(context)
                                .mTimeLimitExceeded))
                        : _buildLayout(),
                    bottomSheet: (_questionIndex < _microSurvey.length)
                        ? _actionButton()
                        : PageLoader()),
              ],
            ),
          );
  }

  Widget _getAppbar(ctx) {
    return AppBar(
      titleSpacing: 0,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
            widget.assessmentSectionLength > 1 ? Icons.arrow_back : Icons.clear,
            color: FeedbackColors.black60),
        onPressed: () {
          if (widget.assessmentSectionLength == 1) {
            if (widget.isFullAnswered()) {
              setState(() {
                _questionIndex++;
                _nextQuestion = !(widget.primaryCategory ==
                    PrimaryCategory.practiceAssessment);
                _showAnswer = false;
              });
              widget.submitSurvey();
              _timer?.cancel();
            } else {
              _onSubmitPressed(ctx);
            }
          } else {
            Navigator.of(context).pop();
          }
        },
      ),
      automaticallyImplyLeading: false,
      title: Container(
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width * 0.7,
        child: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(
              // widget.assessmentInfo['name'],
              widget.title,
              overflow: TextOverflow.fade,
              style: GoogleFonts.montserrat(
                  color: FeedbackColors.black87,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.25),
            )),
      ),
      actions: [
        (_questionIndex >= _microSurvey.length)
            ? Center()
            : (widget.primaryCategory == PrimaryCategory.finalAssessment)
                ? Container(
                    child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _timeFormat != null &&
                              _questionIndex < _microSurvey.length
                          ? Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                width: 80,
                                margin: EdgeInsets.only(left: 16, right: 16),
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                    color:
                                        AppColors.primaryBlue.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                        color: AppColors.primaryBlue,
                                        width: 1)),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 2),
                                      child: Icon(
                                        Icons.timer_outlined,
                                        color: AppColors.primaryBlue,
                                        size: 16,
                                      ),
                                    ),
                                    Container(
                                      width: 40,
                                      child: Text(
                                        '$_timeFormat' + ' ',
                                        style: GoogleFonts.montserrat(
                                          color: AppColors.primaryBlue,
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )
                          : SizedBox.shrink(),
                    ],
                  ))
                : SizedBox.shrink(),
      ],
    );
  }

  Widget roundedButton(String buttonLabel, Color bgColor, Color textColor) {
    var optionButton = Container(
      width: MediaQuery.of(context).size.width - 40,
      padding: EdgeInsets.all(10),
      alignment: FractionalOffset.center,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.all(const Radius.circular(4.0)),
        border: bgColor == Colors.white
            ? Border.all(color: FeedbackColors.black40)
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
    return optionButton;
  }

  Widget _buildLayout() {
    return Container(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Stack(
        children: [
          Column(
            children: [
              if (_questionIndex < _microSurvey.length)
                Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: Container(
                      color: Colors.white, child: _generatePagination()),
                ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
          Positioned.fill(
            child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: EdgeInsets.only(bottom: 8),
                  height: 24,
                  width: 24,
                  decoration: BoxDecoration(
                    color: Color(0XFF1B2133),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        _showQuestionIndex = !_showQuestionIndex;
                      });
                    },
                    iconSize: 20,
                    icon: _showQuestionIndex
                        ? Icon(
                            Icons.arrow_drop_up,
                            color: AppColors.white,
                          )
                        : Icon(
                            Icons.arrow_drop_down,
                            color: AppColors.white,
                          ),
                    padding: EdgeInsets.zero,
                  ),
                )),
          ),
        ],
      ),
      _assessmentProgress(),
      _assessmentWidget(),
    ]));
  }

  Widget _generatePagination() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _totalAnswerItem('${_microSurvey.length - _answeredQuestion}',
                    AppLocalizations.of(context).mStaticNotAnswered),
                SizedBox(
                  width: 32.0,
                ),
                _totalAnswerItem('${_answeredQuestion}',
                    AppLocalizations.of(context).mStaticAnswered),
              ],
            ),
            _headerToolTip(),
          ],
        ),
      ),
      Visibility(
        visible: _showQuestionIndex,
        child: _questionIndexWidget(),
      )
    ]);
  }

  Widget _totalAnswerItem(String value, String label) {
    return Container(
      margin: EdgeInsets.all(4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(1.0),
            child: Text(
              value,
              style: GoogleFonts.lato(
                color: AppColors.darkBlue,
                fontWeight: FontWeight.w600,
                fontSize: 16.0,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(1.0),
            child: Text(
              label,
              style: GoogleFonts.lato(
                color: FeedbackColors.black60,
                fontWeight: FontWeight.w400,
                fontSize: 12.0,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _headerToolTip() {
    return Container(
      margin: EdgeInsets.only(top: 8, bottom: 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Divider(
                  thickness: 1,
                  color: AppColors.grey16,
                ),
              ),
              Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context).mStaticQuestion,
                      style: GoogleFonts.lato(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: AppColors.greys87),
                    ),
                    JustTheTooltip(
                      showDuration: const Duration(seconds: 30),
                      tailBaseWidth: 16,
                      triggerMode: TooltipTriggerMode.tap,
                      backgroundColor: AppColors.black.withOpacity(0.96),
                      borderRadius: BorderRadius.all(Radius.circular(24)),
                      child: Material(
                        color: Colors.transparent,
                        shape: const CircleBorder(),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Icon(Icons.info_outline,
                              color: AppColors.greys60, size: 14),
                        ),
                      ),
                      content: Container(
                        height: 180,
                        width: 260,
                        child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(2),
                                child: Row(
                                  children: [
                                    Stack(
                                      children: [
                                        Container(
                                          height: 28,
                                          width: 44,
                                          margin: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: AppColors.white,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(0)),
                                            border: Border.all(
                                              color: AppColors.primaryBlue,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          height: 28,
                                          width: 44,
                                          margin: const EdgeInsets.all(6),
                                          child: Center(
                                              child: Icon(
                                            Icons.check,
                                            color: AppColors.primaryBlue,
                                          )),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryBlue
                                                .withOpacity(0.16),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(0)),
                                            border: Border.all(
                                              color: AppColors.primaryBlue,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 16),
                                      child: Text(
                                        AppLocalizations.of(context)
                                            .mStaticAnswered,
                                        style: GoogleFonts.lato(
                                          color: AppColors.white,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16.0,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(2),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 28,
                                      width: 44,
                                      margin: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: AppColors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(0)),
                                        border: Border.all(
                                          color:
                                              AppColors.black.withOpacity(0.4),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 16),
                                      child: Text(
                                        AppLocalizations.of(context)
                                            .mStaticNotAnswered,
                                        style: GoogleFonts.lato(
                                          color: AppColors.white,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16.0,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(2),
                                child: Row(
                                  children: [
                                    Stack(
                                      children: [
                                        Container(
                                          height: 28,
                                          width: 44,
                                          margin: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: AppColors.white,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(50)),
                                            border: Border.all(
                                                color: AppColors.primaryOne),
                                          ),
                                        ),
                                        Container(
                                          height: 28,
                                          width: 44,
                                          margin: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryOne
                                                .withOpacity(0.16),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(50)),
                                            border: Border.all(
                                                color: AppColors.primaryOne),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 16),
                                      child: Text(
                                        AppLocalizations.of(context)
                                            .mStaticFlagged,
                                        style: GoogleFonts.lato(
                                          color: AppColors.white,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16.0,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      margin: EdgeInsets.all(40),
                    ),
                  ],
                ),
                padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
              ),
              Expanded(
                child: Divider(
                  thickness: 1,
                  color: AppColors.grey16,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _questionIndexWidget() {
    return SizedBox(
      height: MediaQuery.of(context).size.width * 0.33,
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(left: 34, bottom: 16, right: 34),
          alignment: Alignment.center,
          child: Wrap(
            direction: Axis.horizontal,
            children: _microSurvey.map((item) {
              return InkWell(
                  onTap: () {
                    widget.generateInteractTelemetryData(
                        _microSurvey[_microSurvey.indexOf(item)]['identifier'],
                        TelemetrySubType.click);
                    _questionIndex = _microSurvey.indexOf(item);
                    setState(() {
                      if (_answerGiven(_microSurvey[_microSurvey.indexOf(item)]
                          ['identifier'])) {
                        _showAnswer = widget.primaryCategory ==
                            PrimaryCategory.practiceAssessment;
                      } else {
                        _showAnswer = false;
                      }
                      _nextQuestion = (_questionIndex > 0) ? true : false;
                    });
                  },
                  child: Container(
                    height: 28,
                    width: 44,
                    margin: const EdgeInsets.all(6),
                    child: Center(
                      child: (_answerGiven(
                                  _microSurvey[_microSurvey.indexOf(item)]
                                      ['identifier']) &&
                              _questionIndex != _microSurvey.indexOf(item))
                          ? Icon(
                              Icons.check,
                              color: AppColors.darkBlue,
                            )
                          : Text(
                              '${_microSurvey.indexOf(item) + 1}',
                              style: GoogleFonts.lato(
                                color:
                                    _questionIndex == _microSurvey.indexOf(item)
                                        ? AppColors.darkBlue
                                        : FeedbackColors.black60,
                                fontWeight:
                                    _questionIndex == _microSurvey.indexOf(item)
                                        ? FontWeight.w700
                                        : FontWeight.w400,
                                fontSize: 14,
                              ),
                            ),
                    ),
                    decoration: BoxDecoration(
                      color: (_flaggedQuestions
                              .contains(_microSurvey.indexOf(item)))
                          ? AppColors.primaryOne.withOpacity(0.16)
                          : _questionIndex == _microSurvey.indexOf(item)
                              ? AppColors.white
                              : _answerGiven(
                                      _microSurvey[_microSurvey.indexOf(item)]
                                          ['identifier'])
                                  ? AppColors.darkBlue.withOpacity(0.16)
                                  : Colors.white,
                      borderRadius: BorderRadius.all((_flaggedQuestions
                              .contains(_microSurvey.indexOf(item)))
                          ? Radius.circular(50)
                          : Radius.circular(0)),
                      border: Border.all(
                          color: (_flaggedQuestions
                                  .contains(_microSurvey.indexOf(item)))
                              ? AppColors.primaryOne
                              : _questionIndex == _microSurvey.indexOf(item)
                                  ? AppColors.darkBlue
                                  : _answerGiven(_microSurvey[_microSurvey
                                          .indexOf(item)]['identifier'])
                                      ? AppColors.darkBlue
                                      : AppColors.black.withOpacity(0.4)),
                    ),
                  ));
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _assessmentProgress() {
    return LinearProgressIndicator(
      value: ((_questionIndex + 1) / _microSurvey.length) ?? 0,
      backgroundColor: Colors.black.withOpacity(0.16),
      valueColor: AlwaysStoppedAnimation<Color>(AppColors.darkBlue),
    );
  }

  Widget _assessmentWidget() {
    return Expanded(
        child: Container(
      color: Colors.white,
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Row(
                children: [
                  Text(
                    AppLocalizations.of(context).mStaticQuestion,
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.w400,
                      fontSize: 16.0,
                    ),
                  ),
                  Text(
                    ' ${_questionIndex + 1} ${AppLocalizations.of(context).mStaticOutOf} ${_microSurvey.length}',
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.w700,
                      fontSize: 16.0,
                    ),
                  ),
                  Spacer(),
                  widget.primaryCategory != PrimaryCategory.finalAssessment
                      ? IconButton(
                          onPressed: () {
                            if (_answerGiven(
                                _microSurvey[_questionIndex]['identifier'])) {
                              setState(() {
                                _showAnswer = true;
                              });
                            } else {
                              _showDialogBox();
                            }
                          },
                          icon: Icon(
                            Icons.remove_red_eye,
                            color: _showAnswer
                                ? AppColors.darkBlue
                                : AppColors.greys60,
                            size: 24,
                          ))
                      : Center(),
                  IconButton(
                      iconSize: 24,
                      onPressed: () {
                        if (!_flaggedQuestions.contains(_questionIndex)) {
                          setState(() {
                            _flaggedQuestions.add(_questionIndex);
                          });
                        } else {
                          setState(() {
                            _flaggedQuestions.remove(_questionIndex);
                          });
                        }
                      },
                      icon: (_flaggedQuestions.contains(_questionIndex))
                          ? Icon(
                              Icons.flag,
                              color: AppColors.primaryOne,
                            )
                          : Icon(
                              Icons.flag_outlined,
                              color: AppColors.greys60,
                            )),
                ],
              ),
            ),
            _questionIndex >= _microSurvey.length
                ? PageLoader(
                    bottom: 200,
                  )
                : _microSurvey[_questionIndex]['qType'] ==
                        AssessmentQuestionType.radioType.toUpperCase()
                    ? _radioAssessment()
                    : _microSurvey[_questionIndex]['qType'] ==
                            AssessmentQuestionType.checkBoxType.toUpperCase()
                        ? _multiSelectAssessment()
                        : _microSurvey[_questionIndex]['qType'] ==
                                AssessmentQuestionType.matchCase.toUpperCase()
                            ? _matchCaseAssessment()
                            : Container(
                                color: Colors.white,
                                child: FillInTheBlankQuestion(
                                  widget.primaryCategory ==
                                          PrimaryCategory.finalAssessment
                                      ? _microSurvey[_questionIndex]['choices']
                                      : _microSurvey[_questionIndex]
                                          ['editorState'],
                                  _microSurvey[_questionIndex]['body'],
                                  _questionIndex + 1,
                                  _getQuestionAnswer(
                                      _microSurvey[_questionIndex]
                                          ['identifier']),
                                  _showAnswer,
                                  setUserAnswer,
                                  id: _microSurvey[_questionIndex]
                                      ['identifier'],
                                ))
          ],
        ),
      ),
    ));
  }

  Widget _radioAssessment() {
    return Container(
        child: RadioQuestion(
          widget.primaryCategory == PrimaryCategory.finalAssessment
              ? _microSurvey[_questionIndex]['choices']
              : _microSurvey[_questionIndex]['editorState'],
          _microSurvey[_questionIndex]['body'],
          _questionIndex + 1,
          _getQuestionAnswer(_microSurvey[_questionIndex]['identifier']),
          _showAnswer,
          _getRadioQuestionCorrectAnswer(
              widget.primaryCategory == PrimaryCategory.finalAssessment
                  ? _microSurvey[_questionIndex]['choices']['options']
                  : _microSurvey[_questionIndex]['editorState']['options']),
          setUserAnswer,
          isNewAssessment: true,
          id: _microSurvey[_questionIndex]['identifier'],
        ));
  }

  Widget _multiSelectAssessment() {
    return Container(
        child: MultiSelectQuestion(
          widget.primaryCategory == PrimaryCategory.finalAssessment
              ? _microSurvey[_questionIndex]['choices']
              : _microSurvey[_questionIndex]['editorState'],
          _microSurvey[_questionIndex]['body'],
          _questionIndex + 1,
          _getQuestionAnswer(_microSurvey[_questionIndex]['identifier']),
          _showAnswer,
          setUserAnswer,
          isNewAssessment: true,
          id: _microSurvey[_questionIndex]['identifier'],
        ));
  }

  Widget _matchCaseAssessment() {
    return Container(
        child: MatchCaseQuestion(
          widget.primaryCategory == PrimaryCategory.finalAssessment
              ? _microSurvey[_questionIndex]['choices']
              : _microSurvey[_questionIndex]['editorState'],
          _microSurvey[_questionIndex]['body'],
          _microSurvey[_questionIndex]['rhsChoices'],
          _questionIndex + 1,
          _getQuestionAnswer(_microSurvey[_questionIndex]['identifier']),
          _showAnswer,
          setUserAnswer,
          isNewAssessment: true,
          id: _microSurvey[_questionIndex]['identifier'],
        ));
  }

  Widget _actionButton() {
    return Container(
      height: _questionIndex >= _microSurvey.length ? 0 : 74,
      padding: ((_nextQuestion ||
                  widget.primaryCategory == PrimaryCategory.finalAssessment) &&
              _questionIndex != 0)
          ? EdgeInsets.fromLTRB(8, 16, 12, 18)
          : EdgeInsets.fromLTRB(12, 16, 12, 18),
      decoration: BoxDecoration(color: Colors.white),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          ((_nextQuestion) && _questionIndex != 0)
              ? Container(
                  height: 58,
                  width: MediaQuery.of(context).size.width * 0.44,
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        if (_questionIndex != 0) {
                          _questionIndex--;
                          _nextQuestion = true;
                          _showAnswer = false;
                        }
                      });
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                          side: BorderSide(color: AppColors.darkBlue)),
                      // onSurface: Colors.grey,
                    ),
                    child: Text(
                      AppLocalizations.of(context).mStaticPrevious,
                      style: GoogleFonts.lato(
                        color: AppColors.darkBlue,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
              : Container(),
          Container(
            height: 58,
            width: _questionIndex != 0
                ? MediaQuery.of(context).size.width * 0.44
                : widget.primaryCategory == PrimaryCategory.finalAssessment
                    ? (MediaQuery.of(context).size.width - 24)
                    : widget.primaryCategory ==
                                PrimaryCategory.practiceAssessment &&
                            _questionIndex == 0
                        ? MediaQuery.of(context).size.width * 0.9
                        : (MediaQuery.of(context).size.width * 0.44),
            child: TextButton(
              onPressed: () {
                if (_questionIndex == _microSurvey.length - 1 &&
                    _questionAnswers.length < _microSurvey.length) {
                  if (widget.isLastSection) {
                    if (widget.assessmentSectionLength > 1) {
                      for (var i = 0;
                          i <
                              (widget.assessmentSectionLength -
                                  widget.selectedSection);
                          i++) {
                        Navigator.of(context).pop();
                      }
                    } else {
                      _onSubmitPressed(context);
                    }
                  } else {
                    widget.navigateToNextSection(widget.sectionIndex + 1);
                  }
                } else if (_questionIndex == _microSurvey.length - 1) {
                  if (widget.isLastSection && widget.isFullAnswered()) {
                    if (widget.assessmentSectionLength > 1) {
                      for (var i = 0;
                          i <
                              (widget.assessmentSectionLength -
                                  widget.selectedSection);
                          i++) {
                        Navigator.of(context).pop();
                      }
                    } else {
                      setState(() {
                        _questionIndex++;
                        _nextQuestion = !(widget.primaryCategory ==
                            PrimaryCategory.practiceAssessment);
                        _showAnswer = false;
                      });
                      widget.submitSurvey();
                      _timer?.cancel();
                    }
                  } else if (!widget.isLastSection) {
                    widget.navigateToNextSection(widget.sectionIndex + 1);
                  } else {
                    if (widget.assessmentSectionLength > 1) {
                      for (var i = 0;
                          i <
                              (widget.assessmentSectionLength -
                                  widget.selectedSection);
                          i++) {
                        Navigator.of(context).pop();
                      }
                    } else {
                      _onSubmitPressed(context);
                    }
                  }
                } else {
                  setState(() {
                    _questionIndex++;
                    _nextQuestion = true;
                    _showAnswer = false;
                  });
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: AppColors.darkBlue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                    side: BorderSide(color: AppColors.darkBlue)),
              ),
              child: Text(
                _questionIndex < _microSurvey.length - 1
                    ? AppLocalizations.of(context).mNextQuestion
                    : !widget.isLastSection
                        ? AppLocalizations.of(context).mNextSection
                        : AppLocalizations.of(context).mStaticDone,
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

  _showDialogBox() => {
        showDialog(
            barrierDismissible: true,
            context: context,
            builder: (BuildContext contxt) => FutureBuilder(
                future:
                    Future.delayed(Duration(seconds: 3)).then((value) => true),
                builder: (BuildContext futureContext, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    Navigator.of(contxt).pop();
                  }
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      AlertDialog(
                          insetPadding: EdgeInsets.symmetric(horizontal: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          actionsPadding: EdgeInsets.zero,
                          actions: [
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: AppColors.negativeLight),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: Container(
                                      child: TitleRegularGrey60(
                                        AppLocalizations.of(context)
                                            .mGiveYourAnswerBeforeShowingAnswer,
                                        fontSize: 14,
                                        color: AppColors.appBarBackground,
                                        maxLines: 3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ]),
                    ],
                  );
                }))
      };
}
