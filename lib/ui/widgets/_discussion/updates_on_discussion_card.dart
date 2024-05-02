import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../constants/index.dart';
import '../../../models/index.dart';

class UpdatesOnDiscussionCard extends StatelessWidget {
  final Discuss latestDiscussion;

  const UpdatesOnDiscussionCard({Key key, this.latestDiscussion})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.appBarBackground,
        border: Border.all(color: AppColors.grey16),
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          latestDiscussion.upVotes > 0
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${latestDiscussion.upVotes} Upvote on your post',
                      style: GoogleFonts.lato(
                          color: AppColors.darkBlue,
                          fontWeight: FontWeight.w700,
                          wordSpacing: 1.0,
                          fontSize: 14.0,
                          letterSpacing: 0.25),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        latestDiscussion.title,
                        style: GoogleFonts.lato(
                          color: AppColors.greys87,
                          fontWeight: FontWeight.w400,
                          wordSpacing: 1.0,
                          letterSpacing: 0.25,
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                  ],
                )
              : Center(),
          latestDiscussion.downVotes > 0
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${latestDiscussion.downVotes} DownVotes on your post',
                      style: GoogleFonts.lato(
                          color: AppColors.darkBlue,
                          fontWeight: FontWeight.w700,
                          wordSpacing: 1.0,
                          fontSize: 14.0,
                          letterSpacing: 0.25),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        latestDiscussion.title,
                        textAlign: TextAlign.left,
                        style: GoogleFonts.lato(
                          color: AppColors.greys87,
                          fontWeight: FontWeight.w400,
                          wordSpacing: 1.0,
                          letterSpacing: 0.25,
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                  ],
                )
              : Center(),
        ],
      ),
    );
  }
}
