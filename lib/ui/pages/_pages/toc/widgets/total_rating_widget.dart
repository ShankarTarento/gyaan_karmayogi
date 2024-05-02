import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../constants/index.dart';
import '../../../../widgets/index.dart';

class TotalRatingWidget extends StatelessWidget {
  final List<dynamic> additionalTags;
  final String noOfRating;
  final String rating;
  const TotalRatingWidget(
      {Key key,
      @required this.rating,
      @required this.noOfRating,
      this.additionalTags})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: rating != '0.0' && noOfRating != '0.0'
            ? Row(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                        color: AppColors.greys60,
                        borderRadius: BorderRadius.circular(63)),
                    padding: EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            right: rating != '0.0' ? 5 : 0,
                          ),
                          child: rating != '0.0'
                              ? Icon(
                                  Icons.star,
                                  size: 16,
                                  color: AppColors.primaryOne,
                                )
                              : Center(),
                        ),
                        Text(
                          rating,
                          style: GoogleFonts.lato(
                              color: AppColors.appBarBackground,
                              fontWeight: FontWeight.w600,
                              fontSize: 12.0,
                              letterSpacing: 0.25),
                        ),
                        Container(
                          height: 20,
                          width: 2,
                          color: AppColors.white016,
                          margin: EdgeInsets.symmetric(horizontal: 7),
                        ),
                        Text(
                          noOfRating,
                          style: GoogleFonts.lato(
                              color: AppColors.appBarBackground,
                              fontWeight: FontWeight.w600,
                              fontSize: 12.0,
                              letterSpacing: 0.25),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  additionalTags.isNotEmpty
                      ? Expanded(
                          child: SizedBox(
                            height: 20,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: additionalTags.length,
                                itemBuilder: (BuildContext context, index) {
                                  return Container(
                                      margin: EdgeInsets.only(left: 4),
                                      padding: EdgeInsets.symmetric(
                                          vertical: 2, horizontal: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.yellowShade,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: TitleRegularGrey60(
                                          getTagsText(context,
                                              additionalTags[index].toString()),
                                          color: AppColors.enrollLabelGrey,
                                          fontSize: 10,
                                        ),
                                      ));
                                }),
                          ),
                        )
                      : Center(),
                ],
              )
            : SizedBox.shrink());
  }

  String getTagsText(BuildContext context, String tag) {
    switch (tag) {
      case 'mostEnrolled':
        return AppLocalizations.of(context).mStaticMostEnrolled;

      case 'mostTreanding':
        return AppLocalizations.of(context).mHomeLabelMostTrending;

      default:
        return tag;
    }
  }
}
