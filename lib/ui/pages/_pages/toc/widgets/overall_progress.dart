import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/models/_models/course_model.dart';
import 'package:karmayogi_mobile/services/_services/learn_service.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/services/toc_services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../respositories/_respositories/learn_repository.dart';
import '../../learn/course_rating.dart';

class OverallProgress extends StatefulWidget {
  final List<Course> enrollmentDetails;
  final course;

  const OverallProgress({Key key, this.course, this.enrollmentDetails})
      : super(key: key);

  @override
  State<OverallProgress> createState() => _OverallProgressState();
}

class _OverallProgressState extends State<OverallProgress> {
  final LearnService learnService = LearnService();
  Course course;
  double progress;

  @override
  void initState() {
    super.initState();
    getProgress();
  }

  @override
  void didUpdateWidget(OverallProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    getProgress();
  }

  getProgress() {
    var enrollmentDetail = widget.enrollmentDetails.firstWhere(
      (element) =>
          element.raw["content"]["identifier"] == widget.course["identifier"],
      orElse: () => null,
    );
    if (enrollmentDetail != null) {
      course = enrollmentDetail;

      progress = enrollmentDetail.completionPercentage / 100;
    } else {
      progress = null;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TocServices>(builder: (context, tocServices, _) {
      var courseProgress = tocServices.courseProgress;
      if (courseProgress != null) {
        if (progress != null && progress < courseProgress) {
          progress = courseProgress;
        } else {
          progress = courseProgress;
        }
      }

      return progress != null
          ? Consumer<LearnRepository>(builder: (context, learnRepository, _) {
              var yourReviews = learnRepository.courseRatingAndReview;
              return Container(
                height: 50,
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                ),
                width: MediaQuery.of(context).size.width,
                color: (progress * 100).toInt() == 100
                    ? AppColors.profilebgGrey
                    : Colors.white,
                child: Row(children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 200,
                          child: Row(
                            children: [
                              Text(
                                (progress * 100).toInt() == 100
                                    ? AppLocalizations.of(context)
                                        .mCommoncompleted
                                    : AppLocalizations.of(context)
                                        .mStaticOverallProgress,
                                style: GoogleFonts.lato(
                                    color: (progress * 100).toInt() == 100
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400),
                              ),
                              Spacer(),
                              Text(
                                "${(progress * 100).toInt()}%",
                                style: GoogleFonts.lato(
                                    color: (progress * 100).toInt() == 100
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        SizedBox(
                          height: 4,
                          width: 200,
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Color.fromARGB(40, 35, 35, 35),
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.orangeTourText),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CourseRating(
                            course.raw["content"]["name"],
                            course.raw["content"]["identifier"],
                            course.raw["content"]["primaryCategory"],
                            yourReviews,
                            parentAction: () {},
                            onSubmitted: (value) {
                              Provider.of<TocServices>(context, listen: false)
                                  .getCourseRating(
                                      courseDetails: widget.course);
                            },
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(63),
                          color: (progress * 100).toInt() == 100
                              ? AppColors.orangeTourText
                              : Colors.transparent),
                      child: Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: (progress * 100).toInt() == 100
                                ? AppColors.profilebgGrey
                                : AppColors.darkBlue,
                            size: 18,
                          ),
                          Text(
                            yourReviews != null
                                ? AppLocalizations.of(context).mLearnEditRating
                                : AppLocalizations.of(context).mStaticRateNow,
                            style: GoogleFonts.lato(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: (progress * 100).toInt() == 100
                                  ? AppColors.profilebgGrey
                                  : AppColors.darkBlue,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ]),
              );
            })
          : SizedBox();
    });
  }
}
