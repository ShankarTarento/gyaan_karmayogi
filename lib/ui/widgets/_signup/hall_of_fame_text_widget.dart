import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/feedback/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HallOfFameTextWidget extends StatelessWidget {
  const HallOfFameTextWidget(
      {Key key,
      @required this.title,
      @required this.fontSize,
      @required this.subTitle,
      this.showClock = false,
      this.showCrown = false})
      : super(key: key);
  final String title;
  final double fontSize;
  final String subTitle;
  final bool showClock;
  final bool showCrown;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Visibility(
          visible: showCrown,
          child: SizedBox(
            width: 46,
            height: 46,
            child: Image.asset(
              HallOfFameAssets.crown,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Row(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                color: AppColors.whiteGradientOne,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
            JustTheTooltip(
              showDuration: const Duration(seconds: 3),
              tailBaseWidth: 16,
              triggerMode: TooltipTriggerMode.tap,
              backgroundColor: AppColors.appBarBackground.withOpacity(1),
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: Visibility(
                  visible: showClock,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: SvgPicture.asset(
                      HallOfFameAssets.clock,
                      width: 16.0,
                      height: 16.0,
                    ),
                  ),
                ),
              ),
              content: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    AppLocalizations.of(context).mHallOfFameClockInfo,
                    style: GoogleFonts.montserrat(
                        color: AppColors.black,
                        height: 1.33,
                        letterSpacing: 0.25,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              margin: EdgeInsets.all(40),
            ),
          ],
        ),
        SizedBox(
          width: 70,
          child: Text(
            subTitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(
              color: AppColors.whiteGradientOne,
              fontSize: 7.0,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
