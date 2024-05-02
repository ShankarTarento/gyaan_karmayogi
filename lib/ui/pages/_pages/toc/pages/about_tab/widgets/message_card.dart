import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/services/toc_services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../../../constants/index.dart';
import '../../../../../../../respositories/_respositories/learn_repository.dart';
import '../../../../../../../respositories/_respositories/profile_repository.dart';
import '../../../../../../widgets/index.dart';

class MessageCards extends StatefulWidget {
  final course;
  final ValueChanged<bool> showKarmaPointClaimButton;
  final bool showCourseCongratsMessage;
  const MessageCards(
      {Key key,
      @required this.course,
      @required this.showKarmaPointClaimButton,
      @required this.showCourseCongratsMessage})
      : super(key: key);

  @override
  State<MessageCards> createState() => _MessageCardsState();
}

class _MessageCardsState extends State<MessageCards> {
  bool isAcbp = false;
  int rewardPoint = 0;
  Map cbpList;
  String cbpEndDate;
  ValueNotifier<bool> showCongratsMessage = ValueNotifier(true);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: <Widget>[
            Consumer<LearnRepository>(builder: (context, learnRepository, _) {
              var review = learnRepository.courseRatingAndReview;
              rewardPoint = COURSE_RATING_POINT;
              if (review == null) {
                return messageWidget(context,
                    isRating: true, isPointRewarded: false);
              } else {
                return messageWidget(context,
                    isRating: true, isPointRewarded: true);
              }
            }),
            widget.showCourseCongratsMessage &&
                    (widget.course['courseCategory'].toString().toLowerCase() ==
                        PrimaryCategory.course.toLowerCase())
                ? Consumer<LearnRepository>(
                    builder: (context, learnRepository, _) {
                    final cbpData = learnRepository.cbplanData;
                    return Consumer<TocServices>(
                        builder: (context, tocservice, _) {
                      dynamic courseProgress = tocservice.courseProgress;

                      if (cbpData != null) {
                        isAcbp =
                            checkIsAcbp(widget.course['identifier'], cbpData);
                      }
                      if (isAcbp && cbpData != null) {
                        getCBPEnddate(cbpData);
                        rewardPoint = ACBP_COURSE_COMPLETION_POINT;
                        if (courseProgress == 1) {
                          showCongratsMessage.value = true;
                          checkIsKarmaPointRewarded(
                              widget.course['identifier']);
                        } else if (getTimeDiff(cbpEndDate) < 0) {
                          isAcbp = false;
                          rewardPoint = COURSE_COMPLETION_POINT;
                        }
                      } else {
                        rewardPoint = COURSE_COMPLETION_POINT;
                      }

                      return ValueListenableBuilder(
                          valueListenable: showCongratsMessage,
                          builder:
                              (BuildContext context, bool value, Widget child) {
                            return value
                                ? messageWidget(context,
                                    isRating: false,
                                    isPointRewarded: courseProgress == 1)
                                : Center();
                          });
                    });
                  })
                : Center()
          ])),
    );
  }

  Container messageWidget(BuildContext context,
      {isRating = false, isPointRewarded = false}) {
    return Container(
      height: 72,
      width: MediaQuery.of(context).size.width * 0.85,
      margin: EdgeInsets.only(right: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Color(0xffEF951E).withOpacity(0.08),
          border: Border.all(
            color: Color(0xffEF951E),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8)),
      child: Row(children: [
        SvgPicture.asset(
          "assets/img/kp_icon.svg",
          alignment: Alignment.center,
          height: 32,
          width: 32,
          // color: Color(0xff1B4CA1),
          fit: BoxFit.contain,
        ),
        SizedBox(
          width: 16,
        ),
        isPointRewarded
            ? congratsMessageWidget(context, isRating)
            : taskRewardMessageWidget(context, isRating)
      ]),
    );
  }

  Widget congratsMessageWidget(context, isRating) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.6,
      child: RichText(
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          children: [
            textWidget(
                isRating
                    ? AppLocalizations.of(context).mStaticcourseRatedMessage(
                        widget.course['courseCategory']
                            .toString()
                            .toLowerCase())
                    : AppLocalizations.of(context)
                        .mStaticcourseCompletedMessage(widget
                            .course['courseCategory']
                            .toString()
                            .toLowerCase()),
                FontWeight.w400),
            textWidget(
                ' $rewardPoint ' +
                    AppLocalizations.of(context).mStaticKarmaPoints +
                    '. ',
                FontWeight.w900),
            WidgetSpan(
                child: isRating
                    ? SizedBox.shrink()
                    : TooltipWidget(
                        message: isAcbp
                            ? AppLocalizations.of(context)
                                .mStaticCourseCompletedInfo
                            : AppLocalizations.of(context)
                                .mStaticCourseCompletedInfo))
          ],
        ),
      ),
    );
  }

  Widget taskRewardMessageWidget(context, isRating) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.6,
      child: RichText(
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          children: [
            textWidget(
                AppLocalizations.of(context).mStaticEarn, FontWeight.w400),
            textWidget(
                ' $rewardPoint ' +
                    AppLocalizations.of(context)
                        .mStaticKarmaPoints
                        .toLowerCase() +
                    ' ',
                FontWeight.w900),
            textWidget(
                isRating
                    ? AppLocalizations.of(context).mratingCourseMessage(widget
                        .course['primaryCategory']
                        .toString()
                        .toLowerCase())
                    : AppLocalizations.of(context)
                        .mStaticcourseCompletedMessage(widget
                            .course['primaryCategory']
                            .toString()
                            .toLowerCase()),
                FontWeight.w400),
            WidgetSpan(
                child: TooltipWidget(
                    message: isRating
                        ? AppLocalizations.of(context).mCourseRatingInfo(
                            widget.course['primaryCategory']
                                .toString()
                                .toLowerCase(),
                            "")
                        : isAcbp
                            ? AppLocalizations.of(context)
                                .mStaticAcbpCourseCompletionInfo
                            : AppLocalizations.of(context)
                                .mStaticCourseCompletionInfo))
          ],
        ),
      ),
    );
  }

  TextSpan textWidget(String message, FontWeight font,
      {Color color = AppColors.greys87, double fontSize = 12}) {
    return TextSpan(
      text: message,
      style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: font,
          letterSpacing: 0.25),
    );
  }

  bool checkIsAcbp(String courseId, cbpData) {
    bool isCourseFound = false;
    if (cbpData.length != null) {
      if (cbpData.length == 0) {
        return isCourseFound;
      }
      cbpData['content'].forEach((cbp) {
        var data = cbp['contentList'].firstWhere(
            (element) => element['identifier'] == courseId,
            orElse: () => {});
        if (data.isNotEmpty) {
          isCourseFound = true;
        }
      });
    }
    return isCourseFound;
  }

  void checkIsKarmaPointRewarded(String courseId) async {
    var response = await ProfileRepository().getKarmaPointCourseRead(courseId);
    if (response != null &&
        response.isNotEmpty &&
        response['points'] < ACBP_COURSE_COMPLETION_POINT) {
      widget.showKarmaPointClaimButton(true);
      showCongratsMessage.value = false;
    }
  }

  int getTimeDiff(String date1) {
    return DateTime.parse(
            DateFormat('yyyy-MM-dd').format(DateTime.parse(date1)))
        .difference(
            DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.now())))
        .inDays;
  }

  void getCBPEnddate(cbpList) {
    if (cbpEndDate == null && cbpList.runtimeType != String) {
      var cbpCourse = cbpList['content'] ?? [];

      for (int index = 0; index < cbpCourse.length; index++) {
        var element = cbpCourse[index]['contentList'];
        for (int elementindex = 0;
            elementindex < element.length;
            elementindex++) {
          if (element[elementindex]['identifier'] ==
              widget.course['identifier']) {
            cbpEndDate = cbpCourse[index]['endDate'];
            break;
          }
        }
      }
    }
  }
}
