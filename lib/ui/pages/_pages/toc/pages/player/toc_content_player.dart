import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/ui/pages/index.dart';

import '../../../../../../constants/index.dart';
import '../../../../../../env/env.dart';
import '../../../../../../feedback/pages/_pages/_cbpSurvey/content_feedback.dart';
import '../../../../../widgets/index.dart';

class TocContentPlayer extends StatelessWidget {
  final ValueChanged<bool> changeLayout;
  final ValueChanged<Map> updateContentProgress, showLatestProgress;
  final bool fullScreen, isFeatured, isCuratedProgram;
  final Map resourceNavigateItems;
  final Map<String, dynamic> courseHierarchyData;
  final String batchId, primaryCategory;
  final List navigationItems;
  final ValueChanged<bool> playNextResource;

  TocContentPlayer(
      {Key key,
      @required this.changeLayout,
      @required this.updateContentProgress,
      this.fullScreen = false,
      @required this.resourceNavigateItems,
      @required this.courseHierarchyData,
      this.isFeatured = false,
      this.isCuratedProgram = false,
      @required this.batchId,
      @required this.showLatestProgress,
      @required this.primaryCategory,
      @required this.navigationItems,
      this.playNextResource})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: fullScreen ? MediaQuery.of(context).size.height - 100 : 250,
        width: MediaQuery.of(context).size.width,
        color: AppColors.greys87,
        child: resourceNavigateItems['mimeType'] == EMimeTypes.pdf
            ? TocPlayerPdfScreen(
                player: CoursePdfPlayer(
                    course: courseHierarchyData,
                    identifier: resourceNavigateItems['identifier'],
                    fileUrl:
                        _generateCdnUri(resourceNavigateItems['artifactUrl']),
                    currentProgress: resourceNavigateItems['currentProgress'],
                    status: resourceNavigateItems['status'],
                    batchId: isCuratedProgram
                        ? resourceNavigateItems['parentBatchId']
                        : batchId,
                    parentCourseId: isCuratedProgram
                        ? resourceNavigateItems['parentCourseId']
                        : courseHierarchyData['identifier'],
                    parentAction1: changeLayout,
                    parentAction2: updateContentProgress,
                    isFeaturedCourse: isFeatured,
                    updateProgress: showLatestProgress,
                    primaryCategory: primaryCategory,
                    playNextResource: playNextResource),
                resourcename: resourceNavigateItems['name'])
            : (resourceNavigateItems['mimeType'] == EMimeTypes.mp4 ||
                    resourceNavigateItems['mimeType'] == EMimeTypes.m3u8)
                ? CourseVideoPlayer(
                    course: courseHierarchyData,
                    identifier: resourceNavigateItems['identifier'],
                    fileUrl:
                        _generateCdnUri(resourceNavigateItems['artifactUrl']),
                    mimeType: resourceNavigateItems['mimeType'],
                    updateProgress: true,
                    currentProgress: resourceNavigateItems['currentProgress'],
                    status: resourceNavigateItems['status'],
                    batchId: isCuratedProgram
                        ? resourceNavigateItems['parentBatchId']
                        : batchId,
                    parentCourseId: isCuratedProgram
                        ? resourceNavigateItems['parentCourseId']
                        : courseHierarchyData['identifier'],
                    parentAction: showLatestProgress,
                    isFeatured: false,
                    primaryCategory: resourceNavigateItems['primaryCategory'],
                    playNextResource: playNextResource,
                  )
                : resourceNavigateItems['mimeType'] == EMimeTypes.mp3
                    ? CourseAudioPlayer(
                        identifier: resourceNavigateItems['identifier'],
                        fileUrl: _generateCdnUri(
                            resourceNavigateItems['artifactUrl']),
                        updateProgress: true,
                        batchId: isCuratedProgram
                            ? resourceNavigateItems['parentBatchId']
                            : batchId,
                        parentCourseId: isCuratedProgram
                            ? resourceNavigateItems['parentCourseId']
                            : courseHierarchyData['identifier'],
                        course: courseHierarchyData,
                        status: resourceNavigateItems['status'],
                        parentAction: showLatestProgress,
                        isFeaturedCourse: isFeatured,
                        primaryCategory:
                            resourceNavigateItems['primaryCategory'],
                        currentProgress:
                            resourceNavigateItems['currentProgress'],
                      )
                    : resourceNavigateItems['mimeType'] == EMimeTypes.html
                        ? TocPlayerInNewScreen(
                            player: CourseHtmlPlayer(
                                courseHierarchyData,
                                resourceNavigateItems['identifier'],
                                resourceNavigateItems['artifactUrl'],
                                isCuratedProgram
                                    ? resourceNavigateItems['parentBatchId']
                                    : batchId,
                                changeLayout,
                                updateContentProgress,
                                parentAction3: showLatestProgress,
                                isFeaturedCourse: isFeatured,
                                streamingUrl:
                                    resourceNavigateItems['streamingUrl'],
                                primaryCategory:
                                    resourceNavigateItems['primaryCategory'],
                                initFile: resourceNavigateItems['initFile'],
                                duration: navigationItems,
                                parentCourseId: isCuratedProgram
                                    ? resourceNavigateItems['parentCourseId']
                                    : courseHierarchyData['identifier']),
                            resourcename: resourceNavigateItems['name'],
                          )
                        : resourceNavigateItems['mimeType'] ==
                                    EMimeTypes.externalLink ||
                                resourceNavigateItems['mimeType'] ==
                                    EMimeTypes.youtubeLink
                            ? TocPlayerInNewScreen(
                                player: CourseYoutubePlayer(
                                  courseHierarchyData,
                                  resourceNavigateItems['identifier'],
                                  resourceNavigateItems['artifactUrl'],
                                  resourceNavigateItems['currentProgress'],
                                  resourceNavigateItems['status'],
                                  isCuratedProgram
                                      ? resourceNavigateItems['parentBatchId']
                                      : batchId,
                                  resourceNavigateItems['mimeType'],
                                  isFeaturedCourse: isFeatured,
                                  updateContentProgress: showLatestProgress,
                                  primaryCategory:
                                      resourceNavigateItems['primaryCategory'],
                                  parentCourseId: isCuratedProgram
                                      ? resourceNavigateItems['parentCourseId']
                                      : courseHierarchyData['identifier'],
                                ),
                                isYoutubeContent: true,
                                resourcename: resourceNavigateItems['name'],
                              )
                            : resourceNavigateItems['mimeType'] ==
                                    EMimeTypes.survey
                                ? (!isFeatured
                                    ? TocPlayerInNewScreen(
                                        player: ContentFeedback(
                                          resourceNavigateItems['artifactUrl'],
                                          resourceNavigateItems['name'],
                                          courseHierarchyData,
                                          resourceNavigateItems['identifier'],
                                          isCuratedProgram
                                              ? resourceNavigateItems[
                                                  'parentBatchId']
                                              : batchId,
                                          updateContentProgress:
                                              showLatestProgress,
                                          parentCourseId: isCuratedProgram
                                              ? resourceNavigateItems[
                                                  'parentCourseId']
                                              : courseHierarchyData[
                                                  'identifier'],
                                          playNextResource: playNextResource,
                                        ),
                                        isSurvey: true,
                                        resourcename:
                                            resourceNavigateItems['name'],
                                      )

                                    // Center(
                                    //     child: Text(
                                    //     resourceNavigateItems['status'] == 2
                                    //         ? 'Survey is already submitted'
                                    //         : 'Tap on the survey to start',
                                    //     textAlign: TextAlign.center,
                                    //     style: GoogleFonts.lato(
                                    //         height: 1.5,
                                    //         color: AppColors.greys87,
                                    //         fontSize: 16,
                                    //         fontWeight: FontWeight.w400),
                                    //   ))
                                    : Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      32, 16, 32, 8),
                                              child: Text(
                                                AppLocalizations.of(context)
                                                    .mDoSignInOrRegisterMessage,
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.lato(
                                                    fontWeight: FontWeight.w500,
                                                    height: 1.5,
                                                    fontSize: 16),
                                              ),
                                            ),
                                            // signInOrRegister(),
                                          ],
                                        ),
                                      ))
                                : (!isFeatured
                                    ? TocPlayerInNewScreen(
                                        player: CourseAssessmentPlayer(
                                            courseHierarchyData,
                                            resourceNavigateItems['name'],
                                            resourceNavigateItems['identifier'],
                                            resourceNavigateItems[
                                                'artifactUrl'],
                                            showLatestProgress,
                                            isCuratedProgram
                                                ? resourceNavigateItems[
                                                    'parentBatchId']
                                                : batchId,
                                            resourceNavigateItems['duration'],
                                            primaryCategory:
                                                resourceNavigateItems[
                                                    'primaryCategory'],
                                            parentCourseId: isCuratedProgram
                                                ? resourceNavigateItems[
                                                    'parentCourseId']
                                                : courseHierarchyData['identifier'],
                                            playNextResource: playNextResource),
                                        resourcename: resourceNavigateItems['name'],
                                        isAssessment: true)
                                    : Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      32, 16, 32, 8),
                                              child: Text(
                                                'Tap on assessment to start',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.lato(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 16),
                                              ),
                                            ),
                                            // signInOrRegister(),
                                          ],
                                        ),
                                      )));
  }

  String _generateCdnUri(String artifactUri) {
    try {
      var chunk = artifactUri.split('/');
      String host = Env.cdnHost;
      String bucket = Env.cdnBucket;
      var newChunk = host.split('/');
      var newLink = [];
      for (var i = 0; i < chunk.length; i += 1) {
        if (i == 2) {
          newLink.add(newChunk[i]);
        } else if (i == 3) {
          newLink.add(bucket.substring(1));
        } else {
          newLink.add(chunk[i]);
        }
      }
      String newUrl = newLink.join('/');
      return newUrl;
    } catch (e) {
      return artifactUri ?? '';
    }
  }
}
