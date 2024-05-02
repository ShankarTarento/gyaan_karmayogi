import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/localization/index.dart';
import 'package:karmayogi_mobile/respositories/_respositories/learn_repository.dart';
import 'package:karmayogi_mobile/services/index.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/about_tab/about_tab.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/services/toc_services.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/widgets/toc_button.dart';
import 'package:karmayogi_mobile/ui/widgets/index.dart';
import 'package:karmayogi_mobile/util/telemetry.dart';
import 'package:karmayogi_mobile/util/telemetry_db_helper.dart';
import 'package:provider/provider.dart';

import '../../../../../constants/_constants/storage_constants.dart';
import '../../../../../models/_arguments/index.dart';
import '../../../../../models/index.dart';
import '../../../../../respositories/_respositories/in_app_review_repository.dart';
import '../../../../../util/helper.dart';
import '../../../../skeleton/index.dart';
import '../../../index.dart';
import '../../learn/course_sharing/course_sharing_page.dart';
import '../util/toc_helper.dart';
import '../widgets/rate_now_pop_up.dart';
import 'about_tab/widgets/enroll_blended_program_button.dart';
import 'blended_program_content/blended_program_content.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CourseTocPage extends StatefulWidget {
  final CourseTocModel arguments;
  final List<Course> enrollmentDetails;
  CourseTocPage({Key key, @required this.arguments, this.enrollmentDetails})
      : super(key: key);
  @override
  State<CourseTocPage> createState() => _CourseTocPageState();
}

