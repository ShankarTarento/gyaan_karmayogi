import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/models/_models/course_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/widgets/overall_progress.dart';
import 'package:provider/provider.dart';

import '../../../../../constants/index.dart';
import '../../../../../respositories/_respositories/learn_repository.dart';
import '../../../../../util/helper.dart';
import '../../../../widgets/index.dart';
import '../../../index.dart';

class TocContentHeader extends StatelessWidget {
  const TocContentHeader(
      {Key key,
      @required this.course,
      this.isFeaturedCourse,
      this.enrollmentDetails,
      this.clickedRating})
      : super(key: key);
  final List<Course> enrollmentDetails;
  final course;
  final bool isFeaturedCourse;
  final VoidCallback clickedRating;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.darkBlue,
      child: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(shrinkWrap: true, children: <Widget>[
              PrimaryCategoryWidget(
                contentType: course['courseCategory'] != null
                    ? course['courseCategory']
                    : '',
                bgColor: AppColors.black40,
                textColor: AppColors.appBarBackground,
                addedMargin: true,
              ),
              SizedBox(height: 16),
              Text(
                course['name'] != null ? course['name'] : '',
                style: GoogleFonts.montserrat(
                    color: AppColors.appBarBackground,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.12),
                softWrap: true,
              ),
              SizedBox(height: 8),
              Text(
                course['source'] != null
                    ? '${AppLocalizations.of(context).mCommonBy.toLowerCase()} ${course['source']}'
                    : '',
                style: GoogleFonts.lato(
                    color: AppColors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.429,
                    letterSpacing: 0.25),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Consumer<LearnRepository>(builder: (context, learnRepository, _) {
                var courseRatingInfo = learnRepository.courseRating;
                if (courseRatingInfo != null) {
                  if (courseRatingInfo.runtimeType != String) {
                    double totalRating = getTotalRating(courseRatingInfo);
                    int totalNoOfRating = getTotalNoOfRating(courseRatingInfo);
                    return InkWell(
                      onTap: clickedRating,

                      // () {
                      //   Provider.of<TocServices>(context, listen: false)
                      //       .scrollToBottom();
                      // },
                      child: TotalRatingWidget(
                        rating: totalRating.toStringAsFixed(1),
                        noOfRating: totalNoOfRating.toString(),
                        additionalTags: course['additionalTags'] != null
                            ? course['additionalTags']
                            : [],
                      ),
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                } else {
                  return SizedBox.shrink();
                }
              }),
              SizedBox(height: 8),
              Text(
                course['lastUpdatedOn'] != null
                    ? '(${AppLocalizations.of(context).mCourseLastUpdatedOn} ${Helper.getDateTimeInFormat(course['lastUpdatedOn'], desiredDateFormat: 'MMM dd, yyyy')})'
                    : '',
                style: GoogleFonts.lato(
                    color: AppColors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1.333,
                    letterSpacing: 0.25),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 32),
            ]),
          ),
          OverallProgress(course: course, enrollmentDetails: enrollmentDetails),
        ],
      ),
    );
  }

  int getTotalNoOfRating(courseRatingInfo) {
    return courseRatingInfo['total_number_of_ratings'] != null
        ? courseRatingInfo['total_number_of_ratings'].toInt()
        : 0;
  }

  double getTotalRating(courseRatingInfo) {
    return courseRatingInfo['sum_of_total_ratings'] != null &&
            courseRatingInfo['total_number_of_ratings'] != null
        ? (courseRatingInfo['sum_of_total_ratings'] /
            courseRatingInfo['total_number_of_ratings'])
        : 0;
  }
}
