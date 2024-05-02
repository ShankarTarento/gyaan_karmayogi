import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../constants/index.dart';

class AutoplayNextResource extends StatelessWidget {
  const AutoplayNextResource({
    Key key,
    this.clickedPlayNextResource,
    this.cancelTimer,
  }) : super(key: key);

  final VoidCallback clickedPlayNextResource;
  final VoidCallback cancelTimer;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: () => clickedPlayNextResource(),
          child: Container(
            padding: EdgeInsets.all(6),
            child: Text(
              AppLocalizations.of(context) != null
                  ? AppLocalizations.of(context).mUpNext
                  : 'Up Next',
              style: GoogleFonts.montserrat(
                  color: AppColors.appBarBackground,
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  letterSpacing: 0.12),
            ),
          ),
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            CircularCountDownTimer(
              duration: 30,
              fillColor: AppColors.appBarBackground,
              backgroundColor: AppColors.greys87,
              height: 50,
              ringColor: AppColors.greys87,
              width: 50,
              onComplete: () => clickedPlayNextResource(),
            ),
            Icon(Icons.play_arrow_rounded,
                size: 24, color: AppColors.appBarBackground),
          ],
        ),
        InkWell(
          onTap: () => cancelTimer(),
          child: Container(
            padding: EdgeInsets.all(6),
            child: Text(
              AppLocalizations.of(context) != null
                  ? AppLocalizations.of(context).mStaticCancel
                  : 'Cancel',
              style: GoogleFonts.montserrat(
                  color: AppColors.appBarBackground,
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  letterSpacing: 0.12),
            ),
          ),
        ),
      ],
    );
  }
}