class _CourseTocPageState extends State<CourseTocPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final _storage = FlutterSecureStorage();
  LearnRepository learnRepository = LearnRepository();
  TabController learnTabController;
  CourseTocModel arguments;
  String courseId, batchId, lastAccessContentId;
  ValueNotifier<List<Course>> enrolmentList = ValueNotifier<List<Course>>([]);
  ValueNotifier<List> navigationItems = ValueNotifier([]);
  Map<String, dynamic> courseHierarchyData;
  Map _currentCourse;

  List<LearnTab> learnTabs;
  List<Map> showCertificate = [];
  bool isRatingTriggered = false,
      isFeaturedCourse = false,
      isCuratedProgram = false,
      isProgressRead = false,
      showToc = false;

  bool isBlendedProgram = false;

  var course, contentProgress = Map();
  double progress = 0.0;
  int courseIndex = 0;
  Course enrolledCourse;
  Course enrolledParentCourse;
  var formId = 1694586265488;
  bool focusRating = false;

  String userId;
  String userSessionId;
  String messageIdentifier;
  String departmentId;
  List allEventsData = [];
  Map rollup = {};
  String deviceIdentifier;
  var telemetryEventData;

  var _contentProgressResponse;

  @override
  void initState() {
    super.initState();
    navigationItems.value = [];
    courseId = widget.arguments.courseId;
    isFeaturedCourse = widget.arguments.isFeaturedCourse != null
        ? widget.arguments.isFeaturedCourse
        : false;

    if ((widget.arguments.isBlendedProgram != null &&
            widget.arguments.isBlendedProgram) ||
        (widget.arguments.isModeratedContent != null &&
            widget.arguments.isModeratedContent)) {
      getBatchDetails();
    }
    fetchData();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        clearCourseInfo(context);
        Provider.of<TocServices>(context, listen: false).clearCourseProgress();
      }
    });
  }

  @override
  void didChangeDependencies() {
     learnTabController = TabController(length: LearnTab.tocTabs(context).length, vsync: this, initialIndex: 0);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    navigationItems.value.clear();
    super.dispose();
  }

  List<Batch> batches = [];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(onWillPop: () async {
      clearCourseInfo(context);
      navigationItems.value.clear();
      Navigator.pop(context);
      return false;
    }, child: Scaffold(
        body: Consumer<LearnRepository>(builder: (context, learnRepository, _) {
      if (course == null || learnRepository.contentRead != null) {
        course = learnRepository.contentRead;
      }
      if (courseHierarchyData == null ||
          learnRepository.courseHierarchyInfo != null) {
        courseHierarchyData = learnRepository.courseHierarchyInfo;
      }
      if (course != null && course['courseCategory'] == "Blended Program") {
        isBlendedProgram = true;
        getBatchDetails();
      }
      if (course != null && courseHierarchyData != null && showToc) {
        if (course.runtimeType == String) {
          return NoDataWidget(
              message: AppLocalizations.of(context).mCourseNoCourse);
        } else {
          if (course['batches'] != null && course['batches'].isNotEmpty) {
            batchId = course['batches'].first['batchId'];
          }
          if (course['courseCategory'] != null &&
              course['courseCategory'] == PrimaryCategory.curatedProgram) {
            isCuratedProgram = true;
          }
          if (!isProgressRead) {
            checkIsEnrolled();
            getContentAndProgress();
            Future.delayed(Duration(milliseconds: 500), () {
              if (widget.arguments.showCourseCompletionMessage != null &&
                  widget.arguments.showCourseCompletionMessage) {
                showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    backgroundColor: AppColors.greys60,
                    builder: (ctx) => RateNowPopUp(
                          courseDetails: Course.fromJson(course),
                        ));
              }
            });
          }
          if (!isRatingTriggered) {
            getReviews();
            getYourRatingAndReview(course);
            isRatingTriggered = true;
          }

          return DefaultTabController(
              length: LearnTab.tocTabs(context).length,
              child: Stack(children: [
                NotificationListener<OverscrollIndicatorNotification>(
                  onNotification: (overscroll) {
                    overscroll.disallowIndicator();
                    return true;
                  },
                  child: SafeArea(
                    child: NestedScrollView(
                        //   controller: context.watch<TocServices>().scrollController,
                        headerSliverBuilder:
                            (BuildContext context, innerBoxIsScrolled) {
                          return <Widget>[
                            TocAppbarWidget(
                              isOverview: true,
                              showCourseShareOption: _showCourseShareOption(),
                              courseShareOptionCallback:
                                  _shareModalBottomSheetMenu,
                            ),
                            SliverToBoxAdapter(
                              child: ValueListenableBuilder<List<Course>>(
                                valueListenable: enrolmentList,
                                builder: (context, value, _) {
                                  return TocContentHeader(
                                    course: course,
                                    enrollmentDetails: enrolmentList.value,
                                    isFeaturedCourse:
                                        widget.arguments.isFeaturedCourse,
                                    clickedRating: () {
                                      setState(() {
                                        focusRating = true;
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                            SliverAppBar(
                              automaticallyImplyLeading: false,
                              pinned: true,
                              flexibleSpace: Container(
                                color: AppColors.darkBlue,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(16.0),
                                    topRight: Radius.circular(16.0),
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.only(top: 4),
                                    color: Colors.white,
                                    child: TabBar(
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
                                      labelColor: AppColors.darkBlue,
                                      labelStyle: GoogleFonts.lato(
                                        fontSize: 10.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      unselectedLabelStyle: GoogleFonts.lato(
                                        fontSize: 10.0,
                                        fontWeight: FontWeight.normal,
                                      ),
                                      onTap: (value) {
                                        _generateInteractTelemetryData(
                                            learnTabController.index == 0
                                                ? TelemetryIdentifier.aboutTab
                                                : TelemetryIdentifier
                                                    .contentTab);
                                      },
                                      tabs: [
                                        for (var tabItem
                                            in LearnTab.tocTabs(context))
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16),
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
                                      controller: learnTabController,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ];
                        },
                        body: TabBarView(
                            controller: learnTabController,
                            children: [
                              AboutTab(
                                  isBlendedProgram: isBlendedProgram,
                                  courseRead: course,
                                  enrollmentDetails: enrolmentList.value,
                                  courseHierarchy: courseHierarchyData,
                                  highlightRating: focusRating),
                              isBlendedProgram
                                  ? Consumer<TocServices>(
                                      builder: (context, tocServices, _) {
                                        return ValueListenableBuilder<List>(
                                          valueListenable: navigationItems,
                                          builder: (context, value, _) {
                                            return BlendedProgramContent(
                                              courseDetails: course,
                                              batch: tocServices.batch,
                                              enrollmentList:
                                                  enrolmentList.value,
                                              contentProgressResponse:
                                                  _contentProgressResponse,
                                              course: course,
                                              courseHierarchyData:
                                                  courseHierarchyData,
                                              courseId: courseId,
                                              lastAccessContentId:
                                                  lastAccessContentId,
                                              navigationItems:
                                                  navigationItems.value,
                                              enrolledCourse:
                                                  enrolledParentCourse,
                                            );
                                          },
                                        );
                                      },
                                    )
                                  : ValueListenableBuilder<List>(
                                      valueListenable: navigationItems,
                                      builder: (context, value, _) {
                                        return TocContentPage(
                                            courseId: courseId,
                                            course: course,
                                            enrolmentList: enrolmentList.value,
                                            courseHierarchy:
                                                courseHierarchyData,
                                            navigationItems:
                                                navigationItems.value,
                                            contentProgressResponse:
                                                _contentProgressResponse,
                                            lastAccessContentId:
                                                lastAccessContentId,
                                            readCourseProgress: () {
                                              if (enrolledParentCourse !=
                                                  null) {
                                                readCourseContentProgress(
                                                    courseId, batchId);
                                              }
                                            },
                                            enrolledCourse:
                                                enrolledParentCourse);
                                      }),
                            ])),
                  ),
                ),
                Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                        padding: EdgeInsets.fromLTRB(16, 24, 16, 32),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xffEEEEEE).withOpacity(0),
                              Color(0xffFFFFFF).withOpacity(1)
                            ],
                          ),
                        ),
                        child: isBlendedProgram
                            ? Consumer<TocServices>(
                                builder: (context, tocServices, _) {
                                return EnrollBlendedProgramButton(
                                  batches: batches,
                                  selectedBatch: tocServices.batch,
                                  courseDetails: course,
                                  enrollmentList: enrolmentList.value,
                                  contentProgressResponse:
                                      _contentProgressResponse,
                                  lastAccessContentId: lastAccessContentId,
                                  navigationItems: navigationItems.value,
                                  batchId: batchId,
                                  courseId: courseId,
                                );
                              })
                            : Consumer<TocServices>(
                                builder: (context, tocServices, _) {
                                return TocButton(
                                    isStandAloneAssesment:
                                        course["primaryCategory"] ==
                                                EnglishLang.standaloneAssessment
                                            ? true
                                            : false,
                                    isModerated:
                                        widget.arguments.isModeratedContent,
                                    courseDetails: course,
                                    enrolmentList: enrolmentList.value,
                                    navigationItems: navigationItems.value,
                                    contentProgressResponse:
                                        _contentProgressResponse,
                                    isCuratedProgram: isCuratedProgram,
                                    batchId: batchId,
                                    courseId: courseId,
                                    lastAccessContentId: lastAccessContentId,
                                    selectedBatch: tocServices.batch,
                                    batches: batches,
                                    readCourseProgress: () =>
                                        readCourseContentProgress(
                                            courseId, batchId),
                                    updateEnrolmentList: () async {
                                      await getEnrolmentInfo();
                                      checkIsEnrolled();
                                    });
                              }))),
              ]));
        }
      } else {
        return TocSkeletonPage(
            showCourseShareOption: false,
            courseShareOptionCallback: _shareModalBottomSheetMenu);
      }
    })));
  }

  void _generateTelemetryData() async {
    deviceIdentifier = await Telemetry.getDeviceIdentifier();
    userId = await Telemetry.getUserId(isPublic: isFeaturedCourse);
    userSessionId = await Telemetry.generateUserSessionId();
    messageIdentifier = await Telemetry.generateUserSessionId();
    departmentId = await Telemetry.getUserDeptId(isPublic: isFeaturedCourse);
    Map eventData1 = Telemetry.getImpressionTelemetryEvent(
        deviceIdentifier,
        userId,
        departmentId,
        isFeaturedCourse
            ? TelemetryPageIdentifier.publicCourseDetailsPageId
            : TelemetryPageIdentifier.courseDetailsPageId,
        userSessionId,
        messageIdentifier,
        TelemetryType.page,
        (isFeaturedCourse
                ? TelemetryPageIdentifier.publicCourseDetailsPageUri
                : TelemetryPageIdentifier.courseDetailsPageUri)
            .replaceAll(':do_ID', courseId),
        env: TelemetryEnv.learn,
        objectId: courseId,
        objectType: course['primaryCategory'],
        isPublic: isFeaturedCourse);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData1);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap(),
        isPublic: isFeaturedCourse);
  }

  void _generateInteractTelemetryData(String contentId) async {
    Map eventData = Telemetry.getInteractTelemetryEvent(
        deviceIdentifier,
        userId,
        departmentId,
        (isFeaturedCourse
                ? TelemetryPageIdentifier.publicCourseDetailsPageId
                : TelemetryPageIdentifier.courseDetailsPageId) +
            '_' +
            contentId,
        userSessionId,
        messageIdentifier,
        contentId,
        TelemetrySubType.courseTab,
        env: TelemetryEnv.learn,
        isPublic: isFeaturedCourse);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap(),
        isPublic: isFeaturedCourse);
  }

  void checkIsEnrolled() {
    enrolledParentCourse = enrolmentList.value.firstWhere(
      (element) => element.raw["content"]["identifier"] == course["identifier"],
      orElse: () => null,
    );
    if (enrolledParentCourse != null &&
        enrolledParentCourse.raw['lastReadContentId'] != null) {
      lastAccessContentId = enrolledParentCourse.raw['lastReadContentId'];
    }
  }

  void getContentAndProgress() async {
    await generateNavigation();
    if (enrolmentList.value != null) {
      if (batchId != null && !isFeaturedCourse && !isCuratedProgram) {
        readCourseContentProgress(courseId, batchId);
      }
      if (course['cumulativeTracking'] != null &&
          course['cumulativeTracking']) {
        if (courseHierarchyData['children'] != null) {
          for (int index = 0;
              index < courseHierarchyData['children'].length;
              index++) {
            if (enrolledCourse == null && enrolmentList.value != null) {
              for (var enrolledItem in enrolmentList.value) {
                if (enrolledItem.raw['courseId'] ==
                    courseHierarchyData['children'][index]['identifier']) {
                  await updatenavItemsProgress(enrolledItem);
                  break;
                }
              }
            } else if (enrolledCourse != null) {
              await updatenavItemsProgress(enrolledCourse);
              break;
            }
          }
        }
      }
      isProgressRead = true;
    }
  }

  Future<void> updatenavItemsProgress(Course enrolledcourse) async {
    if (enrolledcourse.completionPercentage < 100) {
      await readCourseContentProgress(enrolledcourse.raw['courseId'],
          enrolledcourse.raw['batch']['batchId']);
    } else if (enrolledcourse.completionPercentage == 100) {
      navigationItems.value.forEach((element) {
        if (element[0] == null &&
            element['parentCourseId'] == enrolledcourse.raw['courseId']) {
          element['completionPercentage'] = 1;
        } else if (element[0] != null) {
          element.forEach((item) {
            if (item[0] == null &&
                item['parentCourseId'] == enrolledcourse.raw['courseId']) {
              item['completionPercentage'] = 1;
            } else if (item[0] != null) {
              item.forEach((subItem) {
                if (subItem[0] == null &&
                    subItem['parentCourseId'] ==
                        enrolledcourse.raw['courseId']) {
                  subItem['completionPercentage'] = 1;
                } else if (subItem[0] != null) {
                  subItem.forEach((childItem) {
                    if (childItem[0] == null &&
                        childItem['parentCourseId'] ==
                            enrolledcourse.raw['courseId']) {
                      childItem['completionPercentage'] = 1;
                    }
                  });
                }
              });
            }
          });
        }
      });
    }
  }

  void clearCourseInfo(BuildContext context) {
    Provider.of<LearnRepository>(context, listen: false).clearContentRead();
    Provider.of<LearnRepository>(context, listen: false)
        .clearCourseHierarchyInfo();
    Provider.of<LearnRepository>(context, listen: false).clearReview();
    Provider.of<TocServices>(context, listen: false).clearCourseProgress();
  }

  Future<void> fetchData() async {
    await getEnrolmentInfo();
    getCourseInfo();
    getCourseHierarchyDetails();
    await navigateToPlayer();
    _generateTelemetryData();
  }

  // Content read api - To get all course details including batch info
  Future<void> getCourseInfo() async {
    await Provider.of<LearnRepository>(context, listen: false)
        .getCourseData(courseId);
  }

  // get enrolment info from local storage
  Future<void> getEnrolmentInfo() async {
    List enrolList = [];
    String responseData = await _storage.read(key: Storage.enrolmentList);
    String time = await _storage.read(key: Storage.enrolmentExpiryTime);
    DateTime expiryTime = time != null ? DateTime.parse(time) : null;
    if (responseData != null &&
        (expiryTime != null &&
            expiryTime.difference(DateTime.now()).inSeconds >= 0)) {
      enrolList = jsonDecode(responseData);
    } else {
      enrolList = await fetchEnrolInfo();
    }
    enrolmentList.value = enrolList
        .map(
          (dynamic item) => Course.fromJson(item),
        )
        .toList();
    setState(() {
      isProgressRead = false;
    });
  }

  // get enrolment info from api if storage doesn't have data or data expired
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
    return response['courses'];
  }

  Future<void> getReviews() async {
    await Provider.of<LearnRepository>(context, listen: false)
        .getCourseReviewSummery(courseId, course['primaryCategory']);
  }

  Future<void> getCourseHierarchyDetails() async {
    await Provider.of<LearnRepository>(context, listen: false)
        .getCourseDetails(courseId, isFeatured: isFeaturedCourse);
  }

  Future<void> getBatchDetails() async {
    batches = await Provider.of<LearnRepository>(context, listen: false)
        .getBatchList(courseId);
    if (course != null) {
      Provider.of<TocServices>(context, listen: false).setInitialBatch(
          batches: batches,
          courseId: course["identifier"],
          enrollmentList: enrolmentList.value);
    }
  }

  Future<dynamic> generateNavigation() async {
    int index;
    int k = 0;
    List tempNavItems = [];
    if (courseHierarchyData['children'] != null) {
      for (index = 0; index < courseHierarchyData['children'].length; index++) {
        String parentBatchId = '';
        if (course['cumulativeTracking'] != null &&
          course['cumulativeTracking']) {
          Course enrolledCourse = enrolmentList.value.firstWhere(
            (course) =>
                course.raw['courseId'] ==
                courseHierarchyData['children'][index]['identifier'],
            orElse: () => null,
          );
          parentBatchId = enrolledCourse != null
              ? enrolledCourse.raw['batch']['batchId']
              : batchId;
        }
        if ((courseHierarchyData['children'][index]['contentType'] ==
                'Collection' ||
            courseHierarchyData['children'][index]['contentType'] ==
                'CourseUnit')) {
          List temp = [];

          if (courseHierarchyData['children'][index]['children'] != null) {
            for (int i = 0;
                i < courseHierarchyData['children'][index]['children'].length;
                i++) {
              temp.add({
                'index': k++,
                'moduleName': courseHierarchyData['children'][index]['name'],
                'mimeType': courseHierarchyData['children'][index]['children']
                    [i]['mimeType'],
                'identifier': courseHierarchyData['children'][index]['children']
                    [i]['identifier'],
                'name': courseHierarchyData['children'][index]['children'][i]
                    ['name'],
                'parentCourseId': courseHierarchyData['children'][index]
                    ['identifier'],
                'artifactUrl': courseHierarchyData['children'][index]
                    ['children'][i]['artifactUrl'],
                'contentId': courseHierarchyData['children'][index]['children']
                    [i]['identifier'],
                'currentProgress': '0',
                'completionPercentage': '0',
                'status': 0,
                'moduleDuration':
                    courseHierarchyData['children'][index]['duration'] != null
                        ? Helper.getFullTimeFormat(
                            courseHierarchyData['children'][index]['duration'])
                        : '',
                'duration': (courseHierarchyData['children'][index]['children']
                                [i]['duration'] !=
                            null &&
                        courseHierarchyData['children'][index]['children'][i]
                                ['duration'] !=
                            '')
                    ? Helper.getFullTimeFormat(courseHierarchyData['children']
                            [index]['children'][i]['duration']
                        .toString())
                    : (courseHierarchyData['children'][index]['children'][i]
                                    ['expectedDuration'] !=
                                null &&
                            courseHierarchyData['children'][index]['children']
                                    [i]['expectedDuration'] !=
                                '')
                        ? Helper.getFullTimeFormat(courseHierarchyData['children'][index]['children'][i]['expectedDuration'].toString())
                        : '',
                'parentBatchId': parentBatchId,
                'primaryCategory': courseHierarchyData['children'][index]
                    ['children'][i]['primaryCategory'],
                'maxQuestions': (courseHierarchyData['children'][index]
                                ['children'][i]['maxQuestions'] !=
                            null &&
                        courseHierarchyData['children'][index]['children'][i]
                                ['maxQuestions'] !=
                            '')
                    ? courseHierarchyData['children'][index]['children'][i]
                        ['maxQuestions']
                    : '',
              });
            }
          } else {
            temp.add({
              'index': k++,
              'moduleName': courseHierarchyData['children'][index]['name'],
              'moduleDuration':
                  courseHierarchyData['children'][index]['duration'] != null
                      ? Helper.getFullTimeFormat(
                          courseHierarchyData['children'][index]['duration'])
                      : '',
              'identifier': courseHierarchyData['children'][index]
                  ['identifier'],
              'primaryCategory': courseHierarchyData['children'][index]
                  ['primaryCategory'],
            });
          }
          tempNavItems.add(temp);
        } else if (courseHierarchyData['children'][index]['contentType'] ==
            'Course') {
          List courseList = [];
          for (var i = 0;
              i < courseHierarchyData['children'][index]['children'].length;
              i++) {
            List temp = [];
            if (courseHierarchyData['children'][index]['children'][i]
                        ['contentType'] ==
                    'Collection' ||
                courseHierarchyData['children'][index]['children'][i]
                        ['contentType'] ==
                    'CourseUnit') {
              for (var j = 0;
                  j <
                      courseHierarchyData['children'][index]['children'][i]
                              ['children']
                          .length;
                  j++) {
                temp.add({
                  'index': k++,
                  'courseName': courseHierarchyData['children'][index]['name'],
                  'moduleName': courseHierarchyData['children'][index]
                      ['children'][i]['name'],
                  'mimeType': courseHierarchyData['children'][index]['children']
                      [i]['children'][j]['mimeType'],
                  'identifier': courseHierarchyData['children'][index]
                      ['children'][i]['children'][j]['identifier'],
                  'name': courseHierarchyData['children'][index]['children'][i]
                      ['children'][j]['name'],
                  'parentCourseId': courseHierarchyData['children'][index]
                      ['identifier'],
                  'artifactUrl': courseHierarchyData['children'][index]
                      ['children'][i]['children'][j]['artifactUrl'],
                  'contentId': courseHierarchyData['children'][index]
                      ['children'][i]['children'][j]['identifier'],
                  'currentProgress': '0',
                  'completionPercentage': '0',
                  'status': 0,
                  'moduleDuration': courseHierarchyData['children'][index]
                              ['children'][i]['duration'] !=
                          null
                      ? Helper.getFullTimeFormat(courseHierarchyData['children']
                          [index]['children'][i]['duration'])
                      : '',
                  'courseDuration': courseHierarchyData['children'][index]
                              ['duration'] !=
                          null
                      ? Helper.getFullTimeFormat(
                          courseHierarchyData['children'][index]['duration'])
                      : '',
                  'duration': (courseHierarchyData['children'][index]['children'][i]['children'][j]['duration'] != null &&
                          courseHierarchyData['children'][index]['children'][i]
                                  ['children'][j]['duration'] !=
                              '')
                      ? Helper.getFullTimeFormat(courseHierarchyData['children']
                              [index]['children'][i]['children'][j]['duration']
                          .toString())
                      : (courseHierarchyData['children'][index]['children'][i]['children'][j]['expectedDuration'] != null &&
                              courseHierarchyData['children'][index]['children']
                                      [i]['children'][j]['expectedDuration'] !=
                                  '')
                          ? Helper.getFullTimeFormat(courseHierarchyData['children'][index]['children'][i]['children'][j]['expectedDuration'].toString())
                          : '',
                  'parentBatchId': parentBatchId,
                  'primaryCategory': courseHierarchyData['children'][index]
                      ['children'][i]['children'][j]['primaryCategory'],
                  'maxQuestions': (courseHierarchyData['children'][index]
                                      ['children'][i]['children'][j]
                                  ['maxQuestions'] !=
                              null &&
                          courseHierarchyData['children'][index]['children'][i]
                                  ['children'][j]['maxQuestions'] !=
                              '')
                      ? courseHierarchyData['children'][index]['children'][i]
                          ['children'][j]['maxQuestions']
                      : '',
                });
              }
              courseList.add(temp);
            } else {
              courseList.add({
                'index': k++,
                'courseName': courseHierarchyData['children'][index]['name'],
                'parentCourseId': courseHierarchyData['children'][index]
                    ['identifier'],
                'mimeType': courseHierarchyData['children'][index]['children']
                    [i]['mimeType'],
                'identifier': courseHierarchyData['children'][index]['children']
                    [i]['identifier'],
                'name': courseHierarchyData['children'][index]['children'][i]
                    ['name'],
                'artifactUrl': courseHierarchyData['children'][index]
                    ['children'][i]['artifactUrl'],
                'contentId': courseHierarchyData['children'][index]['children']
                    [i]['identifier'],
                'currentProgress': '0',
                'completionPercentage': '0',
                'status': 0,
                'courseDuration':
                    courseHierarchyData['children'][index]['duration'] != null
                        ? Helper.getFullTimeFormat(
                            courseHierarchyData['children'][index]['duration'])
                        : '',
                'duration': (courseHierarchyData['children'][index]['children']
                                [i]['duration'] !=
                            null &&
                        courseHierarchyData['children'][index]['children'][i]
                                ['duration'] !=
                            '')
                    ? Helper.getFullTimeFormat(courseHierarchyData['children']
                            [index]['children'][i]['duration']
                        .toString())
                    : (courseHierarchyData['children'][index]['children'][i]
                                    ['expectedDuration'] !=
                                null &&
                            courseHierarchyData['children'][index]['children']
                                    [i]['expectedDuration'] !=
                                '')
                        ? Helper.getFullTimeFormat(courseHierarchyData['children'][index]['children'][i]['expectedDuration'].toString())
                        : '',
                'parentBatchId': parentBatchId,
                'primaryCategory': courseHierarchyData['children'][index]
                    ['children'][i]['primaryCategory'],
                'maxQuestions': (courseHierarchyData['children'][index]
                                ['children'][i]['maxQuestions'] !=
                            null &&
                        courseHierarchyData['children'][index]['children'][i]
                                ['maxQuestions'] !=
                            '')
                    ? courseHierarchyData['children'][index]['children'][i]
                        ['maxQuestions']
                    : '',
              });
            }
          }
          tempNavItems.add(courseList);
        } else {
          tempNavItems.add({
            'index': k++,
            'mimeType': courseHierarchyData['children'][index]['mimeType'],
            'identifier': courseHierarchyData['children'][index]['identifier'],
            'name': courseHierarchyData['children'][index]['name'],
            'parentCourseId': courseHierarchyData['children'][index]
                ['identifier'],
            'artifactUrl': courseHierarchyData['children'][index]
                ['artifactUrl'],
            'contentId': courseHierarchyData['children'][index]['identifier'],
            'currentProgress': '0',
            'completionPercentage': '0',
            'status': 0,
            'courseDuration':
                courseHierarchyData['children'][index]['duration'] != null
                    ? Helper.getFullTimeFormat(
                        courseHierarchyData['children'][index]['duration'])
                    : '',
            'duration': (courseHierarchyData['children'][index]['duration'] !=
                        null &&
                    courseHierarchyData['children'][index]['duration'] != '')
                ? Helper.getFullTimeFormat(courseHierarchyData['children']
                        [index]['duration']
                    .toString())
                : (courseHierarchyData['children'][index]['expectedDuration'] !=
                            null &&
                        courseHierarchyData['children'][index]
                                ['expectedDuration'] !=
                            '')
                    ? Helper.getFullTimeFormat(courseHierarchyData['children']
                            [index]['expectedDuration']
                        .toString())
                    : '',
            'parentBatchId': parentBatchId,
            'primaryCategory': courseHierarchyData['children'][index]
                ['primaryCategory'],
            'maxQuestions': (courseHierarchyData['children'][index]
                            ['maxQuestions'] !=
                        null &&
                    courseHierarchyData['children'][index]['maxQuestions'] !=
                        '')
                ? courseHierarchyData['children'][index]['maxQuestions']
                : '',
          });
        }
      }
    }

    if (tempNavItems.length != 0 && isCuratedProgram) {
      showCertificate.clear();
      for (int i = 0; i < tempNavItems.length; i++) {
        if (tempNavItems[i][0] != null && tempNavItems[i][0][0] != null) {
          showCertificate.add({tempNavItems[i][0][0]: false});
        }
      }
    }
    navigationItems.value = tempNavItems;
  }

  Future<dynamic> readCourseContentProgress(courseId, batchId) async {
    var response = await LearnService().readContentProgress(courseId, batchId);
    List _sortContentProgress = _extractSortContentProgress(response);
    if (_sortContentProgress.isNotEmpty && lastAccessContentId == null) {
      lastAccessContentId = _sortContentProgress.first['contentId'];
    }

    _updateNavigationItems(response, _sortContentProgress);
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
    // _allContentProgress = response;
    return _sortContentProgress;
  }

  void _updateNavigationItems(response, _sortContentProgress) {
    for (int i = 0; i < navigationItems.value.length; i++) {
      var currentItem = navigationItems.value[i];
      if (currentItem[0] == null) {
        _updateNavigationItemsWithoutNested(
            currentItem, response, _sortContentProgress, i);
      } else if (hasModuleInChildren(currentItem)) {
        for (var m = 0; m < currentItem.length; m++) {
          if (currentItem[m][0] != null) {
            for (int k = 0; k < currentItem[m].length; k++) {
              _updateNavigationItemsWithNested(
                  currentItem, response, _sortContentProgress, i);
            }
          } else {
            _updateNavigationItemsNestedIsNull(
                currentItem, response, _sortContentProgress, m);
          }
        }
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

        currentItem['completionPercentage'] = progress;

        if (contentListItem['progressdetails'] != null &&
            contentListItem['progressdetails']['current'] != null) {
          currentItem['currentProgress'] =
              (contentListItem['progressdetails']['current'].length > 0)
                  ? contentListItem['progressdetails']['current'].last
                  : 0;
        }

        currentItem['status'] = contentListItem['status'];
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

            currentItem[m][k]['completionPercentage'] = progress;

            if (contentListItem['progressdetails'] != null &&
                contentListItem['progressdetails']['current'] != null) {
              currentItem[m][k]['currentProgress'] =
                  (contentListItem['progressdetails']['current'].length > 0)
                      ? contentListItem['progressdetails']['current'].last
                      : 0;
            }

            currentItem[m][k]['status'] = contentListItem['status'];
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
            nestedItem[0] == null &&
            nestedItem['contentId'] == contentListItem['contentId']) {
          double progress = (contentListItem['completionPercentage'] != null)
              ? contentListItem['completionPercentage'] / 100
              : 0;

          nestedItem['completionPercentage'] = progress;

          if (contentListItem['progressdetails'] != null &&
              contentListItem['progressdetails']['current'] != null) {
            nestedItem['currentProgress'] =
                (contentListItem['progressdetails']['current'].length > 0)
                    ? contentListItem['progressdetails']['current'].last
                    : 0;
          }

          nestedItem['status'] = contentListItem['status'];
        } else if (currentItem[k][0] == null) {
          // Logic for further nesting if required
        }
      }
    }
  }

  bool hasModuleInChildren(navigationItem) {
    for (var item in navigationItem) {
      if (item is List) {
        return true;
      }
    }
    return false;
  }

  Future<void> getYourRatingAndReview(course) async {
    await Provider.of<LearnRepository>(context, listen: false)
        .getYourReview(course['identifier'], course['primaryCategory']);
  }

  bool _showCourseShareOption() {
    return (course['courseCategory'] != PrimaryCategory.inviteOnlyProgram &&
        course['courseCategory'] != PrimaryCategory.moderatedCourses &&
        course['courseCategory'] != PrimaryCategory.moderatedProgram &&
        course['courseCategory'] != PrimaryCategory.moderatedAssessment);
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
                course['identifier'],
                course['name'],
                course['posterImage'],
                course['source'],
                course['primaryCategory'],
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

  Future<void> navigateToPlayer() async {
    var enrolledCourseInfo = await TocHelper().checkIsCoursesInProgress(
        enrolmentList: enrolmentList.value,
        courseId: courseId,
        context: context);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        if (enrolledCourseInfo != null &&
            enrolledCourseInfo.raw['lastReadContentId'] != null) {
          var result = await Navigator.pushNamed(
            context,
            AppUrl.tocPlayer,
            arguments: TocPlayerModel(
                enrolmentList: enrolmentList.value,
                batchId: enrolledCourseInfo.raw['batchId'],
                lastAccessContentId:
                    enrolledCourseInfo.raw['lastReadContentId'],
                courseId: enrolledCourseInfo.raw['courseId']),
          );
          setState(() {
            showToc = true;
          });
          if (result != null && result is Map<String, bool>) {
            Map<String, dynamic> response = result;
            if (response['isFinished']) {
              showModalBottomSheet(
                  isScrollControlled: true,
                  context: context,
                  backgroundColor: AppColors.greys60,
                  builder: (ctx) => RateNowPopUp(
                        courseDetails: Course.fromJson(course),
                      )).whenComplete(
                  () => InAppReviewRespository().triggerInAppReviewPopup());
            }
          }
        } else {
          setState(() {
            showToc = true;
          });
        }
        if (enrolledParentCourse != null) {
          readCourseContentProgress(courseId, batchId);
        }
      }
    });
  }
}
