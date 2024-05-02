import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/models/_models/new_competency_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CompetencyCard extends StatefulWidget {
  final List<CompetencyArea> competencyAreas;
  final int selectedIndex;
  final int index;
  const CompetencyCard(
      {Key key,
      @required this.competencyAreas,
      @required this.index,
      @required this.selectedIndex})
      : super(key: key);

  @override
  State<CompetencyCard> createState() => _CompetencyCardState();
}

class _CompetencyCardState extends State<CompetencyCard> {
  bool showAllItems = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
      margin: EdgeInsets.only(top: 15, right: 15),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: widget.competencyAreas[widget.selectedIndex].name
                      .toString()
                      .toLowerCase() ==
                  CompetencyAreas.behavioural
              ? AppColors.orangeShade1
              : widget.competencyAreas[widget.selectedIndex].name
                          .toString()
                          .toLowerCase() ==
                      CompetencyAreas.domain
                  ? AppColors.purpleShade1
                  : AppColors.pinkShade1),
      child: Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.only(
          top: 4,
        ),
        padding: EdgeInsets.only(top: 8, bottom: 16, left: 6, right: 6),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Color(0xff00000).withOpacity(0.04)),
            color: AppColors.appBarBackground),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            widget.competencyAreas[widget.selectedIndex]
                .competencyTheme[widget.index].name,
            style: GoogleFonts.lato(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Wrap(
              alignment: !showAllItems
                  ? WrapAlignment.spaceBetween
                  : WrapAlignment.start,
              children: [
                ...List.generate(
                  showAllItems
                      ? widget.competencyAreas[widget.selectedIndex]
                          .competencyTheme[widget.index].subTheme.length
                      : 1,
                  (subthemeIndex) => Container(
                    margin: EdgeInsets.only(top: 8, right: 16),
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xff1B4CA1)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      widget
                          .competencyAreas[widget.selectedIndex]
                          .competencyTheme[widget.index]
                          .subTheme[subthemeIndex]
                          .name,
                      style: GoogleFonts.lato(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: Color(0xff1B4CA1),
                      ),
                    ),
                  ),
                ),
                widget.competencyAreas[widget.selectedIndex]
                            .competencyTheme[widget.index].subTheme.length >
                        1
                    ? GestureDetector(
                        onTap: () {
                          setState(() {
                            showAllItems = !showAllItems;
                          });
                        },
                        child: Text(
                          showAllItems
                              ? AppLocalizations.of(context)
                                  .mCompetencyViewLessTxt
                              : AppLocalizations.of(context)
                                  .mCompetencyViewMoreTxt,
                          style: GoogleFonts.lato(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Color(0xff1B4CA1),
                            height: 2.5,
                            decorationThickness: 1.0,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      )
                    : SizedBox()
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
