import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/models/_models/competency_passbook_model.dart';
import 'package:karmayogi_mobile/models/_models/new_competency_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'competency_card.dart';

class Competencies extends StatefulWidget {
  final List<CompetencyPassbook> competencies;
  const Competencies({Key key, @required this.competencies}) : super(key: key);

  @override
  State<Competencies> createState() => _CompetenciesState();
}

class _CompetenciesState extends State<Competencies> {
  initState() {
    super.initState();
    getCompetencies();
    selectedCompetencyArea = competencyAreas[0];
  }

  List<CompetencyArea> competencyAreas = [];
  getCompetencies() {
    for (var competency in widget.competencies) {
      var existingArea = competencyAreas.firstWhere(
          (area) => area.name == competency.competencyArea,
          orElse: () => null);

      if (existingArea == null) {
        existingArea = CompetencyArea(
            name: competency.competencyArea,
            id: competency.competencyAreaId.toString(),
            competencyTheme: []);
        competencyAreas.add(existingArea);
      }

      var existingTheme = existingArea.competencyTheme.firstWhere(
          (theme) => theme.name == competency.competencyTheme,
          orElse: () => null);

      if (existingTheme == null) {
        existingTheme = CompetencyTheme(
            id: competency.competencyThemeId.toString(),
            name: competency.competencyTheme,
            subTheme: []);
        existingArea.competencyTheme.add(existingTheme);
      }

      var subTheme = CompetencySubTheme(
          id: competency.competencySubThemeId.toString(),
          name: competency.competencySubTheme);
      existingTheme.subTheme.add(subTheme);
    }
  }

  CompetencyArea selectedCompetencyArea;
  int selectedIndex = 0;
  bool showAllItems = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).mCompetencies,
          style: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(
          height: 16,
        ),
        SizedBox(
          height: 32,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: competencyAreas.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) => GestureDetector(
              onTap: () {
                selectedIndex = index;
                selectedCompetencyArea = competencyAreas[index];
                setState(() {});
              },
              child: Container(
                  margin: EdgeInsets.only(right: 16),
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: selectedIndex == index
                          ? Color(0xff1B4CA1)
                          : Color(0xff000000).withOpacity(0.08),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    competencyAreas[index].name,
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      fontWeight: selectedIndex == index
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: selectedIndex == index
                          ? Color(0xff1B4CA1)
                          : Color(0xff000000).withOpacity(0.6),
                    ),
                  )),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: List.generate(
                competencyAreas[selectedIndex].competencyTheme.length,
                (index) => CompetencyCard(
                      competencyAreas: competencyAreas,
                      index: index,
                      selectedIndex: selectedIndex,
                    )),
          ),
        ),
      ],
    );
  }
}
