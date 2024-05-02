import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:karmayogi_mobile/services/_services/learn_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../models/_models/course_model.dart';
import '../../../../../util/faderoute.dart';
import '../../learn/course_rating_submitted.dart';

class RateNowPopUp extends StatelessWidget {
  final Course courseDetails;
  RateNowPopUp({Key key, @required this.courseDetails}) : super(key: key);
  final LearnService learnService = LearnService();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              children: [
                Spacer(),
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: AppColors.grey40,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.close,
                        size: 24,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height / 3.5,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/img/certificate_icon.svg',
                  width: 36.0,
                  height: 32.0,
                ),
                SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)
                      .mStaticCongratulationsOnCompleting,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  AppLocalizations.of(context)
                      .mStaticYourCertificateWillBeGeneratedWithin48Hrs,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.white70,
                  ),
                ),
                Divider(
                  color: Colors.white,
                  height: 40,
                ),
                RatingBar.builder(
                  initialRating: 0,
                  minRating: 1,
                  glow: false,
                  direction: Axis.horizontal,
                  itemCount: 5,
                  unratedColor: Colors.white,
                  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    //     print(rating);
                    _saveRatingAndReview(
                        id: courseDetails.raw['identifier'],
                        context: context,
                        rating: rating,
                        comment: '',
                        type: courseDetails.raw['primaryCategory']);
                  },
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  AppLocalizations.of(context).mCommonRateTheCourse,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _saveRatingAndReview({id, type, rating, comment, context}) async {
    Response response =
        await learnService.postCourseReview(id, type, rating, comment);
    if (response.statusCode == 200) {
      Navigator.push(
        context,
        FadeRoute(
            page: CourseRatingSubmitted(
          title: courseDetails.raw['name'],
          courseId: courseDetails.raw['identifier'],
          primaryCategory: courseDetails.raw['primaryCategory'],
        )),
      );
      // if (!widget.isFromContentPlayer) {
      //   widget.parentAction(true);
      // }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(jsonDecode(response.body)['params']['errmsg']),
          backgroundColor: AppColors.negativeLight,
        ),
      );
    }
  }
}
