import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/models/_models/batch_attributes_model.dart';
import 'package:karmayogi_mobile/models/index.dart';
import 'package:karmayogi_mobile/services/_services/learn_service.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/blended_program_content/widgets/attendence_marker.dart';
import '../../../../../../../constants/_constants/app_constants.dart';
import '../../../../../../../util/helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SessionDetails extends StatefulWidget {
  final SessionDetailsV2 session;
  final Batch batch;
  final BatchAttributes selectedBatchAttributes;
  final Map<String, dynamic> courseDetails;
  final List<Course> enrollmentList;
  final Function() onAttendanceMarked;
  const SessionDetails(
      {Key key,
      @required this.session,
      @required this.batch,
      @required this.onAttendanceMarked,
      @required this.enrollmentList,
      @required this.selectedBatchAttributes,
      @required this.courseDetails})
      : super(key: key);

  @override
  State<SessionDetails> createState() => _SessionDetailsState();
}

class _SessionDetailsState extends State<SessionDetails> {
  @override
  void initState() {
    super.initState();
  }

  final LearnService learnService = LearnService();

  // BatchAttributes selectedBatchAttributes;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(children: [
        Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width / 1.4,
              child: Text(
                widget.session.title,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: 8,
            ),
            courseTypeButton(
              title: widget.session.sessionType,
            )
          ],
        ),
        SizedBox(
          height: 8,
        ),
        Row(
          children: [
            Text(
              Helper.getDateTimeInFormat(widget.session.startDate,
                  desiredDateFormat: IntentType.dateFormat2),
              style: GoogleFonts.lato(
                color: AppColors.greys60,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8),
              child: CircleAvatar(
                radius: 1,
                backgroundColor: AppColors.greys60,
              ),
            ),
            Icon(
              Icons.play_circle,
              color: AppColors.greys60,
            ),
            SizedBox(
              width: 6,
            ),
            Text(
              "${widget.session.sessionDuration}",
              style: GoogleFonts.lato(
                color: AppColors.greys60,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8),
              child: CircleAvatar(
                radius: 1,
                backgroundColor: AppColors.greys60,
              ),
            ),
            Text(
              "${widget.session.startTime} to ${widget.session.endTime}",
              style: GoogleFonts.lato(
                color: AppColors.greys60,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            )
          ],
        ),
        Container(
          margin: EdgeInsets.only(top: 16),
          padding: EdgeInsets.only(top: 16, left: 16, bottom: 16, right: 34),
          // height: 92,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: AppColors.orange32,
            border: Border.all(color: AppColors.primaryOne),
          ),
          child: Row(children: [
            SizedBox(
              width: MediaQuery.of(context).size.width / 1.6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.session.description,
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  widget.session.sessionAttendanceStatus
                      ? Text(
                          //    String formattedTime = DateFormat('h:mm a').format(DateTime.parse(widget.session.lastCompletedTime));

                          "Attendence marked @  ${getTImeFormat(widget.session.lastCompletedTime)}",
                          style: GoogleFonts.lato(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        )
                      : Text(
                          "After the batch starts, you will be able to mark the attendace ",
                          style: GoogleFonts.lato(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                ],
              ),
            ),
            Spacer(),
            AttendenceMarker(
              onAttendanceMarked: widget.onAttendanceMarked,
              enrollmentList: widget.enrollmentList,
              session: widget.session,
              batch: widget.batch,
              courseDetails: widget.courseDetails,
              selectedBatchAttributes: widget.selectedBatchAttributes,
            ),
          ]),
        )
      ]),
    );
  }

  Widget courseTypeButton({@required String title}) {
    return Container(
      height: 16,
      width: 37,
      padding: EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: title.toLowerCase() == "online"
            ? AppColors.positiveLight
            : AppColors.greys60,
      ),
      child: Center(
        child: Text(
          title,
          style: GoogleFonts.lato(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  String getTImeFormat(dateString) {
    String formattedDateString = dateString.substring(0, 19);
    DateTime dateTime = DateTime.parse(formattedDateString);

    return DateFormat('h:mm a').format(dateTime);
  }
}
