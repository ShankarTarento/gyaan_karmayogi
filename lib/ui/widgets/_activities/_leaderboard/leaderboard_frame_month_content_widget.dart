import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../models/_models/leaderboard_model.dart';
import 'leaderboard_fame_list_item.dart';
import 'leaderboard_heading_widget.dart';
import 'leaderboard_rank_holder_widget.dart';

class LeaderBoardFrameMonthContentWidget extends StatefulWidget {
  List<LeaderboardModel> leaderboardDataList;

  LeaderBoardFrameMonthContentWidget({Key key, this.leaderboardDataList})
      : super(key: key);

  @override
  State<LeaderBoardFrameMonthContentWidget> createState() =>
      _LeaderBoardFrameMonthContentWidgetState();
}

class _LeaderBoardFrameMonthContentWidgetState
    extends State<LeaderBoardFrameMonthContentWidget> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(16).w),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(16).w),
        ),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 1.sw,
                  height: 0.6.sw + 20.w,
                  color: Color.fromRGBO(2, 75, 163, 1),
                ),
                Column(
                  children: [
                    Container(
                      width: 1.sw,
                      height: 0.6.sw + 4.w,
                      color: Color.fromRGBO(2, 75, 163, 1),
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 2).w,
                            child: Column(
                              children: [
                                //Leader board title
                                LeaderboardHeadingWidget(month: (int.parse(widget.leaderboardDataList[0].month??'1')), year: widget.leaderboardDataList[0].year??''),
                                //Rank holder
                                LeaderboardRankHolderWidget(leaderboardDataList: widget.leaderboardDataList,),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Stack(
                      children: [
                        Container(
                          child: Image(
                            image: AssetImage('assets/img/leaderboard_rank_base_banner_gradient.png'),
                            width: 1.sw,
                            height: 86.w,
                            fit: BoxFit.fill,
                          ),
                        ),
                        Container(
                          width: 1.sw,
                          height: 86.w,
                          child: SvgPicture.asset(
                            'assets/img/leaderboard_rank_base_banner.svg',
                            fit: BoxFit.fill,
                            width: 1.sw,
                            height: 86.w,
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ],
            ),
            //Leaderboard list
            if (widget.leaderboardDataList.length > 3)
              leaderboardMonthlyList(),
          ],
        ),
      ),
    );
  }

  Widget leaderboardMonthlyList() {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.leaderboardDataList.length-3,
          itemBuilder: (BuildContext context, int index) {
            return LeaderboardFameListItemWidget(
              leaderboardData: widget.leaderboardDataList[index+3],
            );
          }),
    );
  }
}
