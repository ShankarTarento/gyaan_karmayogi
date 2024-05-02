import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../constants/index.dart';
import '../../../../../respositories/_respositories/learn_repository.dart';
import '../pages/services/toc_services.dart';

class TocAppbarWidget extends StatelessWidget {
  final bool isOverview;
  final bool showCourseShareOption;
  Function courseShareOptionCallback;
  final bool isPlayer;
  final String courseId;
  TocAppbarWidget(
      {Key key,
      @required this.isOverview,
      this.showCourseShareOption,
      this.courseShareOptionCallback,
      this.isPlayer = false,
      this.courseId})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    bool isPressed = false;
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.darkBlue,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          size: 24,
          color: AppColors.appBarBackground,
        ),
        onPressed: () {
          if (!isPressed) {
            isPressed = true;
            if (isPlayer) {
              Future.delayed(Duration(milliseconds: 500), () {
                if (isOverview) {
                  clearCourseInfo(context);
                }
                Navigator.pop(context);
              });
            } else {
              if (isOverview) {
                clearCourseInfo(context);
              }
              Navigator.pop(context);
            }
          }
        },
      ),
      actions: [
        IconButton(
          icon: showCourseShareOption
              ? Icon(
                  Icons.share,
                  size: 24,
                  color: AppColors.appBarBackground,
                )
              : SizedBox.shrink(),
          onPressed: () {
            if (courseShareOptionCallback != null) {
              courseShareOptionCallback();
            }
          },
        ),
      ],
    );
  }

  void clearCourseInfo(BuildContext context) {
    Provider.of<LearnRepository>(context, listen: false).clearContentRead();
    Provider.of<LearnRepository>(context, listen: false)
        .clearCourseHierarchyInfo();
    Provider.of<LearnRepository>(context, listen: false).clearReview();
    Provider.of<TocServices>(context, listen: false).clearCourseProgress();
  }
}
