import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../services/_services/learn_service.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class SurveyPage extends StatefulWidget {
  final Map surveyform;
  final ValueChanged<String> enrollParentAction;
  final String courseDetails;
  final int formId;
  final String courseId;
  final String batchId;
  final List batchList;
  SurveyPage(this.surveyform, this.enrollParentAction, this.courseDetails,
      this.formId, this.courseId,
      {this.batchId, this.batchList});
  @override
  SurveyPageState createState() => SurveyPageState();
}

enum Answer { yes, no }

class SurveyPageState extends State<SurveyPage> {
  List surveyFields = [];
  List mandatoryFields = [];
  bool enableConfirmbtn = false;
  int id = 1;
  String radioButtonItem = 'ONE';
  Map<int, Answer> answerVal = {};
  Map<int, List> checkboxAnswerVal = {};
  List<TextEditingController> textFieldControllers = [];
  final LearnService learnService = LearnService();
  List ratingValList = [];
  List checkedItems = [];
  var formResponse;
  bool showConfirmDialog = false;
  String startDate = '', endDate = '';

  @override
  void initState() {
    super.initState();
    surveyFields =
        widget.surveyform['fields'] != null ? widget.surveyform['fields'] : [];
    mandatoryFields = widget.surveyform['mandatoryFields'] != null
        ? widget.surveyform['mandatoryFields']
        : [];
    if (surveyFields.length == 0) {
      showConfirmDialog = true;
    } else {
      for (var i = 0; i < surveyFields.length; i++) {
        textFieldControllers.add(TextEditingController());
        textFieldControllers[i] = TextEditingController();
        ratingValList.add(0.0);
        checkedItems.add([]);
      }
    }
    widget.batchList.forEach((element) {
      if (element['batchId'] == widget.batchId) {
        startDate = element['startDate'];
        endDate = element['endDate'];
      }
    });
    checkSubmitBtnStatus();
  }

  checkSubmitBtnStatus() {
    if (checkMandatoryFieldsStatus()) {
      setState(() {
        enableConfirmbtn = true;
      });
    }
  }

  bool checkMandatoryFieldsStatus() {
    bool completed = true;
    for (var field in mandatoryFields) {
      switch (field['fieldType']) {
        case 'text':
          int textareaCount = 0, filledFieldCount = 0;
          for (int i = 0; i < surveyFields.length; i++) {
            if (surveyFields[i]['fieldType'] == FieldTypes.textarea.name) {
              textareaCount++;
            }
            if (textFieldControllers[i].text.length > 0) {
              filledFieldCount++;
            }
          }
          if (textareaCount != filledFieldCount) {
            completed = false;
          }
          break;
        default:
      }
      if (!completed) {
        break;
      }
    }
    return completed;
  }

