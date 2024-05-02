import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../../constants/index.dart';
import '../../../../localization/index.dart';
import '../../../../models/index.dart';
import '../../../../util/helper.dart';
import '../../_common/rating_widget.dart';
import '../../index.dart';

class CbpCourseCard extends StatelessWidget {
  final Course course;
  const CbpCourseCard({Key key, @required this.course}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var imageExtension;
    if (course.appIcon != null) {
      imageExtension = course.appIcon.substring(course.appIcon.length - 3);
    }
    var imgExtension;
    if (course.raw['content'] != null &&
        course.raw['content']['posterImage'] != null) {
      imgExtension = course.raw['content']['posterImage']
          .substring(course.raw['content']['posterImage'].length - 3);
    }
    return Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppColors.appBarBackground,
            borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PrimaryCategoryWidget(
                contentType: course.contentType, addedMargin: true),
            SizedBox(height: 8),
            Row(
              children: [
                ClipRRect(
                    child: Stack(fit: StackFit.passthrough, children: <Widget>[
                  course.appIcon != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          child: imageExtension != 'svg'
                              ? Image.network(
                                  course.appIcon,
                                  // fit: BoxFit.cover,
                                  fit: BoxFit.fill,
                                  width:
                                      MediaQuery.of(context).size.width * 0.35,
                                  height: 100,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Image.asset(
                                    'assets/img/image_placeholder.jpg',
                                    width: MediaQuery.of(context).size.width *
                                        0.35,
                                    height: 100,
                                    fit: BoxFit.fitWidth,
                                  ),
                                )
                              : Image.asset(
                                  'assets/img/image_placeholder.jpg',
                                  width:
                                      MediaQuery.of(context).size.width * 0.35,
                                  height: 100,
                                  fit: BoxFit.fitWidth,
                                ))
                      : course.raw['content'] != null
                          ? ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12)),
                              child: course.raw['content']['posterImage'] !=
                                      null
                                  ? imgExtension != 'svg'
                                      ? Image.network(
                                          Helper.convertImageUrl(course
                                              .raw['content']['posterImage']),
                                          fit: BoxFit.fill,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.3,
                                          height: 100,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Image.asset(
                                            'assets/img/image_placeholder.jpg',
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.3,
                                            height: 100,
                                            fit: BoxFit.fitWidth,
                                          ),
                                        )
                                      : Image.asset(
                                          'assets/img/image_placeholder.jpg',
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.3,
                                          height: 100,
                                          fit: BoxFit.fitWidth,
                                        )
                                  : Image.asset(
                                      'assets/img/image_placeholder.jpg',
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                      height: 100,
                                      fit: BoxFit.fitWidth,
                                    ),
                            )
                          : Image.asset(
                              'assets/img/image_placeholder.jpg',
                              width: MediaQuery.of(context).size.width * 0.35,
                              height: 100,
                              fit: BoxFit.fitWidth,
                            ),
                  Positioned(
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
                                : DurationWidget(
                                    Helper.getTimeFormat(course.duration))
                        : (course.raw['content'] != null &&
                                course.raw['content']['duration'] != null)
                            ? DurationWidget(Helper.getTimeFormat(
                                course.raw['content']['duration']))
                            : Text(''),
                  ),
                  Positioned(
                    top: course.raw['cbPlanEndDate'] != null ? 4 : 0,
                    left: course.raw['cbPlanEndDate'] != null ? 4 : 0,
                    child: course.raw['cbPlanEndDate'] != null
                        ? Container(
                            margin: EdgeInsets.all(4),
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                                color: AppColors.appBarBackground,
                                border: Border.all(
                                    color: AppColors.grey16, width: 1),
                                borderRadius: BorderRadius.all(
                                    const Radius.circular(6.0))),
                            child: Text(
                              Helper.getDateTimeInFormat(
                                  course.raw['cbPlanEndDate'].toString(),
                                  desiredDateFormat: IntentType.dateFormat2),
                              style: GoogleFonts.lato(
                                color: AppColors.greys87,
                                fontWeight: FontWeight.w700,
                                fontSize: 10.0,
                              ),
                            ))
                        : course.endDate != null
                            ? dateWidget(course.endDate, context)
                            : Text(''),
                  )
                ])),
                Flexible(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Container(
                          height: 40,
                          child: Text(
                            course.raw['courseName'] != null
                                ? course.raw['courseName']
                                : course.raw['name'] != null
                                    ? course.raw['name']
                                    : '',
                            style: GoogleFonts.lato(
                                color: AppColors.greys87,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                letterSpacing: 0.25,
                                height: 1.429),
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ),
                      //Source
                      Row(
                        children: [
                          (course.creatorIcon != null)
                              ? Container(
                                  margin: EdgeInsets.only(top: 8),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                          color: AppColors.grey16, width: 1),
                                      borderRadius: BorderRadius.all(
                                          const Radius.circular(4.0))),
                                  child: Container(
                                    height: 16,
                                    width: 17,
                                    margin: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image:
                                              NetworkImage(course.creatorIcon),
                                          fit: BoxFit.fitWidth),
                                    ),
                                  ),
                                )
                              : course.creatorLogo != null
                                  ? Container(
                                      margin: EdgeInsets.only(top: 6, left: 16),
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
                                        margin: EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: course.creatorLogo != ''
                                                ? NetworkImage(
                                                    course.creatorLogo)
                                                : AssetImage(
                                                    'assets/img/igot_creator_icon.png'),
                                          ),
                                        ),
                                      ),
                                    )
                                  : SizedBox.shrink(),
                          Expanded(
                            child: Container(
                              alignment: Alignment.topLeft,
                              padding: EdgeInsets.only(left: 16, right: 16),
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
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: RatingWidget(
                            rating: course.rating.toString(),
                            additionalTags: course.additionalTags,
                            isFromBrowse: true),
                      )
                    ]))
              ],
            ),
          ],
        ));
  }

  Widget dateWidget(String endDate, BuildContext context) {
    int dateDiff = getTimeDiff(endDate, DateTime.now().toString());
    return Container(
      decoration: BoxDecoration(
          color: Colors.transparent.withOpacity(0.5),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12.0),
              bottomRight: Radius.circular(8.0))),
      child: Container(
          margin: EdgeInsets.all(8),
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
              color: dateDiff < 0
                  ? AppColors.negativeLight
                  : dateDiff < 30
                      ? AppColors.verifiedBadgeIconColor
                      : AppColors.positiveLight,
              borderRadius: BorderRadius.all(const Radius.circular(6.0))),
          child: Text(
            dateDiff < 0
                ? AppLocalizations.of(context).mStaticOverdue
                : Helper.getDateTimeInFormat(endDate,
                    desiredDateFormat: IntentType.dateFormat2),
            style: GoogleFonts.lato(
                color: AppColors.appBarBackground,
                fontWeight: FontWeight.w400,
                fontSize: 10.0,
                letterSpacing: 0.5),
          )),
    );
  }

  int getTimeDiff(String date1, String date2) {
    return DateTime.parse(
            DateFormat('yyyy-MM-dd').format(DateTime.parse(date1)))
        .difference(DateTime.parse(
            DateFormat('yyyy-MM-dd').format(DateTime.parse(date2))))
        .inDays;
  }
}
