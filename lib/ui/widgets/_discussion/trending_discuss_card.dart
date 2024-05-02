import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple_moment/simple_moment.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../constants/index.dart';
import '../../../util/helper.dart';

class TrendingDiscussCard extends StatelessWidget {
  final data;
  final bool filterEnabled;
  final bool showVideo;
  final bool isProfile;
  final bool isDiscussion;

  TrendingDiscussCard(
      {Key key,
      this.data,
      this.filterEnabled = true,
      this.showVideo = false,
      this.isProfile = false,
      this.isDiscussion = false})
      : super(key: key);
  final dateNow = Moment.now();
  final service = HttpClient();
  String _name;

  List<Widget> _getTags(List discussionTags) {
    List<Widget> tags = [];
    if (discussionTags != null)
      for (int i = 0; i < discussionTags.length; i++) {
        tags.add(InkWell(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Container(
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.grey04,
                border: Border.all(color: AppColors.grey08),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(04),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(04)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 2, 12, 4),
                child: Text(
                  discussionTags[i]['value'],
                  style: GoogleFonts.lato(
                    color: AppColors.greys87,
                    fontWeight: FontWeight.w400,
                    wordSpacing: 1.0,
                    fontSize: 12.0,
                  ),
                ),
              ),
            ),
          ),
        ));
      }
    return tags;
  }

  Future<String> _getUserName() async {
    if (data.user['fullname'] != null && data.user['fullname'] != '') {
      _name = data.user['fullname'];
    } else if (data.user['displayname'] != null &&
        data.user['displayname'] != '') {
      _name = data.user['displayname'];
    } else if (data.user['username'] != null && data.user['username'] != '') {
      _name = data.user['username'];
    } else {
      _name = 'Unknown user';
    }
    return _name;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getUserName(),
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.data != null) {
            return Container(
                margin: isProfile
                    ? EdgeInsets.fromLTRB(16, 0, 16, 8)
                    : EdgeInsets.only(right: 6),
                padding: isProfile
                    ? EdgeInsets.zero
                    : EdgeInsets.only(top: 16, bottom: 8),
                width: isProfile || isDiscussion
                    ? MediaQuery.of(context).size.width
                    : MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                  color: AppColors.appBarBackground,
                  border: Border.all(
                      color: isProfile ? Colors.transparent : AppColors.grey16),
                  borderRadius:
                      BorderRadius.all(Radius.circular(isProfile ? 0 : 16)),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _name != null
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                  Container(
                                      height: 24,
                                      width: 24,
                                      margin: isProfile
                                          ? EdgeInsets.zero
                                          : EdgeInsets.only(left: 16),
                                      decoration: BoxDecoration(
                                        color: isProfile
                                            ? AppColors.profilebgGrey
                                            : AppColors.networkBg[Random()
                                                .nextInt(AppColors
                                                    .networkBg.length)],
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          Helper.getInitialsNew(_name)
                                              .toUpperCase(),
                                          style: GoogleFonts.lato(
                                            color: Colors.white,
                                            fontSize: 10.0,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      )),
                                  Container(
                                      padding: EdgeInsets.only(
                                        left: 8.0,
                                      ),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            ConstrainedBox(
                                              constraints: BoxConstraints(
                                                  maxWidth:
                                                      isProfile ? 150 : 200),
                                              child: Text(
                                                Helper()
                                                    .capitalizeEachWordFirstCharacter(
                                                        _name),
                                                style: GoogleFonts.lato(
                                                    color: AppColors.greys60,
                                                    fontSize: 14.0,
                                                    fontWeight: FontWeight.w400,
                                                    letterSpacing: 0.25),
                                                softWrap: true,
                                                maxLines: 2,
                                              ),
                                            ),
                                            Text(
                                              (dateNow.from(DateTime
                                                      .fromMillisecondsSinceEpoch(
                                                          data.timeStamp)))
                                                  .toString(),
                                              style: GoogleFonts.lato(
                                                  color: AppColors.greys60,
                                                  fontSize: 12.0,
                                                  fontWeight: FontWeight.w400,
                                                  letterSpacing: 0.25),
                                              overflow: TextOverflow.ellipsis,
                                            )
                                          ]))
                                ])
                          : Center(),
                      Padding(
                        padding: isProfile
                            ? EdgeInsets.only(top: 12.0)
                            : EdgeInsets.only(top: 12.0, left: 16, right: 16),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width),
                            child: Text(
                              data.title,
                              style: GoogleFonts.lato(
                                color: AppColors.greys87,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w400,
                                wordSpacing: 1,
                                textStyle: TextStyle(height: 1.5),
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: isProfile
                            ? EdgeInsets.only(top: 16)
                            : EdgeInsets.only(left: 12, right: 12, top: 16.0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              showStatusofDiscussion(
                                  'assets/img/swap_vert.svg',
                                  AppLocalizations.of(context).mStaticVotes,
                                  (data.upVotes != null &&
                                          data.downVotes != null)
                                      ? data.upVotes + data.downVotes
                                      : 0,
                                  context),
                              data.viewCount != null && data.viewCount != 0
                                  ? showStatusofDiscussion(
                                      'assets/img/eye_icon.svg',
                                      AppLocalizations.of(context).mStaticViews,
                                      data.viewCount != null
                                          ? data.viewCount
                                          : 0,
                                      context)
                                  : Center(),
                              showStatusofDiscussion(
                                  'assets/img/comment_icon.svg',
                                  AppLocalizations.of(context).mStaticComments,
                                  data.postCount != null
                                      ? data.postCount - 1
                                      : 0,
                                  context)
                            ],
                          ),
                        ),
                      )
                    ]));
          } else {
            return Center();
          }
        });
  }

  Widget showStatusofDiscussion(
      String image, String category, int count, BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          image,
          width: 24.0,
          height: 24.0,
        ),
        Padding(
          padding: EdgeInsets.only(left: 2.0, right: 8),
          child: Text(
            count.toString() + ' ' + category,
            style: GoogleFonts.lato(
              color: AppColors.greys60,
              fontWeight: FontWeight.w400,
              fontSize: 12.0,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
