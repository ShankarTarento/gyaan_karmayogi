import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/ui/widgets/_common/rating_widget.dart';

import '../../../constants/_constants/telemetry_constants.dart';
import '../../../constants/index.dart';
import '../../../localization/index.dart';
import '../../../models/_arguments/index.dart';
import '../../../models/index.dart';
import '../../../util/helper.dart';
import '../../../util/telemetry.dart';
import '../../../util/telemetry_db_helper.dart';
import '../index.dart';

class BrowseCard extends StatelessWidget {
  final Course course;
  final bool isProgram;
  final bool isCuratedProgram;
  final bool isFeatured;
  final bool isModerated;
  final bool isBlendedProgram;

  BrowseCard(
      {this.course,
      this.isProgram = false,
      this.isBlendedProgram = false,
      this.isCuratedProgram = false,
      this.isFeatured = false,
      this.isModerated = false});

  String userId;
  String userSessionId;
  String messageIdentifier;
  String departmentId;
  String deviceIdentifier;
  var telemetryEventData;

  void _generateInteractTelemetryData(String contentId) async {
    deviceIdentifier = await Telemetry.getDeviceIdentifier();
    userId = await Telemetry.getUserId();
    userSessionId = await Telemetry.generateUserSessionId();
    messageIdentifier = await Telemetry.generateUserSessionId();
    departmentId = await Telemetry.getUserDeptId();
    Map eventData = Telemetry.getInteractTelemetryEvent(
        deviceIdentifier,
        userId,
        departmentId,
        TelemetryPageIdentifier.topicCoursesPageId,
        userSessionId,
        messageIdentifier,
        contentId,
        TelemetrySubType.courseCard,
        env: TelemetryEnv.explore,
        objectType: TelemetrySubType.courseCard);
    telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap());
  }

  @override
  Widget build(BuildContext context) {
    // print("Name: ${browseCompetencyCardModel.name}");
    var imageExtension;
    if (course.appIcon != null) {
      imageExtension = course.appIcon.substring(course.appIcon.length - 3);
    }
    return InkWell(
        onTap: () async {
          _generateInteractTelemetryData(course.id);

          String batchId = '';
          if (course.raw['cumulativeTracking'] != null) {
            if (course.raw['cumulativeTracking']) {
              course.raw['batches']
                  .forEach((batch) => batchId = batch['batchId']);
            }
          }

          Navigator.pushNamed(context, AppUrl.courseTocPage,
              arguments: CourseTocModel.fromJson({
                'courseId': course.id,
                'isBlendedProgram': isBlendedProgram,
                'isModeratedContent': isModerated
              }));
        },
        child: Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.grey08)),
            child: Column(
              children: [
                //Primary type
                PrimaryCategoryWidget(
                    contentType: course.contentType, addedMargin: true),
                SizedBox(
                  height: 6,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ClipRRect(
                        child:
                            Stack(fit: StackFit.passthrough, children: <Widget>[
                      ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            height: 100,
                            width: 139,
                            decoration: BoxDecoration(
                              image: course.appIcon != null
                                  ? DecorationImage(
                                      onError: (exception, stackTrace) =>
                                          AssetImage(
                                            'assets/img/image_placeholder.jpg',
                                          ),
                                      image: imageExtension != 'svg'
                                          ? NetworkImage(course.appIcon)
                                          : AssetImage(
                                              'assets/img/image_placeholder.jpg',
                                            ),
                                      fit: BoxFit.fill)
                                  : DecorationImage(
                                      image: AssetImage(
                                        'assets/img/image_placeholder.jpg',
                                      ),
                                      fit: BoxFit.fill),
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(const Radius.circular(4.0)),
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
                          )),
                      !isFeatured
                          ? Positioned(
                              bottom: 4,
                              right: 4,
                              child: course.duration != null
                                  ? (course.contentType).toLowerCase() ==
                                              (EnglishLang.blendedProgram)
                                                  .toLowerCase() &&
                                          course.duration == '0' &&
                                          course.programDuration == null
                                      ? Center()
                                      : course.programDuration != null &&
                                              course.programDuration.isNotEmpty
                                          ? DurationWidget(
                                              course.programDuration + ' days')
                                          : DurationWidget(isFeatured
                                              ? ('LEARNING HOURS: \t \t' +
                                                  Helper.getTimeFormat(
                                                      course.duration))
                                              : Helper.getTimeFormat(
                                                  course.duration))
                                  : (course.raw['content'] != null &&
                                          course.raw['content']['duration'] !=
                                              null)
                                      ? DurationWidget(Helper.getTimeFormat(
                                          course.raw['content']['duration']))
                                      : Text(''),
                            )
                          : Center(),
                      Positioned(
                        top: 0,
                        left: 0,
                        child: course.endDate != null
                            ? ShowDateWidget(endDate: course.endDate)
                            : Text(''),
                      )
                    ])),
                    SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TitleBoldWidget(
                              course.name != null ? course.name : '',
                              fontSize: 14,
                              maxLines: 2,
                            ),
                            SizedBox(height: 8),
                            //Source
                            Row(
                              children: [
                                (course.creatorIcon != null && !isFeatured)
                                    ? Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(
                                                color: AppColors.grey16,
                                                width: 1),
                                            borderRadius: BorderRadius.all(
                                                const Radius.circular(4.0))),
                                        child: Container(
                                          height: 16,
                                          width: 17,
                                          margin: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image: NetworkImage(
                                                    course.creatorIcon),
                                                fit: BoxFit.fitWidth),
                                          ),
                                        ),
                                      )
                                    : !isFeatured
                                        ? Container(
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                border: Border.all(
                                                    color: AppColors.grey16,
                                                    width: 1),
                                                borderRadius: BorderRadius.all(
                                                    const Radius.circular(
                                                        4.0))),
                                            child: Container(
                                              height: 16,
                                              width: 17,
                                              margin: EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  image: course.creatorLogo !=
                                                          ''
                                                      ? NetworkImage(
                                                          course.creatorLogo)
                                                      : AssetImage(
                                                          'assets/img/igot_creator_icon.png'),
                                                ),
                                              ),
                                            ),
                                          )
                                        : Center(),
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.topLeft,
                                    padding:
                                        EdgeInsets.only(left: 16, right: 16),
                                    child: Text(
                                      course.source != null
                                          ? course.source != ''
                                              ? 'By ' + course.source
                                              : ''
                                          : '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.lato(
                                        color: AppColors.greys60,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12.0,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            //Rating
                            RatingWidget(
                                rating: course.rating.toString(),
                                additionalTags: course.additionalTags,
                                isFromBrowse: true)
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ],
            )));
  }
}
