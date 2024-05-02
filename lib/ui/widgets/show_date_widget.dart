import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../../util/helper.dart';
import './../../../constants/index.dart';

class ShowDateWidget extends StatelessWidget {
  final String endDate;

  ShowDateWidget({@required this.endDate});

  @override
  Widget build(BuildContext context) {
    int dateDiff = getTimeDiff(endDate, DateTime.now().toString());
    return Container(
      decoration: BoxDecoration(
          color: Colors.transparent.withOpacity(0.5),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12.0),
              bottomRight: Radius.circular(8.0))),
      child: Container(
          margin: EdgeInsets.all(8),
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
              color: dateDiff < 0
                  ? AppColors.negativeLight
                  : dateDiff < 30
                      ? AppColors.verifiedBadgeIconColor
                      : AppColors.positiveLight,
              borderRadius: BorderRadius.all(const Radius.circular(6.0))),
          child: Text(
            dateDiff < 0
                ? AppLocalizations.of(context).mStaticOverdue
                : Helper.getDateTimeInFormat(endDate,
                    desiredDateFormat: IntentType.dateFormat2),
            style: GoogleFonts.lato(
                color: AppColors.appBarBackground,
                fontWeight: FontWeight.w400,
                fontSize: 10.0,
                letterSpacing: 0.5),
          )),
    );
  }

  int getTimeDiff(String date1, String date2) {
    return DateTime.parse(
            DateFormat('yyyy-MM-dd').format(DateTime.parse(date1)))
        .difference(DateTime.parse(
            DateFormat('yyyy-MM-dd').format(DateTime.parse(date2))))
        .inDays;
  }
}
