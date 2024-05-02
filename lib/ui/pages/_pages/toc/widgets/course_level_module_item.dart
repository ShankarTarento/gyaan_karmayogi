import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../constants/index.dart';
import '../../../../../models/index.dart';
import '../../../../../util/helper.dart';
import '../../../../widgets/index.dart';
import '../../../index.dart';

class CourseLevelModuleItem extends StatefulWidget {
  final index, content, course, courseHierarchyInfo, contentProgressResponse;
  final bool isCuratedProgram,
      isProgram,
      isFeatured,
      showCertificateIcon,
      showProgress,
      isPlayer;
  final String batchId, lastAccessContentId;
  final List<Map> showCertificate;
  final ValueChanged<String> startNewResourse;
  final List<Course> enrolmentList;
  final VoidCallback readCourseProgress;
  final Course enrolledCourse;

  const CourseLevelModuleItem(
      {Key key,
      @required this.index,
      @required this.content,
      @required this.course,
      @required this.courseHierarchyInfo,
      @required this.batchId,
      @required this.showCertificate,
      @required this.contentProgressResponse,
      @required this.lastAccessContentId,
      @required this.enrolmentList,
      this.showCertificateIcon = false,
      this.isCuratedProgram = false,
      this.showProgress = false,
      this.isProgram = false,
      this.isFeatured = false,
      this.isPlayer = false,
      this.startNewResourse,
      this.readCourseProgress,
      this.enrolledCourse})
      : super(key: key);

  @override
  State<CourseLevelModuleItem> createState() => _CourseLevelModuleItemState();
}

