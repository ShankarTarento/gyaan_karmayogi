import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../constants/index.dart';
import '../../../models/_models/competency_data_model.dart';
import '../../../util/helper.dart';

class CompetencyPassbookThemeHeader extends StatelessWidget {
  const CompetencyPassbookThemeHeader({
    Key key,
    @required this.competencyTheme,
  }) : super(key: key);

  final CompetencyTheme competencyTheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: MediaQuery.of(context).size.width - 105,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                competencyTheme.theme.name,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: GoogleFonts.montserrat(
                    height: 1.5, fontSize: 20, fontWeight: FontWeight.w600),
              ),
              Text(
                competencyTheme.courses.first.completedOn != null
                    ? '${AppLocalizations.of(context).mCourseLastUpdatedOn} ${Helper.getDateTimeInFormat(competencyTheme.courses.first.completedOn, desiredDateFormat: 'MMM yyyy')}'
                    : '',
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.montserrat(
                    height: 1.5, fontSize: 12, fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),
        SvgPicture.asset(
          getImageUrl(competencyTheme.competencyArea.name),
          width: 95.0,
          height: 60.0,
        )
      ],
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
