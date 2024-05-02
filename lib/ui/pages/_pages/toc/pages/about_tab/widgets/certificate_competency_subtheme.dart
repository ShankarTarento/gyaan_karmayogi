import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';

import '../../../../../../../constants/_constants/app_constants.dart';

class CertificateCompetencySubtheme extends StatefulWidget {
  final List competencySubthemes;
  const CertificateCompetencySubtheme(
      {Key key, @required this.competencySubthemes})
      : super(key: key);

  @override
  State<CertificateCompetencySubtheme> createState() =>
      _CertificateCompetencySubthemeState();
}

class _CertificateCompetencySubthemeState
    extends State<CertificateCompetencySubtheme> {
  final double leftPadding = 8.0;
  bool viewMore = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: leftPadding),
      child: Wrap(
        runSpacing: 5,
        spacing: 8,
        alignment: WrapAlignment.start,
        children: [
          ...widget.competencySubthemes
              .take(
                viewMore
                    ? widget.competencySubthemes.length
                    : widget.competencySubthemes.length > SUBTHEME_VIEW_COUNT
                        ? SUBTHEME_VIEW_COUNT
                        : widget.competencySubthemes.length,
              )
              .map<Widget>((subthemes) => Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(width: 1, color: AppColors.darkBlue)),
                    child: Text(
                      subthemes.competencySubTheme,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.lato(
                          color: AppColors.darkBlue,
                          fontSize: 9,
                          fontWeight: FontWeight.w400),
                    ),
                  ))
              .toList(),
          GestureDetector(
            onTap: () {
              setState(() {
                viewMore = !viewMore;
              });
            },
            child: widget.competencySubthemes.length > SUBTHEME_VIEW_COUNT
                ? Container(
                    padding: EdgeInsets.all(6),
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      viewMore
                          ? AppLocalizations.of(context).mStaticViewMore
                          : AppLocalizations.of(context).mStaticViewLess,
                      style: GoogleFonts.lato(
                          decoration: TextDecoration.underline,
                          color: AppColors.darkBlue,
                          fontSize: 12,
                          fontWeight: FontWeight.w400),
                    ),
                  )
                : SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