class _CourseLevelModuleItemState extends State<CourseLevelModuleItem> {
  int index = 0;
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    index = widget.index;
    if (widget.isPlayer && widget.showProgress) {
      isLastAccessedContentExist();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      for (int j = 0; j < widget.content[index].length; j++)
        widget.content[index][j][0] != null
            ? Container(
                margin: EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                    border: Border.all(
                        color: isExpanded
                            ? AppColors.darkBlue
                            : AppColors.appBarBackground),
                    color: isExpanded
                        ? AppColors.darkBlue
                        : AppColors.appBarBackground),
                child: InkWell(
                  onTap: () {},
                  child: ExpansionTile(
                    onExpansionChanged: (value) {
                      setState(() {
                        isExpanded = !isExpanded;
                      });
                    },
                    initiallyExpanded: isExpanded,
                    tilePadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    childrenPadding: EdgeInsets.zero,
                    title: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: Container(
                          padding: const EdgeInsets.only(left: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${index + 1}  ${widget.content[index][j][0]['courseName']}',
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.montserrat(
                                    height: 1.5,
                                    decoration: TextDecoration.none,
                                    color: isExpanded
                                        ? AppColors.appBarBackground
                                        : AppColors.greys87,
                                    fontSize: 16,
                                    fontWeight: isExpanded
                                        ? FontWeight.w700
                                        : FontWeight.w500),
                              ),
                              SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CourseAtGlanceWidget(
                                    courseInfo: widget.content[index][j][0],
                                    courseHierarchyInfo:
                                        widget.courseHierarchyInfo,
                                    isExpanded: isExpanded,
                                    isCourse: true,
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              widget.showProgress &&
                                      widget.content[index][j][0]
                                              ['completionPercentage'] !=
                                          '0' &&
                                      widget.content[index][j][0]
                                              ['completionPercentage'] !=
                                          0
                                  ? (widget.enrolledCourse != null &&
                                              widget.enrolledCourse
                                                      .completionPercentage ==
                                                  100) ||
                                          getCompletionStatus(
                                                  widget.content[index][j]) ==
                                              1
                                      ? TocDownloadCertificateWidget(
                                          courseId: widget.content[index][j][0]
                                              ['parentCourseId'],
                                          isPlayer: widget.isPlayer,
                                          isExpanded: isExpanded &&
                                              widget.enrolledCourse != null)
                                      : LinearProgressIndicatorWidget(
                                          value: getCompletionStatus(widget.content[index][j]),
                                          isExpnaded: isExpanded,
                                          isCourse: true)
                                  : Center()
                            ],
                          ),
                        )),
                      ],
                    ),
                    trailing: isExpanded
                        ? Icon(
                            Icons.arrow_drop_up,
                            color: AppColors.appBarBackground,
                          )
                        : Icon(
                            Icons.arrow_drop_down,
                            color: AppColors.darkBlue,
                          ),
                    children: [
                      for (var k = 0;
                          k < widget.content[index].length;
                          k++, j++)
                        Container(
                          child: (widget.content[index][k][0] != null
                              ? ModuleItem(
                                  course: widget.course,
                                  moduleIndex: k,
                                  moduleName: widget.content[index][k][0]
                                      ['moduleName'],
                                  glanceListItems: widget.content[index][k],
                                  contentProgressResponse:
                                      widget.contentProgressResponse,
                                  navigation: widget.content[index],
                                  batchId: widget.batchId,
                                  isFeatured: widget.isFeatured,
                                  duration: getModuleDuration(
                                      widget.content[index][k]),
                                  parentCourseId: widget.content[index][k][0]
                                      ['parentCourseId'],
                                  showProgress: widget.showProgress,
                                  courseHierarchyInfo:
                                      widget.courseHierarchyInfo,
                                  itemCount: widget.content[index][k].length,
                                  lastAccessContentId:
                                      widget.lastAccessContentId,
                                  startNewResourse: widget.startNewResourse,
                                  isPlayer: widget.isPlayer,
                                  navigationItems: widget.content,
                                  enrolmentList: widget.enrolmentList,
                                  readCourseProgress: () =>
                                      widget.readCourseProgress(),
                                  enrolledCourse: widget.enrolledCourse)
                              : (widget.content[index][k] != null)
                                  ? Column(
                                      children: [
                                        TocContentObjectWidget(
                                          content: widget.content[index][k],
                                          course: widget.courseHierarchyInfo,
                                          showProgress: widget.showProgress,
                                          lastAccessContentId:
                                              widget.lastAccessContentId,
                                          startNewResourse:
                                              widget.startNewResourse,
                                          isPlayer: widget.isPlayer,
                                          enrolmentList: widget.enrolmentList,
                                          navigationItems: widget.content,
                                          courseId: widget.course['identifier'],
                                          batchId: widget.batchId,
                                          isCuratedProgram:
                                              widget.isCuratedProgram,
                                          enrolledCourse: widget.enrolledCourse,
                                        ),
                                      ],
                                    )
                                  : Center()),
                        )
                    ],
                  ),
                ),
              )
            : Center()
    ]);
  }

  String getModuleDuration(content) {
    int totalDurationInMilliSeconds = 0;
    content.forEach((item) {
      totalDurationInMilliSeconds +=
          Helper.getMilliSecondsFromTimeFormat(item['duration']);
    });
    return Helper.getFullTimeFormat(totalDurationInMilliSeconds.toString());
  }

  void isLastAccessedContentExist() {
    for (var content in widget.content) {
      for (var childContent in content) {
        if (childContent[0] != null) {
          for (var subContent in childContent) {
            if (subContent['contentId'] == widget.lastAccessContentId) {
              setState(() {
                isExpanded = true;
              });
              break;
            }
          }
        } else if (childContent['contentId'] == widget.lastAccessContentId) {
          setState(() {
            isExpanded = true;
          });
          break;
        }
      }
    }
  }

  double getCompletionStatus(content) {
    if (content is List) {
      double totalprogress = 0;
      content.forEach((element) {
        totalprogress +=
            double.parse(element['completionPercentage'].toString());
      });
      return totalprogress / content.length;
    } else {
      return double.parse(content['completionPercentage'].toString());
    }
  }
}
