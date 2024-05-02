import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../constants/index.dart';

// ignore: must_be_immutable
class CourseAtGlanceWidget extends StatelessWidget {
  CourseAtGlanceWidget(
      {Key key,
      @required this.courseInfo,
      @required this.courseHierarchyInfo,
      @required this.isExpanded,
      this.itemCount = 0,
      this.duration,
      this.isCourse = true})
      : super(key: key);
  final courseInfo;
  final courseHierarchyInfo;
  final bool isExpanded, isCourse;
  final int itemCount;
  final String duration;
  int moduleCount = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 8),
      child: Wrap(
        children: [getItemCounts(context)],
      ),
    );
  }

  Widget getItemCounts(BuildContext context) {
    var courseWithId;
    Map mimeTypesCount;
    int moduleItemCount = 0;
    if (courseHierarchyInfo != null &&
        courseHierarchyInfo['children'] != null) {
      courseWithId = courseHierarchyInfo['children'].firstWhere(
          (item) => item['identifier'] == courseInfo['parentCourseId'],
          orElse: () => -1);
      if (courseWithId != -1 && courseWithId['mimeTypesCount'] != null) {
        mimeTypesCount = jsonDecode(courseWithId['mimeTypesCount']);
      }
    }
    if (isCourse &&
        mimeTypesCount != null &&
        mimeTypesCount[EMimeTypes.collection] != null &&
        mimeTypesCount[EMimeTypes.collection] > 0) {
      moduleCount = mimeTypesCount[EMimeTypes.collection];
    }
    if (!isCourse && courseWithId != -1) {
      var moduleInfo = courseWithId['children'].firstWhere(
        (item) {
          var leafNodes = item['leafNodes'] as List<dynamic>;
          if (leafNodes != null) {
            return leafNodes.contains(courseInfo['identifier']);
          } else if (leafNodes != null) {
            return leafNodes.contains(courseInfo['parentCourseId']);
          }
          return false;
        },
        orElse: () => -1,
      );

      if (moduleInfo != -1 && moduleInfo['leafNodesCount'] != null) {
        moduleItemCount = moduleInfo['leafNodesCount'];
      }
    }

    return Wrap(
        direction: Axis.horizontal,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SvgPicture.asset(
            isCourse
                ? 'assets/img/course_icon.svg'
                : 'assets/img/icons-file-types-module.svg',
            color: isExpanded && isCourse
                ? AppColors.appBarBackground
                : AppColors.greys60,
            height: 16,
            width: 16,
          ),
          if (duration != null || courseInfo['courseDuration'] != null) ...[
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: textWidget(
                  duration != null ? duration : courseInfo['courseDuration']),
            )
          ],
          if (moduleCount > 0 && isCourse) ...[
            textWidget(
                '  \u2022  $moduleCount ${AppLocalizations.of(context).mLearnModules}'),
          ],
          if (itemCount > 0) ...[
            isCourse?
             textWidget('  \u2022  $itemCount ${AppLocalizations.of(context).mStaticItems}')
             : moduleItemCount > 0 ?
                textWidget('  \u2022  $moduleItemCount ${AppLocalizations.of(context).mStaticItems}')
                : SizedBox.shrink()
          ] else if (courseWithId != -1 &&courseWithId['leafNodesCount'] != null &&
              courseWithId['leafNodesCount'] > 0) ...[
            textWidget(
                '  \u2022  ${courseWithId['leafNodesCount']} ${AppLocalizations.of(context).mStaticItems}'),
          ],
        ]);
  }

  Text textWidget(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: GoogleFonts.lato(
          height: 1.33,
          letterSpacing: 0.25,
          color: isExpanded && isCourse
              ? AppColors.appBarBackground
              : AppColors.greys60,
          fontSize: 12,
          fontWeight: FontWeight.w400),
    );
  }
}
