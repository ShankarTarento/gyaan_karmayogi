import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/util/toc_helper.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../constants/index.dart';
import '../../../../../models/_arguments/index.dart';
import '../../../../../models/index.dart';
import '../../../../../respositories/_respositories/learn_repository.dart';
import '../../../../../services/index.dart';
import '../../../../../util/helper.dart';
import '../../../../skeleton/index.dart';
import '../../../../widgets/index.dart';
import '../../../index.dart';
import '../../learn/course_sharing/course_sharing_page.dart';
import '../pages/about_tab/about_tab.dart';
import '../pages/services/toc_services.dart';
import '../widgets/overall_progress.dart';

class TocPlayerScreen extends StatefulWidget {
  final TocPlayerModel arguments;

  TocPlayerScreen({Key key, @required this.arguments}) : super(key: key);
  @override
  State<TocPlayerScreen> createState() => _TocPlayerScreenState();
}

class _TocPlayerScreenState extends State<TocPlayerScreen>
    with SingleTickerProviderStateMixin {
  var course;
  Map<String, dynamic> courseHierarchyData;
  String courseId, batchId, lastAccessContentId;
  TabController learnTabController;
  List<Course> enrolmentList;
  List navigationItems = [];
  List resourceNavigateItems = [];
  var contentProgressResponse;
  bool fullScreen = false,
      isCuratedProgram = false,
      isFeatured = false,
      isFetchDataCalled = false;
  int courseIndex = 0;
  var formId = 1694586265488;
  double courseOverallProgress = 0;
  Course enrolledCourse;

  @override
  void initState() {
    super.initState();
    enrolmentList = widget.arguments.enrolmentList;
    contentProgressResponse = widget.arguments.contentProgressResponse;
    isCuratedProgram = widget.arguments.isCuratedProgram;
    batchId = widget.arguments.batchId;
    lastAccessContentId = widget.arguments.lastAccessContentId;
    isFeatured = widget.arguments.isFeatured != null
        ? widget.arguments.isFeatured
        : false;
    courseId = widget.arguments.courseId;
    getEnrolledCourse();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Provider.of<TocServices>(context, listen: false).clearCourseProgress();
    });
  }

  @override
  void dispose() {
    navigationItems.clear();
    super.dispose();
  }
  @override
  void didChangeDependencies() {
        learnTabController = TabController(
        length: LearnTab.tocTabs(context).length, vsync: this, initialIndex: 1);
    super.didChangeDependencies();
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        navigationItems.clear();
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
          body: DefaultTabController(
            length: LearnTab.tocTabs(context).length,
            child: Consumer<LearnRepository>(
                builder: (context, learnRepository, _) {
              if (course == null || learnRepository.contentRead != null) {
                course = learnRepository.contentRead;
              }
              if (courseHierarchyData == null ||
                  learnRepository.courseHierarchyInfo != null) {
                courseHierarchyData = learnRepository.courseHierarchyInfo;
              }
              if (course != null &&
                  courseHierarchyData != null &&
                  courseId == course['identifier'] &&
                  courseId == courseHierarchyData['identifier']) {
                if (navigationItems == null || navigationItems.isEmpty) {
                  if (course['courseCategory'] != null &&
                      course['courseCategory'] ==
                          PrimaryCategory.curatedProgram) {
                    isCuratedProgram = true;
                  } else {
                    isCuratedProgram = false;
                  }
                  getContentAndProgress();
                }
                if (resourceNavigateItems.isEmpty) {
                  return TocPlayerSkeleton(
                      showCourseShareOption: false,
                      courseShareOptionCallback: _shareModalBottomSheetMenu);
                }

                if (course.runtimeType == String) {
                  return NoDataWidget(message: 'No course');
                } else {
                  return NotificationListener<OverscrollIndicatorNotification>(
                    onNotification: (overscroll) {
                      overscroll.disallowIndicator();
                      return true;
                    },
                    child: SafeArea(
                      child: NestedScrollView(
                          headerSliverBuilder:
                              (BuildContext context, innerBoxIsScrolled) {
                            return <Widget>[
                              TocAppbarWidget(
                                  isOverview: false,
                                  showCourseShareOption:
                                      _showCourseShareOption(),
                                  courseShareOptionCallback:
                                      _shareModalBottomSheetMenu,
                                  isPlayer: true,
                                  courseId: courseId),
                            ];
                          },
                          body: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TocContentPlayer(
                                courseHierarchyData: courseHierarchyData,
                                batchId: batchId,
                                changeLayout: manageScreen,
                                fullScreen: fullScreen,
                                isCuratedProgram: course['cumulativeTracking'] != null && course['cumulativeTracking'],
                                isFeatured: isFeatured,
                                resourceNavigateItems:
                                    resourceNavigateItems[courseIndex],
                                showLatestProgress: _showLatestProgress,
                                updateContentProgress: updateContentProgress,
                                primaryCategory:
                                    resourceNavigateItems[courseIndex]
                                                ['primaryCategory'] !=
                                            null
                                        ? resourceNavigateItems[courseIndex]
                                            ['primaryCategory']
                                        : course['contentType'],
                                navigationItems: resourceNavigateItems,
                                playNextResource: (value) {
                                  if (courseIndex <
                                      resourceNavigateItems.length - 1) {
                                    setState(() {
                                      courseIndex++;
                                      lastAccessContentId =
                                          resourceNavigateItems[courseIndex]
                                              ['contentId'];
                                    });
                                  } else {
                                    var resourceNotCompleted =
                                        resourceNavigateItems.firstWhere(
                                            (item) => item['status'] != 2,
                                            orElse: () => null);
                                    if (resourceNotCompleted == null) {
                                      Navigator.of(context)
                                          .pop({'isFinished': true});
                                    } else {
                                      Navigator.pop(context);
                                    }
                                  }
                                },
                              ),
                              !fullScreen
                                  ? Column(
                                      children: [
                                        OverallProgress(
                                            course: course,
                                            enrollmentDetails: enrolmentList),
                                        Container(
                                          color: AppColors.greys87,
                                          width:
                                              MediaQuery.of(context).size.width,
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
                                                labelPadding:
                                                    EdgeInsets.only(top: 0.0),
                                                unselectedLabelColor:
                                                    AppColors.greys60,
                                                labelColor: AppColors.darkBlue,
                                                labelStyle: GoogleFonts.lato(
                                                  fontSize: 10.0,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                unselectedLabelStyle:
                                                    GoogleFonts.lato(
                                                  fontSize: 10.0,
                                                  fontWeight: FontWeight.normal,
                                                ),
                                                tabs: [
                                                  for (var tabItem
                                                      in LearnTab.tocTabs(
                                                          context))
                                                    Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 16),
                                                      child: Tab(
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  5.0),
                                                          child: Text(
                                                            tabItem.title,
                                                            style: GoogleFonts
                                                                .lato(
                                                              color: AppColors
                                                                  .greys87,
                                                              fontSize: 14.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
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
                                        SizedBox(
                                          height: 8,
                                        )
                                      ],
                                    )
                                  : Center(),
                              !fullScreen
                                  ? Expanded(
                                      child: TabBarView(
                                          controller: learnTabController,
                                          children: [
                                            AboutTab(
                                              courseRead: course,
                                              enrollmentDetails: enrolmentList,
                                              courseHierarchy:
                                                  courseHierarchyData,
                                              isBlendedProgram: false,
                                            ),
                                            TocContentPage(
                                              courseId: courseId,
                                              course: course,
                                              enrolmentList: enrolmentList,
                                              courseHierarchy:
                                                  courseHierarchyData,
                                              navigationItems:
                                                  navigationItems != null
                                                      ? navigationItems
                                                      : [],
                                              contentProgressResponse:
                                                  contentProgressResponse,
                                              lastAccessContentId:
                                                  lastAccessContentId,
                                              startNewResourse:
                                                  startNewResourse,
                                              isPlayer: true,
                                              readCourseProgress: () =>
                                                  readCourseContentProgress(
                                                      courseId, batchId),
                                              enrolledCourse: enrolledCourse,
                                            )
                                          ]),
                                    )
                                  : Center(),
                            ],
                          )),
                    ),
                  );
                }
              } else {
                if (!isFetchDataCalled) {
                  clearCourseInfo(context);
                  Provider.of<TocServices>(context, listen: false)
                      .clearCourseProgress();
                  fetchCourseData();
                  isFetchDataCalled = true;
                }
                return TocPlayerSkeleton(
                    showCourseShareOption: false,
                    courseShareOptionCallback: _shareModalBottomSheetMenu);
              }
            }),
          ),
          bottomNavigationBar: BottomAppBar(
              child: TocPlayerButton(
            courseIndex: courseIndex,
            resourceNavigateItems: resourceNavigateItems,
            clickedPrevious: () {
              setState(() {
                courseIndex--;
                lastAccessContentId =
                    resourceNavigateItems[courseIndex]['contentId'];
              });
            },
            clickedNext: () {
              setState(() {
                courseIndex++;
                lastAccessContentId =
                    resourceNavigateItems[courseIndex]['contentId'];
              });
            },
            clickedFinish: () {
              var resourceNotCompleted = resourceNavigateItems.firstWhere(
                  (item) => item['status'] != 2,
                  orElse: () => null);
              if (resourceNotCompleted == null) {
                Navigator.of(context).pop({'isFinished': true});
              } else {
                Navigator.pop(context);
              }
            },
          ))),
    );
  }

  Future<void> getContentAndProgress() async {
    await generateNavigation();
    if (batchId != null && !isFeatured && !isCuratedProgram) {
      await readCourseContentProgress(courseId, batchId);
    }
    if (course['cumulativeTracking'] != null &&
          course['cumulativeTracking']) {
        if (courseHierarchyData['children'] != null) {
          for (int index = 0;
              index < courseHierarchyData['children'].length;
              index++) {
            if (enrolledCourse == null && enrolmentList != null) {
              for (var enrolledItem in enrolmentList) {
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

    getResourceNavigationItems(navigationItems);
    setState(() {});
  }

  void manageScreen(bool fullScreen) {
    setState(() {
      fullScreen = fullScreen;
    });
  }

  Future<void> updateContentProgress(Map data) async {
    if (!isFeatured) {
      for (int i = 0; i < resourceNavigateItems.length; i++) {
        if (resourceNavigateItems[i]['identifier'] == data['identifier']) {
          resourceNavigateItems[i]['completionPercentage'] =
              (data['completionPercentage']).toString();
          resourceNavigateItems[i]['currentProgress'] =
              data['mimeType'] == EMimeTypes.assessment
                  ? (data['completionPercentage']).toString()
                  : data['current'];
          if ((data['mimeType'] == EMimeTypes.youtubeLink &&
                  data['completionPercentage'].toString() == '1') ||
              double.parse(data['completionPercentage'].toString()) == 1) {
            resourceNavigateItems[i]['status'] = 2;
          }
          double totalProgress = 0;
          totalProgress = getCourseOverallProgress(totalProgress);
          if ((totalProgress / resourceNavigateItems.length) >
                  courseOverallProgress &&
              (totalProgress / resourceNavigateItems.length) -
                      courseOverallProgress >=
                  0.1) {
            courseOverallProgress =
                totalProgress / resourceNavigateItems.length;
            Provider.of<TocServices>(context, listen: false)
                .setCourseProgress(courseOverallProgress);
          }

          await updateNavigationItems(data);
        }
      }
    }
  }

  _showLatestProgress(data) async {
    if (mounted) {
      await updateContentProgress(data);      
      }
  }

  Future<void> getResourceNavigationItems(navItems) async {
    navItems.forEach((child) {
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
    if (lastAccessContentId == null) {
      lastAccessContentId = resourceNavigateItems.first['identifier'];
    }

    if (resourceNavigateItems.isNotEmpty && lastAccessContentId != null) {
      getCurrentResourceIndex();
    }
    double totalProgress = 0;
    totalProgress = getCourseOverallProgress(totalProgress);

    courseOverallProgress = totalProgress / resourceNavigateItems.length;
  }

  double getCourseOverallProgress(double totalProgress) {
    resourceNavigateItems.forEach((element) {
      if (element['status'] == 2) {
        totalProgress += 1;
      } else {
        totalProgress +=
            double.parse(element['completionPercentage'].toString());
      }
    });
    return totalProgress;
  }

  void getCurrentResourceIndex() {
    courseIndex = resourceNavigateItems
        .indexWhere((element) => element['contentId'] == lastAccessContentId);
    if (courseIndex < 0) {
      courseIndex = 0;
    }
  }

  void startNewResourse(String value) {
    if (lastAccessContentId != value) {
      setState(() {
        lastAccessContentId = value;
        getCurrentResourceIndex();
      });
    }
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

  updateNavigationItems(data) {
    navigationItems.forEach((child) {
      if (child.runtimeType != List) {
        if (child['contentId'] == data['identifier']) {
          child['currentProgress'] = data['current'];
          child['completionPercentage'] = data['completionPercentage'];
        }
      } else {
        child.forEach((childElement) {
          if (childElement.runtimeType != List) {
            if (childElement['contentId'] == data['identifier']) {
              childElement['currentProgress'] = data['current'];
              childElement['completionPercentage'] =
                  data['completionPercentage'];
            }
          } else {
            childElement.forEach((childItem) {
              if (childItem.runtimeType != List) {
                if (childItem['contentId'] == data['identifier']) {
                  childItem['currentProgress'] = data['current'];
                  childItem['completionPercentage'] =
                      data['completionPercentage'];
                }
              }
            });
          }
        });
      }
    });
    if (mounted) {
      setState(() {});
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
          Course enrolledCourse = enrolmentList.firstWhere(
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
    // await getResourceNavigationItems(tempNavItems);
    navigationItems = tempNavItems;
  }

  Future<void> fetchCourseData() async {
    await getCourseInfo();
    await getCourseHierarchyDetails();
  }

  // Content read api - To get all course details including batch info
  Future<void> getCourseInfo() async {
    await Provider.of<LearnRepository>(context, listen: false)
        .getCourseData(courseId);
  }

  Future<void> getCourseHierarchyDetails() async {
    await Provider.of<LearnRepository>(context, listen: false)
        .getCourseDetails(courseId, isFeatured: isFeatured);
  }

  Future<void> updatenavItemsProgress(Course enrolledcourse) async {
    if (enrolledcourse.completionPercentage < 100) {
      await readCourseContentProgress(enrolledcourse.raw['courseId'],
          enrolledcourse.raw['batch']['batchId']);
    } else if (enrolledcourse.completionPercentage == 100 &&
        navigationItems != null) {
      navigationItems.forEach((element) {
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
    for (int i = 0; i < navigationItems.length; i++) {
      var currentItem = navigationItems[i];
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

  void getEnrolledCourse() {
    enrolledCourse = TocHelper()
        .checkCourseEnrolled(enrolmentList: enrolmentList, id: courseId);
  }

  void clearCourseInfo(BuildContext context) {
    Provider.of<LearnRepository>(context, listen: false).clearContentRead();
    Provider.of<LearnRepository>(context, listen: false)
        .clearCourseHierarchyInfo();
    Provider.of<LearnRepository>(context, listen: false).clearReview();
    Provider.of<TocServices>(context, listen: false).clearCourseProgress();
  }
}
