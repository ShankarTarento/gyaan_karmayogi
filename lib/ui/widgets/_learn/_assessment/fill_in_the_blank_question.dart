import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import './../../../../constants/index.dart';
import './../../../../feedback/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FillInTheBlankQuestion extends StatefulWidget {
  final question;
  final String questionText;
  final int currentIndex;
  final answerGiven;
  final bool showAnswer;
  final ValueChanged<Map> parentAction;
  // final bool isNewAssessment;
  final String id;
  FillInTheBlankQuestion(this.question, this.questionText, this.currentIndex,
      this.answerGiven, this.showAnswer, this.parentAction,
      {this.id});
  @override
  _FillInTheBlankQuestionState createState() => _FillInTheBlankQuestionState();
}

class _FillInTheBlankQuestionState extends State<FillInTheBlankQuestion> {
  // List<String> _questionText = [];
  String _qId;
  List<String> _alphabets =
      List.generate(10, (index) => String.fromCharCode(index + 65));
  String _questionWithBlank;
  List<dynamic> _answer = [];
  int _blankCount;
  dynamic _question;
  final List<TextEditingController> _optionController = [];

  @override
  void initState() {
    _qId = widget.id;
    _setText();
    super.initState();
  }

  _setText() async {
    _optionController.clear();
    String substring = "_______________";
    RegExp regExp = RegExp(substring);
    _blankCount = regExp.allMatches(widget.questionText).length;
    _questionWithBlank = widget.questionText;
    _question = widget.question;
    for (var i = 0;
        i <
            ((_question != null && _question['options'] != null)
                ? _question['options'].length
                : _blankCount);
        i++) {
      _optionController.add(TextEditingController());
      _questionWithBlank = _questionWithBlank.replaceFirst(
          "_______________", " ___(${_alphabets[i].toLowerCase()})___");
    }

    _answer = widget.answerGiven.sublist(0);
    for (var i = 0; i < _answer.length; i++) {
      _optionController[i].text = _answer[i];
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    _optionController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_qId != widget.id) {
      setState(() {
        _setText();
        _qId = widget.id;
      });
    }
    // print((widget.answerGiven.length > 0 && widget.showAnswer) &&
    //     (_answer.length > 0 && _answer[0] != null));
    return Container(
        height: MediaQuery.of(context).size.height - 30,
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: 15),
              child: Text(
                AppLocalizations.of(context).mStaticFillInTheBlanks,
                style: GoogleFonts.lato(
                  color: FeedbackColors.black87,
                  fontWeight: FontWeight.w400,
                  fontSize: 14.0,
                ),
              ),
            ),
            Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: Divider(
                  color: AppColors.greys60,
                )),
            Container(
              padding: const EdgeInsets.only(bottom: 15),
              child: HtmlWidget(
                _questionWithBlank,
                textStyle: GoogleFonts.lato(
                    color: FeedbackColors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 16.0,
                    height: 1.5),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Column(
              children: [
                for (var i = 0;
                    i <
                        ((_question != null && _question['options'] != null)
                            ? _question['options'].length
                            : _blankCount);
                    i++)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                          width: MediaQuery.of(context).size.width,
                          // margin: const EdgeInsets.only(bottom: 0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: TextField(
                            controller: _optionController[i],
                            // initialValue: (widget.answerGiven.length > 0) &&
                            //         (_answer.length > i && _answer[i] != null)
                            //     ? _answer[i]
                            //     : '',
                            onEditingComplete: () {
                              widget.parentAction({
                                'index': _qId,
                                'isCorrect': (_question != null &&
                                        _question['options'] != null)
                                    ? _question['options'][i]['answer']
                                    : true,
                                'value': _answer.sublist(0),
                              });
                              return true;
                            },
                            onChanged: (value) {
                              if (_answer.length > i) {
                                _answer.insert(i, value);
                                _answer.removeAt(i + 1);
                              } else if (_answer.length < i) {
                                for (var j = 0; j < i; j++) {
                                  _answer.add('');
                                }
                                _answer.insert(i, value);
                              } else {
                                _answer.insert(i, value);
                              }
                              if (_answer.length > 0) {
                                widget.parentAction({
                                  'index': _qId,
                                  'isCorrect': (_question != null &&
                                          _question['options'] != null)
                                      ? _question['options'][i]['answer']
                                      : true,
                                  'value': _answer,
                                });
                              }
                            },
                            onSubmitted: (value) {
                              // if (_answer.length > 0) {
                              widget.parentAction({
                                'index': _qId,
                                'isCorrect': (_question != null &&
                                        _question['options'] != null)
                                    ? _question['options'][i]['answer']
                                    : true,
                                'value': _answer,
                              });
                              // }
                            },
                            enabled: widget.showAnswer ? false : true,
                            textInputAction: TextInputAction.done,
                            style: GoogleFonts.lato(fontSize: 14.0),
                            keyboardType: TextInputType.name,
                            decoration: InputDecoration(
                                filled: true,
                                fillColor: !widget.showAnswer
                                    ? Colors.white
                                    : (_answer.length > i && _answer[i] != null)
                                        ? (_question['options'][i]['value']
                                                        ['body']
                                                    .toString() ==
                                                _answer[i].toString()
                                            ? FeedbackColors.positiveLightBg
                                            : FeedbackColors.negativeLightBg)
                                        : FeedbackColors.negativeLightBg,
                                contentPadding:
                                    EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                                border: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: AppColors.grey16)),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: AppColors.grey16),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: AppColors.primaryThree),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: widget.showAnswer
                                          ? (_answer.length > i &&
                                                  _answer[i] != null)
                                              ? (_question['options'][i]
                                                              ['value']['body']
                                                          .toString() ==
                                                      _answer[i].toString()
                                                  ? FeedbackColors.positiveLight
                                                  : FeedbackColors
                                                      .negativeLight)
                                              : FeedbackColors.negativeLight
                                          : AppColors.grey16),
                                ),
                                helperText: '',
                                hintStyle: GoogleFonts.lato(
                                    color: AppColors.grey40,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400),
                                icon: Text(_alphabets[i].toLowerCase())),
                          )),
                      (widget.showAnswer &&
                              _question['options'][i]['value']['body']
                                      .toString() !=
                                  (_answer.length > i ? _answer[i] : ''))
                          ? Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 20, left: 24),
                              child: Row(
                                // mainAxisAlignment: MainAxisAlignment.s,
                                children: [
                                  Text(
                                    AppLocalizations.of(context).mStaticCorrectAnswer,
                                    style: GoogleFonts.lato(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.greys87),
                                  ),
                                  Text(
                                    _question['options'][i]['value']['body']
                                        .toString(),
                                    style: GoogleFonts.lato(
                                        color: AppColors.positiveLight),
                                  ),
                                ],
                              ),
                            )
                          : Center()
                    ],
                  ),
              ],
            ),
          ],
        ));
  }
}
