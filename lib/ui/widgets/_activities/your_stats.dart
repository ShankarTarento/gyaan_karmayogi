import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../constants/index.dart';

class YourStats extends StatelessWidget {
  final int progress;
  final int certificate;
  final String learningHour;
  @required
  final int karmaPoints;

  const YourStats(
      this.progress, this.certificate, this.learningHour, this.karmaPoints,
      {Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        statusWidget(progress.toString(), 'assets/img/play_course.svg',
            AppLocalizations.of(context).mStaticInprogress, context),
        SizedBox(width: 8),
        statusWidget(
            certificate.toString(),
            'assets/img/certificate_icon_orange.svg',
            AppLocalizations.of(context).mCommonCertificates,
            context),
        SizedBox(width: 8),
        statusWidget(learningHour.toString(), 'assets/img/time_active.svg',
            AppLocalizations.of(context).mCommonLearningHours, context),
        SizedBox(width: 8),
        statusWidget(karmaPoints.toString(), 'assets/img/karma_point_badge.svg',
            AppLocalizations.of(context).mStaticKarmaPoints, context)
      ],
    );
  }

  Widget statusWidget(count, imagePath, text, context) {
    return Flexible(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            imagePath,
            width: 20.0,
            height: 20.0,
          ),
          SizedBox(height: 4),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.055,
            child: Text(
              text,
              style: GoogleFonts.lato(
                color: AppColors.greys60,
                fontWeight: FontWeight.w400,
                fontSize: 12,
                letterSpacing: 0.12,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: 4),
          Text(count,
              style: GoogleFonts.lato(
                color: AppColors.darkBlue,
                fontWeight: FontWeight.w600,
                fontSize: 16,
                letterSpacing: 0.12,
              )),
        ],
      ),
    );
  }
}
