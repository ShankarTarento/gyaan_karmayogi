import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/feedback/constants.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/models/_models/telemetry_event_model.dart';
import 'package:karmayogi_mobile/services/_services/learn_service.dart';
import 'package:karmayogi_mobile/ui/widgets/_learn/_assessment/assessment_completed_screen.dart';
import 'package:karmayogi_mobile/ui/widgets/_learn/_assessment/assessment_verification_screen.dart';
import 'package:karmayogi_mobile/ui/widgets/_learn/_assessment/new_assessment_questions.dart';
import 'package:karmayogi_mobile/ui/widgets/index.dart';
import 'package:karmayogi_mobile/util/telemetry.dart';
import 'package:karmayogi_mobile/util/telemetry_db_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AssessmentSection extends StatefulWidget {
  final course;
  final String title;
  final String identifier;
  final questionSets;
  final ValueChanged<double> parentAction;
  final String batchId;
  final duration;
  final bool isNewAssessment;
  final String primaryCategory;
  final String objectType;
  final assessmentsInfo;
  final updateContentProgress;
  final String fileUrl;
  final String parentCourseId;

  const AssessmentSection(this.course, this.title, this.identifier,
      this.questionSets, this.parentAction, this.batchId, this.duration,
      {Key key,
      this.isNewAssessment = false,
      this.primaryCategory,
      this.objectType,
      this.assessmentsInfo,
      this.updateContentProgress,
      this.fileUrl,
      this.parentCourseId})
      : super(key: key);

  @override
  State<AssessmentSection> createState() => _AssessmentSectionState();
}

class _AssessmentSectionState extends State<AssessmentSection> {
  final LearnService learnService = LearnService();

  String _timeFormat;
  int _start;
  Timer _timer;
  List _selected = [];
  int _selectedSection;

  String userId;
  String userSessionId;
  String messageIdentifier;
  String departmentId;
  String pageIdentifier;
  String telemetryType;
  String pageUri;
  List allEventsData = [];
  String deviceIdentifier;
  var telemetryEventData;

  @override
  void initState() {
    super.initState();
    _start = widget.duration;

    if (_start == widget.duration) {
      telemetryType = TelemetryType.player;
      pageIdentifier = TelemetryPageIdentifier.assessmentPlayerPageId;
      pageUri =
          "viewer/quiz/${widget.identifier}?primaryCategory=Learning%20Resource&collectionId=${widget.parentCourseId}&collectionType=Course&batchId=${widget.course['batches'] != null ? (widget.course['batches'].runtimeType == String ? jsonDecode(widget.course['batches']).last['batchId'] : widget.course['batches'].last['batchId']) : (widget.batchId != null ? widget.batchId : '')}";
      _generateTelemetryData();
    }

    if (widget.primaryCategory == PrimaryCategory.finalAssessment) {
      startTimer();
    }
  }