  Widget question(text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: GoogleFonts.lato(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            letterSpacing: 0.25,
            color: AppColors.greys87),
      ),
    );
  }

  Widget textareaTypeQstn(list, index) {
    return Column(children: [
      question('${index + 1}. ${list['name']}'),
      SizedBox(
        height: 6,
      ),
      Container(
        height: 50,
        decoration: BoxDecoration(
            border: Border.all(width: 1, color: AppColors.grey16)),
        padding: EdgeInsets.only(left: 10, right: 10),
        child: TextField(
          controller: textFieldControllers[index],
          maxLines: 5,
          onChanged: (value) {
            setState(() {
              enableConfirmbtn = checkMandatoryFieldsStatus();
            });
          },
          keyboardType: TextInputType.multiline,
          style: GoogleFonts.lato(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.5,
              letterSpacing: 0.25,
              color: AppColors.greys87),
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context).mCommonTypeHere,
            border: InputBorder.none,
            hintStyle: GoogleFonts.lato(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.5,
                letterSpacing: 0.25,
                color: AppColors.grey40),
          ),
        ),
      )
    ]);
  }

  Widget radioTypeQstn(radiofield, index) {
    if (answerVal[index] == null) {
      answerVal[index] = Answer.yes;
    }
    return Column(children: [
      question('${index + 1}. ${radiofield['name']}'),
      SizedBox(height: 16),
      Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
        Container(
          padding: EdgeInsets.only(right: 26),
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(
              color: (answerVal[index] == Answer.yes)
                  ? AppColors.primaryThree
                  : AppColors.grey16,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Radio(
                value: Answer.yes,
                groupValue: answerVal[index],
                onChanged: (val) {
                  setState(() {
                    answerVal[index] = val;
                    checkMandatoryFieldsStatus();
                  });
                },
              ),
              Text(
                AppLocalizations.of(context).mStaticYes,
                style: GoogleFonts.lato(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    letterSpacing: 0.25,
                    color: AppColors.greys87),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        SizedBox(width: 24),
        Container(
          height: 50,
          padding: EdgeInsets.only(right: 26),
          decoration: BoxDecoration(
            border: Border.all(
              color: (answerVal[index] == Answer.no)
                  ? AppColors.primaryThree
                  : AppColors.grey16,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Radio(
                value: Answer.no,
                groupValue: answerVal[index],
                onChanged: (val) {
                  setState(() {
                    answerVal[index] = val;
                  });
                },
              ),
              Text(
                AppLocalizations.of(context).mStaticNo,
                style: GoogleFonts.lato(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    letterSpacing: 0.25,
                    color: AppColors.greys87),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ])
    ]);
  }

  Widget ratingTypeQstn(ratinglist, index) {
    return Column(children: [
      question('${index + 1}. ${ratinglist['name']}'),
      SizedBox(
        height: 8,
      ),
      Align(
        alignment: Alignment.centerLeft,
        child: RatingBar.builder(
          initialRating: ratingValList[index],
          minRating: 1,
          itemCount: 5,
          itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
          itemBuilder: (context, _) => Icon(
            Icons.star,
            color: AppColors.primaryOne,
            size: 5,
          ),
          onRatingUpdate: (rating) {
            ratingValList[index] = rating;
            checkMandatoryFieldsStatus();
          },
        ),
      )
    ]);
  }

  Widget checkboxTypeQstn(checklist, index) {
    if (checkboxAnswerVal[index] == null) {
      checkboxAnswerVal[index] = [];
    }
    return Column(children: [
      question('${index + 1}. ${checklist['name']}'),
      SizedBox(
        height: 8,
      ),
      ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount:
              checklist['values'] != null ? checklist['values'].length : 0,
          itemBuilder: (context, checkboxIndex) {
            return Container(
              decoration: BoxDecoration(
                  border: Border.all(width: 1, color: AppColors.grey16)),
              padding: EdgeInsets.only(
                left: 10,
                right: 10,
              ),
              margin: EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  Checkbox(
                    checkColor: AppColors.appBarBackground,
                    activeColor: AppColors.primaryThree,
                    value: checkboxAnswerVal[index]
                            .contains(checklist['values'][checkboxIndex]['key'])
                        ? true
                        : false,
                    onChanged: (bool value) {
                      setState(() {
                        if (value) {
                          checkboxAnswerVal[index]
                              .add(checklist['values'][checkboxIndex]['key']);
                        } else {
                          checkboxAnswerVal[index].remove(
                              checklist['values'][checkboxIndex]['key']);
                        }
                        checkMandatoryFieldsStatus();
                      });
                    },
                  ),
                  Text(checklist['values'][checkboxIndex]['key'])
                ],
              ),
            );
          })
    ]);
  }

  submitForm() async {
    var dataObject = {};
    for (int i = 0; i < surveyFields.length; i++) {
      if (surveyFields[i]['fieldType'] == FieldTypes.radio.name) {
        dataObject[surveyFields[i]['name']] = answerVal[i].name;
      } else if (surveyFields[i]['fieldType'] == FieldTypes.textarea.name) {
        dataObject[surveyFields[i]['name']] = textFieldControllers[i].text;
      } else if (surveyFields[i]['fieldType'] == FieldTypes.rating.name) {
        dataObject[surveyFields[i]['name']] = ratingValList[i];
      } else if (surveyFields[i]['fieldType'] == FieldTypes.checkbox.name) {
        dataObject[surveyFields[i]['name']] = checkboxAnswerVal[i];
      }
    }
    dataObject['Course ID and Name'] = widget.courseDetails;
    formResponse = await learnService.submitSurveyForm(
        widget.formId, dataObject, widget.courseId);
    if (formResponse == "success") {
      setState(() {
        showConfirmDialog = true;
      });
    }
  }

  Widget confirmMessage(text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 26),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              letterSpacing: 0.25,
              color: AppColors.greys87),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8, top: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  !showConfirmDialog
                      ? 'Enter the details to enroll'
                      : showConfirmDialog
                          ? 'You’re one step away from enrolling!'
                          : 'Are you sure you want to withdraw your request?',
                  style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      letterSpacing: 0.12,
                      color: AppColors.greys87),
                ),
              ),
            ),
            showConfirmDialog
                ? confirmMessage(
                    'This batch is active from $startDate  -  $endDate, kindly go through the content and be prepared.')
                : Center(),
            !showConfirmDialog
                ? Padding(
                    padding: const EdgeInsets.only(top: 18, right: 18),
                    child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: surveyFields.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 26),
                            child: surveyFields[index]['fieldType'] ==
                                    FieldTypes.radio.name
                                ? Container(
                                    color: Colors.white,
                                    child: radioTypeQstn(
                                        surveyFields[index], index),
                                  )
                                : surveyFields[index]['fieldType'] ==
                                        FieldTypes.textarea.name
                                    ? Container(
                                        color: Colors.white,
                                        child: textareaTypeQstn(
                                            surveyFields[index], index),
                                      )
                                    : surveyFields[index]['fieldType'] ==
                                            FieldTypes.rating.name
                                        ? Container(
                                            color: Colors.white,
                                            child: ratingTypeQstn(
                                                surveyFields[index], index),
                                          )
                                        : surveyFields[index]['fieldType'] ==
                                                FieldTypes.checkbox.name
                                            ? Container(
                                                color: Colors.white,
                                                child: checkboxTypeQstn(
                                                    surveyFields[index], index),
                                              )
                                            : Center(),
                          );
                        }),
                  )
                : Center(),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () => {
                        widget.enrollParentAction('Cancel'),
                        Navigator.of(context).pop(true)
                      },
                      style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4.0),
                                    side: BorderSide(
                                        color: AppColors.primaryThree,
                                        width: 1.5))),
                        backgroundColor: MaterialStateProperty.all<Color>(
                            AppColors.appBarBackground),
                      ),
                      // padding: EdgeInsets.all(15.0),
                      child: Text(
                        AppLocalizations.of(context).mStaticCancel,
                        style: GoogleFonts.lato(
                          color: AppColors.primaryThree,
                          fontSize: 14.0,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 16,
                ),
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 40,
                    child: TextButton(
                      onPressed: !enableConfirmbtn
                          ? null
                          : () async {
                              if (surveyFields.length > 0)
                                showConfirmDialog = false;
                              if (!showConfirmDialog &&
                                  formResponse != "success") {
                                await submitForm();
                              }
                              if ((formResponse == "success" &&
                                      !showConfirmDialog) ||
                                  surveyFields.length == 0 &&
                                      showConfirmDialog) {
                                widget.enrollParentAction('Confirm');
                                Navigator.of(context).pop();
                              } else {
                                widget.enrollParentAction('Form submitted');
                              }
                            },
                      style: TextButton.styleFrom(
                        backgroundColor: enableConfirmbtn
                            ? AppColors.primaryThree
                            : AppColors.shadeFour,
                      ),
                      // padding: EdgeInsets.all(15.0),
                      child: Text(
                        AppLocalizations.of(context).mStaticConfirm,
                        style: GoogleFonts.lato(
                          color: Colors.white,
                          fontSize: 14.0,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
