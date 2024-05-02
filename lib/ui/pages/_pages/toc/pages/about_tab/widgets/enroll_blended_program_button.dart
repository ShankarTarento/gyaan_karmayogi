import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/models/_arguments/toc_player_model.dart';
import 'package:karmayogi_mobile/models/_models/batch_model.dart';
import 'package:karmayogi_mobile/models/_models/blended_program_enroll_response_model.dart';
import 'package:karmayogi_mobile/models/_models/blended_program_unenroll_response_model.dart';
import 'package:karmayogi_mobile/models/_models/course_model.dart';
import 'package:karmayogi_mobile/respositories/_respositories/learn_repository.dart';
import 'package:karmayogi_mobile/services/_services/learn_service.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/learn/course_session_page.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/about_tab/widgets/select_batch_bottom_sheer.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/about_tab/widgets/withdraw_request_button.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/services/toc_services.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../../../respositories/_respositories/in_app_review_repository.dart';
import '../../../widgets/rate_now_pop_up.dart';
import 'enrollment_details.dart';

class EnrollBlendedProgramButton extends StatefulWidget {
  final List<Batch> batches;
  final Batch selectedBatch;
  final List<Course> enrollmentList;
  final navigationItems;
  final contentProgressResponse;
  final lastAccessContentId;
  final String batchId;
  final String courseId;
  final VoidCallback readCourseProgress;
  final Map<String, dynamic> courseDetails;
  EnrollBlendedProgramButton(
      {Key key,
      @required this.batches,
      @required this.contentProgressResponse,
      @required this.lastAccessContentId,
      @required this.navigationItems,
      @required this.selectedBatch,
      @required this.batchId,
      @required this.courseId,
      this.enrollmentList,
      this.courseDetails,
      this.readCourseProgress})
      : super(key: key);

  @override
  State<EnrollBlendedProgramButton> createState() =>
      _EnrollBlendedProgramButtonState();
}

