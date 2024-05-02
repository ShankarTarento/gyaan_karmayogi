import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../constants/_constants/color_constants.dart';
import '../../../../models/_models/leaderboard_model.dart';
import '../../../../respositories/_respositories/profile_repository.dart';
import 'leaderboard_frame_month_content_widget.dart';

class LeaderboardFameWidget extends StatefulWidget {
  LeaderboardFameWidget({Key key}) : super(key: key);

  @override
  State<LeaderboardFameWidget> createState() => _LeaderboardFameWidgetState();
}

class _LeaderboardFameWidgetState extends State<LeaderboardFameWidget> {
  Future<dynamic> getLeaderboardDataFuture;

  @override
  void initState() {
    super.initState();
    _getLeaderboardData();
  }

  void _getLeaderboardData() async {
    getLeaderboardDataFuture = Provider.of<ProfileRepository>(context, listen: false).getLeaderboardData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getLeaderboardDataFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          List<LeaderboardModel> _leaderboardDataList = List<LeaderboardModel>.from(snapshot.data
              .map((data) => LeaderboardModel.fromJson(data))
              .toList());
          if (_leaderboardDataList.isNotEmpty){
            return Container(
                margin: EdgeInsets.only(top: 16.w),
                decoration: BoxDecoration(
                  color: AppColors.appBarBackground,
                  borderRadius:
                  BorderRadius.all(Radius.circular(16.w)),
                ),
                child: LeaderBoardFrameMonthContentWidget(leaderboardDataList: _leaderboardDataList));
          } else {
            return SizedBox.shrink();
          }
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }
}
