import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/feedback/models/micro_survey_model.dart';
import '../../../constants/index.dart';
import './../../constants.dart';

class CheckboxTypeQuestion extends StatefulWidget {
  final question;
  final int currentIndex;
  final answerGiven;
  final bool showAnswer;
  final ValueChanged<Map> parentAction;
  CheckboxTypeQuestion(this.question, this.currentIndex, this.answerGiven,
      this.showAnswer, this.parentAction);
  @override
  _CheckboxTypeQuestionState createState() => _CheckboxTypeQuestionState();
}

class _CheckboxTypeQuestionState extends State<CheckboxTypeQuestion> {
  Map<int, bool> isChecked = {
    1: false,
    2: false,
    3: false,
    4: false,
  };
  // List _answerGiven = [];
  List<int> _correctAnswer = [2, 3];
  MicroSurvey _questions;
  dynamic _answerGiven;

  @override
  void initState() {
    super.initState();
    print(widget.answerGiven);
    _questions = widget.question;
    _answerGiven = widget.answerGiven;
    if (_questions.options.length > 4) {
      for (var i = 5; i < _questions.options.length + 1; i++) {
        final entry = <int, bool>{i: false};
        isChecked.addEntries(entry.entries);
      }
    }
    // if (_questions.answer != null) {
    //   _answerGiven = _questions.answer;
    //   for (int i = 0; i < _questions.options.length; i++) {
    //     if (_answerGiven.contains(_questions.options[i]['value'])) {
    //       isChecked[i + 1] = true;
    //     }
    //   }
    // }
    if (_answerGiven != null) {
      for (int i = 0; i < _questions.options.length; i++) {
        if (_answerGiven.contains(_questions.options[i]['key'])) {
          isChecked[i + 1] = true;
        } else {
          isChecked[i + 1] = false;
        }
      }
    } else {
      _answerGiven = [];
      for (var i = 0; i < _questions.options.length; i++) {
        isChecked[i + 1] = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.question.id != _questions.id) {
      setState(() {
        _questions = null;
        _questions = widget.question;
        _answerGiven = widget.answerGiven;
      });
      if (_questions.options.length > 4) {
        for (var i = 5; i < _questions.options.length + 1; i++) {
          final entry = <int, bool>{i: false};
          isChecked.addEntries(entry.entries);
        }
      }
      // if (_questions.answer != null) {
      //   _answerGiven = _questions.answer;
      //   for (int i = 0; i < _questions.options.length; i++) {
      //     if (_answerGiven.contains(_questions.options[i]['value'])) {
      //       isChecked[i + 1] = true;
      //     }
      //   }
      // }
      if (_answerGiven != null) {
        for (int i = 0; i < _questions.options.length; i++) {
          if (_answerGiven.contains(_questions.options[i]['key'])) {
            isChecked[i + 1] = true;
          } else {
            isChecked[i + 1] = false;
          }
        }
      } else {
        _answerGiven = [];
        for (var i = 0; i < _questions.options.length; i++) {
          isChecked[i + 1] = false;
        }
      }
    }
    return Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: 15),
              child: Text(
                _questions.question,
                style: GoogleFonts.lato(
                  color: FeedbackColors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 16.0,
                ),
              ),
            ),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _questions.options.length,
              itemBuilder: (context, index) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  // padding: const EdgeInsets.all(15),
                  margin: const EdgeInsets.only(top: 10, bottom: 10),
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
                                        ? FeedbackColors.positiveLightBg
                                        : Colors.white,
                    borderRadius: BorderRadius.all(const Radius.circular(4.0)),
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
                                              _correctAnswer.contains(index) &&
                                              widget.showAnswer
                                          ? FeedbackColors.positiveLight
                                          : isChecked[index + 1]
                                              ? AppColors.darkBlue
                                              : FeedbackColors.black16,
                    ),
                  ),
                  child: CheckboxListTile(
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: _correctAnswer.contains(index) &&
                              widget.showAnswer
                          ? FeedbackColors.positiveLight
                          : !_correctAnswer.contains(index) && widget.showAnswer
                              ? FeedbackColors.negativeLight
                              : AppColors.darkBlue,
                      dense: true,
                      //font change
                      title: Text(
                        _questions.options[index]['key'].toString(),
                        style: GoogleFonts.lato(
                          color: FeedbackColors.black87,
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                      value: isChecked[index + 1],
                      onChanged: (bool value) {
                        if (!widget.showAnswer) {
                          if (value) {
                            if (!_answerGiven
                                .contains(_questions.options[index]['key'])) {
                              _answerGiven
                                  .add(_questions.options[index]['key']);
                            }
                          } else {
                            if (_answerGiven
                                .contains(_questions.options[index]['key'])) {
                              _answerGiven
                                  .remove(_questions.options[index]['key']);
                            }
                          }
                          widget.parentAction({
                            'index': _questions.id - 1,
                            'question': _questions.question,
                            'value': _answerGiven
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
        ));
  }
}
