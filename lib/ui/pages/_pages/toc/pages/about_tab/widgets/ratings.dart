import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/models/_models/review_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_learn/star_progress_bar.dart';

class Ratings extends StatelessWidget {
  final OverallRating ratingAndReview;
  const Ratings({Key key, @required this.ratingAndReview}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              Text(
                ratingAndReview != null
                    ? (ratingAndReview.sumOfTotalRatings /
                            ratingAndReview.totalNumberOfRatings)
                        .toStringAsFixed(1)
                    : "0",
                style: GoogleFonts.montserrat(
                    fontSize: 24,
                    color: Color(0xff1B4CA1),
                    fontWeight: FontWeight.w700),
                maxLines: 1,
              ),
              SizedBox(
                width: 16,
              ),
              RatingBarIndicator(
                rating: ratingAndReview != null
                    ? ratingAndReview.sumOfTotalRatings /
                        ratingAndReview.totalNumberOfRatings
                    : 0,
                itemBuilder: (context, index) => Icon(
                  Icons.star,
                  color: AppColors.primaryOne,
                ),
                itemCount: 5,
                itemSize: 30.0,
                direction: Axis.horizontal,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 20),
            child: Text(
              // '1 rating',
              ratingAndReview != null
                  ? "${ratingAndReview.totalNumberOfRatings.ceil().toString()} ${AppLocalizations.of(context).mCommonratings}"
                  : "0 ${AppLocalizations.of(context).mCommonratings}",
              style: GoogleFonts.lato(
                color: AppColors.greys60,
                fontWeight: FontWeight.w400,
                fontSize: 14.0,
              ),
            ),
          ),
          StarProgressBar(
              text: '5 ${AppLocalizations.of(context).mStaticStar}',
              progress: ratingAndReview != null &&
                      ratingAndReview.totalCount5Stars > 0
                  ? ratingAndReview.totalCount5Stars /
                      ratingAndReview.totalNumberOfRatings
                  : 0),
          StarProgressBar(
              text: '4 ${AppLocalizations.of(context).mStaticStar}',
              progress: ratingAndReview != null &&
                      ratingAndReview.totalCount4Stars > 0
                  ? ratingAndReview.totalCount4Stars /
                      ratingAndReview.totalNumberOfRatings
                  : 0),
          StarProgressBar(
              text: '3 ${AppLocalizations.of(context).mStaticStar}',
              progress: ratingAndReview != null &&
                      ratingAndReview.totalCount3Stars > 0
                  ? ratingAndReview.totalCount3Stars /
                      ratingAndReview.totalNumberOfRatings
                  : 0),
          StarProgressBar(
              text: '2 ${AppLocalizations.of(context).mStaticStar}',
              progress: ratingAndReview != null &&
                      ratingAndReview.totalCount2Stars > 0
                  ? ratingAndReview.totalCount2Stars /
                      ratingAndReview.totalNumberOfRatings
                  : 0),
          StarProgressBar(
              text: '1 ${AppLocalizations.of(context).mStaticStar}',
              progress: ratingAndReview != null &&
                      ratingAndReview.totalCount1Stars > 0
                  ? ratingAndReview.totalCount1Stars /
                      ratingAndReview.totalNumberOfRatings
                  : 0),
        ],
      ),
    );
  }
}
