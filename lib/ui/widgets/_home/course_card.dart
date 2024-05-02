import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../constants/index.dart';
import '../../../localization/index.dart';
import '../../../models/index.dart';
import '../../../util/helper.dart';
import '../_common/rating_widget.dart';
import '../index.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final bool displayProgress;
  final double progress;
  final bool isProgram;
  final bool isMandatory;
  final bool isVertical;
  final bool isFeatured;

  CourseCard(
      {@required this.course,
      this.displayProgress = false,
      this.progress = 0,
      this.isProgram = false,
      this.isMandatory = false,
      this.isVertical = false,
      this.isFeatured = false});

  bool isCuratedProgram = false;

  void initState() {
    if (course.raw['cumulativeTracking'] != null) {
      if (course.raw['cumulativeTracking']) {
        isCuratedProgram = true;
      }
    }
  }

  generateCourse(context) {
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
    var courseWidgets = Column(
      // mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //Image
        ClipRRect(
            child: Stack(fit: StackFit.passthrough, children: <Widget>[
          course.appIcon != null
              ? ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: imageExtension != 'svg'
                      ? Image.network(
                          Helper.convertImageUrl(
                            course.appIcon,
                          ),
                          // fit: BoxFit.cover,
                          fit: BoxFit.fill,
                          width: double.infinity,
                          height: 140,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset(
                            'assets/img/image_placeholder.jpg',
                            width: double.infinity,
                            height: 125,
                            fit: BoxFit.fitWidth,
                          ),
                        )
                      : Image.asset(
                          'assets/img/image_placeholder.jpg',
                          width: double.infinity,
                          height: 125,
                          fit: BoxFit.fitWidth,
                        ))
              : course.raw['content'] != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                      child: course.raw['content']['posterImage'] != null
                          ? imgExtension != 'svg'
                              ? Image.network(
                                  Helper.convertToPortalUrl(
                                      course.raw['content']['posterImage']),
                                  fit: BoxFit.fill,
                                  width: double.infinity,
                                  height: 125,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Image.asset(
                                    'assets/img/image_placeholder.jpg',
                                    width: double.infinity,
                                    height: 125,
                                    fit: BoxFit.fitWidth,
                                  ),
                                )
                              : Image.asset(
                                  'assets/img/image_placeholder.jpg',
                                  width: double.infinity,
                                  height: 125,
                                  fit: BoxFit.fitWidth,
                                )
                          : Image.asset(
                              'assets/img/image_placeholder.jpg',
                              width: double.infinity,
                              height: 125,
                              fit: BoxFit.fitWidth,
                            ),
                    )
                  : Image.asset(
                      'assets/img/image_placeholder.jpg',
                      width: double.infinity,
                      height: 125,
                      fit: BoxFit.fitWidth,
                    ),
          (course.creatorIcon != null && !isFeatured)
              ? Positioned(
                  top: 16,
                  right: 16,
                  child: InkWell(
                      onTap: () {},
                      child: Container(
                        margin: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: NetworkImage(course.creatorIcon),
                              fit: BoxFit.fitWidth),
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.all(const Radius.circular(4.0)),
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
                        height: 48,
                        width: 48,
                      )),
                )
              : !isFeatured
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
                                  ? DurationWidget(course.programDuration == "1"
                                      ? '${course.programDuration} day'
                                      : '${course.programDuration} days')
                                  : DurationWidget(isFeatured
                                      ? ('LEARNING HOURS: \t \t' +
                                          Helper.getTimeFormat(course.duration))
                                      : Helper.getTimeFormat(course.duration))
                          : (course.raw['content'] != null &&
                                  course.raw['content']['duration'] != null)
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
        //Primary type
        PrimaryCategoryWidget(
            contentType: course.contentType != null
                ? course.contentType
                : course.raw['contentType']),
        //Course name
        Container(
          alignment: Alignment.topLeft,
          padding: EdgeInsets.fromLTRB(16, 4, 16, 2),
          child: Text(
            course.name != null ? course.name : course.raw['courseName'],
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.lato(
              color: AppColors.greys87,
              fontWeight: FontWeight.w700,
              fontSize: 14.0,
              height: 1.5,
            ),
          ),
        ),
        //Source
        Row(
          children: [
            (course.creatorIcon != null && !isFeatured)
                ? Container(
                    margin: EdgeInsets.only(left: 16, top: 8),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.grey16, width: 1),
                        borderRadius:
                            BorderRadius.all(const Radius.circular(4.0))),
                    child: Container(
                      height: 16,
                      width: 17,
                      margin: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(course.creatorIcon),
                            fit: BoxFit.fitWidth),
                      ),
                    ),
                  )
                : !isFeatured
                    ? Container(
                        margin: EdgeInsets.only(left: 16, top: 6),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border:
                                Border.all(color: AppColors.grey16, width: 1),
                            borderRadius:
                                BorderRadius.all(const Radius.circular(4.0))),
                        child: Container(
                          height: 16,
                          width: 17,
                          margin: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: course.creatorLogo != ''
                                  ? NetworkImage(course.creatorLogo)
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
        RatingWidget(
          rating: course.rating.toString(),
          additionalTags: course.additionalTags,
        ),
      ],
    );

    return courseWidgets;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: COURSE_CARD_WIDTH,
      margin: isVertical
          ? EdgeInsets.only(bottom: 14)
          : EdgeInsets.only(right: 10, bottom: 0),
      padding: EdgeInsets.only(bottom: isVertical ? 16 : 0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.grey08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: generateCourse(context),
    );
  }
}
