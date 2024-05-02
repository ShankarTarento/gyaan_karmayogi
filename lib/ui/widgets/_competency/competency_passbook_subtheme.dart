import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../constants/index.dart';
import '../index.dart';

class CompetencyPassbookSubtheme extends StatefulWidget {
  final List competencySubthemes;
  const CompetencyPassbookSubtheme(
      {Key key, @required this.competencySubthemes})
      : super(key: key);

  @override
  State<CompetencyPassbookSubtheme> createState() =>
      _CompetencyPassbookSubthemeState();
}

class _CompetencyPassbookSubthemeState
    extends State<CompetencyPassbookSubtheme> {
  final double leftPadding = 20.0;
  bool viewMore = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: leftPadding),
      child: Wrap(
        runSpacing: 20,
        spacing: 10,
        alignment: WrapAlignment.start,
        children: [
          ...widget.competencySubthemes
              .take(viewMore
                  ? widget.competencySubthemes.length
                  : widget.competencySubthemes.length > SUBTHEME_VIEW_COUNT
                      ? SUBTHEME_VIEW_COUNT
                      : widget.competencySubthemes.length)
              .map<Widget>((subthemes) => CompetencyPassbookThemeChipsWidget(
                  chipText: subthemes.name))
              .toList(),
          GestureDetector(
            onTap: () {
              setState(() {
                viewMore = !viewMore;
              });
            },
            child: widget.competencySubthemes.length > SUBTHEME_VIEW_COUNT
                ? Container(
                    padding: EdgeInsets.all(8),
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      viewMore
                          ? AppLocalizations.of(context).mCompetencyViewMoreTxt
                          : AppLocalizations.of(context).mCompetencyViewLessTxt,
                      style: GoogleFonts.lato(
                          decoration: TextDecoration.underline,
                          height: 1.5,
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
