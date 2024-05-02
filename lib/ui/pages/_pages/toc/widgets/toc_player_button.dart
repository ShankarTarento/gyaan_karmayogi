import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:google_fonts/google_fonts.dart';

import '../../../../../constants/index.dart';

class TocPlayerButton extends StatelessWidget {
  final int courseIndex;
  final VoidCallback clickedPrevious;
  final VoidCallback clickedNext;
  final VoidCallback clickedFinish;
  final List resourceNavigateItems;

  const TocPlayerButton(
      {Key key,
      @required this.courseIndex,
      @required this.resourceNavigateItems,
      this.clickedPrevious,
      this.clickedNext,
      this.clickedFinish})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () {
                if (courseIndex > 0) {
                  clickedPrevious();
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  AppLocalizations.of(context).mStaticPrevious,
                  style: GoogleFonts.lato(
                      color: AppColors.darkBlue,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      letterSpacing: 0.25,
                      height: 1.429),
                ),
              ),
            ),
            courseIndex == resourceNavigateItems.length - 1
                ? InkWell(
                    onTap: () {
                      clickedFinish();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(
                        AppLocalizations.of(context).mStaticFinish,
                        style: GoogleFonts.lato(
                            color: AppColors.darkBlue,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            letterSpacing: 0.25,
                            height: 1.429),
                      ),
                    ),
                  )
                : InkWell(
                    onTap: () {
                      clickedNext();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(
                        AppLocalizations.of(context).mStaticNext,
                        style: GoogleFonts.lato(
                            color: AppColors.darkBlue,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            letterSpacing: 0.25,
                            height: 1.429),
                      ),
                    ),
                  ),
          ],
        ));
  }
}
