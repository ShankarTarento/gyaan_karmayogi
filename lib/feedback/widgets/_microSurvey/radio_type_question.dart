import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/feedback/models/micro_survey_model.dart';
import '../../../constants/index.dart';
import './../../constants.dart';

class RadioTypeQuestion extends StatefulWidget {
  final question;
  final int currentIndex;
  final answerGiven;
  final bool showAnswer;
  final ValueChanged<Map> parentAction;
  RadioTypeQuestion(this.question, this.currentIndex, this.answerGiven,
      this.showAnswer, this.parentAction);
  @override
  _RadioTypeQuestionState createState() => _RadioTypeQuestionState();
}

class _RadioTypeQuestionState extends State<RadioTypeQuestion> {
  String _radioValue = '';
  int _correctAnswer = 2;
  MicroSurvey _questions;

  @override
  void initState() {
    super.initState();
    _radioValue = widget.answerGiven;
    _questions = widget.question;
    // _radioValue = _questions.answer != null
    //     ? _questions.answer
    //     : widget.answerGiven;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.question.id != _questions.id) {
      _questions = widget.question;
      _radioValue = widget.answerGiven;
    }
    // _radioValue = widget.answerGiven;
    return Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text('${widget.currentIndex}, ${widget.answerGiven}, $_radioValue'),
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
                      color: _radioValue == _questions.options[index]['key'] &&
                              _correctAnswer == index &&
                              widget.showAnswer
                          ? FeedbackColors.positiveLightBg
                          : _radioValue == _questions.options[index]['key'] &&
                                  _correctAnswer != index &&
                                  widget.showAnswer
                              ? FeedbackColors.negativeLightBg
                              : _correctAnswer == index && widget.showAnswer
                                  ? FeedbackColors.positiveLightBg
                                  : Colors.white,
                      borderRadius:
                          BorderRadius.all(const Radius.circular(4.0)),
                      border: Border.all(
                          color: _radioValue ==
                                      _questions.options[index]['key'] &&
                                  _correctAnswer == index &&
                                  widget.showAnswer
                              ? FeedbackColors.positiveLight
                              : _radioValue ==
                                          _questions.options[index]['key'] &&
                                      _correctAnswer != index &&
                                      widget.showAnswer
                                  ? FeedbackColors.negativeLight
                                  : _radioValue ==
                                          _questions.options[index]['key']
                                      ? AppColors.darkBlue
                                      : _correctAnswer == index &&
                                              widget.showAnswer
                                          ? FeedbackColors.positiveLight
                                          : FeedbackColors.black16),
                    ),
                    child: RadioListTile(
                      selected: true,
                      activeColor: AppColors.darkBlue,
                      groupValue: _radioValue,
                      title: Text(
                        _questions.options[index]['key'].toString(),
                        style: GoogleFonts.lato(
                          color: FeedbackColors.black87,
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                      value: _questions.options[index]['key'].toString(),
                      onChanged: (value) {
                        if (!widget.showAnswer) {
                          widget.parentAction({
                            'index': _questions.id - 1,
                            'question': _questions.question,
                            'value': value
                          });
                          setState(() {
                            _radioValue = value;
                          });
                        }
                      },
                    ));
              },
            ),
          ],
        ));
  }
}
