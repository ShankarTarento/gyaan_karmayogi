import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/index.dart';

import '../index.dart';

class CompetencyPassbookCardWidget extends StatelessWidget {
  final dynamic themeItem;
  final VoidCallback callBack;
  const CompetencyPassbookCardWidget(
      {Key key, @required this.themeItem, @required this.callBack})
      : super(key: key);

  final double leftPadding = 20.0;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: callBack,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(0.5),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: themeItem.competencyArea.name.toString().toLowerCase() ==
                    CompetencyAreas.behavioural
                ? AppColors.orangeShade1
                : themeItem.competencyArea.name.toString().toLowerCase() ==
                        CompetencyAreas.domain
                    ? AppColors.purpleShade1
                    : AppColors.pinkShade1),
        child: Container(
            width: double.infinity,
            margin: EdgeInsets.only(
              top: 10,
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppColors.appBarBackground),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(leftPadding),
                        child: Text(
                          themeItem.theme.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: GoogleFonts.montserrat(
                              height: 1.5,
                              color: AppColors.darkBlue,
                              fontSize: 20,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: leftPadding, right: leftPadding),
                      child: SvgPicture.asset(
                        getImageUrl(themeItem.competencyArea.name),
                        width: 74.0,
                        height: 46.0,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          left: leftPadding, right: leftPadding),
                      child: SvgPicture.asset(
                        'assets/img/Learn.svg',
                        color: AppColors.darkBlue,
                        width: 24.0,
                        height: 24.0,
                      ),
                    ),
                    Text(
                      themeItem.courses.length.toString(),
                      style: GoogleFonts.lato(
                          height: 1.5,
                          color: AppColors.darkBlue,
                          fontSize: 12,
                          fontWeight: FontWeight.w400),
                    ),
                    Spacer(),
                  ],
                ),
                Divider(
                  height: 30,
                  thickness: 1,
                  color: AppColors.grey08,
                ),
                CompetencyPassbookSubtheme(
                    competencySubthemes: themeItem.competencySubthemes),
                SizedBox(
                  height: 20,
                )
              ],
            )),
      ),
    );
  }

  String getImageUrl(String name) {
    if (name.toLowerCase() == CompetencyAreas.behavioural) {
      return 'assets/img/behavioural_competency.svg';
    } else if (name.toLowerCase() == CompetencyAreas.domain) {
      return 'assets/img/domain_competency.svg';
    } else if (name.toLowerCase() == CompetencyAreas.functional) {
      return 'assets/img/functional_competency.svg';
    } else {
      return 'assets/img/functional_competency.svg';
    }
  }
}
