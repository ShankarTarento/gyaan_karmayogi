import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/ui/widgets/_competency/competency_passbook_card.dart';
import 'package:provider/provider.dart';

import '../../../respositories/_respositories/learn_repository.dart';
import '../../pages/index.dart';

class CompetencyPassbookBodyWidget extends StatelessWidget {
  final String text;

  CompetencyPassbookBodyWidget({this.text});

  @override
  Widget build(BuildContext context) {
    return Consumer<LearnRepository>(builder: (context, learnRepository, _) {
      var allCompetencyTheme = learnRepository.competencyThemeList;
      if (allCompetencyTheme != null &&
          allCompetencyTheme.runtimeType != String) {
        return allCompetencyTheme.length > 0
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 40),
                    Text(
                      AppLocalizations.of(context).mCompetencyPassbookListTitle,
                      style: GoogleFonts.montserrat(
                          height: 1.5,
                          color: AppColors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 16),
                    ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount:
                            allCompetencyTheme.length > KARMAPOINT_DISPLAY_LIMIT
                                ? KARMAPOINT_DISPLAY_LIMIT
                                : allCompetencyTheme.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: CompetencyPassbookCardWidget(
                              themeItem: allCompetencyTheme[index],
                              callBack: () {
                                Navigator.pushNamed(
                                    context, AppUrl.competencyPassbookThemePage,
                                    arguments: {
                                      'competencyTheme':
                                          allCompetencyTheme[index],
                                    });
                              },
                            ),
                          );
                        }),
                    SizedBox(height: 30),
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                            context, AppUrl.competencyPassbookTabbedPage,
                            arguments: {'competency': allCompetencyTheme});
                      },
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          AppLocalizations.of(context).mCommonShowAll,
                          style: GoogleFonts.montserrat(
                              height: 1.5,
                              color: AppColors.darkBlue,
                              fontSize: 12,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                    SizedBox(height: 50),
                  ],
                ),
              )
            : NoDataWidget(
                message: AppLocalizations.of(context).mStaticCompetencyNotFound,
              );
      } else {
        return Center();
      }
    });
  }
}
