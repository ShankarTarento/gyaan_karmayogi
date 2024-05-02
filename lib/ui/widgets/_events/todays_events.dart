import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/models/_models/event_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_events/no_events.dart';
import 'package:karmayogi_mobile/ui/widgets/primary_category_widget.dart';
import 'package:karmayogi_mobile/util/helper.dart';

import '../../../constants/_constants/color_constants.dart';
import '../../../util/faderoute.dart';
import '../../pages/_pages/events/event_details_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TodaysEvents extends StatefulWidget {
  final List<Event> events;
  const TodaysEvents({Key key, this.events}) : super(key: key);

  @override
  State<TodaysEvents> createState() => _TodaysEventsState();
}

class _TodaysEventsState extends State<TodaysEvents> {
  _formatTimeIn12hourFormat(time) {
    int _hour = int.parse(time.substring(0, 2));
    String _min = time.substring(3, 5);
    String timeIn12HourFormat = time.substring(0, 5);
    timeIn12HourFormat = (_hour < 12
        ? ' $timeIn12HourFormat am'
        : '${(_hour - 12).toString() + ':' + _min} pm');
    return timeIn12HourFormat;
  }

  formatTime(time) {
    return time.substring(0, 5);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              widget.events.length == 1
                  ? AppLocalizations.of(context).mEventsLabelTodayEvent
                  : AppLocalizations.of(context).mEventsLabelTodayEvent,
              style: GoogleFonts.lato(
                color: AppColors.greys87,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          widget.events.length > 0
              ? ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: widget.events.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () => Navigator.push(
                          context,
                          FadeRoute(
                              page: EventDetailsPage(
                            eventId: widget.events[index].identifier,
                          ))),
                      child: Container(
                        margin: EdgeInsets.all(8),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.appBarBackground,
                          borderRadius:
                              BorderRadius.all(const Radius.circular(4.0)),
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 16.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Stack(
                                  alignment: AlignmentDirectional.topEnd,
                                  children: [
                                    Image(
                                      height: 120,
                                      width: 120,
                                      fit: BoxFit.fitWidth,
                                      image: NetworkImage(
                                          Helper.convertPortalImageUrl(
                                              widget.events[index].eventIcon)),
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return SizedBox(
                                          width: 50,
                                          height: 50,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: CircularProgressIndicator(
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes
                                                  : null,
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              SizedBox(
                                        height: 120,
                                        width: 120,
                                        child: Icon(
                                          Icons.error,
                                          color: AppColors.darkGrey,
                                        ),
                                      ),
                                    ),
                                    widget.events[index].status != null &&
                                            isEventCompleted(
                                                widget.events[index])
                                        ? Container(
                                            width: 60,
                                            padding: EdgeInsets.symmetric(
                                                vertical: 4),
                                            margin: EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: AppColors.avatarRed,
                                              borderRadius: BorderRadius.all(
                                                  const Radius.circular(20.0)),
                                            ),
                                            child: Center(
                                              child: Text(
                                                  '\u2022 ' +
                                                      widget
                                                          .events[index].status
                                                          .toString()
                                                          .toUpperCase(),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  style: GoogleFonts.lato(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    letterSpacing: 0.43,
                                                    fontWeight: FontWeight.w700,
                                                  )),
                                            ))
                                        : Center(),
                                  ],
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                PrimaryCategoryWidget(
                                  contentType: widget.events[index].eventType,
                                  addedMargin: true,
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width - 180,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0),
                                    child: Text(widget.events[index].name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.lato(
                                          color: AppColors.greys60,
                                          fontSize: 16,
                                          letterSpacing: 0.12,
                                          fontWeight: FontWeight.w700,
                                        )),
                                  ),
                                ),
                                Text(
                                    '${_formatTimeIn12hourFormat(widget.events[index].startTime)} - ${_formatTimeIn12hourFormat(widget.events[index].endTime)}',
                                    style: GoogleFonts.lato(
                                      color: AppColors.greys87,
                                      fontSize: 14,
                                      letterSpacing: 0.25,
                                      fontWeight: FontWeight.w400,
                                    )),
                                roundedButton(
                                  buttonLabel: AppLocalizations.of(context)
                                      .mStaticJoinEvent,
                                  bgColor: AppColors.darkBlue,
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              : NoEventsWidget(),
        ],
      ),
    );
  }

  bool isEventCompleted(Event event) {
    int timestampNow = DateTime.now().millisecondsSinceEpoch;
    String start = event.startDate + ' ' + formatTime(event.startTime);
    DateTime startDate = DateTime.parse(start);
    int timestampStartEvent = startDate.microsecondsSinceEpoch;
    double eventStartTime = timestampStartEvent / 1000;
    String expiry = event.startDate + ' ' + formatTime(event.endTime);
    DateTime expireDate = DateTime.parse(expiry);
    int timestampExpireEvent = expireDate.microsecondsSinceEpoch;
    double eventExpireTime = timestampExpireEvent / 1000;
    return timestampNow <= eventExpireTime && timestampNow >= eventStartTime;
  }

  Widget roundedButton(
      {String buttonLabel = '',
      Color bgColor = AppColors.black,
      Color textColor = AppColors.appBarBackground}) {
    var optionButton = Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(vertical: 8.0),
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
    );
    return optionButton;
  }
}
