import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:karmayogi_mobile/constants/_constants/storage_constants.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/respositories/_respositories/learn_repository.dart';
import 'package:karmayogi_mobile/services/_services/learn_service.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/learn/course_session_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/enroll_moderated_program.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/widgets/rate_now_pop_up.dart';
import 'package:provider/provider.dart';
import '../../../../../models/_arguments/index.dart';
import '../../../../../models/index.dart';
import '../../../../../respositories/_respositories/in_app_review_repository.dart';
import '../../../../../util/helper.dart';
import '../pages/services/toc_services.dart';

class TocButton extends StatefulWidget {
  final bool isStandAloneAssesment;
  final List<Course> enrolmentList;
  final bool isModerated;
  final List navigationItems;
  final contentProgressResponse;
  final bool isCuratedProgram;
  final Map<String, dynamic> courseDetails;
  final String batchId, lastAccessContentId, courseId;
  final Batch selectedBatch;
  final List<Batch> batches;
  final VoidCallback readCourseProgress, updateEnrolmentList;
  const TocButton(
      {Key key,
      @required this.isStandAloneAssesment,
      this.isModerated = false,
      @required this.enrolmentList,
      @required this.courseDetails,
      @required this.navigationItems,
      @required this.contentProgressResponse,
      this.isCuratedProgram = false,
      @required this.batchId,
      @required this.courseId,
      @required this.lastAccessContentId,
      this.selectedBatch,
      this.batches,
      this.readCourseProgress,
      this.updateEnrolmentList})
      : super(key: key);

  @override
  State<TocButton> createState() => _TocButtonState();
}

