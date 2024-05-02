import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/localization/index.dart';
import 'package:karmayogi_mobile/ui/widgets/_learn/author.dart';
import 'package:karmayogi_mobile/ui/widgets/_network/follow_us_social_media.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../models/_models/event_detail_model.dart';

class EventOverview extends StatefulWidget {
  final EventDetail eventDetail;
  EventOverview({Key key, this.eventDetail}) : super(key: key);

  @override
  _EventOverviewState createState() => _EventOverviewState();
}

class _EventOverviewState extends State<EventOverview> {
  bool isBigDescription = true;

  bool trimText = false;

  int _maxLength = 100;

  @override
  void initState() {
    super.initState();
    if (widget.eventDetail.description != null) {
      if (widget.eventDetail.description.length > _maxLength) {
        trimText = true;
      }
    }
    // DateTime parseDt = DateTime.parse(widget.course['lastUpdatedOn']);
    // formattedDate = DateFormat.yMMMd().format(parseDt);
    // developer.log('keywords: ' + widget.course['additionalFields'].toString());
  }

  formateDate(date) {
    return DateFormat("MMM d, y").format(DateTime.parse(date));
  }

  formateTime(time) {
    return time.substring(0, 5);
  }

  _formatTimeIn12hourFormat(time) {
    int _hour = int.parse(time.substring(0, 2));
    int _min = int.parse(time.substring(0, 2));
    String timeIn12HourFormat = time.substring(0, 5);
    timeIn12HourFormat = (_hour < 12
        ? ' $timeIn12HourFormat am'
        : '${(_hour - 12).toString() + ':' + _min.toString()} pm');
    return timeIn12HourFormat;
  }

  isEventCompleted() {
    int timestampNow = DateTime.now().millisecondsSinceEpoch;
    String start = widget.eventDetail.startDate +
        ' ' +
        formateTime(widget.eventDetail.startTime);
    DateTime startDate = DateTime.parse(start);
    int timestampStartEvent = startDate.microsecondsSinceEpoch;
    double eventStartTime = timestampStartEvent / 1000;
    String expiry = widget.eventDetail.endDate +
        ' ' +
        formateTime(widget.eventDetail.endTime);
    DateTime expireDate = DateTime.parse(expiry);
    int timestampExpireEvent = expireDate.microsecondsSinceEpoch;
    double eventExpireTime = timestampExpireEvent / 1000;
    if (timestampNow > eventExpireTime) {
      return EnglishLang.completed;
    } else if (timestampNow <= eventExpireTime &&
        timestampNow >= eventStartTime) {
      return EnglishLang.started;
    } else
      return EnglishLang.notStarted;
  }

