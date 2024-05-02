import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';

import '../../../../constants/_constants/color_constants.dart';

class LeaderboardHeadingWidget extends StatelessWidget {
  final int month;
  final String year;
  const LeaderboardHeadingWidget({this.month, this.year, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8).w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                    AppLocalizations.of(context).mMyActivityLeaderboardHeading,
                    style: GoogleFonts.lato(
                      color: AppColors.whiteGradientOne,
                      fontWeight: FontWeight.w700,
                      fontSize: 18.sp,
                      letterSpacing: 0.25.sp,
                    )),
              ),
              JustTheTooltip(
                showDuration: const Duration(seconds: 3),
                tailBaseWidth: 16.w,
                triggerMode: TooltipTriggerMode.tap,
                backgroundColor: Colors.black,
                child: Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0).w,
                    child: Icon(Icons.info_outline,
                        color: AppColors.whiteGradientOne, size: 16.w),
                  ),
                ),
                content: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.all(Radius.circular(10).w),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(12.0).w,
                    child: Text(
                      AppLocalizations.of(context)
                          .mMyActivityLeaderboardTooltipInfo,
                      style: GoogleFonts.montserrat(
                          color: Colors.white,
                          height: 1.33.w,
                          letterSpacing: 0.25,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                margin: EdgeInsets.all(40.w),
              ),
            ],
          ),
          Text(
              '${DateFormat('MMMM').format(DateTime(0, month))} ${year}',
              textAlign: TextAlign.start,
              style: GoogleFonts.lato(
                color: AppColors.primaryOne,
                fontWeight: FontWeight.w700,
                fontSize: 17.sp,
                letterSpacing: 0.12,
              )),
        ],
      ),
    );
  }
}
