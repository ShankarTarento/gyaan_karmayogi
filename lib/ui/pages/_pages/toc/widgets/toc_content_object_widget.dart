import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/util/toc_helper.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/widgets/rate_now_pop_up.dart';

import '../../../../../constants/index.dart';
import '../../../../../models/_arguments/index.dart';
import '../../../../../models/index.dart';
import '../../../../../respositories/_respositories/in_app_review_repository.dart';
import '../../../../widgets/index.dart';

class TocContentObjectWidget extends StatelessWidget {
  const TocContentObjectWidget(
      {Key key,
      @required this.content,
      @required this.course,
      @required this.showProgress,
      @required this.lastAccessContentId,
      @required this.navigationItems,
      @required this.enrolmentList,
      @required this.courseId,
      @required this.batchId,
      this.isFeatured = false,
      this.startNewResourse,
      this.isPlayer = false,
      this.isCuratedProgram = false,
      this.readCourseProgress,
      this.enrolledCourse})
      : super(key: key);

  final content;
  final course;
  final bool isFeatured, showProgress, isPlayer, isCuratedProgram;
  final String lastAccessContentId;
  final ValueChanged<String> startNewResourse;
  final List navigationItems;
  final List<Course> enrolmentList;
  final String courseId, batchId;
  final VoidCallback readCourseProgress;
  final Course enrolledCourse;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: InkWell(
        onTap: () async {
          // _generateInteractTelemetryData(
          //     content['identifier'], content['mimeType']);
          if (isPlayer) {
            startNewResourse(content['contentId']);
          } else if (showProgress) {
            var result;
            if ((course['courseCategory'] == PrimaryCategory.moderatedProgram ||
                    course['courseCategory'] ==
                        PrimaryCategory.blendedProgram) &&
                TocHelper().isProgramLive(enrolledCourse)) {
              result = await Navigator.pushNamed(
                context,
                AppUrl.tocPlayer,
                arguments: TocPlayerModel(
                    enrolmentList: enrolmentList,
                    navigationItems: navigationItems,
                    isCuratedProgram: isCuratedProgram,
                    batchId: batchId,
                    lastAccessContentId: content['contentId'],
                    courseId: courseId),
              );
            } else if (course['courseCategory'] !=
                    PrimaryCategory.moderatedProgram &&
                course['courseCategory'] != PrimaryCategory.blendedProgram) {
              result = await Navigator.pushNamed(
                context,
                AppUrl.tocPlayer,
                arguments: TocPlayerModel(
                    enrolmentList: enrolmentList,
                    navigationItems: navigationItems,
                    isCuratedProgram: isCuratedProgram,
                    batchId: batchId,
                    lastAccessContentId: content['contentId'],
                    courseId: courseId),
              );
            }
            if (result != null && result is Map<String, bool>) {
              Map<String, dynamic> response = result;
              if (response['isFinished']) {
                showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    backgroundColor: AppColors.greys60,
                    builder: (ctx) => RateNowPopUp(
                        courseDetails: Course.fromJson(course))).whenComplete(
                    () => InAppReviewRespository().triggerInAppReviewPopup());
              }
            }
            readCourseProgress();
          }
        },
        child: content['mimeType'] != null
            ? content['mimeType'] == EMimeTypes.offline
                ? Center()
                : Column(
                    children: [
                      GlanceItem3(
                        icon: (content['mimeType'] == EMimeTypes.mp4 ||
                                content['mimeType'] == EMimeTypes.m3u8)
                            ? 'assets/img/icons-av-play.svg'
                            : content['mimeType'] == EMimeTypes.mp3
                                ? 'assets/img/audio.svg'
                                : (content['mimeType'] ==
                                            EMimeTypes.externalLink ||
                                        content['mimeType'] ==
                                            EMimeTypes.youtubeLink)
                                    ? 'assets/img/link.svg'
                                    : content['mimeType'] == EMimeTypes.pdf
                                        ? 'assets/img/icons-file-types-pdf-alternate.svg'
                                        : (content['mimeType'] ==
                                                    EMimeTypes.assessment ||
                                                content['mimeType'] ==
                                                    EMimeTypes.newAssessment)
                                            ? 'assets/img/assessment_icon.svg'
                                            : 'assets/img/resource.svg',
                        text: content['name'],
                        status: enrolledCourse != null &&
                                enrolledCourse.completionPercentage == 100
                            ? 2
                            : content['status'],
                        duration: content['duration'],
                        isFeaturedCourse: isFeatured,
                        currentProgress: enrolledCourse != null &&
                                enrolledCourse.completionPercentage == 100
                            ? 1
                            : double.parse(content['completionPercentage']
                                        .toString()) >
                                    1
                                ? double.parse(content['completionPercentage']
                                        .toString()) /
                                    100
                                : double.parse(
                                    content['completionPercentage'].toString()),
                        showProgress: showProgress,
                        isLastAccessed:
                            content['contentId'] == lastAccessContentId,
                        isEnrolled: isPlayer ? true : enrolledCourse != null,
                        maxQuestions: content['maxQuestions'].toString(),
                        mimeType: content['mimeType'],
                      ),
                    ],
                  )
            : Center(),
      ),
    );
  }
}