  void _toogleReadMore() {
    setState(() {
      trimText = !trimText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.topLeft,
          padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Text(
            widget.eventDetail.name,
            style: GoogleFonts.lato(
              color: AppColors.greys87,
              fontWeight: FontWeight.w700,
              fontSize: 16.0,
            ),
          ),
        ),
        Visibility(
          visible: widget.eventDetail.instructions.isNotEmpty,
          child: Container(
            alignment: Alignment.topLeft,
            padding: EdgeInsets.only(left: 20, right: 20, bottom: 16),
            child: Text(
              widget.eventDetail.instructions,
              // maxLines: 2,
              style: GoogleFonts.lato(
                color: AppColors.greys87,
                height: 1.5,
                fontSize: 16.0,
              ),
            ),
          ),
        ),
        Container(
            width: 166,
            height: 44,
            alignment: Alignment.topLeft,
            margin: EdgeInsets.symmetric(horizontal: 16),
            child: widget.eventDetail.eventType.toString().toLowerCase() ==
                    EventType.karmayogiTalks.toLowerCase()
                ? Image.asset(
                    'assets/img/karmayogi_talks_logo.png',
                    fit: BoxFit.fitWidth,
                    errorBuilder: (context, error, stackTrace) =>
                        SizedBox.shrink(),
                  )
                : roundedButton(
                    buttonLabel: EventType.webinar,
                    bgColor: AppColors.darkBlue,
                    textColor: AppColors.appBarBackground)),
        Container(
          alignment: Alignment.topLeft,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.fromLTRB(30, 15, 20, 20),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(const Radius.circular(12.0)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 40,
                margin: const EdgeInsets.only(top: 16),
                child: ButtonTheme(
                  child: OutlinedButton(
                    onPressed: () async {
                      if ((isEventCompleted() == EnglishLang.notStarted ||
                              isEventCompleted() == EnglishLang.started) &&
                          widget.eventDetail.registrationLink != null) {
                        Helper.doLaunchUrl(
                            url: widget.eventDetail.registrationLink,
                            mode: LaunchMode.externalApplication);
                      } else if (isEventCompleted() == EnglishLang.completed &&
                          widget.eventDetail.recordedLinks != null) {
                        Helper.doLaunchUrl(
                            url: widget.eventDetail.recordedLinks.first
                                .toString(),
                            mode: LaunchMode.externalApplication);
                      } else {
                        Helper.showSnackBarMessage(
                            context: context,
                            text: AppLocalizations.of(context)
                                .mStaticLinkNotAvailable,
                            bgColor: AppColors.greys87);
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(width: 1, color: AppColors.darkBlue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Text(
                      isEventCompleted() == EnglishLang.completed
                          ? AppLocalizations.of(context).mStaticEventIsCompleted
                          : isEventCompleted() == EnglishLang.notStarted
                              ? AppLocalizations.of(context)
                                  .mStaticEventIsNotCompleted
                              : AppLocalizations.of(context).mStaticJoinnow,
                      style: GoogleFonts.lato(
                          color: AppColors.darkBlue,
                          fontSize: 14,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
              Container(
                color: AppColors.black40.withOpacity(0.1),
                margin: EdgeInsets.only(top: 16),
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.topLeft,
                      child: Text(
                        formateDate(widget.eventDetail.startDate),
                        style: GoogleFonts.montserrat(
                            decoration: TextDecoration.none,
                            color: AppColors.greys87,
                            fontSize: 14,
                            letterSpacing: 0.25,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    Container(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          _formatTimeIn12hourFormat(
                                  widget.eventDetail.startTime) +
                              ' - ' +
                              _formatTimeIn12hourFormat(
                                  widget.eventDetail.endTime),
                          style: GoogleFonts.montserrat(
                              decoration: TextDecoration.none,
                              color: AppColors.black40,
                              fontSize: 14,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    AppLocalizations.of(context).mEventsEventType,
                    style: GoogleFonts.montserrat(
                        decoration: TextDecoration.none,
                        color: AppColors.darkBlue,
                        fontSize: 16,
                        letterSpacing: 0.25,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    widget.eventDetail.eventType,
                    style: GoogleFonts.montserrat(
                        decoration: TextDecoration.none,
                        fontSize: 14,
                        fontWeight: FontWeight.w400),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    AppLocalizations.of(context).mEventsHostedBy,
                    style: GoogleFonts.montserrat(
                        decoration: TextDecoration.none,
                        color: AppColors.darkBlue,
                        fontSize: 16,
                        letterSpacing: 0.25,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    widget.eventDetail.source,
                    style: GoogleFonts.montserrat(
                        decoration: TextDecoration.none,
                        fontSize: 14,
                        fontWeight: FontWeight.w400),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    AppLocalizations.of(context).mEventsLastUpdatedOn +
                        formateDate(widget.eventDetail.lastUpdatedOn),
                    style: GoogleFonts.montserrat(
                        decoration: TextDecoration.none,
                        color: AppColors.greys60,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
            margin: const EdgeInsets.only(bottom: 15, top: 4),
            padding: const EdgeInsets.fromLTRB(10, 15, 20, 20),
            width: double.infinity,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  AppLocalizations.of(context).mEventsDescription,
                  style: GoogleFonts.montserrat(
                      decoration: TextDecoration.none,
                      color: AppColors.greys87,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  (trimText &&
                          widget.eventDetail.description.length > _maxLength)
                      ? widget.eventDetail.description
                              .substring(0, _maxLength - 1) +
                          '...'
                      : widget.eventDetail.description,
                  style: GoogleFonts.montserrat(
                      decoration: TextDecoration.none,
                      color: AppColors.greys87,
                      fontSize: 16,
                      height: 1.5,
                      fontWeight: FontWeight.w400),
                ),
              ),
              widget.eventDetail.description != null
                  ? (widget.eventDetail.description.length > _maxLength)
                      ? Padding(
                          padding: const EdgeInsets.all(10),
                          child: Center(
                            child: InkWell(
                                onTap: () => _toogleReadMore(),
                                child: Text(
                                  trimText
                                      ? AppLocalizations.of(context)
                                          .mCommonReadMore
                                      : AppLocalizations.of(context)
                                          .mStaticShowLess,
                                  style: GoogleFonts.montserrat(
                                      decoration: TextDecoration.none,
                                      color: AppColors.primaryThree,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                )),
                          ))
                      : Center()
                  : Center()
            ])),
        Visibility(
          visible: widget.eventDetail.creatorDetails.length > 0,
          child: Container(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 15),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 10, 20),
                      child: Text(
                        AppLocalizations.of(context).mEventsPresenters,
                        style: GoogleFonts.montserrat(
                            decoration: TextDecoration.none,
                            color: AppColors.greys87,
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    // for (int j = 0; j < 1; j++)
                    //   Author(
                    //       name: widget.course['creatorContacts'][j]['name'],
                    //       designation: 'Author'),
                    // Author(
                    //     name: 'Jayasree Talpade',
                    //
                    //  designation: 'Joint Secretary at Tourism'),
                    Container(
                      height: widget.eventDetail.creatorDetails.length * 85.0,
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: widget.eventDetail.creatorDetails.length,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return Author(
                              name: widget.eventDetail.creatorDetails[index]
                                      ['name'] ??
                                  widget.eventDetail.creatorDetails[index]
                                      ['firstname'],
                              designation: 'Host');
                        },
                      ),
                    )
                  ])),
        ),
        Visibility(
          visible: widget.eventDetail.learningObjective.isNotEmpty,
          child: Container(
              padding: const EdgeInsets.fromLTRB(10, 20, 0, 15),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
                      child: Text(
                        AppLocalizations.of(context).mEventsAgenda,
                        style: GoogleFonts.montserrat(
                            decoration: TextDecoration.none,
                            color: AppColors.greys87,
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
                      child: Text(
                        widget.eventDetail.learningObjective,
                        style: GoogleFonts.montserrat(
                            decoration: TextDecoration.none,
                            color: AppColors.greys87,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                  ])),
        ),
        // Follow Us
        FollowUsOnSocialMedia(),
      ],
    ));
  }

  Widget roundedButton(
      {String buttonLabel = '',
      Color bgColor = AppColors.black,
      Color textColor = AppColors.appBarBackground,
      VoidCallback onCallBack}) {
    var optionButton = InkWell(
      onTap: onCallBack,
      child: Container(
        alignment: FractionalOffset.center,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.all(const Radius.circular(20.0)),
        ),
        child: Text(
          buttonLabel,
          style: GoogleFonts.lato(
              decoration: TextDecoration.none,
              color: textColor,
              fontSize: 14,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w700),
        ),
      ),
    );
    return optionButton;
  }
}
