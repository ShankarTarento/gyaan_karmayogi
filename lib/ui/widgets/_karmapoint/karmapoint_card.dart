import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../constants/index.dart';
import '../../../util/helper.dart';
import '../index.dart';

class KarmapointCard extends StatelessWidget {
  final Map<dynamic, dynamic> kpItem;

  const KarmapointCard({Key key, @required this.kpItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String courseName = 'No course';
    bool isAcbp = false;
    // Get course name and checking is ACBP
    if (kpItem['addinfo'] != null) {
      if (kpItem['addinfo'].runtimeType == String && kpItem['addinfo'] != "") {
        var addinfo = jsonDecode(kpItem['addinfo']);
        if (addinfo['COURSENAME'] != null) {
          courseName = addinfo['COURSENAME'];
        }
        if (addinfo['ACBP'] != null) {
          isAcbp = addinfo['ACBP'];
        }
      } else if (kpItem['addinfo'] != null &&
          kpItem['addinfo'].runtimeType != String) {
        if (kpItem['addinfo']['COURSENAME'] != null) {
          courseName = kpItem['addinfo']['COURSENAME'];
        }
        if (kpItem['addinfo']['ACBP'] != null) {
          isAcbp = kpItem['addinfo']['ACBP'];
        }
      }
    }
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.only(top: 16),
      color: AppColors.appBarBackground,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TitleBoldWidget(getKarmaPointOperationType(
                      kpItem['operation_type'], context)),
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/img/kp_icon.svg',
                        width: 33.5,
                        height: 32,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '+${kpItem['points']}',
                        style: GoogleFonts.montserrat(
                            color: AppColors.verifiedBadgeIconColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            letterSpacing: 0.12),
                      )
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: TitleRegularGrey60(
                    courseName,
                    fontSize: 14,
                    color: AppColors.greys87,
                    maxLines: 2,
                  ),
                ),
                isAcbp
                    ? Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(63),
                            border: Border.all(color: AppColors.grey08),
                            color: AppColors.whiteGradientOne),
                        child: Text(
                          AppLocalizations.of(context).mStaticBonus.toUpperCase(),
                          style: GoogleFonts.lato(
                              color: AppColors.darkBlue,
                              fontSize: 14,
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.w700),
                        ),
                      )
                    : SizedBox.shrink()
              ],
            ),
            SizedBox(height: 8),
            TitleRegularGrey60(
              kpItem['credit_date'] != null
                  ? Helper.getDateTimeInFormat(
                      DateTime.fromMillisecondsSinceEpoch(kpItem['credit_date'])
                          .toString(),
                      desiredDateFormat: 'dd MMM yyyy')
                  : '',
              fontSize: 14,
            )
          ],
        ),
      ),
    );
  }

  String getKarmaPointOperationType(type, context) {
    String operationType;
    switch (type) {
      case OperationTypes.couseCompletion:
        operationType = AppLocalizations.of(context).mStaticCourseCompletion;
        break;
      case OperationTypes.firstEnrolment:
        operationType = AppLocalizations.of(context).mStaticFirstEnrolment;
        break;
      case OperationTypes.firstLogin:
        operationType = AppLocalizations.of(context).mStaticFirstLogin;
        break;
      case OperationTypes.rating:
        operationType = AppLocalizations.of(context).mCourseRating;
        break;
      default:
        operationType = type;
        break;
    }
    return operationType;
  }
}