class _EnrollBlendedProgramButtonState
    extends State<EnrollBlendedProgramButton> {
  @override
  void initState() {
    checkEnrolledBlendedProgram();
    userSearch();
    setState(() {});
    super.initState();
  }

  var formId = 1694586265488;
  var workflowDetails;
  Map<String, dynamic> enrolledBatch;
  bool _disableButton = false;
  Batch enrolledBatchDetails;
  bool isWithdrawPopupShowing = false, isAllBatchEnrollmentDateFinished = false;
  String wfId = '';
  bool startCourse = true;
  Course approvedBlendedCourse;

  final LearnService learnService = LearnService();
  bool showWithdrawbtnforEnrolled = false;

  bool enableRequestWithdrawBtn = true,
      isBatchStarted = false,
      isRequestRejected = false,
      isRequestRemoved = false;
  ValueNotifier<bool> showBlendedProgramReqButton = ValueNotifier<bool>(false);
  bool showStart = false, enableWithdrawBtn = false;

  bool enableStartButton = false;

  Future<Map> getForm(id) async {
    var surveyForm = await Provider.of<LearnRepository>(context, listen: false)
        .getSurveyForm(id);
    return surveyForm;
  }

  String enrollStatus;

  @override
  Widget build(BuildContext context) {
    return widget.selectedBatch != null
        ? showStart
            ? SizedBox(
                height: 40,
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  onPressed: () async {
                    if (enableStartButton) {
                      var result = await Navigator.pushNamed(
                        context,
                        AppUrl.tocPlayer,
                        arguments: TocPlayerModel.fromJson(
                          {
                            'enrolmentList': widget.enrollmentList,
                            'navigationItems': widget.navigationItems,
                            'contentProgressResponse':
                                widget.contentProgressResponse,
                            'isCuratedProgram': false,
                            'batchId': widget.batchId,
                            'lastAccessContentId': widget.lastAccessContentId,
                            'courseId': widget.courseId
                          },
                        ),
                      );
                      if (result != null && result is Map<String, bool>) {
                        Map<String, dynamic> response = result;
                        if (response['isFinished']) {
                          showModalBottomSheet(
                              isScrollControlled: true,
                              context: context,
                              backgroundColor: AppColors.greys60,
                              builder: (ctx) => RateNowPopUp(
                                    courseDetails:
                                        Course.fromJson(widget.courseDetails),
                                  )).whenComplete(() => InAppReviewRespository()
                              .triggerInAppReviewPopup());
                        }
                      }
                      widget.readCourseProgress();
                    }
                  },
                  style: ButtonStyle(
                    overlayColor:
                        MaterialStateProperty.all<Color>(Colors.transparent),
                    backgroundColor: enableStartButton
                        ? MaterialStateProperty.all<Color>(
                            AppColors.primaryThree)
                        : MaterialStateProperty.all<Color>(
                            AppColors.primaryThree.withOpacity(0.5)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(63.0),
                      ),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context).mStaticStart,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
            : showWithdrawbtnforEnrolled != null
                ? showWithdrawbtnforEnrolled
                    ? WithdrawRequest(
                        courseDetails: widget.courseDetails,
                        selectedBatch: enrolledBatchDetails,
                        withdrawFunction: () async {
                          await unenrollBlendedCourse();
                          showWithdrawbtnforEnrolled = false;

                          setState(() {});
                        },
                      )
                    : Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: Container(
                          padding: EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color:
                                  AppColors.secondaryShade1.withOpacity(0.2)),
                          width: MediaQuery.of(context).size.width,
                          child: Column(children: [
                            Container(
                              margin: EdgeInsets.only(
                                  bottom: 10, left: 16, top: 16, right: 16),
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                  border:
                                      Border.all(color: AppColors.primaryOne)),
                              width: MediaQuery.of(context).size.width,
                              child: Row(
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 1.6,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.selectedBatch.name,
                                          style: GoogleFonts.lato(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(
                                          height: 4,
                                        ),
                                        Text(
                                          "${Helper.getDateTimeInFormat(widget.selectedBatch.startDate, desiredDateFormat: IntentType.dateFormat2)} to  ${Helper.getDateTimeInFormat(widget.selectedBatch.endDate, desiredDateFormat: IntentType.dateFormat2)}",
                                          style: GoogleFonts.lato(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 12,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        )
                                      ],
                                    ),
                                  ),
                                  Spacer(),
                                  IconButton(
                                      onPressed: () {
                                        showModalBottomSheet(
                                            context: context,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(16),
                                                topRight: Radius.circular(16),
                                              ),
                                              side: BorderSide(
                                                color: AppColors.grey08,
                                              ),
                                            ),
                                            builder: (BuildContext context) {
                                              return Consumer<TocServices>(
                                                  builder: (context,
                                                      tocServices, _) {
                                                return SelectBatchBottomSheet(
                                                  batches: widget.batches,
                                                  batch: tocServices.batch,
                                                );
                                              });
                                            });
                                      },
                                      icon: Icon(Icons.keyboard_arrow_down))
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 16.0, right: 16),
                              child: Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)
                                            .mStaticLastEnrollDate,
                                        style: GoogleFonts.lato(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                          height: 1.5,
                                        ),
                                      ),
                                      Text(
                                        enrolledBatchDetails != null
                                            ? Helper.getDateTimeInFormat(
                                                enrolledBatchDetails
                                                    .enrollmentEndDate,
                                                desiredDateFormat:
                                                    IntentType.dateFormat)
                                            : Helper.getDateTimeInFormat(
                                                widget.selectedBatch
                                                    .enrollmentEndDate,
                                                desiredDateFormat:
                                                    IntentType.dateFormat),
                                        style: GoogleFonts.lato(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Spacer(),
                                  ElevatedButton(
                                    onPressed: showBlendedProgramReqButton
                                                .value ||
                                            (!showStart &&
                                                isAllBatchEnrollmentDateFinished) ||
                                            (showStart && !isBatchStarted) &&
                                                false
                                        ? null
                                        : !_disableButton
                                            ? () async {
                                                startCourse = true;
                                                if (widget.courseDetails[
                                                            'primaryCategory'] ==
                                                        PrimaryCategory
                                                            .blendedProgram &&
                                                    widget.courseDetails[
                                                            'batches'] !=
                                                        null) {
                                                  debugPrint(
                                                      "--survveylink--------------${widget.courseDetails['wfSurveyLink']}");
                                                  if (widget.courseDetails[
                                                              'wfSurveyLink'] !=
                                                          null &&
                                                      widget.courseDetails[
                                                              'wfSurveyLink'] !=
                                                          '') {
                                                    var surveyFormLink =
                                                        widget.courseDetails[
                                                            'wfSurveyLink'];
                                                    formId = int.parse(
                                                        surveyFormLink
                                                            .split('/')
                                                            .last);

                                                    if (true && !showStart) {
                                                      var response =
                                                          await getForm(formId);
                                                      userSearch();
                                                      if (response != null) {
                                                        await showModalBottomSheet(
                                                            isScrollControlled:
                                                                true,
                                                            context: context,
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        16),
                                                                topRight: Radius
                                                                    .circular(
                                                                        16),
                                                              ),
                                                              side: BorderSide(
                                                                color: AppColors
                                                                    .grey08,
                                                              ),
                                                            ),
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return Padding(
                                                                padding: EdgeInsets.only(
                                                                    bottom: MediaQuery.of(
                                                                            context)
                                                                        .viewInsets
                                                                        .bottom),
                                                                child:
                                                                    Container(
                                                                  height: 620,
                                                                  child:
                                                                      EnrollmentDetailsForm(
                                                                    batch: widget
                                                                        .selectedBatch,
                                                                    surveyform:
                                                                        response,
                                                                    courseDetails:
                                                                        '${widget.courseDetails['identifier']},${widget.courseDetails['name']}',
                                                                    courseId:
                                                                        '${widget.courseDetails['identifier']}',
                                                                    formId:
                                                                        formId,
                                                                    enrollParentAction:
                                                                        (value) {
                                                                      setEnrollStatus(
                                                                          value);
                                                                    },
                                                                  ),
                                                                ),
                                                              );
                                                            });
                                                      }
                                                    }
                                                  } else {
                                                    await showModalBottomSheet(
                                                        isScrollControlled:
                                                            true,
                                                        context: context,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    16),
                                                            topRight:
                                                                Radius.circular(
                                                                    16),
                                                          ),
                                                          side: BorderSide(
                                                            color: AppColors
                                                                .grey08,
                                                          ),
                                                        ),
                                                        builder: (BuildContext
                                                            context) {
                                                          return Container(
                                                            height: 200,
                                                            padding:
                                                                EdgeInsets.only(
                                                                    top: 24,
                                                                    left: 16,
                                                                    right: 16),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  AppLocalizations.of(
                                                                          context)
                                                                      .mSurveyFormOneStepAwayFromEnroll,
                                                                  style:
                                                                      GoogleFonts
                                                                          .lato(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 16,
                                                                ),
                                                                Text(
                                                                  "${AppLocalizations.of(context).mThisBatchStarting} ${Helper.getDateTimeInFormat(widget.selectedBatch.startDate, desiredDateFormat: IntentType.dateFormat2)} - ${Helper.getDateTimeInFormat(widget.selectedBatch.endDate, desiredDateFormat: IntentType.dateFormat2)}, ${AppLocalizations.of(context).mBatchStartConsent}",
                                                                  style:
                                                                      GoogleFonts
                                                                          .lato(
                                                                    color: AppColors
                                                                        .greys87,
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 20,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    SizedBox(
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width /
                                                                          2.3,
                                                                      child:
                                                                          ElevatedButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.pop(
                                                                              context);
                                                                        },
                                                                        style:
                                                                            ButtonStyle(
                                                                          backgroundColor:
                                                                              MaterialStateProperty.all<Color>(Colors.white),
                                                                          shape:
                                                                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                                                            RoundedRectangleBorder(
                                                                              side: BorderSide(color: AppColors.darkBlue),
                                                                              borderRadius: BorderRadius.circular(63.0),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        child:
                                                                            Text(
                                                                          AppLocalizations.of(context)
                                                                              .mStaticCancel,
                                                                          style: GoogleFonts.lato(
                                                                              fontWeight: FontWeight.w700,
                                                                              fontSize: 14,
                                                                              color: AppColors.darkBlue),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Spacer(),
                                                                    SizedBox(
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width /
                                                                          2.3,
                                                                      child:
                                                                          ElevatedButton(
                                                                        onPressed:
                                                                            () async {
                                                                          Navigator.pop(
                                                                              context);
                                                                          setEnrollStatus(
                                                                              "Confirm");
                                                                          //   await enrollBlendedCourse();
                                                                        },
                                                                        style:
                                                                            ButtonStyle(
                                                                          backgroundColor:
                                                                              MaterialStateProperty.all<Color>(AppColors.darkBlue),
                                                                          shape:
                                                                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                                                            RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(63.0),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        child:
                                                                            Text(
                                                                          AppLocalizations.of(context)
                                                                              .mStaticEnroll,
                                                                          style:
                                                                              GoogleFonts.lato(
                                                                            fontWeight:
                                                                                FontWeight.w700,
                                                                            fontSize:
                                                                                14,
                                                                            color:
                                                                                Colors.white,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        });
                                                  }
                                                }
                                              }
                                            : null,
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              AppColors.primaryOne),
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(63.0),
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      AppLocalizations.of(context)
                                          .mLearnRequestToEnroll,
                                      style: GoogleFonts.lato(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ]),
                        ),
                      )
                : SizedBox()
        : Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.secondaryShade1.withOpacity(0.2)),
              width: MediaQuery.of(context).size.width,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 10),
                      padding: EdgeInsets.all(12),
                      height: 50,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.black40)),
                      width: MediaQuery.of(context).size.width,
                    ),
                    Text(
                      AppLocalizations.of(context).mLearnNoActiveBatches,
                      style: GoogleFonts.lato(
                          color: AppColors.textHeadingColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)
                                  .mStaticLastEnrollDate,
                              style: GoogleFonts.lato(
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                height: 1.5,
                              ),
                            ),
                            Text(
                              enrolledBatchDetails != null
                                  ? enrolledBatchDetails.enrollmentEndDate
                                  : "",
                              style: GoogleFonts.lato(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        ElevatedButton(
                          onPressed: () {},
                          style: ButtonStyle(
                            elevation: MaterialStateProperty.all(0),
                            backgroundColor: MaterialStateProperty.all<Color>(
                                AppColors.black40),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(63.0),
                              ),
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context).mLearnRequestToEnroll,
                            style: GoogleFonts.lato(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ]),
            ));
  }

  setEnrollStatus(String value) async {
    enrollStatus = value;
    if (value == 'Confirm') {
      await enrollBlendedCourse();
      await userSearch();
    }
  }

  userSearch() async {
    workflowDetails = [];
    List batchList = [];
    widget.batches.forEach((item) {
      batchList.add(item.batchId);
    });
    try {
      String courseId = widget.courseDetails['identifier'];
      workflowDetails = await learnService.userSearch(courseId, batchList);

      checkWorkflowStatus();
      // else if (workflowDetails[0]['wfInfo'][0]['currentStatus'] ==
      //     WFBlendedProgramStatus.WITHDRAW.name) {
      //   setState(() {
      //     wfId = workflowDetails[0]['wfInfo'][0]['wfId'];
      //   });
      // }
    } catch (e) {
      print(e);
    }
  }

  void checkWorkflowStatus() {
    if (workflowDetails != null && workflowDetails.isNotEmpty) {
      if (workflowDetails[0]['wfInfo'] != null) {
        List workflowStates = [];
        if (enrolledBatchDetails == null) {
          workflowDetails[0]['wfInfo'].forEach((workFlow) {
            if (workFlow['currentStatus'] ==
                    WFBlendedProgramStatus.REJECTED.name ||
                workFlow['currentStatus'] ==
                    WFBlendedProgramStatus.REMOVED.name ||
                workFlow['currentStatus'] ==
                    WFBlendedProgramStatus.SEND_FOR_MDO_APPROVAL.name ||
                workFlow['currentStatus'] ==
                    WFBlendedProgramStatus.SEND_FOR_PC_APPROVAL.name) {
              widget.batches.forEach((batch) {
                if (workFlow['applicationId'] == batch.batchId) {
                  enrolledBatchDetails = batch;
                  Provider.of<TocServices>(context, listen: false)
                      .setBatchDetails(selectedBatch: enrolledBatchDetails);
                }
              });
            }
          });
          workflowStates = workflowDetails[0]['wfInfo'];
        } else {
          workflowDetails[0]['wfInfo'].forEach((workFlow) {
            if (workFlow['applicationId'] == enrolledBatchDetails.batchId) {
              workflowStates.add(workFlow);
            }
          });
        }
        if (workflowStates != null && workflowStates.isNotEmpty) {
          workflowStates.sort((a, b) {
            return DateTime.fromMillisecondsSinceEpoch(a['lastUpdatedOn'])
                .compareTo(
                    DateTime.fromMillisecondsSinceEpoch(b['lastUpdatedOn']));
          });
          bool withdrawStatus = false;
          showWithdrawBtn(workflowStates.last['currentStatus']);
          for (int i = 0; i < WFBlendedWithdrawCheck.values.length; i++) {
            if (WFBlendedWithdrawCheck.values[i].name ==
                workflowStates.last['currentStatus']) {
              withdrawStatus = true;
              enableRequestWithdraw(workflowStates.last['currentStatus'],
                  workflowStates.last['serviceName']);

              if (!enableRequestWithdrawBtn) {
                List batches = widget.courseDetails['batches'];
                batches.forEach((batch) {
                  if (batch.batchId == workflowStates.last['applicationId']) {
                    if (DateTime.parse(batch.startDate)
                            .isBefore(DateTime.now()) ||
                        DateTime.parse(batch.startDate)
                            .isAtSameMomentAs(DateTime.now())) {
                      if (!isWithdrawPopupShowing) {
                        isWithdrawPopupShowing = true;
                        _showWithdrawPopUp();
                      }
                    }
                  }
                });
              }
              break;
            }
          }
          if (withdrawStatus) {
            wfId = workflowStates.last['wfId'];
            enrolledBatch = workflowStates.last;
            showBlendedProgramReqButton.value = true;
          } else if (workflowStates.last['currentStatus'] ==
              WFBlendedProgramStatus.APPROVED.name) {
            setState(() {
              showStart = true;
              enrolledBatch = workflowStates.last;
            });
          } else if (workflowStates.last['currentStatus'] ==
              WFBlendedProgramStatus.WITHDRAWN.name) {
            showBlendedProgramReqButton.value = false;
          } else if (workflowStates.last['currentStatus'] ==
                  WFBlendedProgramStatus.REJECTED.name ||
              workflowStates.last['currentStatus'] ==
                  WFBlendedProgramStatus.REMOVED.name) {
            showBlendedProgramReqButton.value = true;
          }
        } else {
          showBlendedProgramReqButton.value = false;
          showWithdrawBtn(WFBlendedProgramStatus.WITHDRAWN.name);
        }
      }
    } else {
      enrolledBatchDetails = widget.selectedBatch;
      showBlendedProgramReqButton.value = false;
      showWithdrawBtn(WFBlendedProgramStatus.WITHDRAWN.name);
    }
  }

  void showWithdrawBtn(currentStatus) {
    isRequestRejected = false;
    isRequestRemoved = false;
    showWithdrawbtnforEnrolled = false;
    if (WFBlendedWithdrawCheck.SEND_FOR_MDO_APPROVAL.name == currentStatus ||
        WFBlendedWithdrawCheck.SEND_FOR_PC_APPROVAL.name == currentStatus) {
      showWithdrawbtnforEnrolled = true;
      showBlendedProgramReqButton.value = true;
    } else if (WFBlendedWithdrawCheck.REJECTED.name == currentStatus) {
      isRequestRejected = true;
      showBlendedProgramReqButton.value = true;
    } else if (WFBlendedWithdrawCheck.REMOVED.name == currentStatus) {
      isRequestRemoved = true;
      showBlendedProgramReqButton.value = true;
    } else if (WFBlendedProgramStatus.WITHDRAWN.name == currentStatus) {
      showStart = false;
      showBlendedProgramReqButton.value = false;
    }
    if (mounted) {
      setState(() {});
    }
  }

  void enableRequestWithdraw(currentStatus, serviceName) {
    setState(() {
      if (WFBlendedProgramAprovalTypes.twoStepMDOAndPCApproval.name ==
              serviceName &&
          WFBlendedWithdrawCheck.SEND_FOR_PC_APPROVAL.name == currentStatus) {
        enableRequestWithdrawBtn = false;
        // _showPopUP();
      } else if (WFBlendedProgramAprovalTypes.twoStepPCAndMDOApproval.name ==
              serviceName &&
          WFBlendedWithdrawCheck.SEND_FOR_MDO_APPROVAL.name == currentStatus) {
        enableRequestWithdrawBtn = false;
      } else {
        enableRequestWithdrawBtn = true;
        // _showPopUP();
      }
    });
  }

  Future<void> unenrollBlendedCourse() async {
    //print("$enrolledBatch");
    //SEND_FOR_PC_APPROVAL"
    BlendedProgramUnenrollResponseModel enrolList =
        await learnService.requestUnenroll(
            batchId: enrolledBatchDetails.batchId,
            courseId: widget.courseDetails['identifier'],
            wfId: wfId,
            state: enrolledBatch['currentStatus'],
            action: WFBlendedProgramStatus.WITHDRAW.name);
    userSearch();
  }

  _showWithdrawPopUp() => {
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) => ButtonBarTheme(
                  data: ButtonBarThemeData(alignment: MainAxisAlignment.center),
                  child: AlertDialog(
                    content: Text(
                        AppLocalizations.of(context)
                            .mStaticYourEnrollmentIsNotApproved,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          letterSpacing: 0.25,
                          color: AppColors.greys87,
                        )),
                    actionsAlignment: MainAxisAlignment.center,
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          isWithdrawPopupShowing = false;
                          Navigator.of(context).pop();
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
                          EnglishLang.cancel,
                          style: GoogleFonts.lato(
                            color: AppColors.primaryThree,
                            fontSize: 14.0,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() async {
                            await unenrollBlendedCourse();
                            isWithdrawPopupShowing = false;
                            Navigator.of(context)
                              ..pop()
                              ..pop();
                          });
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              AppColors.primaryThree),
                        ),
                        // padding: EdgeInsets.all(15.0),
                        child: Text(
                          EnglishLang.withdraw,
                          style: GoogleFonts.lato(
                            color: Colors.white,
                            fontSize: 14.0,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    ],
                  ),
                ))
      };
  enrollBlendedCourse() async {
    // print("enroll function called------------");
    String courseId = widget.courseDetails['identifier'];
    if (enrollStatus == 'Confirm') {
      var batchDetails = await learnService.requestToEnroll(
          batchId: widget.selectedBatch.batchId,
          courseId: courseId,
          state: WFBlendedProgramStatus.INITIATE.name,
          action: WFBlendedProgramStatus.INITIATE.name);
      if (batchDetails is String) {
        await userSearch();
        showToastMessage(context, message: batchDetails.toString());
        return;
      }
      if (batchDetails is BlendedProgramEnrollResponseModel) {
        debugPrint(batchDetails.message);
        showToastMessage(context,
            message:
                AppLocalizations.of(context).mStaticEnrollmentSentForReview);
        showWithdrawbtnforEnrolled = true;
        await userSearch();
        setState(() {});
        return;
      }
    }
  }

  checkEnrolledBlendedProgram() async {
    DateTime now = DateTime.now();
    var approvedCourse = widget.enrollmentList.firstWhere(
      (element) =>
          element.raw["content"]["identifier"] ==
          widget.courseDetails["identifier"],
      orElse: () => null,
    );

    if (approvedCourse != null) {
      approvedBlendedCourse = approvedCourse;

      if (DateTime.now().isAfter(DateTime.parse(
              approvedBlendedCourse.raw["batch"]["startDate"])) &&
          DateTime(now.year, now.month, now.day - 1).isBefore(
              DateTime.parse(approvedBlendedCourse.raw["batch"]["endDate"]))) {
        enableStartButton = true;
      }
      showStart = true;
    } else {
      showStart = false;
    }
    setState(() {});
  }

  String getProgress() {
    var enrollmentDetail = widget.enrollmentList.firstWhere(
      (element) =>
          element.raw["content"]["identifier"] ==
          widget.courseDetails["identifier"],
      orElse: () => null,
    );
    if (enrollmentDetail != null) {
      if (enrollmentDetail.completionPercentage / 100 > 0 &&
          enrollmentDetail.completionPercentage / 100 < 1) {
        return AppLocalizations.of(context).mStaticResume;
      } else if (enrollmentDetail.completionPercentage / 100 == 1) {
        return AppLocalizations.of(context).mStartAgain;
      }
    } else {
      return AppLocalizations.of(context).mLearnStart;
    }
  }
}
