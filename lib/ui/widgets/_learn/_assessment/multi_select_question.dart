import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import '../../../../constants/index.dart';
import './../../../../feedback/constants.dart';

class MultiSelectQuestion extends StatefulWidget {
  final question;
  final String _questionText;
  final int currentIndex;
  final answerGiven;
  final bool showAnswer;
  final ValueChanged<Map> parentAction;
  final bool isNewAssessment;
  final String id;
  MultiSelectQuestion(this.question, this._questionText, this.currentIndex,
      this.answerGiven, this.showAnswer, this.parentAction,
      {this.isNewAssessment = false, this.id});
  @override
  _MultiSelectQuestionQuestionState createState() =>
      _MultiSelectQuestionQuestionState();
}

class _MultiSelectQuestionQuestionState extends State<MultiSelectQuestion> {
  Map<int, bool> isChecked = {
    1: false,
    2: false,
    3: false,
    4: false,
  };
  List selectedOptions = [];
  List<int> _correctAnswer = [];
  String _qId;

  @override
  void initState() {
    super.initState();
    _qId = widget.isNewAssessment ? widget.id : widget.question['questionId'];
    _updateChanges();
  }

  _updateChanges() async {
    if (widget.question['options'].length > 4) {
      for (var i = 5; i < widget.question['options'].length + 1; i++) {
        final entry = <int, bool>{i: false};
        isChecked.addEntries(entry.entries);
      }
    }
    if (widget.answerGiven != null) {
      selectedOptions = widget.answerGiven;
      for (int i = 0; i < widget.question['options'].length; i++) {
        if (selectedOptions.contains(widget.isNewAssessment
            ? widget.question['options'][i]['value']['value']
            : widget.question['options'][i]['optionId'])) {
          isChecked[i + 1] = true;
        }
        if (widget.isNewAssessment
            ? (widget.question['options'][i]['answer'] != null
                ? widget.question['options'][i]['answer']
                : false)
            : widget.question['options'][i]['isCorrect']) {
          _correctAnswer.add(i);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_qId !=
        (widget.isNewAssessment ? widget.id : widget.question['questionId'])) {
      isChecked = isChecked = {
        1: false,
        2: false,
        3: false,
        4: false,
      };
      _updateChanges();
      _qId = widget.isNewAssessment ? widget.id : widget.question['questionId'];
    }
    return SingleChildScrollView(
      child: Container(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.only(bottom: 15),
                child: HtmlWidget(
                  widget._questionText != null
                      ? widget._questionText
                      : widget.question['question'],
                  textStyle: GoogleFonts.lato(
                      color: FeedbackColors.black87,
                      fontWeight: FontWeight.w400,
                      fontSize: 14.0,
                      height: 1.5
                  ),
                ),
              ),
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: widget.question['options'].length,
                itemBuilder: (context, index) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    // padding: const EdgeInsets.all(15),
                    margin: const EdgeInsets.only(top: 10, bottom: 4),
                    decoration: BoxDecoration(
                      color: isChecked[index + 1] &&
                              _correctAnswer.contains(index) &&
                              widget.showAnswer
                          ? FeedbackColors.positiveLightBg
                          : isChecked[index + 1] &&
                                  !_correctAnswer.contains(index) &&
                                  widget.showAnswer
                              ? FeedbackColors.negativeLightBg
                              : _correctAnswer.contains(index) &&
                                      widget.showAnswer
                                  ? FeedbackColors.positiveLightBg
                                  : _correctAnswer.contains(index) &&
                                          widget.showAnswer
                                      ? FeedbackColors.negativeLightBg
                                      : isChecked[index + 1] &&
                                              _correctAnswer.contains(index) &&
                                              widget.showAnswer
                                          ? FeedbackColors.positiveLightBg : isChecked[index + 1]
                                            ? AppColors.darkBlue.withOpacity(0.16)
                                              : Colors.black.withOpacity(0.04),
                      borderRadius:
                          BorderRadius.all(const Radius.circular(10.0)),
                      border: Border.all(
                        color: isChecked[index + 1] &&
                                _correctAnswer.contains(index) &&
                                widget.showAnswer
                            ? FeedbackColors.positiveLight
                            : isChecked[index + 1] &&
                                    !_correctAnswer.contains(index) &&
                                    widget.showAnswer
                                ? FeedbackColors.negativeLight
                                : _correctAnswer.contains(index) &&
                                        widget.showAnswer
                                    ? FeedbackColors.positiveLight
                                    : _correctAnswer.contains(index) &&
                                            widget.showAnswer
                                        ? FeedbackColors.negativeLight
                                        : isChecked[index + 1] &&
                                                _correctAnswer
                                                    .contains(index) &&
                                                widget.showAnswer
                                            ? FeedbackColors.positiveLight
                                            : isChecked[index + 1]
                                                ? AppColors.darkBlue
                                                : Colors.black.withOpacity(0.04),
                      ),
                    ),
                    child: CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        side: const BorderSide(width: 0.8),
                        activeColor:
                            _correctAnswer.contains(index) && widget.showAnswer
                                ? FeedbackColors.positiveLight
                                : !_correctAnswer.contains(index) &&
                                        widget.showAnswer
                                    ? FeedbackColors.negativeLight
                                    : AppColors.darkBlue,
                        dense: true,
                        //font change
                        title: Text(
                          widget.isNewAssessment
                              ? widget.question['options'][index]['value']
                                      ['body']
                                  .toString()
                              : widget.question['options'][index]['text'],
                          style: GoogleFonts.lato(
                            color: FeedbackColors.black87,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        value: isChecked[index + 1],
                        onChanged: (bool value) {
                          if (!widget.showAnswer) {
                            if (value) {
                              if (!selectedOptions.contains(
                                  widget.isNewAssessment
                                      ? widget.question['options'][index]
                                          ['value']['value']
                                      : widget.question['options'][index]
                                          ['optionId'])) {
                                selectedOptions.add(widget.isNewAssessment
                                    ? widget.question['options'][index]['value']
                                        ['value']
                                    : widget.question['options'][index]
                                        ['optionId']);
                              }
                            } else {
                              if (selectedOptions.contains(
                                  widget.isNewAssessment
                                      ? widget.question['options'][index]
                                          ['value']['value']
                                      : widget.question['options'][index]
                                          ['optionId'])) {
                                selectedOptions.remove(widget.isNewAssessment
                                    ? widget.question['options'][index]['value']
                                        ['value']
                                    : widget.question['options'][index]
                                        ['optionId']);
                              }
                            }
                            widget.parentAction({
                              'index': _qId,
                              'isCorrect': widget.isNewAssessment
                                  ? widget.question['options'][index]['answer']
                                  : widget.question['options'][index]
                                      ['isCorrect'],
                              'value': selectedOptions
                            });
                            setState(() {
                              isChecked[index + 1] = value;
                            });
                          }
                        }),
                  );
                },
              ),
            ],
          )),
    );
  }
}
