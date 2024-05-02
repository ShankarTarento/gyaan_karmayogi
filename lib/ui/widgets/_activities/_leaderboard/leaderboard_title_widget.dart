import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import '../../../../constants/_constants/color_constants.dart';
import '../../../../util/faderoute.dart';
import '../../../screens/_screens/profile_screen.dart';

class LeaderboardTitleWidget extends StatelessWidget {
  final String rank;

  const LeaderboardTitleWidget({Key key, this.rank}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            FadeRoute(
              page: ProfileScreen(
                showMyActivity: true,
                scrollOffset: 280.0,
              ),
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(AppLocalizations.of(context).mLeaderboard,
                    style: GoogleFonts.lato(
                      color: AppColors.greys87,
                      fontWeight: FontWeight.w400,
                      fontSize: 12.sp,
                      letterSpacing: 0.12,
                    )),
              ],
            ),
            SizedBox(
              height: 8.w,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                getImage('assets/img/leaderboard_icon.svg'),
                SizedBox(width: 8.w),
                Text(
                    '${Helper.numberWithSuffix(int.parse(rank ?? '0'))} ${AppLocalizations.of(context).mRank}',
                    style: GoogleFonts.lato(
                      color: AppColors.greys87,
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                      letterSpacing: 0.12,
                    ))
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget getImage(imagePath) {
    return SvgPicture.asset(
      imagePath,
      width: 24.w,
      height: 26.w,
    );
  }
}
