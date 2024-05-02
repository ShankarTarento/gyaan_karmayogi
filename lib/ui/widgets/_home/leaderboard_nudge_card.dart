import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:lottie/lottie.dart';

import '../../../models/_models/leaderboard_model.dart';
class LeaderboardNudgeCard extends StatelessWidget {
  LeaderboardModel leaderboardData;
  LeaderboardNudgeCard(
      {Key key, this.leaderboardData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320.h,
      margin: EdgeInsets.fromLTRB(17, 16, 17, 16).w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(12.0).w),
      ),
      alignment: Alignment.center,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(0.0).w,
          child: Stack(
            children: [

              Center(
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                    child: ClipRRect(
                      // Apply corner radius
                      borderRadius: BorderRadius.circular(12.0).w,
                      child: Container(
                        color: Colors.black.withOpacity(0.6), // Adjust opacity as needed
                      ),
                    ),
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 64.w,
                    width: 64.w,
                    decoration: BoxDecoration(
                      color: AppColors.whiteGradientOne,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/img/leaderboard_icon.svg',
                        width: 32.w,
                        height: 32.w,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 8.w,
                  ),
                  Padding(padding: const EdgeInsets.all(16.0).w,
                    child: Text("Your dedication to learning is impressive! Congratulations on reaching the ${Helper.numberWithSuffix(leaderboardData.rank??'')} rank this month, which is ${(leaderboardData.previousRank - leaderboardData.rank)??''} ${(((leaderboardData.previousRank - leaderboardData.rank)??0) == 1) ? 'level' : 'levels'} higher than your previous ranking.",
                      style: GoogleFonts.lato(
                        color: AppColors.whiteGradientOne,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                        letterSpacing: 0.12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0).w,
                child: Lottie.asset('assets/animations/leaderboard_celebration.json' ?? '',
                  width: 300.h,
                  height: 300.h,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
