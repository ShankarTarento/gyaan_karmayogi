import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';

import '../../../../constants/_constants/storage_constants.dart';
import '../../../../models/_models/leaderboard_model.dart';
import '../../../../util/helper.dart';

class LeaderboardFameListItemWidget extends StatelessWidget {
  final LeaderboardModel leaderboardData;
  LeaderboardFameListItemWidget({Key key, this.leaderboardData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future<bool> isCurrentUser = _isCurrentUser(leaderboardData.userId);
    return FutureBuilder(
        future: isCurrentUser,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            bool _isCurrentUser = snapshot.data;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 2).w,
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 8).w,
                  decoration: BoxDecoration(
                    color: (_isCurrentUser)
                        ? AppColors.orangeShadow.withOpacity(0.4)
                        : AppColors.appBarBackground,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 28.w,
                            child: Text(
                              '${leaderboardData.rank}',
                              style: GoogleFonts.montserrat(
                                fontSize: 14.0.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(2, 0, 10, 0).w,
                            child: ((leaderboardData.profileImage ?? '') != '')
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(63).w,
                                    child: Image(
                                      height: 32.w,
                                      width: 32.w,
                                      fit: BoxFit.fitWidth,
                                      image: NetworkImage(
                                          leaderboardData.profileImage ?? ''),
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              SizedBox.shrink(),
                                    ),
                                  )
                                : Container(
                                    height: 32.w,
                                    width: 32.w,
                                    decoration: BoxDecoration(
                                      color: AppColors.networkBg[Random()
                                          .nextInt(AppColors.networkBg.length)],
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        Helper.getInitialsNew(
                                            leaderboardData.fullname),
                                        style: GoogleFonts.lato(
                                            color: AppColors.avatarText,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12.0.sp),
                                      ),
                                    ),
                                  ),
                          ),
                          Container(
                            width: 0.5.sw,
                            child: Text(
                              leaderboardData.fullname,
                              style: GoogleFonts.montserrat(
                                fontSize: 14.0.sp,
                                fontWeight: (_isCurrentUser)
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                          Spacer(),
                          Container(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 0),
                                  child: SvgPicture.asset(
                                    'assets/img/kp_icon.svg',
                                    width: 18.w,
                                    height: 18.w,
                                  ),
                                ),
                                Container(
                                  width: 28.w,
                                  margin: EdgeInsets.only(left: 4),
                                  child: Text(
                                    '${(leaderboardData.totalPoints ?? 0).toString()}',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 14.0.sp,
                                      fontWeight: (_isCurrentUser)
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                      if (((leaderboardData.rank) !=
                              (leaderboardData.previousRank)) &&
                          _isCurrentUser)
                        _updateOnRankWidget()
                    ],
                  ),
                ),
              ],
            );
          } else {
            return Container();
          }
        });
  }

  Widget _updateOnRankWidget() {
    return Visibility(
      visible: leaderboardData.previousRank != 0,
      child: Column(
        children: [
          SizedBox(
            height: 8.w,
          ),
          Row(
            children: [
              Row(
                children: [
                  ((leaderboardData.rank) < (leaderboardData.previousRank))
                      ? Icon(
                          Icons.arrow_drop_up,
                          size: 16.w,
                          color: AppColors.positiveLight,
                        )
                      : Icon(
                          Icons.arrow_drop_down,
                          size: 16.w,
                          color: AppColors.negativeLight,
                        ),
                  ((leaderboardData.rank) < (leaderboardData.previousRank))
                      ? Text(
                          '${leaderboardData.previousRank - leaderboardData.rank}',
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.lato(
                              color: AppColors.positiveLight,
                              fontWeight: FontWeight.w400,
                              fontSize: 10.sp,
                              letterSpacing: 0.25,
                              height: 1.3.w))
                      : Text(
                          '${leaderboardData.rank - leaderboardData.previousRank}',
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.lato(
                              color: AppColors.negativeLight,
                              fontWeight: FontWeight.w400,
                              fontSize: 10.sp,
                              letterSpacing: 0.25,
                              height: 1.3.w))
                ],
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12, right: 10).w,
                  child: Text(
                    'You were in the ${Helper.numberWithSuffix(leaderboardData.previousRank)} position last month',
                    style: GoogleFonts.montserrat(
                      fontSize: 10.0.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<bool> _isCurrentUser(String userId) async {
    final _storage = FlutterSecureStorage();
    var _userId = await _storage.read(key: Storage.wid);
    if (userId.toString() == _userId.toString()) {
      return true;
    }
    return false;
  }
}
