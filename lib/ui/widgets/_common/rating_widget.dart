import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../constants/_constants/color_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RatingWidget extends StatelessWidget {
  final List<dynamic> additionalTags;
  final bool isFromBrowse;
  const RatingWidget(
      {Key key,
      @required this.rating,
      this.additionalTags,
      this.isFromBrowse = false})
      : super(key: key);

  final String rating;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Padding(
            padding: EdgeInsets.only(
                left: isFromBrowse ? 0 : 16, top: 5, bottom: 15),
            child: Row(
              children: <Widget>[
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
                rating != '0.0'
                    ? Text(
                        rating,
                        style: GoogleFonts.lato(
                          color: AppColors.greys60,
                          fontWeight: FontWeight.w400,
                          fontSize: 12.0,
                        ),
                      )
                    : Center(),
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
                                    child: Text(
                                        getTagsText(context,
                                            additionalTags[index].toString()),
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.lato(
                                            color: AppColors.enrollLabelGrey,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 10,
                                            letterSpacing: 0.25,
                                            height: 1.3)));
                              }),
                        ),
                      )
                    : Center(),

                //         RatingBar.builder(
                //           initialRating: widget.course.rating,
                //           minRating: 1,
                //           direction: Axis.horizontal,
                //           allowHalfRating: true,
                //           itemCount: 5,
                //           itemSize: 20,
                //           itemPadding: EdgeInsets.symmetric(horizontal: 0.0), mjjk
                //           itemBuilder: (context, _) => Icon(
                //             Icons.star,
                //             color: AppColors.primaryOne,
                //           ),
                //           onRatingUpdate: (rating) {
                //             // print(rating);
                //           },
                //         )
              ],
            )));
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
