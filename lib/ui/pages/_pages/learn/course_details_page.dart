import 'dart:async';
import 'dart:convert';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:karmayogi_mobile/respositories/_respositories/learn_repository.dart';
import 'package:karmayogi_mobile/respositories/_respositories/profile_repository.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:provider/provider.dart';
import '../../../../constants/_constants/storage_constants.dart';
import '../../../../constants/_constants/telemetry_constants.dart';
import '../../../../localization/_langs/english_lang.dart';
import '../../../../models/_models/blended_program_unenroll_response_model.dart';
import './../../../../models/index.dart';
// import 'package:flutter_svg/flutter_svg.dart';
import './../../../../ui/widgets/index.dart';
import './../../../../constants/index.dart';
import './../../../../services/index.dart';
// import './../../../../ui/pages/_pages/text_search_results/text_search_page.dart';
import './../../../../ui/pages/index.dart';
import './../../../../util/faderoute.dart';
import './../../../../util/telemetry.dart';
// import 'dart:developer' as developer;
import './../../../../util/telemetry_db_helper.dart';
import 'course_session_page.dart';
import 'blended_program_survey_page.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'course_sharing/course_sharing_page.dart';

class CourseDetailsPage extends StatefulWidget {
  final String id;
  final bool isContinueLearning;
  final bool isFeaturedCourse;
  final bool isStandAloneAssessment;
  final String primaryCategory;
  final bool isCuratedProgram;
  final String curatedPgmBatchId;
  final bool isModerated;

  const CourseDetailsPage(this.primaryCategory,
      {Key key,
      this.id,
      this.isContinueLearning = false,
      this.isFeaturedCourse = false,
      this.isStandAloneAssessment = false,
      this.curatedPgmBatchId,
      this.isCuratedProgram = false,
      this.isModerated = false})
      : super(key: key);

