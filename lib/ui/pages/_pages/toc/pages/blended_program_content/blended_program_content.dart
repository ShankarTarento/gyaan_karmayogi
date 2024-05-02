import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/models/_models/batch_model.dart';
import 'package:karmayogi_mobile/models/_models/course_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/blended_program_content/widgets/led_by_instructor.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/toc_content_page.dart';

class BlendedProgramContent extends StatefulWidget {
  final Map<String, dynamic> courseDetails;
  final Batch batch;
  final dynamic course;
  final String courseId;
  final dynamic courseHierarchyData;
  final dynamic contentProgressResponse;
  final List<Course> enrollmentList;
  final String lastAccessContentId;
  final List navigationItems;
  final Course enrolledCourse;

  const BlendedProgramContent(
      {Key key,
      @required this.courseDetails,
      @required this.batch,
      @required this.enrollmentList,
      @required this.contentProgressResponse,
      @required this.course,
      @required this.courseHierarchyData,
      @required this.courseId,
      @required this.lastAccessContentId,
      @required this.navigationItems,
      this.enrolledCourse})
      : super(key: key);

  @override
  State<BlendedProgramContent> createState() => _BlendedProgramContentState();
}

class _BlendedProgramContentState extends State<BlendedProgramContent> {
  List<String> contentType = [];
  int selectedContentIndex = 0;

  @override
  void didChangeDependencies() {
    contentType = [
      AppLocalizations.of(context).mBlendedSelfPaced,
      AppLocalizations.of(context).mBlendedInstructorLed
    ];
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  void initState() {
    super.initState();
    removeOfflineContentFromNavigation();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(
        children: List.generate(
          contentType.length,
          (index) => GestureDetector(
            onTap: () {
              if (index == 1 &&
                  widget.batch != null &&
                  widget.batch.batchAttributes.sessionDetailsV2.isNotEmpty) {
                selectedContentIndex = index;
                setState(() {});
              }
            },
            child: Container(
              margin: EdgeInsets.only(left: 16, top: 24),
              padding: EdgeInsets.only(top: 6, bottom: 6, left: 16, right: 16),
              decoration: BoxDecoration(
                border: Border.all(
                    color: selectedContentIndex == index
                        ? AppColors.darkBlue
                        : AppColors.grey08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Flexible(
                child: Text(
                  contentType[index],
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: selectedContentIndex == index
                        ? AppColors.darkBlue
                        : AppColors.greys60,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ),
      ),
      Expanded(
          child: selectedContentIndex == 0
              ? TocContentPage(
                  courseId: widget.courseId,
                  course: widget.course,
                  enrolmentList: widget.enrollmentList,
                  courseHierarchy: widget.courseHierarchyData,
                  navigationItems: widget.navigationItems,
                  contentProgressResponse: widget.contentProgressResponse,
                  lastAccessContentId: widget.lastAccessContentId,
                  enrolledCourse: widget.enrolledCourse,
                )
              : LedByInstructor(
                  enrollmentList: widget.enrollmentList,
                  batch: widget.batch,
                  courseDetails: widget.courseDetails,
                ))
    ]);
  }

  void removeOfflineContentFromNavigation() {
    widget.navigationItems.removeWhere((child) {
      if (child is! List &&
          child['primaryCategory'] == PrimaryCategory.offlineSession) {
        return true; // remove this child
      } else if (child is List) {
        child.removeWhere((childElement) {
          if (childElement is! List &&
              childElement['primaryCategory'] ==
                  PrimaryCategory.offlineSession) {
            return true; // remove this childElement
          } else if (childElement is List) {
            childElement.removeWhere((childItem) {
              return childItem is! List &&
                  childItem['primaryCategory'] ==
                      PrimaryCategory.offlineSession;
            });
          }
          return false;
        });
      }
      return false;
    });
    widget.navigationItems.removeWhere((element) => element.isEmpty);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {});
    });
  }
}