  void _generateTelemetryData() async {
    deviceIdentifier = await Telemetry.getDeviceIdentifier();
    userId = await Telemetry.getUserId();
    userSessionId = await Telemetry.generateUserSessionId();
    messageIdentifier = await Telemetry.generateUserSessionId();
    departmentId = await Telemetry.getUserDeptId();

    Map eventData1 = Telemetry.getStartTelemetryEvent(
        deviceIdentifier,
        userId,
        departmentId,
        pageIdentifier,
        userSessionId,
        messageIdentifier,
        telemetryType,
        pageUri,
        objectId: widget.identifier,
        objectType: widget.primaryCategory,
        env: TelemetryEnv.learn, l1: widget.parentCourseId);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData1);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());
    Map eventData2 = Telemetry.getImpressionTelemetryEvent(
        deviceIdentifier,
        userId,
        departmentId,
        pageIdentifier,
        userSessionId,
        messageIdentifier,
        telemetryType,
        pageUri,
        env: TelemetryEnv.learn,
        objectId: widget.identifier,
        objectType: widget.primaryCategory);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData2);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());
    allEventsData.add(eventData1);
    allEventsData.add(eventData2);
    // await telemetryService.triggerEvent(allEventsData);
  }

  void _generateInteractTelemetryData(String contentId, String subtype) async {
    deviceIdentifier = await Telemetry.getDeviceIdentifier();
    userId = await Telemetry.getUserId();
    userSessionId = await Telemetry.generateUserSessionId();
    messageIdentifier = await Telemetry.generateUserSessionId();
    departmentId = await Telemetry.getUserDeptId();
    Map eventData = Telemetry.getInteractTelemetryEvent(
        deviceIdentifier,
        userId,
        departmentId,
        pageIdentifier,
        userSessionId,
        messageIdentifier,
        contentId,
        subtype,
        env: TelemetryEnv.learn,
        objectType: widget.primaryCategory);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());
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
            timer.cancel();
            _submitSurvey();
          });
        } else {
          setState(() {
            _start--;
          });
        }
        _timeFormat = formatHHMMSS(_start);
      },
    );
  }

  _getAnsweredStatus(int index, List<dynamic> selectedAnswers) {
    var selected = _selected.sublist(0);
    if (selected.length > 0) {
      for (var i = 0; i < selected.length; i++) {
        if (!selected.any((element) =>
            element['index'] == index &&
            element['selectedAnswers'] == selectedAnswers)) {
          if (selected[i]['index'] == index && selected.length > i) {
            _selected[i] = {'index': index, 'selectedAnswers': selectedAnswers};
            _selected.remove(selected[i + 1]);
          } else {
            _selected.add({'index': index, 'selectedAnswers': selectedAnswers});
          }
        }
      }
    } else {
      _selected.add({'index': index, 'selectedAnswers': selectedAnswers});
    }

    _selected.sort((a, b) => a['index'].compareTo(b['index']));
  }

  Future<void> _submitSurvey() async {
    _generateInteractTelemetryData(widget.identifier, TelemetrySubType.submit);
    var questionAnswers = [];
    var courseAssessmentData = [];

    for (var q = 0; q < widget.questionSets.length; q++) {
      _selected.forEach((selectedItem) {
        if (selectedItem['index'] == q) {
          questionAnswers = selectedItem['selectedAnswers'];
        }
      });
      List assessmentQuestions = widget.questionSets[q].sublist(0);

      for (int i = 0; i < widget.questionSets[q].length; i++) {
        var userSelected;
        widget.questionSets[q][i]['editorState'] =
            widget.questionSets[q][i]['editorState'] != null
                ? widget.questionSets[q][i]['editorState']
                : widget.questionSets[q][i]['choices'];
        assessmentQuestions[i]['editorState'] =
            assessmentQuestions[i]['editorState'] != null
                ? assessmentQuestions[i]['editorState']
                : assessmentQuestions[i]['choices'];
        for (int j = 0; j < questionAnswers.length; j++) {
          if (questionAnswers[j]['index'] ==
              widget.questionSets[q][i]['identifier']) {
            if (questionAnswers[j]['value'] != null)
              userSelected = questionAnswers[j];
          }
        }
        if (assessmentQuestions[i]['qType'] ==
            AssessmentQuestionType.matchCase.toUpperCase()) {
          for (int k = 0;
              k < widget.questionSets[q][i]['editorState']['options'].length;
              k++) {
            if (userSelected != null) {
              for (var m = 0; m < userSelected['value'].length; m++) {
                if (m ==
                    widget.questionSets[q][i]['editorState']['options'][k]
                        ['value']['value']) {
                  assessmentQuestions[i]['editorState']['options'][k]['index'] =
                      widget.questionSets[q][i]['editorState']['options'][k]
                              ['value']['value']
                          .toString();
                  assessmentQuestions[i]['editorState']['options'][k]
                      ['selectedAnswer'] = userSelected['value'][m];
                }
              }
            }
          }
        } else if (assessmentQuestions[i]['qType'] ==
            AssessmentQuestionType.radioType.toUpperCase()) {
          for (int k = 0;
              k < widget.questionSets[q][i]['editorState']['options'].length;
              k++) {
            if (userSelected != null) {
              if (widget.questionSets[q][i]['editorState']['options'][k]
                          ['value']['body']
                      .toString() ==
                  userSelected['value'].toString()) {
                assessmentQuestions[i]['editorState']['options'][k]['index'] =
                    widget.questionSets[q][i]['editorState']['options'][k]
                            ['value']['value']
                        .toString();
                assessmentQuestions[i]['editorState']['options'][k]
                    ['selectedAnswer'] = true;
              }
            }
          }
        } else if (assessmentQuestions[i]['qType'] ==
            AssessmentQuestionType.checkBoxType.toUpperCase()) {
          for (int k = 0;
              k < widget.questionSets[q][i]['editorState']['options'].length;
              k++) {
            if (userSelected != null) {
              userSelected['value'].forEach((element) {
                if ((element) ==
                    widget.questionSets[q][i]['editorState']['options'][k]
                        ['value']['value']) {
                  assessmentQuestions[i]['editorState']['options'][k]['index'] =
                      widget.questionSets[q][i]['editorState']['options'][k]
                              ['value']['value']
                          .toString();
                  assessmentQuestions[i]['editorState']['options'][k]
                      ['selectedAnswer'] = true;
                }
              });
            }
          }
        } else if (userSelected != null &&
            assessmentQuestions[i]['qType'] ==
                AssessmentQuestionType.ftb.toUpperCase()) {
          if (widget.questionSets[q][i]['editorState'] != null) {
            for (int k = 0;
                k < widget.questionSets[q][i]['editorState']['options'].length;
                k++) {
              if (userSelected != null) {
                for (var m = 0; m < userSelected['value'].length; m++) {
                  if (m ==
                      widget.questionSets[q][i]['editorState']['options'][k]
                          ['value']['value']) {
                    assessmentQuestions[i]['editorState']['options'][k]
                        ['index'] = widget.questionSets[q][i]['editorState']
                            ['options'][k]['value']['value']
                        .toString();
                    assessmentQuestions[i]['editorState']['options'][k]
                        ['selectedAnswer'] = userSelected['value'][m];
                  }
                }
              }
            }
          } else {
            assessmentQuestions[i]['editorState'] = {'options': []};

            for (var m = 0; m < userSelected['value'].length; m++) {
              assessmentQuestions[i]['editorState']['options'].add(
                  {'index': '$m', 'selectedAnswer': userSelected['value'][m]});
            }
          }
        }
      }

      var submittedAnswers = [];

      assessmentQuestions.map((element) {
        if (element['editorState'] != null &&
            element['editorState']['question'] != null) {
          element['editorState'].remove('question');
        }
        if (element['editorState'] != null) {
          element['editorState']['options'].forEach((option) {
            if (option['selectedAnswer'] != null) {
              option.remove('answer');
              option.remove('value');
            }
          });
        }
        if (element['editorState'] == null) {
          element['editorState'] = {'options': []};
        }
        List editorStateOptions = element['editorState']['options'].sublist(0);
        element['editorState']['options'] = editorStateOptions
            .where((element) => element['value'] == null)
            .toList();
        submittedAnswers.add({
          "identifier": element['identifier'],
          "mimeType": element['mimeType'],
          "objectType": element['objectType'],
          "primaryCategory":
              element['qType'] == AssessmentQuestionType.radioType.toUpperCase()
                  ? 'Single Choice Question'
                  : element['primaryCategory'],
          "qType": element['qType'],
          "editorState": element['editorState'],
          "question": element['body']
        });
      }).toString();

      // log('SubmittedAnswers: ' + jsonEncode(submittedAnswers));

      Map assessmentData = {
        "identifier": widget.assessmentsInfo[q]['identifier'],
        "objectType": widget.assessmentsInfo[q]['objectType'],
        "primaryCategory": widget.assessmentsInfo[q]['primaryCategory'],
        "scoreCutoffType": widget.assessmentsInfo[q]['scoreCutoffType'],
        "children": submittedAnswers
      };

      courseAssessmentData.add(assessmentData);
    }
    Map surveyData = {
      'batchId': widget.batchId,
      'identifier': widget.identifier,
      'primaryCategory': widget.primaryCategory,
      'courseId': widget.parentCourseId,
      "isAssessment": true,
      'objectType': widget.objectType,
      'timeLimit': widget.duration,
      'children': courseAssessmentData
    };

    var response = await learnService.submitAssessmentNew(surveyData);
    var contents = jsonDecode(response.body);
    bool submittedSuccessfully =
        (response.statusCode == 200 || response.statusCode == 201);

    if (submittedSuccessfully &&
        widget.primaryCategory == PrimaryCategory.practiceAssessment) {
      await Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => AssessmentCompletedScreen(
                formatHHMMSS(widget.duration - _start),
                contents['result'],
                assessmentTitle: widget.title,
                assessmentsInfo: widget.assessmentsInfo,
                primaryCategory: widget.primaryCategory,
                course: widget.course,
                identifier: widget.identifier,
                updateContentProgress: widget.updateContentProgress,
                batchId: widget.batchId,
                fromSectionalCutoff: widget.questionSets.length > 1,
              )));
    } else if (submittedSuccessfully &&
        widget.primaryCategory == PrimaryCategory.finalAssessment) {
      Map request = {
        'assessmentId': widget.identifier,
        'batchId': widget.batchId,
        'courseId': widget.parentCourseId,
      };
      Map requestBody = {
        'request': request,
      };

      Navigator.of(context).pop();
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        enableDrag: false,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return Container(
              child: AssessmentVerificationScreen(
            formatHHMMSS(widget.duration - _start),
            requestBody,
            assessmentTitle: widget.title,
            assessmentsInfo: widget.assessmentsInfo,
            primaryCategory: widget.primaryCategory,
            course: widget.course,
            identifier: widget.identifier,
            updateContentProgress: widget.updateContentProgress,
            batchId: widget.batchId,
            fromSectionalCutoff: widget.questionSets.length > 1,
          ));
        },
      );
    } else {
      widget.parentAction(0.0);
      await Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => Scaffold(body: ErrorPage())));
    }
    if ((widget.course['batches'] != null || widget.batchId != null) &&
        submittedSuccessfully) {
      _updateContentProgress();
      widget.parentAction(100.0);
    }
  }

  Future<void> _updateContentProgress() async {
    List<String> current = [];

    current.add(widget.questionSets.last.length.toString());
    String courseId = widget.parentCourseId;
    String batchId = widget.batchId;
    String contentId = widget.identifier;
    int status = 2;
    String contentType = EMimeTypes.newAssessment;
    var maxSize = widget.course['duration'];
    // double completionPercentage =
    //     status == 2 ? 100.0 : (_start / maxSize) * 100;
    double completionPercentage = 100.0;
    await learnService.updateContentProgress(courseId, batchId, contentId,
        status, contentType, current, maxSize, completionPercentage,
        isAssessment: true);
    // print('response: ' + response.toString());
  }

  Future<bool> _onSubmitPressed() {
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
                    AppLocalizations.of(context).mStaticQuestionsNotAttempted,
                    style: GoogleFonts.montserrat(
                        decoration: TextDecoration.none,
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  )),
              GestureDetector(
                onTap: () async {
                  _timer?.cancel();
                  Navigator.of(context).pop(true);
                  await _submitSurvey();
                },
                child: roundedButton(
                    AppLocalizations.of(context).mStaticNoSubmit,
                    Colors.white,
                    FeedbackColors.primaryBlue),
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
                      FeedbackColors.primaryBlue,
                      Colors.white),
                ),
              )
            ],
          ),
        ),
      ),
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

  Widget _getAppbar() {
    return AppBar(
      titleSpacing: 0,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.clear, color: FeedbackColors.black60),
        onPressed: () {
          if (_isFullAnswered()) {
            _submitSurvey();
          } else {
            _onSubmitPressed();
          }
        },
      ),
      title: Container(
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width * 0.7,
        child: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(
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
        if (widget.primaryCategory == PrimaryCategory.finalAssessment)
          Container(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _timeFormat != null
                  ? Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 80,
                        margin: EdgeInsets.only(left: 16, right: 16),
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: AppColors.primaryBlue, width: 1)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 2),
                              child: Icon(
                                Icons.timer_outlined,
                                color: FeedbackColors.primaryBlue,
                                size: 16,
                              ),
                            ),
                            Container(
                              width: 40,
                              child: Text(
                                '$_timeFormat' + ' ',
                                style: GoogleFonts.montserrat(
                                  color: FeedbackColors.primaryBlue,
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
      ],
    );
  }

  _getSectionStatusIndicators(Color borderColor, Color fillColor, String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 12, 8),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            margin: EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
                color: fillColor,
                border: Border.all(
                  color: borderColor,
                  width: 1,
                )),
          ),
          Text(text, style: GoogleFonts.lato()),
        ],
      ),
    );
  }

  _navigateToNextSection(int index) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => NewAssessmentQuestions(
              widget.course,
              widget.title,
              widget.identifier,
              widget.questionSets[index],
              widget.parentAction,
              widget.batchId,
              widget.duration,
              isNewAssessment: true,
              primaryCategory: widget.primaryCategory,
              objectType: widget.objectType,
              assessmentInfo: widget.assessmentsInfo[index],
              sectionIndex: index,
              getAnsweredQuestions: _getAnsweredStatus,
              answeredQuestions: _selected
                          .indexWhere((element) => element['index'] == index) ==
                      -1
                  ? []
                  : _selected[_selected
                          .indexWhere((element) => element['index'] == index)]
                      ['selectedAnswers'],
              isLastSection: index == widget.assessmentsInfo.length - 1,
              navigateToNextSection: _navigateToNextSection,
              currentRunningTime: _start,
              isFullAnswered: _isFullAnswered,
              submitSurvey: _submitSurvey,
              assessmentSectionLength: widget.questionSets.length,
              selectedSection: _selectedSection,
              generateInteractTelemetryData: _generateInteractTelemetryData,
            )));
  }

  bool _isFullAnswered() {
    int answered = 0;
    int total = 0;
    widget.questionSets.forEach((element) {
      total = total + element.length;
    });

    _selected.forEach((element) {
      answered = answered + element['selectedAnswers'].length;
    });
    // print("Total: $total, Answered: $answered");

    return total == answered;
  }

  @override
  void dispose() async {
    _timer?.cancel();
    super.dispose();
    Map eventData = Telemetry.getEndTelemetryEvent(
        deviceIdentifier,
        userId,
        departmentId,
        pageIdentifier,
        userSessionId,
        messageIdentifier,
        _start,
        telemetryType,
        pageUri,
        {},
        objectId: widget.identifier,
        objectType: widget.primaryCategory,
        env: TelemetryEnv.learn, l1: widget.parentCourseId);
    allEventsData.add(eventData);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());
  }

  @override
  Widget build(BuildContext context) {
    return widget.questionSets.length > 1
        ? WillPopScope(
            onWillPop: () async => false,
            child: Scaffold(
                appBar: _getAppbar(),
                body: _buildLayout(),
                bottomSheet: _actionButton()),
          )
        : widget.questionSets.first.length > 0
            ? NewAssessmentQuestions(
                widget.course,
                widget.title,
                widget.identifier,
                widget.questionSets.first,
                widget.parentAction,
                widget.batchId,
                widget.duration,
                isNewAssessment: true,
                primaryCategory: widget.primaryCategory,
                objectType: widget.objectType,
                assessmentInfo: widget.assessmentsInfo.first,
                isLastSection: true,
                submitSurvey: _submitSurvey,
                isFullAnswered: _isFullAnswered,
                sectionIndex: 0,
                getAnsweredQuestions: _getAnsweredStatus,
                answeredQuestions:
                    _selected.length > 0 ? _selected[0]['selectedAnswers'] : [],
                assessmentSectionLength: widget.questionSets.length,
                generateInteractTelemetryData: _generateInteractTelemetryData,
              )
            : ErrorPage();
  }

  Widget _buildLayout() {
    return Container(
      color: AppColors.appBarBackground,
      child: Column(
        children: [
          _statusIndicatorWidget(),
          Divider(
            thickness: 16,
            color: AppColors.grey08,
          ),
          _assessmentListWidget(),
        ],
      ),
    );
  }

  Widget _statusIndicatorWidget() {
    return Container(
      color: AppColors.appBarBackground,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              _getSectionStatusIndicators(
                  FeedbackColors.positiveLight,
                  FeedbackColors.positiveLightBg,
                  AppLocalizations.of(context).mCommoncompleted),
              _getSectionStatusIndicators(
                  FeedbackColors.negativeLight,
                  FeedbackColors.negativeLightBg,
                  AppLocalizations.of(context).mStaticIncomplete),
              _getSectionStatusIndicators(
                  FeedbackColors.black40,
                  FeedbackColors.background,
                  AppLocalizations.of(context).mCommonnotStarted),
              _getSectionStatusIndicators(
                  FeedbackColors.primaryBlue,
                  FeedbackColors.primaryBlueBg,
                  AppLocalizations.of(context).mStaticSelected),
            ],
          ),
        ),
      ),
    );
  }

  Widget _assessmentListWidget() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.only(bottom: 100),
        color: AppColors.appBarBackground,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              for (var i = 0; i < widget.assessmentsInfo.length; i++)
                InkWell(
                  onTap: () {
                    setState(() {
                      _selectedSection = i;
                    });
                    _navigateToNextSection(i);
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              widget.assessmentsInfo[i]['name'],
                              style: GoogleFonts.lato(
                                  fontWeight: FontWeight.w700, fontSize: 16),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '${AppLocalizations.of(context).mStaticToPass}' +
                                  '${widget.assessmentsInfo[i]['minimumPassPercentage'].toString() + '%'}',
                              style: GoogleFonts.lato(),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '${AppLocalizations.of(context).mStaticTotalQuestions}' +
                                  '${widget.assessmentsInfo[i]['maxQuestions'].toString()}',
                              style: GoogleFonts.lato(),
                            ),
                          ),
                          Text(
                              widget.assessmentsInfo[i]
                                  ['additionalInstructions'],
                              style: GoogleFonts.lato()),
                        ],
                      ),
                    ),
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.grey08,
                            blurRadius: 6.0,
                            spreadRadius: 0,
                            offset: Offset(
                              3,
                              3,
                            ),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(16),
                        color: _selected.indexWhere(
                                    (element) => element['index'] == i) !=
                                -1
                            ? (_selected[_selected.indexWhere((element) => element['index'] == i)]
                                            ['selectedAnswers']
                                        .length ==
                                    widget.questionSets[i].length
                                ? FeedbackColors.positiveLightBg
                                : (_selected[_selected.indexWhere((element) => element['index'] == i)]
                                                    ['selectedAnswers']
                                                .length >
                                            0 &&
                                        _selected[_selected.indexWhere((element) =>
                                                        element['index'] == i)]
                                                    ['selectedAnswers']
                                                .length <
                                            widget.questionSets[i].length)
                                    ? FeedbackColors.negativeLightBg
                                    : FeedbackColors.background)
                            : FeedbackColors.background,
                        border: Border.all(
                          color: _selected.indexWhere(
                                      (element) => element['index'] == i) !=
                                  -1
                              ? (_selected[_selected.indexWhere((element) => element['index'] == i)]
                                              ['selectedAnswers']
                                          .length ==
                                      widget.questionSets[i].length
                                  ? FeedbackColors.positiveLight
                                  : (_selected[_selected.indexWhere((element) => element['index'] == i)]
                                                      ['selectedAnswers']
                                                  .length >
                                              0 &&
                                          _selected[_selected.indexWhere((element) =>
                                                          element['index'] == i)]
                                                      ['selectedAnswers']
                                                  .length <
                                              widget.questionSets[i].length)
                                      ? FeedbackColors.negativeLight
                                      : FeedbackColors.black04)
                              : FeedbackColors.black40,
                          width: 1,
                        )),
                    //     shadowColor: Colors.black.withOpacity(0.5),
                    // elevation: 5,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButton() {
    return Container(
      height: 90,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.fromLTRB(8, 16, 16, 32),
      decoration: BoxDecoration(color: Colors.white),
      child: ElevatedButton(
        onPressed: () {
          if (_isFullAnswered()) {
            _submitSurvey();
          } else {
            _onSubmitPressed();
          }
        },
        style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all<Color>(AppColors.primaryBlue),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(63.0),
            ),
          ),
        ),
        child: Text(
          AppLocalizations.of(context).mStaticSubmitAssessment,
          style: GoogleFonts.lato(
            color: Colors.white,
            fontSize: 14.0,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