  @override
  _CourseDetailsPageState createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage>
    with SingleTickerProviderStateMixin {
  var _courseDetails;
  var courseInfo;
  Batch selectedBatch;
  TabController _controller;
  final LearnService learnService = LearnService();
  final LearnRepository learnRepository = LearnRepository();
  final ProfileRepository profileRepository = ProfileRepository();
  // final DiscussService discussService = DiscussService(HttpClient client);
  final TelemetryService telemetryService = TelemetryService();
  List<CourseLearner> _courseLearners = [];
  List<Course> _continueLearningcourses;
  // List<CourseAuthor> _courseAuthors = [];
  List _courseAuthors = [];
  List _courseCurators = [];
  List _navigationItems = [];
  double progress = 0.0;
  dynamic _contentProgress = Map();
  Map _currentCourse;
  Map _allContentProgress;
  // bool _showPopUp = true;
  // List<Profile> _profileDetails;
  String _batchId;
  double _rating;
  var _courseProgress;
  List _issuedCertificate;
  List<Batch> courseBatches = [];
  // List<String> _batchesNames = [];
  int _tabIndex = 0;
  int _catId;
  var _base64CertificateImage;
  bool _disableButton = false;
  bool startCourse = true;
  String userId;
  String userSessionId;
  String messageIdentifier;
  String departmentId;
  int _start = 0;
  String pageIdentifier;
  String pageUri;
  List allEventsData = [];
  Map rollup = {};
  String deviceIdentifier;
  var telemetryEventData;
  ValueNotifier<bool> showBlendedProgramReqButton = ValueNotifier<bool>(false);
  ValueNotifier<bool> showKarmaPointClaimButton = ValueNotifier<bool>(false);
  ValueNotifier<bool> showCongratsMessage = ValueNotifier<bool>(false);
  bool showStart = false, enableWithdrawBtn = false;
  String enrollStatus;
  var formId = 1694586265488;
  var workflowDetails;
  Map<String, dynamic> enrolledBatch;
  String wfId = '';
  bool isWithdrawPopupShowing = false, isAllBatchEnrollmentDateFinished = false;

  bool get isBlendedProgram =>
      widget.primaryCategory == PrimaryCategory.blendedProgram;
  List<LearnTab> get learnTabs => (isBlendedProgram
      ? LearnTab.blendedProgramItems(context: context)
      : widget.isFeaturedCourse
          ? LearnTab.majorItems(context: context)
          : widget.isStandAloneAssessment
              ? LearnTab.standaloneAssessmentItems(context: context)
              : LearnTab.items(context: context));
  bool enableRequestWithdrawBtn = true,
      showWithdrawbtnforEnrolled = false,
      isBatchStarted = false,
      isRequestRejected = false,
      isRequestRemoved = false;
  Course courseDetails;
  int leafNodeCount = 0;
  double totalCourseProgress = 0;
  List leafNodes = [];
  Map cbpList;
  String cbpEndDate;
  final _storage = FlutterSecureStorage();
  bool showCourseCompletionRewardMessage = true;
  bool showCourseCompletionCongratsMessage = true, isAcbp = false;
  int rewardPoint = 0;
  String _certificateId;

  get isEnrollmentEndDate {
    if (selectedBatch != null) {
      String enrolEndDate =
          Helper.getDateTimeInFormat(selectedBatch.enrollmentEndDate);
      String now = Helper.getDateTimeInFormat(DateTime.now().toString());
      return DateFormat('dd-MM-yyyy')
          .parse(enrolEndDate)
          .isAfter(DateFormat('dd-MM-yyyy').parse(now));
    }
    return false;
  }

  @override
  void initState() {
    super.initState();

    getTotalKarmaPointInfo();
    _getCategoryId(widget.id);
    // _showBanner = isBlendedProgram;
    _getCourseBatches(widget.id);
    // _generateTelemetryData();
    getCBPdata();
  }

  Future<void> getTotalKarmaPointInfo() async {
    var response = await profileRepository.getTotalKarmaPoint();
    if (response.runtimeType != String && response != null) {
      if (response['kpList'] != null && response['kpList']['addinfo'] != null) {
        var addInfo = jsonDecode(response['kpList']['addinfo']);
        if (addInfo['claimedNonACBPCourseKarmaQuota'] >=
            KARMPOINT_AWARD_LIMIT_TO_COURSE) {
          showCourseCompletionRewardMessage = false;
        }
      }
    }
  }

  @override
  void didChangeDependencies() {
    _controller =
        TabController(length: learnTabs.length, vsync: this, initialIndex: 0);
    super.didChangeDependencies();
  }

  Future<dynamic> _getCompletionCertificate(dynamic certificateId) async {
    final certificate =
        await learnService.getCourseCompletionCertificate(certificateId);

    setState(() {
      _base64CertificateImage = certificate;
    });
    return _base64CertificateImage;
  }

  void _generateTelemetryData() async {
    deviceIdentifier = await Telemetry.getDeviceIdentifier();
    userId = await Telemetry.getUserId(isPublic: widget.isFeaturedCourse);
    userSessionId = await Telemetry.generateUserSessionId();
    messageIdentifier = await Telemetry.generateUserSessionId();
    departmentId =
        await Telemetry.getUserDeptId(isPublic: widget.isFeaturedCourse);
    Map eventData1 = Telemetry.getImpressionTelemetryEvent(
        deviceIdentifier,
        userId,
        departmentId,
        pageIdentifier,
        userSessionId,
        messageIdentifier,
        TelemetryType.page,
        pageUri,
        env: TelemetryEnv.learn,
        objectId: widget.id,
        objectType: widget.primaryCategory,
        isPublic: widget.isFeaturedCourse);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData1);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap(),
        isPublic: widget.isFeaturedCourse);
  }

  void _generateInteractTelemetryData(String contentId) async {
    deviceIdentifier = await Telemetry.getDeviceIdentifier();
    userId = await Telemetry.getUserId(isPublic: widget.isFeaturedCourse);
    userSessionId = await Telemetry.generateUserSessionId();
    messageIdentifier = await Telemetry.generateUserSessionId();
    departmentId =
        await Telemetry.getUserDeptId(isPublic: widget.isFeaturedCourse);
    Map eventData = Telemetry.getInteractTelemetryEvent(
        deviceIdentifier,
        userId,
        departmentId,
        (widget.isFeaturedCourse
                ? TelemetryPageIdentifier.publicCourseDetailsPageId
                : TelemetryPageIdentifier.courseDetailsPageId) +
            '_' +
            contentId,
        userSessionId,
        messageIdentifier,
        contentId,
        TelemetrySubType.courseTab,
        env: TelemetryEnv.learn,
        objectType: TelemetrySubType.courseTab,
        isPublic: widget.isFeaturedCourse);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap(),
        isPublic: widget.isFeaturedCourse);
  }

  void _triggerInteractTelemetryData(int index) {
    if (index == 0) {
      _generateInteractTelemetryData(TelemetrySubType.overviewTab);
    } else if (index == 1) {
      _generateInteractTelemetryData(TelemetrySubType.contentTab);
    } else if (index == 2) {
      _generateInteractTelemetryData(TelemetrySubType.discussionTab);
    } else
      _generateInteractTelemetryData(TelemetrySubType.learnersTab);
  }

  Future<void> _getCourseBatches(courseId) async {
    courseBatches = await Provider.of<LearnRepository>(context, listen: false)
        .getBatchList(widget.id);
  }

  _getCourseProgress() async {
    if (mounted) {
      //Call api to get enrolled courses
      _continueLearningcourses =
          await Provider.of<LearnRepository>(context, listen: false)
              .getContinueLearningCourses();
      final course = _continueLearningcourses
          .where((element) => element.raw['courseId'] == widget.id);
      courseDetails = course.length > 0 ? course.first : null;
      if (courseDetails != null) {
        checkCompletionMonth(courseDetails);
        if (isBlendedProgram) {
          isBatchStarted = checkCourseConsumptionAllowed();
        }
        var progress = courseDetails.raw['completionPercentage'];
        List issuedCertificate = courseDetails.raw['issuedCertificates'];
        String batchId = courseDetails.raw['batchId'];
        if (mounted) {
          setState(() {
            _courseProgress = progress;
            _issuedCertificate = issuedCertificate;
            _batchId = batchId;
          });
        }
      }
    }
  }

  Future<dynamic> getCourseInfo() async {
    return await learnService.getCourseData(widget.id);
  }

  Future<dynamic> _getCourseDetails() async {
    if (_courseDetails == null) {
      _courseDetails = widget.isFeaturedCourse
          ? await learnService.getCourseDetails(widget.id, isFeatured: true)
          : await learnService.getCourseDetails(widget.id);
      courseInfo = await getCourseInfo();
      if (courseInfo != null) {
        if (courseInfo['batches'] != null) {
          if (courseBatches != null) {
            courseInfo['batches'] = courseBatches;
          }
        }
        if (isBlendedProgram) {
          isAllBatchEnrollmentDateFinished = checkAllBatchEnrollmentDateOver();
          userSearch();
        }
      }
      // fetching cbp end date
      getCBPEnddate();
      if (_courseDetails.toString() == EnglishLang.notFound) {
        return _courseDetails;
      }
      // _courseAuthors = await Provider.of<LearnRepository>(context, listen: false).getCourseAuthors(widget.id);
      if (courseInfo['creatorContacts'] != null) {
        _courseCurators = jsonDecode(courseInfo['creatorContacts']);
      } else {
        _courseCurators = [];
      }
      if (courseInfo['creatorDetails'] != null) {
        _courseAuthors = jsonDecode(courseInfo['creatorDetails']);
      } else {
        _courseAuthors = [];
      }
      await _getCourseProgress();
      await _generateNavigation();
      if (!widget.isFeaturedCourse) {
        if (isBlendedProgram && courseInfo['batches'] != null) {
          _batchId = (courseInfo['batches'].runtimeType == String
              ? jsonDecode(courseInfo['batches']).first.batchId.toString()
              : courseInfo['batches'].first.batchId.toString());
          var batches = courseInfo['batches'];
          for (int i = 0; i < batches.length; i++) {
            if (isValidBatch(DateTime.parse(batches[i].enrollmentEndDate))) {
              _batchId = batches[i].batchId;
              break;
            }
          }
        }
        if (widget.isModerated && courseInfo['batches'] != null) {
          _batchId = (courseInfo['batches'].runtimeType == String
              ? jsonDecode(courseInfo['batches']).first.batchId.toString()
              : courseInfo['batches'].first.batchId.toString());
          var batches = courseInfo['batches'];
          for (int i = 0; i < batches.length; i++) {
            if (batches[i].enrollmentEndDate == null ||
                isValidBatch(DateTime.parse(batches[i].enrollmentEndDate))) {
              _batchId = batches[i].batchId;
              break;
            }
          }
        }
        if (_batchId != null) {
          await _readContentProgress(_courseDetails['identifier'], _batchId);
          setState(() {});
        }
        totalCourseProgress = 0;
        leafNodes = _courseDetails['leafNodes'];
        for (int index = 0;
            index < _courseDetails['children'].length;
            index++) {
          _continueLearningcourses.forEach((course) async {
            if (course.raw['courseId'] ==
                _courseDetails['children'][index]['identifier']) {
              await _readContentProgress(
                  course.raw['courseId'], course.raw['batch']['batchId']);
            }
          });
        }
        _triggerTelemetryEvent();
        if (_batchId != null && _courseProgress == 100) {
          _certificateId = _issuedCertificate.length > 0
              ? (_issuedCertificate.length > 1
                  ? _issuedCertificate[1]['identifier']
                  : _issuedCertificate[0]['identifier'])
              : null;
          if (_certificateId != null) {
            await _getCompletionCertificate(_certificateId);
          }
        }
      }
    }
    return _courseDetails;
  }

  void getCBPEnddate() {
    if (cbpEndDate == null && cbpList.runtimeType != String) {
      var cbpCourse = cbpList['content'] ?? [];

      for (int index = 0; index < cbpCourse.length; index++) {
        var element = cbpCourse[index]['contentList'];
        for (int elementindex = 0;
            elementindex < element.length;
            elementindex++) {
          if (element[elementindex]['identifier'] ==
              _courseDetails['identifier']) {
            cbpEndDate = cbpCourse[index]['endDate'];
            break;
          }
        }
      }
    }
  }

  bool checkAllBatchEnrollmentDateOver() {
    bool batchstatus = true;
    if (courseInfo['batches'] != null) {
      courseInfo['batches'].forEach((batch) {
        if (batchstatus == true) {
          if (batch.enrollmentEndDate != null) {
            if (DateTime.parse(batch.enrollmentEndDate)
                    .isAfter(DateTime.now()) ||
                (Helper.getDateTimeInFormat(batch.enrollmentEndDate) ==
                    (Helper.getDateTimeInFormat(DateTime.now().toString())))) {
              batchstatus = false;
            }
          }
        }
      });
    }
    return batchstatus;
  }

  bool checkCourseConsumptionAllowed() {
    if ((DateTime.parse(courseDetails.raw['batch']['startDate'])
                .isAfter(DateTime.now()) &&
            Helper.getDateTimeInFormat(
                    courseDetails.raw['batch']['startDate']) !=
                Helper.getDateTimeInFormat(DateTime.now().toString())) ||
        (DateTime.parse(courseDetails.raw['batch']['endDate'])
                .isBefore(DateTime.now()) &&
            Helper.getDateTimeInFormat(courseDetails.raw['batch']['endDate']) !=
                Helper.getDateTimeInFormat(DateTime.now().toString()))) {
      return false;
    } else {
      return true;
    }
  }

  _getCourseLearners() async {
    if (!widget.isFeaturedCourse) {
      _courseLearners =
          await Provider.of<LearnRepository>(context, listen: false)
              .getCourseLearners(widget.id);
      // _profileDetails =
      //     await Provider.of<ProfileRepository>(context, listen: false)
      //         .getProfileDetailsById('');
    }
    return _courseLearners;
  }

  _enrollCourse() async {
    if (widget.isCuratedProgram) {
      String message = await learnService.enrollToCuratedProgram(
          widget.id, widget.curatedPgmBatchId);

      if (message != 'SUCCESS') {
        showToastMessage(context, message: 'Enrollment failed');
      } else {
        await _getCourseProgress();
      }
    } else if (widget.isModerated &&
        _courseDetails['primaryCategory'] == EnglishLang.program &&
        courseDetails == null) {
      var batchDetails = await learnService.enrollProgram(
          courseId: widget.id, programId: widget.id, batchId: _batchId);
      if (batchDetails.runtimeType == String) {
        if (widget.isModerated) {
          showStart = true;
        } else {
          showToastMessage(context, message: 'Enrollment failed');
        }
      } else {
        await _getCourseProgress();
      }
    } else {
      var batchDetails = await learnService.autoEnrollBatch(widget.id);
      if (batchDetails.runtimeType == String) {
        if (widget.isModerated) {
          showStart = true;
        } else {
          showToastMessage(context, message: 'Enrollment failed');
        }
      } else {
        _batchId = batchDetails['batchId'];
        await _getCourseProgress();
      }
    }
  }

  _enrollBlendedCourse() async {
    String courseId = _courseDetails['identifier'];
    if (enrollStatus == 'Confirm') {
      var batchDetails = await learnService.requestToEnroll(
          batchId: selectedBatch.batchId,
          courseId: courseId,
          state: WFBlendedProgramStatus.INITIATE.name,
          action: WFBlendedProgramStatus.INITIATE.name);
      if (batchDetails is String) {
        showToastMessage(context, message: batchDetails.toString());
        return;
      }

      await userSearch();
    }
  }

  Future<void> unenrollBlendedCourse() async {
    BlendedProgramUnenrollResponseModel enrolList =
        await learnService.requestUnenroll(
            batchId: selectedBatch.batchId,
            courseId: _courseDetails['identifier'],
            wfId: wfId,
            state: enrolledBatch['currentStatus'],
            action: WFBlendedProgramStatus.WITHDRAW.name);
    userSearch();
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
      // setState(() {
      // });
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

  userSearch() async {
    workflowDetails = [];
    List batchList = [];
    courseInfo['batches'].forEach((item) {
      batchList.add(item.batchId);
    });
    try {
      String courseId = courseInfo['identifier'];
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

  void updateContents(param) {
    _getCourseDetails();
  }

  Future<Map> getForm(id) async {
    var surveyForm = await Provider.of<LearnRepository>(context, listen: false)
        .getSurveyForm(id);
    print(surveyForm);
    return surveyForm;
  }

  Future<dynamic> _readContentProgress(courseId, batchId) async {
    List toRemoveChildNodes = [];
    var response = await learnService.readContentProgress(courseId, batchId);
    List _sortContentProgress = _extractSortContentProgress(response);

    _updateNavigationItems(response, _sortContentProgress);

    _triggerTelemetryEvent();

    if (totalCourseProgress > 0) {
      leafNodes.removeWhere((content) => toRemoveChildNodes.contains(content));
      if (_courseProgress != 100) {
        _courseProgress =
            totalCourseProgress ~/ _courseDetails['leafNodesCount'];
      }
    }

    if (mounted) {
      setState(() {});
    }

    return response['result']['contentList'];
  }

  List _extractSortContentProgress(response) {
    List _sortContentProgress = [];
    for (int i = 0; i < response['result']['contentList'].length; i++) {
      var contentListItem = response['result']['contentList'][i];
      if (contentListItem['lastAccessTime'] != null ||
          contentListItem['completionPercentage'] != null) {
        _sortContentProgress.add(contentListItem);
      }
    }
    if (_sortContentProgress.isNotEmpty) {
      _sortContentProgress.sort((a, b) =>
          (a['lastAccessTime'] ?? a['completionPercentage'])
              .compareTo(b['lastAccessTime'] ?? b['completionPercentage']));
    } else {
      _sortContentProgress = response['result']['contentList'];
    }
    _sortContentProgress = _sortContentProgress.reversed.toList();
    _allContentProgress = response;
    return _sortContentProgress;
  }

  void _updateNavigationItems(response, _sortContentProgress) {
    for (int i = 0; i < _navigationItems.length; i++) {
      var currentItem = _navigationItems[i];
      if (currentItem[0] == null) {
        _updateNavigationItemsWithoutNested(
            currentItem, response, _sortContentProgress, i);
      } else if (currentItem[0][0] != null) {
        _updateNavigationItemsWithNested(
            currentItem, response, _sortContentProgress, i);
      } else {
        _updateNavigationItemsNestedIsNull(
            currentItem, response, _sortContentProgress, i);
      }
    }
  }

  void _updateNavigationItemsWithoutNested(
      currentItem, response, _sortContentProgress, index) {
    for (int j = 0; j < response['result']['contentList'].length; j++) {
      var contentListItem = response['result']['contentList'][j];
      if (currentItem['contentId'] == contentListItem['contentId']) {
        double progress = (contentListItem['completionPercentage'] != null)
            ? contentListItem['completionPercentage'] / 100
            : 0;

        _contentProgress[contentListItem['contentId']] = progress;
        currentItem['completionPercentage'] = progress;

        if (contentListItem['progressdetails'] != null &&
            contentListItem['progressdetails']['current'] != null) {
          currentItem['currentProgress'] =
              (contentListItem['progressdetails']['current'].length > 0)
                  ? contentListItem['progressdetails']['current'].last
                  : 0;
        }

        currentItem['status'] = contentListItem['status'];
        currentItem['currentProgress'] = progress;

        if (_sortContentProgress.isNotEmpty &&
            currentItem['contentId'] == _sortContentProgress[0]['contentId']) {
          _currentCourse = currentItem;
          _currentCourse['moduleItems'] = _navigationItems[index].length;
          _currentCourse['currentIndex'] = index + 1;
        }
      }
    }
  }

  void _updateNavigationItemsWithNested(
      currentItem, response, _sortContentProgress, index) {
    for (var m = 0; m < currentItem.length; m++) {
      for (int k = 0; k < currentItem[m].length; k++) {
        for (int j = 0; j < response['result']['contentList'].length; j++) {
          var contentListItem = response['result']['contentList'][j];
          if (currentItem[m][k] != null &&
              currentItem[m][k]['contentId'] == contentListItem['contentId']) {
            double progress = (contentListItem['completionPercentage'] != null)
                ? contentListItem['completionPercentage'] / 100
                : 0;

            _contentProgress[contentListItem['contentId']] = progress;
            currentItem[m][k]['completionPercentage'] = progress;

            if (contentListItem['progressdetails'] != null &&
                contentListItem['progressdetails']['current'] != null) {
              currentItem[m][k]['currentProgress'] =
                  (contentListItem['progressdetails']['current'].length > 0)
                      ? contentListItem['progressdetails']['current'].last
                      : 0;
            }

            currentItem[m][k]['status'] = contentListItem['status'];
            currentItem[m][k]['currentProgress'] = progress;

            if (_sortContentProgress.isNotEmpty &&
                currentItem[m][k]['contentId'] ==
                    _sortContentProgress[0]['contentId']) {
              _currentCourse = currentItem[m][k];
              _currentCourse['moduleItems'] = _navigationItems[index].length;
              _currentCourse['currentIndex'] = k + 1;
            }
          }
        }
      }
    }
  }

  void _updateNavigationItemsNestedIsNull(
      currentItem, response, _sortContentProgress, index) {
    for (int k = 0; k < currentItem.length; k++) {
      var nestedItem = currentItem[k];
      for (int j = 0; j < response['result']['contentList'].length; j++) {
        var contentListItem = response['result']['contentList'][j];
        if (nestedItem != null &&
            nestedItem['contentId'] == contentListItem['contentId']) {
          double progress = (contentListItem['completionPercentage'] != null)
              ? contentListItem['completionPercentage'] / 100
              : 0;

          _contentProgress[contentListItem['contentId']] = progress;
          nestedItem['completionPercentage'] = progress;

          if (contentListItem['progressdetails'] != null &&
              contentListItem['progressdetails']['current'] != null) {
            nestedItem['currentProgress'] =
                (contentListItem['progressdetails']['current'].length > 0)
                    ? contentListItem['progressdetails']['current'].last
                    : 0;
          }

          nestedItem['status'] = contentListItem['status'];
          nestedItem['currentProgress'] = progress;

          if (_sortContentProgress.isNotEmpty &&
              nestedItem['contentId'] == _sortContentProgress[0]['contentId']) {
            _currentCourse = nestedItem;
            _currentCourse['moduleItems'] = _navigationItems[index].length;
            _currentCourse['currentIndex'] = k + 1;
          }
        } else if (currentItem[k][0] == null) {
          // Logic for further nesting if required
        }
      }
    }
  }

  _triggerTelemetryEvent() {
    if (_start == 0) {
      pageIdentifier = !widget.isFeaturedCourse
          ? TelemetryPageIdentifier.courseDetailsPageId
          : TelemetryPageIdentifier.publicCourseDetailsPageId;
      pageUri = (!widget.isFeaturedCourse
              ? TelemetryPageIdentifier.courseDetailsPageUri
              : TelemetryPageIdentifier.publicCourseDetailsPageUri)
          .replaceAll(':do_ID', widget.id);
      if (_batchId != null) {
        pageUri = pageUri.toString() + '?batchId=$_batchId';
      }
      rollup['l1'] = widget.id;
      _generateTelemetryData();
    }
  }

  Future<dynamic> _generateNavigation() async {
    _navigationItems = [];
    int index;
    int k = 0;
    if (_courseDetails['children'] != null) {
      String parentCourseId = '';
      if (_courseDetails['primaryCategory'] == EnglishLang.course) {
        parentCourseId = _courseDetails['identifier'];
      }
      for (index = 0; index < _courseDetails['children'].length; index++) {
        String parentBatchId = '';
        if (_courseDetails['cumulativeTracking'] != null &&
            _courseDetails['cumulativeTracking']) {
          Course enrolledCourse = _continueLearningcourses.firstWhere(
            (course) =>
                course.raw['courseId'] ==
                _courseDetails['children'][index]['identifier'],
            orElse: () => null,
          );
          parentBatchId = enrolledCourse != null
              ? enrolledCourse.raw['batch']['batchId']
              : _batchId;
        }

        if (_courseDetails['children'][index]['contentType'] == 'Collection' ||
            _courseDetails['children'][index]['contentType'] == 'CourseUnit') {
          List temp = [];
          if (_courseDetails['children'][index]['children'] != null) {
            String parentCourseId;
            if (_courseDetails['cumulativeTracking'] != null &&
                _courseDetails['cumulativeTracking']) {
              parentCourseId = _courseDetails['children'][index]['identifier'];
            }
            for (int i = 0;
                i < _courseDetails['children'][index]['children'].length;
                i++) {
              temp.add({
                'index': k++,
                'moduleName': _courseDetails['children'][index]['name'],
                'mimeType': _courseDetails['children'][index]['children'][i]
                    ['mimeType'],
                'identifier': _courseDetails['children'][index]['children'][i]
                    ['identifier'],
                'name': _courseDetails['children'][index]['children'][i]
                    ['name'],
                'artifactUrl': _courseDetails['children'][index]['children'][i]
                    ['artifactUrl'],
                'contentId': _courseDetails['children'][index]['children'][i]
                    ['identifier'],
                'currentProgress': '0',
                'status': 0,
                'primaryCategory': _courseDetails['children'][index]['children']
                    [i]['primaryCategory'],
                'moduleDuration':
                    _courseDetails['children'][index]['duration'] != null
                        ? Helper.getFullTimeFormat(
                            _courseDetails['children'][index]['duration'])
                        : '',
                'duration': ((_courseDetails['children'][index]['children'][i]
                                    ['duration'] !=
                                null &&
                            _courseDetails['children'][index]['children'][i]
                                    ['duration'] !=
                                '') ||
                        (_courseDetails['children'][index]['children'][i]
                                    ['expectedDuration'] !=
                                null &&
                            _courseDetails['children'][index]['children'][i]
                                    ['expectedDuration'] !=
                                ''))
                    ? _courseDetails['children'][index]['children'][i]['mimeType'] ==
                            EMimeTypes.pdf
                        ? 'PDF - ' +
                            Helper.getFullTimeFormat(_courseDetails['children'][index]['children'][i]['duration'])
                        : _courseDetails['children'][index]['children'][i]['mimeType'] == EMimeTypes.mp4
                            ? 'Video - ' + Helper.getFullTimeFormat(_courseDetails['children'][index]['children'][i]['duration'])
                            : _courseDetails['children'][index]['children'][i]['mimeType'] == EMimeTypes.mp3
                                ? 'Audio - ' + Helper.getFullTimeFormat(_courseDetails['children'][index]['children'][i]['duration'])
                                : _courseDetails['children'][index]['children'][i]['mimeType'] == EMimeTypes.assessment
                                    ? 'Assessment - ' + Helper.getFullTimeFormat(_courseDetails['children'][index]['children'][i]['duration'])
                                    : _courseDetails['children'][index]['children'][i]['mimeType'] == EMimeTypes.survey
                                        ? 'Survey - ' + Helper.getFullTimeFormat(_courseDetails['children'][index]['children'][i]['duration'])
                                        : _courseDetails['children'][index]['children'][i]['mimeType'] == EMimeTypes.newAssessment
                                            ? Helper.getFullTimeFormat(_courseDetails['children'][index]['children'][i]['expectedDuration'].toString())
                                            : 'Resource - ' + Helper.getFullTimeFormat(_courseDetails['children'][index]['children'][i]['duration'])
                    : '',
                'parentCourseId': parentCourseId,
                'parentBatchId': parentBatchId
              });
            }
          } else {
            temp.add({
              'index': k++,
              'moduleName': _courseDetails['children'][index]['name'],
              'moduleDuration':
                  _courseDetails['children'][index]['duration'] != null
                      ? Helper.getFullTimeFormat(
                          _courseDetails['children'][index]['duration'])
                      : '',
              'identifier': _courseDetails['children'][index]['identifier'],
            });
          }
          _navigationItems.add(temp);
        }
        //Added below condition to handle course items
        else if (_courseDetails['children'][index]['contentType'] == 'Course') {
          List<List<Map<String, dynamic>>> courseList = [];
          for (var i = 0;
              i < _courseDetails['children'][index]['children'].length;
              i++) {
            List<Map<String, dynamic>> temp = [];
            if (_courseDetails['children'][index]['children'][i]
                        ['contentType'] ==
                    'Collection' ||
                _courseDetails['children'][index]['children'][i]
                        ['contentType'] ==
                    'CourseUnit') {
              for (var j = 0;
                  j <
                      _courseDetails['children'][index]['children'][i]
                              ['children']
                          .length;
                  j++) {
                if (_courseDetails['cumulativeTracking'] != null &&
                    _courseDetails['cumulativeTracking']) {
                  parentCourseId =
                      _courseDetails['children'][index]['identifier'];
                }
                temp.add({
                  'index': k++,
                  'courseName': _courseDetails['children'][index]['name'],
                  'moduleName': _courseDetails['children'][index]['children'][i]
                      ['name'],
                  'mimeType': _courseDetails['children'][index]['children'][i]
                      ['children'][j]['mimeType'],
                  'identifier': _courseDetails['children'][index]['children'][i]
                      ['children'][j]['identifier'],
                  'name': _courseDetails['children'][index]['children'][i]
                      ['children'][j]['name'],
                  'artifactUrl': _courseDetails['children'][index]['children']
                      [i]['children'][j]['artifactUrl'],
                  'contentId': _courseDetails['children'][index]['children'][i]
                      ['children'][j]['identifier'],
                  'currentProgress': '0',
                  'completionPercentage': '0',
                  'status': 0,
                  'primaryCategory': _courseDetails['children'][index]
                      ['children'][i]['children'][j]['primaryCategory'],
                  'moduleDuration': _courseDetails['children'][index]
                              ['children'][i]['duration'] !=
                          null
                      ? Helper.getFullTimeFormat(_courseDetails['children']
                          [index]['children'][i]['duration'])
                      : '',
                  'courseDuration':
                      _courseDetails['children'][index]['duration'] != null
                          ? Helper.getFullTimeFormat(
                              _courseDetails['children'][index]['duration'])
                          : '',
                  'duration': ((_courseDetails['children'][index]['children'][i]
                                      ['children'][j]['duration'] !=
                                  null &&
                              _courseDetails['children'][index]['children'][i]['children'][j]['duration'] !=
                                  '') ||
                          (_courseDetails['children'][index]['children'][i]
                                      ['children'][j]['expectedDuration'] !=
                                  null &&
                              _courseDetails['children'][index]['children'][i]
                                      ['children'][j]['expectedDuration'] !=
                                  ''))
                      ? _courseDetails['children'][index]['children'][i]['children'][j]['mimeType'] == EMimeTypes.pdf
                          ? 'PDF - ' + Helper.getFullTimeFormat(_courseDetails['children'][index]['children'][i]['children'][j]['duration'])
                          : _courseDetails['children'][index]['children'][i]['children'][j]['mimeType'] == EMimeTypes.mp4
                              ? 'Video - ' + Helper.getFullTimeFormat(_courseDetails['children'][index]['children'][i]['children'][j]['duration'])
                              : _courseDetails['children'][index]['children'][i]['children'][j]['mimeType'] == EMimeTypes.mp3
                                  ? 'Audio - ' + Helper.getFullTimeFormat(_courseDetails['children'][index]['children'][i]['children'][j]['duration'])
                                  : _courseDetails['children'][index]['children'][i]['children'][j]['mimeType'] == EMimeTypes.assessment
                                      ? 'Assessment - ' + Helper.getFullTimeFormat(_courseDetails['children'][index]['children'][i]['children'][j]['duration'])
                                      : _courseDetails['children'][index]['children'][i]['children'][j]['mimeType'] == EMimeTypes.survey
                                          ? 'Survey - ' + Helper.getFullTimeFormat(_courseDetails['children'][index]['children'][i]['children'][j]['duration'])
                                          : _courseDetails['children'][index]['children'][i]['children'][j]['mimeType'] == EMimeTypes.newAssessment
                                              ? Helper.getFullTimeFormat(_courseDetails['children'][index]['children'][i]['children'][j]['expectedDuration'].toString())
                                              : 'Resource - ' + Helper.getFullTimeFormat(_courseDetails['children'][index]['children'][i]['children'][j]['duration'])
                      : 'Link - ' + (_courseDetails['children'][index]['children'][i]['children'][j]['duration'] != null ? Helper.getFullTimeFormat(_courseDetails['children'][index]['children'][i]['children'][j]['duration']) : ''),
                  'parentCourseId': parentCourseId,
                  'parentBatchId': parentBatchId
                });
              }
              courseList.add(temp);
            } else {
              if (_courseDetails['cumulativeTracking'] != null &&
                  _courseDetails['cumulativeTracking']) {
                parentCourseId =
                    _courseDetails['children'][index]['identifier'];
              }
              temp.add({
                'index': k++,
                'courseName': _courseDetails['children'][index]['name'],
                'mimeType': _courseDetails['children'][index]['children'][i]
                    ['mimeType'],
                'identifier': _courseDetails['children'][index]['children'][i]
                    ['identifier'],
                'name': _courseDetails['children'][index]['children'][i]
                    ['name'],
                'artifactUrl': _courseDetails['children'][index]['children'][i]
                    ['artifactUrl'],
                'contentId': _courseDetails['children'][index]['children'][i]
                    ['identifier'],
                'currentProgress': '0',
                'completionPercentage': '0',
                'status': 0,
                'primaryCategory': _courseDetails['children'][index]['children']
                    [i]['primaryCategory'],
                'duration': ((_courseDetails['children'][index]['children'][i]
                                    ['duration'] !=
                                null &&
                            _courseDetails['children'][index]['children'][i]
                                    ['duration'] !=
                                '') ||
                        (_courseDetails['children'][index]['children'][i]
                                    ['expectedDuration'] !=
                                null &&
                            _courseDetails['children'][index]['children'][i]
                                    ['expectedDuration'] !=
                                ''))
                    ? _courseDetails['children'][index]['children'][i]['mimeType'] ==
                            EMimeTypes.pdf
                        ? 'PDF - ' +
                            Helper.getFullTimeFormat(_courseDetails['children'][index]['children'][i]['duration'])
                        : _courseDetails['children'][index]['children'][i]['mimeType'] == EMimeTypes.mp4
                            ? 'Video - ' + Helper.getFullTimeFormat(_courseDetails['children'][index]['children'][i]['duration'])
                            : _courseDetails['children'][index]['children'][i]['mimeType'] == EMimeTypes.mp3
                                ? 'Audio - ' + Helper.getFullTimeFormat(_courseDetails['children'][index]['children'][i]['duration'])
                                : _courseDetails['children'][index]['children'][i]['mimeType'] == EMimeTypes.assessment
                                    ? 'Assessment - ' + Helper.getFullTimeFormat(_courseDetails['children'][index]['children'][i]['duration'])
                                    : _courseDetails['children'][index]['children'][i]['mimeType'] == EMimeTypes.survey
                                        ? 'Survey - ' + Helper.getFullTimeFormat(_courseDetails['children'][index]['children'][i]['duration'])
                                        : _courseDetails['children'][index]['children'][i]['mimeType'] == EMimeTypes.newAssessment
                                            ? Helper.getFullTimeFormat(_courseDetails['children'][index]['children'][i]['expectedDuration'].toString())
                                            : 'Resource - ' + Helper.getFullTimeFormat(_courseDetails['children'][index]['children'][i]['duration'])
                    : 'Link - ' + (_courseDetails['children'][index]['children'][i]['duration'] != null ? Helper.getFullTimeFormat(_courseDetails['children'][index]['children'][i]['duration']) : ''),
                'parentCourseId': parentCourseId,
                'parentBatchId': parentBatchId
              });
              courseList.add(temp);
            }
          }
          _navigationItems.add(courseList);
        } else {
          // Check if cumulativeTracking is not null and true
          bool isCumulativeTracking =
              _courseDetails['cumulativeTracking'] != null &&
                  _courseDetails['cumulativeTracking'];

          // Set parentCourseId if cumulativeTracking is true
          if (isCumulativeTracking) {
            parentCourseId = _courseDetails['children'][index]['identifier'];
          }

          // Create a Map for the current item
          Map<String, dynamic> currentItem = {
            'index': k++,
            'mimeType': _courseDetails['children'][index]['mimeType'],
            'identifier': _courseDetails['children'][index]['identifier'],
            'name': _courseDetails['children'][index]['name'],
            'artifactUrl': _courseDetails['children'][index]['artifactUrl'],
            'contentId': _courseDetails['children'][index]['identifier'],
            'currentProgress': '0',
            'status': 0,
            'primaryCategory': _courseDetails['children'][index]
                ['primaryCategory'],
            'courseDuration':
                _courseDetails['children'][index]['duration'] != null
                    ? Helper.getFullTimeFormat(
                        _courseDetails['children'][index]['duration'])
                    : '',
            'duration': ((_courseDetails['children'][index]['duration'] != null &&
                        _courseDetails['children'][index]['duration'] != '') ||
                    (_courseDetails['children'][index]['expectedDuration'] !=
                            null &&
                        _courseDetails['children'][index]['expectedDuration'] !=
                            ''))
                ? _courseDetails['children'][index]['mimeType'] ==
                        EMimeTypes.pdf
                    ? 'PDF - ' +
                        Helper.getFullTimeFormat(
                            _courseDetails['children'][index]['duration'])
                    : _courseDetails['children'][index]['mimeType'] ==
                            EMimeTypes.mp4
                        ? 'Video - ' +
                            Helper.getFullTimeFormat(
                                _courseDetails['children'][index]['duration'])
                        : _courseDetails['children'][index]['mimeType'] ==
                                EMimeTypes.mp3
                            ? 'Audio - ' +
                                Helper.getFullTimeFormat(_courseDetails['children'][index]['duration'])
                            : _courseDetails['children'][index]['mimeType'] == EMimeTypes.assessment
                                ? 'Assessment - ' + Helper.getFullTimeFormat(_courseDetails['children'][index]['duration'])
                                : _courseDetails['children'][index]['mimeType'] == EMimeTypes.survey
                                    ? 'Survey - ' + Helper.getFullTimeFormat(_courseDetails['children'][index]['duration'])
                                    : _courseDetails['children'][index]['mimeType'] == EMimeTypes.newAssessment
                                        ? Helper.getFullTimeFormat(_courseDetails['children'][index]['expectedDuration'].toString())
                                        : 'Resource - ' + Helper.getFullTimeFormat(_courseDetails['children'][index]['duration'])
                : '',
            'parentCourseId': parentCourseId,
            'parentBatchId': parentBatchId
          };

          // Add the currentItem to _navigationItems list
          _navigationItems.add(currentItem);
        }
        // developer.log(jsonEncode(_navigationItems));
      }
    }
    return _navigationItems;
  }

  // void enrollToBatch(String batchName) {
  //   print(batchName);
  // }

  Future<int> _getCategoryId(String id) async {
    final response = await DiscussService.getCategoryIdOfCourse(id);
    // print(response.toString());
    int catId;
    if (response.length > 0) {
      // setState(() {
      _catId = response[0];
      // });
      // catId = response[0];
    }
    // return response.length > 0 ? response[0] : null;
    return catId;
  }

  void _getRating(rating) async {
    _rating = rating;
    // print('Rating: ' + _rating.toString());
  }

  void _updateData() async {
    if (!widget.isFeaturedCourse) {
      await _readContentProgress(_courseDetails['identifier'], _batchId);
      if (mounted) {
        setState(() {});
      }
    }
  }

  List<Widget> _getTags(tagsList) {
    List<Widget> tags = [];
    for (int i = 0; i < tagsList.length; i++) {
      tags.add(InkWell(
        onTap: () {},
        child: Container(
          margin: const EdgeInsets.only(right: 10, bottom: 10),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.grey04,
              border: Border.all(color: AppColors.grey08),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(8),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(8)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Text(
                tagsList[i],
                style: GoogleFonts.lato(
                  color: AppColors.greys87,
                  fontWeight: FontWeight.w400,
                  wordSpacing: 1.0,
                  fontSize: 12.0,
                ),
              ),
            ),
          ),
        ),
      ));
    }
    return tags;
  }

  @override
  void dispose() async {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // developer.log(_base64CertificateImage.toString());
    return Scaffold(
        body: DefaultTabController(
            length: learnTabs.length,
            child: SafeArea(
              child: FutureBuilder(
                  future: _getCourseDetails(),
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data == EnglishLang.notFound) {
                        return Scaffold(
                          appBar: AppBar(
                            titleSpacing: 0,
                            // leading: IconButton(
                            //   icon: Icon(Icons.clear, color: AppColors.greys60),
                            //   onPressed: () => Navigator.of(context).pop(),
                            // ),
                            title: Text(
                              AppLocalizations.of(context).mStaticBack,
                              style: GoogleFonts.montserrat(
                                color: AppColors.greys87,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          body: Stack(
                            children: <Widget>[
                              Column(
                                children: [
                                  Container(
                                    child: Center(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 125),
                                        child: SvgPicture.asset(
                                          'assets/img/empty_search.svg',
                                          alignment: Alignment.center,
                                          // color: AppColors.grey16,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.2,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.2,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 16),
                                    child: Text(
                                      AppLocalizations.of(context)
                                          .mLearnContentNotAvailable,
                                      style: GoogleFonts.lato(
                                        color: AppColors.greys60,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        height: 1.5,
                                        letterSpacing: 0.25,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      } else {
                        var course = snapshot.data;
                        var imageExtension;
                        if (snapshot.data['posterImage'] != null &&
                            snapshot.data['posterImage'] != '') {
                          imageExtension = course['posterImage']
                              .substring(course['posterImage'].length - 3);
                        }
                        return Consumer<LearnRepository>(
                            builder: (context, learnRepository, _) {
                          final cbpData = learnRepository.cbplanData;
                          if (course['primaryCategory']
                                  .toString()
                                  .toLowerCase() ==
                              PrimaryCategory.course.toLowerCase()) {
                            isAcbp = checkIsAcbp(course['identifier'], cbpData);
                          }
                          if (isAcbp) {
                            rewardPoint = ACBP_COURSE_COMPLETION_POINT;
                            if (_courseProgress == 100) {
                              checkIsKarmaPointRewarded(course['identifier']);
                            } else if (getTimeDiff(cbpEndDate) < 0) {
                              showCourseCompletionRewardMessage = false;
                              isAcbp = false;
                              rewardPoint = COURSE_COMPLETION_POINT;
                            }
                          } else {
                            showCongratsMessage.value = true;
                            rewardPoint = COURSE_COMPLETION_POINT;
                          }
                          return NestedScrollView(
                            headerSliverBuilder: (BuildContext context,
                                bool innerBoxIsScrolled) {
                              return <Widget>[
                                SliverAppBar(
                                    pinned: false,
                                    // expandedHeight: 450,
                                    expandedHeight:
                                        MediaQuery.of(context).size.height *
                                            0.525,
                                    leading: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      child:
                                          BackButton(color: AppColors.greys60),
                                    ),
                                    flexibleSpace: ListView(
                                      shrinkWrap: true,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          child: Align(
                                            alignment: Alignment.topRight,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                // Container(
                                                //   child: !widget
                                                //           .isFeaturedCourse
                                                //       ? IconButton(
                                                //           icon: Icon(
                                                //             Icons.search,
                                                //             color: AppColors
                                                //                 .greys60,
                                                //           ),
                                                //           onPressed: () =>
                                                //               Navigator.push(
                                                //                 context,
                                                //                 FadeRoute(
                                                //                     page: CustomTabs(
                                                //                         customIndex:
                                                //                             2)),
                                                //               ))
                                                //       : SizedBox(
                                                //           height: 36,
                                                //         ),
                                                // ),
                                                ((_courseDetails[
                                                                'courseCategory'] !=
                                                            PrimaryCategory
                                                                .inviteOnlyProgram &&
                                                        _courseDetails[
                                                                'courseCategory'] !=
                                                            PrimaryCategory
                                                                .moderatedCourses &&
                                                        _courseDetails[
                                                                'courseCategory'] !=
                                                            PrimaryCategory
                                                                .moderatedProgram &&
                                                        _courseDetails[
                                                                'courseCategory'] !=
                                                            PrimaryCategory
                                                                .moderatedAssessment))
                                                    ? Container(
                                                        child: IconButton(
                                                            icon: Icon(
                                                              Icons.share,
                                                              color: AppColors
                                                                  .greys60,
                                                            ),
                                                            onPressed: () {
                                                              _shareModalBottomSheetMenu();
                                                            }))
                                                    : SizedBox(
                                                        height: 36,
                                                      ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Stack(
                                          children: [
                                            Container(
                                                width: double.infinity,
                                                child: course['posterImage'] !=
                                                        null
                                                    ? imageExtension != 'svg'
                                                        ? Image.network(
                                                            Helper.convertToPortalUrl(
                                                                course[
                                                                    'posterImage']),
                                                            fit: BoxFit.cover,
                                                            errorBuilder: (context,
                                                                    error,
                                                                    stackTrace) =>
                                                                Image.asset(
                                                                  'assets/img/image_placeholder.jpg',
                                                                  // width: 320,
                                                                  // height: 182,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ))
                                                        : Image.asset(
                                                            'assets/img/image_placeholder.jpg',
                                                            // width: 320,
                                                            // height: 182,
                                                            fit: BoxFit.cover,
                                                          )
                                                    : Image.asset(
                                                        'assets/img/image_placeholder.jpg',
                                                        // width: 320,
                                                        // height: 182,
                                                        fit: BoxFit.cover,
                                                      )),
                                            // CouseDetailsPageInfoBanner(
                                            //     showBanner: course['batches'] !=
                                            //             null
                                            //         ? _showBanner &&
                                            //             DateTime.parse(
                                            //                     course['batches']
                                            //                             [0]
                                            //                         ['startDate'])
                                            //                 .isAfter(
                                            //                     DateTime.now())
                                            //         : false,
                                            //     callBack: () {
                                            //       setState(() {
                                            //         _showBanner = false;
                                            //       });
                                            //     },
                                            //     //TO DO: Please update below for dynamic
                                            //     days: course['batches'] != null
                                            //         ? DateTime.parse(
                                            //                 course['batches'][0]
                                            //                     ['startDate'])
                                            //             .difference(
                                            //                 DateTime.now())
                                            //             .inDays
                                            //             .toString()
                                            //         : ''),
                                          ],
                                        ),
                                        Container(
                                          alignment: Alignment.topLeft,
                                          padding: EdgeInsets.fromLTRB(
                                              20, 20, 20, 10),
                                          child: Text(
                                            course['name'] != null
                                                ? course['name']
                                                : '',
                                            style: GoogleFonts.lato(
                                              color: AppColors.greys87,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16.0,
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                              margin: EdgeInsets.all(8),
                                              padding: EdgeInsets.all(8),
                                              alignment: Alignment.topLeft,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                border: Border.all(
                                                    color: AppColors.grey08),
                                                borderRadius: BorderRadius.all(
                                                    const Radius.circular(
                                                        20.0)),
                                                // shape: BoxShape.circle,
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 12),
                                                    child: SvgPicture.asset(
                                                      'assets/img/course_icon.svg',
                                                      width: 16.0,
                                                      height: 16.0,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 6),
                                                    child: Text(
                                                      course['primaryCategory'] !=
                                                              null
                                                          ? course[
                                                                  'primaryCategory']
                                                              .toUpperCase()
                                                          : '',
                                                      style: GoogleFonts.lato(
                                                        color:
                                                            AppColors.greys60,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.all(8),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                border: Border.all(
                                                    color: AppColors.grey08),
                                                borderRadius: BorderRadius.all(
                                                    const Radius.circular(
                                                        20.0)),
                                                // shape: BoxShape.circle,
                                              ),
                                              child: Image(
                                                height: 30,
                                                width: 60,
                                                image: course['creatorLogo'] !=
                                                            null &&
                                                        course['creatorLogo'] !=
                                                            ''
                                                    ? NetworkImage(Helper
                                                        .convertToPortalUrl(
                                                            course[
                                                                'creatorLogo']))
                                                    : AssetImage(
                                                        'assets/img/igot_icon.png'),
                                                fit: BoxFit.scaleDown,
                                              ),
                                            )
                                          ],
                                        ),
                                        Container(
                                          alignment: Alignment.topLeft,
                                          padding: EdgeInsets.only(
                                              left: 20, right: 20),
                                          child: Text(
                                            course['purpose'] != null
                                                ? course['purpose']
                                                : '',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.lato(
                                              color: AppColors.greys87,
                                              height: 1.5,
                                              fontSize: 16.0,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          child: Row(
                                            children: <Widget>[
                                              // Container(
                                              Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 20, top: 15),
                                                  child: Row(
                                                    children: <Widget>[
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(right: 5),
                                                        child: Text(
                                                          (_rating != null
                                                                  ? double.parse(
                                                                          (_rating)
                                                                              .toStringAsFixed(1))
                                                                      .toString()
                                                                  : 0.0)
                                                              .toString(),
                                                          style:
                                                              GoogleFonts.lato(
                                                            color: AppColors
                                                                .primaryOne,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: 14.0,
                                                          ),
                                                        ),
                                                      ),
                                                      RatingBarIndicator(
                                                        rating: _rating != null
                                                            ? _rating
                                                            : 0,
                                                        itemBuilder:
                                                            (context, index) =>
                                                                Icon(
                                                          Icons.star,
                                                          color: AppColors
                                                              .primaryOne,
                                                        ),
                                                        itemCount: 5,
                                                        itemSize: 20.0,
                                                        direction:
                                                            Axis.horizontal,
                                                      ),
                                                    ],
                                                  )),
                                              // Spacer(),
                                              // _courseBatches.length > 0
                                              //     ? Container(
                                              //         padding: EdgeInsets.only(
                                              //             top: 10,
                                              //             // left: 20,
                                              //             right: 20),
                                              //         child: SimpleDropdown(
                                              //             items: _batchesNames,
                                              //             selectedItem:
                                              //                 _batchesNames[0],
                                              //             parentAction:
                                              //                 enrollToBatch),
                                              //       )
                                              //     : Center(),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 16,
                                              right: 300,
                                              top: 8,
                                              bottom: 10),
                                          child: Container(
                                            height: 48,
                                            width: 48,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                  image: course['creatorLogo'] !=
                                                              null &&
                                                          course['creatorLogo'] !=
                                                              ''
                                                      ? NetworkImage(Helper
                                                          .convertToPortalUrl(
                                                              course[
                                                                  'creatorLogo']))
                                                      : AssetImage(
                                                          'assets/img/Karmayogi_bharat_logo_horizontal.png'),
                                                  fit: BoxFit.scaleDown),
                                              color: Colors.white,
                                              borderRadius: BorderRadius.all(
                                                  const Radius.circular(4.0)),
                                              // shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppColors.grey08,
                                                  blurRadius: 3,
                                                  spreadRadius: 0,
                                                  offset: Offset(
                                                    3,
                                                    3,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        course['keywords'] != null &&
                                                course['keywords'].length > 0
                                            ? Padding(
                                                padding:
                                                    const EdgeInsets.all(16.0),
                                                child: Wrap(
                                                    children: _getTags(
                                                        course['keywords'])),
                                              )
                                            : Center(),
                                        // SvgPicture.memory(_base64CertificateImage)
                                        // SvgPicture.string(
                                        //   _base64CertificateImage.toString(),
                                        //   fit: BoxFit.cover,
                                        // )
                                      ],
                                    )),
                                SliverPersistentHeader(
                                  delegate: SilverAppBarDelegate(
                                    TabBar(
                                      isScrollable: true,
                                      indicator: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: AppColors.darkBlue,
                                            width: 2.0,
                                          ),
                                        ),
                                      ),
                                      indicatorColor: Colors.white,
                                      labelPadding: EdgeInsets.only(top: 0.0),
                                      unselectedLabelColor: AppColors.greys60,
                                      labelColor: AppColors.primaryThree,
                                      labelStyle: GoogleFonts.lato(
                                        fontSize: 10.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      unselectedLabelStyle: GoogleFonts.lato(
                                        fontSize: 10.0,
                                        fontWeight: FontWeight.normal,
                                      ),
                                      tabs: [
                                        for (var tabItem in learnTabs)
                                          Container(
                                            // width: 110,
                                            padding: const EdgeInsets.only(
                                                left: 16, right: 16),
                                            child: Tab(
                                              child: Padding(
                                                padding: EdgeInsets.all(5.0),
                                                child: Text(
                                                  tabItem.title,
                                                  style: GoogleFonts.lato(
                                                    color: AppColors.greys87,
                                                    fontSize: 14.0,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                      ],
                                      controller: _controller,
                                      onTap: (value) {
                                        setState(() {
                                          _tabIndex = _controller.index;
                                        });
                                        _triggerInteractTelemetryData(
                                            _controller.index);
                                      },
                                    ),
                                  ),
                                  pinned: true,
                                  floating: false,
                                ),
                              ];
                            },

                            // TabBar view
                            body: Container(
                              color: AppColors.lightBackground,
                              child: FutureBuilder(
                                  future: Future.delayed(
                                      Duration(milliseconds: 500)),
                                  builder: (BuildContext context,
                                      AsyncSnapshot snapshot) {
                                    return ValueListenableBuilder<bool>(
                                        valueListenable:
                                            showKarmaPointClaimButton,
                                        builder: (context, value, _) {
                                          return isBlendedProgram
                                              ? ValueListenableBuilder<bool>(
                                                  valueListenable:
                                                      showBlendedProgramReqButton,
                                                  builder: (context, value, _) {
                                                    return TabBarView(
                                                      controller: _controller,
                                                      children: [
                                                        CourseOverviewPage(
                                                          isBlendedProgram:
                                                              isBlendedProgram,
                                                          batchParentAction:
                                                              setBatchSelection,
                                                          enrolledBatch:
                                                              enrolledBatch,
                                                          wfId: wfId,
                                                          enrollStatusParentAction:
                                                              setEnrollStatus,
                                                          course: courseInfo,
                                                          selectedBatchId:
                                                              selectedBatch !=
                                                                      null
                                                                  ? selectedBatch
                                                                          .batchId ??
                                                                      _batchId
                                                                  : _batchId,
                                                          courseAuthors:
                                                              _courseAuthors,
                                                          courseCurators:
                                                              _courseCurators,
                                                          certificate:
                                                              _base64CertificateImage,
                                                          progress:
                                                              courseDetails !=
                                                                      null
                                                                  ? _courseProgress
                                                                  : null,
                                                          parentAction:
                                                              _getRating,
                                                          isStarted: (_navigationItems
                                                                          .length >
                                                                      0 &&
                                                                  _currentCourse !=
                                                                      null)
                                                              ? true
                                                              : false,
                                                          isFeatured: widget
                                                              .isFeaturedCourse,
                                                          enableDropdown: (!showBlendedProgramReqButton
                                                                      .value &&
                                                                  !showStart) ||
                                                              isRequestRejected ||
                                                              isRequestRemoved,
                                                          enrolmentStatus: showStart
                                                              ? EnrolmentStatus.enrolled
                                                              : showWithdrawbtnforEnrolled
                                                                  ? EnrolmentStatus.waiting
                                                                  : isRequestRejected
                                                                      ? EnrolmentStatus.rejected
                                                                      : isRequestRemoved
                                                                          ? EnrolmentStatus.removed
                                                                          : EnrolmentStatus.withdrawn,
                                                          enableRequestWithdrawBtn:
                                                              enableRequestWithdrawBtn,
                                                          cbpEndDate:
                                                              cbpEndDate,
                                                          isACBP: isAcbp,
                                                          showKarmaPointClaimButton:
                                                              showKarmaPointClaimButton
                                                                  .value,
                                                          claimedKarmaPoint:
                                                              updateKarmaPointInfo,
                                                          certificateId:
                                                              _certificateId,
                                                        ),
                                                        CourseContentPage(
                                                            identifier:
                                                                widget.id,
                                                            course: course,
                                                            isContinueLearning:
                                                                widget
                                                                    .isContinueLearning,
                                                            batchId: _batchId,
                                                            contentProgress:
                                                                _allContentProgress,
                                                            parentAction:
                                                                updateContents,
                                                            isFeatured: widget
                                                                .isFeaturedCourse,
                                                            enrollmentList:
                                                                _continueLearningcourses),
                                                        FutureBuilder(
                                                            future: Future
                                                                .delayed(Duration(
                                                                    milliseconds:
                                                                        500)),
                                                            builder: (BuildContext
                                                                    context,
                                                                AsyncSnapshot
                                                                    snapshot) {
                                                              bool
                                                                  isSessionAvailable =
                                                                  false;
                                                              if (courseInfo[
                                                                      'batches'] !=
                                                                  null) {
                                                                courseInfo[
                                                                        'batches']
                                                                    .forEach(
                                                                        (batch) {
                                                                  if (batch
                                                                          .batchAttributes !=
                                                                      null) {
                                                                    if (batch
                                                                        .batchAttributes
                                                                        .sessionDetailsV2
                                                                        .isNotEmpty) {
                                                                      isSessionAvailable =
                                                                          true;
                                                                    }
                                                                  }
                                                                });
                                                              }
                                                              return isBlendedProgram &&
                                                                      !isSessionAvailable
                                                                  ? Container(
                                                                      padding: EdgeInsets.only(
                                                                          top:
                                                                              20),
                                                                      child: Text(
                                                                          AppLocalizations.of(context)
                                                                              .mLearnNoSessionAvailable,
                                                                          textAlign: TextAlign
                                                                              .center,
                                                                          style:
                                                                              GoogleFonts
                                                                                  .lato(
                                                                            color:
                                                                                AppColors.grey40,
                                                                            fontWeight:
                                                                                FontWeight.w700,
                                                                            letterSpacing:
                                                                                0.5,
                                                                            fontSize:
                                                                                14,
                                                                          )))
                                                                  : CourseSessionPage(
                                                                      course:
                                                                          courseInfo,
                                                                      isBlendedProgram:
                                                                          isBlendedProgram,
                                                                      isContinueLearning:
                                                                          widget
                                                                              .isContinueLearning,
                                                                      batchId: selectedBatch !=
                                                                              null
                                                                          ? selectedBatch
                                                                              .batchId
                                                                          : _batchId,
                                                                      contentProgress:
                                                                          _allContentProgress,
                                                                      parentAction:
                                                                          updateContents,
                                                                      isFeatured:
                                                                          widget
                                                                              .isFeaturedCourse,
                                                                      scannerVisibility:
                                                                          (showStart &&
                                                                              isBatchStarted));
                                                            }),
                                                        CourseDiscussionPage(
                                                            course),
// =======
//                                               course: course,
//                                               courseAuthors: _courseAuthors,
//                                               courseCurators: _courseCurators,
//                                               // taggedCompetency:
//                                               //     _profileDetails != null
//                                               //         ? _profileDetails
//                                               //             .first.competencies
//                                               //         : [],
//                                               certificate:
//                                                   _base64CertificateImage,
//                                               progress: courseDetails != null
//                                                   ? _courseProgress
//                                                   : null,
//                                               parentAction: _getRating,
//                                               isStarted: (_navigationItems
//                                                               .length >
//                                                           0 &&
//                                                       _currentCourse != null)
//                                                   ? true
//                                                   : false,
//                                               isFeatured:
//                                                   widget.isFeaturedCourse,
//                                             ),
//                                             CourseContentPage(
//                                                 identifier: widget.id,
//                                                 course: course,
//                                                 isContinueLearning:
//                                                     widget.isContinueLearning,
//                                                 batchId: _batchId,
//                                                 contentProgress:
//                                                     _allContentProgress,
//                                                 parentAction: updateContents,
//                                                 isFeatured:
//                                                     widget.isFeaturedCourse,
//                                                 isProgram: _courseDetails[
//                                                             'primaryCategory'] ==
//                                                         EnglishLang.program &&
//                                                     courseDetails != null),
// >>>>>>> origin/curated-program
                                                      ],
                                                    );
                                                  })
                                              : widget.isFeaturedCourse
                                                  ? TabBarView(
                                                      controller: _controller,
                                                      children: [
                                                        CourseOverviewPage(
                                                          course: course,
                                                          courseAuthors:
                                                              _courseAuthors,
                                                          courseCurators:
                                                              _courseCurators,
                                                          // taggedCompetency:
                                                          //     _profileDetails != null
                                                          //         ? _profileDetails
                                                          //             .first.competencies
                                                          //         : [],
                                                          certificate:
                                                              _base64CertificateImage,
                                                          progress:
                                                              courseDetails !=
                                                                      null
                                                                  ? _courseProgress
                                                                  : null,
                                                          parentAction:
                                                              _getRating,
                                                          isStarted: (_navigationItems
                                                                          .length >
                                                                      0 &&
                                                                  _currentCourse !=
                                                                      null)
                                                              ? true
                                                              : false,
                                                          isFeatured: widget
                                                              .isFeaturedCourse,
                                                          enableDropdown:
                                                              !showBlendedProgramReqButton
                                                                  .value,
                                                          cbpEndDate:
                                                              cbpEndDate,
                                                          isACBP: isAcbp,
                                                          showKarmaPointClaimButton:
                                                              showKarmaPointClaimButton
                                                                  .value,
                                                          claimedKarmaPoint:
                                                              updateKarmaPointInfo,
                                                          certificateId:
                                                              _certificateId,
                                                        ),
                                                        CourseContentPage(
                                                            identifier:
                                                                widget.id,
                                                            course: course,
                                                            isContinueLearning:
                                                                widget
                                                                    .isContinueLearning,
                                                            batchId: _batchId,
                                                            contentProgress:
                                                                _allContentProgress,
                                                            parentAction:
                                                                updateContents,
                                                            isFeatured: widget
                                                                .isFeaturedCourse,
                                                            enrollmentList:
                                                                _continueLearningcourses,
                                                            isProgram: _courseDetails[
                                                                        'primaryCategory'] ==
                                                                    EnglishLang
                                                                        .program &&
                                                                courseDetails !=
                                                                    null),
                                                      ],
                                                    )
                                                  : widget.isStandAloneAssessment
                                                      ? TabBarView(
                                                          controller:
                                                              _controller,
                                                          children: [
                                                            CourseOverviewPage(
                                                              course: course,
                                                              courseAuthors:
                                                                  _courseAuthors,
                                                              courseCurators:
                                                                  _courseCurators,
                                                              // taggedCompetency:
                                                              //     _profileDetails != null
                                                              //         ? _profileDetails
                                                              //             .first.competencies
                                                              //         : [],
                                                              certificate:
                                                                  _base64CertificateImage,
                                                              progress:
                                                                  courseDetails !=
                                                                          null
                                                                      ? _courseProgress
                                                                      : null,
                                                              parentAction:
                                                                  _getRating,
                                                              isStarted: (_navigationItems
                                                                              .length >
                                                                          0 &&
                                                                      _currentCourse !=
                                                                          null)
                                                                  ? true
                                                                  : false,
                                                              isFeatured: widget
                                                                  .isFeaturedCourse,
                                                              enableDropdown:
                                                                  !showBlendedProgramReqButton
                                                                      .value,
                                                              cbpEndDate:
                                                                  cbpEndDate,
                                                              isACBP: isAcbp,
                                                              showKarmaPointClaimButton:
                                                                  showKarmaPointClaimButton
                                                                      .value,
                                                              claimedKarmaPoint:
                                                                  updateKarmaPointInfo,
                                                              certificateId:
                                                                  _certificateId,
                                                            ),
                                                            CourseContentPage(
                                                              identifier:
                                                                  widget.id,
                                                              course: course,
                                                              isContinueLearning:
                                                                  widget
                                                                      .isContinueLearning,
                                                              batchId: _batchId,
                                                              contentProgress:
                                                                  _allContentProgress,
                                                              parentAction:
                                                                  updateContents,
                                                              isFeatured: widget
                                                                  .isFeaturedCourse,
                                                            ),
                                                            CourseDiscussionPage(
                                                                course)
                                                          ],
                                                        )
                                                      : TabBarView(
                                                          controller:
                                                              _controller,
                                                          children: [
                                                            CourseOverviewPage(
                                                              course: course,
                                                              courseAuthors:
                                                                  _courseAuthors,
                                                              courseCurators:
                                                                  _courseCurators,
                                                              // taggedCompetency:
                                                              //     _profileDetails != null
                                                              //         ? _profileDetails
                                                              //             .first.competencies
                                                              //         : [],
                                                              certificate:
                                                                  _base64CertificateImage,
                                                              progress:
                                                                  courseDetails !=
                                                                          null
                                                                      ? _courseProgress
                                                                      : null,
                                                              parentAction:
                                                                  _getRating,
                                                              isStarted: (_navigationItems
                                                                              .length >
                                                                          0 &&
                                                                      _currentCourse !=
                                                                          null)
                                                                  ? true
                                                                  : false,
                                                              isFeatured: widget
                                                                  .isFeaturedCourse,
                                                              enableDropdown:
                                                                  !showBlendedProgramReqButton
                                                                      .value,
                                                              cbpEndDate:
                                                                  cbpEndDate,
                                                              isACBP: isAcbp,
                                                              showKarmaPointClaimButton:
                                                                  showKarmaPointClaimButton
                                                                      .value,
                                                              claimedKarmaPoint:
                                                                  updateKarmaPointInfo,
                                                              certificateId:
                                                                  _certificateId,
                                                            ),
                                                            CourseContentPage(
                                                                identifier:
                                                                    widget.id,
                                                                course: course,
                                                                isContinueLearning:
                                                                    widget
                                                                        .isContinueLearning,
                                                                batchId:
                                                                    _batchId,
                                                                contentProgress:
                                                                    _allContentProgress,
                                                                parentAction:
                                                                    updateContents,
                                                                isFeatured: widget
                                                                    .isFeaturedCourse,
                                                                enrollmentList:
                                                                    _continueLearningcourses,
                                                                isProgram: _courseDetails[
                                                                            'primaryCategory'] ==
                                                                        EnglishLang
                                                                            .program &&
                                                                    courseDetails !=
                                                                        null),
                                                            CourseDiscussionPage(
                                                                course),
                                                            // FutureBuilder(
                                                            //     future:
                                                            //         _getCourseLearners(),
                                                            //     builder: (BuildContext
                                                            //             context,
                                                            //         AsyncSnapshot<dynamic>
                                                            //             snapshot) {
                                                            //       return CourseLearnersPage(
                                                            //           course,
                                                            //           _courseLearners);
                                                            //     }),
                                                          ],
                                                        );
                                        });
                                  }),
                            ),
                          );
                        });
                      }
                    } else {
                      // return Center(child: CircularProgressIndicator());
                      return PageLoader();
                    }
                  }),
            )),
        floatingActionButton: (learnTabs.elementAt(_tabIndex).title ==
                    AppLocalizations.of(context).mLearnCourseDiscussion &&
                !widget.isFeaturedCourse)
            ? Padding(
                padding: const EdgeInsets.only(bottom: 75),
                child: OpenContainer(
                    closedElevation: 10,
                    openColor: AppColors.primaryThree,
                    transitionDuration: Duration(milliseconds: 750),
                    openBuilder: (context, _) => NewDiscussionPage(
                          isCourseDiscussion: true,
                          cid: _catId,
                        ),
                    closedShape: CircleBorder(),
                    closedColor: AppColors.primaryThree,
                    transitionType: ContainerTransitionType.fadeThrough,
                    closedBuilder: (context, openContainer) =>
                        FloatingActionButton(
                          //   boxShadow: [
                          //   BoxShadow(
                          //     color: AppColors.grey08,
                          //     blurRadius: 3,
                          //     spreadRadius: 0,
                          //     offset: Offset(
                          //       3,
                          //       3,
                          //     ),
                          //   ),
                          // ],
                          elevation: 10,
                          heroTag: 'newDiscussion',
                          onPressed: openContainer,
                          child: Icon(Icons.add),
                          backgroundColor: AppColors.primaryThree,
                        )),
              )
            : Center(),
        bottomSheet: FutureBuilder(
            future: _getCourseDetails(),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.hasData) {
                return _navigationItems.length > 0
                    ? _currentCourse != null && courseDetails != null
                        ? Wrap(
                            children: [
                              courseDetails != null &&
                                      courseDetails.contentType.toLowerCase() ==
                                          'course'
                                  ? Container(
                                      width: MediaQuery.of(context).size.width,
                                      color: Colors.white,
                                      margin: const EdgeInsets.fromLTRB(
                                          20, 10, 20, 10),
                                      child: _courseProgress == 100
                                          ? ValueListenableBuilder<bool>(
                                              valueListenable:
                                                  showCongratsMessage,
                                              builder: (context, value, _) {
                                                return (showCongratsMessage
                                                        .value)
                                                    ? karmaCongratsMessageWidget()
                                                    : SizedBox.shrink();
                                              })
                                          : courseCompletionMessageWidget(),
                                    )
                                  : Center(),
                              Container(
                                height: 48,
                                color: Colors.white,
                                width: double.infinity,
                                margin:
                                    const EdgeInsets.fromLTRB(20, 10, 20, 10),
                                child: TextButton(
                                  onPressed: (!isBatchStarted &&
                                          isBlendedProgram)
                                      ? null
                                      : () {
                                          // Navigator.of(context).pop(false);
                                          if (_courseProgress == 100) {
                                            setState(() {
                                              _currentCourse = _navigationItems
                                                          .first[0] ==
                                                      null
                                                  ? _navigationItems.first
                                                  : (_navigationItems.first[0]
                                                              [0] ==
                                                          null
                                                      ? _navigationItems
                                                          .first.first
                                                      : _navigationItems
                                                          .first.first.first);
                                            });
                                          }
                                          Navigator.push(
                                              context,
                                              FadeRoute(
                                                  page: CourseNavigationPage(
                                                course: _courseDetails,
                                                identifier:
                                                    _currentCourse['contentId'],
                                                contentProgress:
                                                    _allContentProgress,
                                                navigation: _navigationItems,
                                                moduleName: _currentCourse[
                                                            'moduleName'] !=
                                                        null
                                                    ? _currentCourse[
                                                        'moduleName']
                                                    : (_currentCourse[
                                                        'courseName']),
                                                batchId: _batchId,
                                                courseProgress: _courseProgress,
                                                updateCourseProgress:
                                                    _getCourseProgress,
                                                parentAction: _updateData,
                                                isFeatured:
                                                    widget.isFeaturedCourse,
                                                enrollmentList:
                                                    _continueLearningcourses,
                                              )));
                                        },
                                  style: TextButton.styleFrom(
                                    // primary: Colors.white,
                                    backgroundColor:
                                        (!isBatchStarted && isBlendedProgram)
                                            ? AppColors.lightSelected
                                            : AppColors.customBlue,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                        side: BorderSide(
                                            color: AppColors.grey16)),
                                    // onSurface: Colors.grey,
                                  ),
                                  child: Text(
                                    _courseProgress == 100
                                        ? AppLocalizations.of(context)
                                            .mLearnStartAgain
                                        : _courseDetails[
                                                    'cumulativeTracking'] !=
                                                null
                                            ? _courseDetails[
                                                        'cumulativeTracking'] &&
                                                    _courseProgress == 0
                                                ? AppLocalizations.of(context)
                                                    .mLearnStart
                                                : AppLocalizations.of(context)
                                                    .mLearnResume
                                            : AppLocalizations.of(context)
                                                .mLearnResume,
                                    style: GoogleFonts.lato(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        // Container(
                        //     height: _currentCourse != null ? 75 : 0,
                        //     child: Stack(children: [
                        //       Positioned(
                        //           child: Align(
                        //               alignment: FractionalOffset.bottomCenter,
                        //               child: Container(
                        //                   // padding: EdgeInsets.all(20),
                        //                   width: double.infinity,
                        //                   height: 75,
                        //                   color: Colors.white,
                        //                   child: InkWell(
                        //                       onTap: () {
                        //                         Navigator.of(context)
                        //                             .pop(false);
                        //                         Navigator.push(
                        //                             context,
                        //                             FadeRoute(
                        //                                 page:
                        //                                     CourseNavigationPage(
                        //                               course: _courseDetails,
                        //                               identifier:
                        //                                   _currentCourse[
                        //                                       'contentId'],
                        //                               contentProgress:
                        //                                   _allContentProgress,
                        //                               navigation:
                        //                                   _navigationItems,
                        //                               moduleName:
                        //                                   _currentCourse[
                        //                                       'moduleName'],
                        //                               batchId: _batchId,
                        //                             )));
                        //                       },
                        //                       child: Stack(children: [
                        //                         SizedBox(
                        //                           width: double.infinity,
                        //                           child: SvgPicture.asset(
                        //                             'assets/img/login_header.svg',
                        //                             fit: BoxFit.cover,
                        //                             height: 75,

                        //                             // alignment: Alignment.topLeft,
                        //                           ),
                        //                         ),
                        //                         LinearProgressIndicator(
                        //                           minHeight: 4,
                        //                           backgroundColor:
                        //                               AppColors.grey16,
                        //                           valueColor:
                        //                               AlwaysStoppedAnimation<
                        //                                   Color>(
                        //                             AppColors.primaryThree,
                        //                           ),
                        //                           value: _currentCourse[
                        //                                           'currentProgress']
                        //                                       .runtimeType !=
                        //                                   String
                        //                               ? _currentCourse[
                        //                                   'currentProgress']
                        //                               : double.parse(
                        //                                   _currentCourse[
                        //                                       'currentProgress']),
                        //                         ),
                        //                         Container(
                        //                           height: 64,
                        //                           margin: EdgeInsets.only(
                        //                               top: 10.0),
                        //                           child: Row(
                        //                             children: [
                        //                               Padding(
                        //                                 padding:
                        //                                     const EdgeInsets
                        //                                         .only(left: 18),
                        //                                 child: SvgPicture.asset(
                        //                                   'assets/img/icons-av-play.svg',
                        //                                   color: AppColors
                        //                                       .primaryThree,
                        //                                   height: 22,
                        //                                 ),
                        //                                 // Icon(
                        //                                 //   Icons.play_circle_fill,
                        //                                 //   color: AppColors.primaryThree,
                        //                                 //   size: 22,
                        //                                 // ),
                        //                               ),
                        //                               Padding(
                        //                                 padding:
                        //                                     const EdgeInsets
                        //                                         .only(left: 16),
                        //                                 child: Column(
                        //                                     crossAxisAlignment:
                        //                                         CrossAxisAlignment
                        //                                             .start,
                        //                                     children: [
                        //                                       Container(
                        //                                         width: MediaQuery.of(
                        //                                                     context)
                        //                                                 .size
                        //                                                 .width -
                        //                                             56,
                        //                                         padding:
                        //                                             const EdgeInsets
                        //                                                     .only(
                        //                                                 top: 8),
                        //                                         child: Text(
                        //                                           _currentCourse[
                        //                                               'name'],
                        //                                           overflow:
                        //                                               TextOverflow
                        //                                                   .ellipsis,
                        //                                           style:
                        //                                               GoogleFonts
                        //                                                   .lato(
                        //                                             color: AppColors
                        //                                                 .greys87,
                        //                                             fontWeight:
                        //                                                 FontWeight
                        //                                                     .w700,
                        //                                             fontSize:
                        //                                                 16,
                        //                                           ),
                        //                                         ),
                        //                                       ),
                        //                                       Container(
                        //                                         width: MediaQuery.of(
                        //                                                     context)
                        //                                                 .size
                        //                                                 .width -
                        //                                             56,
                        //                                         padding:
                        //                                             const EdgeInsets
                        //                                                     .only(
                        //                                                 top: 8),
                        //                                         child: Text(
                        //                                           '${_currentCourse['currentIndex']}/${_currentCourse['moduleItems']} ${_currentCourse['name']}',
                        //                                           overflow:
                        //                                               TextOverflow
                        //                                                   .ellipsis,
                        //                                           style:
                        //                                               GoogleFonts
                        //                                                   .lato(
                        //                                             color: AppColors
                        //                                                 .greys60,
                        //                                             fontWeight:
                        //                                                 FontWeight
                        //                                                     .w700,
                        //                                             fontSize:
                        //                                                 14,
                        //                                           ),
                        //                                         ),
                        //                                       )
                        //                                     ]),
                        //                               )
                        //                             ],
                        //                           ),
                        //                         )
                        //                       ])))))
                        //     ]),
                        //   )
                        : (_courseDetails['primaryCategory'] ==
                                    EnglishLang.program &&
                                courseDetails == null &&
                                !widget.isModerated
                            ? Container(
                                width: double.infinity,
                                color: AppColors.grey04,
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  AppLocalizations.of(context)
                                      .mLearnYouAreNotInvited,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.lato(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14),
                                ))
                            : Wrap(
                                children: [
                                  courseDetails != null &&
                                          courseDetails.contentType
                                                  .toLowerCase() ==
                                              'course'
                                      ? Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          color: AppColors.appBarBackground,
                                          margin: const EdgeInsets.fromLTRB(
                                              20, 10, 20, 10),
                                          child: _courseProgress == 100
                                              ? karmaCongratsMessageWidget()
                                              : courseCompletionMessageWidget(),
                                        )
                                      : Center(),
                                  Container(
                                    height: 48,
                                    color: Colors.white,
                                    width: double.infinity,
                                    margin: const EdgeInsets.fromLTRB(
                                        20, 10, 20, 10),
                                    child: _disableButton
                                        ? PageLoader()
                                        : ValueListenableBuilder<bool>(
                                            valueListenable:
                                                showBlendedProgramReqButton,
                                            builder: (context, value, _) {
                                              return TextButton(
                                                onPressed: showBlendedProgramReqButton
                                                            .value ||
                                                        (!showStart &&
                                                            isAllBatchEnrollmentDateFinished) ||
                                                        (showStart &&
                                                                !isBatchStarted) &&
                                                            !widget.isModerated
                                                    ? null
                                                    : !_disableButton
                                                        ? () async {
                                                            startCourse = true;
                                                            if (_courseDetails[
                                                                        'primaryCategory'] ==
                                                                    PrimaryCategory
                                                                        .blendedProgram &&
                                                                _courseDetails[
                                                                        'batches'] !=
                                                                    null) {
                                                              if (_courseDetails[
                                                                          'wfSurveyLink'] !=
                                                                      null &&
                                                                  _courseDetails[
                                                                          'wfSurveyLink'] !=
                                                                      '') {
                                                                var surveyFormLink =
                                                                    _courseDetails[
                                                                        'wfSurveyLink'];
                                                                formId = int.parse(
                                                                    surveyFormLink
                                                                        .split(
                                                                            '/')
                                                                        .last);
                                                              }
                                                              if (isBlendedProgram &&
                                                                  !showStart) {
                                                                var response =
                                                                    await getForm(
                                                                        formId);
                                                                userSearch();
                                                                if (response !=
                                                                    null) {
                                                                  await showModalBottomSheet(
                                                                      isScrollControlled:
                                                                          true,
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.only(
                                                                            topLeft:
                                                                                Radius.circular(8),
                                                                            topRight: Radius.circular(8)),
                                                                        side:
                                                                            BorderSide(
                                                                          color:
                                                                              AppColors.grey08,
                                                                        ),
                                                                      ),
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (context) =>
                                                                              Padding(
                                                                                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                                                                                child: SurveyPage(response, setEnrollStatus, '${_courseDetails['identifier']},${_courseDetails['name']}', formId, _courseDetails['identifier'], batchList: _courseDetails['batches'], batchId: selectedBatch.batchId),
                                                                              ));
                                                                }
                                                              }
                                                            }

                                                            setState(() {
                                                              if (!isBlendedProgram) {
                                                                _disableButton =
                                                                    true;
                                                              }
                                                            });
                                                            if (isBlendedProgram &&
                                                                !showStart) {
                                                              await _enrollBlendedCourse();
                                                            }
                                                            if (!widget
                                                                    .isFeaturedCourse &&
                                                                courseDetails ==
                                                                    null &&
                                                                !isBlendedProgram) {
                                                              startCourse =
                                                                  false;
                                                              await _enrollCourse();
                                                            }
                                                            if (showStart ||
                                                                //  widget.isModerated ||
                                                                ((courseDetails !=
                                                                            null ||
                                                                        widget
                                                                            .isModerated) &&
                                                                    startCourse)) {
                                                              await Navigator
                                                                  .push(
                                                                      context,
                                                                      FadeRoute(
                                                                          page:
                                                                              CourseNavigationPage(
                                                                        course:
                                                                            _courseDetails,
                                                                        identifier: (_navigationItems[0][0] ==
                                                                                null)
                                                                            ? _navigationItems[0][
                                                                                'contentId']
                                                                            : (_navigationItems[0][0][0] != null
                                                                                ? _navigationItems[0][0][0]['contentId']
                                                                                : _navigationItems[0][0]['contentId']),
                                                                        contentProgress:
                                                                            _allContentProgress,
                                                                        navigation:
                                                                            _navigationItems,
                                                                        moduleName: _navigationItems[0][0] ==
                                                                                null
                                                                            ? _navigationItems[0]['moduleName'] != null
                                                                                ? _navigationItems[0]['moduleName']
                                                                                : ''
                                                                            : _navigationItems[0][0][0] != null
                                                                                ? _navigationItems[0][0][0]['moduleName']
                                                                                : _navigationItems[0][0]['moduleName'],
                                                                        batchId:
                                                                            _batchId,
                                                                        parentAction:
                                                                            _updateData,
                                                                        isFeatured:
                                                                            widget.isFeaturedCourse,
                                                                        courseProgress:
                                                                            _courseProgress,
                                                                        updateCourseProgress:
                                                                            _getCourseProgress,
                                                                        enrollmentList:
                                                                            _continueLearningcourses,
                                                                      )));
                                                            }
                                                            setState(() {
                                                              _disableButton =
                                                                  false;
                                                            });
                                                          }
                                                        : null,
                                                style: TextButton.styleFrom(
                                                  // primary: Colors.white,
                                                  backgroundColor:
                                                      showBlendedProgramReqButton
                                                                  .value ||
                                                              (!showStart &&
                                                                  isAllBatchEnrollmentDateFinished) ||
                                                              (showStart &&
                                                                  !isBatchStarted &&
                                                                  !widget
                                                                      .isModerated)
                                                          ? AppColors
                                                              .lightSelected
                                                          : AppColors
                                                              .customBlue,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                      side: BorderSide(
                                                          color: AppColors
                                                              .grey16)),
                                                  // onSurface: Colors.grey,
                                                ),
                                                child: Text(
                                                  widget.isFeaturedCourse
                                                      ? AppLocalizations.of(
                                                              context)
                                                          .mLearnView
                                                      : (_courseDetails[
                                                                  'primaryCategory'] ==
                                                              PrimaryCategory
                                                                  .standaloneAssessment)
                                                          ? AppLocalizations
                                                                  .of(context)
                                                              .mLearnTakeTest
                                                          : (_courseDetails[
                                                                      'primaryCategory'] ==
                                                                  PrimaryCategory
                                                                      .blendedProgram)
                                                              ? showStart
                                                                  ? AppLocalizations.of(
                                                                          context)
                                                                      .mLearnStart
                                                                  : showWithdrawbtnforEnrolled
                                                                      ? AppLocalizations.of(
                                                                              context)
                                                                          .mLearnRequestUnderReview
                                                                      : AppLocalizations.of(
                                                                              context)
                                                                          .mStaticRequestToEnrollProgram
                                                              : courseDetails !=
                                                                          null ||
                                                                      widget
                                                                          .isModerated
                                                                  ? AppLocalizations.of(
                                                                          context)
                                                                      .mLearnStart
                                                                  : AppLocalizations.of(
                                                                          context)
                                                                      .mLearnEnroll,
                                                  style: GoogleFonts.lato(
                                                    color:
                                                        showBlendedProgramReqButton
                                                                .value
                                                            ? AppColors
                                                                .primaryThree
                                                            : Colors.white,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              );
                                            }),
                                  ),
                                ],
                              ))
                    : Container(
                        height: 0,
                        child: Center(),
                      );
              } else {
                return PageLoader();
              }
            }));
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
                          AppLocalizations.of(context).mStaticCancel,
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
                          AppLocalizations.of(context).mStaticWithdraw,
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

  setBatchSelection(Batch value) async {
    selectedBatch = value;
    checkWorkflowStatus();
  }

  setEnrollStatus(String value) async {
    enrollStatus = value;
    if (value == 'Confirm') {
      await userSearch();
    }
  }

  updateKarmaPointInfo(bool value) async {
    if (value) {
      showCongratsMessage.value = true;
      showKarmaPointClaimButton.value = false;
    }
  }

  List updateTotalCourseProgress(contentId, progress, toRemoveChildNodes) {
    leafNodes.forEach((node) {
      if (contentId == node) {
        totalCourseProgress = totalCourseProgress + progress;
        toRemoveChildNodes.add(node);
      }
    });
    return toRemoveChildNodes;
  }

  void showToastMessage(BuildContext context, {String title, String message}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Column(
      children: [
        Text(title ?? ''),
        Text(
          message ?? '',
          textAlign: TextAlign.center,
        ),
      ],
    )));
  }

  void checkWorkflowStatus() {
    if (workflowDetails != null && workflowDetails.isNotEmpty) {
      if (workflowDetails[0]['wfInfo'] != null) {
        List workflowStates = [];
        if (selectedBatch == null) {
          workflowDetails[0]['wfInfo'].forEach((workFlow) {
            if (workFlow['currentStatus'] ==
                    WFBlendedProgramStatus.REJECTED.name ||
                workFlow['currentStatus'] ==
                    WFBlendedProgramStatus.REMOVED.name ||
                workFlow['currentStatus'] ==
                    WFBlendedProgramStatus.SEND_FOR_MDO_APPROVAL.name ||
                workFlow['currentStatus'] ==
                    WFBlendedProgramStatus.SEND_FOR_PC_APPROVAL.name) {
              courseInfo['batches'].forEach((batch) {
                if (workFlow['applicationId'] == batch.batchId) {
                  selectedBatch = batch;
                }
              });
            }
          });
          workflowStates = workflowDetails[0]['wfInfo'];
        } else {
          workflowDetails[0]['wfInfo'].forEach((workFlow) {
            if (workFlow['applicationId'] == selectedBatch.batchId) {
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
                List batches = courseInfo['batches'];
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
      showBlendedProgramReqButton.value = false;
      showWithdrawBtn(WFBlendedProgramStatus.WITHDRAWN.name);
    }
  }

  bool isValidBatch(var enrollmentEndDate) {
    var dateDiff = enrollmentEndDate.difference(DateTime.now()).inDays;
    return dateDiff >= 0;
  }

  void getCBPdata() async {
    cbpList = jsonDecode(await _storage.read(key: Storage.cbpdataInfo));
  }

  Widget karmaImageWidget() {
    return SvgPicture.asset(
      'assets/img/kp_icon.svg',
      width: 24,
      height: 24,
    );
  }

  Widget courseCompletionMessageWidget() {
    return showCourseCompletionRewardMessage || isAcbp
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: RichText(
              text: TextSpan(
                children: [
                  textWidget(AppLocalizations.of(context).mStaticEarn + ' ',
                      FontWeight.w400),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: karmaImageWidget(),
                  ),
                  textWidget(
                      ' $rewardPoint ' +
                          AppLocalizations.of(context).mStaticKarmaPoints,
                      FontWeight.w900),
                  textWidget(
                      ' ' +
                          AppLocalizations.of(context).mStaticCompletingCourse +
                          ' ',
                      FontWeight.w400),
                  WidgetSpan(
                      child: TooltipWidget(
                          message: isAcbp
                              ? AppLocalizations.of(context)
                                  .mStaticAcbpCourseCompletionInfo
                              : AppLocalizations.of(context)
                                  .mStaticCourseCompletionInfo))
                ],
              ),
            ),
          )
        : SizedBox.shrink();
  }

  Widget karmaCongratsMessageWidget() {
    return (showCourseCompletionRewardMessage &&
                showCourseCompletionCongratsMessage) ||
            isAcbp
        ? RichText(
            text: TextSpan(
              children: [
                textWidget(
                    AppLocalizations.of(context).mCourseCompletedMessage + ' ',
                    FontWeight.w400),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: karmaImageWidget(),
                ),
                textWidget(
                    ' $rewardPoint ' +
                        AppLocalizations.of(context).mStaticKarmaPoints +
                        '. ',
                    FontWeight.w900),
                WidgetSpan(
                    child: TooltipWidget(
                        message: AppLocalizations.of(context)
                            .mStaticCourseCompletedInfo))
              ],
            ),
          )
        : SizedBox.shrink();
  }

  TextSpan textWidget(String message, FontWeight font) {
    return TextSpan(
      text: message,
      style: TextStyle(
          color: AppColors.greys87,
          fontSize: 12,
          fontWeight: font,
          letterSpacing: 0.25),
    );
  }

  bool isInSameMonth(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month;
  }

  void checkCompletionMonth(Course courseDetails) {
    if (courseDetails.completedOn != null) {
      DateTime dateTime =
          DateTime.fromMillisecondsSinceEpoch(courseDetails.completedOn);
      if (dateTime.month != DateTime.now().month ||
          dateTime.year != DateTime.now().year) {
        showCourseCompletionCongratsMessage = false;
      }
    }
  }

  bool checkIsAcbp(String courseId, cbpData) {
    bool isCourseFound = false;
    if (cbpData.length != null) {
      if (cbpData.length == 0) {
        return isCourseFound;
      }
      cbpData['content'].forEach((cbp) {
        var data = cbp['contentList'].firstWhere(
            (element) => element['identifier'] == courseId,
            orElse: () => {});
        if (data.isNotEmpty) {
          isCourseFound = true;
        }
      });
    }
    // if(isCourseFound && getTimeDiff(cbpEndDate) < 0){
    //   isCourseFound = false;
    // }
    return isCourseFound;
  }

  void checkIsKarmaPointRewarded(String courseId) async {
    var response = await profileRepository.getKarmaPointCourseRead(courseId);
    if (response != null &&
        response.isNotEmpty &&
        response['points'] < ACBP_COURSE_COMPLETION_POINT) {
      showKarmaPointClaimButton.value = true;
    } else {
      showCongratsMessage.value = true;
    }
  }

  int getTimeDiff(String date1) {
    return DateTime.parse(
            DateFormat('yyyy-MM-dd').format(DateTime.parse(date1)))
        .difference(
            DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.now())))
        .inDays;
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Set to true for full-screen behavior
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              // Your content for the bottom sheet
              Text(
                AppLocalizations.of(context).mFullScreenMessage,
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close the bottom sheet
                },
                child: Text(AppLocalizations.of(context).mCommonClose),
              ),
            ],
          ),
        );
      },
    );
  }

  void _shareModalBottomSheetMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
            child: CourseSharingPage(
                formId,
                _courseDetails['identifier'],
                _courseDetails['name'],
                _courseDetails['posterImage'],
                _courseDetails['source'],
                widget.primaryCategory,
                receiveShareResponse));
      },
    );
  }

  void receiveShareResponse(String data) {
    _showSuccessDialogBox();
  }

  _showSuccessDialogBox() => {
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
                                  color: AppColors.positiveLight),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: Container(
                                      child: TitleRegularGrey60(
                                        AppLocalizations.of(context)
                                            .mContentSharePageSuccessMessage,
                                        fontSize: 14,
                                        color: AppColors.appBarBackground,
                                        maxLines: 3,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(16, 4, 4, 0),
                                    child: Icon(
                                      Icons.check,
                                      color: AppColors.appBarBackground,
                                      size: 24,
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
