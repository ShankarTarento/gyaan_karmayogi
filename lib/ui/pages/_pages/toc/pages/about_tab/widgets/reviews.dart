import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/models/_models/review_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/view_all_reviews.dart/view_all_reviews.dart';
import 'package:karmayogi_mobile/util/helper.dart';

class Reviews extends StatelessWidget {
  final OverallRating reviewAndRating;
  final Map<String, dynamic> course;
  const Reviews(
      {Key key, @required this.reviewAndRating, @required this.course})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16, bottom: 10),
          child: Row(
            children: [
              Text(
                AppLocalizations.of(context).mStaticTopReviews,
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Spacer(),
              TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: ((context) => ViewAllReviews(
                              course: course,
                            )),
                      ),
                    );
                  },
                  child: Text(
                    AppLocalizations.of(context).mStaticShowAll,
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      color: Color(0xff1B4CA1),
                      fontWeight: FontWeight.w400,
                    ),
                  ))
            ],
          ),
        ),
        // SizedBox(
        //   height: 16,
        // ),
        reviewAndRating != null && reviewAndRating.reviews.isNotEmpty
            ? SizedBox(
                height: 112,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: reviewAndRating.reviews.length,
                    itemBuilder: (context, index) => reviewCard(
                        index: index,
                        review: reviewAndRating.reviews[index],
                        context: context)),
              )
            : Container(
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.only(top: 16, left: 16, right: 16),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  AppLocalizations.of(context).mStaticNoReviewsFound,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
        SizedBox(
          height: 16,
        ),
      ],
    );
    // : Column(
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: [
    //       Text(
    //         "Top reviews",
    //         style: GoogleFonts.lato(
    //           fontSize: 16,
    //           fontWeight: FontWeight.w700,
    //         ),
    //       ),

    //     ],
    //   );
  }

  Widget reviewCard(
      {@required Review review,
      @required BuildContext context,
      @required int index}) {
    return Container(
      height: 112,
      width: MediaQuery.of(context).size.width / 1.2,
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(right: 16, left: index == 0 ? 16 : 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: Color(0xff306933),
                child: Text(
                  Helper.getInitials(review.firstName),
                  style: GoogleFonts.lato(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                width: 8,
              ),
              Flexible(
                child: Text(
                  review.firstName,
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff000000).withOpacity(0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8),
                child: CircleAvatar(
                  radius: 1,
                  backgroundColor: Color(0xff000000).withOpacity(0.6),
                ),
              ),
              Text(
                getReviewTime(review.date.toString(), context),
                style: GoogleFonts.lato(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xff000000).withOpacity(0.6),
                ),
              ),
              Spacer(),
              Icon(
                Icons.star,
                color: Color(0xffEF951E),
                size: 16,
              ),
              SizedBox(
                width: 2,
              ),
              Text(
                review.rating.toString(),
                style: GoogleFonts.lato(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xff000000).withOpacity(0.6),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 8,
          ),
          Flexible(
            child: Text(
              review.review,
              style: GoogleFonts.lato(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xff000000),
                  height: 1.5),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          )
        ],
      ),
    );
  }

  String getReviewTime(String time, BuildContext context) {
    DateTime now = DateTime.now();
    DateTime reviewTime = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    Duration difference = now.difference(reviewTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${AppLocalizations.of(context).mStaticMinutesAgo}';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${AppLocalizations.of(context).mStaticHoursAgo}';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} ${AppLocalizations.of(context).mStaticDaysAgo}';
    } else {
      int months =
          (now.year - reviewTime.year) * 12 + now.month - reviewTime.month;
      return '$months ${AppLocalizations.of(context).mHomeDiscussionMonthsAgo}';
    }
  }
}