class _TocButtonState extends State<TocButton> {
  @override
  void initState() {
    newEnrollmentList = widget.enrolmentList;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      checkEnrolled();
    });
    checkHasMultipleBatch();
    checkInviteOnlyProgram();

    // print(widget.enrolmentList[0].raw["batch"]);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    checkStandAloneAssesment();
    super.didChangeDependencies();
  }

  double progress;
  @override
  void didUpdateWidget(TocButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    newEnrollmentList = widget.enrolmentList;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      checkEnrolled();
      if (isEnrolled && completionPercentage < 100) {
        progress = getResourceNavigationItems();
        updateButtonStatus(progress);
      }
    });
  }

  final LearnService learnService = LearnService();
  final _storage = FlutterSecureStorage();
  List<Course> newEnrollmentList = [];

  String curatedProgramBatchId;
  bool showStart, isEnrolled = false;
  ValueNotifier<String> buttonStatus = ValueNotifier('');
  double completionPercentage = 0;
  bool isInviteOnlyProgram = false;
  bool invited = false;
  bool showStartInviteOnlyProgram = false;
  bool isEnrolledStandaloneAssesment = false;
  bool showEnrolInviteOnlyProgram = false;
  bool showMultipleBatchSelection = false;

  @override
  Widget build(BuildContext context) {
    return widget.isStandAloneAssesment
        ? SizedBox(
            height: 40,
            width: MediaQuery.of(context).size.width,
            child: ElevatedButton(
              onPressed: () async {
                if (isEnrolledStandaloneAssesment) {
                  var result = await Navigator.pushNamed(
                    context,
                    AppUrl.tocPlayer,
                    arguments: TocPlayerModel(
                      enrolmentList: newEnrollmentList,
                      navigationItems: widget.navigationItems,
                      contentProgressResponse: widget.contentProgressResponse,
                      isCuratedProgram: widget.isCuratedProgram,
                      batchId: widget.batchId,
                      lastAccessContentId: widget.lastAccessContentId,
                      courseId: widget.courseId,
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
                              )).whenComplete(() =>
                          InAppReviewRespository().triggerInAppReviewPopup());
                    }
                  }
                  widget.readCourseProgress();
                } else {
                  enrollStandaloneAssessment(context);
                }
              },
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(AppColors.darkBlue),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(63.0),
                  ),
                ),
              ),
              child: ValueListenableBuilder<String>(
                  valueListenable: buttonStatus,
                  builder: (context, value, _) {
                    return Text(isEnrolledStandaloneAssesment
                        ? value == TocButtonStatus.startAgain
                            ? AppLocalizations.of(context)
                                .mAssessmentTakeTestAgain
                            : AppLocalizations.of(context).mLearnTakeTest
                        : AppLocalizations.of(context).mLearnEnroll);
                  }),
            ),
          )
        : isInviteOnlyProgram && widget.batches.length == 0
            ? Container(
                height: 40,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(63),
                  color: Colors.white,
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    if (showStartInviteOnlyProgram) {
                      var result = await Navigator.pushNamed(
                        context,
                        AppUrl.tocPlayer,
                        arguments: TocPlayerModel(
                            enrolmentList: newEnrollmentList,
                            navigationItems: widget.navigationItems,
                            contentProgressResponse:
                                widget.contentProgressResponse,
                            isCuratedProgram: widget.isCuratedProgram,
                            batchId: widget.batchId,
                            lastAccessContentId: widget.lastAccessContentId,
                            courseId: widget.courseId),
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
                    } else if (showEnrolInviteOnlyProgram) {
                      _enrollCourse(context: context);
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: showStartInviteOnlyProgram ||
                            showEnrolInviteOnlyProgram
                        ? MaterialStateProperty.all<Color>(AppColors.darkBlue)
                        : MaterialStateProperty.all<Color>(AppColors.black40),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(63.0),
                      ),
                    ),
                  ),
                  child: ValueListenableBuilder<String>(
                      valueListenable: buttonStatus,
                      builder: (context, value, _) {
                        return Text(
                          checkInviteOnlyProgram(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        );
                      }),
                ),
              )
            : showMultipleBatchSelection && !showStart
                ? EnrollModeratedProgram(
                    selectedBatch: widget.selectedBatch,
                    batches: widget.batches,
                    onEnrollPressed: (BuildContext context) {
                      _enrollCourse(context: context);
                      setState(() {});
                    },
                  )
                : SizedBox(
                    height: 40,
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (showStart) {
                          var result = await Navigator.pushNamed(
                            context,
                            AppUrl.tocPlayer,
                            arguments: TocPlayerModel.fromJson(
                              {
                                'enrolmentList': widget.enrolmentList,
                                'navigationItems': widget.navigationItems,
                                'contentProgressResponse':
                                    widget.contentProgressResponse,
                                'isCuratedProgram': widget.isCuratedProgram,
                                'batchId': widget.batchId,
                                'lastAccessContentId':
                                    widget.lastAccessContentId,
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
                                        courseDetails: Course.fromJson(
                                            widget.courseDetails),
                                      )).whenComplete(() =>
                                  InAppReviewRespository()
                                      .triggerInAppReviewPopup());
                            }
                          }
                          widget.readCourseProgress();
                        } else {
                          _enrollCourse(context: context);
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            AppColors.darkBlue),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(63.0),
                          ),
                        ),
                      ),
                      child: ValueListenableBuilder<String>(
                          valueListenable: buttonStatus,
                          builder: (context, value, _) {
                            return Text(getLocalizedStatus());
                          }),
                    ),
                  );
  }

  checkHasMultipleBatch() {
    showMultipleBatchSelection = widget.batches.length > 1;
  }

  _enrollCourse({@required BuildContext context}) async {
    if (widget.isCuratedProgram && !widget.isModerated) {
      String message = await learnService.enrollToCuratedProgram(
          widget.courseDetails["identifier"],
          widget.courseDetails["batches"][0]["batchId"]);

      if (message == 'SUCCESS') {
        navigateToContent();
        fetchEnrolInfo();
        showToastMessage(context, message: 'Enrolled successfully');
        buttonStatus.value = "start";
        showStart = true;
      } else {
        showToastMessage(context, message: 'Enrollment failed');
      }
    } else if (widget.isModerated &&
        widget.courseDetails["primaryCategory"] == EnglishLang.program &&
        !isEnrolled) {
      // print('Selected batch Id: ' + widget.selectedBatch.startDate);
      Response batchDetails = await learnService.enrollProgram(
          courseId: widget.courseDetails["identifier"],
          programId: widget.courseDetails["identifier"],
          batchId: widget.batches.length > 1
              ? widget.selectedBatch.batchId
              : widget.batchId);
      if (batchDetails.statusCode == 200) {
        await fetchEnrolInfo();
        navigateToContent();
        buttonStatus.value = "start";
        showStart = true;

        fetchEnrolInfo();
        showToastMessage(context,
            message: AppLocalizations.of(context).mStaticEnrolledSuccessfully);
      } else {
        showToastMessage(context,
            message:
                '${AppLocalizations.of(context).mStaticEnrollmentFailed}, ${jsonDecode(batchDetails.body)['params']['errmsg']}');
      }
    } else {
      var batchDetails = await learnService
          .autoEnrollBatch(widget.courseDetails["identifier"]);

      if (batchDetails.runtimeType == String) {
        showToastMessage(context,
            message: AppLocalizations.of(context).mStaticEnrollmentFailed);
      } else {
        await fetchEnrolInfo();
        navigateToContent();
        buttonStatus.value = "start";
        showStart = true;

        fetchEnrolInfo();
        showToastMessage(context,
            message: AppLocalizations.of(context).mStaticEnrolledSuccessfully);
      }
    }
  }

  void checkEnrolled() {
    isEnrolled = newEnrollmentList.any((element) =>
        element.raw["content"]["identifier"] ==
        widget.courseDetails["identifier"]);

    if (isEnrolled) {
      Course enrolledCourse = newEnrollmentList.firstWhere((element) =>
          element.raw["content"]["identifier"] ==
          widget.courseDetails["identifier"]);
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (mounted) {
          Provider.of<TocServices>(context, listen: false).setCourseProgress(
              double.parse(enrolledCourse.completionPercentage.toString()) /
                  100);
        }
      });
      if (enrolledCourse.completionPercentage == 100) {
        showStart = true;
        buttonStatus.value = TocButtonStatus.startAgain;
      } else if (enrolledCourse.completionPercentage > 0) {
        showStart = true;
        buttonStatus.value = TocButtonStatus.resume;
      } else {
        showStart = true;
        buttonStatus.value = TocButtonStatus.start;
      }
      completionPercentage =
          double.parse(enrolledCourse.completionPercentage.toString());
    } else {
      showStart = false;
      buttonStatus.value = TocButtonStatus.enroll;
    }
  }

  Future<dynamic> fetchEnrolInfo() async {
    Map<String, dynamic> response =
        await Provider.of<LearnRepository>(context, listen: false)
            .getEnrollmentList();
    if (response != null) {
      _storage.write(
          key: Storage.userCourseEnrolmentInfo,
          value: jsonEncode(response['userCourseEnrolmentInfo']));
      _storage.write(
          key: Storage.enrolmentList, value: jsonEncode(response['courses']));
      _storage.write(
          key: Storage.enrolmentExpiryTime,
          value: DateTime.now()
              .add(Duration(seconds: CACHE_EXPIRY_DURATION))
              .toString());
    }
    widget.updateEnrolmentList();
    widget.readCourseProgress();

    List<dynamic> coursesData = response['courses'];
    newEnrollmentList =
        coursesData.map((item) => Course.fromJson(item)).toList();
    setState(() {});
    return response['courses'];
  }

  double getResourceNavigationItems() {
    List resourceNavigateItems = [];
    widget.navigationItems.forEach((child) {
      if (child.runtimeType != List) {
        resourceNavigateItems.add(child);
      } else {
        child.forEach((childElement) {
          if (childElement.runtimeType != List) {
            resourceNavigateItems.add(childElement);
          } else {
            childElement.forEach((childItem) {
              if (childItem.runtimeType != List) {
                resourceNavigateItems.add(childItem);
              }
            });
          }
        });
      }
    });
    double totalProgress = 0;
    resourceNavigateItems.forEach((element) {
      if (element['status'] == 2) {
        totalProgress += 1;
      } else {
        totalProgress +=
            double.parse(element['completionPercentage'].toString());
      }
    });
    return totalProgress / resourceNavigateItems.length;
  }

  void updateButtonStatus(double progress) {
    String status = '';
    if (progress != null && progress * 100 > completionPercentage) {
      completionPercentage = progress * 100;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (mounted) {
          Provider.of<TocServices>(context, listen: false)
              .setCourseProgress(progress);
        }
      });
      if (progress == 1) {
        showStart = true;
        status = TocButtonStatus.startAgain;
      } else if (progress > 0) {
        showStart = true;
        status = TocButtonStatus.resume;
      } else {
        showStart = true;
        status = TocButtonStatus.start;
      }
      if (status != buttonStatus.value) {
        buttonStatus.value = status;
      }
    }
  }

  String getLocalizedStatus() {
    switch (buttonStatus.value) {
      case TocButtonStatus.enroll:
        return AppLocalizations.of(context).mStaticEnroll;
      case TocButtonStatus.start:
        return AppLocalizations.of(context).mStaticStart;
      case TocButtonStatus.resume:
        return AppLocalizations.of(context).mStaticResume;
      case TocButtonStatus.startAgain:
        return AppLocalizations.of(context).mStaticStart;
      default:
        return '';
    }
  }

  String checkInviteOnlyProgram() {
    if (widget.courseDetails["batches"] != null &&
        widget.courseDetails["batches"].isNotEmpty &&
        widget.courseDetails["batches"][0]["enrollmentType"] == "invite-only") {
      isInviteOnlyProgram = true;
      Course course;
      try {
        course = newEnrollmentList.firstWhere((element) =>
            element.raw["content"]["identifier"] ==
            widget.courseDetails["identifier"]);
      } catch (e) {
        course = null;
      }
      if (course != null) {
        if (DateTime.parse(course.raw["batch"]["startDate"])
            .isAfter(DateTime.now())) {
          showStartInviteOnlyProgram = false;

          return "${AppLocalizations.of(context).mHomeBlendedProgramBatchStart} ${Helper.getDateTimeInFormat(course.raw["batch"]["startDate"], desiredDateFormat: IntentType.dateFormat2)}";
        } else if (DateTime.parse(course.raw["batch"]["startDate"])
                .isBefore(DateTime.now()) &&
            DateTime.parse(course.raw["batch"]["endDate"])
                .isAfter(DateTime.now())) {
          if (progress != null && progress * 100 == 100) {
            showStartInviteOnlyProgram = true;
            return "Start again";
          } else if (progress != null &&
              progress * 100 < 100 &&
              progress * 100 > 0) {
            showStartInviteOnlyProgram = true;

            return "Resume";
          } else {
            showStartInviteOnlyProgram = true;
            return AppLocalizations.of(context).mLearnStart;
          }
        } else {
          showStartInviteOnlyProgram = false;
          return AppLocalizations.of(context).mLearnNoActiveBatches;
        }
      } else if (widget.courseDetails["primaryCategory"] ==
              EnglishLang.program &&
          widget.isModerated &&
          course == null) {
        showEnrolInviteOnlyProgram = true;
        return AppLocalizations.of(context).mLearnEnroll;
      } else {
        showStartInviteOnlyProgram = false;
        return AppLocalizations.of(context).mLearnYouAreNotInvited;
      }
    } else {
      isInviteOnlyProgram = false;
    }
    return "";
  }

  String checkStandAloneAssesment() {
    Course course;
    try {
      course = newEnrollmentList.firstWhere((element) =>
          element.raw["content"]["identifier"] ==
          widget.courseDetails["identifier"]);
    } catch (e) {
      course = null;
    }
    course != null
        ? isEnrolledStandaloneAssesment = true
        : isEnrolledStandaloneAssesment = false;
    setState(() {});
    return isEnrolledStandaloneAssesment == true
        ? AppLocalizations.of(context).mStaticTakeTest
        : AppLocalizations.of(context).mLearnEnroll;
  }

  enrollStandaloneAssessment(context) async {
    var message = await learnService.autoEnrollBatch(
      widget.courseDetails["identifier"],
    );
    if (message.runtimeType == String) {
      showToastMessage(context,
          message: AppLocalizations.of(context).mStaticEnrollmentFailed);
      isEnrolledStandaloneAssesment = false;
    } else {
      isEnrolledStandaloneAssesment = true;
      await fetchEnrolInfo();
      navigateToContent();

      showToastMessage(context,
          message: AppLocalizations.of(context).mStaticEnrolledSuccessfully);
    }

    setState(() {});
  }

  navigateToContent() {
    Navigator.pushNamed(
      context,
      AppUrl.tocPlayer,
      arguments: TocPlayerModel(
          enrolmentList: newEnrollmentList,
          navigationItems: widget.navigationItems,
          contentProgressResponse: widget.contentProgressResponse,
          isCuratedProgram: widget.isCuratedProgram,
          batchId: widget.batchId,
          lastAccessContentId: widget.lastAccessContentId,
          courseId: widget.courseId),
    );
  }
}
